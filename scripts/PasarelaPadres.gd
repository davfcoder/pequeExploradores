extends Control

@onready var input_codigo: LineEdit = $PanelCentral/Contenedor/InputCodigo
@onready var btn_validar: Button = $PanelCentral/Contenedor/BtnValidar
@onready var btn_volver: Button = $BtnVolver

func _ready() -> void:
	btn_validar.pressed.connect(_on_btn_validar_pressed)
	btn_volver.pressed.connect(_on_btn_volver_pressed)

func _on_btn_validar_pressed() -> void:
	if input_codigo.text == "6":
		get_tree().change_scene_to_file("res://scenes/menus/PanelPadres.tscn")
	else:
		input_codigo.text = ""

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
