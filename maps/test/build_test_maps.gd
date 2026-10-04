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


const NPC_SCENE := "res://src/overworld/npc/npc.tscn"
const ITEM_SCENE := "res://src/overworld/item_ball/item_ball.tscn"
const SIGN_SCENE := "res://src/overworld/sign/sign.tscn"
const WARP_SCRIPT := "res://src/overworld/warp/warp.gd"
const SHEETS := "res://assets/sprites/characters/placeholder/"

const ROOM_ENTITIES := [
	{"scene": NPC_SCENE, "name": "Profesor", "tile": Vector2i(10, 4), "props": {
		"display_name": "Profesor", "sheet": "professor",
		"lines": ["¡Hola! Soy el profesor provisional.", "Esta es la sala de pruebas del equipo."]}},
	{"scene": NPC_SCENE, "name": "Probador", "tile": Vector2i(4, 6), "script": "res://maps/test/test_battle_npc.gd",
		"props": {"display_name": "Probador", "sheet": "trainer", "initial_facing": 2}},
	{"scene": NPC_SCENE, "name": "Paseante", "tile": Vector2i(15, 6), "props": {
		"sheet": "npc_woman", "wander": true,
		"lines": ["Doy vueltas por la sala para probar el paseo de los NPCs."]}},
	{"scene": NPC_SCENE, "name": "Dependiente", "tile": Vector2i(9, 6), "props": {
		"display_name": "Dependiente", "sheet": "clerk",
		"lines": ["Te atiendo por encima del mostrador."]}},
	{"scene": ITEM_SCENE, "name": "Pocion", "tile": Vector2i(17, 8), "props": {"item_id": &"potion"}},
	{"scene": ITEM_SCENE, "name": "CarameloOculto", "tile": Vector2i(2, 8), "props": {
		"item_id": &"rarecandy", "hidden_item": true}},
]
const ROOM_WARPS := [
	{"name": "ToOutdoor", "tile": Vector2i(9, 10), "size": Vector2i(2, 1), "map": &"test/test_outdoor",
		"spawn": &"from_room", "facing": 1, "sound": &"exit"},
]

const OUTDOOR_ENTITIES := [
	{"scene": SIGN_SCENE, "name": "Cartel", "tile": Vector2i(7, 5), "props": {"lines": [
		"EXTERIOR DE PRUEBAS",
		"La hierba alta da encuentros si existe data/encounters/test_outdoor.json."]}},
	{"scene": NPC_SCENE, "name": "Vecino", "tile": Vector2i(12, 9), "props": {
		"sheet": "npc_man", "wander": true, "lines": ["¡Cuidado con la hierba alta!"]}},
	{"scene": NPC_SCENE, "name": "Abuelo", "tile": Vector2i(24, 8), "props": {
		"sheet": "npc_old", "initial_facing": 1, "lines": ["El agua de ahí no se cruza sin Surf."]}},
	{"scene": ITEM_SCENE, "name": "PokeBalls", "tile": Vector2i(26, 10), "props": {
		"item_id": &"pokeball", "quantity": 2}},
	{"scene": ITEM_SCENE, "name": "PocionOculta", "tile": Vector2i(28, 1), "props": {
		"item_id": &"potion", "hidden_item": true}},
]
const OUTDOOR_WARPS := [
	{"name": "ToRoom", "tile": Vector2i(5, 4), "map": &"test/test_room", "spawn": &"from_outdoor",
		"facing": 4, "sound": &"door"},
]


## En _initialize (no en _init) para que los autoloads ya existan al cargar los scripts.
func _initialize() -> void:
	await process_frame
	var force := "--force" in OS.get_cmdline_user_args()
	_build("res://maps/test/test_room.tscn", ROOM, 3, force, {
		"id": &"test/test_room",
		"display_name": "Sala de pruebas",
		"outdoor": false,
		"fixed_camera": true,
		"healing_spot": &"test/test_room",
	}, {"default": Vector2i(10, 5), "from_outdoor": Vector2i(9, 9)}, ROOM_ENTITIES, ROOM_WARPS)
	_build("res://maps/test/test_outdoor.tscn", OUTDOOR, 0, force, {
		"id": &"test/test_outdoor",
		"display_name": "Exterior de pruebas",
		"outdoor": true,
		"encounter_table": &"test_outdoor",
		"healing_spot": &"test/test_room",
	}, {"default": Vector2i(10, 9), "from_room": Vector2i(5, 5)}, OUTDOOR_ENTITIES, OUTDOOR_WARPS)
	quit()


func _build(path: String, rows: Array, floor_tile: int, force: bool, data: Dictionary,
		spawns: Dictionary, entities_spec: Array, warps_spec: Array) -> void:
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
	var warps := _add(map_node, Node2D.new(), "Warps")
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

	for spec: Dictionary in entities_spec:
		var entity := (load(spec["scene"]) as PackedScene).instantiate() as Node2D
		if spec.has("script"):
			entity.set_script(load(spec["script"]))
		_add(entities, entity, spec["name"])
		entity.position = Grid.to_world(spec["tile"])
		var props: Dictionary = spec["props"]
		for key: String in props:
			if key == "sheet":
				entity.set("sprite_sheet", load(SHEETS + props[key] + ".png"))
			elif key == "lines":
				entity.set("lines", PackedStringArray(props[key]))
			else:
				entity.set(key, props[key])

	for spec: Dictionary in warps_spec:
		var warp := Node2D.new()
		warp.set_script(load(WARP_SCRIPT))
		_add(warps, warp, spec["name"])
		warp.position = Grid.to_world(spec["tile"])
		warp.set("target_map", spec["map"])
		warp.set("target_spawn", spec["spawn"])
		warp.set("arrival_facing", spec["facing"])
		warp.set("size", spec.get("size", Vector2i.ONE))
		warp.set("sound", spec["sound"])

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
