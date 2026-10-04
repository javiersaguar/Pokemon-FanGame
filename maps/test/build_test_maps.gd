extends SceneTree
## Genera desde cero las escenas de la sala de pruebas con el tileset provisional.
## Solo para regenerarlas: una vez editadas en el editor, NO lo vuelvas a ejecutar
## (sobrescribiría los cambios). Por eso exige `-- --force` si ya existen.
## Uso: godot --headless --path . -s res://maps/test/build_test_maps.gd [-- --force]

const TILESET := "res://assets/tilesets/placeholder/placeholder.tres"
const MAP_ROOT := "res://src/overworld/map_root.gd"

## Carácter → [capa, columna del tile en placeholder.png]. Ground lleva debajo
## el suelo indicado en `floor`.
const LEGEND := {
	".": ["Ground", 0], ",": ["Ground", 1], "p": ["Ground", 2], "o": ["Ground", 3],
	"~": ["Ground", 5], "f": ["Ground", 13], "M": ["Ground", 12],
	"#": ["Decor", 4], "T": ["Decor", 6], "L": ["Decor", 7], "D": ["Decor", 8],
	"R": ["Decor", 9], "H": ["Decor", 10], "C": ["Decor", 11], "W": ["Decor", 14],
}

const ROOM := [
	"WWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWW",
	"WooooooooooooooooooW",
	"WooCCCooooooooCCCooW",
	"WooooooooooooooooooW",
	"WooooooooooooooooooW",
	"WooooooooooooooooooW",
	"WoooooooCCCCoooooooW",
	"WooooooooooooooooooW",
	"WooooooooooooooooooW",
	"WWWWWWWWWMMWWWWWWWWW",
]

const OUTDOOR := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"T............................T",
	"T..RRRRR.....................T",
	"T..RRRRR.......,,,,,,........T",
	"T..HHDHH.......,,,,,,........T",
	"T....p.........,,,,,,....~~~.T",
	"T....p.........,,,,,,....~~~.T",
	"T....ppppppppppppppppp...~~~.T",
	"T....................p.......T",
	"T..ff................p....ff.T",
	"T....................p.......T",
	"T,,,,,...............p.......T",
	"T,,,,,...............p.......T",
	"T,,,,,.......LLLLLLLLp.......T",
	"T....................p.......T",
	"T....................p.......T",
	"T..........ff........p.......T",
	"T....................p.......T",
	"T....................p.......T",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]


func _init() -> void:
	var force := "--force" in OS.get_cmdline_user_args()
	_build("res://maps/test/test_room.tscn", ROOM, 3, force, {
		"id": &"test/test_room",
		"display_name": "Sala de pruebas",
		"outdoor": false,
		"fixed_camera": true,
		"healing_spot": &"test/test_room",
	}, {"default": Vector2i(10, 5), "from_outdoor": Vector2i(9, 9)})
	_build("res://maps/test/test_outdoor.tscn", OUTDOOR, 0, force, {
		"id": &"test/test_outdoor",
		"display_name": "Exterior de pruebas",
		"outdoor": true,
		"healing_spot": &"test/test_room",
	}, {"default": Vector2i(10, 9), "from_room": Vector2i(5, 5)})
	quit()


func _build(path: String, rows: Array, floor_tile: int, force: bool, data: Dictionary,
		spawns: Dictionary) -> void:
	if FileAccess.file_exists(path) and not force:
		print("%s ya existe; usa -- --force para sobrescribirlo." % path)
		return
	var tileset: TileSet = load(TILESET)
	var map_node := Node2D.new()
	map_node.name = path.get_file().get_basename().to_pascal_case()
	map_node.set_script(load(MAP_ROOT))
	var map_data := MapData.new()
	for key: String in data:
		map_data.set(key, data[key])
	map_node.set("data", map_data)

	var layers := {}
	for layer_name: String in ["Ground", "Decor"]:
		layers[layer_name] = _add_layer(map_node, layer_name, tileset)
	var entities := _add(map_node, Node2D.new(), "Entities") as Node2D
	entities.y_sort_enabled = true
	_add_layer(map_node, "Above", tileset)
	_add(map_node, Node2D.new(), "Warps")
	var spawns_node := _add(map_node, Node2D.new(), "Spawns")
	_add(map_node, Node2D.new(), "Triggers")

	for y: int in rows.size():
		var row: String = rows[y]
		assert(row.length() == rows[0].length(), "%s: fila %d con otra longitud" % [path, y])
		for x: int in row.length():
			var entry: Array = LEGEND[row[x]]
			var cell := Vector2i(x, y)
			if entry[0] != "Ground":
				(layers["Ground"] as TileMapLayer).set_cell(cell, 0, Vector2i(floor_tile, 0))
			(layers[entry[0]] as TileMapLayer).set_cell(cell, 0, Vector2i(entry[1], 0))

	for spawn_id: String in spawns:
		var marker := _add(spawns_node, Marker2D.new(), spawn_id) as Marker2D
		marker.position = Grid.to_world(spawns[spawn_id])

	var scene := PackedScene.new()
	scene.pack(map_node)
	print("%s: %s" % [path, error_string(ResourceSaver.save(scene, path))])
	map_node.free()


func _add_layer(map_node: Node, layer_name: String, tileset: TileSet) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = tileset
	return _add(map_node, layer, layer_name) as TileMapLayer


func _add(parent: Node, node: Node, node_name: String) -> Node:
	node.name = node_name
	parent.add_child(node)
	node.owner = parent if parent.owner == null else parent.owner
	return node
