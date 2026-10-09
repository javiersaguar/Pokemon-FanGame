extends SceneTree
## Pinta la Ruta 14 · Doñana (maps/ruta_14/exterior.tscn), de Sevilla (este) hacia Huelva (oeste) por el
## Parque Nacional de Doñana (docs/mundo/rutas.md): el pinar del Aljarafe; la aldea de El Rocío, con sus
## calles de arena y casas encaladas de hermandad; las marismas, cruzadas por una vereda, con los juncales
## y el observatorio de aves; y las dunas de la costa al suroeste. Se une sin fundido con Sevilla · Río
## (este) y con Huelva (oeste).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_14.gd -- --force

const OUT := "res://maps/ruta_14/exterior.tscn"
const SIZE := Vector2i(72, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_14: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_14/exterior"
	data.display_name = "Ruta 14 · Doñana"
	data.zone_id = &"ruta_14"
	data.encounter_table = &"ruta_14"
	data.region_map_position = Vector2i(7, 20)
	var p: RefCounted = painter.new("Ruta14", SIZE, data, 1969)
	p.fill_grass(0.3)
	p.connect_edge("east", &"sevilla/rio", 0, Vector2i(20, 32))
	p.connect_edge("west", &"huelva/exterior", 0, Vector2i(16, 28))

	# Las marismas, con la vereda que las cruza (filas 26-27) y la del observatorio.
	p.water(Rect2i(10, 20, 38, 6))
	p.water(Rect2i(10, 28, 38, 8))
	p.water(Rect2i(16, 14, 10, 6))
	p.build_water(0.15)
	p.terrain(rects([Rect2i(56, 24, 16, 3), Rect2i(48, 12, 3, 15), Rect2i(0, 26, 51, 2), Rect2i(30, 16, 2, 10),
		Rect2i(0, 20, 3, 8), Rect2i(50, 24, 6, 3)]), ExteriorTiles.TERRAIN_PATH)
	# Juncales (hierba alta) en las orillas de la marisma.
	p.terrain(rects([Rect2i(4, 14, 10, 6), Rect2i(36, 14, 10, 5), Rect2i(52, 30, 12, 6), Rect2i(4, 30, 6, 4)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	# El Rocío: calles de arena; y las dunas de la costa al suroeste.
	for r: Rect2i in [Rect2i(38, 2, 14, 8), Rect2i(52, 4, 4, 14), Rect2i(0, 34, 10, 6), Rect2i(10, 36, 30, 4)]:
		p.soil(r)
	for r: Rect2i in [Rect2i(0, 0, 36, 4), Rect2i(56, 0, 16, 4), Rect2i(0, 4, 4, 10), Rect2i(60, 4, 12, 16),
			Rect2i(64, 32, 8, 8), Rect2i(48, 36, 16, 4), Rect2i(0, 28, 2, 2)]:
		p.forest(r)
	p.build_forest()

	# La aldea de El Rocío: casas de hermandad encaladas y barandas para atar los caballos.
	for cell: Vector2i in [Vector2i(38, 9), Vector2i(43, 9), Vector2i(52, 9), Vector2i(52, 17), Vector2i(56, 9)]:
		p.object(&"casa_ibicenca", cell)
	p.fence(39, 46, 11)
	p.object(&"cabana", Vector2i(31, 13))               # observatorio de aves
	for cell: Vector2i in [Vector2i(6, 11), Vector2i(20, 11), Vector2i(57, 22)]:
		p.object(&"pino", cell)
	for cell: Vector2i in [Vector2i(14, 38), Vector2i(26, 39), Vector2i(36, 37), Vector2i(44, 37)]:
		p.deco(cell, ExteriorTiles.TUFT_TALL)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(69, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(69, 23), PackedStringArray(["RUTA 14 · DOÑANA",
		"← Huelva y el ferry a Canarias   → Sevilla. Parque Nacional: prohibido pescar, cazar y regar fresas."]))
	p.deco(Vector2i(47, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRocio", Vector2i(47, 13), PackedStringArray(["ALDEA DE EL ROCÍO.",
		"Once meses de silencio y un fin de semana con un millón de romeros. La ermita queda detrás de las casas."]))
	p.deco(Vector2i(32, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelObservatorio", Vector2i(32, 15), PackedStringArray(["OBSERVATORIO DE AVES.",
		"Aquí se ven flamencos, espátulas y garzas. Los flamencos de la Feria están en Sevilla."]))
	p.deco(Vector2i(51, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelLince", Vector2i(51, 27), PackedStringArray(["¡ATENCIÓN: PASO DE LINCES!",
		"Quedan unos cientos. Si ves uno, no le hagas fotos: ya tiene más que muchos famosos."]))
	p.deco(Vector2i(8, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelAgua", Vector2i(8, 25), PackedStringArray(["LA MARISMA SE SECA.",
		"Los pozos ilegales de los regadíos se beben el agua del parque. Las fresas, en cambio, salen muy jugosas."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(70, 25))
	p.spawn("from_sevilla", Vector2i(71, 25))
	p.spawn("from_huelva", Vector2i(0, 26))
	p.trainer("Elena", &"ruta14_ornitologa", Vector2i(30, 19), DOWN, 3)
	p.trainer("Rafa", &"ruta14_rociero", Vector2i(47, 5), DOWN, 3)
	p.trainer("Paco", &"ruta14_guarda", Vector2i(20, 27), RIGHT, 4)
	p.npc("Romera", "npc_woman", Vector2i(41, 5), DOWN, PackedStringArray([
		"Venimos andando desde Triana: cuatro días de camino con la carreta. Los pies, de recuerdo para el año que viene."]))
	p.npc("Agricultor", "npc_man", Vector2i(58, 26), LEFT, PackedStringArray([
		"Mis fresas van a Alemania. El agua, de donde salga. Bueno, de donde no debería, según los del parque."]))
	return p
