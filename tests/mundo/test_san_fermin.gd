extends GutTest
## San Fermín en Pamplona (src/events/san_fermin_event.gd): solo del 6 al 14 de julio con el reloj real; el
## 6, el chupinazo y, del 7 al 14, el encierro; una vez al día, al entrar en Pamplona.

const EVENT := "res://src/events/san_fermin_event.gd"

var _main: Node


func after_each() -> void:
	SanFerminEvent.fecha_de_prueba = {}
	if is_instance_valid(_main):
		SceneManager._leave_game()
		_main.queue_free()
		await wait_physics_frames(2)
		SceneManager.world = null
		SceneManager.ui_layer = null
		SceneManager.battle_layer = null
		SceneManager.transition_layer = null
		SceneManager._fade = null
	GameState.reset()
	MapLoader.clear()


func _press() -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"accept"
		event.pressed = down
		Input.parse_input_event(event)


func _play_until_done(frames: int = 900) -> void:
	for frame: int in frames:
		await wait_physics_frames(1)
		if Dialogue.is_open:
			_press()
		if frame > 10 and not Cutscene.is_running() and not SceneManager.is_busy() and not Dialogue.is_open:
			return


func test_solo_del_6_al_14_de_julio() -> void:
	for case: Array in [[7, 5, false], [7, 6, true], [7, 7, true], [7, 14, true], [7, 15, false], [6, 7, false], [8, 7, false]]:
		assert_eq(SanFerminEvent.en_fiestas({"year": 2026, "month": case[0], "day": case[1]}), case[2], "%d/%d" % [case[1], case[0]])
	SanFerminEvent.fecha_de_prueba = {"year": 2026, "month": 7, "day": 9}
	assert_eq(SanFerminEvent.hoy(), {"year": 2026, "month": 7, "day": 9}, "La fecha de pruebas manda")
	SanFerminEvent.fecha_de_prueba = {}
	var real := SanFerminEvent.hoy()
	assert_between(int(real.month), 1, 12, "Sin fecha de pruebas, la del reloj real")


func test_pamplona_lo_dispara_al_entrar() -> void:
	var map: Node = (load("res://maps/pamplona/exterior.tscn") as PackedScene).instantiate()
	var trigger := map.get_node_or_null("Triggers/SanFermin") as Trigger
	assert_not_null(trigger, "Pamplona tiene el disparador de San Fermín")
	if trigger != null:
		assert_eq(trigger.mode, Trigger.Mode.ON_ENTER)
		assert_eq(trigger.event.resource_path, EVENT)
	map.free()


func test_encierro_una_vez_al_dia_y_nada_fuera_de_fiestas() -> void:
	var old_speed: int = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	GameState.reset()
	_main = load("res://src/main/main.tscn").instantiate()
	_main.set_script(null)
	add_child(_main)
	SceneManager.register_main(_main)
	SanFerminEvent.fecha_de_prueba = {"year": 2026, "month": 7, "day": 7}
	assert_eq(await SceneManager.start_new_game(&"pamplona/exterior", &"default", {"intro": false}), OK)
	var saw := false
	for frame: int in 900:
		await wait_physics_frames(1)
		saw = saw or Cutscene.is_running()
		if Dialogue.is_open:
			_press()
		if saw and frame > 10 and not Cutscene.is_running() and not Dialogue.is_open:
			break
	assert_true(saw, "Al entrar en Pamplona el 7 de julio salta el encierro")
	assert_true(GameState.flag(&"san_fermin_2026_7"), "Queda hecho el encierro de ese día")
	# Otra vez el mismo día: ya no salta.
	var event: SanFerminEvent = load(EVENT).new()
	event.params = {}
	await event.run()
	assert_false(Dialogue.is_open, "No se repite el mismo día")
	# El 6, el chupinazo; fuera de fiestas, nada.
	SanFerminEvent.fecha_de_prueba = {"year": 2026, "month": 7, "day": 6}
	Cutscene.play(load(EVENT), null, {})
	await _play_until_done()
	assert_true(GameState.flag(&"san_fermin_2026_6"), "El chupinazo del 6")
	SanFerminEvent.fecha_de_prueba = {"year": 2026, "month": 10, "day": 15}
	Cutscene.play(load(EVENT), null, {})
	await _play_until_done()
	assert_false(GameState.flag(&"san_fermin_2026_15"), "En octubre no hay San Fermín")
	Dialogue._box.text_speed = old_speed
