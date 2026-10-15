extends SceneTree
## Calcula la casilla de cada personaje de data/personajes_en_el_mapa.json: la libre y alcanzable más
## cercana a su "cerca", que no esté en hierba alta, ni en una puerta o pasarela (ni al lado), ni en
## el borde del mapa, ni en un pasillo estrecho, y que no deje sin camino ninguna casilla a la que
## antes se llegaba. Escribe "casilla" en el JSON. Rehazlo si cambia un mapa. Las entradas con "fija": true
## conservan su casilla (las obras que cortan un borde, por ejemplo).
## Uso: godot --headless --path . -s res://maps/_tools/colocar_personajes.gd

const DATA := "res://data/personajes_en_el_mapa.json"
const BLOCKING_MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func _initialize() -> void:
	await process_frame
	var doc := JsonFile.read_dict(DATA)
	var entries: Array = doc.get("colocados", [])
	var maps := {}
	for entry: Dictionary in entries:
		maps[str(entry["mapa"])] = true
	var problems := 0
	for map_id: String in maps:
		problems += await _place_in(map_id, entries.filter(func(e: Dictionary) -> bool: return e["mapa"] == map_id))
	var file := FileAccess.open(DATA, FileAccess.WRITE)
	file.store_string(JSON.stringify(doc, " ", false) + "\n")
	file.close()
	print("colocar_personajes: %d personajes en %d mapas, %d problemas." % [entries.size(), maps.size(), problems])
	quit(1 if problems > 0 else 0)


func _place_in(map_id: String, entries: Array) -> int:
	var scene := load("res://maps/%s.tscn" % map_id) as PackedScene
	if scene == null:
		print("  ✗ no existe el mapa %s" % map_id)
		return entries.size()
	# Sin tipar: en un script suelto MapRoot no compila (le faltan los autoloads), como en alcance.gd.
	var map: Node2D = scene.instantiate()
	# Los nodos que sustituye un personaje ("sustituye") le dejan su sitio: fuera antes de medir.
	for entry: Dictionary in entries:
		var replaced := map.get_node_or_null("Entities/" + str(entry.get("sustituye", "-")))
		if replaced != null:
			replaced.free()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	var ground: TileMapLayer = map.get_node("Ground")
	var bounds := ground.get_used_rect()
	# Casillas libres (la misma consulta de física que el alcance de los mapas).
	var free := {}
	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			var q := PhysicsPointQueryParameters2D.new()
			q.position = map.to_global(Grid.to_world(Vector2i(x, y)))
			q.collision_mask = BLOCKING_MASK
			if space.intersect_point(q, 1).is_empty():
				free[Vector2i(x, y)] = true
	# Prohibidas: puertas y pasarelas con su alrededor, los bordes y los personajes que ya hay.
	var banned := {}
	var catalog := ExteriorTiles.objects()
	var by_tile := {}
	for id: StringName in catalog:
		by_tile["%d:%s" % [catalog[id]["source"], catalog[id]["coords"]]] = id
	var objects: TileMapLayer = map.get_node("Entities/Objects")
	var hot: Array[Vector2i] = []
	for cell: Vector2i in objects.get_used_cells():
		var key := "%d:%s" % [objects.get_cell_source_id(cell), objects.get_cell_atlas_coords(cell)]
		if by_tile.has(key) and Vector2i(catalog[by_tile[key]]["door"]).x >= 0:
			hot.append(cell + Vector2i(catalog[by_tile[key]]["door"]))
	for warp: Node in map.get_node("Warps").get_children():
		hot.append(Grid.to_tile((warp as Node2D).position))
	for node: Node in map.get_node("Entities").get_children():
		if node is Node2D and node != objects:
			hot.append(Grid.to_tile((node as Node2D).position))
	for c: Vector2i in hot:
		for dy: int in range(-1, 3):
			for dx: int in range(-1, 2):
				banned[c + Vector2i(dx, dy)] = true
	var start := Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)
	var reach := _reach(start, free, {})
	var taken := {}
	var problems := 0
	for entry: Dictionary in entries:
		if bool(entry.get("fija", false)):
			taken[Vector2i(int(entry["casilla"][0]), int(entry["casilla"][1]))] = true
			continue
		var target := Vector2i(int(entry["cerca"][0]), int(entry["cerca"][1]))
		var candidates: Array = reach.keys().filter(func(c: Vector2i) -> bool:
			return not banned.has(c) and not taken.has(c) and c.x > bounds.position.x and c.y > bounds.position.y \
				and c.x < bounds.end.x - 1 and c.y < bounds.end.y - 1 and _terrain(ground, c) != "tall_grass" \
				and DIRS.filter(func(d: Vector2i) -> bool: return free.has(c + d) and not taken.has(c + d)).size() >= 3)
		candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			var da := absi(a.x - target.x) + absi(a.y - target.y)
			var db := absi(b.x - target.x) + absi(b.y - target.y)
			return da < db or (da == db and (a.y < b.y or (a.y == b.y and a.x < b.x))))
		var chosen := Vector2i(-1, -1)
		for c: Vector2i in candidates.slice(0, 40):
			var blocked := taken.duplicate()
			blocked[c] = true
			if _reach(start, free, blocked).size() == reach.size() - blocked.size():
				chosen = c
				break
		if chosen.x < 0:
			print("  ✗ %s: no hay sitio cerca de %s en %s" % [entry["id"], target, map_id])
			problems += 1
			continue
		taken[chosen] = true
		entry["casilla"] = [chosen.x, chosen.y]
		print("  %s → %s %s (pedido %s)" % [entry["id"], map_id, chosen, target])
	map.queue_free()
	await process_frame
	return problems


func _terrain(ground: TileMapLayer, cell: Vector2i) -> String:
	var data := ground.get_cell_tile_data(cell)
	return str(data.get_custom_data("terrain")) if data else ""


func _reach(start: Vector2i, free: Dictionary, blocked: Dictionary) -> Dictionary:
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := t + d
			if not seen.has(n) and free.has(n) and not blocked.has(n):
				seen[n] = true
				queue.append(n)
	return seen
