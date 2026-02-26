extends Area2D

## Hazard zone — deals damage to any node that has a HealthComponent child
## while it stays inside the area. Damage is applied once per tick_interval.

@export var damage_per_tick: int = 10
@export var tick_interval: float = 0.8

var _tick_timer: float = 0.0
var _bodies_inside: Array[Node] = []


func _ready() -> void:
	# Self-connect so no scene-file signal wiring is required.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	_bodies_inside.append(body)


func _on_body_exited(body: Node) -> void:
	_bodies_inside.erase(body)


func _process(delta: float) -> void:
	if _bodies_inside.is_empty():
		_tick_timer = 0.0
		return

	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		for body in _bodies_inside:
			var hp: HealthComponent = body.get_node_or_null("HealthComponent")
			if hp:
				hp.take_damage(damage_per_tick)
