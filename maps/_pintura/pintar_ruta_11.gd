extends SceneTree
## Pinta la Ruta 11 · Palmeral de Elche (maps/ruta_11/exterior.tscn), de Alicante a Murcia por la A-7
## (docs/mundo/rutas.md), de este a oeste: las salinas de Santa Pola con sus flamencos; Elche con el
## Palmeral (hierba alta entre las palmeras) y la Palmera Imperial al norte, y al sur la Basílica de
## Santa María, la Dama de Elche y una fábrica de calzado; la Vega Baja con sus granados y Orihuela, el
## pueblo de Miguel Hernández; y el límite con la Región de Murcia.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_11.gd -- --force

const OUT := "res://maps/ruta_11/exterior.tscn"
const SIZE := Vector2i(76, 34)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_11: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_11/exterior"
	data.display_name = "Ruta 11 · Palmeral de Elche"
	data.zone_id = &"ruta_11"
	data.encounter_table = &"ruta_11"
	data.region_map_position = Vector2i(21, 17)
	var p: RefCounted = painter.new("Ruta11", SIZE, data, 1265)
	p.fill_grass(0.25)
	p.connect_edge("east", &"alicante/exterior", 18, Vector2i(16, 20))
	p.connect_edge("west", &"murcia/exterior", -2, Vector2i(16, 20))

	# La A-7 de este a oeste y las calles de Elche y de Orihuela.
	p.paving(Rect2i(0, 16, SIZE.x, 4))
	p.paving(Rect2i(30, 20, 28, 12))
	p.paving(Rect2i(8, 20, 21, 12))
	p.build_paving()
	# El Palmeral, el saladar y la huerta: hierba alta.
	p.terrain(rects([Rect2i(30, 2, 25, 13), Rect2i(60, 3, 12, 9), Rect2i(1, 22, 6, 8), Rect2i(1, 3, 6, 9)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(rects([Rect2i(9, 14, 18, 2), Rect2i(16, 3, 2, 11)]), ExteriorTiles.TERRAIN_PATH)   # camino de la huerta
	p.water(Rect2i(60, 23, 12, 8))          # las salinas de Santa Pola
	p.build_water(0.3)

	# El Palmeral de Elche y la Palmera Imperial.
	for x: int in [31, 36, 41, 46, 51]:
		p.object(&"palmera", Vector2i(x, 8))
		p.object(&"palmera", Vector2i(x, 14))
	p.object(&"palmera_imperial", Vector2i(56, 14))
	# Elche: la basílica, la Dama y la fábrica de calzado.
	p.object(&"basilica_elche", Vector2i(32, 28))
	p.object(&"dama_elche", Vector2i(40, 25))
	p.object(&"casa_dos_aguas", Vector2i(43, 28))
	p.object(&"nave_logistica", Vector2i(48, 28))
	for cell: Vector2i in [Vector2i(39, 31), Vector2i(53, 31)]:
		p.object(&"palmera", cell)
	# La Vega Baja: frutales en hileras, y Orihuela.
	for x: int in [9, 13, 19, 23]:
		p.object(&"manzano", Vector2i(x, 7))
		p.object(&"manzano", Vector2i(x, 12))
	p.flowers(Rect2i(9, 2, 6, 2))
	p.flowers(Rect2i(19, 2, 7, 2))
	p.object(&"casa_teja", Vector2i(9, 28))
	p.object(&"casa_roja_chimenea", Vector2i(16, 28))
	p.object(&"casa_madera", Vector2i(22, 28))
	p.object(&"busto", Vector2i(27, 23))
	for cell: Vector2i in [Vector2i(60, 14), Vector2i(73, 14), Vector2i(74, 23), Vector2i(58, 31), Vector2i(27, 13)]:
		p.object(&"arbol_redondo", cell)
	p.sprinkle(Rect2i(58, 0, 18, 15), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(74, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(74, 15), PackedStringArray(["RUTA 11 · PALMERAL DE ELCHE",
		"→ Alicante   ← Murcia. Aeropuerto de Alicante-Elche: los dos nombres, para que no discutan."]))
	p.deco(Vector2i(59, 22), ExteriorTiles.SIGN)
	p.sign_text("CartelSalinas", Vector2i(59, 22), PackedStringArray(["SALINAS DE SANTA POLA.",
		"Los flamencos vienen por la sal. Los turistas, por los flamencos. La sal se va en camiones."]))
	p.deco(Vector2i(55, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelPalmeral", Vector2i(55, 15), PackedStringArray(["PALMERAL DE ELCHE · Patrimonio de la Humanidad.",
		"Doscientas mil palmeras que plantaron los árabes. La Palmera Imperial tiene siete brazos y ningún cuñado que los pode."]))
	p.deco(Vector2i(38, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelBasilica", Vector2i(38, 29), PackedStringArray(["BASÍLICA DE SANTA MARÍA.",
		"Aquí se canta el Misteri d'Elx desde la Edad Media. Un ángel baja del techo colgado de una cuerda, sin prevención de riesgos."]))
	p.deco(Vector2i(42, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelDama", Vector2i(42, 25), PackedStringArray(["DAMA DE ELCHE (copia).",
		"La de verdad está en Madrid desde 1941. En Elche la piden cada año; en Madrid contestan que ya si eso."]))
	p.deco(Vector2i(47, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelCalzado", Vector2i(47, 29), PackedStringArray(["FÁBRICA DE CALZADO.",
		"Zapato cosido en Elche, etiqueta puesta en Italia. Se buscan aparadoras: contrato de palabra, sueldo de susurro."]))
	p.deco(Vector2i(29, 24), ExteriorTiles.SIGN)
	p.sign_text("CartelOrihuela", Vector2i(29, 24), PackedStringArray(["ORIHUELA · Busto de Miguel Hernández.",
		"Poeta y pastor de cabras. Murió en la cárcel en 1942. El instituto, la calle y el aeropuerto llevan ahora su nombre."]))
	p.deco(Vector2i(2, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelMurcia", Vector2i(2, 15), PackedStringArray(["← REGIÓN DE MURCIA.",
		"Bienvenido. Sí, existe. No, no hace falta que lo comentes."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(74, 17))
	p.spawn("from_alicante", Vector2i(75, 17))
	p.spawn("from_murcia", Vector2i(0, 17))
	p.trainer("Carmen", &"ruta11_ornitologa", Vector2i(66, 21), UP, 3)
	p.trainer("Sergio", &"ruta11_estudiante", Vector2i(44, 15), DOWN, 3)
	p.trainer("Pencho", &"ruta11_huertano", Vector2i(21, 15), DOWN, 3)
	p.npc("Aparadora", "npc_old_woman", Vector2i(50, 30), DOWN, PackedStringArray([
		"Llevo cuarenta años cosiendo zapatos en la cocina de mi casa. Cotizados tengo once.",
		"El par sale de aquí a doce euros y lo verás en un escaparate a doscientos. Algo se pierde por el camino."]))
	p.npc("Palmerero", "npc_man", Vector2i(34, 15), UP, PackedStringArray([
		"Subo a las palmeras con una cuerda y una hoz. El seguro no lo quiere ni oír.",
		"El picudo rojo se come una palmera en un año. Es el único bicho que aquí trabaja más que yo."]))
	p.npc("Huertana", "npc_woman", Vector2i(12, 14), DOWN, PackedStringArray([
		"Las granadas me las pagan a veinte céntimos el kilo. Este año las dejo en el árbol: me sale más barato.",
		"El trasvase llega cuando llueve en Madrid. Aquí no llueve; aquí se discute."]))
	return p
