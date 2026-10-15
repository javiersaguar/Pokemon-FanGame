extends GutTest
## Surf (docs/mundo/region.md: de Palma a Ibiza por la Ruta marítima 1, decisión de Javier). Comprueba que
## solo hace falta en ese tramo de agua, que tiene entrada desde la playa de Palma, se cruza entero por el
## agua y tiene salida a tierra en Ibiza, y que el jugador de verdad hace Surf, cruza los dos bordes sin
## dejar de hacerlo y vuelve a andar al pisar la playa. La herramienta de campo (qué objeto y con qué
## medalla) es del sistema de medallas: aquí se da con una configuración de prueba, como en test_field_world.

const SURF_MAPS: Array[String] = ["maritima_1/exterior", "palma/exterior", "ibiza/exterior"]
const MASK := 1 | 2 | 8
const WATER := 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var _original: Dictionary
var _main: Node


func before_each() -> void:
	_original = GameState.world_config.duplicate(true)


func after_each() -> void:
	GameState.world_config = _original
	Debug.encounters_disabled = false
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


## {walk, surf, water, bounds} de un mapa ya en el árbol.
func _tiles(map: MapRoot) -> Dictionary:
	var space := map.get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = false
	var walk := {}
	var surf := {}
	var water := {}
	for cell: Vector2i in map.get_ground().get_used_cells():
		query.position = map.to_global(Grid.to_world(cell))
		query.collision_mask = MASK
		var free_walk := space.intersect_point(query, 1).is_empty()
		query.collision_mask = MASK & ~WATER
		var free_surf := space.intersect_point(query, 1).is_empty()
		if free_walk: walk[cell] = true
		if free_surf: surf[cell] = true
		if free_surf and map.terrain_at(cell) == "water": water[cell] = true
	return {"walk": walk, "surf": surf, "water": water, "bounds": map.get_ground().get_used_rect()}


func _flood(free: Dictionary, starts: Array) -> Dictionary:
	var seen := {}
	var queue: Array = []
	# La casilla de salida cuenta aunque la ocupe el propio jugador.
	for s: Vector2i in starts:
		if not seen.has(s):
			seen[s] = true
			queue.append(s)
	var cursor := 0
	while cursor < queue.size():
		var t: Vector2i = queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := t + d
			if free.has(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func _spawns(map: MapRoot) -> Array:
	var out: Array = []
	for spawn: Node2D in map.get_node("Spawns").get_children():
		out.append(Grid.to_tile(spawn.position))
	return out


## Casillas del borde de una conexión (dentro de su tramo).
func _edge(c: MapConnection, bounds: Rect2i, from: Dictionary) -> Array:
	var out: Array = []
	for t: Vector2i in from:
		var along := t.y if c.edge in ["east", "west"] else t.x
		if c.span != Vector2i.ZERO and (along < c.span.x or along >= c.span.y):
			continue
		if (c.edge == "north" and t.y == bounds.position.y) or (c.edge == "south" and t.y == bounds.end.y - 1) \
				or (c.edge == "west" and t.x == bounds.position.x) or (c.edge == "east" and t.x == bounds.end.x - 1):
			out.append(t)
	out.sort()
	return out


func _prepare(id: String) -> MapRoot:
	var prepared := MapLoader.prepare(StringName(id))
	var map: MapRoot = prepared.map
	add_child(map)
	await wait_physics_frames(2)
	return map


func test_surf_solo_hace_falta_entre_palma_e_ibiza() -> void:
	GameState.reset()
	var needs_surf := {}
	for id: StringName in MapRoot.list_all():
		var sid := String(id)
		if sid.begins_with("test/") or sid.begins_with("muestras/"):
			continue
		# Los interiores se descartan sin instanciarlos.
		var state := (load(MapRoot.path_from_id(id)) as PackedScene).get_state()
		var outdoor := true
		for j: int in state.get_node_property_count(0):
			if state.get_node_property_name(0, j) == &"data" and state.get_node_property_value(0, j) is MapData:
				outdoor = (state.get_node_property_value(0, j) as MapData).outdoor
		if not outdoor:
			continue
		var map := await _prepare(sid)
		if not map.data.outdoor:
			map.free()
			continue
		var tiles := _tiles(map)
		if tiles.water.is_empty():
			map.free()
			continue
		var walk := _flood(tiles.walk, _spawns(map))
		var surf := _flood(tiles.surf, _spawns(map))
		var only: Array = []
		for c: MapConnection in map.data.connections:
			if _edge(c, tiles.bounds, walk).is_empty() and not _edge(c, tiles.bounds, surf).is_empty():
				only.append("borde %s" % c.target_map)
		for warp: Warp in map.get_warps():
			var at := Grid.to_tile(warp.position)
			if not walk.has(at) and surf.has(at):
				only.append("puerta %s" % warp.name)
		if not only.is_empty():
			needs_surf[sid] = only
		map.free()
		await wait_physics_frames(1)
	assert_eq(needs_surf.keys().filter(func(k: String) -> bool: return k not in SURF_MAPS), [], "Fuera del canal de Ibiza no hace falta Surf para nada")
	assert_has(needs_surf.get("palma/exterior", []), "borde maritima_1/exterior", "De Palma al canal, con Surf")
	assert_has(needs_surf.get("ibiza/exterior", []), "borde maritima_1/exterior", "De Ibiza al canal, con Surf")


func test_entrada_desde_palma_cruce_entero_y_salida_en_ibiza() -> void:
	GameState.reset()
	# Palma: desde una casilla de playa a la que se llega andando, el agua lleva hasta el borde sur.
	var palma := await _prepare("palma/exterior")
	var tiles := _tiles(palma)
	var walk := _flood(tiles.walk, _spawns(palma))
	var to_sea: MapConnection = null
	for c: MapConnection in palma.data.connections:
		if String(c.target_map) == "maritima_1/exterior": to_sea = c
	assert_not_null(to_sea)
	var entries: Array = []
	for land: Vector2i in walk:
		for d: Vector2i in DIRS:
			if tiles.water.has(land + d): entries.append(land + d)
	assert_false(entries.is_empty(), "Palma tiene playa desde la que meterse al agua")
	var sea := _flood(tiles.water, entries)
	assert_false(_edge(to_sea, tiles.bounds, sea).is_empty(), "Desde la playa de Palma se llega por el agua al canal")
	palma.free()
	# Canal: por el agua, de un borde al otro.
	var canal := await _prepare("maritima_1/exterior")
	tiles = _tiles(canal)
	var north: MapConnection = null
	var south: MapConnection = null
	for c: MapConnection in canal.data.connections:
		if c.edge == "north": north = c
		if c.edge == "south": south = c
	var crossing := _flood(tiles.water, _edge(north, tiles.bounds, tiles.water))
	assert_false(_edge(south, tiles.bounds, crossing).is_empty(), "El canal se cruza entero por el agua")
	canal.free()
	# Ibiza: del borde norte, por el agua, a una playa unida al resto de la ciudad.
	var ibiza := await _prepare("ibiza/exterior")
	tiles = _tiles(ibiza)
	walk = _flood(tiles.walk, [Grid.to_tile((ibiza.get_node("Spawns/default") as Node2D).position)])
	var from_sea: MapConnection = null
	for c: MapConnection in ibiza.data.connections:
		if String(c.target_map) == "maritima_1/exterior": from_sea = c
	var arriving := _flood(tiles.water, _edge(from_sea, tiles.bounds, tiles.water))
	var exits := 0
	for w: Vector2i in arriving:
		for d: Vector2i in DIRS:
			if walk.has(w + d): exits += 1
	assert_gt(exits, 0, "Desde el canal se desembarca en Ibiza y se llega a la ciudad")
	ibiza.free()


func _start(map_id: StringName) -> void:
	_main = load("res://src/main/main.tscn").instantiate()
	_main.set_script(null)
	add_child(_main)
	SceneManager.register_main(_main)
	SceneManager._fade.hide()
	assert_eq(await SceneManager.start_new_game(map_id, &"default", {"intro": false}), OK)
	Debug.encounters_disabled = true


## Un paso del jugador de verdad (o el cruce del borde) hacia `dir`.
func _step(dir: Vector2i) -> void:
	await SceneManager.player._walk(dir)
	await wait_until(func() -> bool: return not SceneManager.is_busy(), 3.0)
	await wait_physics_frames(2)


func test_el_jugador_hace_surf_de_palma_a_ibiza() -> void:
	GameState.world_config.field.actions.surf = {"item": "hm03", "required_flag": ""}
	await _start(&"palma/exterior")
	GameState.bag.add(&"hm03")
	var map := SceneManager.current_map
	var tiles := _tiles(map)
	var walk := _flood(tiles.walk, _spawns(map))
	# Una playa de Palma desde la que el agua lleva al canal.
	var to_sea: MapConnection = null
	for c: MapConnection in map.data.connections:
		if String(c.target_map) == "maritima_1/exterior": to_sea = c
	var land := Vector2i(-1, -1)
	var dir := Vector2i.ZERO
	for t: Vector2i in walk:
		for d: Vector2i in DIRS:
			if tiles.water.has(t + d) and not _edge(to_sea, tiles.bounds, _flood(tiles.water, [t + d])).is_empty():
				land = t
				dir = d
				break
		if dir != Vector2i.ZERO: break
	assert_ne(dir, Vector2i.ZERO, "Hay playa en Palma")
	if dir == Vector2i.ZERO: return
	assert_eq(await SceneManager.change_map_at(&"palma/exterior", land, dir, false), OK)
	SceneManager.player.face(dir)
	assert_true(FieldActions.available(&"surf", SceneManager.current_map), "Con la herramienta, Surf está disponible")
	assert_true(SceneManager.player.set_transport_mode(&"surf"), "Mirando al agua se hace Surf")
	await _step(dir)
	assert_eq(SceneManager.player.tile_position(), land + dir, "Se entra en el agua")
	assert_eq(FieldActions.transport(), &"surf")
	# Cruza el borde sur haciendo Surf.
	var edge_tile: Vector2i = _edge(to_sea, tiles.bounds, _flood(tiles.water, [land + dir]))[0]
	assert_eq(await SceneManager.change_map_at(&"palma/exterior", edge_tile, Vector2i.DOWN, false), OK)
	await _step(Vector2i.DOWN)
	assert_eq(GameState.map_id, &"maritima_1/exterior", "Del agua de Palma al canal")
	assert_eq(FieldActions.transport(), &"surf", "Sigue haciendo Surf al cruzar")
	# Del canal a Ibiza.
	map = SceneManager.current_map
	tiles = _tiles(map)
	var south: MapConnection = null
	for c: MapConnection in map.data.connections:
		if c.edge == "south": south = c
	var crossing := _flood(tiles.water, [SceneManager.player.tile_position()])
	var south_tile: Vector2i = _edge(south, tiles.bounds, crossing)[0]
	assert_eq(await SceneManager.change_map_at(&"maritima_1/exterior", south_tile, Vector2i.DOWN, false), OK)
	await _step(Vector2i.DOWN)
	assert_eq(GameState.map_id, &"ibiza/exterior", "Del canal a Ibiza")
	assert_eq(FieldActions.transport(), &"surf")
	# Desembarca en una playa de Ibiza unida a la ciudad: vuelve a andar.
	map = SceneManager.current_map
	tiles = _tiles(map)
	walk = _flood(tiles.walk, [Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)])
	var arriving := _flood(tiles.water, [SceneManager.player.tile_position()])
	var shore := Vector2i(-1, -1)
	for w: Vector2i in arriving:
		for d: Vector2i in DIRS:
			if walk.has(w + d):
				shore = w
				dir = d
				break
		if shore.x >= 0: break
	assert_true(shore.x >= 0, "Hay playa en Ibiza")
	assert_eq(await SceneManager.change_map_at(&"ibiza/exterior", shore, dir, false), OK)
	assert_eq(FieldActions.transport(), &"surf", "En el agua de Ibiza sigue el Surf")
	await _step(dir)
	assert_eq(SceneManager.player.tile_position(), shore + dir, "Pisa la playa")
	assert_eq(FieldActions.transport(), &"walk", "Al pisar tierra vuelve a andar")
