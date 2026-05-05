extends Node

const SAVE_PATH: String = "user://progreso_exploradores.json"

func _ready() -> void:
	cargar()  # Carga automática al iniciar el juego

func guardar() -> void:
	var data: Dictionary = {
		"modo_bilingue": GameState.modo_bilingue_comprado,
		"idioma":        GameState.idioma_actual,
		"estrellas":     GameState.estrellas_totales,
		"tiempo":        GameState.tiempo_total_segundos,
		"progreso":      GameState.progreso_mundos
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func cargar() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if not data is Dictionary:
		return

	GameState.modo_bilingue_comprado = bool(data.get("modo_bilingue", false))
	GameState.idioma_actual = str(data.get("idioma", "es"))
	GameState.estrellas_totales = int(data.get("estrellas", 0))
	GameState.tiempo_total_segundos = float(data.get("tiempo", 0.0))

	var progreso_cargado: Dictionary = data.get("progreso", {})
	var progreso_default: Dictionary = GameState.get_progreso_default()

	for mundo in GameState.MUNDOS:
		if progreso_cargado.has(mundo) and progreso_cargado[mundo] is Dictionary:
			for key in ["stars", "errors", "time"]:
				if progreso_cargado[mundo].has(key):
					progreso_default[mundo][key] = progreso_cargado[mundo][key]

	GameState.progreso_mundos = progreso_default

func borrar() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	GameState.reiniciar_progreso()
	GameState.modo_bilingue_comprado = false
	GameState.idioma_actual = "es"
	GameState.mundo_actual = "colores"
