extends Node

@export var play_button: Button
@export var exit_button: Button
@export var level1_scene: PackedScene

func _ready() -> void:
	MusicPlayer.play_menu_music()
	play_button.pressed.connect(go_to_level1)
	exit_button.pressed.connect(exit)

func _exit_tree() -> void:
	play_button.pressed.disconnect(go_to_level1)
	exit_button.pressed.disconnect(exit)

func go_to_level1() -> void:
	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().change_scene_to_packed(level1_scene)

func exit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(0)
