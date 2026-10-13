extends GutTest
## Gimnasios por dentro (docs/DECISIONES_JAVIER_2026-10-14.md): en cada sala no se llega a la puerta
## siguiente (ni al líder) sin ganar antes a todos sus entrenadores, y después de ganarles sí.

const SPEC := "res://maps/_pintura/gimnasios_salas.json"
const MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


var _map: Node2D


func after_each() -> void:
	GameState.flags.clear()
	if is_instance_valid(_map):
		_map.free()


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


## La meta de la sala: la puerta a la siguiente, o una casilla junto al líder.
func _goal(map: Node2D) -> Array[Vector2i]:
	var next := map.get_node_or_null("Warps/Siguiente") as Node2D
	if next != null:
		return [Grid.to_tile(next.position)]
	var leader := map.get_node_or_null("Entities/Lider") as Node2D
	if leader == null:
		leader = map.get_node("Entities/Ayuso") as Node2D
	var out: Array[Vector2i] = []
	for d: Vector2i in DIRS:
		out.append(Grid.to_tile(leader.position) + d)
	return out


func _reaches(map: Node2D) -> bool:
	var seen := _reach(map)
	for cell: Vector2i in _goal(map):
		if seen.has(cell):
			return true
	return false


func test_no_se_pasa_de_sala_sin_ganar_a_todos() -> void:
	var spec := JsonFile.read_dict(SPEC)
	assert_eq(spec.size(), 8)
	for city: String in spec:
		var gym: Dictionary = spec[city]
		var rooms: Array = gym["salas"].duplicate()
		rooms.append({"entrenadores": gym.get("lider_previos", [])})
		for i: int in rooms.size():
			var map_id := "%s/gimnasio_lider" % city if i == rooms.size() - 1 else "%s/gimnasio_%d" % [city, i + 1]
			var trainers: Array = rooms[i]["entrenadores"]
			GameState.flags.clear()
			GameState.set_flag(&"quiron_superado")
			if not trainers.is_empty():
				assert_false(_reaches(await _open(map_id)), "%s: se pasa sin ganar a nadie" % map_id)
				# Falta el último: tampoco.
				for t: Dictionary in trainers.slice(0, trainers.size() - 1):
					GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % str(t["id"])))
				assert_false(_reaches(await _open(map_id)), "%s: se pasa con uno sin ganar" % map_id)
			for t: Dictionary in trainers:
				GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % str(t["id"])))
			assert_true(_reaches(await _open(map_id)), "%s: no se llega ni ganando a todos" % map_id)


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
