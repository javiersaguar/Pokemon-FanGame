extends SceneTree
## Pinta Madrid · Moncloa y Argüelles (maps/madrid/moncloa.tscn), la entrada a Madrid desde la Ruta 4
## por la A-6 (docs/mundo/ciudades/madrid.md y el plano real docs/mundo/planos/madrid_centro.svg,
## con el norte arriba): el Palacio de la Moncloa tras su verja (noroeste), el Faro de Moncloa y la
## glorieta del Arco de la Victoria; la calle de la Princesa baja hacia la Plaza de España (sureste)
## con la calle Ferraz en paralelo al oeste (Ferraz 70, la sede del Clan PSOE); al este, las
## manzanas de Argüelles (El Corte Inglés de Princesa, Centro Pokémon, Mercadona, estanco); al
## suroeste, el Parque del Oeste con el Templo de Debod y su estanque.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_moncloa.gd -- --force

const OUT := "res://maps/madrid/moncloa.tscn"
const SIZE := Vector2i(64, 52)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_moncloa: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"madrid/moncloa"
	data.display_name = "Madrid · Moncloa"
	data.zone_id = &"madrid"
	data.encounter_table = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridMoncloa", SIZE, data, 1956)
	p.fill_grass(0.15)
	p.connect_edge("west", &"ruta_4/exterior", 16)
	p.connect_edge("east", &"madrid/centro", -38)  # la Plaza de España sigue en el centro (Gran Vía)

	# --- La ciudad, toda de baldosas (como Ciudad Jubileo): la llegada por la A-6 y, desde la
	# glorieta del Arco, todo Argüelles hasta la Plaza de España. Las calles reales (Princesa,
	# Ferraz, Alberto Aguilera, Marqués de Urquijo) son los pasillos que dejan libres las manzanas.
	p.paving(Rect2i(0, 14, 18, 3))
	p.paving(Rect2i(18, 14, 46, 38))
	p.build_paving()

	# --- Parque del Oeste: caminos, hierba alta y el estanque del Templo de Debod ---
	p.terrain(rects([Rect2i(7, 42, 1, 8), Rect2i(6, 50, 12, 2), Rect2i(9, 17, 2, 8), Rect2i(9, 25, 9, 2)]),
		ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(3, 19, 6, 6), Rect2i(11, 28, 6, 6), Rect2i(22, 5, 6, 5)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.water(Rect2i(2, 42, 3, 8))
	p.water(Rect2i(10, 42, 4, 8))
	p.build_water(0.3)

	for r: Rect2i in [Rect2i(0, 18, 2, 34), Rect2i(14, 0, 2, 12), Rect2i(20, 0, 16, 4), Rect2i(36, 0, 28, 4)]:
		p.forest(r)
	p.build_forest()

	# --- Palacio de la Moncloa tras su verja ---
	p.object(&"casa_azul", Vector2i(4, 10))
	p.fence(0, 4, 12)
	p.fence(6, 13, 12)
	p.object(&"arbol_redondo", Vector2i(1, 7))
	p.object(&"arbol_redondo", Vector2i(12, 8))

	# --- Monumentos ---
	p.object(&"faro_moncloa", Vector2i(17, 12))
	p.object(&"arco_victoria", Vector2i(24, 24))
	p.object(&"templo_debod", Vector2i(5, 41))
	p.object(&"puerta_debod", Vector2i(6, 47))

	# --- Edificios ---
	var buildings := [
		[&"oficinas_azules", Vector2i(21, 37)],      # Ferraz 70: la sede del Clan PSOE
		[&"bloque_pisos", Vector2i(21, 49)],
		[&"oficinas_verdes", Vector2i(37, 17)],      # facultades y oficinas de Princesa
		[&"bloque_pisos", Vector2i(45, 17)],
		[&"grandes_almacenes", Vector2i(53, 17)],    # El Corte Inglés de Princesa
		[&"centro_pokemon", Vector2i(38, 29)],
		[&"tienda_verde", Vector2i(50, 29)],         # Mercadona de Argüelles
		[&"bloque_pisos", Vector2i(56, 29)],
		[&"oficinas_azules", Vector2i(37, 39)],
		[&"tienda_morada", Vector2i(50, 39)],        # estanco
		[&"bloque_verde_2", Vector2i(56, 39)],       # Edificio España
		[&"puesto_mercado", Vector2i(32, 39)],       # quiosco de prensa
		[&"bloque_verde_2", Vector2i(29, 49)],
		[&"teatro", Vector2i(37, 49)],               # cine de la calle de la Princesa
	]
	for b: Array in buildings:
		p.object(b[0], b[1])

	# --- Plaza de España: el monumento a Cervantes (fuente y busto, provisional) y árboles ---
	p.object(&"fuente_plaza", Vector2i(51, 47))
	p.object(&"busto", Vector2i(56, 47))
	for cell: Vector2i in [Vector2i(45, 51), Vector2i(61, 51), Vector2i(36, 26),
			Vector2i(16, 47), Vector2i(3, 36), Vector2i(13, 22), Vector2i(30, 10)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(21, 27), Vector2i(34, 21), Vector2i(43, 44), Vector2i(62, 44)]:
		p.object(&"farola_verde", cell)
	p.object(&"banco", Vector2i(57, 51))
	p.flowers(Rect2i(40, 5, 6, 2), 0.4)
	p.flowers(Rect2i(2, 30, 4, 2), 0.5)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.04, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(23, 26), ExteriorTiles.SIGN)
	p.sign_text("CartelArco", Vector2i(23, 26), PackedStringArray(["ARCO DE LA VICTORIA (1956).",
		"Encima, Minerva en su cuadriga. Debajo, el atasco de la A-6 desde 1956."]))
	p.deco(Vector2i(20, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelFaro", Vector2i(20, 12), PackedStringArray(["FARO DE MONCLOA.",
		"Mirador a 92 metros. No es un faro: en Madrid no hay mar. Ni falta que hace, dicen."]))
	p.deco(Vector2i(27, 37), ExteriorTiles.SIGN)
	p.sign_text("CartelFerraz", Vector2i(27, 37), PackedStringArray(["CALLE DE FERRAZ, 70.",
		"Sede del Clan. Prohibido el paso a jueces, periodistas y guardias civiles con carpetas."]))
	p.deco(Vector2i(4, 38), ExteriorTiles.SIGN)
	p.sign_text("CartelDebod", Vector2i(4, 38), PackedStringArray(["TEMPLO DE DEBOD.",
		"Templo egipcio del siglo II a. C., regalo de Egipto a España en 1968.",
		"Aquí se ven los mejores atardeceres de Madrid."]))
	p.deco(Vector2i(45, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelPlazaEspana", Vector2i(45, 41), PackedStringArray(["PLAZA DE ESPAÑA.",
		"Don Quijote y Sancho Panza, a los pies de Cervantes. → Gran Vía y Sol."]))
	p.deco(Vector2i(55, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelMercadona", Vector2i(55, 29), PackedStringArray(["MERCADONA.",
		"Abierto de 9 a 21:30. Domingos cerrado, como Dios manda."]))
	p.deco(Vector2i(49, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelEstanco", Vector2i(49, 39), PackedStringArray(["ESTANCO · EXPENDEDURÍA N.º 33.",
		"Tabaco, sellos, lotería y Poké Balls."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(2, 15))
	p.spawn("from_route_4", Vector2i(0, 15))
	p.trainer("Recluta1", &"madrid_recluta_1", Vector2i(24, 39), LEFT, 3)
	p.trainer("Recluta2", &"madrid_recluta_2", Vector2i(19, 41), UP, 3)
	p.npc("Escolta", "npc_man", Vector2i(5, 12), DOWN, PackedStringArray([
		"Palacio de la Moncloa. Aquí vive el Líder Supremo cuando no está en el Falcon.",
		"Sin cita previa no se pasa. Y con cita previa, tampoco."]))
	p.npc("Estudiante", "estudianteinge", Vector2i(30, 7), DOWN, PackedStringArray([
		"Vengo de la Ciudad Universitaria. Llevo cuatro años en primero de Ingeniería.",
		"Dicen que el Pokémon más fuerte del Clan es un Liepard. Yo creo que es el aforamiento."]))
	p.npc("Jubilado", "npc_old_man", Vector2i(12, 40), LEFT, PackedStringArray([
		"Este templo lo trajeron de Egipto piedra a piedra. Como mi yerno los muebles de IKEA.",
		"Y aun así el templo está mejor montado."]))
	p.npc("Turista", "turistachanclas", Vector2i(54, 49), UP, PackedStringArray([
		"Don Quixote! ¿Dónde está el molino? ¿Y la paella? Me han dicho que todo está en Madrid."]))
	return p
