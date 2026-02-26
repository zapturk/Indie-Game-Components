extends Node2D
class_name GridMoverComponent

## Emitted when a grid step finishes. from_pos is where the parent was, to_pos is where it ended up.
## GridFollowerComponent listens to this to trace the leader's breadcrumb trail.
signal moved(from_pos: Vector2, to_pos: Vector2)

## The tile size of your grid (e.g., 16 or 32)
@export var grid_size: int = 32

## How fast the character slides between tiles
@export var move_speed: float = 0.2
@export var tween_type: Tween.TransitionType

var is_moving: bool = false
@onready var parent: Node2D = get_parent()

## The core function to move the character
func move_to(direction: Vector2) -> bool:
	if is_moving:
		return false
	
	# Calculate target position
	var target_pos = parent.global_position + (direction * grid_size)
	
	# 1. Collision Check (Integration with Story 3)
	if is_occupied(target_pos):
		return false
	
	# 2. Execute Movement
	_animate_move(target_pos)
	return true

func _animate_move(target_pos: Vector2) -> void:
	var from_pos: Vector2 = parent.global_position
	is_moving = true
	
	# Using a Tween for smooth pixel-art movement
	var tween = create_tween()
	tween.tween_property(parent, "global_position", target_pos, move_speed).set_trans(tween_type)
	
	await tween.finished
	is_moving = false
	moved.emit(from_pos, target_pos)

## Placeholder Collision logic
func is_occupied(_target_pos: Vector2) -> bool:
	# Later, you'll reference your TileMap here to check for walls
	return false
