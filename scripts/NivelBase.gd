extends Control

@onready var lbl_titulo_mundo: Label = $HUD/LblTituloMundo
@onready var lbl_estrellas: Label = $HUD/LblEstrellas
@onready var instruccion_text: Label = $InstruccionText
@onready var zona_juego: HBoxContainer = $ZonaJuego
@onready var btn_volver: Button = $HUD/BtnVolver
@onready var lumi: Node2D = $Lumi

# Aqui arrastraremos los archivos .tres desde el Inspector
@export var recursos_colores: Array[Resource]

var objetivo_actual: Resource

func _ready() -> void:
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	lbl_estrellas.text = "⭐ " + str(GameManager.progreso_mundos[GameManager.mundo_actual]["stars"])
	
	if GameManager.mundo_actual == "colores":
		lbl_titulo_mundo.text = "Valle de los Colores"
		iniciar_ronda_colores()
	else:
		lbl_titulo_mundo.text = "Mundo en construccion"

func iniciar_ronda_colores() -> void:
	# Limpiar la zona de juego
	for hijo in zona_juego.get_children():
		hijo.queue_free()
		
	if recursos_colores.size() < 2:
		instruccion_text.text = "Faltan recursos .tres en el Inspector!"
		return

	# Elegir 3 colores al azar
	var opciones = recursos_colores.duplicate()
	opciones.shuffle()
	opciones = opciones.slice(0, 3) # Tomar solo 3
	
	# Elegir el objetivo de esa ronda
	objetivo_actual = opciones.pick_random()
	
	# Actualizar instruccion segun idioma
	var nombre_color = objetivo_actual.nombre_mostrar_es
	if GameManager.modo_bilingue_comprado:
		nombre_color = objetivo_actual.nombre_mostrar_en
		
	instruccion_text.text = "Toca el color " + nombre_color
	lumi.hablar("Busca el color " + nombre_color)
	
	# Generar los botones visuales
	for recurso in opciones:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 250)
		# Usamos la textura si existe, si no, creamos un color solido temporal
		if recurso.textura_visual != null:
			btn.icon = recurso.textura_visual
			btn.expand_icon = true
		else:
			btn.text = "Textura faltante"
			var style = StyleBoxFlat.new()
			style.bg_color = recurso.valor_asociado
			style.corner_radius_top_left = 30
			style.corner_radius_top_right = 30
			style.corner_radius_bottom_left = 30
			style.corner_radius_bottom_right = 30
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
			btn.add_theme_stylebox_override("pressed", style)
		
		# Conectar el clic del boton
		btn.pressed.connect(func(): verificar_respuesta(recurso))
		zona_juego.add_child(btn)
		
	GameManager.reiniciar_fatiga()

func verificar_respuesta(recurso_seleccionado: Resource) -> void:
	if recurso_seleccionado == objetivo_actual:
		# Acierto
		lumi.celebrar()
		GameManager.progreso_mundos[GameManager.mundo_actual]["stars"] += 1
		GameManager.estrellas_totales += 1
		lbl_estrellas.text = "⭐ " + str(GameManager.progreso_mundos[GameManager.mundo_actual]["stars"])
		GameManager.guardar_datos()
		
		# Siguiente ronda despues de 1.5 segundos
		await get_tree().create_timer(1.5).timeout
		iniciar_ronda_colores()
	else:
		# Error
		lumi.hablar("Ese no es, intenta de nuevo")
		GameManager.progreso_mundos[GameManager.mundo_actual]["errors"] += 1
		GameManager.guardar_datos()

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")
