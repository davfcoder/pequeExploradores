extends Node

const MUSICA_MENU := "res://assets/audio/music/musicaMenu.wav"
const MUSICA_JUEGO := "res://assets/audio/music/musicaJuego.wav"

var _player_voz: AudioStreamPlayer
var _player_sfx: AudioStreamPlayer
var _player_musica: AudioStreamPlayer

var musica_activa: bool = true
var _musica_actual: String = ""


func _ready() -> void:
	_player_voz = AudioStreamPlayer.new()
	_player_sfx = AudioStreamPlayer.new()
	_player_musica = AudioStreamPlayer.new()

	_player_voz.name = "PlayerVoz"
	_player_sfx.name = "PlayerSFX"
	_player_musica.name = "PlayerMusica"

	_player_voz.volume_db = 0.0
	_player_sfx.volume_db = -2.0
	_player_musica.volume_db = -8.0

	add_child(_player_voz)
	add_child(_player_sfx)
	add_child(_player_musica)

	musica_activa = GameState.musica_activa


func reproducir_voz(stream: AudioStream) -> void:
	if stream == null:
		return

	_player_voz.stop()
	_player_voz.stream = stream
	_player_voz.play()


func reproducir_sfx(stream: AudioStream) -> void:
	if stream == null:
		return

	_player_sfx.stream = stream
	_player_sfx.play()


func reproducir_musica_menu() -> void:
	_reproducir_musica_por_ruta(MUSICA_MENU)


func reproducir_musica_juego() -> void:
	_reproducir_musica_por_ruta(MUSICA_JUEGO)


func _reproducir_musica_por_ruta(ruta: String) -> void:
	if not ResourceLoader.exists(ruta):
		push_warning("AudioManager: No existe música: " + ruta)
		return

	if _musica_actual == ruta and _player_musica.playing:
		return

	var stream_original: AudioStream = load(ruta)

	if stream_original == null:
		push_warning("AudioManager: No se pudo cargar música: " + ruta)
		return

	var stream: AudioStream = stream_original.duplicate(true)

	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

		# En WAV, loop_end va en frames. Esta línea evita loops vacíos.
		var frames := int(wav.get_length() * wav.mix_rate)
		if frames > 0:
			wav.loop_begin = 0
			wav.loop_end = frames

	_musica_actual = ruta

	_player_musica.stop()
	_player_musica.stream = stream

	if musica_activa:
		_player_musica.play()
	else:
		_player_musica.stop()


func set_musica_activa(activo: bool) -> void:
	musica_activa = activo
	GameState.musica_activa = activo

	if activo:
		if _player_musica.stream:
			_player_musica.play()
	else:
		_player_musica.stop()


func detener_voz() -> void:
	if _player_voz:
		_player_voz.stop()


func detener_musica() -> void:
	if _player_musica:
		_player_musica.stop()
