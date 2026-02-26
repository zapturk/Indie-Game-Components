extends Node
class_name HealthComponent

## Emitted whenever current health changes.
signal health_changed(old_value: int, new_value: int)
## Emitted when damage is successfully applied (after i-frames check).
signal damaged(amount: int)
## Emitted when health is restored.
signal healed(amount: int)
## Emitted once when health reaches 0.
signal died

## Maximum and starting health.
@export var max_health: int = 100

## Brief invincibility window after taking a hit (seconds). 0 = disabled.
@export var invincibility_time: float = 0.5

## When true, health cannot drop below 1.
@export var immortal: bool = false

## Current health — read only at runtime, use take_damage() / heal().
var current_health: int

var _is_invincible: bool = false
var _is_dead: bool = false


func _ready() -> void:
	current_health = max_health


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Apply damage. Returns actual damage dealt (0 if blocked).
func take_damage(amount: int) -> int:
	if _is_dead or _is_invincible or amount <= 0:
		return 0

	var old_health := current_health
	var min_health := 1 if immortal else 0
	current_health = clampi(current_health - amount, min_health, max_health)

	var actual := old_health - current_health
	health_changed.emit(old_health, current_health)
	damaged.emit(actual)

	if current_health <= 0 and not immortal:
		_is_dead = true
		died.emit()
	elif invincibility_time > 0.0:
		_start_invincibility()

	return actual


## Restore health. Returns actual amount healed.
func heal(amount: int) -> int:
	if _is_dead or amount <= 0:
		return 0

	var old_health := current_health
	current_health = clampi(current_health + amount, 0, max_health)

	var actual := current_health - old_health
	if actual > 0:
		health_changed.emit(old_health, current_health)
		healed.emit(actual)

	return actual


## Restore full health and clear dead/invincible state.
func reset() -> void:
	_is_dead = false
	_is_invincible = false
	var old_health := current_health
	current_health = max_health
	health_changed.emit(old_health, current_health)


## Returns true if the entity has died.
func is_dead() -> bool:
	return _is_dead


## Returns health as a 0.0–1.0 fraction — useful for health bars.
func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)


# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

func _start_invincibility() -> void:
	_is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	_is_invincible = false
