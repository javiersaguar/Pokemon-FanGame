extends SceneTree
## Pinta la Ruta 8 · Montserrat (maps/ruta_8/exterior.tscn), de Los Monegros a Barcelona
## (docs/mundo/rutas.md): al norte, la montaña de Montserrat con sus agujas de conglomerado y, en su
## terraza, el monasterio de la Moreneta (se sube por las escaleras, como con la cremallera); el camino
## pasa al pie entre pinares, con los pueblos del Bages y el Baix Llobregat al sur (Santpedor y Sant
## Esteve Sesrovires). Se une sin fundido con la Ruta 7 por el oeste.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_8.gd -- --force

const OUT := "res://maps/ruta_8/exterior.tscn"
const SIZE := Vector2i(72, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_8: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_8/exterior"
	data.display_name = "Ruta 8 · Montserrat"
	data.zone_id = &"ruta_8"
	data.encounter_table = &"ruta_8"
	data.region_map_position = Vector2i(26, 7)
	var p: RefCounted = painter.new("Ruta8", SIZE, data, 1025)
	p.fill_grass(0.2)
	p.connect_edge("west", &"ruta_7/exterior", 0, Vector2i(14, 18))
	p.connect_edge("east", &"barcelona/les_corts", 0, Vector2i(14, 18))

	# El camino al pie de la montaña y la plaza del monasterio.
	p.terrain(rects([Rect2i(0, 14, 72, 4), Rect2i(14, 18, 2, 12), Rect2i(54, 18, 2, 12)]),
		ExteriorTiles.TERRAIN_PATH)
	p.paving(Rect2i(26, 7, 22, 5))
	p.build_paving()
	p.terrain(rects([Rect2i(2, 20, 10, 8), Rect2i(24, 22, 10, 8), Rect2i(40, 20, 12, 6), Rect2i(60, 20, 10, 6)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)

	# La terraza del monasterio (con su escalera) y las agujas de la montaña detrás.
	p.plateau(Rect2i(22, -2, 30, 16), [44, 45])
	p.object(&"agujas_montserrat", Vector2i(2, 12))
	p.object(&"agujas_montserrat", Vector2i(58, 12))
	p.object(&"agujas_montserrat", Vector2i(24, 4))
	p.object(&"agujas_montserrat", Vector2i(39, 4))
	p.object(&"monasterio_montserrat", Vector2i(32, 10))

	# Pinares, pueblos y piedras.
	for r: Rect2i in [Rect2i(0, 30, 12, 10), Rect2i(60, 30, 12, 10), Rect2i(34, 34, 14, 6)]:
		p.forest(r)
	p.build_forest()
	p.object(&"casa_roja_chimenea", Vector2i(16, 37))   # Santpedor
	p.object(&"casa_dos_aguas", Vector2i(22, 37))
	p.object(&"casa_madera", Vector2i(50, 37))           # Sant Esteve Sesrovires
	p.object(&"casa_granero", Vector2i(55, 37))
	for cell: Vector2i in [Vector2i(18, 12), Vector2i(53, 9), Vector2i(8, 18), Vector2i(66, 18), Vector2i(30, 31)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(0, 14, SIZE.x, 26), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(1, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(1, 13), PackedStringArray(["RUTA 8 · MONTSERRAT",
		"← Lleida y Los Monegros   → Barcelona"]))
	p.deco(Vector2i(39, 14), ExteriorTiles.SIGN)
	p.sign_text("CartelMonasterio", Vector2i(39, 14), PackedStringArray(["MONASTERIO DE MONTSERRAT.",
		"Aquí está la Moreneta, la patrona de Cataluña. Y la Escolanía, que canta mejor que tú."]))
	p.deco(Vector2i(13, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelSantpedor", Vector2i(13, 30), PackedStringArray(["SANTPEDOR.",
		"Pueblo de un entrenador muy famoso que gana muchas ligas... en Inglaterra."]))
	p.deco(Vector2i(56, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelSantEsteve", Vector2i(56, 30), PackedStringArray(["SANT ESTEVE SESROVIRES.",
		"Pueblo de una cantante que ha llenado estadios con motomamis."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_ruta_7", Vector2i(0, 15))
	p.trainer("Laia", &"ruta8_laia", Vector2i(20, 18), UP, 3)
	p.trainer("Oriol", &"ruta8_flautista", Vector2i(46, 9), LEFT, 3)
	p.npc("Monje", "npc_old_man", Vector2i(30, 9), DOWN, PackedStringArray([
		"Benedictinos desde el año 1025. La cremallera es de 1892. Las colas para ver a la Moreneta, eternas."]))
	return p
