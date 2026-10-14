extends GutTest
## Ferris y avión por dentro (maps/_pintura/pintar_transportes.gd): cada pasarela lleva a su barco o a su
## terminal, el viaje salta al entrar, se baja en el destino y al avión no se sube sin pasar el control.

const MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const TRIP_EVENT := "res://src/events/viaje_event.gd"
const SECURITY_EVENT := "res://src/events/control_seguridad_event.gd"
## [calle, pasarela, mapa del viaje, destino, aparición en el destino].
const FERRIES: Array = [
	["barcelona/ciutat_vella", "FerryPalma", "transporte/ferry_barcelona_palma", "palma/exterior", "from_ferry"],
	["palma/exterior", "FerryBarcelona", "transporte/ferry_palma_barcelona", "barcelona/ciutat_vella", "from_ferry"],
	["valencia/malvarrosa", "FerryIbiza", "transporte/ferry_valencia_ibiza", "ibiza/exterior", "from_ferry"],
	["ibiza/exterior", "FerryValencia", "transporte/ferry_ibiza_valencia", "valencia/malvarrosa", "from_ferry"],
	["huelva/exterior", "FerryCanarias", "transporte/ferry_huelva_las_palmas", "las_palmas/canteras", "from_ferry"],
	["las_palmas/canteras", "FerryHuelva", "transporte/ferry_las_palmas_huelva", "huelva/exterior", "from_ferry"],
]
## [calle, pasarela, terminal, avión, terminal de llegada, calle de llegada].
const FLIGHTS: Array = [
	["playa_del_ingles/exterior", "AvionVigo", "playa_del_ingles/aeropuerto", "transporte/avion_gran_canaria_vigo", "vigo/aeropuerto", "vigo/exterior"],
	["vigo/exterior", "AvionGranCanaria", "vigo/aeropuerto", "transporte/avion_vigo_gran_canaria", "playa_del_ingles/aeropuerto", "playa_del_ingles/exterior"],
]

var _map: Node2D


func after_each() -> void:
	if is_instance_valid(_map):
		_map.free()


func _scene(map_id: String) -> Node:
	return (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()


## Comprueba que el Warp `warp` de `map_id` lleva a `target`/`spawn` y que esa aparición existe.
func _leads(map_id: String, warp: String, target: String, spawn: String) -> void:
	var map := _scene(map_id)
	var node := map.get_node_or_null("Warps/" + warp)
	assert_not_null(node, "%s no tiene la puerta %s" % [map_id, warp])
	if node != null:
		assert_eq(String(node.get(&"target_map")), target, "%s/%s" % [map_id, warp])
		assert_eq(String(node.get(&"target_spawn")), spawn, "%s/%s" % [map_id, warp])
	map.free()
	var dest := _scene(target)
	assert_not_null(dest.get_node_or_null("Spawns/" + spawn), "%s no tiene la aparición %s" % [target, spawn])
	dest.free()


func _trip_trigger(map_id: String) -> void:
	var map := _scene(map_id)
	var trigger := map.get_node_or_null("Triggers/Viaje") as Trigger
	assert_not_null(trigger, "%s: sin viaje" % map_id)
	if trigger != null:
		assert_eq(trigger.mode, Trigger.Mode.ON_ENTER, map_id)
		assert_eq(trigger.event.resource_path, TRIP_EVENT, map_id)
		assert_false((trigger.event_params.get("salida", []) as Array).is_empty(), map_id)
		assert_false((trigger.event_params.get("llegada", []) as Array).is_empty(), map_id)
	map.free()


func test_cada_pasarela_lleva_al_viaje_y_el_viaje_al_destino() -> void:
	for f: Array in FERRIES:
		_leads(f[0], f[1], f[2], "default")
		_trip_trigger(f[2])
		_leads(f[2], "Desembarcar", f[3], f[4])
	for f: Array in FLIGHTS:
		_leads(f[0], f[1], f[2], "default")
		_leads(f[2], "Embarque", f[3], "default")
		_trip_trigger(f[3])
		_leads(f[3], "Bajar", f[4], "from_llegadas")
		_leads(f[4], "Salida", f[5], "from_avion")


## Casillas a las que se llega andando desde `spawn`, sin pisar `blocked`.
func _reach(map: Node2D, spawn: String, blocked: Array[Vector2i] = []) -> Dictionary:
	var space := map.get_world_2d().direct_space_state
	var bounds := (map.get_node("Ground") as TileMapLayer).get_used_rect()
	var start := Grid.to_tile((map.get_node("Spawns/" + spawn) as Node2D).position)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := t + d
			if seen.has(n) or n in blocked or not bounds.has_point(n):
				continue
			var q := PhysicsPointQueryParameters2D.new()
			q.position = map.to_global(Grid.to_world(n))
			q.collision_mask = MASK
			q.collide_with_areas = false
			if space.intersect_point(q, 1).is_empty():
				seen[n] = true
				queue.append(n)
	return seen


func _warp_tile(map: Node2D, warp: String) -> Vector2i:
	return Grid.to_tile((map.get_node("Warps/" + warp) as Node2D).position)


func test_al_avion_no_se_sube_sin_pasar_el_control() -> void:
	for map_id: String in ["playa_del_ingles/aeropuerto", "vigo/aeropuerto"]:
		_map = _scene(map_id) as Node2D
		add_child(_map)
		await wait_physics_frames(3)
		var control := _map.get_node("Triggers/ControlSeguridad") as Trigger
		assert_eq(control.event.resource_path, SECURITY_EVENT)
		assert_eq(control.mode, Trigger.Mode.STEP)
		var arch := Grid.to_tile(control.position)
		var gate := _warp_tile(_map, "Embarque")
		var street := _warp_tile(_map, "Salida")
		assert_true(_reach(_map, "default").has(gate), "%s: no se llega a embarcar" % map_id)
		assert_false(_reach(_map, "default", [arch]).has(gate), "%s: se embarca sin pasar el control" % map_id)
		assert_true(_reach(_map, "from_llegadas", [arch]).has(street), "%s: al bajar del avión no se sale sin volver a pasar el control" % map_id)
		_map.free()
		await wait_physics_frames(2)


func test_cada_viaje_se_puede_completar() -> void:
	for map_id: String in ["transporte/ferry_huelva_las_palmas", "transporte/avion_vigo_gran_canaria"]:
		_map = _scene(map_id) as Node2D
		add_child(_map)
		await wait_physics_frames(3)
		var exit := "Desembarcar" if map_id.contains("ferry") else "Bajar"
		assert_true(_reach(_map, "default").has(_warp_tile(_map, exit)), "%s: no se llega a la puerta" % map_id)
		_map.free()
		await wait_physics_frames(2)


func _press() -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"accept"
		event.pressed = down
		Input.parse_input_event(event)


func test_los_eventos_terminan() -> void:
	var old_speed: int = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	GameState.reset()
	# El fundido del viaje necesita la escena principal (capa de transición).
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	assert_eq(await SceneManager.start_new_game(&"transporte/avion_vigo_gran_canaria", &"default"), OK)
	# Al empezar dentro del avión salta su propio viaje: se deja terminar antes de probar los demás.
	for frame: int in 600:
		await wait_physics_frames(1)
		if Dialogue.is_open:
			_press()
		if not Cutscene.is_running() and frame > 10:
			break
	# Subir al ferry por su pasarela dispara el viaje al entrar.
	SceneManager.change_map(&"transporte/ferry_huelva_las_palmas", &"default")
	var saw_trip := false
	for frame: int in 900:
		await wait_physics_frames(1)
		saw_trip = saw_trip or Cutscene.is_running()
		if Dialogue.is_open:
			_press()
		if saw_trip and not Cutscene.is_running():
			break
	assert_true(saw_trip, "al subir al ferry no salta el viaje")
	assert_eq(GameState.map_id, &"transporte/ferry_huelva_las_palmas")
	for case: Array in [
		[load(TRIP_EVENT), {"hablante": "Comandante", "salida": ["Despegamos."], "trayecto": ["Turbulencias."], "llegada": ["Aterrizamos."], "turbulencias": true}],
		[load(SECURITY_EVENT), {"flag": "test_control_visto", "guardia": "Guardia Civil"}],
		[load(SECURITY_EVENT), {"flag": "test_control_visto", "guardia": "Guardia Civil"}],
	]:
		var done: Array = []
		var play := func() -> void:
			await Cutscene.play(case[0], null, case[1])
			done.append(true)
		play.call()
		for frame: int in 600:
			await wait_physics_frames(1)
			if Dialogue.is_open:
				_press()
			if not done.is_empty():
				break
		assert_eq(done, [true], "el evento %s no termina" % (case[0] as Script).resource_path)
	assert_true(GameState.flag(&"test_control_visto"), "el control se recuerda")
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	Dialogue._box.text_speed = old_speed
	GameState.reset()
	MapLoader.clear()
