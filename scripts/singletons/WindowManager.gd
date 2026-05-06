extends Node

var _ultimo_tamano: Vector2i = Vector2i(1280, 720)
var _ultima_posicion: Vector2i = Vector2i(100, 100)

func _ready() -> void:
	await get_tree().process_frame

	if GameState.pantalla_completa:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func toggle_fullscreen() -> void:
	if _es_fullscreen():
		salir_fullscreen()
	else:
		entrar_fullscreen()

func entrar_fullscreen() -> void:
	_ultimo_tamano = DisplayServer.window_get_size()
	_ultima_posicion = DisplayServer.window_get_position()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameState.pantalla_completa = true

func salir_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	await get_tree().process_frame
	DisplayServer.window_set_size(_ultimo_tamano)
	DisplayServer.window_set_position(_ultima_posicion)
	GameState.pantalla_completa = false

func _es_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func get_texto_boton() -> String:
	return Lang.t("exit_fullscreen") if _es_fullscreen() else Lang.t("fullscreen")
