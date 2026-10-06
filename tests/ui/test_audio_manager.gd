extends GutTest
## Tests del autoload AudioManager (contratos.md §9.2). Los streams de prueba se
## generan en memoria y se meten en la caché, para no depender de archivos.

const MIX_RATE := 8000


func before_each() -> void:
	AudioManager.stop_bgm(0.0)
	AudioManager.stop_ambient(0.0)


func after_all() -> void:
	AudioManager.stop_bgm(0.0)
	for key: String in AudioManager._cache.keys():
		if key.contains("test_"):
			AudioManager._cache.erase(key)
	for bus: StringName in AudioManager.BUSES:
		AudioManager.set_volume(bus, 1.0)


func _tone(seconds: float, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = MIX_RATE
	var data := PackedByteArray()
	data.resize(int(seconds * MIX_RATE))
	for i: int in data.size():
		data[i] = 64 if (i / 20) % 2 == 0 else 192
	stream.data = data
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = data.size()
	return stream


func _fake(dir: String, id: String, stream: AudioStream) -> void:
	AudioManager._cache[dir + id] = stream


func test_buses_exist() -> void:
	for bus: StringName in AudioManager.BUSES:
		assert_ne(AudioServer.get_bus_index(bus), -1, "existe el bus %s" % bus)


func test_volume_round_trip_and_mute_at_zero() -> void:
	AudioManager.set_volume(&"BGM", 0.5)
	assert_almost_eq(AudioManager.get_volume(&"BGM"), 0.5, 0.01)
	AudioManager.set_volume(&"BGM", 0.0)
	assert_eq(AudioManager.get_volume(&"BGM"), 0.0)
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"BGM")))
	AudioManager.set_volume(&"BGM", 1.0)
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"BGM")))


func test_missing_bgm_does_not_break() -> void:
	AudioManager.play_bgm(&"pista_que_no_existe", 0.0)
	assert_eq(AudioManager.current_bgm, &"pista_que_no_existe")
	AudioManager.stop_bgm(0.0)
	assert_eq(AudioManager.current_bgm, &"")


func test_play_bgm_crossfades_and_same_id_does_not_restart() -> void:
	_fake(AudioManager.BGM_DIR, "test_a", _tone(1.0, true))
	_fake(AudioManager.BGM_DIR, "test_b", _tone(1.0, true))
	AudioManager.play_bgm(&"test_a", 0.0)
	var first: AudioStreamPlayer = AudioManager._bgm[AudioManager._bgm_index]
	assert_true(first.playing, "suena test_a")
	AudioManager.play_bgm(&"test_a", 0.0)
	assert_eq(AudioManager._bgm[AudioManager._bgm_index], first, "la misma pista no se reinicia")
	AudioManager.play_bgm(&"test_b", 0.1)
	var second: AudioStreamPlayer = AudioManager._bgm[AudioManager._bgm_index]
	assert_ne(second, first, "la nueva pista va en el otro reproductor")
	assert_true(second.playing)
	await wait_seconds(0.25)
	assert_false(first.playing, "la pista anterior se apaga al acabar el fundido")
	assert_almost_eq(db_to_linear(second.volume_db), 1.0, 0.01, "la nueva llega a volumen normal")


func test_play_me_pauses_and_resumes_bgm() -> void:
	_fake(AudioManager.BGM_DIR, "test_a", _tone(1.0, true))
	_fake(AudioManager.ME_DIR, "test_jingle", _tone(0.15, false))
	AudioManager.play_bgm(&"test_a", 0.0)
	var bgm: AudioStreamPlayer = AudioManager._bgm[AudioManager._bgm_index]
	var state := {"done": false}
	var jingle := func() -> void:
		await AudioManager.play_me(&"test_jingle")
		state["done"] = true
	jingle.call()
	assert_true(bgm.stream_paused, "la BGM se pausa durante el ME")
	await wait_seconds(0.4)
	assert_true(state["done"], "play_me se puede esperar")
	assert_false(bgm.stream_paused, "la BGM se reanuda")


func test_save_and_restore_bgm() -> void:
	_fake(AudioManager.BGM_DIR, "test_a", _tone(1.0, true))
	_fake(AudioManager.BGM_DIR, "test_b", _tone(1.0, true))
	AudioManager.play_bgm(&"test_a", 0.0)
	AudioManager.save_bgm()
	AudioManager.play_bgm(&"test_b", 0.0)
	AudioManager.restore_bgm(0.0)
	assert_eq(AudioManager.current_bgm, &"test_a")
	assert_true(AudioManager._bgm[AudioManager._bgm_index].playing)

func test_nested_bgm_restores_victory_then_map_after_evolution() -> void:
	AudioManager.play_bgm(&"test_map", 0.0)
	AudioManager.save_bgm()
	AudioManager.play_bgm(&"test_victory", 0.0)
	AudioManager.save_bgm()
	AudioManager.play_bgm(&"evolution", 0.0)
	AudioManager.restore_bgm(0.0)
	assert_eq(AudioManager.current_bgm, &"test_victory")
	AudioManager.restore_bgm(0.0)
	assert_eq(AudioManager.current_bgm, &"test_map")

func test_imported_audio_manifest_and_loop_flags() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio_assets.json"))
	for entry: Dictionary in manifest.files:
		assert_eq(FileAccess.get_sha256("res://" + entry.target), entry.sha256, "audio copiado sin modificar")
		assert_true(ResourceLoader.exists("res://" + entry.target))
		var stream: AudioStream = load("res://" + entry.target)
		assert_gt(stream.get_length(), 0.0)
	var bgm := AudioManager._find(AudioManager.BGM_DIR, &"low_hp") as AudioStreamOggVorbis
	var me := AudioManager._find(AudioManager.ME_DIR, &"caught") as AudioStreamOggVorbis
	assert_true(bgm.loop)
	assert_false(me.loop)

func test_low_hp_music_restores_battle_then_original_map() -> void:
	var scene := load("res://src/battle/scene/battle_scene.tscn").instantiate() as BattleScene
	add_child(scene)
	AudioManager.play_bgm(&"map_missing_for_test", 0.0)
	AudioManager.save_bgm()
	AudioManager.play_bgm(&"battle_missing_for_test", 0.0)
	scene._player_box.show()
	scene._player_box.max_hp = 100
	scene._player_box.hp = 10
	scene._update_low_hp_music()
	assert_eq(AudioManager.current_bgm, &"low_hp")
	scene._update_low_hp_music()
	scene._player_box.hp = 80
	scene._update_low_hp_music()
	assert_eq(AudioManager.current_bgm, &"battle_missing_for_test")
	AudioManager.restore_bgm(0.0)
	assert_eq(AudioManager.current_bgm, &"map_missing_for_test")
	scene.queue_free()
	await wait_process_frames(2)
