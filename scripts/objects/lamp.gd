class_name Lamp extends StaticBody3D

@export var animation_player: AnimationPlayer
@export var button: TriggerButton

var is_on: bool = false

func _ready() -> void:
	button.toggled.connect(set_light)
	set_light(button.is_pressed)

func _exit_tree() -> void:
	button.toggled.disconnect(set_light)

func set_light(state: bool):
	if state:
		turn_on()
	else:
		turn_off()

func toggle():
	if is_on:
		turn_off()
	else:
		turn_on()

func turn_on():
	if is_on:
		return

	is_on = true
	animation_player.play(&"light-on")

func turn_off():
	if not is_on:
		return

	is_on = false
	animation_player.play(&"light-off")
