extends SceneTree
## Pinta Murcia (maps/murcia/exterior.tscn) con el plano real docs/mundo/planos/murcia.svg (norte arriba;
## docs/mundo/ciudades/murcia.md): al norte, el Teatro Romea, la Universidad y la plaza Circular; en el
## centro, la Catedral con su torre y su imafronte barroco en la plaza del Cardenal Belluga, el Real
## Casino y la plaza de las Flores; al oeste, el paseo del Malecón; el río Segura de lado a lado, con el
## Puente Viejo, otro puente y la sardina que sale del agua; y al sur, el barrio del Carmen con el
## jardín de Floridablanca y la huerta. Por el este llega la Ruta 11 y por el oeste sale la Ruta 12.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_murcia.gd -- --force

const OUT := "res://maps/murcia/exterior.tscn"
const SIZE := Vector2i(72, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_murcia: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"murcia/exterior"
	data.display_name = "Murcia"
	data.zone_id = &"murcia"
	data.encounter_table = &"murcia"
	data.region_map_position = Vector2i(20, 18)
	var p: RefCounted = painter.new("Murcia", SIZE, data, 825)
	p.fill_grass(0.2)
	p.connect_edge("east", &"ruta_11/exterior", 2, Vector2i(14, 18))
	p.connect_edge("west", &"ruta_12/exterior", -4, Vector2i(30, 33))

	# La ciudad al norte del río; al sur, el barrio del Carmen (el jardín de Floridablanca queda en verde).
	p.paving(Rect2i(0, 0, SIZE.x, 37))
	p.paving(Rect2i(0, 43, 36, 3))
	p.paving(Rect2i(10, 46, 26, 10))
	p.paving(Rect2i(36, 43, 16, 3))
	p.paving(Rect2i(52, 43, 20, 13))
	p.build_paving()
	p.terrain(Pintor.cells(Rect2i(38, 48, 10, 6)), ExteriorTiles.TERRAIN_TALL_GRASS)
	# El Segura, con el hueco de los dos puentes (debajo hay suelo pisable).
	for r: Rect2i in [Rect2i(0, 38, 30, 5), Rect2i(34, 38, 18, 5), Rect2i(56, 38, 16, 5)]:
		p.water(r)
	p.build_water(0.15)
	p.object_under(&"puente_piedra", Vector2i(30, 44))      # el Puente Viejo
	p.object_under(&"puente_piedra", Vector2i(52, 44))
	p.object(&"sardina_segura", Vector2i(40, 41))

	# La Catedral, en la plaza del Cardenal Belluga.
	p.object(&"catedral_murcia", Vector2i(34, 30))
	for b: Array in [
		[&"bloque_pisos", Vector2i(2, 12)],
		[&"teatro", Vector2i(10, 12)],                      # Teatro Romea
		[&"oficinas_verdes", Vector2i(20, 12)],             # la Universidad
		[&"bloque_verde", Vector2i(38, 12)], [&"centro_pokemon", Vector2i(48, 12)],
		[&"bloque_pisos", Vector2i(56, 12)], [&"casa_dos_aguas", Vector2i(64, 12)],
		[&"tienda_flores", Vector2i(2, 26)],                # plaza de las Flores
		[&"puesto_mercado", Vector2i(10, 26)],              # pasteles de carne
		[&"tienda_verde", Vector2i(16, 26)],                # Mercadona
		[&"edificio_cupula", Vector2i(24, 26)],             # Real Casino
		[&"tienda_morada", Vector2i(48, 26)],               # estanco
		[&"tienda_azul", Vector2i(55, 26)],                 # Basic-Fit
		[&"casa_roja_chimenea", Vector2i(62, 26)],
		[&"bloque_verde_2", Vector2i(22, 35)],              # Palacio Episcopal
		[&"oficinas_azules", Vector2i(46, 35)],             # el anexo del Ayuntamiento, de Moneo
		[&"casa_naranja", Vector2i(58, 35)], [&"casa_madera", Vector2i(64, 35)],
		# Barrio del Carmen.
		[&"casa_madera", Vector2i(12, 54)], [&"bloque_pisos", Vector2i(18, 54)],
		[&"tienda_naranja", Vector2i(25, 54)],
		[&"casa_naranja", Vector2i(58, 54)], [&"casa_dos_aguas", Vector2i(64, 54)],
	]:
		p.object(b[0], b[1])
	p.object(&"fuente_plaza", Vector2i(31, 9))              # plaza Circular
	p.object(&"busto", Vector2i(36, 50))                    # el conde de Floridablanca
	p.object(&"puesto_mercado", Vector2i(30, 26))           # el puesto de limones
	for cell: Vector2i in [Vector2i(30, 19), Vector2i(44, 19), Vector2i(60, 19), Vector2i(68, 19)]:
		p.object(&"arbol_redondo", cell)
	# El Malecón, el jardín y la huerta.
	p.hedge(2, 18, 33)
	for cell: Vector2i in [Vector2i(3, 36), Vector2i(8, 36), Vector2i(13, 36), Vector2i(18, 36), Vector2i(49, 49),
			Vector2i(49, 54), Vector2i(36, 55)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(1, 49), Vector2i(5, 49), Vector2i(1, 54), Vector2i(5, 54)]:   # limoneros de la huerta
		p.object(&"manzano", cell)
	p.flowers(Rect2i(0, 50, 9, 1))
	p.flowers(Rect2i(40, 46, 6, 2))
	for cell: Vector2i in [Vector2i(45, 13), Vector2i(62, 13), Vector2i(31, 33), Vector2i(44, 33)]:
		p.object(&"farola_verde", cell)
	for cell: Vector2i in [Vector2i(8, 30), Vector2i(38, 34), Vector2i(18, 19)]:
		p.object(&"banco", cell)
	for cell: Vector2i in [Vector2i(2, 19), Vector2i(10, 19), Vector2i(52, 19)]:
		p.object(&"jardinera", cell)

	# --- Carteles ---
	p.deco(Vector2i(70, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelEste", Vector2i(70, 13), PackedStringArray(["MURCIA.",
		"Existe. Temperatura: 45 grados a la sombra. Sombra: no hay."]))
	p.deco(Vector2i(46, 19), ExteriorTiles.SIGN)
	p.sign_text("CartelTermometro", Vector2i(46, 19), PackedStringArray(["TERMÓMETRO DE LA GRAN VÍA: 45 °C.",
		"Lleva marcando lo mismo desde 2019. No está roto."]))
	p.deco(Vector2i(16, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRomea", Vector2i(16, 13), PackedStringArray(["TEATRO ROMEA.",
		"Dice la leyenda que arderá tres veces. Lleva dos. La tercera función se agota siempre por si acaso."]))
	p.deco(Vector2i(27, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelUniversidad", Vector2i(27, 13), PackedStringArray(["UNIVERSIDAD DE MURCIA.",
		"Prácticas no remuneradas en toda la huerta. Se valora inglés y tractor."]))
	p.deco(Vector2i(29, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelCasino", Vector2i(29, 27), PackedStringArray(["REAL CASINO DE MURCIA.",
		"Salón de baile, patio árabe y un tocador de señoras con el techo pintado. Aquí no se apuesta: se aparenta."]))
	p.deco(Vector2i(33, 31), ExteriorTiles.SIGN)
	p.sign_text("CartelCatedral", Vector2i(33, 31), PackedStringArray(["CATEDRAL DE MURCIA.",
		"La torre mide 93 metros y tardó más de dos siglos. Se nota: cada cuerpo es de un estilo, según quién mandara."]))
	p.deco(Vector2i(52, 36), ExteriorTiles.SIGN)
	p.sign_text("CartelMoneo", Vector2i(52, 36), PackedStringArray(["ANEXO DEL AYUNTAMIENTO (Moneo, 1998).",
		"Un edificio moderno delante de la catedral barroca. La mitad de Murcia aún no se habla con la otra mitad."]))
	p.deco(Vector2i(34, 37), ExteriorTiles.SIGN)
	p.sign_text("CartelSardina", Vector2i(34, 37), PackedStringArray(["RÍO SEGURA · LA SARDINA.",
		"En las Fiestas de Primavera se entierra la sardina. Quemándola. En Murcia las cosas se hacen así."]))
	p.deco(Vector2i(19, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelMalecon", Vector2i(19, 34), PackedStringArray(["PASEO DEL MALECÓN.",
		"Muro contra las riadas del Segura. Ahora el río baja con lo justo: el agua se queda por el camino, en los campos de golf."]))
	p.deco(Vector2i(35, 47), ExteriorTiles.SIGN)
	p.sign_text("CartelFloridablanca", Vector2i(35, 47), PackedStringArray(["JARDÍN DE FLORIDABLANCA.",
		"El primer jardín público de España. En la hierba alta hay Pokémon y algún opositor a la sombra."]))
	p.deco(Vector2i(1, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelOeste", Vector2i(1, 29), PackedStringArray(["← RUTA 12 · Sierra Nevada y Granada.",
		"Próxima sombra: a 280 km."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(70, 15))
	p.spawn("from_ruta_11", Vector2i(71, 15))
	p.spawn("from_ruta_12", Vector2i(0, 31))
	p.trainer("Perico", &"mur_huertano", Vector2i(9, 48), RIGHT, 3)
	p.trainer("Fuensanta", &"mur_opositora", Vector2i(48, 47), LEFT, 3)
	p.trainer("Gines", &"mur_camarero", Vector2i(14, 28), DOWN, 3)
	p.npc("Pastelero", "npc_man", Vector2i(12, 27), DOWN, PackedStringArray([
		"¡Pastel de carne! Hojaldre por arriba, ternera, huevo y chorizo por dentro. Se come con las manos y sin testigos.",
		"Y una marinera: rosquilla, ensaladilla y anchoa. Si le quitas la anchoa es una bicicleta. No preguntes."]))
	p.npc("Acalorado", "npc_old_man", Vector2i(36, 33), DOWN, PackedStringArray([
		"Estoy bien, zagal. Solo me he sentado a la sombra de la torre. En mayo. Vuelvo a casa en octubre."]))
	p.npc("Estudiante", "npc_girl", Vector2i(25, 14), DOWN, PackedStringArray([
		"Cuando digo que soy de Murcia me contestan que Murcia no existe. Luego bien que se comen mis tomates."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(31, 46), RIGHT, PackedStringArray([
		"Por este puente pasaba la Virgen de la Fuensanta cuando no llovía. Sigue pasando. Sigue sin llover."]))
	load("res://maps/_pintura/servicios_locales.gd").apply(p, "murcia", "murcia/exterior",
		JsonFile.read_dict("res://maps/_pintura/locales.json")["murcia"])
	return p
