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

@export_category("UI")
@export var progress_circle: TextureProgressBar
@export var reload_button: TextureButton
@export var start_button: BaseButton

var lvel: Vector3
var avel: Vector3
var lose_timer: SceneTreeTimer
var time: float

func _ready() -> void:
	SceneManager.fade_in()
	enter_build_mode()
	win_button.turned_on.connect(win)
	start_button.pressed.connect(start_level)
	reload_button.pressed.connect(reload_level)
	progress_circle.value = 0

func _exit_tree() -> void:
	win_button.turned_on.disconnect(win)
	start_button.pressed.disconnect(start_level)
	reload_button.pressed.disconnect(reload_level)

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

	MusicPlayer.play_build_music()

func enter_play_mode():
	build_mode = false
	enable_physics()
	for s in sections:
		s.lock_change()
		s.remove_highlight()
	for b in buttons:
		b.lock_change()
		b.remove_highlight()
	for a in antigravities:
		a.lock_change()

	MusicPlayer.play_level_music()
	# start the lose timer
	lose_timer = get_tree().create_timer(lose_wait_secs)
	lose_timer.timeout.connect(lose)

func win() -> void:
	reload_button.disabled = true
	reload_button.pressed.disconnect(reload_level)
	if lose_timer:
		lose_timer.timeout.disconnect(lose)

	await get_tree().create_timer(win_wait_secs).timeout

	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().change_scene_to_packed(next_level)

func lose() -> void:
	reload_level()

func reload_level() -> void:
	reload_button.disabled = true
	reload_button.pressed.disconnect(reload_level)
	# Can't use change_scene directly since phantom camera bugs out
	SceneManager.fade_out()
	await SceneManager.fade_complete

	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if build_mode:
		return

	time += delta
	progress_circle.value = 100 - (time / lose_wait_secs) * 100

# now with actual button
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.key_label == KEY_SPACE and event.pressed:
			#if build_mode:
				#enter_play_mode()
			#else:
				#enter_build_mode()

func start_level() -> void:
	enter_play_mode()
	start_button.disabled = true

func disable_physics():
	marble.set_freeze_enabled(true)
	lvel = marble.linear_velocity
	avel = marble.angular_velocity

func enable_physics():
	marble.linear_velocity = lvel
	marble.angular_velocity = avel
	marble.set_freeze_enabled(false)
