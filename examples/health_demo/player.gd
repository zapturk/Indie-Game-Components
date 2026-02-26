extends CharacterBody2D

## Health demo player.
## - Move with Arrow Keys
## - Walk into red hazard zones to take damage
## - Press enter to heal 20 HP
## - Press escape to reset health / respawn

@onready var health: HealthComponent = $HealthComponent
@onready var mover: EightDirMoverComponent = $EightDirMoverComponent
@onready var visual: ColorRect = $Visual
@onready var hud_bar: ProgressBar = get_node("/root/HealthDemo/HUD/HealthBar")
@onready var hud_label: Label = get_node("/root/HealthDemo/HUD/StatusLabel")

const COLOR_ALIVE := Color(0.2, 0.6, 1.0, 1)
const COLOR_HURT := Color(1.0, 1.0, 1.0, 1)
const COLOR_DEAD := Color(0.4, 0.4, 0.4, 1)


func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	health.damaged.connect(_on_damaged)
	health.healed.connect(_on_healed)
	health.died.connect(_on_died)
	_refresh_bar()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): # Enter / Space
		health.heal(20)
	if Input.is_action_just_pressed("ui_cancel"): # Escape / B
		health.reset()
		#mover.enabled = true
		visual.color = COLOR_ALIVE
		hud_label.text = "Alive"


func _on_health_changed(_old: int, _new: int) -> void:
	_refresh_bar()


func _on_damaged(_amount: int) -> void:
	# Flash white to show i-frames window.
	visual.color = COLOR_HURT
	await get_tree().create_timer(health.invincibility_time).timeout
	if not health.is_dead():
		visual.color = COLOR_ALIVE
	hud_label.text = "HP: %d / %d" % [health.current_health, health.max_health]


func _on_healed(_amount: int) -> void:
	hud_label.text = "HP: %d / %d" % [health.current_health, health.max_health]


func _on_died() -> void:
	#mover.enabled = false
	visual.color = COLOR_DEAD
	hud_label.text = "DEAD — Press Escape to respawn"


func _refresh_bar() -> void:
	hud_bar.value = health.get_health_ratio() * 100.0
