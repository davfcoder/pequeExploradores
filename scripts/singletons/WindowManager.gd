extends Node

var _forzando_fullscreen := false

func _ready() -> void:
	await get_tree().process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _process(_delta: float) -> void:
	if _forzando_fullscreen:
		return

	var mode := DisplayServer.window_get_mode()

	if mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
		_forzando_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		await get_tree().process_frame
		_forzando_fullscreen = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		var mode := DisplayServer.window_get_mode()

		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
