extends Node
## Música y sonido (Fase 16.1). Contrato: docs/contratos.md §9.2.
## Los ids se convierten en archivos por convención (BGM_DIR + id + .ogg...):
## si falta el archivo, avisa una vez y no suena nada.

const BUSES: Array[StringName] = [&"BGM", &"SE", &"ME", &"Cries", &"Ambient"]
const BGM_DIR := "res://assets/audio/bgm/"
const SE_DIR := "res://assets/audio/se/"
const ME_DIR := "res://assets/audio/me/"
const CRIES_DIR := "res://assets/audio/cries/"
const AMBIENT_DIR := "res://assets/audio/ambient/"
const EXTENSIONS: Array[String] = ["ogg", "wav", "mp3"]
const SE_VOICES := 6
const SE_ALIASES := {&"cursor": &"menu_move", &"cancel": &"menu_cancel", &"bump": &"menu_error"}
## Margen al esperar un ME o un grito, por si el archivo tiene bucle.
const WAIT_MARGIN := 0.05

var current_bgm: StringName = &""
var current_ambient: StringName = &""

var _bgm: Array[AudioStreamPlayer] = []
var _bgm_index := 0
var _bgm_tweens: Array[Tween] = [null, null]
var _ambient: AudioStreamPlayer
var _ambient_tween: Tween
var _me: AudioStreamPlayer
var _cry: AudioStreamPlayer
var _se: Array[AudioStreamPlayer] = []
var _se_next := 0
var _me_serial := 0
var _bgm_stack: Array[Dictionary] = []
## Ruta base + id → stream (null si no existe), para no buscar cada vez.
var _cache: Dictionary[String, AudioStream] = {}
## Audios pedidos que no existen (se avisa solo del primero).
var _missing: PackedStringArray = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	for i: int in 2:
		_bgm.append(_new_player(&"BGM"))
	_ambient = _new_player(&"Ambient")
	_me = _new_player(&"ME")
	_cry = _new_player(&"Cries")
	for i: int in SE_VOICES:
		_se.append(_new_player(&"SE"))
	_register_debug_commands()


# --- Música ---

## Cambia la BGM con un fundido cruzado. Si `id` ya suena, no la reinicia.
func play_bgm(id: StringName, fade_time: float = 0.5) -> void:
	if id == &"":
		stop_bgm(fade_time)
		return
	if id == current_bgm:
		return
	current_bgm = id
	_crossfade(_find(BGM_DIR, id), fade_time, 0.0)


func stop_bgm(fade_time: float = 0.5) -> void:
	current_bgm = &""
	_crossfade(null, fade_time, 0.0)


## Recuerda la BGM actual y por dónde va (antes de un combate, por ejemplo).
func save_bgm() -> void:
	var player := _bgm[_bgm_index]
	_bgm_stack.append({"id": current_bgm, "position": player.get_playback_position() if player.playing else 0.0})


## Pila para restaurar también tras una evolución dentro del combate.
func restore_bgm(fade_time: float = 0.5) -> void:
	if _bgm_stack.is_empty(): return
	var saved: Dictionary = _bgm_stack.pop_back()
	if saved.id == &"":
		stop_bgm(fade_time)
		return
	current_bgm = saved.id
	_crossfade(_find(BGM_DIR, saved.id), fade_time, float(saved.position))


# --- Efectos ---

func play_se(id: StringName) -> void:
	var stream := _find(SE_DIR, SE_ALIASES.get(id, id))
	if stream == null:
		return
	var player := _se[_se_next]
	_se_next = (_se_next + 1) % _se.size()
	player.stream = stream
	player.play()


## Jingle: pausa la BGM, suena y la reanuda donde estaba. Se puede esperar con await.
func play_me(id: StringName) -> void:
	var stream := _find(ME_DIR, id)
	if stream == null:
		return
	_me_serial += 1
	var serial := _me_serial
	_set_bgm_paused(true)
	_me.stream = stream
	_me.play()
	await _wait_for(_me, stream)
	if serial == _me_serial:
		_set_bgm_paused(false)


## Grito de la especie. Se puede esperar con await.
func play_cry(species_id: StringName) -> void:
	var stream := _find(CRIES_DIR, species_id)
	if stream == null:
		return
	_cry.stream = stream
	_cry.play()
	await _wait_for(_cry, stream)


func play_ambient(id: StringName, fade_time: float = 1.0) -> void:
	if id == current_ambient:
		return
	current_ambient = id
	var stream := _find(AMBIENT_DIR, id) if id != &"" else null
	if _ambient_tween:
		_ambient_tween.kill()
	_ambient_tween = create_tween()
	if _ambient.playing:
		_ambient_tween.tween_method(_set_linear.bind(_ambient), _get_linear(_ambient), 0.0, fade_time)
		_ambient_tween.tween_callback(_ambient.stop)
	if stream:
		_ambient_tween.tween_callback(_start.bind(_ambient, stream, 0.0))
		_ambient_tween.tween_method(_set_linear.bind(_ambient), 0.0, 1.0, fade_time)


func stop_ambient(fade_time: float = 1.0) -> void:
	play_ambient(&"", fade_time)


# --- Volumen ---

## `linear` entre 0.0 (silencio) y 1.0 (volumen normal).
func set_volume(bus: StringName, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index == -1:
		push_error("AudioManager.set_volume: no existe el bus '%s'." % bus)
		return
	linear = clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(index, linear <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))


func get_volume(bus: StringName) -> float:
	var index := AudioServer.get_bus_index(bus)
	if index == -1 or AudioServer.is_bus_mute(index):
		return 0.0
	return snappedf(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.001)


# --- Internos ---

func _crossfade(stream: AudioStream, fade_time: float, from_position: float) -> void:
	var old_index := _bgm_index
	_bgm_index = 1 - _bgm_index
	_fade_player(old_index, 0.0, fade_time, true)
	if stream == null:
		return
	var player := _bgm[_bgm_index]
	_start(player, stream, from_position)
	_set_linear(0.0 if fade_time > 0.0 else 1.0, player)
	_fade_player(_bgm_index, 1.0, fade_time, false)


func _fade_player(index: int, target: float, fade_time: float, stop_at_end: bool) -> void:
	var player := _bgm[index]
	if _bgm_tweens[index]:
		_bgm_tweens[index].kill()
		_bgm_tweens[index] = null
	if not player.playing and not player.stream_paused:
		return
	if fade_time <= 0.0:
		_set_linear(target, player)
		if stop_at_end:
			player.stop()
		return
	var tween := create_tween()
	tween.tween_method(_set_linear.bind(player), _get_linear(player), target, fade_time)
	if stop_at_end:
		tween.tween_callback(player.stop)
	_bgm_tweens[index] = tween


func _set_bgm_paused(paused: bool) -> void:
	_bgm[_bgm_index].stream_paused = paused


func _start(player: AudioStreamPlayer, stream: AudioStream, from_position: float) -> void:
	player.stream = stream
	player.stream_paused = false
	player.play(from_position)


func _wait_for(player: AudioStreamPlayer, stream: AudioStream) -> void:
	var timer := get_tree().create_timer(stream.get_length() + WAIT_MARGIN, true, false, true)
	while player.playing and player.stream == stream and timer.time_left > 0.0:
		await get_tree().process_frame
	if player.stream == stream:
		player.stop()


func _set_linear(linear: float, player: AudioStreamPlayer) -> void:
	player.volume_db = linear_to_db(maxf(linear, 0.0001))


func _get_linear(player: AudioStreamPlayer) -> float:
	return db_to_linear(player.volume_db)


## Stream del id en `dir` (con cualquiera de las EXTENSIONS) o null.
func _find(dir: String, id: StringName) -> AudioStream:
	var key := dir + String(id)
	if _cache.has(key):
		return _cache[key]
	var stream: AudioStream = null
	for extension: String in EXTENSIONS:
		var path := "%s.%s" % [key, extension]
		if ResourceLoader.exists(path):
			stream = load(path) as AudioStream
			if stream is AudioStreamOggVorbis: stream.loop = dir == BGM_DIR or dir == AMBIENT_DIR
			if stream is AudioStreamWAV: stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if dir == BGM_DIR or dir == AMBIENT_DIR else AudioStreamWAV.LOOP_DISABLED
			break
	if stream == null:
		_missing.append(key)
		if _missing.size() == 1:
			push_warning("AudioManager: faltan archivos de audio (el primero, %s.ogg). " % key
				+ "Lista completa: comando de Debug `audio`.")
	_cache[key] = stream
	return stream


func _new_player(bus: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	return player


## Los buses vienen de res://default_bus_layout.tres; si falta alguno, se crea.
func _ensure_buses() -> void:
	for bus: StringName in BUSES:
		if AudioServer.get_bus_index(bus) != -1:
			continue
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus)
		AudioServer.set_bus_send(index, &"Master")


func _register_debug_commands() -> void:
	Debug.register_command("bgm", _cmd_bgm, "bgm [id]: pone la BGM (sin id, la para)")
	Debug.register_command("se", _cmd_se, "se <id>: suena un efecto")
	Debug.register_command("me", _cmd_me, "me <id>: suena un jingle (pausa la BGM)")
	Debug.register_command("volume", _cmd_volume,
		"volume <bus> <0-100>: volumen de Master, BGM, SE, ME, Cries o Ambient")
	Debug.register_command("audio", _cmd_audio, "audio: audios pedidos que faltan")


func _cmd_audio(_args: PackedStringArray) -> String:
	if _missing.is_empty():
		return "No falta ningún audio de los pedidos."
	return "Faltan %d audios:\n%s" % [_missing.size(), "\n".join(_missing)]


func _cmd_bgm(args: PackedStringArray) -> String:
	play_bgm(StringName(args[0]) if not args.is_empty() else &"")
	return "BGM: %s" % current_bgm


func _cmd_se(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: se <id>"
	play_se(StringName(args[0]))
	return ""


func _cmd_me(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: me <id>"
	play_me(StringName(args[0]))
	return ""


func _cmd_volume(args: PackedStringArray) -> String:
	if args.size() < 2:
		return "Uso: volume <bus> <0-100>"
	set_volume(StringName(args[0]), args[1].to_float() / 100.0)
	return "%s: %d %%" % [args[0], roundi(get_volume(StringName(args[0])) * 100.0)]
