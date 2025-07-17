class_name Domino extends RigidBody3D

@export var audio_player: AudioStreamPlayer3D

var played_for: Array[int] = []

func _ready() -> void:
	self.contact_monitor = true
	self.max_contacts_reported = 1
	self.body_entered.connect(play_audio)

func _exit_tree() -> void:
	self.body_entered.disconnect(play_audio)

func play_audio(other: Node3D):
	var id = other.get_instance_id()
	if other is Marble or other is Domino:
		if played_for.has(id):
			return

		played_for.push_back(id)
		if not audio_player.playing:
			audio_player.play()
