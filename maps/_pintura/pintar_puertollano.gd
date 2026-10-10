extends SceneTree
## Puertollano: composición provisional, norte arriba.
const OUT := "res://maps/puertollano/exterior.tscn"
const SIZE := Vector2i(72, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"puertollano/exterior"
	d.display_name = "Puertollano"
	d.zone_id = &"puertollano"
	d.encounter_table = &"puertollano"
	d.region_map_position = Vector2i(13, 16)
	var p := Pintor.new("Puertollano", SIZE, d, 2124)
	p.fill_grass(0.18)
	p.paving(Rect2i(1, 1, 70, 62))
	p.paving(Rect2i(34, 0, 4, 64))
	p.build_paving()
	# Paseo central norte-sur, Santa Ana al noreste y Pozo Norte al sureste.
	for rect: Rect2i in [Rect2i(29, 4, 14, 31), Rect2i(48, 43, 12, 18), Rect2i(47, 0, 25, 20)]:
		for cell: Vector2i in Pintor.cells(rect):
			p.ground.set_cell(cell, ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[0])
	p.terrain(Pintor.cells(Rect2i(34, 0, 4, 64)), ExteriorTiles.TERRAIN_PATH)
	p.plateau(Rect2i(47, -1, 26, 23), [53, 54])
	p.terrain(Pintor.cells(Rect2i(53, 14, 2, 8)), ExteriorTiles.TERRAIN_PATH)
	p.object(&"minero_puertollano", Vector2i(54, 13))
	p.object(&"ermita_virgen_del_rio", Vector2i(29, 12))
	p.object(&"oficinas_azules", Vector2i(42, 35))
	p.object(&"fuente_agria", Vector2i(33, 38))
	for at: Vector2i in [Vector2i(30, 19), Vector2i(40, 20), Vector2i(30, 28), Vector2i(40, 29)]:
		p.object(&"arbol_redondo", at)
	p.object(&"banco", Vector2i(31, 25))
	p.object(&"banco", Vector2i(40, 25))
	p.object(&"casa_roja", Vector2i(4, 11))
	p.object(&"casa_dos_aguas", Vector2i(16, 12))
	p.object(&"casa_madera", Vector2i(5, 24))
	p.object(&"casa_naranja", Vector2i(18, 25))
	p.object(&"bloque_pisos", Vector2i(5, 61))
	p.object(&"casa_dos_aguas", Vector2i(20, 61))
	p.object(&"oficinas_azules", Vector2i(4, 36))
	p.object(&"asuncion_mostoles", Vector2i(15, 43))
	p.object(&"casa_roja_chimenea", Vector2i(21, 43))
	p.object(&"centro_pokemon", Vector2i(4, 52))
	p.object(&"tienda_verde", Vector2i(19, 52))
	p.object(&"tienda_morada", Vector2i(40, 51))
	p.object(&"tienda_azul", Vector2i(62, 51))
	p.object(&"oficinas_azules", Vector2i(60, 33))
	p.object(&"nave_logistica", Vector2i(59, 42))
	p.object(&"castillete_minero", Vector2i(51, 49))
	p.object(&"oficinas_azules", Vector2i(49, 60))
	p.terrain(Pintor.cells(Rect2i(47, 25, 9, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(49, 51, 10, 3)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.flowers(Rect2i(29, 6, 3, 4))
	for at: Vector2i in [Vector2i(3, 40), Vector2i(28, 39), Vector2i(43, 57), Vector2i(67, 57)]:
		p.object(&"farola_verde", at)
	p.spawn("default", Vector2i(35, 1))
	p.spawn("from_ruta_24", Vector2i(35, 0))
	p.spawn("from_ruta_25", Vector2i(35, 63))
	p.spawn("from_ave", Vector2i(7, 37))
	p.connect_edge("north", &"ruta_24/exterior", -10, Vector2i(34, 38))
	p.trainer("JubiladoMinero", &"puertollano_minero", Vector2i(52, 50), 0, 3)
	p.trainer("Poligono", &"puertollano_poligono", Vector2i(57, 34), 1, 3)
	_sign(p, "Minero", Vector2i(56, 14), ["MONUMENTO AL MINERO · CERRO DE SANTA ANA", "Figura de bronce de Pepe Noja, nueve metros en la realidad. Mirador de Puertollano."])
	_sign(p, "Fuente", Vector2i(37, 39), ["FUENTE AGRIA · PASEO DE SAN GREGORIO", "Manantial de agua carbónica y ferruginosa. Servicios del juego pendientes."])
	_sign(p, "Gracia", Vector2i(31, 13), ["ERMITA DE LA VIRGEN DE GRACIA", "En el norte del paseo. Interior pendiente."])
	_sign(p, "Banos", Vector2i(46, 36), ["CASA DE BAÑOS", "Antiguo balneario. Hoy, edificio municipal. Interior pendiente."])
	_sign(p, "Asuncion", Vector2i(17, 44), ["IGLESIA DE NUESTRA SEÑORA DE LA ASUNCIÓN", "Fachada provisional adaptada del set propio; interior pendiente."])
	_sign(p, "Museo", Vector2i(53, 61), ["MUSEO DE LA MINERÍA · POZO NORTE", "Castillete y pasado industrial. La Mina Imagen espera a los interiores."])
	_sign(p, "Estacion", Vector2i(8, 37), ["PUERTOLLANO · AVE", "Madrid y Andalucía por ferrocarril. Transporte pendiente de reglas."])
	_sign(p, "Sur", Vector2i(38, 62), ["SUR · RUTA 25, DESPEÑAPERROS", "El enlace abrirá al pintar la ruta."])
	for local: Array in [["Centro", 4, 53, "CENTRO POKÉMON"], ["Mercadona", 19, 53, "MERCADONA"], ["Estanco", 40, 52, "ESTANCO"], ["BasicFit", 62, 52, "BASIC-FIT"]]:
		_sign(p, local[0], Vector2i(local[1], local[2]), [local[3], "Interior pendiente."])
	p.npc("Paseante", "npc_old_man", Vector2i(31, 30), 0, PackedStringArray(["Mi abuelo bajaba al pozo. Yo bajo al paseo a estirar las piernas.", "El castillete recuerda el pasado minero de esta ciudad."]))
	print("Puertollano: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
