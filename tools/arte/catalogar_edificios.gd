extends Node
## Inventario de fuentes y colocaciones. No pinta mapas ni altera recursos del juego.
## Uso: godot --headless --path . res://tools/arte/catalogar_edificios.tscn -- <informe.json>

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var output := args[0] if not args.is_empty() else "/tmp/edificios-inventario.json"
	var catalog := ExteriorTiles.objects()
	var sources := JsonFile.read_dict("res://assets/tilesets/exterior/hecho_a_mano/piezas.json")
	var by_tile := {}
	var entries := {}
	var tileset := load(ExteriorTiles.TILESET) as TileSet
	var captures := args[1] if args.size() > 1 else ""
	if captures != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(captures))
	for id: StringName in catalog:
		var piece: Dictionary = catalog[id]
		var key := "%d:%s" % [piece.source, piece.coords]
		by_tile[key] = String(id)
		if sources.has(String(id)) or id in [&"casa_madera", &"casa_tejado_rojo", &"faro"]:
			entries[String(id)] = {"source": piece.source, "size": [piece.size.x, piece.size.y], "door": [piece.door.x, piece.door.y], "file": piece.file, "footprint": piece.footprint, "placements": []}
			if captures != "":
				var source := tileset.get_source(int(piece.source)) as TileSetAtlasSource
				if source == null:
					push_error("Fuente de atlas ausente: %s" % id)
					get_tree().quit(1)
					return
				var atlas := source.texture.get_image()
				var rect := Rect2i(piece.coords * 32, piece.size * 32)
				if not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(rect):
					push_error("Recorte fuera de la hoja: %s" % id)
					get_tree().quit(1)
					return
				var result := atlas.get_region(rect).save_png(captures + "/" + String(id) + ".png")
				if result != OK:
					push_error("No se puede capturar %s" % id)
					get_tree().quit(1)
					return
	var paths := PackedStringArray()
	_list_maps("res://maps", paths)
	for path: String in paths:
		if path.contains("/_"):
			continue
		var packed := load(path) as PackedScene
		if packed == null:
			continue
		var map: Node = packed.instantiate()
		var ground := map.get_node_or_null(^"Ground") as TileMapLayer
		var objects := map.get_node_or_null(^"Entities/Objects") as TileMapLayer
		if ground == null or objects == null:
			map.free()
			continue
		var bounds := ground.get_used_rect()
		var map_id := path.trim_prefix("res://maps/").trim_suffix(".tscn")
		for cell: Vector2i in objects.get_used_cells():
			var key := "%d:%s" % [objects.get_cell_source_id(cell), objects.get_cell_atlas_coords(cell)]
			var id := String(by_tile.get(key, ""))
			if not entries.has(id):
				continue
			var piece: Dictionary = catalog[StringName(id)]
			var visual := Rect2i(cell - Vector2i(0, piece.size.y - 1), piece.size)
			var warps := []
			var parent := map.get_node_or_null(^"Warps")
			if parent != null:
				for warp: Node2D in parent.get_children():
					if Grid.to_tile(warp.position) == cell + piece.door:
						warps.append({"name": String(warp.name), "target_map": String(warp.get(&"target_map")), "target_spawn": String(warp.get(&"target_spawn"))})
			entries[id].placements.append({"map": map_id, "anchor": [cell.x, cell.y], "map_size": [bounds.size.x, bounds.size.y], "visual_bounds": [visual.position.x, visual.position.y, visual.size.x, visual.size.y], "cropped": not bounds.encloses(visual), "warps": warps})
		map.free()
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		push_error("No se puede escribir el inventario")
		get_tree().quit(1)
		return
	file.store_string(JSON.stringify({"pieces": entries}, "\t") + "\n")
	file.close()
	print("Inventario: %d piezas, %d escenas recorridas → %s" % [entries.size(), paths.size(), output])
	get_tree().quit()

func _list_maps(folder: String, into: PackedStringArray) -> void:
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".tscn"):
			into.append(folder + "/" + file)
	for subdir: String in DirAccess.get_directories_at(folder):
		if not subdir.begins_with("_"):
			_list_maps(folder + "/" + subdir, into)
