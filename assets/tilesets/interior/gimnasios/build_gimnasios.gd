extends SceneTree
## Tileset de los gimnasios (docs/arte/gimnasios.md). Nunca dibuja arte: recorta franjas del PNG público
## de Akizakura16 (el mismo de assets/tilesets/interior/, ver docs/arte/interiores.md) y monta el TileSet.
## Las fuentes 0–3 son las de interior.tres (mismas casillas: suelos, paredes, muebles y mostradores), así
## que lo que ya se pinta con ellas sirve igual; las 4–8 son franjas nuevas del mismo PNG.
## Uso (en este orden):
##   godot --headless --path . -s res://assets/tilesets/interior/gimnasios/build_gimnasios.gd -- --png=<akizakura16.png>
##   godot --headless --path . --import
##   godot --headless --path . -s res://assets/tilesets/interior/gimnasios/build_gimnasios.gd

const BASE := "res://assets/tilesets/interior/"
const OUT := "res://assets/tilesets/interior/gimnasios/"
const ORIGINAL_SHA256 := "6545d9297c81b6786ebc2ceda1ed43886632b8e444c6d5c6ac64371d49e22039"
## Fuente → [archivo, franja del PNG original (solo las nuevas), qué se puede pisar].
## "suelo": se pisa todo; "solido": choca todo; o una lista de filas [desde, hasta) que se pisan.
const SOURCES := [
	["suelos.png", Rect2i(), "suelo"],
	["paredes.png", Rect2i(), "solido"],
	["muebles.png", Rect2i(), "solido"],
	["mostradores.png", Rect2i(), "solido"],
	["gimnasios/suelos_2.png", Rect2i(0, 2048, 256, 2400), "suelo"],
	["gimnasios/paredes_2.png", Rect2i(0, 7008, 256, 3232), "solido"],
	# Alfombras, flechas, baldosas de teletransporte, puertas, escaleras y escaleras mecánicas se pisan;
	# los postes con cordón, las mamparas y la cabina (filas 48 a 63) chocan.
	["gimnasios/alfombras.png", Rect2i(0, 10240, 256, 2048), [[0, 48]]],
	["gimnasios/maquinas.png", Rect2i(0, 13440, 256, 896), "solido"],
	["gimnasios/mesas.png", Rect2i(0, 16384, 256, 672), "solido"],
]
const COUNTER_SOURCE := 3
const COUNTER_ROWS := 36
## Piezas dibujadas a mano para los gimnasios (assets/_fuentes/mundo/gim_*.px2, exportadas por
## exportar_mundo.gd a propios/): cada PNG es una fuente con su número fijo en propios.json (los mapas
## pintados lo guardan). Chocan las casillas con algo dibujado, salvo las piezas "pasable" (suelos).
const PROPIOS := "res://assets/tilesets/interior/gimnasios/propios.json"
const PROPIOS_DIR := "res://assets/tilesets/interior/gimnasios/propios/"


func _initialize() -> void:
	await process_frame
	var png := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--png="):
			png = arg.get_slice("=", 1)
	if png != "":
		_crop(png)
	else:
		_build()
	quit()


func _crop(path: String) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	var sha := HashingContext.new()
	sha.start(HashingContext.HASH_SHA256)
	sha.update(bytes)
	if sha.finish().hex_encode() != ORIGINAL_SHA256:
		push_error("No es el PNG original de Akizakura16 (SHA-256 distinto).")
		return
	var original := Image.load_from_file(path)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for entry: Array in SOURCES:
		var region: Rect2i = entry[1]
		if region.size == Vector2i.ZERO:
			continue
		var image := original.get_region(region)
		print("%s: %s" % [entry[0], error_string(image.save_png(BASE + str(entry[0])))])


func _build() -> void:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32, 32)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(0, 1)
	tiles.add_custom_data_layer()
	tiles.set_custom_data_layer_name(0, "terrain")
	tiles.set_custom_data_layer_type(0, TYPE_STRING)
	tiles.add_custom_data_layer()
	tiles.set_custom_data_layer_name(1, "walkable")
	tiles.set_custom_data_layer_type(1, TYPE_BOOL)
	for id: int in SOURCES.size():
		var entry: Array = SOURCES[id]
		var texture: Texture2D = load(BASE + str(entry[0]))
		var source := TileSetAtlasSource.new()
		source.texture = texture
		source.texture_region_size = Vector2i(32, 32)
		tiles.add_source(source, id)
		var cells := Vector2i(texture.get_size()) / 32
		for y: int in cells.y:
			for x: int in cells.x:
				source.create_tile(Vector2i(x, y))
				var tile := source.get_tile_data(Vector2i(x, y), 0)
				var walk := _walkable(entry[2], y)
				tile.set_custom_data("terrain", "indoor" if walk else ("counter" if id == COUNTER_SOURCE and y < COUNTER_ROWS else "wall"))
				tile.set_custom_data("walkable", walk)
				if not walk:
					tile.set_collision_polygons_count(0, 1)
					tile.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]))
	_hand_made(tiles)
	print("gimnasios.tres: %s" % error_string(ResourceSaver.save(tiles, OUT + "gimnasios.tres")))


func _hand_made(tiles: TileSet) -> void:
	var pieces := JsonFile.read_dict(PROPIOS)
	var used := {}
	for file: String in DirAccess.get_files_at(PROPIOS_DIR):
		if file.get_extension() != "png":
			continue
		var id := file.get_basename()
		if not pieces.has(id):
			push_error("propios/%s no está en propios.json (dale un número de fuente libre)." % file)
			continue
		var source_id := int(pieces[id]["fuente"])
		if source_id < SOURCES.size() or used.has(source_id):
			push_error("propios.json: la fuente %d de '%s' está repetida o choca con los recortes." % [source_id, id])
			continue
		used[source_id] = true
		var texture: Texture2D = load(PROPIOS_DIR + file)
		var image := Image.load_from_file(ProjectSettings.globalize_path(PROPIOS_DIR + file))
		image.convert(Image.FORMAT_RGBA8)
		var source := TileSetAtlasSource.new()
		source.texture = texture
		source.texture_region_size = Vector2i(32, 32)
		tiles.add_source(source, source_id)
		var passable := bool(pieces[id].get("pasable", false))
		var cells := Vector2i(texture.get_size()) / 32
		for y: int in cells.y:
			for x: int in cells.x:
				source.create_tile(Vector2i(x, y))
				var tile := source.get_tile_data(Vector2i(x, y), 0)
				var walk := passable or _empty(image, Rect2i(x * 32, y * 32, 32, 32))
				tile.set_custom_data("terrain", "indoor" if walk else str(pieces[id].get("terreno", "wall")))
				tile.set_custom_data("walkable", walk)
				if not walk:
					tile.set_collision_polygons_count(0, 1)
					tile.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]))


static func _empty(image: Image, rect: Rect2i) -> bool:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if image.get_pixel(x, y).a > 0.1:
				return false
	return true


static func _walkable(rule: Variant, row: int) -> bool:
	if rule is String:
		return rule == "suelo"
	for span: Array in rule:
		if row >= int(span[0]) and row < int(span[1]):
			return true
	return false
