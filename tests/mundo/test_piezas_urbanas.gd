extends GutTest
## Módulos transitables y muebles sólidos: se comprueba la colisión real del TileSet.
const CONTRACT := "res://docs/arte/comparativas/edificios_reales/urbanas_contrato.json"

func test_piezas_urbanas_tienen_tamano_y_colision_de_su_uso() -> void:
	var catalog := ExteriorTiles.objects()
	var expected := JsonFile.read_dict(CONTRACT).pieces as Dictionary
	var tileset := load(ExteriorTiles.TILESET) as TileSet
	assert_eq(expected.size(),30)
	for id: String in expected:
		assert_true(catalog.has(StringName(id)),id)
		if not catalog.has(StringName(id)):
			continue
		var piece: Dictionary = catalog[StringName(id)]
		var wanted: Dictionary = expected[id]
		assert_eq(piece.source,int(wanted.source),id)
		assert_eq(piece.size,Vector2i(int(wanted.size[0]),int(wanted.size[1])),id)
		assert_eq(piece.door,Vector2i(-1,-1),"el mobiliario no inventa puertas")
		var cells: Array[Vector2i] = []
		for xy: Array in wanted.footprint:
			cells.append(Vector2i(int(xy[0]),int(xy[1])))
		assert_eq(piece.footprint,cells,id)
		var atlas := tileset.get_source(int(piece.source)) as TileSetAtlasSource
		assert_not_null(atlas,id)
		if atlas == null:
			continue
		var data := atlas.get_tile_data(piece.coords,0)
		assert_eq(data.get_collision_polygons_count(0),cells.size(),"%s: polígonos reales"%id)

func test_bordillos_rectos_enlazan_con_sus_esquinas_sin_huecos() -> void:
	# Cada borde se prolonga hasta el extremo del cuadro, sin rotaciones de textura.
	var edges := {
		"bordillo_n": [Vector2i(0,1),Vector2i(31,1)],
		"bordillo_s": [Vector2i(0,25),Vector2i(31,25)],
		"bordillo_o": [Vector2i(1,0),Vector2i(1,31)],
		"bordillo_e": [Vector2i(25,0),Vector2i(25,31)],
		"bordillo_esquina_no": [Vector2i(31,1),Vector2i(1,31)],
		"bordillo_esquina_ne": [Vector2i(0,1),Vector2i(25,31)],
		"bordillo_esquina_so": [Vector2i(31,25),Vector2i(1,0)],
		"bordillo_esquina_se": [Vector2i(0,25),Vector2i(25,0)],
	}
	for id: String in edges:
		var image := (load("res://assets/tilesets/exterior/hecho_a_mano/%s.png"%id) as Texture2D).get_image()
		for pixel: Vector2i in edges[id]:
			assert_gt(image.get_pixelv(pixel).a,0.9,"%s llega al borde %s"%[id,pixel])
