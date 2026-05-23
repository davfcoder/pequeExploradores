class_name MundoAnimales
extends MundoBase

func get_nombre_mundo() -> String:
	return "Mundo de los Animales"

func nueva_ronda() -> void:
	match randi() % 4:
		0: _mision_identifica_por_sonido()
		1: _mision_toca_animal()
		2: _mision_silueta()
		3: _mision_asociar_habitat()

func _mision_identifica_por_sonido() -> void:
	var opciones := preparar_opciones(3)
	var texto = Lang.t("animal_sound")
	
	var audios: Array[AudioStream] = []
	var audio_instruccion = AudioManager.obtener_stream_voz("animal_sonido")
	if audio_instruccion:
		audios.append(audio_instruccion)
	if objetivo_actual.audio_efecto:
		audios.append(objetivo_actual.audio_efecto)
		
	emitir_instruccion(texto, audios)
	
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_animal(res, hbox)

func _mision_toca_animal() -> void:
	var opciones := preparar_opciones(3)
	var texto = Lang.t("touch_animal", {"name": GameState.get_nombre_elemento(objetivo_actual)})
	
	var audios: Array[AudioStream] = []
	var audio_instruccion = AudioManager.obtener_stream_voz("toca_animal")
	if audio_instruccion:
		audios.append(audio_instruccion)
	var audio_elemento = objetivo_actual.get_audio_nombre()
	if audio_elemento:
		audios.append(audio_elemento)
		
	emitir_instruccion(texto, audios)
	
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_animal(res, hbox)

func _mision_silueta() -> void:
	var opciones := preparar_opciones(3)
	var texto = Lang.t("animal_shadow")
	
	var audios: Array[AudioStream] = []
	var audio_instruccion = AudioManager.obtener_stream_voz("animal_silueta")
	if audio_instruccion:
		audios.append(audio_instruccion)
	
	emitir_instruccion(texto, audios)

	var center := _contenedor_central()
	var vbox := _vbox_en(center, 35)

	var panel_sil := Panel.new()
	panel_sil.custom_minimum_size = Vector2(230, 230)
	panel_sil.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(1, 1, 1, 0.0)
	sty.corner_radius_top_left = 24
	sty.corner_radius_top_right = 24
	sty.corner_radius_bottom_left = 24
	sty.corner_radius_bottom_right = 24
	sty.border_width_left = 0
	sty.border_width_top = 0
	sty.border_width_right = 0
	sty.border_width_bottom = 0
	panel_sil.add_theme_stylebox_override("panel", sty)

	var textura : Texture2D = objetivo_actual.textura_silueta
	if textura == null:
		textura = objetivo_actual.textura_visual

	if textura:
		var img_sil := TextureRect.new()
		img_sil.texture = textura
		img_sil.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img_sil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img_sil.mouse_filter = Control.MOUSE_FILTER_IGNORE

		panel_sil.add_child(img_sil)
		img_sil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	vbox.add_child(panel_sil)

	var hbox := _hbox_en(vbox, 50)
	for res in opciones:
		_crear_boton_animal(res, hbox)

func _crear_boton_animal(recurso: Resource, parent: Node) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(210, 210)
	btn.clip_contents       = true

	# Fondo completamente transparente — solo se ve la imagen
	var style := StyleBoxFlat.new()
	style.bg_color                   = Color(1, 1, 1, 0.0)
	style.corner_radius_top_left     = 20
	style.corner_radius_top_right    = 20
	style.corner_radius_bottom_left  = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left          = 5
	style.border_width_top           = 5
	style.border_width_right         = 5
	style.border_width_bottom        = 5
	style.border_color               = Color(1, 1, 1, 0.0)

	var style_hover := style.duplicate()
	style_hover.border_color         = Color("#5eb319")
	style_hover.bg_color             = Color(1, 1, 1, 0.15)
	style_hover.border_width_left    = 7
	style_hover.border_width_top     = 7
	style_hover.border_width_right   = 7
	style_hover.border_width_bottom  = 7

	btn.add_theme_stylebox_override("normal",   style)
	btn.add_theme_stylebox_override("hover",    style_hover)
	btn.add_theme_stylebox_override("disabled", style)
	btn.add_theme_stylebox_override("focus",    style)

	if recurso.textura_visual:
		var img := TextureRect.new()
		img.texture             = recurso.textura_visual
		img.expand_mode         = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.mouse_filter        = Control.MOUSE_FILTER_IGNORE
		btn.add_child(img)

	btn.pressed.connect(func():
		if recurso.audio_efecto:
			AudioManager.reproducir_sfx_animal(recurso.audio_efecto)
			verificar_respuesta(recurso)
	)
	registrar_boton(btn, recurso)
	parent.add_child(btn)

func _mision_asociar_habitat() -> void:
	var opciones := preparar_opciones(3)
	var texto = Lang.t("animal_habitat", {"name": GameState.get_nombre_elemento(objetivo_actual)})
	
	var audios: Array[AudioStream] = []
	var audio_instruccion = AudioManager.obtener_stream_voz("animal_habitat")
	if audio_instruccion:
		audios.append(audio_instruccion)
	var audio_elemento = objetivo_actual.get_audio_nombre()
	if audio_elemento:
		audios.append(audio_elemento)
		
	emitir_instruccion(texto, audios)

	var center := _contenedor_central()
	var vbox := _vbox_en(center, 35)

	var animal_card := PanelContainer.new()
	animal_card.custom_minimum_size = Vector2(230, 210)
	animal_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.10)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	style.shadow_color = Color(0, 0, 0, 0.20)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 5)
	animal_card.add_theme_stylebox_override("panel", style)

	if objetivo_actual.textura_visual:
		var img_animal := TextureRect.new()
		img_animal.texture = objetivo_actual.textura_visual
		img_animal.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img_animal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img_animal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		animal_card.add_child(img_animal)

	vbox.add_child(animal_card)

	var hbox := _hbox_en(vbox, 42)

	for res in opciones:
		_crear_boton_habitat_imagen(res, hbox)

func _crear_boton_habitat_imagen(recurso: Resource, parent: Node) -> void:
	var elem := recurso as ElementoEducativo
	if elem == null:
		return

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(240, 170)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.clip_contents = false
	btn.focus_mode = Control.FOCUS_NONE
	btn.pivot_offset = Vector2(120, 85)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.20)
	normal.corner_radius_top_left = 28
	normal.corner_radius_top_right = 28
	normal.corner_radius_bottom_left = 28
	normal.corner_radius_bottom_right = 28
	normal.border_width_left = 4
	normal.border_width_top = 4
	normal.border_width_right = 4
	normal.border_width_bottom = 4
	normal.border_color = Color.WHITE
	normal.shadow_color = Color(0, 0, 0, 0.22)
	normal.shadow_size = 9
	normal.shadow_offset = Vector2(0, 5)

	var hover := normal.duplicate()
	hover.bg_color = Color(1, 1, 1, 0.35)
	hover.border_color = Color("#fff176")
	hover.shadow_color = Color("#fff176")
	hover.shadow_size = 18

	var pressed := normal.duplicate()
	pressed.bg_color = Color(1, 1, 1, 0.12)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", normal)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	if elem.textura_habitat:
		var img := TextureRect.new()
		img.texture = elem.textura_habitat
		img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE

		btn.add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.offset_left = 8
		img.offset_right = -8
		img.offset_top = 8
		img.offset_bottom = -8
	else:
		btn.text = "Sin imagen"
		btn.add_theme_font_override("font", UIFont.font)
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", Color("#25415e"))

	btn.mouse_entered.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.12)
	)

	btn.mouse_exited.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2.ONE, 0.12)
	)

	btn.pressed.connect(func():
		verificar_respuesta(recurso)
	)

	registrar_boton(btn, recurso)
	parent.add_child(btn)
