class_name MundoBase
extends Control

# --- Señales hacia NivelBase ---
signal ronda_completada(correcta: bool)
signal mundo_completado
signal instruccion_cambiada(texto: String)

const RONDAS_MAXIMAS: int = 5

var ronda_actual: int = 0
var objetivo_actual: Resource = null
var recursos: Array[Resource] = []
var lumi: Node = null
var _recordatorio_timer: Timer
var _ultima_instruccion: String = ""

var _botones: Array[Button] = []

func _ready() -> void:
	_recordatorio_timer = Timer.new()
	_recordatorio_timer.one_shot = true
	_recordatorio_timer.timeout.connect(_on_recordatorio_timeout)
	add_child(_recordatorio_timer)
	
# ─────────────────────────────────────────
# PUNTO DE ENTRADA — llamado por NivelBase
# ─────────────────────────────────────────
func iniciar(recursos_mundo: Array[Resource], referencia_lumi: Node) -> void:
	recursos = recursos_mundo
	lumi = referencia_lumi
	ronda_actual = 0
	_siguiente_ronda()

# ─────────────────────────────────────────
# MÉTODOS VIRTUALES — subclases DEBEN sobreescribir
# ─────────────────────────────────────────

## Lógica específica de cada ronda. Cada mundo lo implementa.
func nueva_ronda() -> void:
	push_error("MundoBase: nueva_ronda() no implementado en: " + get_script().get_path())

## Nombre legible del mundo para el HUD.
func get_nombre_mundo() -> String:
	push_error("MundoBase: get_nombre_mundo() no implementado en: " + get_script().get_path())
	return ""

# ─────────────────────────────────────────
# FLUJO DE RONDAS
# ─────────────────────────────────────────
func _siguiente_ronda() -> void:
	if ronda_actual >= RONDAS_MAXIMAS:
		_lanzar_confeti(180)
		mundo_completado.emit()
		return
	
	ronda_actual += 1
	limpiar_zona()
	FatigaManager.reiniciar()
	nueva_ronda()

# ─────────────────────────────────────────
# LÓGICA COMÚN DE VERIFICACIÓN
# ─────────────────────────────────────────
func verificar_respuesta(seleccionado: Resource) -> void:
	_set_interaccion(false)
	FatigaManager.reiniciar()
	_detener_recordatorio()

	if seleccionado == objetivo_actual:
		GameState.agregar_estrella(GameState.mundo_actual)
		SaveSystem.guardar()
		_lanzar_confeti(60)
		
		if lumi:
			lumi.celebrar()
			lumi.hablar("¡Correcto!")
		ronda_completada.emit(true)
		await get_tree().create_timer(1.5).timeout
		if not is_instance_valid(self):
			return
		_siguiente_ronda()
	else:
		GameState.agregar_error(GameState.mundo_actual)
		if lumi:
			lumi.hablar("¡Inténtalo de nuevo!")
		ronda_completada.emit(false)
		await get_tree().create_timer(1.0).timeout
		if not is_instance_valid(self):
			return
		_set_interaccion(true)
		_programar_recordatorio()

# ─────────────────────────────────────────
# UTILIDADES PARA SUBCLASES
# ─────────────────────────────────────────

## Baraja, corta a `cantidad` y elige objetivo. Siempre llamar antes de crear botones.
func preparar_opciones(cantidad: int) -> Array[Resource]:
	var opciones: Array[Resource] = recursos.duplicate()
	opciones.shuffle()
	if opciones.size() > cantidad:
		opciones = opciones.slice(0, cantidad)
	objetivo_actual = opciones.pick_random()
	return opciones

## Emite la instrucción al HUD y se la dice a Lumi.
func emitir_instruccion(texto: String) -> void:
	_ultima_instruccion = texto
	instruccion_cambiada.emit(texto)
	if lumi:
		lumi.hablar(texto)
	_programar_recordatorio()

## Registrar cada botón interactivo que cree la subclase.
func registrar_boton(btn: Button) -> void:
	_botones.append(btn)

## Limpia todos los hijos y resetea el registro de botones.
func limpiar_zona() -> void:
	_botones.clear()
	for hijo in get_children():
		hijo.queue_free()

func _set_interaccion(enabled: bool) -> void:
	for btn in _botones:
		if is_instance_valid(btn):
			btn.disabled = not enabled

func _contenedor_central() -> CenterContainer:
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return center

func _hbox_en(parent: Node, separacion: int = 50) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", separacion)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(hbox)
	return hbox

func _vbox_en(parent: Node, separacion: int = 30) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", separacion)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(vbox)
	return vbox

func _lanzar_confeti(cantidad: int = 60) -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return

	var overlay := Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 999
	escena.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var colores := [
		Color("#ff7eb3"),
		Color("#ffb430"),
		Color("#4bc3ff"),
		Color("#5eb319"),
		Color("#ffd700"),
		Color("#b56cff")
	]

	var viewport_size := get_viewport_rect().size

	for i in range(cantidad):
		var pieza := ColorRect.new()
		pieza.color = colores.pick_random()
		pieza.custom_minimum_size = Vector2(randf_range(8, 18), randf_range(10, 24))
		pieza.size = pieza.custom_minimum_size
		pieza.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var x_inicio := randf_range(0, viewport_size.x)
		var y_inicio := viewport_size.y + randf_range(20, 90)

		pieza.position = Vector2(x_inicio, y_inicio)
		pieza.rotation = randf_range(0, TAU)

		overlay.add_child(pieza)

		var destino := Vector2(
			x_inicio + randf_range(-180, 180),
			randf_range(viewport_size.y * 0.10, viewport_size.y * 0.55)
		)

		var duracion := randf_range(0.9, 1.35)

		var tween := pieza.create_tween()
		tween.set_parallel(true)
		tween.tween_property(pieza, "position", destino, duracion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(pieza, "rotation", pieza.rotation + randf_range(4.0, 10.0), duracion)
		tween.tween_property(pieza, "modulate:a", 0.0, duracion + 0.25)

	await get_tree().create_timer(1.6).timeout

	if is_instance_valid(overlay):
		overlay.queue_free()

func _programar_recordatorio() -> void:
	if _recordatorio_timer == null:
		return

	_recordatorio_timer.stop()
	_recordatorio_timer.wait_time = randf_range(5.0, 8.0)
	_recordatorio_timer.start()


func _detener_recordatorio() -> void:
	if _recordatorio_timer:
		_recordatorio_timer.stop()


func _on_recordatorio_timeout() -> void:
	if _ultima_instruccion == "":
		return

	if lumi:
		lumi.hablar(_ultima_instruccion)

	_programar_recordatorio()
