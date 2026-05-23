extends Node2D

@onready var sprite_visual: Sprite2D       = $SpriteVisual
@onready var animador:      AnimationPlayer = $Animador
@onready var globo_texto:   Label           = $GloboTexto

var _tween_globo: Tween = null

func _ready() -> void:
	UIFont.aplicar_a_control(self)
	globo_texto.hide()
	_aplicar_estilo_globo()
	if animador.has_animation("idle"):
		animador.play("idle")
	animador.animation_finished.connect(_on_animacion_terminada)

func _aplicar_estilo_globo() -> void:
	globo_texto.custom_minimum_size = Vector2(520, 0)
	globo_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	globo_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	globo_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var empty := StyleBoxEmpty.new()
	globo_texto.add_theme_stylebox_override("normal", empty)

	var settings := LabelSettings.new()
	settings.font = UIFont.font
	settings.font_size = 40
	settings.font_color = Color("#fff4c7")
	settings.outline_size = 12
	settings.outline_color = Color("#25415e")
	settings.shadow_size = 8
	settings.shadow_color = Color(0, 0, 0, 0.35)
	settings.shadow_offset = Vector2(3, 5)

	globo_texto.label_settings = settings

func _on_animacion_terminada(anim_name: String) -> void:
	if anim_name in ["celebrar", "hablar"]:
		if animador.has_animation("idle"):
			animador.play("idle")

func reproducir_animacion(nombre: String) -> void:
	if animador.has_animation(nombre):
		animador.play(nombre)

func hablar(texto: String, audios: Array[AudioStream] = [], duracion: float = 3.5) -> void:
	if _tween_globo and _tween_globo.is_valid():
		_tween_globo.kill()
		
	globo_texto.text = texto
	globo_texto.show()
	reproducir_animacion("hablar")
	
	# Reproducimos la voz si nos enviaron audios
	if audios.size() > 0:
		AudioManager.reproducir_cola_voz(audios)
		
	_tween_globo = create_tween()
	_tween_globo.tween_interval(duracion)
	_tween_globo.tween_callback(globo_texto.hide)

func celebrar() -> void:
	reproducir_animacion("celebrar")

func callar() -> void:
	if _tween_globo and _tween_globo.is_valid():
		_tween_globo.kill()
	globo_texto.hide()
