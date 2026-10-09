extends SceneTree
## Pinta Sevilla · Centro (maps/sevilla/centro.tscn) con el plano real docs/mundo/planos/sevilla.svg
## (norte arriba; docs/mundo/ciudades/sevilla.md): las Setas en la Plaza de la Encarnación al norte; la
## Avenida de la Constitución de norte a sur, con el Centro Pokémon; la Catedral con la Giralda en su
## esquina; el Real Alcázar con la Puerta del León al sur; el barrio de Santa Cruz al este, con sus
## callejones, naranjos y el estanco; y los jardines del Alcázar al sureste. Se une sin fundido con la
## Ruta 13 (este), Sevilla · Río (oeste) y Sevilla · María Luisa (sur).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_sevilla_centro.gd -- --force

const OUT := "res://maps/sevilla/centro.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_sevilla_centro: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"sevilla/centro"
	data.display_name = "Sevilla · Centro"
	data.zone_id = &"sevilla"
	data.encounter_table = &"sevilla"
	data.region_map_position = Vector2i(8, 20)
	var p: RefCounted = painter.new("SevillaCentro", SIZE, data, 1929)
	p.fill_grass(0.1)
	p.connect_edge("east", &"ruta_13/exterior", 0, Vector2i(14, 26))
	p.connect_edge("west", &"sevilla/rio", 0, Vector2i(18, 34))
	p.connect_edge("south", &"sevilla/maria_luisa", -10, Vector2i(30, 46))

	# Toda la ciudad pavimentada; los jardines del Alcázar, con su hierba.
	p.paving(Rect2i(0, 0, 64, 44))
	p.paving(Rect2i(0, 44, 48, 12))
	p.build_paving()

	# Norte: bloques de pisos y las Setas en la Plaza de la Encarnación.
	for b: Array in [[&"bloque_pisos", Vector2i(1, 8)], [&"casa_teja", Vector2i(8, 8)], [&"oficinas_verdes", Vector2i(40, 9)],
			[&"bloque_verde_2", Vector2i(50, 6)], [&"casa_rosa", Vector2i(18, 6)]]:
		p.object(b[0], b[1])
	p.object(&"setas", Vector2i(26, 12))
	# Más ciudad: la calle que viene de la Ruta 13 (filas 21-25) entre manzanas, el oeste de la Avenida y el
	# Archivo de Indias entre la Catedral y el Alcázar.
	for b: Array in [[&"edificio_cupula", Vector2i(58, 12)], [&"casa_roja_chimenea", Vector2i(37, 20)],
			[&"casa_granero", Vector2i(43, 20)], [&"bloque_pisos", Vector2i(48, 20)], [&"casa_madera", Vector2i(55, 20)],
			[&"casa_teja", Vector2i(1, 41)], [&"casa_rosa", Vector2i(7, 41)], [&"bloque_pisos", Vector2i(1, 53)],
			[&"casa_tejado_azul", Vector2i(7, 53)], [&"oficinas_azules", Vector2i(31, 47)]]:
		p.object(b[0], b[1])
	# La Avenida de la Constitución (x 14-17) con el Centro Pokémon, el Mercadona y el Basic-Fit.
	p.object(&"centro_pokemon_grande", Vector2i(5, 27))
	p.object(&"tienda_verde", Vector2i(19, 20))        # Mercadona
	p.object(&"tienda_naranja", Vector2i(25, 21))      # Basic-Fit
	# La Catedral con la Giralda en su esquina, y el Real Alcázar.
	p.object(&"catedral_sevilla", Vector2i(19, 40))
	p.object(&"giralda", Vector2i(27, 40))
	p.object(&"puerta_leon", Vector2i(21, 51))
	p.hedge(14, 20, 51)
	p.hedge(27, 29, 51)
	# El barrio de Santa Cruz: casas encaladas, callejones, naranjos y el estanco.
	for cell: Vector2i in [Vector2i(36, 33), Vector2i(41, 33), Vector2i(46, 33), Vector2i(36, 39), Vector2i(42, 39),
			Vector2i(48, 39), Vector2i(53, 36), Vector2i(58, 33), Vector2i(58, 42)]:
		p.object(&"casa_ibicenca", cell)
	p.object(&"tienda_morada", Vector2i(52, 42))       # Estanco
	for cell: Vector2i in [Vector2i(50, 32), Vector2i(32, 31)]:
		p.object(&"manzano", cell)                      # naranjos
	p.flowers(Rect2i(40, 34, 1, 2), 0.2)
	p.flowers(Rect2i(45, 40, 2, 1), 0.5)
	# Jardines del Alcázar.
	p.object(&"fuente_plaza", Vector2i(54, 51))
	for cell: Vector2i in [Vector2i(49, 55), Vector2i(59, 55), Vector2i(49, 49)]:
		p.object(&"palmera", cell)
	p.hedge(52, 62, 46)
	p.flowers(Rect2i(52, 53, 2, 2), 0.3)
	p.flowers(Rect2i(58, 47, 3, 2), 0.4)
	for cell: Vector2i in [Vector2i(36, 13), Vector2i(12, 34), Vector2i(34, 26)]:
		p.object(&"palmera", cell)
	for cell: Vector2i in [Vector2i(16, 30), Vector2i(16, 44)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(31, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelGiralda", Vector2i(31, 41), PackedStringArray(["LA GIRALDA.",
		"Alminar almohade del siglo XII con campanario cristiano encima: 104 metros. Se sube por rampas, que en",
		"la época subían a caballo. Hoy se sube a pie y se baja con agujetas."]))
	p.deco(Vector2i(18, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelCatedral", Vector2i(18, 41), PackedStringArray(["CATEDRAL DE SANTA MARÍA DE LA SEDE.",
		"La catedral gótica más grande del mundo. Dentro está la tumba de Colón. O parte de Colón: lo demás",
		"está en Santo Domingo, según a quién preguntes."]))
	p.deco(Vector2i(34, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelSetas", Vector2i(34, 12), PackedStringArray(["METROPOL PARASOL · LAS SETAS.",
		"La estructura de madera más grande del mundo. Costó el doble de lo previsto. Muy sevillano y muy español."]))
	p.deco(Vector2i(20, 52), ExteriorTiles.SIGN)
	p.sign_text("CartelAlcazar", Vector2i(20, 52), PackedStringArray(["REAL ALCÁZAR · PUERTA DEL LEÓN.",
		"Palacio real en uso más antiguo de Europa. Aquí se rodó Juego de Tronos: el trono, de momento, sigue libre."]))
	p.deco(Vector2i(37, 46), ExteriorTiles.SIGN)
	p.sign_text("CartelArchivo", Vector2i(37, 46), PackedStringArray(["ARCHIVO GENERAL DE INDIAS.",
		"Ochenta millones de páginas sobre América. Aquí se guarda hasta la factura de las carabelas. Sin pagar."]))
	p.deco(Vector2i(35, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelSantaCruz", Vector2i(35, 34), PackedStringArray(["BARRIO DE SANTA CRUZ.",
		"Callejones de la antigua judería. Hay más pisos turísticos que vecinos y más vecinos que sitio para tender."]))
	p.deco(Vector2i(62, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelEste", Vector2i(62, 13), PackedStringArray(["→ Ruta 13 · Mar de olivos (Córdoba).",
		"Agua y gorra: en Sevilla en agosto no se combate, se sobrevive."]))
	p.deco(Vector2i(38, 54), ExteriorTiles.SIGN)
	p.sign_text("CartelSur", Vector2i(38, 54), PackedStringArray(["↓ Parque de María Luisa y Plaza de España."]))
	p.deco(Vector2i(1, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelOeste", Vector2i(1, 17), PackedStringArray(["← El río: Torre del Oro, la Maestranza y Triana.",
		"En Triana está el club de la comedia: GIMNASIO POKÉMON DE SEVILLA."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(60, 19))
	p.spawn("from_ruta_13", Vector2i(63, 19))
	p.spawn("from_rio", Vector2i(0, 25))
	p.spawn("from_maria_luisa", Vector2i(37, 55))
	p.trainer("Antonio", &"sevilla_costalero", Vector2i(24, 30), DOWN, 3)
	p.trainer("Rocio", &"sevilla_flamenca", Vector2i(45, 26), LEFT, 3)
	p.npc("Cochero", "npc_old_man", Vector2i(29, 44), DOWN, PackedStringArray([
		"¿Un paseo en coche de caballos? Cincuenta euros la media hora. El caballo cobra en zanahorias.",
		"Este verano subimos a sesenta: el calor también se cobra."]))
	p.npc("Guia", "npc_lass", Vector2i(18, 32), RIGHT, PackedStringArray([
		"¿Sabías que la Giralda tiene 35 rampas? Me lo sé porque las subo diez veces al día. Por la mañana."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(40, 41), UP, PackedStringArray([
		"Llevo ochenta años en Santa Cruz. Ahora mis vecinos son maletas con ruedas. Bueno, al menos saludan."]))
	p.npc("Turista", "npc_woman", Vector2i(29, 14), UP, PackedStringArray([
		"Las Setas de día son bonitas y de noche dan sombra. En Sevilla, eso vale más que el oro."]))
	return p
