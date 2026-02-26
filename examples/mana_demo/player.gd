extends CharacterBody2D

## Mana demo player.
## - Move with Arrow Keys
## - Press Space to cast a spell (costs 20 mana)
## - Mana regenerates automatically after a short delay
## - Press R to instantly refill mana

@onready var mana: ManaComponent = $ManaComponent
@onready var mover: EightDirMoverComponent = $EightDirMoverComponent
@onready var visual: ColorRect = $Visual
@onready var mana_bar: ProgressBar = get_node("/root/ManaDemo/HUD/ManaBar")
@onready var status_label: Label = get_node("/root/ManaDemo/HUD/StatusLabel")
@onready var cast_label: Label = get_node("/root/ManaDemo/HUD/CastLabel")
@onready var spells_node: Node2D = get_node("/root/ManaDemo/Spells")

const SPELL_COST := 20.0
const COLOR_NORMAL := Color(0.2, 0.6, 1.0, 1)
const COLOR_NO_MANA := Color(0.5, 0.5, 0.6, 1)

var _cast_label_timer: float = 0.0


func _ready() -> void:
	mana.mana_changed.connect(_on_mana_changed)
	mana.mana_depleted.connect(_on_mana_depleted)
	mana.mana_restored.connect(_on_mana_restored)
	_refresh_bar()


func _process(delta: float) -> void:
	# Fade cast label.
	if _cast_label_timer > 0.0:
		_cast_label_timer -= delta
		cast_label.modulate.a = _cast_label_timer / 1.0
		if _cast_label_timer <= 0.0:
			cast_label.visible = false

	# Cast spell.
	if Input.is_action_just_pressed("ui_accept"):
		_try_cast()

	# Instant refill.
	if Input.is_action_just_pressed("ui_cancel"):
		mana.reset()
		status_label.text = "Mana refilled!"
		visual.color = COLOR_NORMAL

	# Tint player grey when out of mana.
	visual.color = COLOR_NO_MANA if not mana.can_spend(SPELL_COST) else COLOR_NORMAL


func _try_cast() -> void:
	if mana.spend_mana(SPELL_COST):
		_spawn_spell_burst()
		_show_cast_label("✨ Spell cast! (-%d)" % int(SPELL_COST))
	else:
		_show_cast_label("❌ Not enough mana!")


func _spawn_spell_burst() -> void:
	# Visual: create a short-lived expanding ring at the player's position.
	var ring := ColorRect.new()
	ring.size = Vector2(16, 16)
	ring.position = global_position - Vector2(8, 8)
	ring.color = Color(0.4, 0.6, 1.0, 0.8)
	spells_node.add_child(ring)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(4, 4), 0.4)
	tween.tween_property(ring, "modulate:a", 0.0, 0.4)
	tween.tween_callback(ring.queue_free).set_delay(0.4)


func _show_cast_label(text: String) -> void:
	cast_label.text = text
	cast_label.visible = true
	cast_label.modulate.a = 1.0
	_cast_label_timer = 1.0


func _on_mana_changed(_old: float, _new: float) -> void:
	_refresh_bar()


func _on_mana_depleted() -> void:
	status_label.text = "Out of mana! Regenerating..."


func _on_mana_restored(_amount: float) -> void:
	if mana.current_mana >= mana.max_mana:
		status_label.text = "Mana full!"
	elif status_label.text == "Out of mana! Regenerating...":
		status_label.text = "Regenerating..."


func _refresh_bar() -> void:
	mana_bar.value = mana.get_mana_ratio() * 100.0
