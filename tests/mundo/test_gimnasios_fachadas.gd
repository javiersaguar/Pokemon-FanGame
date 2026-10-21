extends GutTest
## Las fachadas propias pueden sustituir píxeles sin recolocar la hoja compartida.
const CONTRACT := "res://docs/arte/comparativas/edificios_reales/gimnasios_pendientes_contrato.json"

func test_sustituir_el_dibujo_conserva_todo_el_catalogo_y_las_huellas() -> void:
	var original := JsonFile.read_dict(CONTRACT)
	var current := JsonFile.read_dict(ExteriorTiles.OBJECTS_JSON)
	for id: String in original.edificios_atlas:
		assert_eq(JSON.stringify(current[id]), JSON.stringify(original.edificios_atlas[id]), "%s: fuente, coordenadas, puerta y huella intactas" % id)
	assert_eq(JSON.stringify(current.escenario_festival), JSON.stringify(original.escenario_festival), "El escenario conserva también las zonas de paso entre sus apoyos")

func test_la_revision_no_toca_ningun_pixel_vecino_del_atlas() -> void:
	var before := Image.load_from_file(ProjectSettings.globalize_path("res://docs/arte/comparativas/edificios_reales/gimnasios_atlas_previo.png"))
	var after := Image.load_from_file(ProjectSettings.globalize_path("res://assets/tilesets/exterior/edificios.png"))
	before.convert(Image.FORMAT_RGBA8)
	after.convert(Image.FORMAT_RGBA8)
	assert_eq(after.get_size(), before.get_size())
	var manifest := JsonFile.read_dict("res://assets/tilesets/exterior/revisiones/piezas.json")
	for id: String in manifest:
		var piece: Dictionary = manifest[id]
		var rect := Rect2i(int(piece.coordenadas[0])*32,int(piece.coordenadas[1])*32,int(piece.tamano[0])*32,int(piece.tamano[1])*32)
		var catalog: Dictionary = JsonFile.read_dict(CONTRACT).edificios_atlas
		for neighbor: String in catalog:
			if neighbor == id:
				continue
			var other: Dictionary = catalog[neighbor]
			var other_rect := Rect2i(int(other.coords[0])*32,int(other.coords[1])*32,int(other.size[0])*32,int(other.size[1])*32)
			assert_false(rect.intersects(other_rect), "%s no invade %s" % [id,neighbor])
		var art := Image.load_from_file(ProjectSettings.globalize_path("res://assets/tilesets/exterior/revisiones/"+String(piece.archivo)))
		art.convert(Image.FORMAT_RGBA8)
		assert_eq(art.get_size(),rect.size)
		assert_true(after.get_region(rect).get_data() == art.get_data(), "%s coincide con el dibujo propio, incluida su transparencia" % id)
		assert_false(before.get_region(rect).get_data() == art.get_data(), "La comparación debe registrar una revisión efectiva")
		before.fill_rect(rect,Color.TRANSPARENT)
		after.fill_rect(rect,Color.TRANSPARENT)
	assert_true(before.get_data() == after.get_data(), "Los píxeles ajenos a las revisiones permanecen idénticos")
	var validator := preload("res://tools/arte/art_validator.gd").new()
	assert_true(validator.run("res://assets/tilesets/exterior/revisiones/"))
	assert_eq(validator.checked, manifest.size())
	assert_eq(validator.errors.size(),0,"\n".join(validator.errors))

func test_portal_y_escenario_conservan_entrada_interior_y_regreso() -> void:
	GameState.reset()
	var entries := [
		[&"madrid/chamberi",Vector2i(28,32),&"atico_jardin",Vector2i(31,32),&"madrid/sala_chamberi_31_32"],
		[&"playa_del_ingles/exterior",Vector2i(45,22),&"escenario_festival",Vector2i(48,23),&"playa_del_ingles/gimnasio_1"],
	]
	for entry: Array in entries:
		var prepared := MapLoader.prepare(entry[0])
		assert_eq(prepared.error,OK)
		var map: MapRoot = prepared.map
		add_child(map)
		await wait_physics_frames(2)
		var piece: Dictionary = ExteriorTiles.objects()[entry[2]]
		var objects := map.get_layer(&"Entities/Objects")
		assert_eq(objects.get_cell_source_id(entry[1]), int(piece.source))
		assert_eq(objects.get_cell_atlas_coords(entry[1]), piece.coords)
		var door: Vector2i = entry[3]
		var warp := map.warp_at(door)
		assert_not_null(warp)
		if warp != null:
			assert_eq(warp.target_map,entry[4])
			var inside := MapLoader.prepare(warp.target_map)
			assert_eq(inside.error,OK)
			var room: MapRoot = inside.map
			var exit := room.get_node(^"Warps/Salida") as Warp
			assert_eq(exit.target_map,map.get_map_id())
			var back: Vector2i = MapLoader.spawn_tile(map,exit.target_spawn)
			assert_eq(back,door+Vector2i.DOWN)
			for cell: Vector2i in [door,back]:
				var query := PhysicsPointQueryParameters2D.new()
				query.position = map.to_global(Grid.to_world(cell))
				query.collision_mask = 1 | 2 | 8
				assert_true(map.get_world_2d().direct_space_state.intersect_point(query,1).is_empty(), "%s: acceso libre %s" % [entry[0],cell])
			room.free()
		map.queue_free()
		await wait_physics_frames(2)
