extends SceneTree
## Vuelca un mapa pintado en texto, una letra por casilla, para planear dónde poner cosas sin
## abrir el editor. Usa la misma consulta de física que los personajes.
## Uso: godot --headless --path . -s res://maps/_tools/mapa_ascii.gd -- <id del mapa> [salida.txt]
## Leyenda: . hierba · , hierba alta · : camino · _ baldosa · s arena · * nieve · + escalera
## ~ agua · T bosque · Y árbol suelto · H edificio · # otro obstáculo · ^ pared de meseta · v bordillo
## D puerta · W pasarela · @ aparición default · N vecino · E entrenador · C cartel · O objeto
## P personaje colocado por datos (data/personajes_en_el_mapa.json).

const BLOCKING_MASK := 1 | 2 | 8


func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var map_id := args[0]
	var map: Node2D = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	var ground: TileMapLayer = map.get_node("Ground")
	var decor: TileMapLayer = map.get_node("Decor")
	var objects: TileMapLayer = map.get_node("Entities/Objects")
	var bounds := ground.get_used_rect()
	var catalog := ExteriorTiles.objects()
	var by_tile := {}
	for id: StringName in catalog:
		by_tile[Vector3i(catalog[id].source, catalog[id].coords.x, catalog[id].coords.y)] = id
	var marks := {}
	# Huella visible de cada objeto: casa (H) o árbol/adorno (T/#).
	for cell: Vector2i in objects.get_used_cells():
		var c := objects.get_cell_atlas_coords(cell)
		var id: StringName = by_tile.get(Vector3i(objects.get_cell_source_id(cell), c.x, c.y), &"")
		if id == &"":
			continue
		var o: Dictionary = catalog[id]
		var letter := "Y" if o.source == ExteriorTiles.SRC_ARBOLES else ("#" if o.source in [ExteriorTiles.SRC_ADORNOS, ExteriorTiles.SRC_VALLAS] else "H")
		for f: Vector2i in o.footprint:
			marks[cell + f] = letter
		if o.door.x >= 0:
			marks[cell + o.door] = "D"
	for warp: Node in map.get_node("Warps").get_children():
		var t := Grid.to_tile((warp as Node2D).position)
		if not marks.has(t) or marks[t] != "D":
			marks[t] = "W"
	for node: Node in map.get_node("Entities").get_children():
		if node == objects or not node is Node2D:
			continue
		var t := Grid.to_tile((node as Node2D).position)
		var letter := "N"
		if node.get("trainer_id") != null:
			letter = "E"
		elif node.get("item_id") != null:
			letter = "O"
		elif node.scene_file_path.ends_with("sign.tscn"):
			letter = "C"
		marks[t] = letter
	for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
		if entry.get("mapa", "") == map_id and entry.has("casilla"):
			marks[Vector2i(int(entry.casilla[0]), int(entry.casilla[1]))] = "P"
	marks[Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)] = "@"
	var lines: PackedStringArray = []
	lines.append("%s · %s (origen %s)" % [map_id, bounds.size, bounds.position])
	for c: Resource in map.get(&"data").connections:
		lines.append("  borde %s → %s, tramo %s" % [c.edge, c.target_map, c.span])
	var header := "    "
	var header2 := "    "
	for x: int in range(bounds.position.x, bounds.end.x):
		header += str(posmod(x / 10, 10)) if x % 10 == 0 else " "
		header2 += str(posmod(x, 10))
	lines.append(header)
	lines.append(header2)
	for y: int in range(bounds.position.y, bounds.end.y):
		var row := "%3d " % y
		for x: int in range(bounds.position.x, bounds.end.x):
			var at := Vector2i(x, y)
			if marks.has(at):
				row += marks[at]
				continue
			var q := PhysicsPointQueryParameters2D.new()
			q.position = map.to_global(Grid.to_world(at))
			q.collision_mask = BLOCKING_MASK
			var hit := space.intersect_point(q, 1)
			var data := ground.get_cell_tile_data(at)
			var terrain := str(data.get_custom_data("terrain")) if data else ""
			var deco := decor.get_cell_tile_data(at)
			var dterrain := str(deco.get_custom_data("terrain")) if deco else ""
			if hit.is_empty():
				if dterrain == "stairs":
					row += "+"
				else:
					row += {"tall_grass": ",", "path": ":", "stone": "_", "sand": "s", "snow": "*", "stairs": "+"}.get(terrain, ".")
			else:
				if terrain == "water" or dterrain == "water":
					row += "~"
				elif dterrain == "tree":
					row += "T"
				elif dterrain == "cliff":
					row += "^"
				elif dterrain == "ledge_down":
					row += "v"
				else:
					row += "#"
		lines.append(row)
	var text := "\n".join(lines) + "\n"
	if args.size() > 1:
		var f := FileAccess.open(args[1], FileAccess.WRITE)
		f.store_string(text)
		f.close()
	else:
		print(text)
	map.queue_free()
	quit()
