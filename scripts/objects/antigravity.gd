class_name Antigravity extends StaticBody3D

enum AntigravityState {
	ATTRACT,
	REPEL,
}

const NUM_STATES = 2

@export var force_area: Area3D
@export var interact_area: Area3D
@export var force_mesh: MeshInstance3D
@export var base_mesh: MeshInstance3D
@export var repel_particles: GPUParticles3D
@export var attract_particles: GPUParticles3D
@export var change_sfx: AudioStreamPlayer3D
@export var force_sfx: AudioStreamPlayer3D

@export_group("Colors")
@export var repel_gravity: float = -8.8
@export var attract_gravity: float = 9.8
@export var repel_color: Color = Color(0.416, 0.817, 1, 1)
@export var attract_color: Color = Color(1, 0.416, 0.483, 1)

@export_group("Interaction Params")
@export var initial_state: AntigravityState = AntigravityState.REPEL
@export var allow_manual_change: bool = true
@export var outline_width: float = 6.0
@export var outline_width_highlight: float = 5.0

@export_group("Sprite", "sprite")
@export var sprite_node: Sprite3D
@export var sprite_attract: Texture2D
@export var sprite_repel: Texture2D

var current_state: AntigravityState
var _manual_control_enabled: bool
var is_hovering: bool = false

func _ready() -> void:
	interact_area.input_event.connect(_on_input)
	interact_area.mouse_entered.connect(_on_mouse_enter)
	interact_area.mouse_exited.connect(_on_mouse_exit)

	force_area.body_entered.connect(play_force_sfx)

	_manual_control_enabled = allow_manual_change
	current_state = initial_state
	set_state(current_state)

func _exit_tree() -> void:
	interact_area.input_event.disconnect(_on_input)
	interact_area.mouse_entered.disconnect(_on_mouse_enter)
	interact_area.mouse_exited.disconnect(_on_mouse_exit)

	force_area.body_entered.disconnect(play_force_sfx)

func set_state(state: AntigravityState):
	if state == AntigravityState.ATTRACT:
		force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		force_area.gravity = attract_gravity

		force_mesh.show()
		force_mesh.set_instance_shader_parameter(&"emission_color", attract_color)

		repel_particles.emitting = false
		attract_particles.emitting = true

		sprite_node.texture = sprite_attract
		sprite_node.modulate = attract_color

	elif state == AntigravityState.REPEL:
		force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		force_area.gravity = repel_gravity

		force_mesh.show()
		force_mesh.set_instance_shader_parameter(&"emission_color", repel_color)

		attract_particles.emitting = false
		repel_particles.emitting = true

		sprite_node.texture = sprite_repel
		sprite_node.modulate = repel_color

	#elif state == AntigravityState.OFF:
		#force_area.gravity_space_override = Area3D.SPACE_OVERRIDE_DISABLED
		#attract_particles.emitting = false
		#repel_particles.emitting = false
		#force_mesh.hide()

	else:
		# if set to the COUNT state accidently, turn off
		push_error("Invalid Antigravity State %s", state)
		#set_state(AntigravityState.OFF)

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

	base_mesh.set_instance_shader_parameter(&"outline_width", outline_width if is_hovering else outline_width_highlight)
	base_mesh.set_instance_shader_parameter(&"pulse_speed", 0.0 if is_hovering else 1.5)

func remove_highlight():
	base_mesh.set_instance_shader_parameter(&"outline_width", 0.0)
	base_mesh.set_instance_shader_parameter(&"pulse_speed", 0.0)

func play_force_sfx(_other: Node3D):
	force_sfx.play()

func _on_input(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not _manual_control_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var current: int = current_state
			current = (current + 1) % NUM_STATES
			current_state = current as AntigravityState
			set_state(current_state)
			change_sfx.play()

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
