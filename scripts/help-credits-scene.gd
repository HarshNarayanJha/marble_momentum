extends Control

@export var back_button: Button
@export_file var main_menu_scene: String

func _ready() -> void:
	SceneManager.fade_in()
	back_button.pressed.connect(func(): SceneManager.change_scene(main_menu_scene))
