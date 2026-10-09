extends SceneTree
## Pinta la Ruta 15 · Costa de Gran Canaria (maps/ruta_15/exterior.tscn), de Las Palmas (norte) a Playa del
## Inglés (sur) por la costa este de la isla (docs/mundo/rutas.md): el malpaís volcánico con cardonales y
## tabaibas, las playas de arena negra de Telde, los barrancos que bajan al mar y las salinas de Arinaga,
## con el Atlántico al este. Se une sin fundido con Vegueta y Triana (norte) y con Playa del Inglés (sur).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_15.gd -- --force

const OUT := "res://maps/ruta_15/exterior.tscn"
const SIZE := Vector2i(36, 72)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_15: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_15/exterior"
	data.display_name = "Ruta 15 · Costa de Gran Canaria"
	data.zone_id = &"ruta_15"
	data.encounter_table = &"ruta_15"
	data.region_map_position = Vector2i(3, 24)
	var p: RefCounted = painter.new("Ruta15", SIZE, data, 1515)
	p.fill_grass(0.3)
	p.connect_edge("north", &"las_palmas/vegueta_triana", 8, Vector2i(12, 20))
	p.connect_edge("south", &"playa_del_ingles/exterior", 0, Vector2i(8, 20))

	# Las playas de arena negra; el Atlántico al este y las salinas.
	for r: Rect2i in [Rect2i(24, 2, 4, 18), Rect2i(22, 32, 6, 14), Rect2i(24, 48, 4, 22), Rect2i(12, 48, 10, 8)]:
		p.soil(r)
	p.water(Rect2i(28, 0, 8, 72))
	p.water(Rect2i(24, 22, 4, 8))
	p.water(Rect2i(14, 50, 6, 4))                      # las salinas de Arinaga
	p.build_water(0.25)
	# El camino de la costa, que baja haciendo eses.
	p.terrain(rects([Rect2i(14, 0, 4, 12), Rect2i(8, 10, 8, 3), Rect2i(8, 10, 3, 22), Rect2i(8, 30, 12, 3),
		Rect2i(17, 30, 3, 18), Rect2i(10, 46, 10, 2), Rect2i(10, 46, 3, 26)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(2, 14, 5, 10), Rect2i(14, 16, 8, 8), Rect2i(2, 38, 12, 6), Rect2i(20, 56, 4, 10),
		Rect2i(2, 58, 6, 8)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	# Un barranco: una meseta de roca con su escalera.
	p.plateau(Rect2i(0, 24, 8, 12), [4, 5])
	for r: Rect2i in [Rect2i(0, 0, 2, 12), Rect2i(0, 48, 2, 24), Rect2i(20, 0, 4, 10)]:
		p.forest(r)
	p.build_forest()
	# Cardones y tabaibas (los arbustos), palmeras y rocas volcánicas.
	for cell: Vector2i in [Vector2i(3, 6), Vector2i(21, 27), Vector2i(2, 47), Vector2i(21, 68)]:
		p.object(&"arbustos", cell)
	for cell: Vector2i in [Vector2i(5, 12), Vector2i(22, 46), Vector2i(4, 70)]:
		p.object(&"palmera", cell)
	for cell: Vector2i in [Vector2i(12, 5), Vector2i(20, 12), Vector2i(4, 45), Vector2i(15, 60), Vector2i(21, 40),
			Vector2i(6, 52), Vector2i(1, 22), Vector2i(13, 36)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.y % 2 == 0 else ExteriorTiles.ROCK_BROWN)
	# Telde: unas casas encaladas.
	for cell: Vector2i in [Vector2i(12, 28), Vector2i(16, 28)]:
		p.object(&"casa_ibicenca", cell)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(13, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(13, 2), PackedStringArray(["RUTA 15 · COSTA DE GRAN CANARIA",
		"↑ Las Palmas   ↓ Playa del Inglés y Maspalomas. La guagua tarda una hora; tú, lo que te dejen los entrenadores."]))
	p.deco(Vector2i(21, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelTelde", Vector2i(21, 34), PackedStringArray(["TELDE · PLAYA DE MELENARA.",
		"Arena negra de volcán. En agosto quema más que la factura de la luz."]))
	p.deco(Vector2i(13, 49), ExteriorTiles.SIGN)
	p.sign_text("CartelSalinas", Vector2i(13, 49), PackedStringArray(["SALINAS DE ARINAGA.",
		"Sal del Atlántico desde el siglo XVIII. Echarle sal a la herida aquí es un oficio."]))
	p.deco(Vector2i(7, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelBarranco", Vector2i(7, 23), PackedStringArray(["BARRANCO.",
		"Cuando llueve en Gran Canaria, aquí baja un río. Llueve cada tres años; el río, lo mismo."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(15, 1))
	p.spawn("from_vegueta", Vector2i(15, 0))
	p.spawn("from_playa_del_ingles", Vector2i(11, 71))
	p.trainer("Aday", &"ruta15_surfista", Vector2i(25, 40), LEFT, 3)
	p.trainer("Nayra", &"ruta15_nadadora", Vector2i(26, 60), UP, 3)
	p.trainer("Echedey", &"ruta15_guaguero", Vector2i(11, 20), DOWN, 3)
	p.npc("Pescador", "npc_fisherman", Vector2i(23, 20), RIGHT, PackedStringArray([
		"Aquí se coge la vieja y el cherne. Y los turistas, en la playa, cogen color."]))
	return p
