extends Node
class_name AudioService

var save_service: Node = null

var ui_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var release_player: AudioStreamPlayer
var win_player: AudioStreamPlayer

func _ready() -> void:
	ui_player = AudioStreamPlayer.new()
	click_player = AudioStreamPlayer.new()
	release_player = AudioStreamPlayer.new()
	win_player = AudioStreamPlayer.new()
	
	add_child(ui_player)
	add_child(click_player)
	add_child(release_player)
	add_child(win_player)

func setup(save_svc: Node) -> void:
	save_service = save_svc

func is_sound_enabled() -> bool:
	if save_service:
		return bool(save_service.get_setting("sound", true))
	return true

func play_ui_tap() -> void:
	if not is_sound_enabled(): return
	var stream := generate_sine_tone(620.0, 0.03, 3.5, 0.4)
	ui_player.stream = stream
	ui_player.volume_db = -8.0
	ui_player.play()

func play_rotation_tick(pitch_multiplier: float = 1.0) -> void:
	if not is_sound_enabled(): return
	var freq := 440.0 * pitch_multiplier
	var stream := generate_sine_tone(freq, 0.025, 4.0, 0.5)
	click_player.stream = stream
	click_player.volume_db = -10.0
	click_player.play()

func play_piece_select() -> void:
	if not is_sound_enabled(): return
	var stream := generate_sine_tone(520.0, 0.04, 2.8, 0.4)
	ui_player.stream = stream
	ui_player.volume_db = -9.0
	ui_player.play()

func play_lock_rattle() -> void:
	if not is_sound_enabled(): return
	var stream := generate_sine_tone(220.0, 0.06, 5.0, 0.6)
	click_player.stream = stream
	click_player.volume_db = -6.0
	click_player.play()

func play_connector_touch() -> void:
	if not is_sound_enabled(): return
	var stream := generate_touch_clack()
	click_player.stream = stream
	click_player.volume_db = -4.0
	click_player.play()

func play_near_alignment() -> void:
	if not is_sound_enabled(): return
	var stream := generate_sine_tone(880.0, 0.08, 3.0, 0.5)
	ui_player.stream = stream
	ui_player.volume_db = -6.0
	ui_player.play()

func play_release(note_index: int = 0) -> void:
	if not is_sound_enabled(): return
	var notes := [523.25, 587.33, 659.25, 783.99, 880.0, 1046.50]
	var freq: float = notes[clampi(note_index, 0, notes.size() - 1)]
	var stream := generate_harmonic_tone(freq, 0.40, 5.5, 0.7)
	release_player.stream = stream
	release_player.volume_db = -3.0
	release_player.play()

func play_level_clear(is_perfect: bool = false) -> void:
	if not is_sound_enabled(): return
	play_release(2)
	var t1 := get_tree().create_timer(0.10)
	t1.timeout.connect(func(): play_release(4))
	var t2 := get_tree().create_timer(0.20)
	t2.timeout.connect(func(): play_release(5))
	if is_perfect:
		var t3 := get_tree().create_timer(0.32)
		t3.timeout.connect(func(): play_release(0))

func play_hint() -> void:
	if not is_sound_enabled(): return
	var stream := generate_harmonic_tone(784.0, 0.35, 4.0, 0.6)
	ui_player.stream = stream
	ui_player.volume_db = -4.0
	ui_player.play()

func generate_sine_tone(freq: float, duration: float, decay_power: float, gain: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var frames := int(sample_rate * duration)
	var buffer := PackedByteArray()
	buffer.resize(frames * 2)
	
	for i in range(frames):
		var t := float(i) / sample_rate
		var progress := float(i) / frames
		var env := pow(1.0 - progress, decay_power)
		var val := sin(t * freq * TAU) * env * gain
		var s := int(clampf(val, -1.0, 1.0) * 32767.0)
		buffer.encode_s16(i * 2, s)
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = buffer
	return stream

func generate_harmonic_tone(fundamental: float, duration: float, decay_rate: float, gain: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var frames := int(sample_rate * duration)
	var buffer := PackedByteArray()
	buffer.resize(frames * 2)
	
	for i in range(frames):
		var t := float(i) / sample_rate
		var progress := float(i) / frames
		var env := exp(-progress * decay_rate)
		var val := (sin(t * fundamental * TAU) * 0.70 + sin(t * fundamental * 2.76 * TAU) * 0.25 + sin(t * fundamental * 5.4 * TAU) * 0.05) * env * gain
		var s := int(clampf(val, -1.0, 1.0) * 32767.0)
		buffer.encode_s16(i * 2, s)
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = buffer
	return stream

func generate_touch_clack() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.045
	var frames := int(sample_rate * duration)
	var buffer := PackedByteArray()
	buffer.resize(frames * 2)

	for i in range(frames):
		var t := float(i) / sample_rate
		var progress := float(i) / float(frames)
		var env := exp(-progress * 6.5) # fast tactile envelope
		var val := (sin(t * 1550.0 * TAU) * 0.45 + sin(t * 460.0 * TAU) * 0.55) * env * 0.8
		var s := int(clampf(val, -1.0, 1.0) * 32767.0)
		buffer.encode_s16(i * 2, s)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = buffer
	return stream
