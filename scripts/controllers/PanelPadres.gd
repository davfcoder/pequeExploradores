extends Control

@onready var contenedor: VBoxContainer = $ScrollContainer/Fondo/Contenedor
@onready var btn_volver: Button        = $BtnVolver

var _popup_confirmar_borrado: PopupPanel

func _ready() -> void:
	AudioManager.reproducir_musica_menu()
	UIFont.aplicar_a_control(self)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, Lang.t("back"))
	_crear_popup_confirmar_borrado()
	_construir_interfaz()


func _nombre_mundo_localizado(mundo: String) -> String:
	match mundo:
		"colores":
			return Lang.t("world_colores")
		"numeros":
			return Lang.t("world_numeros")
		"animales":
			return Lang.t("world_animales")
		"formas":
			return Lang.t("world_formas")
	return mundo

func _construir_interfaz() -> void:
	for hijo in contenedor.get_children():
		hijo.queue_free()

	_agregar_label(Lang.t("progress_report"), 42, Color("#25415e"), true)

	# Calcular tiempo total REAL sumando los mundos
	var tiempo_real: float = 0.0
	for mundo in GameState.MUNDOS:
		tiempo_real += float(GameState.progreso_mundos[mundo]["time"])

	for mundo in GameState.MUNDOS:
		var datos: Dictionary = GameState.progreso_mundos[mundo]
		var tiempo: String    = _formatear_tiempo(int(float(datos["time"])))
		var iconos: Dictionary = {
			"colores": "🎨", "numeros": "🔢",
			"animales": "🐾", "formas": "🔷"
		}
		var icono: String = iconos.get(mundo, "🌍")
		var aciertos: String = str(int(float(datos["stars"])))
		var errores: String  = str(int(float(datos["errors"])))

		var card := _crear_tarjeta(
			icono + " " + _nombre_mundo_localizado(mundo),
			"✅ " + aciertos + "  |  ❌ " + errores + "  |  ⏱ " + tiempo
		)
		contenedor.add_child(card)

	var btn_bilingue := Button.new()
	if GameState.bilingue_desbloqueado:
		btn_bilingue.text = Lang.t("bilingual_unlocked")
		btn_bilingue.disabled = true
	else:
		btn_bilingue.text = Lang.t("unlock_bilingual")
	UIFont.estilizar_boton_volver(btn_bilingue, btn_bilingue.text)
	btn_bilingue.pressed.connect(func():
		GameState.desbloquear_bilingue()
		SaveSystem.guardar()
		_construir_interfaz()
	)
	contenedor.add_child(btn_bilingue)

	_agregar_label("⏱ " + Lang.t("total_time") + ": " + _formatear_tiempo(int(tiempo_real)), 26, Color("#25415e"), false)

	var btn_borrar := Button.new()
	btn_borrar.text = "🗑️ " + Lang.t("delete_all")
	btn_borrar.add_theme_font_size_override("font_size", 24)
	btn_borrar.add_theme_color_override("font_color", Color.WHITE)
	var s := StyleBoxFlat.new()
	s.bg_color                   = Color("#cc0000")
	s.corner_radius_top_left     = 12
	s.corner_radius_top_right    = 12
	s.corner_radius_bottom_left  = 12
	s.corner_radius_bottom_right = 12
	btn_borrar.add_theme_stylebox_override("normal", s)
	btn_borrar.pressed.connect(_on_btn_borrar_pressed)
	contenedor.add_child(btn_borrar)
	UIFont.aplicar_a_control(contenedor)

func _agregar_label(texto: String, font_sz: int, color: Color, centrado: bool) -> void:
	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_override("font", UIFont.font)
	lbl.add_theme_font_size_override("font_size", font_sz)
	lbl.add_theme_color_override("font_color", color)

	if centrado:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	contenedor.add_child(lbl)

func _crear_tarjeta(titulo: String, detalle: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color                   = Color.WHITE
	style.corner_radius_top_left     = 16
	style.corner_radius_top_right    = 16
	style.corner_radius_bottom_left  = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left        = 20
	style.content_margin_right       = 20
	style.content_margin_top         = 10
	style.content_margin_bottom      = 10
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var lbl_t := Label.new()
	lbl_t.add_theme_font_override("font", UIFont.font)
	lbl_t.text = titulo
	lbl_t.add_theme_font_size_override("font_size", 28)
	lbl_t.add_theme_color_override("font_color", Color("#25415e"))
	vbox.add_child(lbl_t)

	var lbl_d := Label.new()
	lbl_d.add_theme_font_override("font", UIFont.font)
	lbl_d.text = detalle
	lbl_d.add_theme_font_size_override("font_size", 22)
	lbl_d.add_theme_color_override("font_color", Color("#555555"))
	vbox.add_child(lbl_d)

	return panel

func _formatear_tiempo(segundos: int) -> String:
	var mins: int = int(segundos / 60.0)
	var segs: int = segundos % 60
	return str(mins) + "m " + str(segs) + "s"

func _on_btn_borrar_pressed() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var popup_size: Vector2 = Vector2(_popup_confirmar_borrado.size)

	_popup_confirmar_borrado.position = Vector2i((viewport_size - popup_size) / 2.0)
	_popup_confirmar_borrado.popup()

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _confirmar_borrado_datos() -> void:
	SaveSystem.borrar()
	_construir_interfaz()

func _crear_popup_confirmar_borrado() -> void:
	_popup_confirmar_borrado = PopupPanel.new()
	_popup_confirmar_borrado.size = Vector2i(620, 330)
	add_child(_popup_confirmar_borrado)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#fff9eb")
	panel_style.corner_radius_top_left = 32
	panel_style.corner_radius_top_right = 32
	panel_style.corner_radius_bottom_left = 32
	panel_style.corner_radius_bottom_right = 32
	panel_style.border_width_left = 7
	panel_style.border_width_top = 7
	panel_style.border_width_right = 7
	panel_style.border_width_bottom = 7
	panel_style.border_color = Color("#ffb430")
	panel_style.shadow_color = Color(0, 0, 0, 0.30)
	panel_style.shadow_size = 22
	panel_style.shadow_offset = Vector2(0, 10)

	_popup_confirmar_borrado.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	_popup_confirmar_borrado.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 22)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = Lang.t("confirm")
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.label_settings = UIFont.crear_label_settings(
		40,
		Color("#25415e"),
		8,
		Color.WHITE
	)
	vbox.add_child(lbl_titulo)

	var lbl_mensaje := Label.new()
	lbl_mensaje.text = Lang.t("delete_confirm")
	lbl_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_mensaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_mensaje.custom_minimum_size = Vector2(520, 90)
	lbl_mensaje.label_settings = UIFont.crear_label_settings(
		28,
		Color("#25415e"),
		4,
		Color.WHITE
	)
	vbox.add_child(lbl_mensaje)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 26)
	vbox.add_child(botones)

	var btn_cancelar := Button.new()
	UIFont.estilizar_boton_volver(btn_cancelar, Lang.t("cancel"))
	btn_cancelar.pressed.connect(func():
		_popup_confirmar_borrado.hide()
	)
	botones.add_child(btn_cancelar)

	var btn_confirmar := Button.new()
	UIFont.estilizar_boton_peligro(btn_confirmar, Lang.t("yes_delete"))
	btn_confirmar.pressed.connect(func():
		_popup_confirmar_borrado.hide()
		_confirmar_borrado_datos()
	)
	botones.add_child(btn_confirmar)
