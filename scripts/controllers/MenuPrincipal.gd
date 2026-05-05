extends Control

@onready var btn_jugar: Button = $ContenedorPrincipal/BtnJugar
@onready var btn_padres: Button = $ContenedorPrincipal/BtnPadres
@onready var titulo: Label = $ContenedorPrincipal/Titulo
@onready var lumi: Node2D = $Lumi

func _ready() -> void:
	UIFont.aplicar_a_control(self)
	aplicar_estilo_titulo()
	
	# 2. Aplicar estilo a los botones (Estilo burbuja/caramelo)
	aplicar_estilo_boton(btn_jugar, Color("#ffb430")) # Naranja vibrante
	aplicar_estilo_boton(btn_padres, Color("#4bc3ff")) # Azul cielo
	
	# Conexiones existentes
	btn_jugar.pressed.connect(_on_btn_jugar_presionado)
	btn_padres.pressed.connect(_on_btn_padres_presionado)
	
	# Saludo inicial
	lumi.hablar("¡Hola! Soy Lumi. \n¿A dónde vamos hoy?")

func aplicar_estilo_titulo() -> void:
	var settings = LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 90
	settings.font_color = Color("#25415e") # Azul oscuro para legibilidad
	settings.outline_size = 20
	settings.outline_color = Color.WHITE
	settings.shadow_size = 10
	settings.shadow_color = Color(0, 0, 0, 0.2)
	settings.shadow_offset = Vector2(5, 5)
	titulo.label_settings = settings

func aplicar_estilo_boton(btn: Button, color_base: Color) -> void:
	# --- ESTADO NORMAL ---
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color_base
	style_normal.corner_radius_top_left = 40
	style_normal.corner_radius_top_right = 40
	style_normal.corner_radius_bottom_left = 40
	style_normal.corner_radius_bottom_right = 40
	
	style_normal.border_width_bottom = 16 # Profundidad 3D (el "grosor" del botón)
	style_normal.border_color = color_base.darkened(0.3) # Color más oscuro abajo
	
	style_normal.shadow_color = Color(0, 0, 0, 0.2)
	style_normal.shadow_size = 10
	style_normal.shadow_offset = Vector2(0, 10)
	
	# --- ESTADO HOVER (Se hunde un poco) ---
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = color_base.lightened(0.1)
	style_hover.border_width_bottom = 10 # Se reduce el grosor
	style_hover.content_margin_top = 6 # DESPLAZAMIENTO: Empuja el botón hacia abajo
	style_hover.shadow_size = 6
	style_hover.shadow_offset = Vector2(0, 6)

	# --- ESTADO PRESSED (Se hunde totalmente) ---
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = color_base.darkened(0.1)
	style_pressed.border_width_bottom = 2 # Casi sin grosor
	style_pressed.border_width_top = 4    # Añade un borde arriba para simular profundidad
	style_pressed.content_margin_top = 14 # DESPLAZAMIENTO máximo
	style_pressed.shadow_size = 0         # Sin sombra porque toca el "suelo"
	style_pressed.shadow_offset = Vector2(0, 0)

	# Aplicar estilos
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	
	# Texto del botón con sombra para profundidad
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 44)
	btn.add_theme_constant_override("outline_size", 10)
	btn.add_theme_color_override("font_outline_color", color_base.darkened(0.4))

# --- Funciones de navegación existentes ---
func _on_btn_jugar_presionado() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")

func _on_btn_padres_presionado() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/PasarelaPadres.tscn")
