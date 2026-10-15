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
## [estación, andén, tren, estación de llegada, calle de la llegada, aparición en esa calle, destino que abre el andén].
const TRAINS: Array = [
	["madrid/sala_retiro_20_58", "Anden1", "transporte/ave_madrid_valladolid", "valladolid/sala_calle_52_59", "valladolid/exterior", "from_sala_52_59", "valladolid/exterior"],
	["madrid/sala_retiro_20_58", "Anden2", "transporte/ave_madrid_malaga", "malaga/sala_calle_5_57", "malaga/exterior", "from_sala_5_57", "malaga/exterior"],
	["valladolid/sala_calle_52_59", "Anden1", "transporte/ave_valladolid_madrid", "madrid/sala_retiro_20_58", "madrid/retiro", "from_sala_20_58", "madrid/retiro"],
	["malaga/sala_calle_5_57", "Anden1", "transporte/ave_malaga_madrid", "madrid/sala_retiro_20_58", "madrid/retiro", "from_sala_20_58", "madrid/retiro"],
	["madrid/sala_retiro_20_58", "Anden3", "transporte/ave_madrid_san_miguel", "pueblo_inicial/sala_calle_30_21", "pueblo_inicial/exterior", "from_sala_30_21", "pueblo_inicial/exterior"],
	["pueblo_inicial/sala_calle_30_21", "Anden1", "transporte/ave_san_miguel_madrid", "madrid/sala_retiro_20_58", "madrid/retiro", "from_sala_20_58", "madrid/retiro"],
]
const FREE_FLIGHT_EVENT := "res://src/events/vuelo_libre_event.gd"
## [ferry, puerto de salida (su pasarela lleva al ferry), aparición a la que te devuelve el sobrecargo].
const FERRY_PORTS: Array = [
	["transporte/ferry_barcelona_palma", "barcelona/ciutat_vella", "from_ferry"],
	["transporte/ferry_palma_barcelona", "palma/exterior", "from_ferry"],
	["transporte/ferry_valencia_ibiza", "valencia/malvarrosa", "from_ferry"],
	["transporte/ferry_ibiza_valencia", "ibiza/exterior", "from_ferry"],
	["transporte/ferry_huelva_las_palmas", "huelva/exterior", "from_ferry"],
	["transporte/ferry_las_palmas_huelva", "las_palmas/canteras", "from_ferry"],
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
	for t: Array in TRAINS:
		_leads(t[0], t[1], t[2], "default")
		_trip_trigger(t[2])
		_leads(t[2], "Bajar", t[3], "from_llegadas")
		_leads(t[3], "Salida", t[4], t[5])


## El andén del AVE lo tapa un revisor hasta haber estado en el destino (viaje rápido entre estaciones ya visitadas).
func test_el_ave_solo_lleva_a_destinos_ya_visitados() -> void:
	for t: Array in TRAINS:
		var station := _scene(t[0])
		var guard := station.get_node("Entities/Revisor" + String(t[1]).trim_prefix("Anden")) as MapEntity
		var gate := Grid.to_tile((station.get_node("Warps/" + t[1]) as Node2D).position)
		assert_eq(Grid.to_tile(guard.position), gate + Vector2i.DOWN, "%s: el revisor tapa el andén" % t[0])
		assert_eq(String(guard.hidden_if_flag), "visited_map:%s" % t[6], "%s/%s" % [t[0], t[1]])
		station.free()


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


## El sobrecargo de cada ferry pide el billete (objeto clave) y, si no lo compras, te devuelve a su puerto.
func test_cada_ferry_pide_el_billete_y_devuelve_a_su_puerto() -> void:
	for f: Array in FERRY_PORTS:
		var map := _scene(f[0])
		var trigger := map.get_node("Triggers/Viaje") as Trigger
		var params: Dictionary = trigger.event_params
		assert_eq(str(params.get("billete", "")), "ssticket", "%s pide el Ticket Barco" % f[0])
		assert_true(DataDB.has_item(&"ssticket") and DataDB.item(&"ssticket").pocket == &"key", "Es un objeto clave")
		assert_gt(int(params.get("precio", 0)), 0, f[0])
		assert_eq(params.get("vuelta", []), [f[1], f[2]], "%s devuelve a %s" % [f[0], f[1]])
		map.free()
		var port := _scene(f[1])
		var gangway := false
		for warp: Node in port.get_node("Warps").get_children():
			gangway = gangway or String(warp.get(&"target_map")) == f[0]
		assert_true(gangway, "%s tiene la pasarela de %s" % [f[1], f[0]])
		assert_not_null(port.get_node_or_null("Spawns/" + f[2]), "%s/%s" % [f[1], f[2]])
		port.free()


func _main_scene() -> Node:
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	return main


func _leave(main: Node) -> void:
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	GameState.reset()
	MapLoader.clear()


## Pulsa A en cada diálogo o lista hasta que acaba el evento (o pasan `frames`).
func _accept_until_done(frames: int = 900) -> void:
	for frame: int in frames:
		await wait_physics_frames(1)
		if Dialogue.is_open or SceneManager.is_menu_open():
			_press()
		if frame > 10 and not Cutscene.is_running() and not SceneManager.is_busy() and not Dialogue.is_open:
			return


func test_sin_billete_ni_dinero_se_vuelve_al_puerto_y_con_dinero_se_compra() -> void:
	var old_speed: int = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	GameState.reset()
	var main := _main_scene()
	assert_eq(await SceneManager.start_new_game(&"barcelona/ciutat_vella", &"from_ferry", {"intro": false}), OK)
	await _accept_until_done(60)
	GameState.money = 0
	SceneManager.change_map(&"transporte/ferry_barcelona_palma", &"default")
	await _accept_until_done()
	assert_eq(GameState.map_id, &"barcelona/ciutat_vella", "Sin dinero para el billete, el sobrecargo te baja a tierra")
	assert_eq(GameState.bag.count(&"ssticket"), 0)
	GameState.money = 1000
	SceneManager.change_map(&"transporte/ferry_barcelona_palma", &"default")
	await _accept_until_done()
	assert_eq(GameState.map_id, &"transporte/ferry_barcelona_palma", "Con el billete comprado se viaja")
	assert_eq(GameState.bag.count(&"ssticket"), 1, "El Ticket Barco queda en la mochila")
	assert_eq(GameState.money, 700, "Cuesta 300")
	SceneManager.change_map(&"transporte/ferry_palma_barcelona", &"default")
	await _accept_until_done()
	assert_eq(GameState.map_id, &"transporte/ferry_palma_barcelona", "El mismo billete vale para los demás ferris")
	assert_eq(GameState.money, 700, "No se vuelve a cobrar")
	Dialogue._box.text_speed = old_speed
	await _leave(main)


func test_el_primer_vuelo_abre_el_vuelo_libre_a_ciudades_visitadas() -> void:
	for map_id: String in ["playa_del_ingles/aeropuerto", "vigo/aeropuerto"]:
		var map := _scene(map_id)
		var desk := map.get_node_or_null("Entities/VuelosNacionales")
		assert_not_null(desk, "%s tiene mostrador de vuelos nacionales" % map_id)
		if desk != null:
			assert_eq((desk.get(&"event") as Script).resource_path, FREE_FLIGHT_EVENT)
			assert_has(["playa_del_ingles", "vigo"], str(desk.get(&"event_params").get("ciudad", "")))
		map.free()
	for map_id: String in ["transporte/avion_gran_canaria_vigo", "transporte/avion_vigo_gran_canaria"]:
		var plane := _scene(map_id)
		assert_eq(str((plane.get_node("Triggers/Viaje") as Trigger).event_params.get("marca", "")), "vuelo_libre", map_id)
		plane.free()
	var old_speed: int = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	GameState.reset()
	var main := _main_scene()
	assert_eq(await SceneManager.start_new_game(&"vigo/aeropuerto", &"default", {"intro": false}), OK)
	await _accept_until_done(60)
	var params := {"ciudad": "vigo", "hablante": "Vuelos nacionales"}
	Cutscene.play(load(FREE_FLIGHT_EVENT), null, params)
	await _accept_until_done()
	assert_eq(GameState.map_id, &"vigo/aeropuerto", "Antes del primer vuelo no hay vuelo libre")
	# El viaje del avión deja la marca al aterrizar.
	Cutscene.play(load(TRIP_EVENT), null, {"hablante": "Comandante", "salida": ["Despegamos."], "llegada": ["Aterrizamos."], "marca": "vuelo_libre"})
	await _accept_until_done()
	assert_true(GameState.flag(&"vuelo_libre"))
	GameState.set_flag(&"visited_map:valencia/ciutat_vella")
	Cutscene.play(load(FREE_FLIGHT_EVENT), null, params)
	await _accept_until_done()
	assert_eq(GameState.map_id, &"valencia/ciutat_vella", "Vuela a la única ciudad visitada")
	Dialogue._box.text_speed = old_speed
	await _leave(main)
