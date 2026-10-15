extends SceneTree
## Inventario de puertas e interiores: escribe un JSON con cada mapa, sus puertas
## (pieza de la fachada, destino y aparición) y, en los interiores, suelo, pared,
## muebles, personajes, carteles y rótulo. Solo lee; no cambia ningún mapa.
## En los scripts sueltos no hay autoloads: no se usan MapRoot, NPC ni MapSign como tipos.
## Uso: godot --headless --path . -s res://maps/_tools/inventario_interiores.gd -- <salida.json> [prefijo ...]

var _catalog: Dictionary = {}
var _by_cell: Dictionary = {}


func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var out_path := "/tmp/inventario_interiores.json" if args.is_empty() else args[0]
	var prefixes := PackedStringArray()
	for i: int in range(1, args.size()):
		prefixes.append(args[i])
	_catalog = ExteriorTiles.objects()
	for id: StringName in _catalog:
		var o: Dictionary = _catalog[id]
		var key := "%s:%s" % [o["source"], o["coords"]]
		if not _by_cell.has(key):
			_by_cell[key] = String(id)
	var ids: Array[String] = []
	_collect("res://maps/", ids)
	ids.sort()
	var maps := {}
	for id: String in ids:
		if id.begins_with("_") or id.begins_with("test/") or id.begins_with("muestras/"):
			continue
		if not prefixes.is_empty():
			var keep := false
			for prefix: String in prefixes:
				if id.begins_with(prefix):
					keep = true
			if not keep:
				continue
		var packed := load("res://maps/%s.tscn" % id) as PackedScene
		if packed == null:
			continue
		var root := packed.instantiate()
		if root.get(&"data") == null:
			root.free()
			continue
		maps[id] = _describe(root)
		root.free()
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"maps": maps}, "", true))
	file.close()
	print("inventario: %d mapas en %s" % [maps.size(), out_path])
	quit()


func _collect(dir_path: String, out: Array[String]) -> void:
	for entry: String in ResourceLoader.list_directory(dir_path):
		if entry.ends_with("/"):
			if entry.begins_with("_"):
				continue
			_collect(dir_path + entry, out)
		elif entry.ends_with(".tscn"):
			out.append((dir_path + entry).trim_prefix("res://maps/").get_basename())


func _describe(map: Node) -> Dictionary:
	var data: Resource = map.get(&"data")
	var outdoor := bool(data.get(&"outdoor"))
	var info := {
		"outdoor": outdoor,
		"display_name": str(data.get(&"display_name")),
		"zone": str(data.get(&"zone_id")),
		"size": [0, 0],
		"warps": [],
		"spawns": {},
		"entities": [],
		"rotulo": "",
	}
	var ground := map.get_node_or_null(^"Ground") as TileMapLayer
	if ground != null:
		var used := ground.get_used_rect()
		info["size"] = [used.size.x, used.size.y]
		info["origin"] = [used.position.x, used.position.y]
		if not outdoor:
			var floors := {}
			for cell: Vector2i in ground.get_used_cells():
				var atlas := ground.get_cell_atlas_coords(cell)
				var k := "%d:%d,%d" % [ground.get_cell_source_id(cell), atlas.x, atlas.y]
				floors[k] = int(floors.get(k, 0)) + 1
			info["floors"] = floors
	var decor := map.get_node_or_null(^"Decor") as TileMapLayer
	if decor != null and not outdoor:
		var cells: Array = []
		for cell: Vector2i in decor.get_used_cells():
			var atlas := decor.get_cell_atlas_coords(cell)
			cells.append([cell.x, cell.y, decor.get_cell_source_id(cell), atlas.x, atlas.y, decor.get_cell_alternative_tile(cell)])
		cells.sort()
		info["decor"] = cells
	var objects := map.get_node_or_null(^"Entities/Objects") as TileMapLayer
	var warps := map.get_node_or_null(^"Warps")
	if warps != null:
		for warp: Node in warps.get_children():
			if not warp is Node2D or warp.get(&"target_map") == null:
				continue
			var tile := Grid.to_tile((warp as Node2D).position)
			var wsize: Vector2i = warp.get(&"size")
			var entry := {
				"name": String(warp.name),
				"tile": [tile.x, tile.y],
				"size": [wsize.x, wsize.y],
				"target_map": str(warp.get(&"target_map")),
				"target_spawn": str(warp.get(&"target_spawn")),
			}
			if outdoor and objects != null:
				entry["piece"] = _piece_with_door(objects, tile)
			(info["warps"] as Array).append(entry)
	var spawns := map.get_node_or_null(^"Spawns")
	if spawns != null:
		for child: Node in spawns.get_children():
			if child is Node2D:
				var t := Grid.to_tile((child as Node2D).position)
				info["spawns"][String(child.name)] = [t.x, t.y]
	var entities := map.get_node_or_null(^"Entities")
	if entities != null:
		for child: Node in entities.get_children():
			if child is TileMapLayer or not child is Node2D:
				continue
			var t := Grid.to_tile((child as Node2D).position)
			var e := {"name": String(child.name), "tile": [t.x, t.y]}
			var script := child.get_script() as Script
			e["script"] = script.resource_path if script != null else ""
			for prop: String in ["display_name", "trainer_id", "art_id"]:
				var v: Variant = child.get(prop)
				if v != null and str(v) != "":
					e[prop] = str(v)
			var sheet: Variant = child.get("sprite_sheet")
			if sheet is Texture2D:
				e["sheet"] = (sheet as Texture2D).resource_path.get_file().get_basename()
			var lines: Variant = child.get("lines")
			if lines is PackedStringArray and not (lines as PackedStringArray).is_empty():
				e["lines"] = Array(lines as PackedStringArray)
			var ev: Variant = child.get("event")
			if ev is Script:
				e["event"] = (ev as Script).resource_path
				var params: Variant = child.get("event_params")
				if params is Dictionary:
					e["event_params"] = params
			(info["entities"] as Array).append(e)
	var rotulo := map.get_node_or_null(^"Rotulo") as Label
	if rotulo != null:
		info["rotulo"] = rotulo.text
	return info


## Pieza de la fachada cuya puerta cae en `door` (busca la casilla de abajo a la izquierda del objeto).
func _piece_with_door(objects: TileMapLayer, door: Vector2i) -> String:
	for dy: int in range(-1, 6):
		for dx: int in range(-12, 1):
			var cell := door + Vector2i(dx, dy)
			var source := objects.get_cell_source_id(cell)
			if source < 0:
				continue
			var key := "%s:%s" % [source, objects.get_cell_atlas_coords(cell)]
			if not _by_cell.has(key):
				continue
			var id: String = _by_cell[key]
			var offset: Vector2i = _catalog[StringName(id)]["door"]
			if offset.x >= 0 and cell + offset == door:
				return id
	return ""
