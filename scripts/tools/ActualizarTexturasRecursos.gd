@tool
extends EditorScript

func _run() -> void:
	_actualizar_animales()
	_actualizar_numeros()
	_actualizar_formas()
	EditorInterface.get_resource_filesystem().scan()
	print("✅ Texturas actualizadas correctamente.")

func _actualizar_animales() -> void:
	var animales := [
		"cabra",
		"elefante",
		"gato",
		"leon",
		"lobo",
		"pajaro",
		"pato",
		"perro",
		"raton",
		"serpiente"
	]

	var siluetas := {
		"cabra": "siluetaCabra",
		"elefante": "siluetaElefante",
		"gato": "siluetaGato",
		"leon": "siluetaLeon",
		"lobo": "siluetaLobo",
		"pajaro": "siluetaPajaro",
		"pato": "siluetaPato",
		"perro": "siluetaPerro",
		"raton": "siluetaRaton",
		"serpiente": "siluetaSerpiente"
	}

	for id in animales:
		var ruta_recurso := "res://data/animales/%s.tres" % id
		var recurso := load(ruta_recurso)

		if recurso == null:
			push_warning("No existe recurso: " + ruta_recurso)
			continue

		recurso.textura_visual = load("res://assets/images/animales/%s.png" % id)
		recurso.textura_silueta = load("res://assets/images/animales/siluetas/%s.png" % siluetas[id])

		ResourceSaver.save(recurso, ruta_recurso)
		print("Animal actualizado: ", id)

func _actualizar_numeros() -> void:
	for i in range(1, 10):
		var id := str(i)
		var ruta_recurso := "res://data/numeros/%s.tres" % id
		var recurso := load(ruta_recurso)

		if recurso == null:
			push_warning("No existe recurso: " + ruta_recurso)
			continue

		recurso.textura_visual = load("res://assets/images/numeros/%s.png" % id)

		ResourceSaver.save(recurso, ruta_recurso)
		print("Número actualizado: ", id)

func _actualizar_formas() -> void:
	var formas := [
		"circulo",
		"corazon",
		"cuadrado",
		"estrella",
		"rectangulo",
		"triangulo"
	]

	for id in formas:
		var ruta_recurso := "res://data/formas/%s.tres" % id
		var recurso := load(ruta_recurso)

		if recurso == null:
			push_warning("No existe recurso: " + ruta_recurso)
			continue

		recurso.textura_visual = load("res://assets/images/formas/%s.png" % id)

		ResourceSaver.save(recurso, ruta_recurso)
		print("Forma actualizada: ", id)
