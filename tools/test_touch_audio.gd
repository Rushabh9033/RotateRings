extends SceneTree

const AudioServiceScript = preload("res://app/audio_service.gd")

func _init() -> void:
	var audio = AudioServiceScript.new()
	root.add_child(audio)
	audio._ready()
	var clack = audio.generate_touch_clack()
	assert(clack != null)
	assert(clack.data.size() > 0)
	print("✅ generate_touch_clack generated successfully! Bytes:", clack.data.size())
	quit(0)
