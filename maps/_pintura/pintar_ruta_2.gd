extends SceneTree
## Pinta la Ruta 2 · Tierra de Pinares y Acueducto (maps/ruta_2/exterior.tscn), de las Hoces del
## Duratón a Segovia (docs/mundo/rutas.md): arriba, los pinares de Cantalejo (resineros y el
## taller de trillos); abajo, Segovia: la plaza del Azoguejo, que cruza de lado a lado el
## Acueducto (se pasa por debajo de los arcos), el mesón del cochinillo y la avenida hacia la
## sierra. Se une sin fundido con la Ruta 1 por el norte y con la Ruta 3 (Puerto de Navacerrada)
## por el sur, en las mismas columnas.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_2.gd -- --force

const OUT := "res://maps/ruta_2/exterior.tscn"
const SIZE := Vector2i(36, 72)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_2: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_2/exterior"
	data.display_name = "Ruta 2 · Tierra de Pinares y Acueducto"
	data.zone_id = &"ruta_2"
	data.encounter_table = &"ruta_2"
	data.region_map_position = Vector2i(14, 9)
	var p: RefCounted = painter.new("Ruta2", SIZE, data, 2002)
	p.fill_grass(0.2)
	p.connect_edge("north", &"ruta_1/exterior")
	p.connect_edge("south", &"ruta_3/exterior")

	# --- Segovia: plaza del Azoguejo, avenida y calle del mesón (baldosas) ---
	p.paving(Rect2i(0, 34, 36, 12))
	p.paving(Rect2i(18, 46, 6, 26))
	p.paving(Rect2i(0, 53, 36, 3))
	p.paving(Rect2i(0, 63, 36, 2))
	p.build_paving()

	# --- Tierra de Pinares: camino de arena entre los pinos ---
	p.terrain(rects([
		Rect2i(20, 0, 3, 8), Rect2i(14, 6, 9, 3), Rect2i(14, 9, 3, 13), Rect2i(14, 22, 12, 3),
		Rect2i(23, 25, 3, 9), Rect2i(7, 20, 7, 2), Rect2i(7, 19, 1, 1),
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(17, 9, 7, 11), Rect2i(12, 26, 10, 6), Rect2i(26, 23, 4, 9),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.soil(Rect2i(16, 1, 3, 3))

	for r: Rect2i in [Rect2i(0, 0, 12, 12), Rect2i(0, 12, 4, 22), Rect2i(4, 22, 8, 12), Rect2i(26, 0, 10, 22),
			Rect2i(30, 22, 6, 12)]:
		p.forest(r)
	p.build_forest()

	# Taller de trillos de Cantalejo, en un claro del pinar.
	p.object(&"casa_madera", Vector2i(6, 19))
	p.object(&"pino", Vector2i(24, 13))
	p.object(&"pino", Vector2i(12, 10))
	p.object(&"pino", Vector2i(24, 21))
	p.object(&"arbol_redondo", Vector2i(10, 17))
	for cell: Vector2i in [Vector2i(19, 4), Vector2i(13, 23), Vector2i(22, 31), Vector2i(27, 32)]:
		p.deco(cell, ExteriorTiles.STUMP)
	p.deco(Vector2i(17, 32), ExteriorTiles.LOG_RIGHT[0])
	p.deco(Vector2i(18, 32), ExteriorTiles.LOG_RIGHT[1])
	p.deco(Vector2i(25, 3), ExteriorTiles.MUSHROOMS)

	# --- El Acueducto, de lado a lado del Azoguejo: tres tramos que encajan (el del centro, con la
	# hornacina de la Virgen). Solo chocan los pilares: se pasa por los arcos de las columnas pares.
	p.object(&"acueducto_segovia_tramo", Vector2i(-3, 44))
	p.object(&"acueducto_segovia", Vector2i(11, 44))
	p.object(&"acueducto_segovia_tramo", Vector2i(25, 44))

	# --- Casas de Segovia a los lados de la avenida; el mesón del cochinillo al este ---
	p.object(&"casa_roja", Vector2i(9, 52))
	p.object(&"casa_tejado_rojo", Vector2i(25, 52))   # el mesón
	p.object(&"casa_dos_aguas", Vector2i(8, 62))
	p.object(&"casa_granero", Vector2i(13, 62))
	p.object(&"casa_roja_chimenea", Vector2i(26, 62))
	p.object(&"casa_azul_pequena", Vector2i(1, 52))
	p.object(&"casa_naranja", Vector2i(1, 62))
	p.object(&"casa_madera", Vector2i(32, 62))

	# Bancos, farolas y árboles del paseo.
	p.object(&"banco", Vector2i(3, 37))
	p.object(&"banco", Vector2i(29, 37))
	for cell: Vector2i in [Vector2i(8, 36), Vector2i(26, 36), Vector2i(16, 52), Vector2i(16, 70), Vector2i(24, 70)]:
		p.object(&"farola_verde", cell)
	for cell: Vector2i in [Vector2i(33, 52), Vector2i(2, 70), Vector2i(33, 70), Vector2i(6, 61)]:
		p.object(&"arbol_redondo", cell)
	p.flowers(Rect2i(32, 46, 4, 2), 0.4)

	p.sprinkle(Rect2i(0, 0, SIZE.x, 34), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.MUSHROOMS])

	# --- Carteles ---
	p.deco(Vector2i(19, 2), ExteriorTiles.ROUTE_SIGN[0])
	p.deco(Vector2i(19, 3), ExteriorTiles.ROUTE_SIGN[1])
	p.sign_text("CartelRuta", Vector2i(19, 3), PackedStringArray(["RUTA 2 · TIERRA DE PINARES",
		"↑ Hoces del Duratón   ↓ Segovia"]))
	p.deco(Vector2i(11, 19), ExteriorTiles.SIGN)
	p.sign_text("CartelTrillos", Vector2i(11, 19), PackedStringArray(["TRILLOS DE CANTALEJO.",
		"Hechos a mano, con piedras de sílex. También para decorar el salón."]))
	p.deco(Vector2i(21, 35), ExteriorTiles.SIGN)
	p.sign_text("CartelAcueducto", Vector2i(21, 35), PackedStringArray(["ACUEDUCTO DE SEGOVIA.",
		"Siglo II, más de 20 000 sillares de granito sin argamasa. Patrimonio de la Humanidad.",
		"Lleva casi dos mil años en pie. La rotonda de al lado, tres."]))
	p.deco(Vector2i(24, 51), ExteriorTiles.SIGN)
	p.sign_text("CartelMeson", Vector2i(24, 51), PackedStringArray(["MESÓN DEL COCHINILLO.",
		"Asado en horno de leña desde hace más de un siglo."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(21, 1))
	p.spawn("from_route_1", Vector2i(21, 0))
	p.trainer("Eusebio", &"ruta2_eusebio", Vector2i(13, 15), RIGHT, 3)
	p.trainer("Steve", &"ruta2_steve", Vector2i(20, 36), RIGHT, 3)
	p.npc("Trillero", "npc_old_man", Vector2i(5, 20), RIGHT, PackedStringArray([
		"En Cantalejo los trilleros hablábamos gacería, para que no nos entendieran en las ferias.",
		"Ahora tampoco nos entiende nadie, pero porque ya no queda nadie."]))
	p.npc("Turista", "turistachanclas_f", Vector2i(12, 37), DOWN, PackedStringArray([
		"¡Foto con el Acueducto! ...Espera, otra. Que salía con los ojos cerrados. Y el Acueducto también."]))
	p.npc("Mesonero", "camarero", Vector2i(30, 54), DOWN, PackedStringArray([
		"El cochinillo se corta con el canto del plato, para que veas lo tierno que está.",
		"Luego el plato se tira al suelo. Y luego se cobra el plato."]))
	p.npc("Guardia", "npc_man", Vector2i(17, 68), RIGHT, PackedStringArray([
		"Por ahí se sube al Puerto de Navacerrada. Cadenas obligatorias.",
		"¿Que es octubre? Ya, pero en la sierra nieva cuando le da la gana."]))
	return p
