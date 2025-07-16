extends Node

@export var marble: Marble
@export var sections: Array[SelectableSection]
@export var buttons: Array[TriggerButton]
@export var antigravities: Array[Antigravity]
@export var build_mode: bool = true

@export_category("Win/Lose")
@export_range(0, 10) var win_wait_secs: float = 3.0
@export_range(0, 50) var lose_wait_secs: float = 10.0
@export var win_button: TriggerButton
@export var next_level: PackedScene

var lvel: Vector3
var avel: Vector3
var lose_timer: SceneTreeTimer

func _ready() -> void:
	SceneManager.fade_in()
	enter_build_mode()
	win_button.turned_on.connect(win)

func _exit_tree() -> void:
	win_button.turned_on.disconnect(win)

func enter_build_mode():
	if lose_timer:
		lose_timer.timeout.disconnect(lose)

	build_mode = true
	disable_physics()
	for s in sections:
		s.unlock_change()
	for b in buttons:
		b.unlock_change()
	for a in antigravities:
		a.unlock_change()

	MusicPlayer.play_build_music()

func enter_play_mode():
	build_mode = false
	enable_physics()
	for s in sections:
		s.lock_change()
	for b in buttons:
		b.lock_change()
	for a in antigravities:
		a.lock_change()

	MusicPlayer.play_level_music()
	# start the lose timer
	lose_timer = get_tree().create_timer(lose_wait_secs)
	lose_timer.timeout.connect(lose)

func win() -> void:
	if lose_timer:
		lose_timer.timeout.disconnect(lose)

	await get_tree().create_timer(win_wait_secs).timeout

	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().change_scene_to_packed(next_level)

func lose() -> void:
	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.key_label == KEY_SPACE and event.pressed:
			if build_mode:
				enter_play_mode()
			else:
				enter_build_mode()

func disable_physics():
	marble.set_freeze_enabled(true)
	lvel = marble.linear_velocity
	avel = marble.angular_velocity

func enable_physics():
	marble.linear_velocity = lvel
	marble.angular_velocity = avel
	marble.set_freeze_enabled(false)
