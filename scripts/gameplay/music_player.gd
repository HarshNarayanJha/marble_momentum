extends Node3D

@export var bg_player: AudioStreamPlayer
@export var level_music_names: Array[StringName]
@export var build_music_names: Array[StringName]
@export var menu_music_names: Array[StringName]

func play_music(mname: StringName):
	var stream_playback: AudioStreamPlaybackInteractive = bg_player.get_stream_playback()
	stream_playback.switch_to_clip_by_name(mname)

func play_level_music():
	play_music(level_music_names.pick_random())

func play_build_music():
	play_music(build_music_names.pick_random())

func play_menu_music():
	play_music(menu_music_names.pick_random())
