extends SceneTree
## Pinta la Ruta 9 · La Albufera y Gandía (maps/ruta_9/exterior.tscn), por la CV-500 y la costa hacia el
## sur (docs/mundo/rutas.md): sale de la Ciudad de las Artes (Jardín del Turia) por el norte; la Devesa
## del Saler con su pinar y las dunas; el lago de la Albufera con las barcas de vela latina y El Palmar
## con sus barracas; los arrozales con sus motas; Cullera con la montaña del castillo, sus torres de
## pisos y el faro; y Gandía con el Palau Ducal dels Borja y la playa del paseo (la casa de *Gandía
## Shore*). El mar va por el este todo el camino. Por el sur sigue la Ruta 10 (Costa Blanca).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_9.gd -- --force

const OUT := "res://maps/ruta_9/exterior.tscn"
const SIZE := Vector2i(48, 76)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_9: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_9/exterior"
	data.display_name = "Ruta 9 · La Albufera y Gandía"
	data.zone_id = &"ruta_9"
	data.encounter_table = &"ruta_9"
	data.region_map_position = Vector2i(22, 15)
	var p: RefCounted = painter.new("Ruta9", SIZE, data, 1238)
	p.fill_grass(0.25)
	p.connect_edge("north", &"valencia/turia", 33, Vector2i(25, 29))
	p.connect_edge("south", &"ruta_10/exterior", 0, Vector2i(25, 29))

	# La CV-500 de norte a sur y las calles de Gandía.
	p.paving(Rect2i(25, 0, 4, 57))
	p.paving(Rect2i(0, 57, 39, 19))
	p.build_paving()
	# El camino de El Palmar y las motas entre los arrozales.
	p.terrain(rects([Rect2i(14, 25, 11, 2), Rect2i(29, 22, 10, 2), Rect2i(29, 30, 10, 2), Rect2i(33, 16, 1, 22)]),
		ExteriorTiles.TERRAIN_PATH)
	# Los arrozales (hierba alta) y el monte bajo del Saler y de Cullera.
	p.terrain(rects([Rect2i(29, 16, 4, 6), Rect2i(34, 16, 5, 6), Rect2i(29, 24, 4, 6), Rect2i(34, 24, 5, 6),
		Rect2i(29, 32, 4, 6), Rect2i(34, 32, 5, 6), Rect2i(14, 2, 10, 9), Rect2i(17, 43, 7, 5)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	# El pinar de la Devesa del Saler.
	for r: Rect2i in [Rect2i(0, 0, 14, 14), Rect2i(30, 0, 8, 12)]:
		p.forest(r)
	p.build_forest()
	p.soil(Rect2i(39, 0, 4, SIZE.y))        # la playa
	p.water(Rect2i(43, 0, 5, SIZE.y))       # el Mediterráneo
	p.water(Rect2i(0, 16, 14, 26))          # el lago de la Albufera
	p.build_water(0.1)
	# La montaña de Cullera, con la escalera del Calvario.
	p.plateau(Rect2i(0, 43, 16, 12), [10, 11])

	# El Palmar: barracas y barcas en el lago.
	p.object(&"barraca", Vector2i(14, 24))
	p.object(&"barraca", Vector2i(19, 24))
	p.object(&"barraca", Vector2i(15, 33))
	p.object(&"barraca", Vector2i(20, 33))
	# La casa forestal de la Devesa y la huerta de El Palmar, con su puesto de naranjas.
	p.object(&"cabana", Vector2i(15, 15))
	p.object(&"banco", Vector2i(20, 14))
	for cell: Vector2i in [Vector2i(30, 15), Vector2i(35, 15)]:
		p.object(&"arbol_redondo", cell)
	p.flowers(Rect2i(15, 37, 4, 4))
	p.object(&"puesto_mercado", Vector2i(20, 41))
	p.object(&"barca_albufera", Vector2i(8, 21))
	p.object(&"barca_albufera", Vector2i(5, 29))
	# Cullera: pinos en la montaña, una torre de pisos de playa y el faro.
	for cell: Vector2i in [Vector2i(2, 50), Vector2i(6, 48), Vector2i(13, 49), Vector2i(4, 53), Vector2i(8, 52)]:
		p.object(&"pino", cell)
	for cell: Vector2i in [Vector2i(10, 46), Vector2i(3, 45), Vector2i(12, 51)]:
		p.deco(cell, ExteriorTiles.ROCK)
	p.object(&"bloque_pisos", Vector2i(17, 56))
	p.object(&"faro", Vector2i(31, 56))
	# Gandía: el Palau Ducal, el casco antiguo y la playa con la casa de Gandía Shore.
	p.object(&"palau_ducal_gandia", Vector2i(2, 66))
	p.object(&"casa_teja", Vector2i(13, 66))
	p.object(&"tienda_naranja", Vector2i(19, 66))
	p.object(&"casa_rosa", Vector2i(2, 74))
	p.object(&"tienda_naranja", Vector2i(8, 74))
	p.object(&"casa_rosa", Vector2i(14, 74))
	p.object(&"casa_roja_pequena", Vector2i(20, 74))
	p.object(&"tienda_azul", Vector2i(29, 74))        # la heladería del paseo
	for cell: Vector2i in [Vector2i(3, 58), Vector2i(9, 58), Vector2i(15, 58)]:
		p.object(&"jardinera", cell)
	p.object(&"banco", Vector2i(20, 58))
	p.object(&"casa_grande", Vector2i(29, 66))
	for cell: Vector2i in [Vector2i(37, 63), Vector2i(37, 71)]:
		p.object(&"palmera", cell)
	p.object(&"torre_socorrista", Vector2i(40, 68))
	p.sprinkle(Rect2i(0, 0, SIZE.x, 42), 0.04, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(24, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(24, 2), PackedStringArray(["RUTA 9 · LA ALBUFERA Y GANDÍA",
		"↑ Valencia   ↓ Gandía. Devesa del Saler: prohibido hacer fuego. Y paella, que también es fuego."]))
	p.deco(Vector2i(24, 16), ExteriorTiles.SIGN)
	p.sign_text("CartelAlbufera", Vector2i(24, 16), PackedStringArray(["PARC NATURAL DE L'ALBUFERA.",
		"El lago más grande de España. Aquí nació la paella. La de chorizo nació en otra parte, y que allí se quede."]))
	p.deco(Vector2i(14, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelBarcas", Vector2i(14, 34), PackedStringArray(["PASEOS EN BARCA AL ATARDECER · El Palmar.",
		"Se paga en efectivo o con tarjeta. Con mascarillas, no: el último lote que nos colaron aún está en el almacén."]))
	p.deco(Vector2i(24, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelArroceria", Vector2i(24, 34), PackedStringArray(["ARROCERÍA · All i pebre y paella.",
		"Paella para dos: mínimo dos personas. Paella para uno: eso es un arroz y aquí no lo servimos."]))
	p.deco(Vector2i(16, 42), ExteriorTiles.SIGN)
	p.sign_text("CartelCullera", Vector2i(16, 42), PackedStringArray(["CULLERA.",
		"Arriba, el castillo y la Virgen. Abajo, las torres de pisos de veraneo. Cada una vigila lo suyo."]))
	p.deco(Vector2i(12, 52), ExteriorTiles.SIGN)
	p.sign_text("CartelCastell", Vector2i(12, 52), PackedStringArray(["CASTELL DE CULLERA.",
		"Desde aquí arriba se ven el Júcar, los arrozales y el mar. Y las letras blancas de CULLERA, por si te pierdes."]))
	p.deco(Vector2i(34, 75), ExteriorTiles.SIGN)
	p.sign_text("CartelHeladeria", Vector2i(34, 75), PackedStringArray(["HELADERÍA DEL PASEO.",
		"Sabor del verano: horchata. Sabor del resto del año: cerrado."]))
	p.deco(Vector2i(12, 67), ExteriorTiles.SIGN)
	p.sign_text("CartelPalau", Vector2i(12, 67), PackedStringArray(["PALAU DUCAL DELS BORJA · Gandía.",
		"Aquí nació san Francisco de Borja. En la familia hubo un papa, un santo y varios envenenados: lo normal."]))
	p.deco(Vector2i(35, 67), ExteriorTiles.SIGN)
	p.sign_text("CartelShore", Vector2i(35, 67), PackedStringArray(["CHALET PRIVADO.",
		"Aquí se rodó un reality en 2012. Los vecinos aún piden perdón al resto de España."]))
	p.deco(Vector2i(24, 74), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta10", Vector2i(24, 74), PackedStringArray(["↓ RUTA 10 · COSTA BLANCA.",
		"Benidorm: más rascacielos por habitante que Nueva York. Y más chanclas."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(26, 1))
	p.spawn("from_valencia", Vector2i(26, 0))
	p.spawn("from_ruta_10", Vector2i(26, 75))
	p.trainer("Vicent", &"ruta9_pescador", Vector2i(14, 26), RIGHT, 5)
	p.trainer("Pilar", &"ruta9_ornitologa", Vector2i(38, 22), LEFT, 4)
	p.trainer("Ivan", &"ruta9_tronista", Vector2i(34, 68), DOWN, 4)
	p.trainer("Nerea", &"ruta9_nadadora", Vector2i(40, 58), DOWN, 4)
	p.npc("Barquero", "npc_fisherman", Vector2i(14, 30), LEFT, PackedStringArray([
		"Mi abuelo pescaba anguilas en este lago. Mi padre, también. Yo paseo a turistas: pican más.",
		"Al atardecer el lago se pone rojo. Como la cara de los turistas sin crema."]))
	p.npc("Guarda", "npc_man", Vector2i(21, 12), DOWN, PackedStringArray([
		"En los setenta quisieron llenar la Devesa de hoteles. La gente salió a la calle: «El Saler per al poble».",
		"Ganó el pinar. Es de las pocas veces que ha ganado un pinar."]))
	p.npc("Cocinero", "npc_man", Vector2i(23, 27), DOWN, PackedStringArray([
		"La paella lleva pollo, conejo, garrofó, bajoqueta y caracoles si hay.",
		"Al que le eche guisantes, que no vuelva. Y al del chorizo, que no salga de su casa."]))
	p.npc("Llauradora", "npc_old_woman", Vector2i(19, 40), DOWN, PackedStringArray([
		"¡Naranjas a un euro el kilo! En el súper están a tres y vienen de la otra punta del mundo.",
		"A mí me las pagan a quince céntimos. Haz tú la cuenta, que yo ya la he hecho llorando."]))
	p.npc("Turista", "npc_girl", Vector2i(41, 72), LEFT, PackedStringArray([
		"He venido a Gandía por la playa. Llevo tres días buscando un hueco para la toalla."]))
	p.npc("Guia", "npc_woman", Vector2i(8, 68), DOWN, PackedStringArray([
		"Los Borja salieron de aquí y llegaron a papas de Roma. Los de ahora salen de aquí y llegan a la tele."]))
	return p
