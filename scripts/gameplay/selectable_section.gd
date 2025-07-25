class_name SelectableSection extends Node3D

@export var click_area: Area3D
@export var sections: Array[PackedScene]
@export var current_section: int = 0
@export var allow_manual_change: bool = true
@export var outline_width: float = 8.0
@export var outline_width_highlight: float = 5.0
@export var change_audio: AudioStreamPlayer3D

var section: Node3D = null
var is_hovering: bool = false

func _ready() -> void:
	click_area.input_event.connect(_on_input)
	click_area.mouse_entered.connect(_on_mouse_enter)
	click_area.mouse_exited.connect(_on_mouse_exit)
	change_section()

func _exit_tree() -> void:
	click_area.input_event.disconnect(_on_input)
	click_area.mouse_entered.disconnect(_on_mouse_enter)
	click_area.mouse_exited.disconnect(_on_mouse_exit)
	if section:
		section.queue_free()

func change_section():
	if current_section >= 0 and current_section < sections.size():
		__replace_section(sections[current_section])

func lock_change():
	_on_mouse_exit()
	allow_manual_change = false

func unlock_change():
	allow_manual_change = true

func highlight_part():
	if not section:
		return

	if not allow_manual_change:
		return

	for sm in section.find_children("*", "MeshInstance3D"):
		var sec_mesh: GeometryInstance3D = sm
		sec_mesh.set_instance_shader_parameter(&"outline_width", outline_width if is_hovering else outline_width_highlight)
		sec_mesh.set_instance_shader_parameter(&"pulse_speed", 0.0 if is_hovering else 1.5)

func remove_highlight():
	if not section:
		return

	for sm in section.find_children("*", "MeshInstance3D"):
		var sec_mesh: GeometryInstance3D = sm
		sec_mesh.set_instance_shader_parameter(&"outline_width", 0.0)
		sec_mesh.set_instance_shader_parameter(&"pulse_speed", 1.0)

func __replace_section(part: PackedScene):
	if section:
		self.remove_child(section)
		section.queue_free()

	if part:
		section = part.instantiate()
		self.add_child(section)
		section.position = Vector3.ZERO

		if is_hovering:
			_on_mouse_enter()

func play_audio():
	change_audio.play()

func _on_input(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not allow_manual_change:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			current_section = wrapi(current_section + 1, 0, sections.size())
			change_section()
			play_audio()

func _on_mouse_enter():
	if not section:
		return

	if not allow_manual_change:
		return

	is_hovering = true
	highlight_part()

func _on_mouse_exit():
	is_hovering = false

	if not section:
		return

	if not allow_manual_change:
		return

	remove_highlight()
