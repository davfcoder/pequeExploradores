extends Resource
class_name ElementoEducativo

# Usamos export para que aparezcan en el inspector de Godot
@export var nombre_id: String = "" # Ejemplo: "perro"
@export var nombre_mostrar_es: String = "" # Ejemplo: "Perro"
@export var nombre_mostrar_en: String = "" # Ejemplo: "Dog"

# Aqui arrastraremos los archivos reales desde la carpeta assets
@export var textura_visual: Texture2D
@export var audio_nombre_es: AudioStream
@export var audio_nombre_en: AudioStream

# Para el mundo de los animales, podemos añadir el sonido caracteristico
@export var audio_efecto: AudioStream 

# Metadata para logica de juego
@export_enum("colores", "numeros", "animales", "formas") var categoria: String = "colores"
@export var valor_asociado: Color = Color.WHITE # Para colores
