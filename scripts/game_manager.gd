extends Node

@export var marble: Marble
@export var sections: Array[SelectableSection]
@export var buttons: Array[TriggerButton]
@export var antigravities: Array[Antigravity]
@export var build_mode: bool = true

var lvel: Vector3
var avel: Vector3

func _ready() -> void:
	enter_build_mode()

func enter_build_mode():
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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.key_label == KEY_SPACE and event.pressed:
			if build_mode:
				enter_play_mode()
			else:
				enter_build_mode()

func disable_physics():
	lvel = marble.linear_velocity
	avel = marble.angular_velocity
	marble.set_freeze_enabled(true)

func enable_physics():
	marble.set_freeze_enabled(false)
	marble.linear_velocity = lvel
	marble.angular_velocity = avel
