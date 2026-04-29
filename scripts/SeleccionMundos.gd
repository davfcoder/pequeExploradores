extends Control

@onready var btn_colores: Button = $Cuadricula/BtnColores
@onready var btn_numeros: Button = $Cuadricula/BtnNumeros
@onready var btn_animales: Button = $Cuadricula/BtnAnimales
@onready var btn_formas: Button = $Cuadricula/BtnFormas
@onready var btn_volver: Button = $BtnVolver
@onready var lumi: Node2D = $Lumi

func _ready() -> void:
	btn_colores.pressed.connect(func(): entrar_mundo("colores"))
	btn_numeros.pressed.connect(func(): entrar_mundo("numeros"))
	btn_animales.pressed.connect(func(): entrar_mundo("animales"))
	btn_formas.pressed.connect(func(): entrar_mundo("formas"))
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	
	lumi.hablar("Adonde vamos a jugar hoy?")

func entrar_mundo(nombre_mundo: String) -> void:
	GameManager.mundo_actual = nombre_mundo
	GameManager.reiniciar_fatiga()
	print("Entrando al mundo: " + nombre_mundo)
	get_tree().change_scene_to_file("res://scenes/levels/NivelBase.tscn")

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
