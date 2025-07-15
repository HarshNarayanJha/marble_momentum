class_name Antigravity extends StaticBody3D

enum AntigravityState {
	ATTRACT,
	REPEL,
	OFF
}

const NUM_STATES = 3

@export var force_area: Area3D
@export var force_mesh: MeshInstance3D
@export var base_mesh: MeshInstance3D
@export var repel_particles: GPUParticles3D
@export var attract_particles: GPUParticles3D

@export_group("Colors")
@export var repel_gravity: float = -8.8
@export var attract_gravity: float = 9.8
@export var repel_color: Color = Color(0.416, 0.817, 1, 1)
@export var attract_color: Color = Color(1, 0.416, 0.483, 1)

@export_group("Interaction Params")
@export var initial_state: AntigravityState = AntigravityState.REPEL
@export var allow_manual_change: bool = true

var current_state: AntigravityState
var _manual_control_enabled: bool
var is_hovering: bool = false

func _ready() -> void:
	force_area.input_event.connect(_on_input)
	force_area.mouse_entered.connect(_on_mouse_enter)
	force_area.mouse_exited.connect(_on_mouse_exit)

	_manual_control_enabled = allow_manual_change
	current_state = initial_state
	set_state(current_state)

func _exit_tree() -> void:
	force_area.input_event.disconnect(_on_input)
	force_area.mouse_entered.disconnect(_on_mouse_enter)
	force_area.mouse_exited.disconnect(_on_mouse_exit)

func set_state(state: AntigravityState):
	if state == AntigravityState.ATTRACT:
		force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		force_area.gravity = attract_gravity

		force_mesh.show()
		force_mesh.set_instance_shader_parameter(&"emission_color", attract_color)

		repel_particles.emitting = false
		attract_particles.emitting = true

	elif state == AntigravityState.REPEL:
		force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		force_area.gravity = repel_gravity

		force_mesh.show()
		force_mesh.set_instance_shader_parameter(&"emission_color", repel_color)

		attract_particles.emitting = false
		repel_particles.emitting = true

	elif state == AntigravityState.OFF:
		force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_DISABLED
		attract_particles.emitting = false
		repel_particles.emitting = false
		force_mesh.hide()

	else:
		# if set to the COUNT state accidently, turn off
		push_error("Invalid Antigravity State")
		set_state(AntigravityState.OFF)

func lock_change():
	_manual_control_enabled = false

func unlock_change():
	if not allow_manual_change:
		return
	_manual_control_enabled = true

func _on_input(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not _manual_control_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var current: int = current_state
			current = (current + 1) % NUM_STATES
			current_state = current as AntigravityState
			set_state(current_state)

func _on_mouse_enter():
	if not _manual_control_enabled:
		return

	is_hovering = true
	base_mesh.set_instance_shader_parameter(&"outline_width", 2.5)

func _on_mouse_exit():
	is_hovering = false

	if not _manual_control_enabled:
		return

	base_mesh.set_instance_shader_parameter(&"outline_width", 0.0)
