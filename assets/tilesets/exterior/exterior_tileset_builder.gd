extends RefCounted
@warning_ignore_start("integer_division")
## Paso 2 de build_exterior.gd: crea exterior.tres con las texturas ya importadas.
## Capas (las mismas que espera MapRoot):
##   Física 0 → "paredes" (capa 1) · Física 1 → "agua" (capa 4, valor 8)
##   Custom data: terrain (String), encounter (bool), footstep_sound (String)
##   Terrenos (conjunto 0, esquinas y lados): 0 hierba alta, 1 camino

const T := 32
const OUT := "res://assets/tilesets/exterior/"
const WALL := 0
const WATER := 1


static func build() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(WALL, 1)
	ts.set_physics_layer_collision_mask(WALL, 0)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(WATER, 1 << 3)
	ts.set_physics_layer_collision_mask(WATER, 0)
	for layer: Array in [["terrain", TYPE_STRING], ["encounter", TYPE_BOOL], ["footstep_sound", TYPE_STRING]]:
		ts.add_custom_data_layer()
		var i := ts.get_custom_data_layers_count() - 1
		ts.set_custom_data_layer_name(i, layer[0])
		ts.set_custom_data_layer_type(i, layer[1])
	ts.add_terrain_set()
	ts.set_terrain_set_mode(ExteriorTiles.TERRAIN_SET, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	ts.add_terrain(ExteriorTiles.TERRAIN_SET)
	ts.set_terrain_name(ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_TALL_GRASS, "Hierba alta")
	ts.set_terrain_color(ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_TALL_GRASS, Color(0.1, 0.6, 0.2))
	ts.add_terrain(ExteriorTiles.TERRAIN_SET)
	ts.set_terrain_name(ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_PATH, "Camino")
	ts.set_terrain_color(ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_PATH, Color(0.8, 0.65, 0.3))

	_gen4(ts)
	_autotiles(ts)
	_animated(ts)
	_flora(ts)
	var objects := ExteriorTiles.objects()
	var object_files := {ExteriorTiles.SRC_CASAS: "casas.png", ExteriorTiles.SRC_ARBOLES: "arboles.png",
		ExteriorTiles.SRC_CASAS_DPPT: "casas_dppt.png", ExteriorTiles.SRC_VALLAS: "vallas.png"}
	for src_id: int in object_files:
		_objects(ts, src_id, object_files[src_id], objects)
	var err := ResourceSaver.save(ts, OUT + "exterior.tres")
	print("exterior.tres: ", error_string(err))


static func _source(ts: TileSet, id: int, file: String) -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	source.texture = load(OUT + file)
	source.texture_region_size = Vector2i(T, T)
	ts.add_source(source, id)
	return source


## Crea una casilla en cada celda del atlas que tenga algún píxel visible.
static func _create_visible_tiles(source: TileSetAtlasSource) -> void:
	var img := source.texture.get_image()
	for ty: int in img.get_height() / T:
		for tx: int in img.get_width() / T:
			if not img.get_region(Rect2i(tx * T, ty * T, T, T)).is_invisible():
				source.create_tile(Vector2i(tx, ty))


static func _tile(source: TileSetAtlasSource, coords: Vector2i, terrain: String, physics: int = -1,
		footstep: String = "") -> void:
	if not source.has_tile(coords):
		return
	var tile := source.get_tile_data(coords, 0)
	tile.set_custom_data("terrain", terrain)
	tile.set_custom_data("footstep_sound", footstep)
	if physics >= 0:
		tile.add_collision_polygon(physics)
		tile.set_collision_polygon_points(physics, tile.get_collision_polygons_count(physics) - 1,
			_square(Vector2i.ZERO))


static func _tile_rect(source: TileSetAtlasSource, rect: Rect2i, terrain: String, physics: int = -1,
		footstep: String = "") -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			_tile(source, Vector2i(x, y), terrain, physics, footstep)


static func _square(cell: Vector2i) -> PackedVector2Array:
	var c := Vector2(cell * T)
	var h := T / 2.0
	return PackedVector2Array([c + Vector2(-h, -h), c + Vector2(h, -h), c + Vector2(h, h), c + Vector2(-h, h)])


static func _gen4(ts: TileSet) -> void:
	var s := _source(ts, ExteriorTiles.SRC_GEN4, "gen4.png")
	_create_visible_tiles(s)
	for g: Vector2i in ExteriorTiles.GRASS:
		_tile(s, g, "grass", -1, "grass")
	for c: Vector2i in [ExteriorTiles.MUSHROOMS, ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL,
			ExteriorTiles.WHITE_FLOWERS, ExteriorTiles.PINK_FLOWERS]:
		_tile(s, c, "flowers", -1, "grass")
	for c: Vector2i in [ExteriorTiles.SIGN, ExteriorTiles.STUMP, ExteriorTiles.STUMP_CUT,
			ExteriorTiles.ROCK, ExteriorTiles.ROCK_BROWN]:
		_tile(s, c, "obstacle", WALL)
	for c: Vector2i in ExteriorTiles.LOG_LEFT + ExteriorTiles.LOG_RIGHT + ExteriorTiles.ROUTE_SIGN:
		_tile(s, c, "obstacle", WALL)
	# Bosque: chocan las columnas de los troncos; la 1 solo es copa que sobresale.
	var forest := ExteriorTiles.FOREST_ORIGIN
	_tile_rect(s, Rect2i(forest + Vector2i(1, 0), Vector2i(4, 6)), "tree", WALL)
	_tile_rect(s, Rect2i(forest + Vector2i(0, 1), Vector2i(1, 4)), "tree")
	_tile_rect(s, Rect2i(ExteriorTiles.SAND_PATCH, Vector2i(5, 3)), "sand", -1, "sand")
	_tile_rect(s, Rect2i(ExteriorTiles.POND, Vector2i(3, 3)), "water", WATER)
	for c: Vector2i in ExteriorTiles.LEDGE:
		_tile(s, c, "ledge_down", WALL, "grass")
	_tile_rect(s, Rect2i(ExteriorTiles.FENCE_ORIGIN, Vector2i(3, 4)), "fence", WALL)
	_tile_rect(s, Rect2i(0, 15, 7, 3), "obstacle", WALL)
	_tile_rect(s, Rect2i(ExteriorTiles.COBBLE_LIGHT, Vector2i(4, 4)), "stone", -1, "stone")
	_tile_rect(s, Rect2i(ExteriorTiles.PAVING, Vector2i(3, 3)), "stone", -1, "stone")
	_tile_rect(s, Rect2i(ExteriorTiles.PAVING_STONE, Vector2i(5, 3)), "stone", -1, "stone")
	# Meseta: solo se pisa el centro de arriba; los bordes y la pared chocan.
	var p := ExteriorTiles.PLATEAU
	_tile_rect(s, Rect2i(p, Vector2i(3, 4)), "cliff", WALL)
	_tile_rect(s, Rect2i(p + Vector2i(3, 0), Vector2i(3, 4)), "cliff", WALL)
	var top := s.get_tile_data(p + Vector2i(1, 1), 0)
	top.remove_collision_polygon(WALL, 0)
	top.set_custom_data("terrain", "grass")
	top.set_custom_data("footstep_sound", "grass")
	for c: Vector2i in ExteriorTiles.STAIRS:
		var stairs := s.get_tile_data(c, 0)
		stairs.remove_collision_polygon(WALL, 0)
		stairs.set_custom_data("terrain", "stairs")
		stairs.set_custom_data("footstep_sound", "stone")


static func _autotiles(ts: TileSet) -> void:
	var s := _source(ts, ExteriorTiles.SRC_AUTO, "autotiles.png")
	var masks := AutotileMasks.all()
	for set_index: int in 2:
		var terrain := ExteriorTiles.TERRAIN_TALL_GRASS if set_index == 0 else ExteriorTiles.TERRAIN_PATH
		for i: int in masks.size():
			var coords := Vector2i(i % 8, set_index * 6 + i / 8)
			s.create_tile(coords)
			var tile := s.get_tile_data(coords, 0)
			tile.terrain_set = ExteriorTiles.TERRAIN_SET
			tile.terrain = terrain
			for neighbor: int in AutotileMasks.peering(masks[i]):
				tile.set_terrain_peering_bit(neighbor, terrain)
			tile.set_custom_data("terrain", "tall_grass" if set_index == 0 else "path")
			tile.set_custom_data("encounter", set_index == 0)
			tile.set_custom_data("footstep_sound", "tall_grass" if set_index == 0 else "dirt")


static func _animated(ts: TileSet) -> void:
	var s := _source(ts, ExteriorTiles.SRC_ANIM, "animados.png")
	for info: Array in [[ExteriorTiles.FLOWERS_RED, 4, 0.25, "flowers"],
			[ExteriorTiles.FLOWERS_WHITE, 4, 0.25, "flowers"], [ExteriorTiles.WATER_SHINE, 2, 0.6, ""]]:
		var coords: Vector2i = info[0]
		s.create_tile(coords)
		s.set_tile_animation_columns(coords, info[1])
		s.set_tile_animation_frames_count(coords, info[1])
		for f: int in int(info[1]):
			s.set_tile_animation_frame_duration(coords, f, info[2])
		s.get_tile_data(coords, 0).set_custom_data("terrain", info[3])


static func _flora(ts: TileSet) -> void:
	var s := _source(ts, ExteriorTiles.SRC_FLORA, "flora.png")
	_create_visible_tiles(s)
	# Filas 21–24: el seto (choca). El resto son flores y nenúfares (decoración).
	for coords: Vector2i in _tile_ids(s):
		var is_hedge := coords.y >= 21 and coords.y <= 24
		_tile(s, coords, "hedge" if is_hedge else "flowers", WALL if is_hedge else -1, "grass")


## Objetos grandes (casas y árboles): una sola casilla grande que se coloca en su
## casilla de abajo a la izquierda, se ordena con los personajes (y-sort) y solo
## choca en su base (`footprint`).
static func _objects(ts: TileSet, src_id: int, file: String, objects: Dictionary) -> void:
	var s := _source(ts, src_id, file)
	for id: StringName in objects:
		var o: Dictionary = objects[id]
		if o["source"] != src_id:
			continue
		var coords: Vector2i = o["coords"]
		var size: Vector2i = o["size"]
		s.create_tile(coords, size)
		var tile := s.get_tile_data(coords, 0)
		tile.texture_origin = Vector2i(T / 2 - size.x * T / 2, size.y * T / 2 - T / 2)
		tile.y_sort_origin = T / 2 - 1
		var terrain := "tree"
		if src_id in [ExteriorTiles.SRC_CASAS, ExteriorTiles.SRC_CASAS_DPPT]:
			terrain = "house"
		elif src_id == ExteriorTiles.SRC_VALLAS:
			terrain = "fence"
		tile.set_custom_data("terrain", terrain)
		for cell: Vector2i in o["footprint"]:
			if cell == o["door"]:
				continue
			tile.add_collision_polygon(WALL)
			tile.set_collision_polygon_points(WALL, tile.get_collision_polygons_count(WALL) - 1, _square(cell))


static func _tile_ids(s: TileSetAtlasSource) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i: int in s.get_tiles_count():
		out.append(s.get_tile_id(i))
	return out
