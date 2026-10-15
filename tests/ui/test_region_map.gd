extends GutTest
## Mapa de la región del juego (src/ui/region_map/region_map_screen.gd): enseña todas las ciudades, pueblos,
## barrios y rutas de data/region.json, el cursor llega a todos, sabe dónde estás y qué has visitado, y los
## destinos de vuelo (data/world.json → field.flight_destinations) son los lugares de la región.

var _screen: RegionMapScreen

func after_each() -> void:
	if is_instance_valid(_screen):
		_screen.free()
	GameState.reset()

func _open() -> RegionMapScreen:
	_screen = RegionMapScreen.new()
	add_child(_screen)
	await wait_process_frames(2)
	return _screen

func test_salen_todas_las_ciudades_pueblos_barrios_y_rutas() -> void:
	GameState.reset()
	var screen := await _open()
	var region := JsonFile.read_dict("res://data/region.json")
	var ids := screen.places.map(func(p: Dictionary) -> String: return p.id)
	for section: String in ["locations", "districts"]:
		for id: String in region[section]:
			if region[section][id].has("pendiente") and not SceneManager.map_exists(StringName(str(region[section][id].map))):
				assert_does_not_have(ids, id, "%s aún no tiene mapa" % id)
				continue
			assert_has(ids, id, "%s en el mapa regional" % id)
	for id: String in region.routes:
		if str(region.routes[id].get("map", "")) != "":
			assert_has(ids, id, "%s en el mapa regional" % id)
	assert_has(ids, "calle_victoria", "La Calle de la Victoria ya sale en el mapa regional")
	for id: String in ["pozuelo", "orcasitas", "huelva", "playa_del_ingles", "rocafonda", "casa_de_campo", "madrid_rio", "bernabeu"]:
		assert_has(ids, id)
	for place: Dictionary in screen.places:
		assert_true(RegionMapScreen.MAP_RECT.has_point(screen.position_of(place)), "%s dentro del plano" % place.id)
		for map: Variant in place.maps:
			assert_true(SceneManager.map_exists(StringName(str(map))), "%s: existe %s" % [place.id, map])

func test_el_cursor_llega_a_todos_los_puntos() -> void:
	GameState.reset()
	var screen := await _open()
	var seen := {0: true}
	var queue: Array[int] = [0]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		for direction: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var next := screen.neighbour(at, direction)
			if not seen.has(next):
				seen[next] = true
				queue.append(next)
	var missing: Array = []
	for i: int in screen.places.size():
		if not seen.has(i): missing.append(screen.places[i].id)
	assert_eq(missing, [], "Con las flechas se llega a todos los puntos")

func test_donde_estas_y_que_has_visitado() -> void:
	GameState.reset()
	GameState.map_id = &"madrid/quiron"
	GameState.set_flag(&"visited_map:pozuelo/exterior")
	var screen := await _open()
	assert_eq(screen.places[screen.here].id, "madrid", "Un interior cuenta como su ciudad")
	assert_eq(screen.places[screen.selected].id, "madrid", "El cursor empieza donde estás")
	assert_true(screen._you.position.x > 0)
	for place: Dictionary in screen.places:
		assert_eq(RegionMapScreen.visited(place), place.id == "pozuelo", "%s visitado" % place.id)
	GameState.map_id = &"madrid/moncloa"
	screen._refresh()
	assert_eq(screen.places[screen.here].id, "moncloa", "Un barrio de Madrid es su punto")
	assert_true(screen._info.text.contains("Estás aquí"))

func test_destinos_de_vuelo_son_los_lugares_de_la_region() -> void:
	GameState.reset()
	var region := JsonFile.read_dict("res://data/region.json")
	var list: Array = GameState.world_config.field.flight_destinations
	var places: Array = region.locations.keys().filter(func(id: String) -> bool: return not region.locations[id].has("pendiente") and region.locations[id].get("vuelo", true))
	assert_eq(list.size(), places.size(), "Un destino por ciudad y pueblo")
	for destination: Dictionary in list:
		assert_true(region.locations.has(str(destination.id)), str(destination.id))
		assert_eq(str(destination.map), str(region.locations[destination.id].map))
		assert_eq(MapLoader.check_spawn(StringName(str(destination.map)), StringName(str(destination.spawn))), OK, str(destination.id))
	assert_eq(WorldTravel.destinations().size(), 0, "Sin visitar no hay destinos")
	GameState.set_flag(&"visited_map:valencia/ciutat_vella")
	var screen := await _open()
	assert_eq(screen.destinations.size(), 1)
	assert_eq(screen.choices, PackedStringArray(["Valencia"]))
	for i: int in screen.places.size():
		if screen.places[i].id == "valencia": screen.selected = i
	screen._show()
	assert_true(screen._info.text.contains("A: volar"), "Valencia ya visitada se ofrece para volar")
	assert_true(screen._info.text.contains("Gimnasio 3"))

func test_se_cierra_con_b() -> void:
	GameState.reset()
	var screen := await _open()
	var closed := []
	screen.closed.connect(func() -> void: closed.append(true))
	var event := InputEventAction.new()
	event.action = &"cancel"
	event.pressed = true
	screen._unhandled_input(event)
	assert_eq(closed, [true])
