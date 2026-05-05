class_name MundoColores
extends MundoBase

func get_nombre_mundo() -> String:
	return "Valle de los Colores"

func nueva_ronda() -> void:
	match randi() % 3:
		0: _mision_toca_color()
		1: _mision_encuentra_igual()
		2: _mision_color_repetido()

func _mision_toca_color() -> void:
	var opciones := preparar_opciones(3)
	emitir_instruccion("Toca el color: " + GameState.get_nombre_elemento(objetivo_actual))
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_color(res, hbox)

func _mision_encuentra_igual() -> void:
	var opciones := preparar_opciones(3)
	emitir_instruccion("Encuentra el color igual a la burbuja")

	var center := _contenedor_central()
	var vbox   := _vbox_en(center, 40)

	# Burbuja grande y redonda con sombra
	var panel := Panel.new()
	panel.custom_minimum_size      = Vector2(160, 160)
	panel.size_flags_horizontal    = Control.SIZE_SHRINK_CENTER

	var sty := StyleBoxFlat.new()
	sty.bg_color                   = objetivo_actual.valor_asociado
	sty.corner_radius_top_left     = 80
	sty.corner_radius_top_right    = 80
	sty.corner_radius_bottom_left  = 80
	sty.corner_radius_bottom_right = 80
	sty.border_width_left          = 8
	sty.border_width_top           = 8
	sty.border_width_right         = 8
	sty.border_width_bottom        = 8
	sty.border_color               = Color.WHITE
	sty.shadow_color               = Color(0, 0, 0, 0.25)
	sty.shadow_size                = 16
	sty.shadow_offset              = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", sty)
	vbox.add_child(panel)

	var hbox := _hbox_en(vbox, 50)
	for res in opciones:
		_crear_boton_color(res, hbox)

func _mision_color_repetido() -> void:
	var copia: Array[Resource] = recursos.duplicate()
	copia.shuffle()
	objetivo_actual         = copia[0]
	var distinto: Resource  = copia[1]
	var opciones: Array     = [objetivo_actual, objetivo_actual, distinto]
	opciones.shuffle()
	emitir_instruccion("Toca el color que aparece dos veces")
	var center := _contenedor_central()
	var hbox   := _hbox_en(center, 50)
	for res in opciones:
		_crear_boton_color(res, hbox)

func _crear_boton_color(recurso: Resource, parent: Node) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(210, 210)

	var color: Color = recurso.valor_asociado

	# Efecto 3D: borde inferior más oscuro
	var style := StyleBoxFlat.new()
	style.bg_color                   = color
	style.corner_radius_top_left     = 32
	style.corner_radius_top_right    = 32
	style.corner_radius_bottom_left  = 32
	style.corner_radius_bottom_right = 32
	style.border_width_bottom        = 12
	style.border_width_left          = 4
	style.border_width_right         = 4
	style.border_width_top           = 4
	style.border_color               = color.darkened(0.35)
	style.shadow_color               = Color(0, 0, 0, 0.2)
	style.shadow_size                = 12
	style.shadow_offset              = Vector2(0, 6)

	var style_hover := style.duplicate()
	style_hover.bg_color        = color.lightened(0.15)
	style_hover.border_width_bottom = 6
	style_hover.shadow_size     = 6

	var style_press := style.duplicate()
	style_press.bg_color        = color.darkened(0.1)
	style_press.border_width_bottom = 2
	style_press.shadow_size     = 0

	btn.add_theme_stylebox_override("normal",   style)
	btn.add_theme_stylebox_override("hover",    style_hover)
	btn.add_theme_stylebox_override("pressed",  style_press)
	btn.add_theme_stylebox_override("disabled", style)

	btn.text = GameState.get_nombre_elemento(recurso)
	btn.add_theme_font_size_override("font_size", 30)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_constant_override("outline_size", 8)
	btn.add_theme_color_override("font_outline_color", color.darkened(0.4))

	btn.pressed.connect(func(): verificar_respuesta(recurso))
	registrar_boton(btn)
	parent.add_child(btn)
