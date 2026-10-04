extends SceneTree
## Crea placeholder.tres a partir de placeholder.png (ver generate_png.gd).
## Capas del TileSet (las mismas que deberá tener el tileset definitivo):
##   Física 0 → capa "paredes" (1) · Física 1 → capa "agua" (4)
##   Custom data: terrain (String), encounter (bool), footstep_sound (String)

const PNG := "res://assets/tilesets/placeholder/placeholder.png"
const OUT := "res://assets/tilesets/placeholder/placeholder.tres"

const NONE := -1
const WALL := 0
const WATER := 1

## Índice = columna en placeholder.png.
const TILES := [
	{"terrain": "grass", "physics": NONE, "encounter": false, "footstep": "grass"},
	{"terrain": "tall_grass", "physics": NONE, "encounter": true, "footstep": "tall_grass"},
	{"terrain": "path", "physics": NONE, "encounter": false, "footstep": "dirt"},
	{"terrain": "floor", "physics": NONE, "encounter": false, "footstep": "wood"},
	{"terrain": "wall", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "water", "physics": WATER, "encounter": false, "footstep": ""},
	{"terrain": "tree", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "ledge_down", "physics": WALL, "encounter": false, "footstep": "grass"},
	{"terrain": "door", "physics": NONE, "encounter": false, "footstep": "wood"},
	{"terrain": "roof", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "house", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "counter", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "mat", "physics": NONE, "encounter": false, "footstep": "carpet"},
	{"terrain": "flowers", "physics": NONE, "encounter": false, "footstep": "grass"},
	{"terrain": "indoor_wall", "physics": WALL, "encounter": false, "footstep": ""},
	{"terrain": "void", "physics": WALL, "encounter": false, "footstep": ""},
]


func _init() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(WALL, 1)
	ts.set_physics_layer_collision_mask(WALL, 0)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(WATER, 1 << 3)
	ts.set_physics_layer_collision_mask(WATER, 0)
	_add_custom_layer(ts, "terrain", TYPE_STRING)
	_add_custom_layer(ts, "encounter", TYPE_BOOL)
	_add_custom_layer(ts, "footstep_sound", TYPE_STRING)

	var source := TileSetAtlasSource.new()
	source.texture = load(PNG)
	source.texture_region_size = Vector2i(16, 16)
	ts.add_source(source, 0)
	var square := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
	for i: int in TILES.size():
		var info: Dictionary = TILES[i]
		var coords := Vector2i(i, 0)
		source.create_tile(coords)
		var tile := source.get_tile_data(coords, 0)
		tile.set_custom_data("terrain", info["terrain"])
		tile.set_custom_data("encounter", info["encounter"])
		tile.set_custom_data("footstep_sound", info["footstep"])
		if info["physics"] != NONE:
			tile.add_collision_polygon(info["physics"])
			tile.set_collision_polygon_points(info["physics"], 0, square)
	print("placeholder.tres: ", error_string(ResourceSaver.save(ts, OUT)))
	quit()


func _add_custom_layer(ts: TileSet, layer_name: String, type: Variant.Type) -> void:
	ts.add_custom_data_layer()
	var index := ts.get_custom_data_layers_count() - 1
	ts.set_custom_data_layer_name(index, layer_name)
	ts.set_custom_data_layer_type(index, type)
