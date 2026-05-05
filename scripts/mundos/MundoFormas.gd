class_name MundoFormas
extends MundoBase

var _clasificacion_seleccionadas: Array[Button] = []
var _clasificacion_botones: Array[Button] = []
var _clasificacion_bloqueada: bool = false

var _drag_recurso: Resource = null
var _drag_node: Control = null
var _drag_zona_drop: Control = null
var _drag_original_parent: Node = null
var _drag_original_index: int = -1
var _drag_original_global_position: Vector2 = Vector2.ZERO
var _drag_original_size: Vector2 = Vector2.ZERO
var _drag_original_scale: Vector2 = Vector2.ONE
var _drag_original_z_index: int = 0
var _drag_offset: Vector2 = Vector2.ZERO


func get_nombre_mundo() -> String:
	return "Ciudad de las Formas"

func nueva_ronda() -> void:
	match randi() % 3:
		0: _mision_identifica_forma()
		1: _mision_drag_and_drop()
		2: _mision_clasifica_forma()

# ── Misión 0: Toca la forma pedida ──────────────────────────────────
func _mision_identifica_forma() -> void:
	var opciones := preparar_opciones(3)
	emitir_instruccion("Toca la figura: " + GameState.get_nombre_elemento(objetivo_actual))
	var audio: AudioStream = objetivo_actual.audio_nombre_en \
		if GameState.modo_bilingue_comprado else objetivo_actual.audio_nombre_es
	if audio:
		AudioManager.reproducir_voz(audio)
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_forma(res, hbox)

# ── Misión 1: Drag & Drop — arrastra la figura a su silueta ─────────
func _mision_drag_and_drop() -> void:
	var opciones := preparar_opciones(3)
	emitir_instruccion("Arrastra la figura a su silueta ✋")

	var center := _contenedor_central()
	var vbox := _vbox_en(center, 40)

	var zona_drop := Panel.new()
	zona_drop.custom_minimum_size = Vector2(210, 210)
	zona_drop.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	zona_drop.name = "ZonaDrop"

	var sty_drop := StyleBoxFlat.new()
	sty_drop.bg_color = Color(1, 1, 1, 0.18)
	sty_drop.corner_radius_top_left = 24
	sty_drop.corner_radius_top_right = 24
	sty_drop.corner_radius_bottom_left = 24
	sty_drop.corner_radius_bottom_right = 24
	sty_drop.border_width_left = 5
	sty_drop.border_width_top = 5
	sty_drop.border_width_right = 5
	sty_drop.border_width_bottom = 5
	sty_drop.border_color = Color.WHITE
	sty_drop.shadow_color = Color(0, 0, 0, 0.18)
	sty_drop.shadow_size = 10
	sty_drop.shadow_offset = Vector2(0, 5)
	zona_drop.add_theme_stylebox_override("panel", sty_drop)

	if objetivo_actual.textura_visual:
		var sil := TextureRect.new()
		sil.texture = objetivo_actual.textura_visual
		sil.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		sil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sil.modulate = Color(0, 0, 0, 1)

		zona_drop.add_child(sil)
		sil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sil.offset_left = 18
		sil.offset_right = -18
		sil.offset_top = 18
		sil.offset_bottom = -18

	vbox.add_child(zona_drop)

	var hbox := _hbox_en(vbox, 50)
	for res in opciones:
		_crear_figura_arrastrable(res, hbox, zona_drop)

# ── Misión 2: Clasifica — toca las dos iguales ──────────────────────
func _mision_clasifica_forma() -> void:
	_clasificacion_seleccionadas.clear()
	_clasificacion_botones.clear()
	_clasificacion_bloqueada = false

	var copia: Array[Resource] = recursos.duplicate()
	copia.shuffle()
	objetivo_actual = copia[0]

	var otros: Array[Resource] = []
	for r in copia:
		if r != objetivo_actual and otros.size() < 2:
			otros.append(r)

	var opciones: Array[Resource] = [objetivo_actual, objetivo_actual]
	for o in otros:
		opciones.append(o)

	opciones.shuffle()

	var nombre := GameState.get_nombre_elemento(objetivo_actual)
	emitir_instruccion("Toca las dos figuras que son: " + nombre)

	var center := _contenedor_central()
	var hbox := _hbox_en(center, 50)

	for res in opciones:
		var es_correcto := res == objetivo_actual
		var btn := _crear_boton_forma_raw(res)

		_clasificacion_botones.append(btn)

		btn.pressed.connect(func():
			_on_forma_clasificacion_presionada(btn, es_correcto)
		)

		registrar_boton(btn)
		hbox.add_child(btn)
	
# ── Helpers ──────────────────────────────────────────────────────────

func _crear_boton_forma(recurso: Resource, parent: Node) -> void:
	var btn := _crear_boton_forma_raw(recurso)
	btn.pressed.connect(func(): verificar_respuesta(recurso))
	registrar_boton(btn)
	parent.add_child(btn)

func _crear_boton_forma_raw(recurso: Resource) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(190, 190)
	btn.clip_contents       = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color                   = Color(1, 1, 1, 0.0)
	style.corner_radius_top_left     = 24
	style.corner_radius_top_right    = 24
	style.corner_radius_bottom_left  = 24
	style.corner_radius_bottom_right = 24
	style.border_width_left          = 5
	style.border_width_top           = 5
	style.border_width_right         = 5
	style.border_width_bottom        = 5
	style.border_color               = Color(1, 1, 1, 0.0)

	var style_hover := style.duplicate()
	style_hover.border_color        = Color("#4bc3ff")
	style_hover.bg_color            = Color(1, 1, 1, 0.15)
	style_hover.border_width_left   = 7
	style_hover.border_width_top    = 7
	style_hover.border_width_right  = 7
	style_hover.border_width_bottom = 7

	var empty := StyleBoxEmpty.new()

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("disabled", empty)
	btn.add_theme_stylebox_override("focus", empty)

	if recurso.textura_visual:
		var img := TextureRect.new()
		img.texture             = recurso.textura_visual
		img.expand_mode         = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.mouse_filter        = Control.MOUSE_FILTER_IGNORE
		btn.add_child(img)

	return btn

func _crear_figura_arrastrable(recurso: Resource, parent: Node, zona_drop: Panel) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(150, 150)
	btn.size = Vector2(150, 150)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.clip_contents = false
	btn.focus_mode = Control.FOCUS_NONE

	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("disabled", empty)
	btn.add_theme_stylebox_override("focus", empty)

	if recurso.textura_visual:
		var img := TextureRect.new()
		img.texture = recurso.textura_visual
		img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE

		btn.add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	btn.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_iniciar_drag(recurso, btn, zona_drop)
	)

	registrar_boton(btn)
	parent.add_child(btn)

func _input(event: InputEvent) -> void:
	if _drag_recurso == null or _drag_node == null:
		return

	if event is InputEventMouseMotion:
		_actualizar_drag()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_soltar_drag()


func _iniciar_drag(recurso: Resource, origen: Control, zona_drop: Control) -> void:
	if _drag_recurso != null:
		return

	_drag_recurso = recurso
	_drag_node = origen
	_drag_zona_drop = zona_drop

	_drag_original_parent = origen.get_parent()
	_drag_original_index = origen.get_index()
	_drag_original_global_position = origen.global_position
	_drag_original_size = origen.size
	_drag_original_scale = origen.scale
	_drag_original_z_index = origen.z_index

	_drag_offset = get_global_mouse_position() - origen.global_position

	# Sacar la figura del HBoxContainer temporalmente.
	origen.reparent(self, true)

	origen.global_position = _drag_original_global_position
	origen.size = _drag_original_size
	origen.scale = _drag_original_scale
	origen.z_index = 1000
	origen.disabled = true
	origen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	origen.show()

	_actualizar_drag()

func _actualizar_drag() -> void:
	if not is_instance_valid(_drag_node):
		return
	_drag_node.global_position = get_global_mouse_position() - _drag_offset


func _soltar_drag() -> void:
	if _drag_recurso == null or not is_instance_valid(_drag_node):
		_limpiar_drag()
		return

	var recurso_soltado: Resource = _drag_recurso
	var nodo_soltado: Control = _drag_node
	var zona: Control = _drag_zona_drop

	var parent_original: Node = _drag_original_parent
	var index_original: int = _drag_original_index
	var posicion_original: Vector2 = _drag_original_global_position
	var size_original: Vector2 = _drag_original_size
	var scale_original: Vector2 = _drag_original_scale
	var z_original: int = _drag_original_z_index

	var mouse_pos := get_global_mouse_position()
	var dentro := false

	if is_instance_valid(zona):
		dentro = zona.get_global_rect().has_point(mouse_pos)

	# Caso 1: correcta dentro de la silueta.
	if dentro and recurso_soltado == objetivo_actual:
		_encajar_figura_en_silueta(recurso_soltado, zona)

		if is_instance_valid(nodo_soltado):
			nodo_soltado.queue_free()

		_limpiar_drag()
		verificar_respuesta(recurso_soltado)
		return

	# Caso 2: incorrecta dentro de la silueta.
	if dentro and recurso_soltado != objetivo_actual:
		await _devolver_nodo_arrastrado(
			nodo_soltado,
			parent_original,
			index_original,
			posicion_original,
			size_original,
			scale_original,
			z_original
		)

		_limpiar_drag()
		verificar_respuesta(recurso_soltado)
		return

	# Caso 3: soltó fuera de la silueta.
	await _devolver_nodo_arrastrado(
		nodo_soltado,
		parent_original,
		index_original,
		posicion_original,
		size_original,
		scale_original,
		z_original
	)

	_limpiar_drag()

	if lumi:
		lumi.hablar("Llévala hasta la silueta")


func _devolver_nodo_arrastrado(
	nodo: Control,
	parent_original: Node,
	index_original: int,
	posicion_original: Vector2,
	size_original: Vector2,
	scale_original: Vector2,
	z_original: int
) -> void:
	if not is_instance_valid(nodo):
		return

	nodo.show()
	nodo.modulate = Color(1, 1, 1, 1)

	var tween := create_tween()
	tween.tween_property(nodo, "global_position", posicion_original, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

	if not is_instance_valid(nodo):
		return

	if is_instance_valid(parent_original):
		nodo.reparent(parent_original, true)

		var max_index := parent_original.get_child_count() - 1
		var safe_index = clamp(index_original, 0, max_index)
		parent_original.move_child(nodo, safe_index)

	nodo.size = size_original
	nodo.scale = scale_original
	nodo.z_index = z_original
	nodo.disabled = false
	nodo.mouse_filter = Control.MOUSE_FILTER_STOP
	nodo.show()


func _restaurar_nodo_arrastrado(nodo: Control, z_original: int) -> void:
	if not is_instance_valid(nodo):
		return

	nodo.top_level = false
	nodo.z_index = z_original
	nodo.mouse_filter = Control.MOUSE_FILTER_STOP
	nodo.disabled = false
	nodo.show()


func _limpiar_drag() -> void:
	_drag_recurso = null
	_drag_node = null
	_drag_zona_drop = null

	_drag_original_parent = null
	_drag_original_index = -1
	_drag_original_global_position = Vector2.ZERO
	_drag_original_size = Vector2.ZERO
	_drag_original_scale = Vector2.ONE
	_drag_original_z_index = 0

	_drag_offset = Vector2.ZERO

func _encajar_figura_en_silueta(recurso: Resource, zona: Control) -> void:
	if recurso.textura_visual == null:
		return

	var figura := TextureRect.new()
	figura.texture = recurso.textura_visual
	figura.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	figura.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	figura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	figura.modulate = Color(1, 1, 1, 1)
	figura.z_index = 10

	zona.add_child(figura)
	figura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	figura.offset_left = 18
	figura.offset_right = -18
	figura.offset_top = 18
	figura.offset_bottom = -18

func _on_forma_clasificacion_presionada(btn: Button, es_correcto: bool) -> void:
	if _clasificacion_bloqueada:
		return

	# Si toca una figura correcta.
	if es_correcto:
		# Evita contar dos veces el mismo botón.
		if _clasificacion_seleccionadas.has(btn):
			return

		_clasificacion_seleccionadas.append(btn)
		_marcar_forma_seleccionada(btn)
		btn.disabled = true

		# Solo es correcto si seleccionó 2 botones correctos distintos.
		if _clasificacion_seleccionadas.size() >= 2:
			_clasificacion_bloqueada = true
			_detener_recordatorio()
			verificar_respuesta(objetivo_actual)

		return

	# Si toca una figura incorrecta.
	await _fallar_clasificacion()


func _fallar_clasificacion() -> void:
	if _clasificacion_bloqueada:
		return

	_clasificacion_bloqueada = true
	_detener_recordatorio()

	GameState.agregar_error(GameState.mundo_actual)

	if lumi:
		lumi.hablar("Inténtalo de nuevo")

	ronda_completada.emit(false)

	for b in _clasificacion_botones:
		if is_instance_valid(b):
			b.disabled = true

	await get_tree().create_timer(0.6).timeout

	if not is_instance_valid(self):
		return

	_resetear_intento_clasificacion()

	_clasificacion_bloqueada = false
	_programar_recordatorio()


func _resetear_intento_clasificacion() -> void:
	for b in _clasificacion_seleccionadas:
		if is_instance_valid(b):
			_limpiar_marca_forma(b)

	_clasificacion_seleccionadas.clear()

	for b in _clasificacion_botones:
		if is_instance_valid(b):
			b.disabled = false
			b.modulate = Color(1, 1, 1, 1)
			b.scale = Vector2.ONE


func _marcar_forma_seleccionada(btn: Button) -> void:
	if not is_instance_valid(btn):
		return

	btn.modulate = Color(0.75, 1.0, 0.75, 1.0)

	var tween := btn.create_tween()
	tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.12)


func _limpiar_marca_forma(btn: Button) -> void:
	if not is_instance_valid(btn):
		return

	btn.modulate = Color(1, 1, 1, 1)

	var tween := btn.create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE, 0.10)
