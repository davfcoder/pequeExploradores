extends Node

signal fatiga_detectada

const TIEMPO_INACTIVIDAD: float = 120.0

var _timer: Timer
var _activo: bool = false

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = TIEMPO_INACTIVIDAD
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

func activar() -> void:
	_activo = true
	_timer.start()

func desactivar() -> void:
	_activo = false
	_timer.stop()

func reiniciar() -> void:
	if _activo:
		_timer.start()

func _input(event: InputEvent) -> void:
	if not _activo:
		return

	if event is InputEventMouseButton and event.pressed:
		reiniciar()

	if event is InputEventScreenTouch and event.pressed:
		reiniciar()

	if event is InputEventKey and event.pressed:
		reiniciar()

func _on_timeout() -> void:
	SaveSystem.guardar()
	fatiga_detectada.emit()
