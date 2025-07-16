class_name SpeedBooster extends Node3D

@export var booster_area: Area3D
@export var impulse_amount: float = 10.0
@export var forward_marker: Marker3D

func _ready() -> void:
	booster_area.body_entered.connect(_on_body_enter)

func _exit_tree() -> void:
	booster_area.body_entered.disconnect(_on_body_enter)

func _on_body_enter(other: Node3D) -> void:
	if other is Marble:
		other.apply_central_impulse(forward_marker.global_basis.z * impulse_amount)
