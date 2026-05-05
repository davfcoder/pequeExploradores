extends Resource
class_name ElementoEducativo

@export var nombre_id: String = ""
@export var nombre_mostrar_es: String = ""
@export var nombre_mostrar_en: String = ""

@export var textura_visual: Texture2D
@export var textura_silueta: Texture2D
@export var textura_habitat: Texture2D

@export var audio_nombre_es: AudioStream
@export var audio_nombre_en: AudioStream
@export var audio_efecto: AudioStream

@export_enum("colores","numeros","animales","formas") var categoria: String = "colores"

@export var valor_asociado: Variant = null
