extends Control

@onready var lbl_titulo_mundo: Label = $HUD/LblTitulo
@onready var lbl_estrellas: Label = $HUD/LblEstrellas
@onready var lbl_instruccion: Label = $HUD/Instruccion
@onready var zona_juego: Control = $ZonaJuego
@onready var btn_volver: Button = $HUD/BtnVolver
@onready var lumi: Node2D = $Lumi
@onready var btn_repetir: Button = $HUD/BtnRepetir
@onready var fondo_textura: TextureRect = $FondoTextura

var _mundo_activo: MundoBase = null

const FONDOS_MUNDO := {
	"colores": "res://assets/images/mundos/mundoColores.png",
	"numeros": "res://assets/images/mundos/mundoNumeros.png",
	"animales": "res://assets/images/mundos/mundoAnimales.png",
	"formas": "res://assets/images/mundos/mundoFormas.png"
}

func _ready() -> void:
	AudioManager.reproducir_musica_juego()
	_estilizar_titulo_mundo()
	_estilizar_instruccion()
	UIFont.aplicar_a_control(self)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	UIFont.estilizar_boton_volver(btn_volver, Lang.t("exit"))
	FatigaManager.activar()
	FatigaManager.fatiga_detectada.connect(_on_fatiga_detectada)
	GameState.modo_bilingue_cambiado.connect(_on_idioma_cambiado)
	btn_repetir.pressed.connect(_on_btn_repetir_pressed)
	UIFont.estilizar_boton_repetir(btn_repetir)
	_cargar_mundo()
	
func _estilizar_instruccion() -> void:
	var settings := LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 42
	settings.font_color = Color("#fff4c7")
	settings.outline_size = 12
	settings.outline_color = Color("#25415e")
	settings.shadow_size = 8
	settings.shadow_color = Color(0, 0, 0, 0.35)
	settings.shadow_offset = Vector2(3, 5)

	lbl_instruccion.label_settings = settings
	lbl_instruccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_instruccion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_btn_repetir_pressed() -> void:
	if _mundo_activo:
		_mundo_activo.repetir_instruccion()

func _on_idioma_cambiado(_activo: bool) -> void:
	if _mundo_activo:
		_mundo_activo.queue_free()
		_mundo_activo = null
	_cargar_mundo()

func _process(delta: float) -> void:
	GameState.agregar_tiempo(GameState.mundo_actual, delta)

func _cargar_mundo() -> void:
	_aplicar_fondo_mundo()
	var mundo: MundoBase = null
	var recursos: Array[Resource] = []

	match GameState.mundo_actual:
		"colores":
			mundo = MundoColores.new()
			recursos = _cargar_recursos("res://data/colores/")
			lbl_titulo_mundo.text = Lang.t("world_colores")
		"numeros":
			mundo = MundoNumeros.new()
			recursos = _cargar_recursos("res://data/numeros/")
			lbl_titulo_mundo.text = Lang.t("world_numeros")
		"animales":
			mundo = MundoAnimales.new()
			recursos = _cargar_recursos("res://data/animales/")
			lbl_titulo_mundo.text = Lang.t("world_animales")
		"formas":
			mundo = MundoFormas.new()
			recursos = _cargar_recursos("res://data/formas/")
			lbl_titulo_mundo.text = Lang.t("world_formas")

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

func _aplicar_fondo_mundo() -> void:
	var ruta: String = FONDOS_MUNDO.get(GameState.mundo_actual, "")

	if ruta == "" or not ResourceLoader.exists(ruta):
		push_warning("No existe fondo para mundo: " + GameState.mundo_actual)
		return

	fondo_textura.texture = load(ruta)
	fondo_textura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo_textura.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fondo_textura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo_textura.self_modulate = Color("#7e7e7e")

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
	lbl_instruccion.text = Lang.t("completed")
	lumi.hablar(Lang.t("completed"))
	lumi.celebrar()
	SaveSystem.guardar()
	await get_tree().create_timer(3.0).timeout
	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")

func _on_fatiga_detectada() -> void:
	SaveSystem.guardar()

	if lumi:
		lumi.hablar(Lang.t("rest"))

	await get_tree().create_timer(3.0).timeout

	if not is_instance_valid(self):
		return

	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")

func _on_btn_volver_pressed() -> void:
	SaveSystem.guardar()
	FatigaManager.desactivar()
	get_tree().change_scene_to_file("res://scenes/menus/SeleccionMundos.tscn")

func _estilizar_titulo_mundo() -> void:
	var settings := LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 44
	settings.font_color = Color("#25415e")
	settings.outline_size = 12
	settings.outline_color = Color.WHITE
	settings.shadow_size = 8
	settings.shadow_color = Color(0, 0, 0, 0.25)
	settings.shadow_offset = Vector2(3, 4)

	lbl_titulo_mundo.label_settings = settings
	lbl_titulo_mundo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
