extends Control

@onready var contenedor: VBoxContainer = $ScrollContainer/Fondo/Contenedor
@onready var btn_volver: Button        = $BtnVolver

func _ready() -> void:
	UIFont.aplicar_a_control(self)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, "Volver")
	_construir_interfaz()

func _construir_interfaz() -> void:
	for hijo in contenedor.get_children():
		hijo.queue_free()

	_agregar_label("📊 Reporte de Aprendizaje", 42, Color("#25415e"), true)

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
			icono + " " + mundo.capitalize(),
			"✅ " + aciertos + "  |  ❌ " + errores + "  |  ⏱ " + tiempo
		)
		contenedor.add_child(card)

	var toggle := CheckButton.new()
	toggle.text = "Activar Modo Bilingüe (Inglés)"
	toggle.button_pressed = GameState.modo_bilingue_comprado
	_estilizar_toggle_bilingue(toggle)
	toggle.toggled.connect(func(on: bool):
		GameState.set_modo_bilingue(on)
		SaveSystem.guardar()
	)
	contenedor.add_child(toggle)

	_agregar_label(
		"⏱ Tiempo total: " + _formatear_tiempo(int(tiempo_real)),
		26, Color("#25415e"), false
	)

	var btn_borrar := Button.new()
	btn_borrar.text = "🗑️ Borrar todos los datos"
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
	var mins: int = segundos / 60
	var segs: int = segundos % 60
	return str(mins) + "m " + str(segs) + "s"

func _on_btn_borrar_pressed() -> void:
	SaveSystem.borrar()
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _estilizar_toggle_bilingue(toggle: CheckButton) -> void:
	toggle.add_theme_font_override("font", UIFont.font)
	toggle.add_theme_font_size_override("font_size", 28)

	var color_texto := Color("#25415e")

	toggle.add_theme_color_override("font_color", color_texto)
	toggle.add_theme_color_override("font_hover_color", color_texto)
	toggle.add_theme_color_override("font_pressed_color", color_texto)
	toggle.add_theme_color_override("font_hover_pressed_color", color_texto)
	toggle.add_theme_color_override("font_focus_color", color_texto)

	toggle.add_theme_color_override("icon_normal_color", Color("#4bc3ff"))
	toggle.add_theme_color_override("icon_hover_color", Color("#ffb430"))
	toggle.add_theme_color_override("icon_pressed_color", Color("#5eb319"))
	toggle.add_theme_color_override("icon_hover_pressed_color", Color("#5eb319"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.0)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color("#fff4c7")
	hover.corner_radius_top_left = 14
	hover.corner_radius_top_right = 14
	hover.corner_radius_bottom_left = 14
	hover.corner_radius_bottom_right = 14
	hover.content_margin_left = 12
	hover.content_margin_right = 12
	hover.content_margin_top = 8
	hover.content_margin_bottom = 8

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color("#d4ffb0")
	pressed.corner_radius_top_left = 14
	pressed.corner_radius_top_right = 14
	pressed.corner_radius_bottom_left = 14
	pressed.corner_radius_bottom_right = 14
	pressed.content_margin_left = 12
	pressed.content_margin_right = 12
	pressed.content_margin_top = 8
	pressed.content_margin_bottom = 8

	var focus := StyleBoxEmpty.new()

	toggle.add_theme_stylebox_override("normal", normal)
	toggle.add_theme_stylebox_override("hover", hover)
	toggle.add_theme_stylebox_override("pressed", pressed)
	toggle.add_theme_stylebox_override("hover_pressed", pressed)
	toggle.add_theme_stylebox_override("focus", focus)
	
