extends SceneTree
## Diagnóstico de composición: física real a pie y coste mínimo de casillas de encuentro.
## No modifica mapas ni decide la aprobación del arte. Sin Surf, saltos, puertas ni cambios de mapa.
## godot --headless --path . -s res://tools/mundo/auditar_composicion.gd -- <salida.json> <mapa>...
const DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const MASK := 1 | 2 | 8

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Se requiere salida JSON y al menos un mapa")
		quit(2)
		return
	for i: int in range(1,args.size()):
		if not ResourceLoader.exists("res://maps/%s.tscn" % args[i]):
			push_error("No existe el mapa %s" % args[i])
			quit(2)
			return
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	var manager := root.get_node("SceneManager")
	manager.register_main(main)
	var loader = load("res://src/util/map_loader.gd")
	root.get_node("GameState").reset()
	var rows := []
	for i: int in range(1,args.size()):
		var path := "res://maps/%s.tscn" % args[i]
		var prepared: Dictionary = loader.prepare(StringName(args[i]))
		if prepared.error != OK:
			push_error("No se puede preparar %s" % path)
			quit(2)
			return
		var map = prepared.map
		root.add_child(map)
		await physics_frame
		await physics_frame
		var row := _audit(map,args[i])
		rows.append(row)
		print(JSON.stringify(row))
		map.free()
		await physics_frame
	var revision := []
	OS.execute("git",["rev-parse","HEAD"],revision)
	var output := {"revision":String(revision[0]).strip_edges() if not revision.is_empty() else "desconocida","godot":Engine.get_version_info().string,"mask":MASK,"metodo":"Física a pie con MapLoader y estado inicial (incluye colocaciones y restricciones dinámicas disponibles). Cada pareja de bordes se prueba en ambos sentidos. El coste cuenta casillas de encuentro, no combates. Sin Surf, saltos ni eventos; sin abandonar el mapa.","maps":rows}
	var f := FileAccess.open(args[0],FileAccess.WRITE)
	if f == null:
		push_error("No se puede escribir %s" % args[0])
		quit(2)
		return
	f.store_string(JSON.stringify(output,"\t")+"\n")
	f.close()
	loader.clear()
	manager._leave_game()
	main.queue_free()
	await process_frame
	await process_frame
	quit.call_deferred()

func _audit(map: Variant,id: String) -> Dictionary:
	var ground: TileMapLayer = map.get_node("Ground")
	var bounds := ground.get_used_rect()
	var free := {}
	var grass := {}
	var q := PhysicsPointQueryParameters2D.new()
	q.collision_mask = MASK
	q.collide_with_areas = false
	var space: PhysicsDirectSpaceState2D = map.get_world_2d().direct_space_state
	var max_square := 0
	var square_at := Vector2i.ZERO
	var squares := {}
	for y: int in range(bounds.position.y,bounds.end.y):
		for x: int in range(bounds.position.x,bounds.end.x):
			var t := Vector2i(x,y)
			if ground.get_cell_source_id(t) < 0:
				continue
			q.position = map.to_global(Grid.to_world(t))
			if not space.intersect_point(q,1).is_empty():
				continue
			free[t] = true
			if map.is_encounter_tile(t):
				grass[t] = true
			else:
				var s := 1 + mini(int(squares.get(t+Vector2i.LEFT,0)),mini(int(squares.get(t+Vector2i.UP,0)),int(squares.get(t+Vector2i(-1,-1),0))))
				squares[t] = s
				if s > max_square:
					max_square = s
					square_at = t - Vector2i(s-1,s-1)
	var doors := []
	var objects: TileMapLayer = map.get_node("Entities/Objects")
	var catalog: Dictionary = load("res://assets/tilesets/exterior/exterior_tiles.gd").objects()
	var keys := {}
	var ids := {}
	var cropped := []
	for key: StringName in catalog:
		var entry: Dictionary = catalog[key]
		if entry.door.x >= 0:
			keys["%d:%s" % [entry.source,entry.coords]] = entry
			ids["%d:%s" % [entry.source,entry.coords]] = String(key)
	for t: Vector2i in objects.get_used_cells():
		var key := "%d:%s" % [objects.get_cell_source_id(t),objects.get_cell_atlas_coords(t)]
		if keys.has(key):
			var tile: Vector2i = t + keys[key].door
			var warp = map.warp_at(tile)
			var footprint := Rect2i(t-Vector2i(0,keys[key].size.y-1),keys[key].size)
			if not bounds.encloses(footprint):
				cropped.append({"building":ids[key],"anchor":[t.x,t.y],"visual_bounds":[footprint.position.x,footprint.position.y,footprint.size.x,footprint.size.y]})
			doors.append({"building":ids[key],"tile":[tile.x,tile.y],"linked":warp != null,"target":String(warp.target_map) if warp != null else ""})
	var edges := []
	for connection: Resource in map.data.connections:
		var tiles: Array[Vector2i] = []
		for t: Vector2i in free:
			var exit_tile := t
			match connection.edge:
				"north": exit_tile.y -= 1
				"south": exit_tile.y += 1
				"west": exit_tile.x -= 1
				"east": exit_tile.x += 1
			if connection.matches(exit_tile,bounds):
				tiles.append(t)
		edges.append({"edge":connection.edge,"target":String(connection.target_map),"tiles":tiles})
	var paths := []
	for i: int in edges.size():
		var costs := minimum_encounters(free,grass,edges[i].tiles)
		for j: int in edges.size():
			if i == j:
				continue
			var min_cost := -1
			for t: Vector2i in edges[j].tiles:
				if costs.has(t) and (min_cost < 0 or int(costs[t]) < min_cost):
					min_cost = int(costs[t])
			paths.append({"from":edges[i].target,"to":edges[j].target,"min_encounter_tiles":min_cost,"reachable":min_cost >= 0,"grass_avoidable":min_cost == 0})
	var edge_summary := []
	for e: Dictionary in edges:
		edge_summary.append({"edge":e.edge,"target":e.target,"walkable_edge_tiles":e.tiles.size()})
	var linked := 0
	for d: Dictionary in doors:
		linked += int(d.linked)
	return {"map":id,"size":[bounds.size.x,bounds.size.y],"walkable":free.size(),"walkable_percent":snappedf(100.0*free.size()/bounds.get_area(),0.1),"walkable_encounter_tiles":grass.size(),"largest_open_square":{"side":max_square,"at":[square_at.x,square_at.y]},"doors":doors.size(),"linked_doors":linked,"cropped_buildings":cropped,"connections":edge_summary,"edge_paths":paths,"scene_sha256":FileAccess.get_sha256("res://maps/%s.tscn" % id)}

static func minimum_encounters(free: Dictionary,grass: Dictionary,starts: Array[Vector2i]) -> Dictionary:
	var costs := {}
	var queue: Array[Vector2i] = []
	for t: Vector2i in starts:
		if free.has(t):
			costs[t] = 1 if grass.has(t) else 0
			queue.append(t)
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := t + d
			if not free.has(n):
				continue
			var extra := 1 if grass.has(n) else 0
			var next := int(costs[t]) + extra
			if not costs.has(n) or next < int(costs[n]):
				costs[n] = next
				if extra == 0:
					queue.push_front(n)
				else:
					queue.push_back(n)
	return costs
