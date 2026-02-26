extends CharacterBody2D

## Player script for the 8-direction movement demo.
## EightDirMoverComponent handles all movement automatically —
## this script just hooks the direction_changed signal to update the HUD.

@onready var mover: EightDirMoverComponent = $EightDirMoverComponent
@onready var facing_label: Label = $FacingLabel

func _ready() -> void:
	mover.direction_changed.connect(_on_direction_changed)

func _on_direction_changed(dir: Vector2) -> void:
	facing_label.text = _dir_to_name(dir)

func _dir_to_name(dir: Vector2) -> String:
	# Map the normalized 8-way direction to a readable label.
	var angle := rad_to_deg(dir.angle())
	# dir.angle() returns radians: right=0, down=90, left=±180, up=-90
	if angle > -22.5 and angle <= 22.5: return "→  East"
	elif angle > 22.5 and angle <= 67.5: return "↘  South-East"
	elif angle > 67.5 and angle <= 112.5: return "↓  South"
	elif angle > 112.5 and angle <= 157.5: return "↙  South-West"
	elif angle > 157.5 or angle <= -157.5: return "←  West"
	elif angle > -157.5 and angle <= -112.5: return "↖  North-West"
	elif angle > -112.5 and angle <= -67.5: return "↑  North"
	elif angle > -67.5 and angle <= -22.5: return "↗  North-East"
	return "·  Idle"
