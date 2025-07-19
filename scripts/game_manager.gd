extends Node

@export var marbles: Array[Marble]
@export var sections: Array[SelectableSection]
@export var buttons: Array[TriggerButton]
@export var antigravities: Array[Antigravity]
@export var skip_lock: Array[Node3D]
@export var build_mode: bool = true

@export_category("Win/Lose")
@export_range(0, 10) var win_wait_secs: float = 3.0
@export_range(0, 90) var lose_wait_secs: float = 10.0
@export var win_button: TriggerButton
@export_file var next_level: String
@export_file var main_menu_scene: String

@export_category("UI")
@export var progress_circle: TextureProgressBar
@export var reload_button: TextureButton
@export var start_button: BaseButton
@export var home_button: BaseButton

var lvels: Array[Vector3]
var avels: Array[Vector3]
var lose_timer: SceneTreeTimer
var time: float

func _ready() -> void:
	SceneManager.fade_in()
	enter_build_mode()
	win_button.turned_on.connect(win)
	start_button.pressed.connect(start_level)
	reload_button.pressed.connect(reload_level)
	home_button.pressed.connect(goto_main_menu)
	progress_circle.value = 0

func _exit_tree() -> void:
	win_button.turned_on.disconnect(win)
	start_button.pressed.disconnect(start_level)
	reload_button.pressed.disconnect(reload_level)
	home_button.pressed.disconnect(goto_main_menu)

func enter_build_mode():
	if lose_timer:
		lose_timer.timeout.disconnect(lose)

	build_mode = true
	disable_physics()
	for s in sections:
		s.unlock_change()
		s.highlight_part()
	for b in buttons:
		b.unlock_change()
		b.highlight()
	for a in antigravities:
		a.unlock_change()
		a.highlight()

	MusicPlayer.play_build_music()

func enter_play_mode():
	build_mode = false
	enable_physics()
	for s in sections:
		if s in skip_lock:
			continue
		s.lock_change()
		s.remove_highlight()
	for b in buttons:
		if b in skip_lock:
			continue
		b.lock_change()
		b.remove_highlight()
	for a in antigravities:
		if a in skip_lock:
			continue
		a.lock_change()
		a.remove_highlight()

	MusicPlayer.play_level_music()
	# start the lose timer
	lose_timer = get_tree().create_timer(lose_wait_secs)
	lose_timer.timeout.connect(lose)

func win() -> void:
	reload_button.disabled = true
	reload_button.pressed.disconnect(reload_level)
	home_button.disabled = true
	home_button.pressed.disconnect(goto_main_menu)

	if lose_timer:
		lose_timer.timeout.disconnect(lose)

	await get_tree().create_timer(win_wait_secs).timeout

	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().change_scene_to_file(next_level)

func lose() -> void:
	reload_button.disabled = true
	if reload_button.pressed.is_connected(reload_level):
		reload_button.pressed.disconnect(reload_level)
	home_button.disabled = true
	if home_button.pressed.is_connected(goto_main_menu):
		home_button.pressed.disconnect(goto_main_menu)

	reload_level()

func reload_level() -> void:
	if SceneManager.is_transitioning:
		return
	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().reload_current_scene()

func goto_main_menu():
	if SceneManager.is_transitioning:
		return
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().change_scene_to_file(main_menu_scene)

func _process(delta: float) -> void:
	if build_mode:
		return

	time += delta
	progress_circle.value = 100 - (time / lose_wait_secs) * 100

func start_level() -> void:
	enter_play_mode()
	start_button.disabled = true
	start_button.pressed.disconnect(start_level)

func disable_physics():
	for m in marbles:
		m.set_freeze_enabled(true)
		lvels.push_back(m.linear_velocity)
		avels.push_back(m.angular_velocity)

func enable_physics():
	for m in marbles:
		m.linear_velocity = lvels.pop_front()
		m.angular_velocity = avels.pop_front()
		m.set_freeze_enabled(false)
