extends SceneTree
## Pinta Sevilla · Río (maps/sevilla/rio.tscn) con el plano real docs/mundo/planos/sevilla.svg (norte
## arriba; docs/mundo/ciudades/sevilla.md): el Guadalquivir de norte a sur; en la orilla este, el Paseo
## de Colón con la Real Maestranza y la Torre del Oro; el Puente de Triana (Isabel II) cruzando el río;
## y en la orilla oeste, Triana: la calle Betis, las casas encaladas, el mercado y la cerámica, y el club
## de la comedia (GIMNASIO 4, Joaquín). Se une sin fundido con Sevilla · Centro (este) y con la Ruta 14
## (oeste).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_sevilla_rio.gd -- --force

const OUT := "res://maps/sevilla/rio.tscn"
const SIZE := Vector2i(56, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_sevilla_rio: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"sevilla/rio"
	data.display_name = "Sevilla · Río y Triana"
	data.zone_id = &"sevilla"
	data.encounter_table = &"sevilla"
	data.region_map_position = Vector2i(8, 20)
	var p: RefCounted = painter.new("SevillaRio", SIZE, data, 1992)
	p.fill_grass(0.1)
	p.connect_edge("east", &"sevilla/centro", 0, Vector2i(18, 34))
	p.connect_edge("west", &"ruta_14/exterior", 0, Vector2i(20, 32))

	p.paving(Rect2i(0, 0, 56, 56))
	p.build_paving()
	# El Guadalquivir, con el hueco del tablero del Puente de Triana (filas 22-23).
	p.water(Rect2i(22, 0, 12, 22))
	p.water(Rect2i(22, 24, 12, 32))
	p.build_water(0.25)
	p.object_under(&"puente_triana", Vector2i(22, 24))

	# Orilla este: el Paseo de Colón, la Maestranza y la Torre del Oro.
	p.object(&"maestranza", Vector2i(40, 14))
	p.object(&"torre_octogonal", Vector2i(36, 46))     # Torre del Oro
	for b: Array in [[&"casa_teja", Vector2i(49, 13)], [&"oficinas_azules", Vector2i(44, 34)],
			[&"bloque_pisos", Vector2i(50, 46)], [&"teatro_real", Vector2i(42, 54)], [&"casa_dos_aguas", Vector2i(49, 24)],
			[&"casa_granero", Vector2i(39, 24)], [&"casa_madera", Vector2i(44, 24)], [&"casa_roja_chimenea", Vector2i(38, 6)],
			[&"casa_teja", Vector2i(43, 7)]]:
		p.object(b[0], b[1])
	for y: int in [6, 30, 38, 52]:
		p.object(&"palmera", Vector2i(34, y))
	# Orilla oeste: Triana.
	p.object(&"teatro", Vector2i(8, 31))               # el club de la comedia
	p.object(&"puesto_mercado", Vector2i(13, 16))      # Mercado de Triana
	p.object(&"tienda_flores", Vector2i(2, 16))        # cerámica de Triana
	for cell: Vector2i in [Vector2i(2, 6), Vector2i(7, 6), Vector2i(12, 6), Vector2i(17, 6), Vector2i(2, 44),
			Vector2i(7, 44), Vector2i(12, 44), Vector2i(17, 44), Vector2i(2, 52), Vector2i(12, 52), Vector2i(16, 37),
			Vector2i(7, 52), Vector2i(17, 52), Vector2i(2, 37), Vector2i(17, 22)]:
		p.object(&"casa_ibicenca", cell)
	for cell: Vector2i in [Vector2i(19, 15), Vector2i(19, 30)]:
		p.object(&"farola_roja", cell)
	p.flowers(Rect2i(15, 32, 3, 1), 0.5)

	# --- Carteles ---
	p.deco(Vector2i(14, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelClub", Vector2i(14, 32), PackedStringArray(["EL CLUB DE LA COMEDIA · GIMNASIO POKÉMON DE SEVILLA.",
		"Líder: Joaquín. Tipo Planta. Si te ríes, combates. Si no te ríes, también."]))
	p.deco(Vector2i(41, 46), ExteriorTiles.SIGN)
	p.sign_text("CartelTorreOro", Vector2i(41, 46), PackedStringArray(["TORRE DEL ORO (siglo XIII).",
		"Torre almohade que cerraba el río con una cadena. Del oro no queda nada: se lo llevaron, como siempre."]))
	p.deco(Vector2i(39, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelMaestranza", Vector2i(39, 15), PackedStringArray(["REAL MAESTRANZA DE CABALLERÍA.",
		"Por la Puerta del Príncipe salen a hombros los toreros. Los Pokémon, en camilla."]))
	p.deco(Vector2i(35, 21), ExteriorTiles.SIGN)
	p.sign_text("CartelPuente", Vector2i(35, 21), PackedStringArray(["PUENTE DE ISABEL II · EL PUENTE DE TRIANA.",
		"De hierro, de 1852. Cruzarlo es como cambiar de país, pero sin pasaporte y con más palmas."]))
	p.deco(Vector2i(20, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelBetis", Vector2i(20, 25), PackedStringArray(["CALLE BETIS · TRIANA.",
		"Aquí se vive mirando al río. Y al alquiler, que sube más que el río en marzo."]))
	p.deco(Vector2i(1, 19), ExteriorTiles.SIGN)
	p.sign_text("CartelOeste", Vector2i(1, 19), PackedStringArray(["← Ruta 14 · Doñana y Huelva.",
		"Del puerto de Huelva sale el ferry a Canarias. Lleva crema: allí ya es verano siempre."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(54, 25))
	p.spawn("from_centro", Vector2i(55, 25))
	p.spawn("from_ruta_14", Vector2i(0, 25))
	p.trainer("Macarena", &"sevilla_flamenca_triana", Vector2i(6, 24), RIGHT, 3)
	p.trainer("Hans", &"sevilla_guiri", Vector2i(42, 42), LEFT, 3)
	p.npc("Portero", "npc_man", Vector2i(10, 33), DOWN, PackedStringArray([
		"Joaquín está ensayando el monólogo. Dice que vuelvas con ocho medallas... o con cuatro, que tampoco es tan serio.",
		"El local está en obras: de momento, la puerta no lleva a ningún sitio. Como los chistes de mi cuñado."]))
	p.npc("Ceramista", "npc_woman", Vector2i(5, 17), DOWN, PackedStringArray([
		"Los azulejos de Triana están en medio mundo. El mío está en la cocina de un guiri en Manchester."]))
	p.npc("Remero", "npc_fisherman", Vector2i(35, 10), LEFT, PackedStringArray([
		"Con Surf puedes bajar por el Guadalquivir. Los barcos turísticos van más lentos que tú y cobran más."]))
	return p
