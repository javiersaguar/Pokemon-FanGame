extends SceneTree
## Ruta 17 · Galicia interior (docs/mundo/rutas.md). Llueve siempre. Sube desde la Ruta 16 por el sur
## (columnas 16–21), cruza el Miño por un vado, rodea la muralla de Lugo (una meseta de piedra con
## escaleras, la catedral y casas dentro) y sale al este hacia la Ruta 18 (filas 8–11). Al sureste,
## Arteixo: la nave de Inditex. Hórreos junto a las casas de labranza.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_17.gd -- --force

const OUT := "res://maps/ruta_17/exterior.tscn"
const SIZE := Vector2i(64, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_17: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	d.id = &"ruta_17/exterior"
	d.display_name = "Ruta 17 · Galicia interior"
	d.zone_id = &"ruta_17"
	d.encounter_table = &"ruta_17"
	d.region_map_position = Vector2i(4, 3)
	d.weather = &"rain"
	var p := Pintor.new("Ruta17", SIZE, d, 1717)
	p.fill_grass(0.24)
	p.connect_edge("south", &"ruta_16/exterior", 0, Vector2i(16, 22))
	p.connect_edge("east", &"ruta_18/exterior", 0, Vector2i(8, 12))

	# Bosque de robles y eucaliptos en los bordes (pinos del pack), con huecos para las salidas.
	p.forest(Rect2i(0, 0, 24, 2))
	p.forest(Rect2i(42, 0, 22, 6))
	p.forest(Rect2i(0, 2, 2, 26))
	p.forest(Rect2i(48, 14, 16, 2))
	p.forest(Rect2i(60, 16, 4, 12))
	p.forest(Rect2i(0, 34, 14, 6))

	# El Miño cruza de oeste a este; el camino lo vadea por las columnas 16–21.
	p.water(Rect2i(0, 28, 16, 3))
	p.water(Rect2i(22, 28, 42, 3))
	p.build_water(0.3)

	p.terrain(rects([
		Rect2i(16, 22, 6, 18),   # desde la Ruta 16 hacia el norte, cruzando el vado
		Rect2i(16, 22, 30, 4),   # hacia el este, al pie de la muralla
		Rect2i(42, 8, 4, 18),    # hacia el norte
		Rect2i(42, 8, 22, 4),    # salida a la Ruta 18
		Rect2i(31, 16, 2, 6),    # puerta de la muralla
		Rect2i(36, 34, 4, 6),    # camino de Arteixo
		Rect2i(22, 32, 20, 2),
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(2, 31, 12, 3),
		Rect2i(4, 6, 10, 10),
		Rect2i(48, 18, 10, 8),
		Rect2i(24, 26, 16, 2),
		Rect2i(54, 31, 8, 7),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Lugo: la muralla romana es una meseta de piedra; se entra por la escalera de abajo.
	p.plateau(Rect2i(24, 2, 16, 14), [31, 32])
	p.object(&"catedral_burgos", Vector2i(30, 7))
	p.object(&"casa_teja", Vector2i(25, 13))
	p.object(&"casa_rosa", Vector2i(34, 13))
	p.flowers(Rect2i(27, 4, 3, 2))

	# Casas de labranza con su hórreo (el granero hace de hórreo hasta que haya pieza propia).
	p.object(&"casa_dos_aguas", Vector2i(4, 25))
	p.object(&"casa_granero", Vector2i(10, 25))
	p.object(&"casa_madera", Vector2i(46, 38))
	# Arteixo: la nave de Inditex, al otro lado del río.
	p.object(&"nave_logistica", Vector2i(26, 39))
	for at: Vector2i in [Vector2i(14, 19), Vector2i(36, 20), Vector2i(48, 6), Vector2i(56, 38), Vector2i(2, 20)]:
		p.object(&"arbol_redondo", at)
	p.object(&"arbustos", Vector2i(46, 27))
	p.flowers(Rect2i(12, 32, 3, 2))
	p.build_forest()

	_sign(p, "CartelSur", Vector2i(22, 37), ["↓ Ruta 16 · Rías Baixas.", "← Vado del Miño. Si llueve, se moja. Si no llueve, estás en otra ruta."])
	_sign(p, "CartelLugo", Vector2i(33, 17), ["LUGO · MURALLA ROMANA.", "Dos kilómetros de muralla con sus torres. Se puede dar la vuelta entera por arriba. Los romanos no tenían Netflix."])
	_sign(p, "CartelHorreo", Vector2i(15, 22), ["HÓRREO.", "Granero sobre pilares para que no suban los ratones. Los Rattata no se han enterado."])
	_sign(p, "CartelArteixo", Vector2i(40, 36), ["ARTEIXO · SEDE DE INDITEX.", "Aquí se diseña la ropa que llevarás el año que viene. Y la que tirarás el siguiente."])
	_sign(p, "CartelEste", Vector2i(60, 12), ["→ Ruta 18 · Asturias y Picos de Europa.", "Sidra, vacas y cuestas. Muchas cuestas."])

	p.spawn("default", Vector2i(18, 36))
	p.spawn("from_ruta_16", Vector2i(18, 39))
	p.spawn("from_ruta_18", Vector2i(63, 9))
	p.trainer("Peregrina", &"ruta17_peregrina", Vector2i(21, 24), LEFT, 3)
	p.trainer("Marisquero", &"ruta17_marisquero", Vector2i(13, 31), RIGHT, 3)
	p.trainer("Gaiteiro", &"ruta17_gaiteiro", Vector2i(45, 16), LEFT, 3)
	p.npc("Labradora", "npc_old_woman", Vector2i(7, 27), DOWN, PackedStringArray([
		"¿Que si va a dejar de llover? Depende.",
		"Aquí el paraguas se hereda. El mío era de mi abuela y todavía no se ha secado."]))
	p.npc("Pulpeira", "npc_woman", Vector2i(30, 19), DOWN, PackedStringArray([
		"Pulpo á feira: cobre, tijera, aceite, sal gorda y pimentón. Y palillo, nada de tenedor.",
		"En Lugo, con cada vino te ponen una tapa. En Madrid te ponen la cuenta."]))
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
