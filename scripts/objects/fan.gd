class_name Fan extends StaticBody3D

@export_range(-20.0, 400.0) var wind_speed: float = 0.0
@export var wind_area: Area3D
@export var animation_player: AnimationPlayer
@export var button: TriggerButton
@export var sfx: AudioStreamPlayer3D

@export_group("Sprite Settings", "sprite")
@export var sprite_fan_sprite: Sprite3D
@export var sprite_off_color: Color
@export var sprite_on_color: Color

var is_running: bool = false
var _body: Marble

func _ready() -> void:
	wind_area.body_entered.connect(on_marble_enter)
	wind_area.body_exited.connect(on_marble_exit)
	button.toggled.connect(set_running)
	set_running(button.is_pressed)

func _exit_tree() -> void:
	wind_area.body_entered.disconnect(on_marble_enter)
	wind_area.body_exited.disconnect(on_marble_exit)
	button.toggled.disconnect(set_running)

func _physics_process(delta: float) -> void:
	if is_running == false:
		return

	if _body == null:
		return

	_body.apply_central_force(-transform.basis.z * delta * wind_speed)

func set_running(state: bool):
	if state:
		__turn_on()
	else:
		__turn_off()

func toggle():
	if is_running:
		__turn_off()
	else:
		__turn_on()

func __turn_on():
	sprite_fan_sprite.modulate = sprite_on_color

	if is_running:
		return

	is_running = true
	animation_player.play(&"spinning")
	sfx.play()

func __turn_off():
	sprite_fan_sprite.modulate = sprite_off_color

	if not is_running:
		return

	is_running = false
	animation_player.stop()
	sfx.stop()

func on_marble_enter(body: Node3D):
	if body is Marble:
		_body = body

func on_marble_exit(body: Node3D):
	if body is Marble:
		_body = null
