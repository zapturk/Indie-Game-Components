extends Node
class_name EightDirFollowerComponent

## Emitted whenever the follower's facing direction changes.
## Hook this to the same AnimationTree logic you use for the leader.
signal direction_changed(new_direction: Vector2)

## The node to follow. Must be a Node2D or CharacterBody2D.
@export var leader: Node2D

## Movement speed in pixels per second. Should match the leader's speed.
@export var speed: float = 90.0

## How many pixels of trail to keep between the follower and the leader.
## Increase this for more party members further behind.
@export var separation: float = 24.0

## Toggle following without removing the component.
@export var enabled: bool = true

## Read-only: last non-zero facing direction (use to drive animations).
var facing: Vector2 = Vector2.DOWN

# Minimum leader movement before a new trail point is recorded.
const _RECORD_THRESHOLD: float = 2.0

var _trail: Array[Vector2] = []
var _parent: CharacterBody2D
var _prev_facing: Vector2 = Vector2.DOWN


func _ready() -> void:
	_parent = get_parent() as CharacterBody2D
	if _parent == null:
		push_error("EightDirFollowerComponent must be a child of a CharacterBody2D.")
		return
	if leader == null:
		push_warning("EightDirFollowerComponent: no leader assigned on %s" % _parent.name)
		return
	# Seed the trail so the follower doesn't jump on the first frame.
	_trail.append(leader.global_position)


func _physics_process(_delta: float) -> void:
	if not enabled or leader == null or _parent == null:
		return

	# --- Record leader trail ---
	var last_recorded: Vector2 = _trail.back()
	if leader.global_position.distance_to(last_recorded) >= _RECORD_THRESHOLD:
		_trail.push_back(leader.global_position)

	# --- Find the target position (separation pixels back along the trail) ---
	var target: Vector2 = _get_trail_target()

	# --- Move toward target ---
	var diff: Vector2 = target - _parent.global_position
	if diff.length() < 0.5:
		_parent.velocity = Vector2.ZERO
	else:
		var dir := diff.normalized()
		_parent.velocity = dir * speed
		facing = dir

	_parent.move_and_slide()
	_prune_trail()

	# Emit signal on facing change.
	if facing != _prev_facing:
		_prev_facing = facing
		direction_changed.emit(facing)


## Walk backwards along the trail until we've accumulated `separation` pixels,
## then return that point as our follow target.
func _get_trail_target() -> Vector2:
	if _trail.is_empty():
		return leader.global_position

	var dist: float = 0.0
	for i in range(_trail.size() - 1, 0, -1):
		dist += _trail[i].distance_to(_trail[i - 1])
		if dist >= separation:
			return _trail[i]

	# Not enough trail yet — stay at the oldest recorded point.
	return _trail[0]


## Discard trail points that are far enough past the follower's target
## so the array doesn't grow forever.
func _prune_trail() -> void:
	var keep_from: int = 0
	var dist: float = 0.0
	for i in range(_trail.size() - 1, 0, -1):
		dist += _trail[i].distance_to(_trail[i - 1])
		if dist >= separation:
			keep_from = i
			break
	if keep_from > 0:
		_trail = _trail.slice(keep_from)
