extends SceneTree
## Leganés. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/leganes/exterior.tscn"
const SIZE := Vector2i(64, 56)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"leganes/exterior"
	d.display_name = "Leganés"
	d.zone_id = &"leganes"
	d.encounter_table = &"leganes"
	d.region_map_position = Vector2i(14, 12)
	var p := Pintor.new("Leganes", SIZE, d, 2122)
	p.fill_grass(0.18)
	p.paving(Rect2i(1, 1, 62, 38))
	p.paving(Rect2i(0, 26, 64, 4))
	p.paving(Rect2i(30, 38, 34, 18))
	p.build_paving()
	p.object(&"oficinas_azules", Vector2i(3, 13))
	p.object(&"casa_dos_aguas", Vector2i(16, 11))
	p.object(&"casa_roja", Vector2i(26, 11))
	p.object(&"san_salvador_leganes", Vector2i(17, 21))
	p.object(&"casa_naranja", Vector2i(28, 21))
	p.object(&"centro_pokemon", Vector2i(3, 24))
	p.object(&"tienda_verde", Vector2i(35, 23))
	p.object(&"tienda_morada", Vector2i(44, 23))
	p.object(&"tienda_azul", Vector2i(53, 23))
	p.object(&"fuente_plaza", Vector2i(26, 25))
	p.object(&"oficinas_azules", Vector2i(3, 36))
	p.object(&"casa_granero", Vector2i(18, 36))
	p.object(&"casa_madera", Vector2i(36, 36))
	# Butarque al noreste; plaza y cuartel al centro; Polvoranca al suroeste.
	p.nine_slice(Rect2i(38, 2, 23, 12), ExteriorTiles.PAVING_STONE)
	p.object(&"soportales", Vector2i(39, 7))
	p.object(&"soportales", Vector2i(47, 7))
	for cell: Vector2i in Pintor.cells(Rect2i(40, 9, 19, 5)):
		p.ground.set_cell(cell, ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[0])
	p.fence(39, 45, 14)
	p.fence(51, 60, 14)
	p.pond(Rect2i(8, 43, 12, 9))
	p.terrain(Pintor.cells(Rect2i(22, 42, 7, 10)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"arbol_redondo", Vector2i(2, 45))
	p.object(&"arbol_redondo", Vector2i(3, 53))
	p.object(&"arbol_redondo", Vector2i(25, 54))
	p.object(&"escultura_leganes", Vector2i(44, 45))
	p.object(&"banco", Vector2i(48, 48))
	p.flowers(Rect2i(38, 47, 4, 5))
	for at: Vector2i in [Vector2i(2, 29), Vector2i(33, 25), Vector2i(60, 31), Vector2i(32, 42)]:
		p.object(&"farola_verde", at)
	p.spawn("default", Vector2i(63, 27))
	p.spawn("from_getafe", Vector2i(63, 27))
	p.spawn("from_mostoles", Vector2i(0, 27))
	p.spawn("from_cercanias", Vector2i(9, 14))
	p.connect_edge("east", &"getafe/exterior", 0, Vector2i(26, 30))
	p.trainer("Pepinero", &"leganes_aficionado", Vector2i(49, 12), 0, 3)
	p.trainer("Estudiante", &"leganes_estudiante", Vector2i(16, 37), 2, 2)
	_sign(p, "Butarque", Vector2i(48, 15), ["BUTARQUE · CD LEGANÉS", "Pepineros. La huerta también tiene grada."])
	_sign(p, "Salvador", Vector2i(21, 22), ["IGLESIA DE SAN SALVADOR", "Entre el barroco y el barrio. Interior pendiente."])
	_sign(p, "Cuartel", Vector2i(13, 37), ["CUARTEL DE LAS REALES GUARDIAS VALONAS", "Hoy, universidad. La oposición cambió de uniforme."])
	_sign(p, "Polvoranca", Vector2i(21, 43), ["PARQUE DE POLVORANCA", "Lagunas, aves y un paseo sin pagar entrada."])
	_sign(p, "Museo", Vector2i(43, 46), ["MUSEO DE ESCULTURA AL AIRE LIBRE", "El arte sale a la calle. El alquiler del estudio no perdona."])
	_sign(p, "Estacion", Vector2i(10, 15), ["LEGANÉS · CERCANÍAS C-5", "Ramal de Humanes; transbordo por Atocha para Móstoles."])
	for local: Array in [["Centro", 3, 25, "CENTRO POKÉMON"], ["Mercadona", 35, 24, "MERCADONA"], ["Estanco", 44, 24, "ESTANCO"], ["BasicFit", 53, 24, "BASIC-FIT"]]:
		_sign(p, local[0], Vector2i(local[1], local[2]), [local[3], "Interior pendiente."])
	print("Leganés: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
