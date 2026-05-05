class_name MundoNumeros
extends MundoBase

func get_nombre_mundo() -> String:
	return "Isla de los Números"

func nueva_ronda() -> void:
	match randi() % 3:
		0: _mision_cuenta_objetos()
		1: _mision_toca_numero()
		2: _mision_tarjeta_cantidad()

func _mision_cuenta_objetos() -> void:
	var opciones := preparar_opciones(3)
	var cantidad := int(objetivo_actual.nombre_id)
	emitir_instruccion("Cuenta los puntos y toca el número correcto")

	var center := _contenedor_central()
	var vbox   := _vbox_en(center, 40)
	_dibujar_puntos(cantidad, vbox)
	var hbox := _hbox_en(vbox, 50)
	for res in opciones:
		_crear_boton_numero(res, hbox)

func _mision_toca_numero() -> void:
	var opciones := preparar_opciones(3)
	emitir_instruccion("Toca el número: " + GameState.get_nombre_elemento(objetivo_actual))
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_numero(res, hbox)

func _mision_tarjeta_cantidad() -> void:
	var opciones := preparar_opciones(3)
	var cantidad := int(objetivo_actual.nombre_id)
	emitir_instruccion("Toca la tarjeta que tiene " + str(cantidad) + " puntos")

	var center := _contenedor_central()
	var vbox   := _vbox_en(center, 40)

	# Número grande de referencia con estilo
	var numero_ref := TextureRect.new()
	numero_ref.custom_minimum_size = Vector2(160, 160)
	numero_ref.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	numero_ref.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	numero_ref.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if objetivo_actual.textura_visual:
		numero_ref.texture = objetivo_actual.textura_visual

	vbox.add_child(numero_ref)

	var hbox := _hbox_en(vbox, 50)
	for res in opciones:
		_crear_tarjeta_puntos(res, hbox)

# ── Helpers ──────────────────────────────────────────────────────────

func _crear_boton_numero(recurso: Resource, parent: Node) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(190, 190)
	btn.clip_contents = true

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.0)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0

	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = Color(1, 1, 1, 0.12)
	style_hover.corner_radius_top_left = 24
	style_hover.corner_radius_top_right = 24
	style_hover.corner_radius_bottom_left = 24
	style_hover.corner_radius_bottom_right = 24
	style_hover.border_width_left = 5
	style_hover.border_width_top = 5
	style_hover.border_width_right = 5
	style_hover.border_width_bottom = 5
	style_hover.border_color = Color("#ffb430")

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)
	btn.add_theme_stylebox_override("focus", style)

	if recurso.textura_visual:
		var img := TextureRect.new()
		img.texture = recurso.textura_visual
		img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE

		btn.add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		btn.text = recurso.nombre_id
		btn.add_theme_font_size_override("font_size", 90)
		btn.add_theme_color_override("font_color", Color("#25415e"))

	btn.pressed.connect(func(): verificar_respuesta(recurso))
	registrar_boton(btn)
	parent.add_child(btn)

func _crear_tarjeta_puntos(recurso: Resource, parent: Node) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(190, 170)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.clip_contents = false
	btn.focus_mode = Control.FOCUS_NONE
	btn.pivot_offset = Vector2(95, 85)

	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("disabled", empty)
	btn.add_theme_stylebox_override("focus", empty)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(1, 1, 1, 0.10)
	hover_style.corner_radius_top_left = 24
	hover_style.corner_radius_top_right = 24
	hover_style.corner_radius_bottom_left = 24
	hover_style.corner_radius_bottom_right = 24
	btn.add_theme_stylebox_override("hover", hover_style)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center.add_child(grid)

	for i in range(int(recurso.nombre_id)):
		var punto := _crear_punto(38)
		grid.add_child(punto)

	btn.mouse_entered.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.10, 1.10), 0.12)
	)

	btn.mouse_exited.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2.ONE, 0.12)
	)

	btn.pressed.connect(func(): verificar_respuesta(recurso))
	registrar_boton(btn)
	parent.add_child(btn)

func _dibujar_puntos(cantidad: int, parent: Node) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var sty := StyleBoxFlat.new()
	sty.bg_color                   = Color(1, 1, 1, 0.55)
	sty.corner_radius_top_left     = 24
	sty.corner_radius_top_right    = 24
	sty.corner_radius_bottom_left  = 24
	sty.corner_radius_bottom_right = 24
	sty.content_margin_left        = 20
	sty.content_margin_right       = 20
	sty.content_margin_top         = 16
	sty.content_margin_bottom      = 16
	panel.add_theme_stylebox_override("panel", sty)

	var flow := HFlowContainer.new()
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 12)
	flow.custom_minimum_size = Vector2(min(cantidad, 5) * 72.0, 0)
	panel.add_child(flow)

	for i in range(cantidad):
		var punto := _crear_punto(56)
		flow.add_child(punto)

	parent.add_child(panel)

func _crear_punto(radio: int = 30) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(radio, radio)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var radio_esquina: int = int(radio / 2.0)

	var s := StyleBoxFlat.new()
	s.bg_color = Color("#ffb430")
	s.corner_radius_top_left = radio_esquina
	s.corner_radius_top_right = radio_esquina
	s.corner_radius_bottom_left = radio_esquina
	s.corner_radius_bottom_right = radio_esquina
	s.border_width_left = 3
	s.border_width_top = 3
	s.border_width_right = 3
	s.border_width_bottom = 3
	s.border_color = Color("#e08000")
	s.shadow_color = Color(0, 0, 0, 0.2)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 2)

	p.add_theme_stylebox_override("panel", s)
	return p
