extends SceneTree
## Comprueba a dónde se llega andando en un mapa pintado: desde una aparición, recorre las casillas
## libres (la misma consulta de física que usan los personajes, Character.is_tile_free) y avisa de
## las puertas de los edificios, los bordes con conexión, los carteles y los personajes a los que
## no se llega. Los bordillos cuentan como pared (no salta); el agua también, salvo con --surf.
## Uso: godot --headless --path . -s res://maps/_tools/alcance.gd -- <id del mapa> [aparición] [--surf]
## Ejemplo: -- madrid/moncloa default

const BLOCKING_MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func _initialize() -> void:
	await process_frame
	var args := Array(OS.get_cmdline_user_args())
	if args.is_empty():
		push_error("alcance: falta el id del mapa.")
		quit(2)
		return
	var map_id := StringName(args[0])
	var surf := "--surf" in args
	args = args.filter(func(a: String) -> bool: return a != "--surf")
	var spawn_name := StringName(args[1]) if args.size() > 1 else &"default"
	var mask := BLOCKING_MASK & ~8 if surf else BLOCKING_MASK
	var scene: PackedScene = load("res://maps/%s.tscn" % map_id)
	var map: Node2D = scene.instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	var ground: TileMapLayer = map.get_node("Ground")
	var bounds := ground.get_used_rect()
	var start := Grid.to_tile((map.get_node("Spawns").get_node(String(spawn_name)) as Node2D).position)
	var free := func(tile: Vector2i) -> bool:
		if not bounds.has_point(tile):
			return false
		var q := PhysicsPointQueryParameters2D.new()
		q.position = map.to_global(Grid.to_world(tile))
		q.collision_mask = mask
		q.collide_with_areas = false
		return space.intersect_point(q, 1).is_empty()
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := t + d
			if not seen.has(n) and free.call(n):
				seen[n] = true
				queue.append(n)
	print("%s: %d casillas a las que se llega desde '%s' %s." % [map_id, seen.size(), spawn_name, start])
	var problems := 0
	# Puertas de los edificios (casilla de la puerta de cada objeto con puerta).
	var catalog := ExteriorTiles.objects()
	var by_tile := {}
	for id: StringName in catalog:
		by_tile["%d:%s" % [catalog[id]["source"], catalog[id]["coords"]]] = id
	var objects: TileMapLayer = map.get_node("Entities/Objects")
	var doors := 0
	for cell: Vector2i in objects.get_used_cells():
		var key := "%d:%s" % [objects.get_cell_source_id(cell), objects.get_cell_atlas_coords(cell)]
		if not by_tile.has(key):
			continue
		var o: Dictionary = catalog[by_tile[key]]
		var door: Vector2i = o["door"]
		if door.x < 0:
			continue
		var at := cell + door
		doors += 1
		if not seen.has(at):
			problems += 1
			print("  NO se llega a la puerta de %s en %s" % [by_tile[key], at])
	print("  %d puertas comprobadas" % doors)
	# Personajes y carteles: hace falta llegar a una casilla de al lado.
	for node: Node in map.get_node("Entities").get_children():
		if node == objects or not node is Node2D:
			continue
		var t := Grid.to_tile((node as Node2D).position)
		var near := false
		for d: Vector2i in DIRS:
			near = near or seen.has(t + d)
		if not near:
			problems += 1
			print("  NO se llega a %s en %s" % [node.name, t])
	# Bordes con conexión.
	for c: Resource in map.get(&"data").connections:
		var count := 0
		for t: Vector2i in seen:
			var along := t.y if c.edge in ["east", "west"] else t.x
			if c.span != Vector2i.ZERO and (along < c.span.x or along >= c.span.y):
				continue
			if (c.edge == "north" and t.y == bounds.position.y) or (c.edge == "south" and t.y == bounds.end.y - 1) \
					or (c.edge == "west" and t.x == bounds.position.x) or (c.edge == "east" and t.x == bounds.end.x - 1):
				count += 1
		print("  borde %s → %s: %d casillas de salida" % [c.edge, c.target_map, count])
		if count == 0:
			problems += 1
	print("%d problemas." % problems)
	map.queue_free()
	quit(1 if problems > 0 else 0)
