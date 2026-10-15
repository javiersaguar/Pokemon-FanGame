extends GutTest
## Gimnasios por dentro (docs/DECISIONES_JAVIER_2026-10-14.md): en cada sala no se llega a la puerta
## siguiente (ni al líder) sin ganar antes a todos sus entrenadores, y después de ganarles sí. Se comprueba
## paso a paso: con los primeros k ganados se llega al entrenador k+1, pero no a la meta.

const SPEC := "res://maps/_pintura/gimnasios_salas.json"
const MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const LEADER_EVENT := "res://src/events/gym_leader_event.gd"
const AYUSO_EVENT := "res://src/events/gym1_ayuso_event.gd"


var _map: Node2D


func after_each() -> void:
	GameState.flags.clear()
	if is_instance_valid(_map):
		_map.free()


## Las salas de un gimnasio en orden: [id del mapa, entrenadores de la sala].
func _rooms(city: String, gym: Dictionary) -> Array:
	var out := []
	var rooms: Array = gym["salas"]
	for i: int in rooms.size():
		out.append(["%s/gimnasio_%d" % [city, i + 1], rooms[i]["entrenadores"]])
	var leader: Dictionary = gym.get("sala_lider", {"entrenadores": gym.get("lider_previos", [])})
	out.append(["%s/gimnasio_lider" % city, leader.get("entrenadores", [])])
	return out


## Casillas a las que se llega andando desde la aparición `default` de un mapa ya metido en el árbol.
func _reach(map: Node2D) -> Dictionary:
	var space := map.get_world_2d().direct_space_state
	var bounds := (map.get_node("Ground") as TileMapLayer).get_used_rect()
	var start := Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := t + d
			if seen.has(n) or not bounds.has_point(n):
				continue
			var q := PhysicsPointQueryParameters2D.new()
			q.position = map.to_global(Grid.to_world(n))
			q.collision_mask = MASK
			q.collide_with_areas = false
			if space.intersect_point(q, 1).is_empty():
				seen[n] = true
				queue.append(n)
	return seen


## Abre un mapa; antes quita el anterior, para que sus vigilantes no sigan chocando en el mismo sitio.
func _open(map_id: String) -> Node2D:
	if is_instance_valid(_map):
		_map.free()
		await wait_physics_frames(2)
	_map = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
	add_child(_map)
	await wait_physics_frames(3)
	return _map


func _leader(map: Node2D) -> Node2D:
	var leader := map.get_node_or_null("Entities/Lider") as Node2D
	return leader if leader != null else map.get_node_or_null("Entities/Ayuso") as Node2D


## La meta de la sala: la puerta a la siguiente, o una casilla junto al líder.
func _goal(map: Node2D) -> Array[Vector2i]:
	var next := map.get_node_or_null("Warps/Siguiente") as Node2D
	if next != null:
		return [Grid.to_tile(next.position)]
	return _around(_leader(map))


func _around(node: Node2D) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d: Vector2i in DIRS:
		out.append(Grid.to_tile(node.position) + d)
	return out


func _reaches(seen: Dictionary, cells: Array[Vector2i]) -> bool:
	for cell: Vector2i in cells:
		if seen.has(cell):
			return true
	return false


## El nodo del entrenador `id` en el mapa.
func _trainer(map: Node2D, id: String) -> Node2D:
	for node: Node in map.get_node("Entities").get_children():
		if node is TrainerNPC and String((node as TrainerNPC).trainer_id) == id:
			return node as Node2D
	return null


func test_no_se_pasa_de_sala_sin_ganar_a_todos() -> void:
	var spec := JsonFile.read_dict(SPEC)
	assert_eq(spec.size(), 8)
	for city: String in spec:
		for room: Array in _rooms(city, spec[city]):
			var map_id: String = room[0]
			var trainers: Array = room[1]
			# Paso a paso: con los k primeros ganados se llega al siguiente, pero no a la meta.
			for k: int in range(0, trainers.size() + 1):
				GameState.flags.clear()
				GameState.set_flag(&"quiron_superado")
				for t: Dictionary in trainers.slice(0, k):
					GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % str(t["id"])))
				var map := await _open(map_id)
				var seen := _reach(map)
				if k < trainers.size():
					var next := _trainer(map, str(trainers[k]["id"]))
					assert_not_null(next, "%s: falta %s" % [map_id, trainers[k]["id"]])
					if next != null:
						assert_true(_reaches(seen, _around(next)), "%s: con %d ganados no se llega a %s" % [map_id, k, trainers[k]["id"]])
					assert_false(_reaches(seen, _goal(map)), "%s: se pasa con %d de %d ganados" % [map_id, k, trainers.size()])
				else:
					assert_true(_reaches(seen, _goal(map)), "%s: no se llega ni ganando a todos" % map_id)


func test_cada_sala_tiene_rotulo_salida_y_puerta() -> void:
	var spec := JsonFile.read_dict(SPEC)
	for city: String in spec:
		var rooms := _rooms(city, spec[city])
		for i: int in rooms.size():
			var map_id: String = rooms[i][0]
			var map: Node = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
			assert_not_null(map.get_node_or_null("Rotulo"), "%s sin rótulo" % map_id)
			assert_not_null(map.get_node_or_null("Spawns/default"), "%s sin aparición" % map_id)
			var exit := map.get_node_or_null("Warps/Salida")
			assert_not_null(exit, "%s sin salida" % map_id)
			if exit != null and i > 0:
				assert_eq(String(exit.get(&"target_map")), rooms[i - 1][0], "%s sale a la sala anterior" % map_id)
				assert_eq(String(exit.get(&"target_spawn")), "from_arriba")
			var next := map.get_node_or_null("Warps/Siguiente")
			if i < rooms.size() - 1:
				assert_not_null(next, "%s sin puerta a la siguiente" % map_id)
				if next != null:
					assert_eq(String(next.get(&"target_map")), rooms[i + 1][0])
				assert_not_null(map.get_node_or_null("Spawns/from_arriba"), "%s sin llegada desde arriba" % map_id)
			else:
				assert_null(next, "la sala del líder no sigue")
			map.free()


func test_el_lider_espera_en_su_sala_con_su_evento() -> void:
	var gyms: Dictionary = JsonFile.read_dict("res://data/gimnasios.json")["gimnasios"]
	for key: String in gyms:
		var gym: Dictionary = gyms[key]
		var map_id: String = gym["salas"][-1]
		var map: Node2D = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
		var leader := _leader(map)
		assert_not_null(leader, "%s sin líder" % map_id)
		if leader is TrainerNPC:
			assert_eq(String((leader as TrainerNPC).trainer_id), str(gym["lider"]))
			assert_eq(((leader as TrainerNPC).challenge_event as GDScript).resource_path, LEADER_EVENT)
		elif leader != null:
			# Madrid: Ayuso te sube a su ático, donde da la medalla (data/personajes_en_el_mapa.json).
			assert_eq((leader.get(&"event") as GDScript).resource_path, AYUSO_EVENT)
		map.free()


func test_el_gimnasio_1_no_abre_hasta_pasar_por_el_quiron() -> void:
	var closed := await _open("madrid/gimnasio_1")
	assert_false((closed.get_node("Entities/Entrenador1") as MapEntity).is_present(), "sin el Quirón no hay con quién combatir")
	assert_true((closed.get_node("Entities/Ujier") as MapEntity).is_present())
	GameState.set_flag(&"quiron_superado")
	var open := await _open("madrid/gimnasio_1")
	assert_true((open.get_node("Entities/Entrenador1") as MapEntity).is_present())
	assert_false((open.get_node("Entities/Ujier") as MapEntity).is_present())


func test_cada_entrenador_de_gimnasio_existe_y_esta_en_su_sala() -> void:
	var gyms: Dictionary = JsonFile.read_dict("res://data/gimnasios.json")["gimnasios"]
	for key: String in gyms:
		var gym: Dictionary = gyms[key]
		var placed := {}
		for map_id: String in gym["salas"]:
			assert_true(ResourceLoader.exists("res://maps/%s.tscn" % map_id), map_id)
			var map: Node = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
			for node: Node in map.get_node("Entities").get_children():
				if node is TrainerNPC:
					placed[String((node as TrainerNPC).trainer_id)] = true
			map.free()
		for trainer: String in gym["entrenadores"]:
			assert_true(TrainerData.exists(StringName(trainer)), trainer)
			assert_true(placed.has(trainer), "%s no está en ninguna sala de %s" % [trainer, key])
