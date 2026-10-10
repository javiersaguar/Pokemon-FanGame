extends SceneTree
## Málaga: composición provisional, norte arriba.
const OUT := "res://maps/malaga/exterior.tscn"
const SIZE := Vector2i(96, 80)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"malaga/exterior"
	d.display_name = "Málaga"
	d.zone_id = &"malaga"
	d.encounter_table = &"malaga"
	d.region_map_position = Vector2i(12, 22)
	var p := Pintor.new("Malaga", SIZE, d, 2124)
	p.fill_grass(0.15)
	p.paving(Rect2i(1, 1, 94, 64))
	p.paving(Rect2i(40, 0, 4, 69))
	p.paving(Rect2i(10, 28, 13, 4))
	p.paving(Rect2i(10, 51, 13, 4))
	p.paving(Rect2i(49, 56, 26, 12))
	p.paving(Rect2i(62, 65, 12, 7))
	p.build_paving()
	p.soil(Rect2i(0, 65, 62, 4))
	p.soil(Rect2i(74, 65, 22, 4))
	# Guadalmedina al oeste del casco: puentes de ocho casillas transpuestos.
	p.water(Rect2i(13, -1, 5, 29))
	p.water(Rect2i(13, 32, 5, 19))
	p.water(Rect2i(13, 55, 5, 14))
	# Puerto y playa al sur; muelle pisable alrededor del velero.
	p.water(Rect2i(-1, 69, 63, 3))
	p.water(Rect2i(74, 69, 23, 3))
	p.water(Rect2i(-1, 72, 98, 9))
	p.build_water()
	var bridge: Dictionary = ExteriorTiles.objects()[&"puente_piedra"]
	for y: int in [28, 51]:
		p.decor.set_cell(Vector2i(20, y), bridge.source, bridge.coords, TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	p.object(&"centro_pokemon", Vector2i(27, 21))
	p.object(&"tienda_verde", Vector2i(46, 21))
	p.object(&"tienda_morada", Vector2i(52, 21))
	p.object(&"tienda_azul", Vector2i(47, 42))
	p.object(&"catedral_malaga", Vector2i(44, 35))
	p.object(&"casa_dos_aguas", Vector2i(23, 11))
	p.object(&"casa_roja_chimenea", Vector2i(47, 11))
	p.object(&"casa_naranja", Vector2i(57, 11))
	p.object(&"soportales", Vector2i(21, 36))
	p.object(&"soportales", Vector2i(29, 36))
	p.object(&"puesto_mercado", Vector2i(21, 40))
	p.object(&"puesto_mercado", Vector2i(27, 40))
	p.object(&"puesto_mercado", Vector2i(33, 40))
	p.object(&"oficinas_azules", Vector2i(23, 54))
	p.object(&"oficinas_azules", Vector2i(3, 57))
	# Alcazaba bajo Gibralfaro, al este del centro; patrimonio comprimido.
	p.plateau(Rect2i(67, -1, 30, 25), [75, 76])
	p.object(&"castillo_luz", Vector2i(74, 16))
	p.object(&"muralla_dalt_vila", Vector2i(81, 20))
	p.terrain(Pintor.cells(Rect2i(75, 17, 2, 7)), ExteriorTiles.TERRAIN_PATH)
	p.plateau(Rect2i(56, 25, 25, 14), [65, 66])
	p.object(&"castillo_luz", Vector2i(58, 35))
	p.object(&"muralla_dalt_vila", Vector2i(66, 32))
	p.terrain(Pintor.cells(Rect2i(65, 33, 2, 6)), ExteriorTiles.TERRAIN_PATH)
	for rect: Rect2i in [Rect2i(58, 40, 17, 2), Rect2i(60, 42, 13, 2), Rect2i(62, 44, 9, 2)]:
		p.nine_slice(rect, ExteriorTiles.PAVING_STONE)
	p.object(&"cubo_pompidou", Vector2i(61, 61))
	p.object(&"velero", Vector2i(65, 70))
	p.object(&"casa_madera", Vector2i(82, 65))
	p.object(&"torre_socorrista", Vector2i(76, 66))
	p.object(&"sombrilla", Vector2i(86, 67))
	p.object(&"sombrilla", Vector2i(91, 67))
	for at: Vector2i in [Vector2i(21, 22), Vector2i(30, 29), Vector2i(53, 50), Vector2i(81, 53), Vector2i(90, 58)]:
		p.object(&"arbol_redondo", at)
	p.terrain(Pintor.cells(Rect2i(83, 28, 11, 6)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(19, 58, 9, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.spawn("default", Vector2i(41, 1))
	p.spawn("from_ruta_26", Vector2i(41, 0))
	p.spawn("from_ave", Vector2i(6, 58))
	p.connect_edge("north", &"ruta_26/exterior", -16, Vector2i(40, 44))
	p.trainer("Rodaje", &"malaga_rodaje", Vector2i(55, 59), 3, 3)
	p.trainer("Playa", &"malaga_playa", Vector2i(80, 67), 1, 3)
	_sign(p, "Catedral", Vector2i(54, 36), ["CATEDRAL · LA MANQUITA", "La torre sur quedó sin terminar."])
	_sign(p, "Alcazaba", Vector2i(64, 39), ["ALCAZABA Y TEATRO ROMANO", "Fortaleza en la ladera y teatro a sus pies. El acceso interior está cerrado."])
	_sign(p, "Gibralfaro", Vector2i(73, 24), ["GIBRALFARO", "Castillo sobre el monte. El acceso interior está cerrado."])
	_sign(p, "Mercado", Vector2i(29, 41), ["MERCADO DE ATARAZANAS", "Puestos de productos frescos. El acceso interior está cerrado."])
	_sign(p, "Pompidou", Vector2i(63, 62), ["CENTRE POMPIDOU · MUELLE UNO", "El Cubo de vidrio coloreado. El acceso interior está cerrado."])
	_sign(p, "Gimnasio", Vector2i(56, 62), ["GIMNASIO 8 · RODAJE DE PELÍCULA", "Líder: Antonio Banderas. Acceso todavía cerrado."])
	_sign(p, "Estacion", Vector2i(8, 58), ["MÁLAGA MARÍA ZAMBRANO · AVE", "El servicio a Madrid todavía no está disponible."])
	for local: Array in [["Centro", 27, 22, "CENTRO POKÉMON"], ["Mercadona", 46, 22, "MERCADONA"], ["Estanco", 52, 22, "ESTANCO"], ["BasicFit", 47, 43, "BASIC-FIT"]]:
		_sign(p, local[0], Vector2i(local[1], local[2]), [local[3], "El acceso está cerrado por ahora."])
	# El agua auxiliar de borde no amplía los límites caminables del mapa.
	for layer: TileMapLayer in [p.ground, p.decor, p.above]:
		for cell: Vector2i in layer.get_used_cells():
			if not Rect2i(Vector2i.ZERO, SIZE).has_point(cell):
				layer.erase_cell(cell)
	print("Málaga: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
