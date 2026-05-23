extends Control

@onready var btn_colores: Button = $Cuadricula/BtnColores
@onready var btn_numeros: Button = $Cuadricula/BtnNumeros
@onready var btn_animales: Button = $Cuadricula/BtnAnimales
@onready var btn_formas: Button = $Cuadricula/BtnFormas
@onready var btn_volver: Button = $BtnVolver
@onready var lumi: Node2D = $Lumi
@onready var titulo: Label = $Titulo

var _portal_tweens: Dictionary = {}
var _timer_recordatorio: Timer = null

func _ready() -> void:
	AudioManager.reproducir_musica_menu()
	UIFont.aplicar_a_control(self)
	FatigaManager.desactivar()

	_aplicar_portales()
	_actualizar_textos()

	btn_colores.pressed.connect(func(): _entrar_mundo("colores"))
	btn_numeros.pressed.connect(func(): _entrar_mundo("numeros"))
	btn_animales.pressed.connect(func(): _entrar_mundo("animales"))
	btn_formas.pressed.connect(func(): _entrar_mundo("formas"))
	btn_volver.pressed.connect(_on_btn_volver_pressed)

	GameState.modo_bilingue_cambiado.connect(func(_activo: bool):
		_actualizar_textos()
	)
	_timer_recordatorio = Timer.new()
	_timer_recordatorio.wait_time = 10.0 # Se repetirá cada 10 segundos
	_timer_recordatorio.one_shot = false
	_timer_recordatorio.timeout.connect(_on_recordatorio_timeout)
	add_child(_timer_recordatorio)
	_timer_recordatorio.start()

func _actualizar_textos() -> void:
	titulo.text = Lang.t("choose_world")
	btn_volver.text = Lang.t("back")

	_estilizar_titulo()
	UIFont.estilizar_boton_volver(btn_volver, Lang.t("back"))

	if lumi:
		var audios: Array[AudioStream] = []
		var audio_voz = AudioManager.obtener_stream_voz("seleccion_mundo")
		if audio_voz:
			audios.append(audio_voz)
		lumi.hablar(Lang.t("lumi_select_world"), audios)


func _estilizar_titulo() -> void:
	var settings := LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 58
	settings.font_color = Color("#fff4c7")
	settings.outline_size = 14
	settings.outline_color = Color("#25415e")
	settings.shadow_size = 8
	settings.shadow_color = Color(0, 0, 0, 0.35)
	settings.shadow_offset = Vector2(3, 5)

	titulo.label_settings = settings
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _entrar_mundo(nombre: String) -> void:
	GameState.mundo_actual = nombre
	_detener_todos_los_tweens_portal()
	get_tree().change_scene_to_file("res://scenes/levels/NivelBase.tscn")


func _aplicar_portales() -> void:
	_configurar_boton_portal(btn_colores, "res://assets/images/portales/portalColores.png")
	_configurar_boton_portal(btn_numeros, "res://assets/images/portales/portalNumeros.png")
	_configurar_boton_portal(btn_animales, "res://assets/images/portales/portalAnimales.png")
	_configurar_boton_portal(btn_formas, "res://assets/images/portales/portalFormas.png")


func _configurar_boton_portal(btn: Button, ruta_textura: String) -> void:
	btn.text = ""
	btn.custom_minimum_size = Vector2(270, 220)
	btn.focus_mode = Control.FOCUS_NONE
	btn.clip_contents = false
	btn.pivot_offset = btn.custom_minimum_size / 2.0

	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("disabled", empty)
	btn.add_theme_stylebox_override("focus", empty)

	for child in btn.get_children():
		child.queue_free()

	if ResourceLoader.exists(ruta_textura):
		var tex: Texture2D = load(ruta_textura)

		var glow_1 := _crear_portal_texture(tex, "Glow1", Color(1, 0.95, 0.25, 0.0), false)
		btn.add_child(glow_1)
		glow_1.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		var glow_2 := _crear_portal_texture(tex, "Glow2", Color(0.25, 0.85, 1.0, 0.0), false)
		btn.add_child(glow_2)
		glow_2.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		var sombra := _crear_portal_texture(tex, "Sombra", Color(0, 0, 0, 0.35), true)
		btn.add_child(sombra)
		sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sombra.offset_left = 8
		sombra.offset_top = 10
		sombra.offset_right = 8
		sombra.offset_bottom = 10

		var img := _crear_portal_texture(tex, "PortalImg", Color.WHITE, true)
		btn.add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		btn.text = "Portal"
		btn.add_theme_font_override("font", UIFont.font)
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color", Color("#25415e"))

	btn.mouse_entered.connect(func():
		_iniciar_hover_portal(btn)
	)

	btn.mouse_exited.connect(func():
		_detener_hover_portal(btn)
	)

	btn.button_down.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(0.96, 0.96), 0.08)
	)

	btn.button_up.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.08)
	)


func _crear_portal_texture(tex: Texture2D, nombre: String, color: Color, visible_inicial: bool) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = nombre
	texture_rect.texture = tex
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.modulate = color
	texture_rect.visible = visible_inicial
	texture_rect.pivot_offset = Vector2(135, 110)
	return texture_rect

func _iniciar_hover_portal(btn: Button) -> void:
	_detener_tweens_portal(btn)

	var glow_1 := btn.get_node_or_null("Glow1") as TextureRect
	var glow_2 := btn.get_node_or_null("Glow2") as TextureRect

	if glow_1:
		glow_1.visible = true
		glow_1.scale = Vector2.ONE
		glow_1.modulate = Color(1, 0.95, 0.25, 0.50)

	if glow_2:
		glow_2.visible = true
		glow_2.scale = Vector2.ONE
		glow_2.modulate = Color(0.25, 0.85, 1.0, 0.35)

	var tween_btn := btn.create_tween()
	tween_btn.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.12)

	var tweens: Array[Tween] = []

	if glow_1:
		tweens.append(_crear_onda_portal(glow_1, Color(1, 0.95, 0.25, 0.52), 0.0))

	if glow_2:
		tweens.append(_crear_onda_portal(glow_2, Color(0.25, 0.85, 1.0, 0.42), 0.35))

	_portal_tweens[btn] = tweens


func _detener_hover_portal(btn: Button) -> void:
	_detener_tweens_portal(btn)

	var glow_1 := btn.get_node_or_null("Glow1") as TextureRect
	var glow_2 := btn.get_node_or_null("Glow2") as TextureRect

	if glow_1:
		glow_1.visible = false
		glow_1.scale = Vector2.ONE
		glow_1.modulate = Color(1, 1, 1, 0)

	if glow_2:
		glow_2.visible = false
		glow_2.scale = Vector2.ONE
		glow_2.modulate = Color(1, 1, 1, 0)

	var tween_btn := btn.create_tween()
	tween_btn.tween_property(btn, "scale", Vector2.ONE, 0.12)


func _crear_onda_portal(glow: TextureRect, color_base: Color, delay: float) -> Tween:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_interval(delay)

	tween.tween_callback(func():
		if is_instance_valid(glow):
			glow.scale = Vector2.ONE
			glow.modulate = color_base
	)

	tween.tween_property(glow, "scale", Vector2(1.18, 1.18), 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(glow, "modulate:a", 0.0, 0.85)
	tween.tween_interval(0.05)

	return tween


func _detener_tweens_portal(btn: Button) -> void:
	if not _portal_tweens.has(btn):
		return

	var tweens: Array = _portal_tweens[btn]

	for tween in tweens:
		if tween and tween.is_valid():
			tween.kill()

	_portal_tweens.erase(btn)


func _detener_todos_los_tweens_portal() -> void:
	for btn in _portal_tweens.keys():
		_detener_tweens_portal(btn)


func _on_btn_volver_pressed() -> void:
	_detener_todos_los_tweens_portal()
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _on_recordatorio_timeout() -> void:
	if lumi:
		var audios: Array[AudioStream] = []
		var audio_voz = AudioManager.obtener_stream_voz("seleccion_mundo")
		if audio_voz: 
			audios.append(audio_voz)
		lumi.hablar(Lang.t("lumi_select_world"), audios)
