extends Control

@onready var instruccion:   Label    = $PanelCentral/Contenedor/Instruccion
@onready var input_codigo:  LineEdit = $PanelCentral/Contenedor/InputCodigo
@onready var btn_validar:   Button   = $PanelCentral/Contenedor/BtnValidar
@onready var btn_volver:    Button   = $BtnVolver

const PREGUNTAS := [
	{"expresion": "4 + 3",  "respuesta": "7"},
	{"expresion": "5 x 2",  "respuesta": "10"},
	{"expresion": "18 - 9", "respuesta": "9"},
	{"expresion": "6 + 7",  "respuesta": "13"},
	{"expresion": "4 x 4",  "respuesta": "16"},
]

var _respuesta_correcta: String = ""

func _ready() -> void:
	AudioManager.reproducir_musica_menu()
	UIFont.aplicar_a_control(self)
	btn_validar.pressed.connect(_on_btn_validar_pressed)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, Lang.t("back"))
	UIFont.estilizar_boton_volver(btn_validar, Lang.t("continue"))
	_nueva_pregunta()

func _nueva_pregunta() -> void:
	var pregunta: Dictionary = PREGUNTAS.pick_random()
	_respuesta_correcta = pregunta["respuesta"]

	instruccion.text = Lang.t("parent_gate", {
		"question": pregunta["expresion"]
	})
	instruccion.add_theme_color_override("font_color", Color("#25415e"))
	input_codigo.text = ""

func _on_btn_validar_pressed() -> void:
	if input_codigo.text.strip_edges() == _respuesta_correcta:
		get_tree().change_scene_to_file("res://scenes/menus/PanelPadres.tscn")
	else:
		btn_validar.disabled = true
		input_codigo.text = ""
		instruccion.add_theme_color_override("font_color", Color("#cc0000"))
		instruccion.text = Lang.t("incorrect_try_again")

		await get_tree().create_timer(0.9).timeout

		if not is_instance_valid(self):
			return

		btn_validar.disabled = false
		_nueva_pregunta()

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
