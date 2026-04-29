extends Node2D

@onready var sprite_visual: Sprite2D = $SpriteVisual
@onready var animador: AnimationPlayer = $Animador

func reproducir_animacion(nombre_animacion: String) -> void:
	if animador.has_animation(nombre_animacion):
		animador.play(nombre_animacion)

func hablar(texto: String) -> void:
	# Aqui conectaremos el globo de dialogo y el audio pregrabado despues
	print("Lumi dice: " + texto)
	reproducir_animacion("hablar")

func celebrar() -> void:
	reproducir_animacion("celebrar")
