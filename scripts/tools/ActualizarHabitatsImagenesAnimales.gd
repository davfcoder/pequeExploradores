@tool
extends EditorScript

func _run() -> void:
	var habitats := {
		"perro": "habitatPerro",
		"cabra": "habitatCabra",
		"gato": "habitatGato",
		"leon": "habitatLeon",
		"lobo": "habitatLobo",
		"serpiente": "habitatSerpiente",
		"raton": "habitatRaton",
		"elefante": "habitatElefante",
		"pato": "habitatPato",
		"pajaro": "habitatPajaro"
	}

	for id in habitats.keys():
		var ruta_recurso := "res://data/animales/%s.tres" % id
		var recurso := load(ruta_recurso)

		if recurso == null:
			push_warning("No existe recurso: " + ruta_recurso)
			continue

		var ruta_habitat := "res://assets/images/animales/habitats/%s.png" % habitats[id]

		if not ResourceLoader.exists(ruta_habitat):
			push_warning("No existe habitat: " + ruta_habitat)
			continue

		recurso.textura_habitat = load(ruta_habitat)

		ResourceSaver.save(recurso, ruta_recurso)
		print("Hábitat asignado: ", id, " -> ", ruta_habitat)

	EditorInterface.get_resource_filesystem().scan()
	print("✅ Hábitats por imagen actualizados.")
