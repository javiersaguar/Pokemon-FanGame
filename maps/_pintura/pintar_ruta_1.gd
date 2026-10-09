extends SceneTree
## Pinta la Ruta 1 · Hoces del Duratón (maps/ruta_1/exterior.tscn), de San Miguel de Bernuy hacia
## Sepúlveda (docs/mundo/rutas.md y docs/mundo/region.md): el cañón del Duratón con el río al
## oeste y el páramo de caliza al este. Abajo, el camino de la ribera con chopos y hierba alta;
## arriba, por las escaleras, el páramo con sabinas y pinos, el mirador de los buitres leonados
## y, en lo más alto del meandro, las ruinas del priorato de San Frutos.
## Se une sin fundido con el pueblo por el norte (mismas columnas: la calle Real sigue aquí).
## Por el sur sigue la Ruta 2 (Tierra de Pinares y Segovia), también sin fundido.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_1.gd -- --force

const OUT := "res://maps/ruta_1/exterior.tscn"
const SIZE := Vector2i(36, 64)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_1: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_1/exterior"
	data.display_name = "Ruta 1 · Hoces del Duratón"
	data.zone_id = &"ruta_1"
	data.encounter_table = &"ruta_1"
	data.region_map_position = Vector2i(13, 8)
	var p: RefCounted = painter.new("Ruta1", SIZE, data, 1990)
	p.fill_grass(0.2)
	p.connect_edge("north", &"pueblo_inicial/exterior")
	p.connect_edge("south", &"ruta_2/exterior")

	# El río Duratón, que viene del pueblo (mismas columnas) y sigue hacia el sur. Recto: el
	# estanque del pack no trae esquinas hacia dentro para hacer meandros.
	p.water(Rect2i(4, 0, 6, 64))

	# Caminos: de la calle Real del pueblo a la ribera, por la ribera hacia el sur y la salida
	# a Sepúlveda; un ramal sube por las escaleras al páramo, al mirador y a San Frutos.
	p.terrain(rects([
		Rect2i(20, 0, 3, 5), Rect2i(13, 4, 10, 3), Rect2i(13, 7, 3, 47), Rect2i(13, 54, 10, 3),
		Rect2i(20, 57, 3, 7),
		Rect2i(16, 52, 12, 2), Rect2i(26, 33, 2, 17), Rect2i(21, 32, 10, 2), Rect2i(21, 25, 2, 7),
		Rect2i(29, 16, 2, 14), Rect2i(25, 15, 6, 2),
	]), ExteriorTiles.TERRAIN_PATH)

	# Hierba alta: en la ribera, en el páramo y en el prado de la salida.
	p.terrain(rects([
		Rect2i(24, 2, 7, 6), Rect2i(10, 8, 3, 6),
		Rect2i(16, 14, 2, 10), Rect2i(9, 22, 4, 8), Rect2i(16, 36, 2, 10), Rect2i(10, 44, 3, 4),
		Rect2i(20, 34, 5, 8), Rect2i(28, 38, 6, 7), Rect2i(19, 14, 4, 8), Rect2i(25, 21, 4, 6),
		Rect2i(32, 23, 3, 5),
		Rect2i(24, 57, 6, 5), Rect2i(14, 58, 5, 4),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	p.build_water()

	# El otro lado del cañón (oeste) y el páramo de caliza (este), con el meandro alto de San
	# Frutos dentro. Escaleras en las paredes de roca.
	p.plateau(Rect2i(-4, -2, 7, 70))
	p.plateau(Rect2i(18, 12, 18, 40), [26, 27])
	p.plateau(Rect2i(24, 12, 12, 20), [29, 30])

	# Pinares y sabinares (bosque de pinos del pack 02: casillas pares).
	for r: Rect2i in [Rect2i(0, 0, 2, 64), Rect2i(32, 0, 4, 10), Rect2i(30, 46, 4, 4), Rect2i(20, 44, 4, 4),
			Rect2i(32, 32, 2, 6), Rect2i(30, 56, 6, 8), Rect2i(24, 62, 6, 2)]:
		p.forest(r)
	p.build_forest()

	# Chopos de la ribera y sabinas del páramo.
	for cell: Vector2i in [Vector2i(10, 18), Vector2i(10, 34), Vector2i(10, 42), Vector2i(10, 52), Vector2i(16, 3),
			Vector2i(18, 10)]:
		p.object(&"arbol_verde", cell)
	for cell: Vector2i in [Vector2i(19, 31), Vector2i(29, 36), Vector2i(24, 49), Vector2i(26, 29)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"arbustos", Vector2i(26, 10))
	p.object(&"arbustos", Vector2i(10, 62))

	# Roca caliza suelta en los bordes del cañón y las ruinas del priorato de San Frutos.
	for cell: Vector2i in [Vector2i(19, 23), Vector2i(19, 34), Vector2i(19, 47), Vector2i(34, 29),
			Vector2i(12, 2), Vector2i(17, 57), Vector2i(33, 11)]:
		p.deco(cell, ExteriorTiles.ROCK)
	for cell: Vector2i in [Vector2i(31, 17), Vector2i(32, 17), Vector2i(34, 17), Vector2i(31, 18), Vector2i(34, 18),
			Vector2i(31, 20), Vector2i(34, 19), Vector2i(32, 20), Vector2i(33, 14)]:
		p.deco(cell, ExteriorTiles.ROCK_BROWN if (cell.x + cell.y) % 2 == 0 else ExteriorTiles.ROCK)
	p.deco(Vector2i(28, 19), ExteriorTiles.STUMP)

	p.flowers(Rect2i(21, 7, 2, 2), 0.4)
	p.flowers(Rect2i(33, 28, 2, 1), 0.6)
	p.flowers(Rect2i(16, 47, 2, 2), 0.3)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL,
		ExteriorTiles.WHITE_FLOWERS])

	# Carteles.
	p.deco(Vector2i(19, 2), ExteriorTiles.ROUTE_SIGN[0])
	p.deco(Vector2i(19, 3), ExteriorTiles.ROUTE_SIGN[1])
	p.sign_text("CartelRuta", Vector2i(19, 3), PackedStringArray(["RUTA 1 · HOCES DEL DURATÓN",
		"↑ San Miguel de Bernuy   ↓ Sepúlveda y Segovia"]))
	p.deco(Vector2i(21, 24), ExteriorTiles.SIGN)
	p.sign_text("CartelMirador", Vector2i(21, 24), PackedStringArray(["Mirador de las Hoces.",
		"Aquí anidan cientos de parejas de buitre leonado. No te asomes con un bocadillo."]))
	p.deco(Vector2i(28, 18), ExteriorTiles.SIGN)
	p.sign_text("CartelSanFrutos", Vector2i(28, 18), PackedStringArray(["Priorato de San Frutos (siglo XII).",
		"Cuenta la leyenda que San Frutos rajó la roca con su cayado: la Cuchillada."]))
	p.deco(Vector2i(24, 56), ExteriorTiles.SIGN)
	p.sign_text("CartelSur", Vector2i(24, 56), PackedStringArray(["↓ Ruta 2 · Tierra de Pinares y Segovia.",
		"Carretera arreglada por el Ministerio en 2019. Bueno: pintada."]))

	# Apariciones.
	p.spawn("default", Vector2i(21, 1))
	p.spawn("from_town", Vector2i(21, 0))

	# Entrenadores y vecinos.
	p.trainer("Manolo", &"ruta1_manolo", Vector2i(16, 30), LEFT, 2)
	p.trainer("Dani", &"ruta1_dani", Vector2i(11, 38), RIGHT, 3)
	p.trainer("Marta", &"ruta1_marta", Vector2i(19, 26), RIGHT, 6)
	p.npc("Ermitano", "npc_old_man", Vector2i(32, 19), DOWN, PackedStringArray([
		"San Frutos vivió aquí con sus hermanos Valentín y Engracia, hace más de mil años.",
		"Dicen que la grieta de la roca la abrió él. Yo creo que fue una obra del Ministerio."]))
	p.npc("Recogida", "npc_fisherman", Vector2i(12, 54), LEFT, PackedStringArray([
		"Aquí se recogen las canoas que bajan desde San Miguel. ¡Ni se te ocurra tirarte al río!"]))
	p.npc("Jubilado", "jubiladoobras", Vector2i(18, 60), RIGHT, PackedStringArray([
		"Llevo desde 2019 mirando esta obra. Por fin han quitado la valla.",
		"Ahora miro la carretera. Por si acaso la vuelven a poner."]))
	return p
