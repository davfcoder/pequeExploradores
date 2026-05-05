extends Node

var _player_voz: AudioStreamPlayer
var _player_sfx: AudioStreamPlayer
var _player_musica: AudioStreamPlayer

var musica_activa: bool = true

func _ready() -> void:
	_player_voz   = AudioStreamPlayer.new()
	_player_sfx   = AudioStreamPlayer.new()
	_player_musica = AudioStreamPlayer.new()
	_player_musica.volume_db = -6.0
	add_child(_player_voz)
	add_child(_player_sfx)
	add_child(_player_musica)

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

func reproducir_musica(stream: AudioStream) -> void:
	if stream == null:
		return
	if _player_musica.stream == stream and _player_musica.playing:
		return  # Ya está sonando, no reiniciar
	_player_musica.stream = stream
	if musica_activa:
		_player_musica.play()

func set_musica_activa(activo: bool) -> void:
	musica_activa = activo
	if activo and _player_musica.stream:
		_player_musica.play()
	else:
		_player_musica.stop()

func detener_voz() -> void:
	_player_voz.stop()
