extends Node
class_name EightDirMoverComponent

## Emitted every frame that the character is moving, with the normalized direction.
signal direction_changed(new_direction: Vector2)

## Movement speed in pixels per second.
@export var speed: float = 90.0

## When true, diagonal movement is normalized so it's the same speed as cardinal.
@export var normalize_diagonal: bool = true

## Multiplier applied when no input is held (set < 1.0 for friction/deceleration,
## or keep at 0.0 for instant stop like the original Zelda GBC games).
@export_range(0.0, 1.0) var friction: float = 0.0

## Read-only: the last non-zero direction the character was facing.
## Use this to drive your AnimationTree or Sprite2D flip.
var facing: Vector2 = Vector2.DOWN

var _parent: CharacterBody2D
var _input_dir: Vector2 = Vector2.ZERO
var _prev_facing: Vector2 = Vector2.DOWN


func _ready() -> void:
	_parent = get_parent() as CharacterBody2D
	if _parent == null:
		push_error(
			"EightDirMoverComponent must be a child of a CharacterBody2D. " +
			"Parent is: %s" % get_parent().get_class()
		)


func _physics_process(_delta: float) -> void:
	if _parent == null:
		return

	_input_dir = _get_input()

	if _input_dir != Vector2.ZERO:
		var move_dir := _input_dir.normalized() if normalize_diagonal else _input_dir
		_parent.velocity = move_dir * speed
		facing = _input_dir.normalized()
	else:
		# Apply friction (0 = instant stop, 1 = no slowdown)
		_parent.velocity = _parent.velocity * friction

	_parent.move_and_slide()

	# Emit signal only when facing direction changes.
	if facing != _prev_facing:
		_prev_facing = facing
		direction_changed.emit(facing)


## Override this function in a subclass to change the input source
## (e.g. AI steering, joystick, network input).
func _get_input() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_up", "ui_down")
	return dir
