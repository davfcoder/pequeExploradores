extends Control

@onready var btn_jugar: Button = $ContenedorPrincipal/BtnJugar
@onready var btn_padres: Button = $ContenedorPrincipal/BtnPadres
@onready var lumi: Node2D = $Lumi

func _ready() -> void:
	# Conectamos las señales
	btn_jugar.pressed.connect(_on_btn_jugar_presionado)
	btn_padres.pressed.connect(_on_btn_padres_presionado)
	
	# Saludo inicial
	lumi.hablar("Hola, soy Lumi. Vamos a aprender jugando")

func _on_btn_jugar_presionado() -> void:
	print("Cambiando a seleccion de mundos")
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")

func _on_btn_padres_presionado() -> void:
	print("Abriendo pasarela de padres")
	get_tree().change_scene_to_file("res://scenes/menus/PasarelaPadres.tscn")
