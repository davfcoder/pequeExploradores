extends Node

signal progreso_cambiado(mundo: String)
signal modo_bilingue_cambiado(activo: bool)

const MUNDOS: Array[String] = ["colores", "numeros", "animales", "formas"]

var mundo_actual: String = "colores"
var idioma_actual: String = "es"
var modo_bilingue_comprado: bool = false
var estrellas_totales: int = 0
var tiempo_total_segundos: float = 0.0  # float, no int

var progreso_mundos: Dictionary = {
	"colores":  {"stars": 0, "errors": 0, "time": 0.0},
	"numeros":  {"stars": 0, "errors": 0, "time": 0.0},
	"animales": {"stars": 0, "errors": 0, "time": 0.0},
	"formas":   {"stars": 0, "errors": 0, "time": 0.0}
}

func get_progreso_default() -> Dictionary:
	return {
		"colores":  {"stars": 0, "errors": 0, "time": 0.0},
		"numeros":  {"stars": 0, "errors": 0, "time": 0.0},
		"animales": {"stars": 0, "errors": 0, "time": 0.0},
		"formas":   {"stars": 0, "errors": 0, "time": 0.0}
	}
	
# --- Mutadores con señales ---

func agregar_estrella(mundo: String) -> void:
	progreso_mundos[mundo]["stars"] += 1
	estrellas_totales += 1
	progreso_cambiado.emit(mundo)

func agregar_error(mundo: String) -> void:
	progreso_mundos[mundo]["errors"] += 1

func agregar_tiempo(mundo: String, delta: float) -> void:
	progreso_mundos[mundo]["time"] += delta
	tiempo_total_segundos += delta

func set_modo_bilingue(activo: bool) -> void:
	modo_bilingue_comprado = activo
	idioma_actual = "en" if activo else "es"
	modo_bilingue_cambiado.emit(activo)

func reiniciar_progreso() -> void:
	estrellas_totales = 0
	tiempo_total_segundos = 0.0
	progreso_mundos = get_progreso_default()
	progreso_cambiado.emit("")

# --- Utilidad de idioma (usada por todos los mundos) ---

func get_nombre_elemento(elemento: Resource) -> String:
	if modo_bilingue_comprado and elemento.nombre_mostrar_en != "":
		return elemento.nombre_mostrar_en
	return elemento.nombre_mostrar_es
