extends SceneTree
## Sustituye módulos incompletos sin mover puertas, interiores ni apariciones.
## Uso: godot --headless --path . -s res://maps/_tools/completar_casas.gd

func _initialize() -> void:
	await process_frame
	var raw := JsonFile.read_dict(ExteriorTiles.OBJECTS_JSON)
	var complete := ExteriorTiles.objects()
	var replacements := {}
	for id: StringName in ExteriorTiles.COMPLETE_HOUSES:
		var old: Dictionary = raw[str(id)]
		replacements[Vector3i(old.source, old.coords[0], old.coords[1])] = id
	var count := 0
	for path: String in _scenes("res://maps"):
		if not FileAccess.get_file_as_string(path).contains(ExteriorTiles.TILESET):
			continue
		var packed := load(path) as PackedScene
		if packed == null:
			continue
		var root := packed.instantiate()
		var changed := false
		for node: Node in root.find_children("*", "TileMapLayer", true, false):
			var layer := node as TileMapLayer
			if layer.tile_set != load(ExteriorTiles.TILESET):
				continue
			var changes: Array[Array] = []
			for at: Vector2i in layer.get_used_cells():
				var coords := layer.get_cell_atlas_coords(at)
				var key := Vector3i(layer.get_cell_source_id(at), coords.x, coords.y)
				if not replacements.has(key):
					continue
				var id: StringName = replacements[key]
				var old: Dictionary = raw[str(id)]
				var house: Dictionary = complete[id]
				var door := at + Vector2i(old.door[0], old.door[1])
				var anchor: Vector2i = door - house.door
				if anchor != at and layer.get_cell_source_id(anchor) >= 0:
					push_error("Ancla ocupada: %s %s" % [path, anchor])
					quit(1)
					return
				changes.append([at, anchor, house])
			for change: Array in changes:
				layer.erase_cell(change[0])
			for change: Array in changes:
				var house: Dictionary = change[2]
				layer.set_cell(change[1], house.source, house.coords)
				changed = true
				count += 1
		if changed:
			var result := PackedScene.new()
			var error := result.pack(root)
			if error == OK:
				error = ResourceSaver.save(result, path)
			if error != OK:
				push_error("%s: %s" % [path, error_string(error)])
				quit(1)
				return
			print(path)
		root.free()
	print("Casas completas: ", count)
	quit()


func _scenes(folder: String) -> Array[String]:
	var result: Array[String] = []
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".tscn"):
			result.append(folder.path_join(file))
	for child: String in DirAccess.get_directories_at(folder):
		result.append_array(_scenes(folder.path_join(child)))
	return result
