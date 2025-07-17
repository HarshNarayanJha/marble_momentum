class_name Marble extends RigidBody3D

@export var bounce_sfx: AudioStreamPlayer3D
@export var rolling_sfx: AudioStreamPlayer3D
@export var bounce_volume_threshold := 1.0
@export var rolling_threshold := 0.2

var last_bounce_time := -1.0

const BOUNCE_COOLDOWN := 0.2

func _ready() -> void:
	self.contact_monitor = true
	self.max_contacts_reported = 5
	last_bounce_time = Time.get_ticks_msec() / 1000.0

func _physics_process(delta: float) -> void:
	var speed = self.linear_velocity.length_squared()
	if self.get_contact_count() > 0 and speed > rolling_threshold * rolling_threshold:
		if not rolling_sfx.playing:
			rolling_sfx.play()
	else:
		if rolling_sfx.playing:
			rolling_sfx.stop()

	rolling_sfx.volume_linear = clampf(speed / 5.0, 0.0, 2.0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for i in state.get_contact_count():
		var local_impulse = state.get_contact_impulse(i)
		if local_impulse.length() > bounce_volume_threshold:
			var now = Time.get_ticks_msec() / 1000.0
			last_bounce_time = now
			play_sound()
			break

func play_sound() -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_bounce_time > BOUNCE_COOLDOWN:
		return

	if not bounce_sfx.playing:
		bounce_sfx.play()
