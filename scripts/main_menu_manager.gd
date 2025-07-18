extends Node

@export var play_button: Button
@export var help_button: Button
@export var credits_button: Button
@export var exit_button: Button
@export var version_text: Label

@export_category("Scenes")
@export_file var level1_scene: String
@export_file var help_scene: String
@export_file var credits_scene: String

func _ready() -> void:
	SceneManager.fade_in()
	MusicPlayer.play_menu_music()
	play_button.pressed.connect(go_to_level1)
	help_button.pressed.connect(goto_help)
	credits_button.pressed.connect(goto_credits)
	exit_button.pressed.connect(exit)
	version_text.text = ProjectSettings.get_setting("application/config/version")

func _exit_tree() -> void:
	play_button.pressed.disconnect(go_to_level1)
	help_button.pressed.disconnect(goto_help)
	credits_button.pressed.disconnect(goto_credits)
	exit_button.pressed.disconnect(exit)

func go_to_level1() -> void:
	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().change_scene_to_file(level1_scene)

func goto_help() -> void:
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().change_scene_to_file(help_scene)

func goto_credits() -> void:
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().change_scene_to_file(credits_scene)

func exit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(0)
