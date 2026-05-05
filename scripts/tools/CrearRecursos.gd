@tool
extends EditorScript

const SCRIPT := "res://scripts/models/ElementoEducativo.gd"

func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://data/colores")
	DirAccess.make_dir_recursive_absolute("res://data/numeros")
	DirAccess.make_dir_recursive_absolute("res://data/animales")
	DirAccess.make_dir_recursive_absolute("res://data/formas")

	_colores()
	_numeros()
	_animales()
	_formas()

	EditorInterface.get_resource_filesystem().scan()
	print("✅ Todos los recursos creados.")

# ─── HELPERS ────────────────────────────────────────────────────────────────

func _nuevo() -> Resource:
	return load(SCRIPT).new()

func _guardar(elem: Resource, ruta: String) -> void:
	ResourceSaver.save(elem, ruta)

# ─── COLORES ────────────────────────────────────────────────────────────────

func _colores() -> void:
	var datos := [
		["rojo",     "Rojo",     "Red",    Color(0.95, 0.18, 0.18)],
		["azul",     "Azul",     "Blue",   Color(0.18, 0.45, 0.98)],
		["verde",    "Verde",    "Green",  Color(0.13, 0.75, 0.22)],
		["amarillo", "Amarillo", "Yellow", Color(0.98, 0.88, 0.10)],
		["naranja",  "Naranja",  "Orange", Color(0.98, 0.52, 0.10)],
		["morado",   "Morado",   "Purple", Color(0.58, 0.12, 0.82)],
		["rosa",     "Rosa",     "Pink",   Color(0.98, 0.50, 0.70)],
		["cafe",     "Café",     "Brown",  Color(0.55, 0.27, 0.07)],
	]
	for d in datos:
		var e := _nuevo()
		e.nombre_id         = d[0]
		e.nombre_mostrar_es = d[1]
		e.nombre_mostrar_en = d[2]
		e.categoria         = "colores"
		e.valor_asociado    = d[3]
		_guardar(e, "res://data/colores/" + d[0] + ".tres")
		print("  color → ", d[0])

# ─── NÚMEROS ────────────────────────────────────────────────────────────────

func _numeros() -> void:
	var datos := [
		["1", "Uno",   "One"],
		["2", "Dos",   "Two"],
		["3", "Tres",  "Three"],
		["4", "Cuatro","Four"],
		["5", "Cinco", "Five"],
		["6", "Seis",  "Six"],
		["7", "Siete", "Seven"],
		["8", "Ocho",  "Eight"],
		["9", "Nueve", "Nine"],
	]
	for d in datos:
		var e := _nuevo()
		e.nombre_id         = d[0]
		e.nombre_mostrar_es = d[1]
		e.nombre_mostrar_en = d[2]
		e.categoria         = "numeros"
		_guardar(e, "res://data/numeros/" + d[0] + ".tres")
		print("  numero → ", d[0])

# ─── ANIMALES ───────────────────────────────────────────────────────────────

func _animales() -> void:
	var datos := [
		["perro",    "Perro",    "Dog"],
		["gato",     "Gato",     "Cat"],
		["cabra",     "Cabra",     "Goat"],
		["pato",     "Pato",     "Duck"],
		["leon",     "León",     "Lion"],
		["elefante", "Elefante", "Elephant"],
		["raton",     "Ratón",     "Mouse"],
		["pajaro",   "Pájaro",   "Bird"],
		["lobo",     "Lobo",     "Wolf"],
		["serpiente",   "Serpiente",   "Snake"],
	]
	for d in datos:
		var e := _nuevo()
		e.nombre_id         = d[0]
		e.nombre_mostrar_es = d[1]
		e.nombre_mostrar_en = d[2]
		e.categoria         = "animales"
		_guardar(e, "res://data/animales/" + d[0] + ".tres")
		print("  animal → ", d[0])

# ─── FORMAS ─────────────────────────────────────────────────────────────────

func _formas() -> void:
	var datos := [
		["circulo",    "Círculo",    "Circle"],
		["cuadrado",   "Cuadrado",   "Square"],
		["triangulo",  "Triángulo",  "Triangle"],
		["rectangulo", "Rectángulo", "Rectangle"],
		["estrella",   "Estrella",   "Star"],
		["corazon",    "Corazón",    "Heart"],
	]
	for d in datos:
		var e := _nuevo()
		e.nombre_id         = d[0]
		e.nombre_mostrar_es = d[1]
		e.nombre_mostrar_en = d[2]
		e.categoria         = "formas"
		_guardar(e, "res://data/formas/" + d[0] + ".tres")
		print("  forma → ", d[0])
