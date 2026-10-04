extends GutTest
## Mapas, casillas y encuentros salvajes (Agente 1).

const OUTDOOR := "res://maps/test/test_outdoor.tscn"

var _map: MapRoot


func before_each() -> void:
	_map = (load(OUTDOOR) as PackedScene).instantiate()
	add_child_autofree(_map)


func test_casillas_y_pixeles() -> void:
	assert_eq(Grid.to_world(Vector2i(2, 3)), Vector2(40, 56), "centro de la casilla")
	assert_eq(Grid.to_tile(Vector2(40, 56)), Vector2i(2, 3))
	assert_eq(Grid.to_tile(Vector2(-1, -1)), Vector2i(-1, -1))
	assert_eq(Grid.snap(Vector2(33, 47)), Vector2(40, 40))


func test_ids_de_mapa() -> void:
	assert_eq(MapRoot.id_from_path("res://maps/pueblo_inicial/exterior.tscn"), &"pueblo_inicial/exterior")
	assert_eq(MapRoot.path_from_id(&"test/test_room"), "res://maps/test/test_room.tscn")
	assert_eq(_map.get_map_id(), &"test/test_outdoor")


func test_datos_de_las_casillas() -> void:
	assert_eq(_map.terrain_at(Vector2i(15, 3)), "tall_grass")
	assert_true(_map.is_encounter_tile(Vector2i(15, 3)))
	assert_false(_map.is_encounter_tile(Vector2i(5, 7)), "el camino no tiene encuentros")
	assert_eq(_map.terrain_at(Vector2i(0, 0)), "tree", "Decor tiene prioridad sobre Ground")
	assert_eq(_map.terrain_at(Vector2i(50, 50)), "", "fuera del mapa")


func test_warps_y_spawns() -> void:
	var warp := _map.warp_at(Vector2i(5, 4))
	assert_not_null(warp)
	assert_eq(warp.target_map, &"test/test_room")
	assert_eq(warp.get_arrival_facing(), Vector2i.UP)
	assert_null(_map.warp_at(Vector2i(6, 4)))
	assert_eq(Grid.to_tile(_map.get_spawn(&"from_room").position), Vector2i(5, 5))
	assert_eq(_map.get_spawn(&"default").name, &"default")


func test_tabla_por_momento_del_dia() -> void:
	var table := {"land": {"day": [{"species": "a"}], "night": [{"species": "b"}]}, "water": [{"species": "c"}]}
	assert_eq(WildEncounters.slots(table, &"land", &"night")[0]["species"], "b")
	assert_eq(WildEncounters.slots(table, &"land", &"morning")[0]["species"], "a", "sin morning se usa day")
	assert_eq(WildEncounters.slots(table, &"water", &"night")[0]["species"], "c", "una lista vale a cualquier hora")
	assert_eq(WildEncounters.slots(table, &"old_rod", &"day"), [])


func test_pesos_y_niveles() -> void:
	var table := {"land": [
		{"species": "pidgey", "min": 2, "max": 4, "weight": 75},
		{"species": "rattata", "min": 3, "max": 3, "weight": 25},
	]}
	WildEncounters.rng.seed = 1234
	var counts := {&"pidgey": 0, &"rattata": 0}
	for i: int in 4000:
		var wild := WildEncounters.pick_from(table, &"land", &"day")
		counts[wild["species"]] += 1
		if wild["species"] == &"rattata":
			assert_eq(wild["level"], 3)
		elif wild["level"] < 2 or wild["level"] > 4:
			fail_test("nivel fuera de rango: %d" % wild["level"])
	assert_almost_eq(counts[&"pidgey"] / 4000.0, 0.75, 0.03)
	WildEncounters.rng.randomize()


func test_probabilidad_por_paso() -> void:
	assert_almost_eq(WildEncounters.step_chance(_map, {"land_rate": 15}), 0.15, 0.0001)
	assert_almost_eq(WildEncounters.step_chance(_map, {}), 0.1, 0.0001, "por defecto, world.json")
	_map.data.encounter_rate = 0.5
	assert_almost_eq(WildEncounters.step_chance(_map, {"land_rate": 15}), 0.5, 0.0001, "manda la del mapa")
	_map.data.encounter_rate = 0.0


func test_tabla_real_de_la_sala_de_pruebas() -> void:
	var wild := WildEncounters.pick(&"test_outdoor", &"land", &"day")
	assert_true(DataDB.has_species(wild["species"]), "especie existente: %s" % wild.get("species"))
