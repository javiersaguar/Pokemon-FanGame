extends SceneTree
## Enlaza las puertas de los locales y de algunas casas con su interior.
## Los locales salen de maps/_pintura/locales.json (la casilla es la del edificio).
## Las casas: como mucho dos por mapa, de las que ya están pintadas.

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const SERVICE := ["hospital", "centro", "mercadona", "estanco"]
const MAX_HOUSES := 2


func _initialize() -> void:
	await process_frame
	var locales: Dictionary = JsonFile.read_dict("res://maps/_pintura/locales.json")
	var catalog: Dictionary = ExteriorTiles.objects()
	var by_cell := {}
	for id: String in catalog:
		var o: Dictionary = catalog[id]
		by_cell["%s:%s" % [o["source"], o["coords"]]] = id
	var rewards: Dictionary = JsonFile.read_dict("res://data/npc_rewards.json")
	var placements: Dictionary = JsonFile.read_dict("res://data/item_placements.json")
	var maps: Dictionary = {}
	for city: String in locales:
		var info: Dictionary = locales[city]
		for kind: String in SERVICE:
			if not info.has(kind):
				continue
			var spec: Array = info[kind]
			var map_id := String(spec[0])
			var cell := Vector2i(int(spec[1]), int(spec[2]))
			_service(maps, by_cell, catalog, map_id, cell, "%s/%s" % [city, kind], "from_" + kind, kind.capitalize())
	for path: String in _exteriors():
		var map_id := path.trim_prefix("res://maps/").trim_suffix(".tscn")
		_houses(maps, by_cell, catalog, map_id, rewards, placements)
	for map_id: String in maps:
		var root: Node = maps[map_id]
		var packed := PackedScene.new()
		var err := packed.pack(root)
		if err != OK:
			push_error("%s: %s" % [map_id, error_string(err)])
			continue
		var save_err := ResourceSaver.save(packed, "res://maps/%s.tscn" % map_id)
		print("%s: %s" % [map_id, error_string(save_err)])
		root.free()
	_write_json("res://data/npc_rewards.json", rewards)
	_write_json("res://data/item_placements.json", placements)
	quit()


func _service(maps: Dictionary, by_cell: Dictionary, catalog: Dictionary, map_id: String, cell: Vector2i,
		interior: String, spawn_name: String, warp_name: String) -> void:
	if not ResourceLoader.exists("res://maps/%s.tscn" % interior):
		print("sin interior ", interior)
		return
	var root := _map(maps, map_id)
	if root == null:
		return
	var object_id := _object_at(root, by_cell, cell)
	if object_id == "":
		print("sin edificio en %s %s" % [map_id, cell])
		return
	var door: Vector2i = cell + (catalog[object_id]["door"] as Vector2i)
	if door.x < 0:
		return
	_link(root, door, warp_name, interior, &"default", spawn_name, door + Vector2i.DOWN)


func _houses(maps: Dictionary, by_cell: Dictionary, catalog: Dictionary, map_id: String,
		rewards: Dictionary, placements: Dictionary) -> void:
	var root := _map(maps, map_id)
	if root == null:
		return
	var objects := root.get_node(^"Entities/Objects") as TileMapLayer
	var found := 0
	var city := map_id.get_slice("/", 0)
	for cell: Vector2i in objects.get_used_cells():
		if found >= MAX_HOUSES:
			break
		var object_id := _object_at(root, by_cell, cell)
		if not object_id.begins_with("casa_"):
			continue
		var door: Vector2i = cell + (catalog[object_id]["door"] as Vector2i)
		if door.x < 0 or _warp_at(root, door) != null:
			continue
		found += 1
		var interior := "%s/casa_%d" % [city, found]
		var spawn_name := "from_casa_%d" % found
		_paint_house(interior, city, map_id, spawn_name, found == 1, rewards, placements)
		_link(root, door, "Casa%d" % found, interior, &"default", spawn_name, door + Vector2i.DOWN)
		print("casa ", interior, " puerta ", door)


func _paint_house(interior: String, city: String, exterior: String, return_spawn: String, gift: bool,
		rewards: Dictionary, placements: Dictionary) -> void:
	var d := MapData.new()
	d.id = StringName(interior)
	d.display_name = "Casa · " + city.capitalize().replace("_", " ")
	d.zone_id = StringName(city)
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Casa", Vector2i(16, 12), d, 1)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, Vector2i(16, 12))):
		p.ground.set_cell(at, 0, Vector2i(1, 25))
	for x: int in 16:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, 23))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, 24))
		if x != 8:
			p.decor.set_cell(Vector2i(x, 11), 1, Vector2i(1, 24))
	for y: int in range(2, 11):
		p.decor.set_cell(Vector2i(0, y), 1, Vector2i(1, 24), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
		p.decor.set_cell(Vector2i(15, y), 1, Vector2i(1, 24), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	p.spawn("default", Vector2i(8, 10))
	p.warp("Salida", Vector2i(8, 11), StringName(exterior), StringName(return_spawn))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	p.npc("Vecino", "npc_old_man", Vector2i(4, 6), 0, PackedStringArray([
		"Pasa, que la calle está para mirarla y la casa para sentarse.",
		"Si buscas el Mercadona o el estanco, están en la misma ciudad."]))
	if gift:
		var reward_id := "%s_%s" % [city, return_spawn]
		var placement := "%s/VecinoRegalo" % interior
		rewards[reward_id] = {
			"placement": placement,
			"quantity": 1,
			"flag": "npc_reward:" + reward_id,
			"item": "potion",
		}
		placements[placement] = "potion"
		p.npc("Anfitrion", "npc_woman", Vector2i(11, 6), 0, PackedStringArray(), {
			"display_name": "Anfitriona",
			"event": load("res://src/events/common/npc_reward_event.gd"),
			"event_params": {"reward_id": reward_id},
		})
	else:
		p.npc("Anfitrion", "npc_lass", Vector2i(11, 6), 0, PackedStringArray([
			"No tengo nada que darte, pero el agua del grifo sale fría. En esta casa, eso es un lujo."]))
	var err := p.save("res://maps/%s.tscn" % interior)
	print(interior, ": ", error_string(err))


func _link(root: Node, door: Vector2i, warp_name: String, interior: String, interior_spawn: StringName,
		spawn_name: String, outside: Vector2i) -> void:
	if _warp_at(root, door) == null:
		var warp := Node2D.new()
		warp.set_script(load("res://src/overworld/warp/warp.gd"))
		warp.name = warp_name
		warp.position = Grid.to_world(door)
		warp.set(&"target_map", StringName(interior))
		warp.set(&"target_spawn", interior_spawn)
		warp.set(&"arrival_facing", Warp.Facing.UP)
		warp.set(&"sound", &"door")
		_add(root, root.get_node(^"Warps"), warp)
	var spawns := root.get_node(^"Spawns")
	if spawns.get_node_or_null(NodePath(spawn_name)) == null:
		var marker := Marker2D.new()
		marker.name = spawn_name
		marker.position = Grid.to_world(outside)
		_add(root, spawns, marker)


func _object_at(root: Node, by_cell: Dictionary, cell: Vector2i) -> String:
	var objects := root.get_node(^"Entities/Objects") as TileMapLayer
	var source := objects.get_cell_source_id(cell)
	if source < 0:
		return ""
	return str(by_cell.get("%s:%s" % [source, objects.get_cell_atlas_coords(cell)], ""))


func _warp_at(root: Node, tile: Vector2i) -> Warp:
	var warps := root.get_node_or_null(^"Warps")
	if warps == null:
		return null
	for child: Node in warps.get_children():
		if child is Warp and (child as Warp).contains_tile(tile):
			return child as Warp
	return null


func _map(maps: Dictionary, map_id: String) -> Node:
	if maps.has(map_id):
		return maps[map_id]
	var path := "res://maps/%s.tscn" % map_id
	if not ResourceLoader.exists(path):
		print("sin mapa ", map_id)
		return null
	var root: Node = (load(path) as PackedScene).instantiate()
	maps[map_id] = root
	return root


func _add(root: Node, parent: Node, node: Node) -> void:
	parent.add_child(node)
	node.owner = root


func _exteriors() -> PackedStringArray:
	var out := PackedStringArray()
	var root := DirAccess.open("res://maps")
	if root == null:
		return out
	for dir_name: String in root.get_directories():
		if dir_name.begins_with("_") or dir_name == "test":
			continue
		var exterior := "res://maps/%s/exterior.tscn" % dir_name
		if ResourceLoader.exists(exterior):
			out.append(exterior)
	return out


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", true) + "\n")
