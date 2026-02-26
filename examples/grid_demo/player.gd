extends CharacterBody2D

## Player controller for the grid demo.
## Uses GridMoverComponent to move one tile at a time with arrow keys.

@onready var mover: GridMoverComponent = $GridMoverComponent

func _process(_delta: float) -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_up"): dir = Vector2.UP
	if Input.is_action_pressed("ui_down"): dir = Vector2.DOWN
	if Input.is_action_pressed("ui_left"): dir = Vector2.LEFT
	if Input.is_action_pressed("ui_right"): dir = Vector2.RIGHT

	if dir != Vector2.ZERO:
		mover.move_to(dir)
