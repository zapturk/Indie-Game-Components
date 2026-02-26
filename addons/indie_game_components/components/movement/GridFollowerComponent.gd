extends Node2D
class_name GridFollowerComponent

## Emitted when this follower finishes a step, passing the tile it just left.
## Connect a second GridFollowerComponent's leader to this node to chain party members.
signal moved(from_pos: Vector2, to_pos: Vector2)

## The node to follow. Must have either a GridMoverComponent or
## a GridFollowerComponent as a direct child so this component can
## subscribe to their "moved" signal.
@export var leader: Node2D

## Duration in seconds for each grid-cell step.
@export var move_speed: float = 0.2

## Tween easing style.
@export var tween_type: Tween.TransitionType = Tween.TRANS_SINE

## Toggle following on/off without removing the component.
@export var enabled: bool = true

var is_moving: bool = false

# Queue of grid positions to step through, oldest first.
var _position_queue: Array[Vector2] = []

@onready var parent: Node2D = get_parent()


func _ready() -> void:
	if leader == null:
		push_warning("GridFollowerComponent: no leader assigned on %s" % parent.name)
		return
	_connect_to_leader()


func _connect_to_leader() -> void:
	# Accept either a GridMoverComponent or another GridFollowerComponent as the source.
	var source: Node = null
	for child in leader.get_children():
		if child is GridMoverComponent or child is GridFollowerComponent:
			source = child
			break

	if source == null:
		push_warning(
			"GridFollowerComponent: leader '%s' has no GridMoverComponent or GridFollowerComponent child."
			% leader.name
		)
		return

	source.moved.connect(_on_leader_moved)


## Called whenever the leader finishes a grid step.
## from_pos is the tile the leader just vacated — that is where we want to go.
func _on_leader_moved(from_pos: Vector2, _to_pos: Vector2) -> void:
	if enabled:
		_position_queue.push_back(from_pos)


func _process(_delta: float) -> void:
	if is_moving or _position_queue.is_empty():
		return
	var next_pos: Vector2 = _position_queue.pop_front()
	_animate_move(next_pos)


func _animate_move(target_pos: Vector2) -> void:
	var from_pos: Vector2 = parent.global_position
	is_moving = true

	var tween = create_tween()
	tween.tween_property(parent, "global_position", target_pos, move_speed) \
		.set_trans(tween_type)

	await tween.finished
	is_moving = false
	moved.emit(from_pos, target_pos)
