extends SceneTree
## Bilbao (docs/mundo/ciudades/bilbao.md). Entra por el oeste desde la Ruta 19 (filas 20–23) y sale por
## el sur a la Ruta 20 (columnas 34–37). La ría cruza de oeste a este y se pasa por dos puentes: el
## Zubizuri y el del Arenal. Al norte: San Mamés (el gimnasio 6; dibujado sobre el del Camp Nou,
## con las gradas rojiblancas), los locales, la Torre Iberdrola, el Guggenheim con Puppy y el Teatro
## Arriaga; arriba a la derecha, Artxanda. Al sur: el parque de Doña Casilda y el Casco Viejo con el
## Mercado de la Ribera, la Plaza Nueva, la catedral de Santiago y las Siete Calles.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_bilbao.gd -- --force

const OUT := "res://maps/bilbao/exterior.tscn"
const SIZE := Vector2i(72, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_bilbao: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	print("%s: %s" % [OUT, error_string(_paint().save(OUT))])
	quit()


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


func _paint() -> Pintor:
	var d := MapData.new()
	d.id = &"bilbao/exterior"
	d.display_name = "Bilbao"
	d.zone_id = &"bilbao"
	d.encounter_table = &"bilbao"
	d.region_map_position = Vector2i(16, 2)
	d.weather = &"rain"
	var p := Pintor.new("Bilbao", SIZE, d, 4646)
	p.fill_grass(0.2)
	p.connect_edge("west", &"ruta_19/exterior", 0, Vector2i(20, 24))
	p.connect_edge("south", &"ruta_20/exterior", 0, Vector2i(34, 38))

	# Calles: el ensanche al norte de la ría, los puentes, la salida al sur y el Casco Viejo.
	p.paving(Rect2i(0, 15, 72, 15))
	p.paving(Rect2i(22, 8, 32, 7))
	p.paving(Rect2i(20, 30, 4, 4))
	p.paving(Rect2i(44, 30, 4, 4))
	p.paving(Rect2i(32, 34, 8, 22))
	p.paving(Rect2i(40, 34, 32, 22))
	p.build_paving()

	# La ría, con los dos puentes sin agua.
	p.water(Rect2i(0, 30, 20, 4))
	p.water(Rect2i(24, 30, 20, 4))
	p.water(Rect2i(48, 30, 24, 4))
	p.build_water(0.25)

	# Norte: San Mamés, los locales, pisos y la Torre Iberdrola.
	p.object(&"san_mames", Vector2i(1, 14))
	p.object(&"tienda_verde", Vector2i(31, 14))
	p.object(&"tienda_morada", Vector2i(37, 14))
	p.object(&"tienda_azul", Vector2i(43, 14))
	p.object(&"bloque_pisos", Vector2i(48, 14))
	p.forest(Rect2i(0, 0, 22, 4))
	p.forest(Rect2i(22, 0, 32, 2))
	# Artxanda: el monte con el mirador y el funicular.
	p.plateau(Rect2i(54, 0, 18, 13), [62, 63])
	p.terrain(rects([Rect2i(56, 2, 14, 7)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"arbol_redondo", Vector2i(55, 10))

	# Junto a la ría: el Guggenheim (provisional, con pieza de museo moderno) y Puppy, la torre, el Arriaga.
	p.object(&"museu_ciencies", Vector2i(3, 28))
	p.flowers(Rect2i(18, 26, 3, 3))
	p.object(&"edificio_cristal", Vector2i(25, 27))
	p.object(&"bloque_verde", Vector2i(35, 27))
	p.object(&"teatro_real", Vector2i(50, 27))
	p.object(&"farola_verde", Vector2i(43, 28))
	p.object(&"farola_verde", Vector2i(60, 28))

	# Sur, al oeste: el parque de Doña Casilda.
	p.pond(Rect2i(4, 38, 9, 6))
	p.terrain(rects([Rect2i(15, 37, 14, 9)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.forest(Rect2i(0, 48, 32, 8))
	for at: Vector2i in [Vector2i(2, 36), Vector2i(13, 46), Vector2i(26, 47), Vector2i(29, 36)]:
		p.object(&"arbol_redondo", at)
	p.flowers(Rect2i(5, 45, 6, 2))

	# El Casco Viejo: Ribera junto a la ría, la Plaza Nueva y las Siete Calles.
	p.object(&"mercado_central", Vector2i(52, 41))
	p.object(&"catedral_burgos", Vector2i(42, 41))
	for x: int in [41, 45, 49]:
		p.object(&"soportales", Vector2i(x, 49))
	p.object(&"soportales_arco", Vector2i(53, 49))
	p.object(&"casa_roja_pequena", Vector2i(58, 49))
	p.object(&"casa_gris", Vector2i(63, 49))
	p.object(&"casa_naranja", Vector2i(68, 49))
	p.object(&"fuente_plaza", Vector2i(47, 54))
	p.object(&"banco", Vector2i(56, 54))
	p.object(&"farola_verde", Vector2i(62, 54))
	p.build_forest()

	_sign(p, "CartelSanMames", Vector2i(22, 16), ["SAN MAMÉS · GIMNASIO 6.",
		"La Catedral del fútbol. Dentro, la grada canta noventa minutos y no se calla ni en el descanso."])
	_sign(p, "CartelGuggenheim", Vector2i(21, 29), ["MUSEO GUGGENHEIM · FRANK GEHRY.",
		"Titanio, cristal y piedra. Delante, Puppy: un perro de doce metros hecho de flores. Le cambian las flores dos veces al año."])
	_sign(p, "CartelZubizuri", Vector2i(19, 34), ["ZUBIZURI · CALATRAVA.", "El suelo de cristal resbala con la lluvia. En Bilbao llueve. Haz las cuentas."])
	_sign(p, "CartelArriaga", Vector2i(58, 23), ["TEATRO ARRIAGA.", "Ópera, teatro y la ría delante. Aquí el drama se paga con entrada."])
	_sign(p, "CartelRibera", Vector2i(63, 36), ["MERCADO DE LA RIBERA.", "Uno de los mercados cubiertos más grandes de Europa. Bacalao, pintxos y señoras que saben más que tú."])
	_sign(p, "CartelSieteCalles", Vector2i(57, 51), ["SIETE CALLES · CASCO VIEJO.", "Pintxo y txikito en cada bar. Se recomienda ir por orden. Nadie lo consigue."])
	_sign(p, "CartelArtxanda", Vector2i(64, 14), ["FUNICULAR DE ARTXANDA.", "Arriba, el mirador de todo Bilbao. El funicular está en obras; la cuesta, no."])
	_sign(p, "CartelTorre", Vector2i(34, 21), ["TORRE IBERDROLA.", "165 metros. Desde arriba se ve la factura de la luz de toda la ciudad."])
	_sign(p, "CartelCasilda", Vector2i(14, 35), ["PARQUE DE DOÑA CASILDA.", "Estanque, patos y cisnes. Los Ducklett no pagan la entrada."])
	_sign(p, "CartelSur", Vector2i(31, 53), ["↓ Ruta 20 · Sierra de Aralar.", "Pamplona al otro lado del monte."])
	_sign(p, "CartelOeste", Vector2i(1, 24), ["← Ruta 19 · Costa de Cantabria."])

	p.spawn("default", Vector2i(12, 18))
	p.spawn("from_ruta_19", Vector2i(0, 21))
	p.spawn("from_ruta_20", Vector2i(35, 55))
	# San Mamés: su puerta lleva al gimnasio 6 (bilbao/gimnasio_1).
	var stadium: Vector2i = p.door_of(&"san_mames", Vector2i(1, 14))
	p.spawn("from_san_mames", stadium + Vector2i.DOWN)
	p.warp("SanMames", stadium, &"bilbao/gimnasio_1", &"default")
	p.root.get_node("Warps/SanMames").arrival_facing = Warp.Facing.UP
	p.trainer("Txikitero", &"bilbao_txikitero", Vector2i(50, 51), LEFT, 3)
	p.trainer("Remera", &"bilbao_remera", Vector2i(40, 29), RIGHT, 3)
	p.npc("Aitona", "npc_old_man", Vector2i(46, 18), DOWN, PackedStringArray([
		"Bilbao es la capital del mundo. Lo sabe todo el mundo, menos el mundo.",
		"¿Que de dónde soy? De Bilbao. ¿Que dónde nací? Donde me dio la gana."]))
	p.npc("Hincha", "npc_youngster", Vector2i(14, 17), DOWN, PackedStringArray([
		"En el Athletic solo juegan los de aquí. Bueno, los de aquí, los de allí y los que tengan una abuela de aquí.",
		"¡Aupa Athletic! ¿Vas al gimnasio? La líder no perdona. La grada, tampoco."]))
	p.npc("Pintxera", "npc_woman", Vector2i(46, 43), DOWN, PackedStringArray([
		"Un pintxo, un euro con ochenta. Dos pintxos, la ruina. Tres, ya eres de aquí.",
		"La gilda: guindilla, anchoa y aceituna. Picante, salada y verde, como el Athletic. No, el Athletic no es verde."]))
	load("res://maps/_pintura/servicios_locales.gd").apply(p, "bilbao", "bilbao/exterior", JsonFile.read_dict("res://maps/_pintura/locales.json")["bilbao"])
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
