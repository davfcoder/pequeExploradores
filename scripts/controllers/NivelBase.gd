extends Control

@onready var lbl_titulo_mundo: Label = $HUD/LblTitulo
@onready var lbl_estrellas: Label = $HUD/LblEstrellas
@onready var lbl_instruccion: Label = $HUD/Instruccion
@onready var zona_juego: Control = $ZonaJuego
@onready var btn_volver: Button = $HUD/BtnVolver
@onready var lumi: Node2D = $Lumi

var _mundo_activo: MundoBase = null


func _ready() -> void:
	UIFont.aplicar_a_control(self)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, "Salir")
	FatigaManager.activar()
	FatigaManager.fatiga_detectada.connect(_on_fatiga_detectada)
	GameState.modo_bilingue_cambiado.connect(_on_idioma_cambiado)
	_cargar_mundo()

func _on_idioma_cambiado(_activo: bool) -> void:
	if _mundo_activo:
		_mundo_activo.queue_free()
		_mundo_activo = null
	_cargar_mundo()

func _process(delta: float) -> void:
	GameState.agregar_tiempo(GameState.mundo_actual, delta)

func _cargar_mundo() -> void:
	var mundo: MundoBase = null
	var recursos: Array[Resource] = []

	match GameState.mundo_actual:
		"colores":
			mundo = MundoColores.new()
			recursos = _cargar_recursos("res://data/colores/")
			lbl_titulo_mundo.text = "Colors" if GameState.modo_bilingue_comprado else "Valle de los Colores"
		"numeros":
			mundo = MundoNumeros.new()
			recursos = _cargar_recursos("res://data/numeros/")
			lbl_titulo_mundo.text = "Numbers" if GameState.modo_bilingue_comprado else "Isla de los Números"
		"animales":
			mundo = MundoAnimales.new()
			recursos = _cargar_recursos("res://data/animales/")
			lbl_titulo_mundo.text = "Animals" if GameState.modo_bilingue_comprado else "Mundo de los Animales"
		"formas":
			mundo = MundoFormas.new()
			recursos = _cargar_recursos("res://data/formas/")
			lbl_titulo_mundo.text = "Shapes" if GameState.modo_bilingue_comprado else "Ciudad de las Formas"

	if mundo == null:
		push_error("NivelBase: mundo no reconocido → " + GameState.mundo_actual)
		return

	zona_juego.add_child(mundo)
	mundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mundo_activo = mundo

	mundo.ronda_completada.connect(_on_ronda_completada)
	mundo.mundo_completado.connect(_on_mundo_completado)
	mundo.instruccion_cambiada.connect(_on_instruccion_cambiada)

	_actualizar_estrellas()
	mundo.iniciar(recursos, lumi)

func _cargar_recursos(carpeta: String) -> Array[Resource]:
	var resultado: Array[Resource] = []
	var dir := DirAccess.open(carpeta)
	if dir == null:
		push_error("NivelBase: carpeta no encontrada → " + carpeta)
		return resultado
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre.ends_with(".tres") and not nombre.ends_with(".import"):
			var res := load(carpeta + nombre)
			if res is ElementoEducativo:
				resultado.append(res)
		nombre = dir.get_next()
	dir.list_dir_end()
	return resultado

func _actualizar_estrellas() -> void:
	var stars: int = GameState.progreso_mundos[GameState.mundo_actual]["stars"]
	lbl_estrellas.text = "⭐ " + str(stars)

func _on_ronda_completada(correcta: bool) -> void:
	if correcta:
		_actualizar_estrellas()

func _on_instruccion_cambiada(texto: String) -> void:
	lbl_instruccion.text = texto

func _on_mundo_completado() -> void:
	lbl_instruccion.text = "¡Mundo Completado!"
	lumi.celebrar()
	lumi.hablar("¡Lo lograste! ¡Eres increíble!")
	SaveSystem.guardar()
	await get_tree().create_timer(3.0).timeout
	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")

func _on_fatiga_detectada() -> void:
	lumi.hablar("¡Muy bien! Es hora de descansar. ¡Volvemos pronto!")
	await get_tree().create_timer(3.0).timeout
	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _on_btn_volver_pressed() -> void:
	SaveSystem.guardar()
	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")
