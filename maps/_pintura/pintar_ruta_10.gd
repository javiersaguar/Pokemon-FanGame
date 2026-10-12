extends SceneTree
## Pinta la Ruta 10 · Costa Blanca (maps/ruta_10/exterior.tscn), de Gandía a Alicante por la costa
## (docs/mundo/rutas.md): Calp con el Peñón de Ifach saliendo del mar; Altea en su cerro, con las casas
## encaladas y la cúpula de teja azul; Benidorm con la línea de rascacielos, el Intempo, una grúa que
## no para, el pub inglés y la playa de Levante llena de sombrillas; y La Vila Joiosa con sus casas de
## colores. El mar va por el este; al oeste, el monte. Por el norte viene la Ruta 9 y por el sur se
## entra en Alicante.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_10.gd -- --force

const OUT := "res://maps/ruta_10/exterior.tscn"
const SIZE := Vector2i(60, 64)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_10: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_10/exterior"
	data.display_name = "Ruta 10 · Costa Blanca"
	data.zone_id = &"ruta_10"
	data.encounter_table = &"ruta_10"
	data.region_map_position = Vector2i(23, 16)
	var p: RefCounted = painter.new("Ruta10", SIZE, data, 1960)
	p.fill_grass(0.25)
	p.connect_edge("north", &"ruta_9/exterior", 0, Vector2i(25, 29))
	p.connect_edge("south", &"alicante/exterior", 11, Vector2i(25, 29))

	# La N-332 de norte a sur, Benidorm entero y el paseo de La Vila.
	p.paving(Rect2i(25, 0, 4, SIZE.y))
	p.paving(Rect2i(4, 29, 34, 23))
	p.paving(Rect2i(4, 61, 21, 2))
	p.build_paving()
	# Monte bajo: pinada y hierba alta.
	p.terrain(rects([Rect2i(6, 2, 7, 10), Rect2i(16, 2, 7, 10), Rect2i(30, 15, 7, 12), Rect2i(30, 54, 7, 8)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(rects([Rect2i(13, 2, 3, 12), Rect2i(13, 12, 12, 2)]), ExteriorTiles.TERRAIN_PATH)   # la senda del monte
	p.forest(Rect2i(0, 0, 4, SIZE.y))
	p.build_forest()
	p.soil(Rect2i(38, 0, 6, SIZE.y))        # las playas
	p.water(Rect2i(44, 0, 16, SIZE.y))      # el Mediterráneo
	p.build_water(0.1)
	# El cerro de Altea, con su escalera.
	p.plateau(Rect2i(4, 15, 19, 13), [20, 21])

	# Calp: el Peñón de Ifach y unas casas blancas de pescadores.
	p.object(&"penon_ifach", Vector2i(44, 12))
	p.object(&"casa_ibicenca", Vector2i(30, 8))
	p.object(&"casa_ibicenca", Vector2i(34, 8))
	p.object(&"casa_ibicenca", Vector2i(30, 13))
	p.object(&"barca_albufera", Vector2i(47, 22))
	p.object(&"barca_albufera", Vector2i(52, 50))
	# Altea: la iglesia de la cúpula azul y el caserío encalado.
	p.object(&"iglesia_altea", Vector2i(8, 23))
	p.object(&"casa_ibicenca", Vector2i(15, 20))
	p.object(&"casa_ibicenca", Vector2i(17, 24))
	# Benidorm: la línea de rascacielos, el Intempo y la grúa.
	for x: int in [5, 9, 19]:
		p.object(&"rascacielos_benidorm", Vector2i(x, 40))
	p.object(&"intempo", Vector2i(13, 40))
	p.object(&"grua", Vector2i(30, 40))
	p.object(&"tienda_naranja", Vector2i(6, 50))        # el pub inglés
	p.object(&"tienda_azul", Vector2i(13, 50))          # souvenirs
	p.object(&"tienda_flores", Vector2i(19, 50))
	p.object(&"bloque_pisos", Vector2i(30, 51))
	for y: int in [33, 39, 45]:
		p.object(&"sombrilla", Vector2i(38, y))
	p.object(&"torre_socorrista", Vector2i(40, 28))
	for cell: Vector2i in [Vector2i(22, 44), Vector2i(36, 48)]:
		p.object(&"palmera", cell)
	# La Vila Joiosa: las casas de colores.
	p.object(&"casa_rosa", Vector2i(4, 60))
	p.object(&"casa_azul_pequena", Vector2i(10, 60))
	p.object(&"casa_naranja", Vector2i(16, 60))
	p.object(&"casa_roja_pequena", Vector2i(20, 60))
	p.object(&"sombrilla", Vector2i(38, 58))
	for cell: Vector2i in [Vector2i(5, 14), Vector2i(9, 14), Vector2i(18, 14), Vector2i(30, 3), Vector2i(35, 3)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"banco", Vector2i(13, 1))
	p.sprinkle(Rect2i(4, 0, 34, 15), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(24, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(24, 2), PackedStringArray(["RUTA 10 · COSTA BLANCA",
		"↑ Gandía   ↓ Alicante. Sol garantizado 300 días al año. Los otros 65 llega la alerta al móvil. Tarde."]))
	p.deco(Vector2i(29, 9), ExteriorTiles.SIGN)
	p.sign_text("CartelCalp", Vector2i(29, 9), PackedStringArray(["CALP · PENYAL D'IFAC.",
		"332 metros de roca sobre el mar. Arriba hay gaviotas y guiris en chanclas esperando al helicóptero de rescate."]))
	p.deco(Vector2i(14, 24), ExteriorTiles.SIGN)
	p.sign_text("CartelAltea", Vector2i(14, 24), PackedStringArray(["ALTEA.",
		"La cúpula azul sale en todas las postales. Las casas blancas, en todos los portales de alquiler turístico."]))
	p.deco(Vector2i(24, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelBenidorm", Vector2i(24, 30), PackedStringArray(["BENIDORM.",
		"Más rascacielos por habitante que Nueva York. Y más despedidas de soltero que habitantes."]))
	p.deco(Vector2i(18, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelIntempo", Vector2i(18, 41), PackedStringArray(["INTEMPO · 47 plantas.",
		"Empezado en 2007. Quebró, se lo quedó el banco malo y se acabó en 2021. Los ascensores sí los pusieron, digan lo que digan."]))
	p.deco(Vector2i(29, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelObra", Vector2i(29, 41), PackedStringArray(["PRÓXIMA CONSTRUCCIÓN.",
		"200 apartamentos turísticos con vistas a otros 200 apartamentos turísticos."]))
	p.deco(Vector2i(11, 51), ExteriorTiles.SIGN)
	p.sign_text("CartelPub", Vector2i(11, 51), PackedStringArray(["THE RED LION · PUB.",
		"Full English Breakfast 4,95 €. Paella with chorizo. We don't speak Spanish. Nobody here does."]))
	p.deco(Vector2i(24, 62), ExteriorTiles.SIGN)
	p.sign_text("CartelVila", Vector2i(24, 62), PackedStringArray(["LA VILA JOIOSA.",
		"Cada casa de un color, para que los pescadores encontraran la suya desde el mar. Y huele a chocolate."]))
	p.deco(Vector2i(29, 62), ExteriorTiles.SIGN)
	p.sign_text("CartelSur", Vector2i(29, 62), PackedStringArray(["↓ ALICANTE.",
		"Castillo de Santa Bárbara, Explanada y hogueras. Lleve agua."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(26, 1))
	p.spawn("from_ruta_9", Vector2i(26, 0))
	p.spawn("from_alicante", Vector2i(26, 63))
	p.trainer("Marc", &"ruta10_surfista", Vector2i(40, 4), DOWN, 4)
	p.trainer("Gary", &"ruta10_guiri", Vector2i(43, 37), UP, 3)
	p.trainer("Paco", &"ruta10_jubilado", Vector2i(34, 43), LEFT, 3)
	p.trainer("Kevin", &"ruta10_camarero", Vector2i(12, 51), RIGHT, 4)
	p.npc("Pescador", "npc_fisherman", Vector2i(36, 10), DOWN, PackedStringArray([
		"Antes salíamos a pescar a la sombra del Peñón. Ahora alquilo el barco para fiestas. Pican más."]))
	p.npc("Senderista", "npc_boy", Vector2i(15, 3), DOWN, PackedStringArray([
		"Desde este banco se ve el Peñón entero. Y el atasco de la N-332, también entero."]))
	p.npc("Pintor", "npc_man", Vector2i(12, 25), DOWN, PackedStringArray([
		"Pinto la cúpula de Altea cada mañana. Llevo cuarenta años y todavía no me sale ese azul."]))
	p.npc("Imserso", "npc_old_woman", Vector2i(12, 43), DOWN, PackedStringArray([
		"Vengo todos los años con el IMSERSO. Quince días, pensión completa y baile por la tarde.",
		"Esto sí que es el Estado del bienestar, y no lo que sale en la tele."]))
	p.npc("Expat", "npc_old_man", Vector2i(42, 41), LEFT, PackedStringArray([
		"«I've lived here for thirty years.»", "No habla ni una palabra de español. Tampoco le ha hecho falta."]))
	p.npc("Chocolatera", "npc_girl", Vector2i(8, 62), UP, PackedStringArray([
		"En La Vila hacemos chocolate desde antes de que hubiera turistas. Ahora hacemos chocolate para turistas."]))
	return p
