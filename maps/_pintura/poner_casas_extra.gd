extends SceneTree
## Unas casas más en el hueco del este de Vigo, que se veía vacío.
const EXTRA := {
	"vigo/exterior": [
		["casa_roja_chimenea", Vector2i(48, 24)],
		["casa_naranja", Vector2i(36, 28)],
	],
}


func _initialize() -> void:
	await process_frame
	var catalog: Dictionary = ExteriorTiles.objects()
	for map_id: String in EXTRA:
		var root: Node = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
		var objects := root.get_node(^"Entities/Objects") as TileMapLayer
		var n := 3
		for spec: Array in EXTRA[map_id]:
			var object_id: String = spec[0]
			var cell: Vector2i = spec[1]
			if objects.get_cell_source_id(cell) >= 0:
				print("ocupada ", map_id, " ", cell)
				continue
			var o: Dictionary = catalog[object_id]
			objects.set_cell(cell, o["source"], o["coords"])
			var door: Vector2i = cell + (o["door"] as Vector2i)
			var interior := "vigo/casa_%d" % n
			_house(interior, map_id, "from_casa_%d" % n)
			var warp := Node2D.new()
			warp.set_script(load("res://src/overworld/warp/warp.gd"))
			warp.name = "Casa%d" % n
			warp.position = Grid.to_world(door)
			warp.set(&"target_map", StringName(interior))
			warp.set(&"target_spawn", &"default")
			warp.set(&"arrival_facing", Warp.Facing.UP)
			root.get_node(^"Warps").add_child(warp)
			warp.owner = root
			var marker := Marker2D.new()
			marker.name = "from_casa_%d" % n
			marker.position = Grid.to_world(door + Vector2i.DOWN)
			root.get_node(^"Spawns").add_child(marker)
			marker.owner = root
			print("extra ", interior, " ", cell)
			n += 1
		var packed := PackedScene.new()
		print(map_id, " ", error_string(packed.pack(root)), " ", error_string(ResourceSaver.save(packed, "res://maps/%s.tscn" % map_id)))
		root.free()
	quit()


func _house(interior: String, exterior: String, return_spawn: String) -> void:
	var d := MapData.new()
	d.id = StringName(interior)
	d.display_name = "Casa · Vigo"
	d.zone_id = &"vigo"
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Casa", Vector2i(16, 12), d, 2)
	var tiles: TileSet = load("res://assets/tilesets/interior/interior.tres")
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
	p.npc("Vecino", "npc_man", Vector2i(5, 6), 0, PackedStringArray([
		"Esta calle estaba vacía y nos hemos mudado. El árbol de la Porta do Sol se ve desde el balcón.",
		"En julio también."]))
	print(interior, " ", error_string(p.save("res://maps/%s.tscn" % interior)))
