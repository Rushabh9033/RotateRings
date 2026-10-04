extends SceneTree

class ConnectorLayer extends Node2D:
	var draw_callback: Callable
	func _draw() -> void:
		if draw_callback.is_valid():
			draw_callback.call(self)

func _init() -> void:
	var cl = ConnectorLayer.new()
	root.add_child(cl)
	cl.draw_callback = func(ci: CanvasItem):
		ci.draw_rect(Rect2(0, 0, 10, 10), Color.RED)
	cl.queue_redraw()
	print("ConnectorLayer created successfully!")
	quit(0)
