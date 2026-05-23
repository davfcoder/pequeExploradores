extends Node

const MUSICA_MENU := "res://assets/audio/music/musicaMenu.wav"
const MUSICA_JUEGO := "res://assets/audio/music/musicaJuego.wav"

var _player_voz: AudioStreamPlayer
var _player_sfx: AudioStreamPlayer
var _player_musica: AudioStreamPlayer
var _player_sfx_animal: AudioStreamPlayer

var musica_activa: bool = true
var _musica_actual: String = ""

var _cola_voz: Array[AudioStream] = []

func _ready() -> void:
	_player_voz = AudioStreamPlayer.new()
	_player_sfx = AudioStreamPlayer.new()
	_player_musica = AudioStreamPlayer.new()
	_player_sfx_animal = AudioStreamPlayer.new()
	
	_player_voz.name = "PlayerVoz"
	_player_sfx.name = "PlayerSFX"
	_player_musica.name = "PlayerMusica"
	_player_sfx_animal.name = "PlayerSFXAnimal"
	
	_player_voz.volume_db = 0.0
	_player_sfx.volume_db = -2.0
	_player_musica.volume_db = -18.0
	_player_sfx_animal.volume_db = -2.0
	
	add_child(_player_voz)
	add_child(_player_sfx)
	add_child(_player_musica)
	add_child(_player_sfx_animal)

	musica_activa = GameState.musica_activa
	
	# Conectamos la señal para reproducir el siguiente audio cuando termine uno
	_player_voz.finished.connect(_on_voz_terminada)


func obtener_stream_voz(nombre_archivo: String) -> AudioStream:
	var idioma = GameState.idioma_actual if GameState.idioma_actual else "es"
	var ruta = "res://assets/audio/" + idioma + "/voz/" + nombre_archivo + ".wav"
	
	if ResourceLoader.exists(ruta):
		return load(ruta) as AudioStream
	
	push_warning("AudioManager: No se encontró la voz en -> " + ruta)
	return null

func reproducir_cola_voz(streams: Array[AudioStream]) -> void:
	detener_voz() # Detenemos si Lumi ya estaba hablando
	
	# Filtramos por si algún stream llegó nulo
	_cola_voz = streams.filter(func(s): return s != null)
	
	if _cola_voz.size() > 0:
		var primero = _cola_voz.pop_front()
		reproducir_voz(primero)

func _on_voz_terminada() -> void:
	if _cola_voz.size() > 0:
		var siguiente = _cola_voz.pop_front()
		reproducir_voz(siguiente)

# ----------------------------------------

func reproducir_voz(stream: AudioStream) -> void:
	if stream == null: return
	_player_voz.stop()
	_player_voz.stream = stream
	_player_voz.play()

func reproducir_sfx(stream: AudioStream) -> void:
	if stream == null: return
	_player_sfx.stream = stream
	_player_sfx.play()

func reproducir_musica_menu() -> void:
	_reproducir_musica_por_ruta(MUSICA_MENU)

func reproducir_musica_juego() -> void:
	_reproducir_musica_por_ruta(MUSICA_JUEGO)

func _reproducir_musica_por_ruta(ruta: String) -> void:
	if not ResourceLoader.exists(ruta): return
	if _musica_actual == ruta and _player_musica.playing: return
	
	var stream_original: AudioStream = load(ruta)
	if stream_original == null: return
	
	var stream: AudioStream = stream_original.duplicate(true)
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		var frames := int(wav.get_length() * wav.mix_rate)
		if frames > 0:
			wav.loop_begin = 0
			wav.loop_end = frames

	_musica_actual = ruta
	_player_musica.stop()
	_player_musica.stream = stream
	if musica_activa: _player_musica.play()

func set_musica_activa(activo: bool) -> void:
	musica_activa = activo
	GameState.musica_activa = activo
	if activo:
		if _player_musica.stream: _player_musica.play()
	else:
		_player_musica.stop()

func detener_voz() -> void:
	if _player_voz:
		_player_voz.stop()
	_cola_voz.clear()

func detener_musica() -> void:
	if _player_musica:
		_player_musica.stop()

func obtener_stream_sfx(nombre_archivo: String) -> AudioStream:
	var ruta = "res://assets/audio/sfx/" + nombre_archivo + ".wav"
	if ResourceLoader.exists(ruta):
		return load(ruta) as AudioStream
	
	push_warning("AudioManager: No se encontró el SFX en -> " + ruta)
	return null

func reproducir_sfx_animal(stream: AudioStream) -> void:
	if stream == null: return
	_player_sfx_animal.stream = stream
	_player_sfx_animal.play()
