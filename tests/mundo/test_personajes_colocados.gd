extends GutTest
## Personajes colocados por datos (data/personajes_en_el_mapa.json) y gimnasios (data/gimnasios.json):
## que cada uno exista, salga en su mapa en una casilla que no pisa a nadie, y que los líderes den su
## medalla.

const GymLeaderEvent := preload("res://src/events/gym_leader_event.gd")


func _doc() -> Dictionary:
	return JsonFile.read_dict(CharacterPlacements.DATA)


func test_cada_personaje_existe_y_tiene_casilla() -> void:
	var placed := {}
	for entry: Dictionary in _doc()["colocados"]:
		if entry.has("entrenador"):
			assert_true(TrainerData.exists(StringName(entry["entrenador"])), "falta el entrenador %s" % entry["entrenador"])
		else:
			assert_true(ResourceLoader.exists("res://assets/sprites/characters/%s.png" % entry["sprite"]), "%s sin sprite" % entry["id"])
			assert_false(Array(entry.get("frases", [])).is_empty(), "%s no dice nada" % entry["id"])
		assert_true(entry.has("casilla"), "%s sin casilla: pasa maps/_tools/colocar_personajes.gd" % entry["id"])
		assert_true(ResourceLoader.exists(MapRoot.path_from_id(StringName(entry["mapa"]))), "no existe %s" % entry["mapa"])
		assert_false(placed.has(entry["id"]), "%s está dos veces" % entry["id"])
		placed[entry["id"]] = true
	for entry: Dictionary in _doc()["pendientes"]:
		assert_true(TrainerData.exists(StringName(entry["id"])), "falta el entrenador pendiente %s" % entry["id"])
		assert_false(placed.has(entry["id"]), "%s está colocado y pendiente a la vez" % entry["id"])


func test_salen_en_su_mapa_sin_pisar_a_nadie() -> void:
	var maps := {}
	for entry: Dictionary in _doc()["colocados"]:
		maps[entry["mapa"]] = true
	for map_id: String in maps:
		var prepared := MapLoader.prepare(StringName(map_id))
		assert_eq(prepared["error"], OK, map_id)
		var map: MapRoot = prepared["map"]
		var tiles := {}
		for node: Node in map.get_entities().get_children():
			if node is Node2D and not node is TileMapLayer:
				var tile := Grid.to_tile((node as Node2D).position)
				assert_false(tiles.has(tile), "%s y %s en la misma casilla %s de %s" % [node.name, tiles.get(tile, ""), tile, map_id])
				tiles[tile] = node.name
		for entry: Dictionary in CharacterPlacements.for_map(StringName(map_id)):
			if not CharacterPlacements.is_available(entry):
				continue
			var node := map.get_entities().get_node_or_null(CharacterPlacements.node_name(entry)) as Node2D
			assert_not_null(node, "%s no sale en %s" % [entry["id"], map_id])
			if node:
				assert_eq(Grid.to_tile(node.position), Vector2i(int(entry["casilla"][0]), int(entry["casilla"][1])))
				assert_null(map.warp_at(Grid.to_tile(node.position)), "%s está sobre una pasarela" % entry["id"])
		map.free()


func test_los_gimnasios_tienen_lider_entrenadores_y_medalla() -> void:
	var gyms: Dictionary = JsonFile.read_dict(GymLeaderEvent.GYMS)["gimnasios"]
	assert_eq(gyms.size(), 8)
	var badges := {}
	for city: String in gyms:
		var gym: Dictionary = gyms[city]
		assert_true(TrainerData.exists(StringName(gym["lider"])), city)
		for trainer: String in gym["entrenadores"]:
			assert_true(TrainerData.exists(StringName(trainer)), trainer)
		assert_false(badges.has(gym["medalla"]), "medalla repetida")
		badges[gym["medalla"]] = true
		assert_eq(GymLeaderEvent.gym_of(StringName(gym["lider"]))["ciudad"], gym["ciudad"])
	assert_true(GymLeaderEvent.gym_of(&"ibai").is_empty())


func test_el_lider_entrega_su_medalla_una_vez() -> void:
	GameState.badges.clear()
	assert_eq(GymLeaderEvent.grant(&"joaquin")["nombre_medalla"], "Medalla Arte")
	assert_true(GameState.has_badge(&"medalla_arte"))
	assert_true(GymLeaderEvent.grant(&"joaquin").is_empty(), "la segunda vez no da otra")
	assert_true(GymLeaderEvent.grant(&"ibai").is_empty(), "un famoso no da medallas")
	assert_eq(GameState.badges, [&"medalla_arte"] as Array[StringName])
	GameState.badges.clear()


func test_los_que_tienen_condicion_solo_salen_al_cumplirla() -> void:
	GameState.badges.clear()
	var leire := {"requiere": {"medallas": 2}}
	assert_false(CharacterPlacements.is_available(leire))
	GameState.badges.assign([&"medalla_libertad", &"medalla_palanca"])
	assert_true(CharacterPlacements.is_available(leire))
	var rey := {"requiere": {"flag": "liga_superada"}}
	assert_false(CharacterPlacements.is_available(rey))
	GameState.set_flag(&"liga_superada")
	assert_true(CharacterPlacements.is_available(rey))
	GameState.clear_flag(&"liga_superada")
	GameState.badges.clear()
	assert_true(CharacterPlacements.is_available({}))
	var obras := {"hasta": {"medallas": 7}}
	assert_true(CharacterPlacements.is_available(obras), "las obras están al principio")
	GameState.badges.assign([&"a", &"b", &"c", &"d", &"e", &"f", &"g"])
	assert_false(CharacterPlacements.is_available(obras), "con 7 medallas se han ido")
	GameState.badges.clear()


func test_cada_gimnasio_da_una_mt_que_existe() -> void:
	var gyms: Dictionary = JsonFile.read_dict(GymLeaderEvent.GYMS)["gimnasios"]
	var seen := {}
	for city: String in gyms:
		var machine := GymLeaderEvent.machine_for(StringName(gyms[city]["premio_mt"]))
		assert_ne(machine, &"", "no hay MT de %s (%s)" % [gyms[city]["premio_mt"], city])
		assert_false(seen.has(machine), "MT repetida")
		seen[machine] = true
