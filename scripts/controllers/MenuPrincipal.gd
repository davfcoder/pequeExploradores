extends Control

@onready var btn_jugar: Button = $ContenedorPrincipal/BtnJugar
@onready var btn_padres: Button = $ContenedorPrincipal/BtnPadres
@onready var titulo: Label = $ContenedorPrincipal/Titulo
@onready var lumi: Node2D = $Lumi
@onready var btn_configuracion: Button = $ContenedorPrincipal/BtnConfiguracion

var _popup_config: PopupPanel
var _lbl_titulo_popup: Label
var _btn_musica_popup: Button
var _btn_idioma_popup: Button
var _btn_fullscreen_popup: Button
var _btn_cerrar_popup: Button
var _timer_recordatorio: Timer = null

func _ready() -> void:
	AudioManager.reproducir_musica_menu()
	UIFont.aplicar_a_control(self)

	_actualizar_textos()
	aplicar_estilo_titulo()

	aplicar_estilo_boton(btn_jugar, Color("#ffb430"))
	btn_jugar.custom_minimum_size = Vector2(420, 120)
	btn_jugar.add_theme_font_size_override("font_size", 72)

	aplicar_estilo_boton(btn_padres, Color("#4bc3ff"))
	aplicar_estilo_boton(btn_configuracion, Color("#5eb319"))

	btn_jugar.pressed.connect(_on_btn_jugar_presionado)
	btn_padres.pressed.connect(_on_btn_padres_presionado)
	btn_configuracion.pressed.connect(_abrir_configuracion)

	_crear_popup_configuracion()

	if lumi:
		var audios: Array[AudioStream] = []
		var audio_voz = AudioManager.obtener_stream_voz("saludo_menu")
		if audio_voz:
			audios.append(audio_voz)
		lumi.hablar(Lang.t("lumi_menu"), audios)
	_timer_recordatorio = Timer.new() 
	_timer_recordatorio.wait_time = 12.0 # Se repetirá cada 12 segundos 
	_timer_recordatorio.one_shot = false 
	_timer_recordatorio.timeout.connect(_on_recordatorio_timeout) 
	add_child(_timer_recordatorio) 
	_timer_recordatorio.start()

func _actualizar_textos() -> void:
	btn_jugar.text = Lang.t("play")
	btn_padres.text = Lang.t("parents")
	btn_configuracion.text = Lang.t("settings")


func aplicar_estilo_titulo() -> void:
	var settings := LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 90
	settings.font_color = Color("#25415e")
	settings.outline_size = 20
	settings.outline_color = Color.WHITE
	settings.shadow_size = 10
	settings.shadow_color = Color(0, 0, 0, 0.2)
	settings.shadow_offset = Vector2(5, 5)

	titulo.label_settings = settings


func aplicar_estilo_boton(btn: Button, color_base: Color) -> void:
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = color_base
	style_normal.corner_radius_top_left = 40
	style_normal.corner_radius_top_right = 40
	style_normal.corner_radius_bottom_left = 40
	style_normal.corner_radius_bottom_right = 40
	style_normal.border_width_bottom = 16
	style_normal.border_color = color_base.darkened(0.3)
	style_normal.shadow_color = Color(0, 0, 0, 0.2)
	style_normal.shadow_size = 10
	style_normal.shadow_offset = Vector2(0, 10)

	var style_hover := style_normal.duplicate()
	style_hover.bg_color = color_base.lightened(0.1)
	style_hover.border_width_bottom = 10
	style_hover.content_margin_top = 6
	style_hover.shadow_size = 6
	style_hover.shadow_offset = Vector2(0, 6)

	var style_pressed := style_normal.duplicate()
	style_pressed.bg_color = color_base.darkened(0.1)
	style_pressed.border_width_bottom = 2
	style_pressed.border_width_top = 4
	style_pressed.content_margin_top = 14
	style_pressed.shadow_size = 0
	style_pressed.shadow_offset = Vector2.ZERO

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)

	btn.add_theme_font_size_override("font_size", 44)
	btn.add_theme_constant_override("outline_size", 10)
	btn.add_theme_color_override("font_outline_color", color_base.darkened(0.4))

	btn.focus_mode = Control.FOCUS_NONE


func _on_btn_jugar_presionado() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")


func _on_btn_padres_presionado() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/PasarelaPadres.tscn")


func _crear_popup_configuracion() -> void:
	_popup_config = PopupPanel.new()
	_popup_config.size = Vector2i(560, 420)
	add_child(_popup_config)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#fff9eb")
	panel_style.corner_radius_top_left = 32
	panel_style.corner_radius_top_right = 32
	panel_style.corner_radius_bottom_left = 32
	panel_style.corner_radius_bottom_right = 32
	panel_style.border_width_left = 6
	panel_style.border_width_top = 6
	panel_style.border_width_right = 6
	panel_style.border_width_bottom = 6
	panel_style.border_color = Color("#ffb430")
	panel_style.shadow_color = Color(0, 0, 0, 0.25)
	panel_style.shadow_size = 18
	panel_style.shadow_offset = Vector2(0, 8)

	_popup_config.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	_popup_config.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	margin.add_child(vbox)

	_lbl_titulo_popup = Label.new()
	_lbl_titulo_popup.text = Lang.t("settings")
	_lbl_titulo_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_titulo_popup.add_theme_font_override("font", UIFont.font)
	_lbl_titulo_popup.add_theme_font_size_override("font_size", 38)
	_lbl_titulo_popup.add_theme_color_override("font_color", Color("#25415e"))
	vbox.add_child(_lbl_titulo_popup)

	_btn_musica_popup = Button.new()
	UIFont.estilizar_boton_volver(_btn_musica_popup, _texto_boton_musica())
	_btn_musica_popup.pressed.connect(func():
		AudioManager.set_musica_activa(not GameState.musica_activa)
		SaveSystem.guardar()
		_actualizar_textos_configuracion()
	)
	vbox.add_child(_btn_musica_popup)

	_btn_idioma_popup = Button.new()
	UIFont.estilizar_boton_volver(_btn_idioma_popup, _texto_boton_idioma())
	_btn_idioma_popup.disabled = not GameState.bilingue_desbloqueado
	_btn_idioma_popup.pressed.connect(func():
		if GameState.idioma_actual == "es":
			GameState.set_idioma("en")
		else:
			GameState.set_idioma("es")

		SaveSystem.guardar()
		_actualizar_textos()
		_actualizar_textos_configuracion()
	)
	vbox.add_child(_btn_idioma_popup)

	_btn_fullscreen_popup = Button.new()
	UIFont.estilizar_boton_volver(_btn_fullscreen_popup, WindowManager.get_texto_boton())
	_btn_fullscreen_popup.pressed.connect(func():
		WindowManager.toggle_fullscreen()
		SaveSystem.guardar()
		_actualizar_textos_configuracion()
	)
	vbox.add_child(_btn_fullscreen_popup)

	_btn_cerrar_popup = Button.new()
	UIFont.estilizar_boton_volver(_btn_cerrar_popup, Lang.t("close"))
	_btn_cerrar_popup.pressed.connect(func():
		_popup_config.hide()
	)
	vbox.add_child(_btn_cerrar_popup)


func _texto_boton_musica() -> String:
	return Lang.t("music_on") if GameState.musica_activa else Lang.t("music_off")


func _texto_boton_idioma() -> String:
	if not GameState.bilingue_desbloqueado:
		return Lang.t("language_locked")

	return Lang.t("language_en") if GameState.esta_en_ingles() else Lang.t("language_es")


func _actualizar_textos_configuracion() -> void:
	if _lbl_titulo_popup:
		_lbl_titulo_popup.text = Lang.t("settings")

	if _btn_musica_popup:
		_btn_musica_popup.text = _texto_boton_musica()

	if _btn_idioma_popup:
		_btn_idioma_popup.text = _texto_boton_idioma()
		_btn_idioma_popup.disabled = not GameState.bilingue_desbloqueado

	if _btn_fullscreen_popup:
		_btn_fullscreen_popup.text = WindowManager.get_texto_boton()

	if _btn_cerrar_popup:
		_btn_cerrar_popup.text = Lang.t("close")


func _abrir_configuracion() -> void:
	_actualizar_textos()
	_actualizar_textos_configuracion()
	_popup_config.popup_centered(_popup_config.size)

func _on_recordatorio_timeout() -> void:
	# Si el panel de configuración está abierto, no interrumpimos al usuario
	if _popup_config and _popup_config.visible:
		return
		
	if lumi:
		var audios: Array[AudioStream] = []
		var audio_voz = AudioManager.obtener_stream_voz("saludo_menu")
		if audio_voz: 
			audios.append(audio_voz)
		lumi.hablar(Lang.t("lumi_menu"), audios)
