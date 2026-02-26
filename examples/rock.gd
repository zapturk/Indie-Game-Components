extends CharacterBody2D


@onready var mover = $GridMoverComponent

func _process(_delta):
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):    
		input_dir = Vector2.UP
	if Input.is_action_pressed("ui_down"):  
		input_dir = Vector2.DOWN
	if Input.is_action_pressed("ui_left"):  
		input_dir = Vector2.LEFT
	if Input.is_action_pressed("ui_right"): 
		input_dir = Vector2.RIGHT

	if input_dir != Vector2.ZERO:
		mover.move_to(input_dir)
