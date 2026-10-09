extends SceneTree
## Pinta la Ruta 4 · El Escorial y Galapagar (maps/ruta_4/exterior.tscn), de la sierra a Madrid
## (docs/mundo/rutas.md): arriba a la izquierda, el Monte Abantos y la Silla de Felipe II; el
## Monasterio de El Escorial con su lonja y unas casas de San Lorenzo; hacia el este, la
## urbanización de chalets de Galapagar con sus setos, y al sur la dehesa de encinas. La calle
## sale por el este hacia Madrid (Moncloa, por la A-6). Se une sin fundido con la Ruta 3 por el
## norte (mismas columnas).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_4.gd -- --force

const OUT := "res://maps/ruta_4/exterior.tscn"
const SIZE := Vector2i(52, 46)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_4: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_4/exterior"
	data.display_name = "Ruta 4 · El Escorial y Galapagar"
	data.zone_id = &"ruta_4"
	data.encounter_table = &"ruta_4"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("Ruta4", SIZE, data, 1563)
	p.fill_grass(0.2)
	p.connect_edge("north", &"ruta_3/exterior")

	# La lonja del Monasterio y la calle que cruza la urbanización hacia Madrid.
	p.paving(Rect2i(0, 25, 26, 5))
	p.paving(Rect2i(18, 30, 34, 3))
	p.paving(Rect2i(28, 41, 24, 2))
	p.paving(Rect2i(50, 33, 2, 8))
	p.build_paving()

	# Camino de la sierra a la lonja y senda de la Silla de Felipe II.
	p.terrain(rects([
		Rect2i(20, 0, 3, 25), Rect2i(14, 4, 6, 2), Rect2i(14, 6, 2, 4),
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(23, 2, 4, 8), Rect2i(2, 33, 12, 7), Rect2i(16, 36, 9, 6),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Monte Abantos (pinar) y bosquetes; la dehesa de encinas al sur.
	for r: Rect2i in [Rect2i(0, 0, 12, 4), Rect2i(0, 4, 8, 12), Rect2i(28, 0, 24, 6), Rect2i(44, 6, 8, 10),
			Rect2i(0, 40, 2, 6), Rect2i(14, 42, 14, 4)]:
		p.forest(r)
	p.build_forest()

	# El Monasterio de El Escorial (fachada de poniente) y casas de San Lorenzo.
	p.object(&"monasterio_escorial", Vector2i(2, 24))
	p.object(&"casa_granero", Vector2i(23, 22))
	p.object(&"casa_madera", Vector2i(28, 15))
	p.object(&"casa_dos_aguas", Vector2i(33, 15))

	# Urbanización de Galapagar: chalets con seto, a los dos lados de la calle.
	p.object(&"casa_azul", Vector2i(28, 29))
	p.object(&"casa_tejado_rojo", Vector2i(36, 29))   # el chalet de la colina
	p.object(&"casa_roja_chimenea", Vector2i(44, 29))
	p.object(&"casa_roja", Vector2i(29, 40))
	p.object(&"casa_azul_pequena", Vector2i(37, 40))
	p.object(&"casa_naranja", Vector2i(43, 40))
	for x: Array in [[27, 27], [35, 35], [43, 43], [49, 51]]:
		p.hedge(x[0], x[1], 29)
	p.hedge(27, 51, 22)
	for x: Array in [[28, 28], [36, 36], [42, 42], [47, 49]]:
		p.hedge(x[0], x[1], 40)
	p.object(&"sombrilla", Vector2i(47, 38))

	# Encinas de la dehesa, árboles sueltos y la Silla de Felipe II (rocas en el monte).
	for cell: Vector2i in [Vector2i(4, 44), Vector2i(10, 45), Vector2i(26, 39), Vector2i(1, 32), Vector2i(14, 32),
			Vector2i(40, 45)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"arbol_redondo", Vector2i(46, 45))
	p.object(&"pino", Vector2i(24, 14))
	for cell: Vector2i in [Vector2i(12, 8), Vector2i(13, 9), Vector2i(12, 10), Vector2i(19, 18), Vector2i(18, 13)]:
		p.deco(cell, ExteriorTiles.ROCK)
	p.flowers(Rect2i(14, 14, 3, 2), 0.4)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(19, 1), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(19, 1), PackedStringArray(["RUTA 4 · EL ESCORIAL Y GALAPAGAR",
		"↑ Puerto de Navacerrada   → Madrid"]))
	p.deco(Vector2i(11, 9), ExteriorTiles.SIGN)
	p.sign_text("CartelSilla", Vector2i(11, 9), PackedStringArray(["SILLA DE FELIPE II.",
		"Desde aquí veía el rey cómo iban las obras del Monasterio. Tardaron 21 años. Hoy sería récord."]))
	p.deco(Vector2i(23, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelMonasterio", Vector2i(23, 27), PackedStringArray([
		"REAL MONASTERIO DE SAN LORENZO DE EL ESCORIAL.",
		"Mandado construir por Felipe II (1563–1584). Panteón de los reyes de España."]))
	p.deco(Vector2i(26, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelUrbanizacion", Vector2i(26, 33), PackedStringArray(["URBANIZACIÓN PRIVADA.",
		"Prohibido el paso a vehículos, peatones, vecinos de otras urbanizaciones y periodistas."]))
	p.deco(Vector2i(49, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelMadrid", Vector2i(49, 33), PackedStringArray(["A-6 → MADRID (Moncloa).",
		"Atasco previsto: sí."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(21, 1))
	p.spawn("from_route_3", Vector2i(21, 0))
	p.trainer("Alvaro", &"ruta4_alvaro", Vector2i(31, 33), UP, 3)
	p.trainer("Carla", &"ruta4_carla", Vector2i(40, 30), DOWN, 2)
	p.npc("Fraile", "npc_old_man", Vector2i(10, 26), DOWN, PackedStringArray([
		"Los agustinos cuidamos el Monasterio desde 1885. La parrilla de San Lorenzo, no: esa la cuida el horno.",
		"Dicen que la planta del edificio tiene forma de parrilla, por el martirio del santo."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(34, 33), LEFT, PackedStringArray([
		"Ese chalet de la colina tiene piscina, cámaras y dos guardias civiles en la puerta.",
		"Antes los dueños vivían en Vallecas. Ahora vienen a la urbanización a hablar de los barrios."]))
	return p
