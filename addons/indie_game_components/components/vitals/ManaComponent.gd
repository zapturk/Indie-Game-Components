extends Node
class_name ManaComponent

## Emitted whenever current mana changes.
signal mana_changed(old_value: float, new_value: float)
## Emitted when mana is successfully spent.
signal mana_spent(amount: float)
## Emitted when mana is restored (regen tick or direct restore).
signal mana_restored(amount: float)
## Emitted once when mana hits 0.
signal mana_depleted

## Maximum mana pool.
@export var max_mana: float = 100.0

## Mana regenerated per second. Set to 0 to disable passive regen.
@export var regen_rate: float = 5.0

## Seconds to wait after spending mana before regen resumes.
## Mimics the "regen pause" feel of classic RPGs.
@export var regen_delay: float = 2.0

## Current mana — read only at runtime, use spend_mana() / restore_mana().
var current_mana: float

var _regen_timer: float = 0.0 # counts down to resume regen
var _is_depleted: bool = false # edge-trigger for mana_depleted signal


func _ready() -> void:
	current_mana = max_mana


func _process(delta: float) -> void:
	if regen_rate <= 0.0 or current_mana >= max_mana:
		return

	if _regen_timer > 0.0:
		_regen_timer -= delta
		return

	# Passive regen tick.
	var old_mana := current_mana
	current_mana = minf(current_mana + regen_rate * delta, max_mana)
	var gained := current_mana - old_mana
	if gained > 0.0:
		mana_changed.emit(old_mana, current_mana)
		mana_restored.emit(gained)
		if _is_depleted and current_mana > 0.0:
			_is_depleted = false


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Spend mana. Returns false if there isn't enough mana.
## Use the return value to gate ability activation.
func spend_mana(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if current_mana < amount:
		return false

	var old_mana := current_mana
	current_mana = maxf(current_mana - amount, 0.0)
	mana_changed.emit(old_mana, current_mana)
	mana_spent.emit(amount)

	# Pause regen after spending.
	_regen_timer = regen_delay

	if current_mana <= 0.0 and not _is_depleted:
		_is_depleted = true
		mana_depleted.emit()

	return true


## Directly restore mana (potion, shrine, etc.).
func restore_mana(amount: float) -> void:
	if amount <= 0.0:
		return

	var old_mana := current_mana
	current_mana = minf(current_mana + amount, max_mana)
	var actual := current_mana - old_mana
	if actual > 0.0:
		mana_changed.emit(old_mana, current_mana)
		mana_restored.emit(actual)
		_is_depleted = false


## Instantly refill mana and reset regen timer.
func reset() -> void:
	var old_mana := current_mana
	current_mana = max_mana
	_regen_timer = 0.0
	_is_depleted = false
	mana_changed.emit(old_mana, current_mana)


## Returns mana as a 0.0–1.0 fraction — useful for mana bars.
func get_mana_ratio() -> float:
	if max_mana <= 0.0:
		return 0.0
	return current_mana / max_mana


## Returns true if there is enough mana for a given cost (use to grey out UI).
func can_spend(amount: float) -> bool:
	return current_mana >= amount
