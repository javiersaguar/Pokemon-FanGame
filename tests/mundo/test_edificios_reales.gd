extends GutTest
## Contrato del redibujo: tamaño, fuente, puerta y colisión permanecen estables.
const BASE := "res://docs/arte/comparativas/edificios_reales/contrato_inicial.json"

func test_redibujo_conserva_fuentes_tamanos_puertas_y_huellas() -> void:
	var baseline := JsonFile.read_dict(BASE)
	var catalog := ExteriorTiles.objects()
	for id: String in baseline.pieces:
		var expected: Dictionary = baseline.pieces[id]
		assert_true(catalog.has(StringName(id)), id)
		if not catalog.has(StringName(id)):
			continue
		var piece: Dictionary = catalog[StringName(id)]
		assert_eq(piece.source, int(expected.source), "%s mantiene su fuente" % id)
		assert_eq(piece.size, Vector2i(int(expected.size[0]), int(expected.size[1])), "%s mantiene su lienzo" % id)
		assert_eq(piece.door, Vector2i(int(expected.door[0]), int(expected.door[1])), "%s mantiene la casilla de puerta" % id)
		assert_eq(JSON.stringify(piece.footprint), JSON.stringify(expected.footprint), "%s mantiene la colisión" % id)

func test_piezas_corregidas_caben_y_conservan_entrada_interior_y_regreso() -> void:
	GameState.reset()
	var catalog := ExteriorTiles.objects()
	for entry: Dictionary in JsonFile.read_dict(BASE).corrections:
		var prepared := MapLoader.prepare(StringName(entry.map))
		assert_eq(prepared.error, OK)
		var map: MapRoot = prepared.map
		add_child(map)
		await wait_physics_frames(2)
		var piece: Dictionary = catalog[StringName(entry.id)]
		var anchor := Vector2i(int(entry.after[0]), int(entry.after[1]))
		var visual := Rect2i(anchor - Vector2i(0, piece.size.y - 1), piece.size)
		assert_true(map.get_ground().get_used_rect().encloses(visual), "%s cabe entero" % entry.id)
		var objects := map.get_layer(&"Entities/Objects")
		assert_eq(objects.get_cell_source_id(anchor), int(piece.source))
		assert_eq(objects.get_cell_atlas_coords(anchor), piece.coords)
		var door: Vector2i = anchor + piece.door
		var warp := map.warp_at(door)
		assert_not_null(warp, "%s tiene puerta enlazada" % entry.id)
		if warp != null:
			assert_eq(String(warp.target_map), String(entry.interior), "no cambia el interior ni su identidad")
			var interior := MapLoader.prepare(warp.target_map)
			assert_eq(interior.error, OK)
			var room: MapRoot = interior.map
			var exit := room.get_node(^"Warps/Salida") as Warp
			assert_eq(exit.target_map, map.get_map_id())
			var back: Variant = MapLoader.spawn_tile(map, exit.target_spawn)
			assert_eq(back, door + Vector2i.DOWN, "se vuelve delante de la puerta trasladada")
			assert_null(map.warp_at(back), "la llegada no reentra inmediatamente")
			var query := PhysicsPointQueryParameters2D.new()
			query.collision_mask = 1 | 2 | 8
			query.position = map.to_global(Grid.to_world(back))
			assert_true(map.get_world_2d().direct_space_state.intersect_point(query, 1).is_empty(), "el regreso no cae en una pared ni un bordillo")
			room.free()
		map.queue_free()
		await wait_physics_frames(2)

func test_la_otra_casa_de_madera_de_ruta_2_no_se_traslada() -> void:
	var map: MapRoot = load("res://maps/ruta_2/exterior.tscn").instantiate()
	var piece: Dictionary = ExteriorTiles.objects()[&"casa_madera"]
	assert_eq(map.get_layer(&"Entities/Objects").get_cell_source_id(Vector2i(6, 19)), int(piece.source))
	assert_eq(map.get_layer(&"Entities/Objects").get_cell_atlas_coords(Vector2i(6, 19)), piece.coords)
	map.free()

func test_club_comedia_conserva_el_gimnasio_y_su_regreso() -> void:
	GameState.reset()
	var contract := JsonFile.read_dict("res://docs/arte/comparativas/edificios_reales/club_comedia_contrato.json")
	var piece: Dictionary = ExteriorTiles.objects()[&"club_comedia"]
	assert_eq(piece.size, Vector2i(int(contract.piece.size[0]), int(contract.piece.size[1])))
	assert_eq(piece.door, Vector2i(int(contract.piece.door[0]), int(contract.piece.door[1])))
	var original_footprint: Array[Vector2i] = []
	for cell: Array in contract.piece.footprint:
		original_footprint.append(Vector2i(int(cell[0]), int(cell[1])))
	assert_eq(JSON.stringify(piece.footprint), JSON.stringify(original_footprint))
	var prepared := MapLoader.prepare(StringName(contract.map))
	assert_eq(prepared.error, OK)
	var map: MapRoot = prepared.map
	add_child(map)
	await wait_physics_frames(2)
	var anchor := Vector2i(int(contract.anchor[0]), int(contract.anchor[1]))
	assert_eq(map.get_layer(&"Entities/Objects").get_cell_source_id(anchor), int(piece.source))
	var door: Vector2i = anchor + piece.door
	assert_eq(door, Vector2i(int(contract.door[0]), int(contract.door[1])))
	var warp := map.warp_at(door)
	assert_not_null(warp)
	if warp != null:
		assert_eq(String(warp.target_map), String(contract.interior))
		var inside := MapLoader.prepare(warp.target_map)
		assert_eq(inside.error, OK)
		var room: MapRoot = inside.map
		var exit := room.get_node(^"Warps/Salida") as Warp
		assert_eq(String(exit.target_map), String(contract.map))
		var back: Vector2i = MapLoader.spawn_tile(map, exit.target_spawn)
		assert_eq(back, door + Vector2i.DOWN)
		var query := PhysicsPointQueryParameters2D.new()
		query.collision_mask = 1 | 2 | 8
		query.position = map.to_global(Grid.to_world(back))
		assert_true(map.get_world_2d().direct_space_state.intersect_point(query, 1).is_empty())
		room.free()
	map.queue_free()
	await wait_physics_frames(2)
