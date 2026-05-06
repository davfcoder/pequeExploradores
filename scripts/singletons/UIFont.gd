extends Node

const FONT_PATH := "res://assets/fonts/Chunky Playful.otf"

var font: FontFile

func _ready() -> void:
	font = load(FONT_PATH)

func aplicar_a_control(root: Node) -> void:
	if font == null:
		return

	if root is Control:
		root.add_theme_font_override("font", font)

	for child in root.get_children():
		aplicar_a_control(child)

func crear_label_settings(size: int, color: Color, outline_size: int = 0, outline_color: Color = Color.WHITE) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font = font
	settings.font_size = size
	settings.font_color = color
	settings.outline_size = outline_size
	settings.outline_color = outline_color
	return settings

func estilizar_boton_volver(btn: Button, texto: String = "↩ Volver") -> void:
	btn.text = texto
	btn.custom_minimum_size = Vector2(150, 64)
	btn.focus_mode = Control.FOCUS_NONE

	if font:
		btn.add_theme_font_override("font", font)

	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_constant_override("outline_size", 6)
	btn.add_theme_color_override("font_outline_color", Color("#25415e"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#4bc3ff")
	normal.corner_radius_top_left = 24
	normal.corner_radius_top_right = 24
	normal.corner_radius_bottom_left = 24
	normal.corner_radius_bottom_right = 24
	normal.border_width_bottom = 8
	normal.border_color = Color("#228dbd")
	normal.shadow_color = Color(0, 0, 0, 0.22)
	normal.shadow_size = 8
	normal.shadow_offset = Vector2(0, 5)

	var hover := normal.duplicate()
	hover.bg_color = Color("#62d4ff")
	hover.border_width_bottom = 5
	hover.shadow_size = 5
	hover.shadow_offset = Vector2(0, 3)

	var pressed := normal.duplicate()
	pressed.bg_color = Color("#2fa8dc")
	pressed.border_width_bottom = 2
	pressed.border_width_top = 4
	pressed.shadow_size = 0

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", normal)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func estilizar_boton_peligro(btn: Button, texto: String = "Borrar") -> void:
	btn.text = texto
	btn.custom_minimum_size = Vector2(170, 58)
	btn.focus_mode = Control.FOCUS_NONE

	if font:
		btn.add_theme_font_override("font", font)

	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_constant_override("outline_size", 5)
	btn.add_theme_color_override("font_outline_color", Color("#7a1010"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#ff4d4d")
	normal.corner_radius_top_left = 20
	normal.corner_radius_top_right = 20
	normal.corner_radius_bottom_left = 20
	normal.corner_radius_bottom_right = 20
	normal.border_width_bottom = 7
	normal.border_color = Color("#b82020")
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 8
	normal.shadow_offset = Vector2(0, 5)

	var hover := normal.duplicate()
	hover.bg_color = Color("#ff7070")
	hover.border_width_bottom = 4

	var pressed := normal.duplicate()
	pressed.bg_color = Color("#d93636")
	pressed.border_width_bottom = 2
	pressed.shadow_size = 0

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func estilizar_boton_repetir(btn: Button) -> void:
	btn.text = "🔊"
	btn.custom_minimum_size = Vector2(72, 72)
	btn.focus_mode = Control.FOCUS_NONE

	if font:
		btn.add_theme_font_override("font", font)

	btn.add_theme_font_size_override("font_size", 34)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#ffb430")
	normal.corner_radius_top_left = 36
	normal.corner_radius_top_right = 36
	normal.corner_radius_bottom_left = 36
	normal.corner_radius_bottom_right = 36
	normal.border_width_bottom = 7
	normal.border_color = Color("#d98a00")
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 8
	normal.shadow_offset = Vector2(0, 5)

	var hover := normal.duplicate()
	hover.bg_color = Color("#ffd166")
	hover.border_width_bottom = 4

	var pressed := normal.duplicate()
	pressed.bg_color = Color("#e09000")
	pressed.border_width_bottom = 2
	pressed.shadow_size = 0

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	btn.mouse_entered.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.10, 1.10), 0.12)
	)

	btn.mouse_exited.connect(func():
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2.ONE, 0.12)
	)
