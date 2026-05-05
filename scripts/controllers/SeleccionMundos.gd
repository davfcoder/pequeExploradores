extends Control

@onready var btn_colores:  Button  = $Cuadricula/BtnColores
@onready var btn_numeros:  Button  = $Cuadricula/BtnNumeros
@onready var btn_animales: Button  = $Cuadricula/BtnAnimales
@onready var btn_formas:   Button  = $Cuadricula/BtnFormas
@onready var btn_volver:   Button  = $BtnVolver
@onready var lumi:         Node2D  = $Lumi
var _portal_tweens: Dictionary = {}

func _ready() -> void:
	UIFont.aplicar_a_control(self)
	FatigaManager.desactivar()
	_aplicar_portales()
	btn_colores.pressed.connect(func():  _entrar_mundo("colores"))
	btn_numeros.pressed.connect(func():  _entrar_mundo("numeros"))
	btn_animales.pressed.connect(func(): _entrar_mundo("animales"))
	btn_formas.pressed.connect(func():   _entrar_mundo("formas"))
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, "Salir")
	lumi.hablar("¿A qué mundo vamos a jugar hoy?")
	GameState.modo_bilingue_cambiado.connect(_on_idioma_cambiado)

func _on_idioma_cambiado(activo: bool) -> void:
	if activo:
		btn_colores.text  = "🎨 Colors"
		btn_numeros.text  = "🔢 Numbers"
		btn_animales.text = "🐾 Animals"
		btn_formas.text   = "🔷 Shapes"
	else:
		btn_colores.text  = "🎨 Colores"
		btn_numeros.text  = "🔢 Números"
		btn_animales.text = "🐾 Animales"
		btn_formas.text   = "🔷 Formas"

func _entrar_mundo(nombre: String) -> void:
	GameState.mundo_actual = nombre
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

		# Onda luminosa 1.
		var glow_1 := TextureRect.new()
		glow_1.name = "Glow1"
		glow_1.texture = tex
		glow_1.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		glow_1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glow_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow_1.modulate = Color(1, 0.95, 0.25, 0.0)
		glow_1.visible = false
		glow_1.pivot_offset = btn.custom_minimum_size / 2.0
		btn.add_child(glow_1)
		glow_1.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		# Onda luminosa 2.
		var glow_2 := TextureRect.new()
		glow_2.name = "Glow2"
		glow_2.texture = tex
		glow_2.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		glow_2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glow_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow_2.modulate = Color(0.25, 0.85, 1.0, 0.0)
		glow_2.visible = false
		glow_2.pivot_offset = btn.custom_minimum_size / 2.0
		btn.add_child(glow_2)
		glow_2.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		# Sombra fija.
		var sombra := TextureRect.new()
		sombra.texture = tex
		sombra.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		sombra.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sombra.modulate = Color(0, 0, 0, 0.35)
		btn.add_child(sombra)
		sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sombra.offset_left = 8
		sombra.offset_top = 10
		sombra.offset_right = 8
		sombra.offset_bottom = 10

		# Portal real.
		var img := TextureRect.new()
		img.name = "PortalImg"
		img.texture = tex
		img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
