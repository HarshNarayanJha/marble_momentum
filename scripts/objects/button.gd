class_name TriggerButton extends StaticBody3D

@export var trigger_area: Area3D
@export var animation_player: AnimationPlayer
@export var initial_pressed: bool = false
@export var keep_pressed: bool = false
@export var allow_manual_change: bool = true

signal toggled(state: bool)
signal turned_on
signal turned_off

var is_pressed: bool = false
var _manual_control_enabled: bool

func _ready() -> void:
	trigger_area.body_entered.connect(on_body_enter)
	trigger_area.body_exited.connect(on_body_exit)
	trigger_area.input_event.connect(on_input)

	_manual_control_enabled = allow_manual_change

	set_pressed(initial_pressed)

func _exit_tree() -> void:
	trigger_area.body_entered.disconnect(on_body_enter)
	trigger_area.body_exited.disconnect(on_body_exit)
	trigger_area.input_event.disconnect(on_input)

func set_pressed(state: bool):
	if state:
		__turn_on()
	else:
		__turn_off()

func toggle():
	if is_pressed:
		__turn_off()
	else:
		__turn_on()

func lock_change():
	_manual_control_enabled = false

func unlock_change():
	if not allow_manual_change:
		return
	_manual_control_enabled = true

func __turn_on():
	if is_pressed:
		return

	is_pressed = true
	toggled.emit(true)
	turned_on.emit()
	animation_player.play(&"toggle-on")

func __turn_off():
	if not is_pressed:
		return

	if keep_pressed:
		return

	is_pressed = false
	toggled.emit(false)
	turned_off.emit()
	animation_player.play(&"toggle-off")

func on_body_enter(body: Node3D):
	if body is not PhysicsBody3D:
		return

	if not is_pressed:
		set_pressed(true)

func on_body_exit(body: Node3D):
	if body is not PhysicsBody3D:
		return

	if is_pressed:
		set_pressed(false)

func on_input(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not _manual_control_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle()
