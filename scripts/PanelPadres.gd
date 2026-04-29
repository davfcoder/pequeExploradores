extends Control

@onready var lbl_estrellas: Label = $ContenedorPrincipal/LblEstrellas
@onready var lbl_tiempo: Label = $ContenedorPrincipal/LblTiempo
@onready var btn_bilingue: CheckButton = $ContenedorPrincipal/BtnBilingue
@onready var btn_volver: Button = $BtnVolver

func _ready() -> void:
	btn_bilingue.toggled.connect(_on_btn_bilingue_toggled)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	
	# Cargar datos desde el Singleton
	lbl_estrellas.text = "Estrellas Totales: " + str(GameManager.estrellas_totales)
	lbl_tiempo.text = "Tiempo Jugado: " + str(GameManager.tiempo_total_segundos) + " segundos"
	btn_bilingue.button_pressed = GameManager.modo_bilingue_comprado

func _on_btn_bilingue_toggled(toggled_on: bool) -> void:
	GameManager.modo_bilingue_comprado = toggled_on
	GameManager.guardar_datos()

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
