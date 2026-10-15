extends SceneTree
## Pone una pieza del tileset exterior (assets/tilesets/exterior/objetos.json) en la capa Entities/Objects de
## un mapa ya pintado, sin repintarlo (repintar desde su script borraría las puertas enlazadas). La casilla
## es la del ancla de la pieza (abajo a la izquierda, como en los pintores). Si la casilla ya tiene esa pieza,
## no hace nada. Para su puerta, después: maps/_tools/enlazar_puerta.gd.
## Uso: godot --headless --path . -s res://maps/_tools/poner_pieza.gd -- <mapa> <pieza> <x> <y>
## Ejemplo: -- madrid/centro boca_metro 48 35

const OBJECTS := "res://assets/tilesets/exterior/objetos.json"


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 4:
		push_error("poner_pieza: faltan argumentos (mapa, pieza, x, y).")
		quit(2)
		return
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OBJECTS))
	if not catalog.has(a[1]):
		push_error("poner_pieza: no existe la pieza %s en objetos.json." % a[1])
		quit(1)
		return
	var piece: Dictionary = catalog[a[1]]
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	var objects := map.get_node(^"Entities/Objects") as TileMapLayer
	var at := Vector2i(int(a[2]), int(a[3]))
	var coords := Vector2i(int(piece["coords"][0]), int(piece["coords"][1]))
	if objects.get_cell_source_id(at) == int(piece["source"]) and objects.get_cell_atlas_coords(at) == coords:
		print("%s: ya tenía %s en %s." % [a[0], a[1], at])
		map.free()
		quit()
		return
	objects.set_cell(at, int(piece["source"]), coords)
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: %s en %s (%s)." % [a[0], a[1], at, error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
