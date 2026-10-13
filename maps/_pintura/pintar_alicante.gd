extends SceneTree
## Pinta Alicante (maps/alicante/exterior.tscn) con el plano real docs/mundo/planos/alicante.svg (norte
## arriba; docs/mundo/ciudades/alicante.md): al noreste, el monte Benacantil con el Castillo de Santa
## Bárbara y, a sus pies, las casas encaladas del barrio de Santa Cruz; en el centro, la Concatedral de
## San Nicolás, el Teatro Principal, la plaza de los Luceros y los grandes almacenes; al sur, la
## Explanada de España con su mosaico ondulado, las palmeras y la Casa Carbonell frente al puerto; al
## este, la playa del Postiguet. Por el norte llega la Ruta 10 y por el oeste sale la Ruta 11 (Elche).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_alicante.gd -- --force

const OUT := "res://maps/alicante/exterior.tscn"
const SIZE := Vector2i(72, 60)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_alicante: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"alicante/exterior"
	data.display_name = "Alicante"
	data.zone_id = &"alicante"
	data.encounter_table = &"alicante"
	data.region_map_position = Vector2i(22, 17)
	var p: RefCounted = painter.new("Alicante", SIZE, data, 1490)
	p.fill_grass(0.2)
	p.connect_edge("north", &"ruta_10/exterior", -11, Vector2i(36, 40))
	p.connect_edge("west", &"ruta_11/exterior", -18, Vector2i(34, 38))

	# La ciudad, Santa Cruz y el muelle.
	p.paving(Rect2i(0, 0, 46, 50))
	p.paving(Rect2i(46, 22, 12, 28))
	p.build_paving()
	# La ladera del Benacantil, sobre la playa.
	p.terrain(Pintor.cells(Rect2i(59, 22, 12, 10)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.soil(Rect2i(58, 34, 14, 10))              # la playa del Postiguet
	p.water(Rect2i(0, 50, SIZE.x, 10))          # el puerto y el Mediterráneo
	p.water(Rect2i(58, 44, 14, 6))
	p.build_water(0.1)
	# El monte Benacantil, con la cuesta que sube desde Santa Cruz.
	p.plateau(Rect2i(47, 2, 23, 18), [50, 51])

	# El mosaico de la Explanada (suelo, bajo los pies).
	for x: int in range(4, 56, 4):
		p.object_under(&"explanada_mosaico", Vector2i(x, 46))

	# Monumentos.
	p.object(&"castillo_santa_barbara", Vector2i(52, 12))
	p.object(&"concatedral_san_nicolas", Vector2i(24, 33))
	p.object(&"casa_carbonell", Vector2i(16, 43))
	# El resto de la ciudad.
	for b: Array in [
		[&"bloque_pisos", Vector2i(2, 9)], [&"oficinas_azules", Vector2i(10, 9)],
		[&"grandes_almacenes", Vector2i(19, 9)],            # los grandes almacenes de Maisonnave
		[&"bloque_verde", Vector2i(28, 9)], [&"casa_dos_aguas", Vector2i(41, 9)],
		[&"gimnasio_madera", Vector2i(2, 20)],              # el club de artes marciales
		[&"tienda_azul", Vector2i(21, 20)],                 # Basic-Fit
		[&"teatro", Vector2i(28, 20)],                      # Teatro Principal
		[&"tienda_verde", Vector2i(2, 32)],                 # Mercadona
		[&"tienda_morada", Vector2i(9, 32)],                # estanco
		[&"casa_rosa", Vector2i(16, 32)],
		[&"oficinas_verdes", Vector2i(41, 33)],             # el Ayuntamiento
		[&"bloque_verde_2", Vector2i(4, 43)],               # hotel de la Explanada
		[&"centro_pokemon", Vector2i(26, 43)],
		[&"edificio_cupula", Vector2i(41, 43)], [&"tienda_naranja", Vector2i(48, 43)],   # la heladería
		# Barrio de Santa Cruz.
		[&"casa_ibicenca", Vector2i(49, 26)], [&"casa_ibicenca", Vector2i(54, 26)],
		[&"casa_ibicenca", Vector2i(49, 31)], [&"casa_ibicenca", Vector2i(54, 31)],
	]:
		p.object(b[0], b[1])
	p.object(&"fuente_plaza", Vector2i(14, 19))             # la fuente de los Luceros
	for x: int in [6, 14, 22, 30, 42, 50]:
		p.object(&"palmera", Vector2i(x, 47))
	for cell: Vector2i in [Vector2i(11, 16), Vector2i(18, 16), Vector2i(34, 24), Vector2i(0, 38)]:
		p.object(&"farola_verde", cell)
	# Más calle: casas, el quiosco de la playa, puestos del mercado, árboles y jardineras.
	p.object(&"casa_naranja", Vector2i(41, 20))
	p.object(&"puesto_mercado", Vector2i(54, 43))
	p.object(&"puesto_mercado", Vector2i(30, 13))
	for cell: Vector2i in [Vector2i(2, 25), Vector2i(22, 25), Vector2i(33, 31), Vector2i(8, 13), Vector2i(16, 13)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(9, 37), Vector2i(41, 23), Vector2i(26, 23)]:
		p.object(&"jardinera", cell)
	for cell: Vector2i in [Vector2i(48, 9), Vector2i(66, 13)]:
		p.object(&"pino", cell)
	for cell: Vector2i in [Vector2i(9, 25), Vector2i(17, 25)]:
		p.object(&"banco", cell)
	# El puerto y la playa.
	p.object(&"barca_albufera", Vector2i(8, 55))
	p.object(&"barca_albufera", Vector2i(22, 57))
	p.object(&"barca_albufera", Vector2i(40, 55))
	p.object(&"sombrilla", Vector2i(60, 38))
	p.object(&"sombrilla", Vector2i(66, 42))
	p.object(&"torre_socorrista", Vector2i(67, 37))
	for cell: Vector2i in [Vector2i(49, 6), Vector2i(66, 9), Vector2i(49, 15), Vector2i(65, 16)]:
		p.deco(cell, ExteriorTiles.ROCK)

	# --- Carteles ---
	p.deco(Vector2i(35, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelNorte", Vector2i(35, 2), PackedStringArray(["ALICANTE · ALACANT.",
		"↑ Ruta 10 · Costa Blanca.   ↓ Explanada y puerto."]))
	p.deco(Vector2i(27, 10), ExteriorTiles.SIGN)
	p.sign_text("CartelAlmacenes", Vector2i(27, 10), PackedStringArray(["GRANDES ALMACENES.",
		"Ya es primavera. Desde enero."]))
	p.deco(Vector2i(10, 21), ExteriorTiles.SIGN)
	p.sign_text("CartelClub", Vector2i(10, 21), PackedStringArray(["CLUB DE ARTES MARCIALES.",
		"De aquí salió un campeón del mundo. Lo dice él mismo en cuanto entras, por si no lo sabías."]))
	p.deco(Vector2i(19, 19), ExteriorTiles.SIGN)
	p.sign_text("CartelLuceros", Vector2i(19, 19), PackedStringArray(["PLAZA DE LOS LUCEROS.",
		"Aquí se dispara la mascletà de las Hogueras. La fuente lleva un siglo aguantando la respiración."]))
	p.deco(Vector2i(32, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelConcatedral", Vector2i(32, 34), PackedStringArray(["CONCATEDRAL DE SAN NICOLÁS (1662).",
		"La cúpula azul mide 45 metros. Debajo hubo una mezquita; debajo de la mezquita, seguramente un bar."]))
	p.deco(Vector2i(24, 44), ExteriorTiles.SIGN)
	p.sign_text("CartelCarbonell", Vector2i(24, 44), PackedStringArray(["CASA CARBONELL (1925).",
		"Cuentan que al dueño, un fabricante de tejidos, no le dejaron entrar en el hotel de al lado por las pintas. Se hizo este, más grande, pegado."]))
	p.deco(Vector2i(36, 44), ExteriorTiles.SIGN)
	p.sign_text("CartelExplanada", Vector2i(36, 44), PackedStringArray(["EXPLANADA DE ESPAÑA.",
		"Seis millones y medio de teselas. Si miras fijo las ondas, te mareas gratis."]))
	p.deco(Vector2i(52, 20), ExteriorTiles.SIGN)
	p.sign_text("CartelCastillo", Vector2i(52, 20), PackedStringArray(["↑ CASTILLO DE SANTA BÁRBARA.",
		"Ascensor por dentro de la montaña: averiado. Suba por la cuesta, que es más auténtico."]))
	p.deco(Vector2i(1, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelOeste", Vector2i(1, 33), PackedStringArray(["← RUTA 11 · Palmeral de Elche.",
		"Doscientas mil palmeras. Las contó alguien con mucho tiempo."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(37, 1))
	p.spawn("from_ruta_10", Vector2i(37, 0))
	p.spawn("from_ruta_11", Vector2i(0, 35))
	p.trainer("Nacho", &"alc_regatista", Vector2i(34, 48), UP, 3)
	p.trainer("Lucia", &"alc_nadadora", Vector2i(64, 40), LEFT, 3)
	p.trainer("Borja", &"alc_luchador", Vector2i(12, 21), DOWN, 3)
	p.npc("Foguerer", "npc_man", Vector2i(18, 22), DOWN, PackedStringArray([
		"En junio plantamos las Hogueras y la noche de San Juan las quemamos.",
		"Los de Valencia dicen que les copiamos las Fallas. Ellos queman en marzo, con abrigo: eso no es quemar ni es nada."]))
	p.npc("Abuelo", "npc_old_man", Vector2i(33, 44), DOWN, PackedStringArray([
		"Me siento aquí cada tarde a ver pasar cruceristas. Bajan tres mil, compran un imán y se vuelven al barco."]))
	p.npc("Guia", "npc_woman", Vector2i(60, 14), DOWN, PackedStringArray([
		"Desde la playa, la montaña tiene cara: la Cara del Moro. Desde aquí arriba solo se ven hoteles.",
		"El castillo aguantó a franceses, ingleses y piratas. Con los pisos turísticos ya veremos."]))
	p.npc("Tendera", "npc_woman", Vector2i(35, 14), LEFT, PackedStringArray([
		"¡Turrón de Jijona y de Alicante! El blando y el duro. El que rompe muelas es el de Alicante, que conste."]))
	p.npc("Crucerista", "npc_boy", Vector2i(46, 45), DOWN, PackedStringArray([
		"Tengo cuatro horas de escala. Ya he visto el castillo desde abajo y me he comprado un imán. ¿Me falta algo?"]))
	p.npc("Vecina", "npc_old_woman", Vector2i(53, 28), DOWN, PackedStringArray([
		"En Santa Cruz quedamos cuatro vecinas y cuarenta pisos turísticos. Las macetas las riego yo todas."]))
	load("res://maps/_pintura/servicios_locales.gd").apply(p, "alicante", "alicante/exterior",
		JsonFile.read_dict("res://maps/_pintura/locales.json")["alicante"])
	return p
