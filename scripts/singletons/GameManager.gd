extends Node

const SAVE_PATH = "user://progreso_exploradores.json"

var idioma_actual: String = "es"
var modo_bilingue_comprado: bool = false
var estrellas_totales: int = 0
var tiempo_total_segundos: int = 0
var mundo_actual: String = "colores"
var progreso_mundos: Dictionary = {
	"colores": {"stars": 0, "errors": 0, "time": 0},
	"numeros": {"stars": 0, "errors": 0, "time": 0},
	"animales": {"stars": 0, "errors": 0, "time": 0},
	"formas": {"stars": 0, "errors": 0, "time": 0}
}

var temporizador_fatiga: Timer

func _ready():
	cargar_datos()
	configurar_fatiga()

func configurar_fatiga():
	temporizador_fatiga = Timer.new()
	temporizador_fatiga.wait_time = 120.0 # 2 minutos (RF-05)
	temporizador_fatiga.one_shot = true
	temporizador_fatiga.timeout.connect(_on_fatiga_timeout)
	add_child(temporizador_fatiga)

func reiniciar_fatiga():
	temporizador_fatiga.start()

func _on_fatiga_timeout():
	guardar_datos()
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func guardar_datos():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"modo_bilingue": modo_bilingue_comprado,
		"estrellas": estrellas_totales,
		"tiempo": tiempo_total_segundos,
		"progreso": progreso_mundos,
		"idioma": idioma_actual
	}
	file.store_string(JSON.stringify(data))

func cargar_datos():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			modo_bilingue_comprado = data.get("modo_bilingue", false)
			estrellas_totales = data.get("estrellas", 0)
			tiempo_total_segundos = data.get("tiempo", 0)
			progreso_mundos = data.get("progreso", progreso_mundos)
			idioma_actual = data.get("idioma", "es")
