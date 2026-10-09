extends SceneTree
## Getafe. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/getafe/exterior.tscn"
const SIZE := Vector2i(64, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"getafe/exterior"
	d.display_name = "Getafe"
	d.zone_id = &"getafe"
	d.encounter_table = &"getafe"
	d.region_map_position = Vector2i(14, 12)
	var p := Pintor.new("Getafe", SIZE, d, 2122)
	p.fill_grass(0.18)
	p.paving(Rect2i(1, 1, 41, 62))
	p.paving(Rect2i(0, 26, 64, 4))
	p.paving(Rect2i(40, 56, 13, 8))
	p.build_paving()
	# Coliseum al norte: graderíos existentes alrededor de una cancha abierta.
	p.nine_slice(Rect2i(27, 3, 29, 12), ExteriorTiles.PAVING_STONE)
	p.object(&"soportales", Vector2i(28, 7))
	p.object(&"soportales", Vector2i(36, 7))
	p.object(&"soportales", Vector2i(44, 7))
	for cell: Vector2i in Pintor.cells(Rect2i(29, 9, 25, 6)):
		p.ground.set_cell(cell, ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[0])
	p.fence(28, 36, 15)
	p.fence(43, 55, 15)
	p.object(&"oficinas_azules", Vector2i(3, 9))
	p.object(&"casa_roja", Vector2i(14, 9))
	p.object(&"casa_dos_aguas", Vector2i(3, 21))
	p.object(&"magdalena_getafe", Vector2i(24, 21))
	p.object(&"casa_naranja", Vector2i(15, 21))
	p.object(&"fuente_plaza", Vector2i(19, 25))
	p.object(&"centro_pokemon", Vector2i(4, 36))
	p.object(&"tienda_verde", Vector2i(15, 36))
	p.object(&"tienda_morada", Vector2i(25, 36))
	p.object(&"tienda_azul", Vector2i(34, 36))
	p.object(&"casa_granero", Vector2i(3, 47))
	p.object(&"casa_madera", Vector2i(20, 47))
	p.object(&"oficinas_azules", Vector2i(29, 47))
	p.object(&"casa_dos_aguas", Vector2i(18, 59))
	p.object(&"casa_roja_chimenea", Vector2i(3, 59))
	# Cerro de los Ángeles al este; riberas del Manzanares aún más al este.
	p.plateau(Rect2i(43, 33, 17, 23), [50, 51])
	p.object(&"sagrado_corazon_getafe", Vector2i(44, 44))
	p.object(&"ermita_virgen_del_rio", Vector2i(53, 44))
	p.terrain(Pintor.cells(Rect2i(50, 44, 2, 12)), ExteriorTiles.TERRAIN_PATH)
	p.water(Rect2i(61, 31, 3, 33))
	p.build_water()
	p.terrain(Pintor.cells(Rect2i(54, 57, 6, 6)), ExteriorTiles.TERRAIN_TALL_GRASS)
	for at: Vector2i in [Vector2i(41, 12), Vector2i(39, 51), Vector2i(10, 42), Vector2i(45, 52), Vector2i(54, 52)]:
		p.object(&"arbol_redondo", at)
	for at: Vector2i in [Vector2i(2, 25), Vector2i(30, 25), Vector2i(40, 35), Vector2i(40, 58)]:
		p.object(&"farola_verde", at)
	p.object(&"banco", Vector2i(33, 24))
	p.flowers(Rect2i(12, 51, 5, 4))
	p.connect_edge("west", &"leganes/exterior", 0, Vector2i(26, 30))
	p.spawn("default", Vector2i(1, 27))
	p.spawn("from_leganes", Vector2i(0, 27))
	p.spawn("from_ruta_24", Vector2i(47, 63))
	p.trainer("Aficionado", &"getafe_aficionado", Vector2i(40, 12), 0, 3)
	p.trainer("Poligono", &"getafe_poligono", Vector2i(34, 51), 2, 2)
	_sign(p, "Coliseum", Vector2i(41, 16), ["COLISEUM · GETAFE CF", "La grada también juega. Las entradas interiores esperan al tileset."])
	_sign(p, "Catedral", Vector2i(28, 22), ["CATEDRAL DE SANTA MARÍA MAGDALENA", "La torre ha visto más siglos que la garantía de cualquier piso nuevo."])
	_sign(p, "Hospitalillo", Vector2i(5, 22), ["HOSPITALILLO DE SAN JOSÉ", "Un patio para respirar. Interior pendiente."])
	_sign(p, "Ayuntamiento", Vector2i(17, 22), ["PLAZA DE LA CONSTITUCIÓN", "Centro de Getafe. Si te piden otra fotocopia, combate no cuenta como trámite."])
	_sign(p, "Cerro", Vector2i(49, 46), ["CERRO DE LOS ÁNGELES", "Mirador de la península y santuario del Sagrado Corazón."])
	_sign(p, "Estacion", Vector2i(7, 10), ["GETAFE CENTRO · C-4", "La C-5 pasa por Leganés. Acceso urbano al oeste."])
	_sign(p, "Sur", Vector2i(50, 61), ["SUR · RUTA 24, LA MANCHA", "Molinos y Puertollano. Enlace al pintar la ruta."])
	for local: Array in [["Centro", 4, "CENTRO POKÉMON"], ["Mercadona", 15, "MERCADONA"], ["Estanco", 25, "ESTANCO"], ["BasicFit", 34, "BASIC-FIT"]]:
		_sign(p, local[0], Vector2i(local[1], 37), [local[2], "Interior pendiente."])
	p.npc("Vecino", "npc_man", Vector2i(12, 27), 0, PackedStringArray(["Aquí está el sur de Madrid. La capital acaba donde empieza tu abono.", "Para Leganés, sigue hacia el oeste."]))
	print("Getafe: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
