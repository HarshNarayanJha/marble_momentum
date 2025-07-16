class_name TriggerButton extends StaticBody3D

@export var trigger_area: Area3D
@export var animation_player: AnimationPlayer
@export var initial_pressed: bool = false
@export var keep_pressed: bool = false
@export var allow_manual_change: bool = true
@export var button_mesh: MeshInstance3D
@export var button_color_mesh: MeshInstance3D
@export var outline_width: float = 5.0
@export var outline_width_highlight: float = 3.0

@export_group("Colors")
@export_color_no_alpha var off_color: Color = Color(0.957, 0.504, 0)
@export_color_no_alpha var on_color: Color = Color(0, 0.874, 0)

signal toggled(state: bool)
signal turned_on
signal turned_off

var is_pressed: bool = false
var _manual_control_enabled: bool
var is_hovering: bool = false

func _ready() -> void:
	trigger_area.body_entered.connect(on_body_enter)
	trigger_area.body_exited.connect(on_body_exit)
	trigger_area.input_event.connect(on_input)
	trigger_area.mouse_entered.connect(_on_mouse_enter)
	trigger_area.mouse_exited.connect(_on_mouse_exit)

	_manual_control_enabled = allow_manual_change

	set_pressed(initial_pressed)

func _exit_tree() -> void:
	trigger_area.body_entered.disconnect(on_body_enter)
	trigger_area.body_exited.disconnect(on_body_exit)
	trigger_area.input_event.disconnect(on_input)
	trigger_area.mouse_entered.disconnect(_on_mouse_enter)
	trigger_area.mouse_exited.disconnect(_on_mouse_exit)

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
	_on_mouse_exit()
	_manual_control_enabled = false

func unlock_change():
	if not allow_manual_change:
		return
	_manual_control_enabled = true

func highlight():
	if not _manual_control_enabled:
		return

	button_mesh.set_instance_shader_parameter(&"outline_width", outline_width if is_hovering else outline_width_highlight)

func remove_highlight():
	button_mesh.set_instance_shader_parameter(&"outline_width", 0.0)

func __turn_on():
	(button_color_mesh.get_surface_override_material(0) as StandardMaterial3D).albedo_color = on_color

	if is_pressed:
		return

	is_pressed = true
	toggled.emit(true)
	turned_on.emit()
	animation_player.play(&"toggle-on")

func __turn_off():
	if keep_pressed and is_pressed:
		return

	(button_color_mesh.get_surface_override_material(0) as StandardMaterial3D).albedo_color = off_color

	if not is_pressed:
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

func _on_mouse_enter():
	if not _manual_control_enabled:
		return

	is_hovering = true
	highlight()

func _on_mouse_exit():
	is_hovering = false

	if not _manual_control_enabled:
		return

	remove_highlight()
