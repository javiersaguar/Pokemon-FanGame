extends SceneTree
## Móstoles. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/mostoles/exterior.tscn"
const SIZE := Vector2i(64, 56)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"mostoles/exterior"
	d.display_name = "Móstoles"
	d.zone_id = &"mostoles"
	d.encounter_table = &"mostoles"
	d.region_map_position = Vector2i(14, 12)
	var p := Pintor.new("Mostoles", SIZE, d, 2122)
	p.fill_grass(0.18)
	p.paving(Rect2i(19, 1, 44, 54))
	p.paving(Rect2i(0, 26, 64, 4))
	p.paving(Rect2i(3, 14, 16, 17))
	p.build_paving()
	p.object(&"oficinas_azules", Vector2i(21, 11))
	p.object(&"casa_dos_aguas", Vector2i(38, 11))
	p.object(&"casa_granero", Vector2i(53, 11))
	p.object(&"asuncion_mostoles", Vector2i(19, 20))
	p.object(&"ermita_virgen_del_rio", Vector2i(29, 20))
	p.object(&"casa_naranja", Vector2i(38, 20))
	p.object(&"fuente_peces", Vector2i(27, 24))
	p.object(&"casa_madera", Vector2i(4, 24))
	p.object(&"casa_roja_pequena", Vector2i(21, 29))
	p.object(&"casa_azul_pequena", Vector2i(38, 29))
	p.object(&"casa_pequena", Vector2i(53, 29))
	p.object(&"arbol_redondo", Vector2i(32, 7))
	p.object(&"arbol_redondo", Vector2i(48, 7))
	p.object(&"arbol_redondo", Vector2i(36, 25))
	p.flowers(Rect2i(30, 7, 2, 3))
	p.flowers(Rect2i(46, 7, 2, 3))
	p.object(&"centro_pokemon", Vector2i(21, 37))
	p.object(&"tienda_verde", Vector2i(33, 37))
	p.object(&"tienda_morada", Vector2i(43, 37))
	p.object(&"tienda_azul", Vector2i(53, 37))
	p.object(&"oficinas_azules", Vector2i(39, 49))
	p.object(&"casa_roja_chimenea", Vector2i(24, 49))
	p.object(&"casa_dos_aguas", Vector2i(52, 49))
	# El Soto al oeste del casco; el campus al noroeste.
	p.object(&"oficinas_azules", Vector2i(3, 10))
	p.pond(Rect2i(3, 38, 12, 9))
	p.terrain(Pintor.cells(Rect2i(3, 49, 13, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"arbol_redondo", Vector2i(3, 34))
	p.object(&"arbol_redondo", Vector2i(12, 36))
	p.object(&"arbol_redondo", Vector2i(17, 46))
	p.object(&"arbol_redondo", Vector2i(60, 53))
	p.object(&"banco", Vector2i(31, 25))
	p.flowers(Rect2i(18, 42, 3, 5))
	for at: Vector2i in [Vector2i(17, 25), Vector2i(45, 25), Vector2i(61, 29), Vector2i(37, 44)]:
		p.object(&"farola_verde", at)
	p.spawn("default", Vector2i(63, 27))
	p.spawn("from_leganes", Vector2i(63, 27))
	p.spawn("from_cercanias", Vector2i(24, 12))
	p.warp("CercaniasAtocha", Vector2i(27, 11), &"madrid/retiro", &"from_cercanias", &"")
	p.connect_edge("east", &"leganes/exterior", 0, Vector2i(26, 30))
	p.trainer("Campus", &"mostoles_estudiante", Vector2i(10, 11), 0, 3)
	p.trainer("Soto", &"mostoles_paseante", Vector2i(17, 47), 1, 2)
	_sign(p, "Pradillo", Vector2i(30, 24), ["PRADILLO · FUENTE DE LOS PECES", "Los tritones llevan echando agua desde 1852. Mi casero no cambia el grifo desde entonces."])
	_sign(p, "Torrejon", Vector2i(7, 25), ["CASA MUSEO ANDRÉS TORREJÓN", "El Bando de 1808. La historia también se firma en una casa pequeña."])
	_sign(p, "Asuncion", Vector2i(22, 21), ["IGLESIA DE NUESTRA SEÑORA DE LA ASUNCIÓN", "Torre mudéjar. Interior pendiente."])
	_sign(p, "Soto", Vector2i(16, 38), ["PARQUE EL SOTO", "Una vuelta al lago. Los patos no aceptan pan de ayer como alquiler."])
	_sign(p, "Campus", Vector2i(11, 11), ["CAMPUS DE MÓSTOLES · URJC", "El diploma ocupa una pared. El contrato, una servilleta."])
	_sign(p, "Estacion", Vector2i(25, 13), ["MÓSTOLES · CERCANÍAS C-5", "Ramal de Móstoles-El Soto; transbordo en Atocha hacia Leganés."])
	for local: Array in [["Centro", 21, "CENTRO POKÉMON"], ["Mercadona", 33, "MERCADONA"], ["Estanco", 43, "ESTANCO"], ["BasicFit", 53, "BASIC-FIT"]]:
		_sign(p, local[0], Vector2i(local[1], 38), [local[2], "Interior pendiente."])
	print("Móstoles: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
