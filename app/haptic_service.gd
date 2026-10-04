extends Node
class_name HapticService

var save_service: Node = null

func setup(save_svc: Node) -> void:
	save_service = save_svc

func is_enabled() -> bool:
	if save_service:
		return bool(save_service.get_setting("haptics", true))
	return true

func trigger_selection() -> void:
	if not is_enabled(): return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(15)

func trigger_rotation_tick() -> void:
	if not is_enabled(): return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(8)

func trigger_alignment() -> void:
	if not is_enabled(): return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(25)

func trigger_release() -> void:
	if not is_enabled(): return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(45)

func trigger_level_complete() -> void:
	if not is_enabled(): return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(70)
