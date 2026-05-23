class_name MundoBase
extends Control

signal ronda_completada(correcta: bool)
signal mundo_completado
signal instruccion_cambiada(texto: String)

const RONDAS_MAXIMAS: int = 5

var ronda_actual: int = 0
var objetivo_actual: Resource = null
var recursos: Array[Resource] = []
var lumi: Node = null

var _botones: Array[Button] = []
var _errores_ronda: int = 0

var _recordatorio_timer: Timer = null
var _ultima_instruccion: String = ""
var _ultimos_audios: Array[AudioStream] = []

func iniciar(recursos_mundo: Array[Resource], referencia_lumi: Node) -> void: 
	_asegurar_recordatorio_timer()

	recursos = recursos_mundo
	lumi = referencia_lumi
	ronda_actual = 0
	_siguiente_ronda()


func nueva_ronda() -> void:
	push_error("MundoBase: nueva_ronda() no implementado en: " + get_script().get_path())


func get_nombre_mundo() -> String:
	push_error("MundoBase: get_nombre_mundo() no implementado en: " + get_script().get_path())
	return ""


func _siguiente_ronda() -> void:
	if ronda_actual >= RONDAS_MAXIMAS:
		_lanzar_confeti(195)
		_detener_recordatorio()
		FatigaManager.desactivar()
	
		var sfx_fin = AudioManager.obtener_stream_sfx("sonido_correcto_ronda")
		if sfx_fin: AudioManager.reproducir_sfx(sfx_fin)

		if lumi:
			lumi.celebrar()
			var audios: Array[AudioStream] = []
			var audio_logro = AudioManager.obtener_stream_voz("lo_lograste")
			if audio_logro: audios.append(audio_logro)
			lumi.hablar(Lang.t("completed"), audios)

		mundo_completado.emit()
		return

	ronda_actual += 1
	_errores_ronda = 0

	limpiar_zona()
	nueva_ronda()


func verificar_respuesta(seleccionado: Resource) -> void:
	_set_interaccion(false)
	FatigaManager.reiniciar()
	_detener_recordatorio()

	if seleccionado == objetivo_actual:
		GameState.agregar_estrella(GameState.mundo_actual)
		SaveSystem.guardar()
		_lanzar_confeti(60)

		var sfx_acierto = AudioManager.obtener_stream_sfx("correcto")
		if sfx_acierto: AudioManager.reproducir_sfx(sfx_acierto)

		if lumi:
			lumi.celebrar()
			var exitos = ["correcto", "muy_bien", "excelente"]
			var audios: Array[AudioStream] = []
			var audio_exito = AudioManager.obtener_stream_voz(exitos.pick_random())
			if audio_exito: audios.append(audio_exito)
			lumi.hablar(Lang.t("correct"), audios)

		ronda_completada.emit(true)
		await get_tree().create_timer(1.5).timeout
		if not is_instance_valid(self): return
		_siguiente_ronda()
	else:
		var sfx_error = AudioManager.obtener_stream_sfx("incorrecto")
		if sfx_error: AudioManager.reproducir_sfx(sfx_error)

		_errores_ronda += 1
		GameState.agregar_error(GameState.mundo_actual)

		if _errores_ronda >= 2:
			if lumi:
				var pistas = ["mira_con_atencion", "pista_visual"]
				var audios: Array[AudioStream] = []
				var audio_pista = AudioManager.obtener_stream_voz(pistas.pick_random())
				if audio_pista: audios.append(audio_pista)
				lumi.hablar(Lang.t("hint"), audios)
			_resaltar_correctas()
		else:
			if lumi:
				var errores = ["intenta_de_nuevo", "no_pasa_nada", "tu_puedes"]
				var audios: Array[AudioStream] = []
				var audio_error = AudioManager.obtener_stream_voz(errores.pick_random())
				if audio_error: audios.append(audio_error)
				lumi.hablar(Lang.t("try_again"), audios)

	ronda_completada.emit(false)
	await get_tree().create_timer(1.0).timeout

	if not is_instance_valid(self): return

	_set_interaccion(true)
	_programar_recordatorio()

func preparar_opciones(cantidad: int) -> Array[Resource]:
	var opciones: Array[Resource] = recursos.duplicate()
	opciones.shuffle()

	if opciones.size() > cantidad:
		opciones = opciones.slice(0, cantidad)

	objetivo_actual = opciones.pick_random()
	return opciones

func emitir_instruccion(texto: String, audios: Array[AudioStream] = []) -> void:
	_asegurar_recordatorio_timer()

	_ultima_instruccion = texto
	_ultimos_audios = audios
	instruccion_cambiada.emit(texto)

	if lumi:
		lumi.hablar(texto, audios)

	_programar_recordatorio()

func repetir_instruccion() -> void:
	if _ultima_instruccion == "": return
	
	if lumi:
		var audios: Array[AudioStream] = []
		var audio_repetir = AudioManager.obtener_stream_voz("repetir_instruccion")
		if audio_repetir:
			audios.append(audio_repetir)
			
		audios.append_array(_ultimos_audios)
		lumi.hablar(_ultima_instruccion, audios)

	_programar_recordatorio()

func registrar_boton(btn: Button, recurso: Resource = null) -> void:
	_botones.append(btn)

	if recurso != null:
		btn.set_meta("recurso", recurso)


func limpiar_zona() -> void:
	_botones.clear()

	for hijo in get_children():
		hijo.queue_free()

	_recordatorio_timer = null
	_asegurar_recordatorio_timer()


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


func _asegurar_recordatorio_timer() -> void:
	if _recordatorio_timer != null and is_instance_valid(_recordatorio_timer):
		return

	_recordatorio_timer = Timer.new()
	_recordatorio_timer.one_shot = true
	_recordatorio_timer.timeout.connect(_on_recordatorio_timeout)
	add_child(_recordatorio_timer)


func _programar_recordatorio() -> void:
	_asegurar_recordatorio_timer()

	_recordatorio_timer.stop()
	_recordatorio_timer.wait_time = randf_range(7.0, 10.0)
	_recordatorio_timer.start()


func _detener_recordatorio() -> void:
	if _recordatorio_timer and is_instance_valid(_recordatorio_timer):
		_recordatorio_timer.stop()


func _on_recordatorio_timeout() -> void:
	if _ultima_instruccion == "": return

	if lumi:
		var audios: Array[AudioStream] = []
		var audio_repetir = AudioManager.obtener_stream_voz("repetir_instruccion")
		if audio_repetir: audios.append(audio_repetir)
		audios.append_array(_ultimos_audios)
		lumi.hablar(_ultima_instruccion, audios)
	_programar_recordatorio()

func _resaltar_correctas() -> void:
	for btn in _botones:
		if not is_instance_valid(btn):
			continue

		if not btn.has_meta("recurso"):
			continue

		var recurso: Resource = btn.get_meta("recurso") as Resource

		if recurso == objetivo_actual:
			_animar_pista_boton(btn)


func _animar_pista_boton(btn: Button) -> void:
	if not is_instance_valid(btn):
		return

	var tween := btn.create_tween()
	tween.set_loops(3)
	tween.tween_property(btn, "scale", Vector2(1.16, 1.16), 0.18)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.18)


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
	
