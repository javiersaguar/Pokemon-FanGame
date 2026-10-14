extends SceneTree
## Pamplona (docs/mundo/ciudades/pamplona.md). Baja desde la Ruta 20 por el norte (columnas 30–33),
## cruza el Arga por el puente de la Magdalena y entra en la ciudad amurallada por el Portal de Francia
## (un hueco en la muralla, que es una meseta de piedra); sale por las escaleras del sur a la Ruta 21
## (columnas 22–25). Dentro: el Ayuntamiento del chupinazo, la catedral, la Plaza del Castillo con el
## quiosco y el Café Iruña, la calle Estafeta hasta la plaza de toros y, al suroeste, la Ciudadela.
## Centro Pokémon, Mercadona y estanco según maps/_pintura/locales.json.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_pamplona.gd -- --force

const OUT := "res://maps/pamplona/exterior.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_pamplona: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	d.id = &"pamplona/exterior"
	d.display_name = "Pamplona"
	d.zone_id = &"pamplona"
	d.encounter_table = &"pamplona"
	d.region_map_position = Vector2i(19, 4)
	var p := Pintor.new("Pamplona", SIZE, d, 7777)
	p.fill_grass(0.22)
	p.connect_edge("north", &"ruta_20/exterior", 0, Vector2i(30, 34))
	p.connect_edge("south", &"ruta_21/exterior", 0, Vector2i(22, 26))

	# El Arga al norte, con el puente de la Magdalena.
	p.water(Rect2i(0, 3, 30, 3))
	p.water(Rect2i(34, 3, 30, 3))
	p.build_water(0.25)
	p.terrain(rects([Rect2i(30, 0, 4, 8), Rect2i(22, 52, 4, 4)]), ExteriorTiles.TERRAIN_PATH)
	p.forest(Rect2i(0, 0, 30, 2))
	p.forest(Rect2i(34, 0, 30, 2))

	# La muralla: la ciudad sobre una meseta de piedra. Se entra por el Portal de Francia (hueco
	# arriba) y se sale por las escaleras del sur.
	p.plateau(Rect2i(2, 7, 60, 45), [23, 24])
	for x: int in range(30, 34):
		p.decor.erase_cell(Vector2i(x, 7))
	p.paving(Rect2i(3, 8, 58, 41))
	p.build_paving()

	# Primera fila: servicios, Ayuntamiento y catedral.
	p.object(&"centro_pokemon", Vector2i(4, 17))
	p.object(&"tienda_verde", Vector2i(11, 17))
	p.object(&"tienda_morada", Vector2i(17, 17))
	p.object(&"tienda_azul", Vector2i(23, 17))
	p.object(&"palacio_infantado", Vector2i(36, 17))
	p.object(&"catedral_burgos", Vector2i(48, 17))
	p.object(&"casa_tejado_azul", Vector2i(55, 17))
	# La Plaza del Castillo: soportales alrededor del quiosco y el Café Iruña.
	for x: int in [4, 8, 12, 16]:
		p.object(&"soportales", Vector2i(x, 29))
	p.object(&"fuente_plaza", Vector2i(23, 27))
	p.object(&"casa_panaderia", Vector2i(36, 29))
	p.object(&"casa_rosa", Vector2i(50, 29))
	p.object(&"casa_roja_pequena", Vector2i(56, 29))
	# La calle Estafeta baja hasta la plaza de toros.
	p.object(&"maestranza", Vector2i(46, 44))
	p.object(&"felipe_iv", Vector2i(42, 40))
	# La Ciudadela: el parque del suroeste.
	p.terrain(rects([Rect2i(6, 36, 14, 10)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	for at: Vector2i in [Vector2i(4, 36), Vector2i(4, 46), Vector2i(20, 36), Vector2i(26, 46), Vector2i(30, 40)]:
		p.object(&"arbol_redondo", at)
	p.flowers(Rect2i(8, 47, 8, 2))
	p.build_forest()

	_sign(p, "CartelPortal", Vector2i(35, 9), ["PORTAL DE FRANCIA.", "Por aquí entran los peregrinos del Camino. Y los franceses, pero esos vienen en coche."])
	_sign(p, "CartelAyuntamiento", Vector2i(46, 18), ["AYUNTAMIENTO.",
		"Del balcón sale el chupinazo el 6 de julio a mediodía. «¡Pamploneses, viva San Fermín!» Y nueve días sin dormir."])
	_sign(p, "CartelCastillo", Vector2i(28, 28), ["PLAZA DEL CASTILLO.",
		"El cuarto de estar de Pamplona. El Café Iruña es de 1888; Hemingway se sentaba aquí. Pagaba poco, decía más."])
	_sign(p, "CartelEstafeta", Vector2i(36, 33), ["CALLE ESTAFETA.", "Por aquí corre el encierro: 875 metros, unos tres minutos y medio. Corre tú, que los Tauros no esperan."])
	_sign(p, "CartelToros", Vector2i(55, 45), ["PLAZA DE TOROS.", "Final del encierro. Fuera del 7 al 14 de julio, conciertos y bodas. Y algún encierro de Tauros, si preguntas."])
	_sign(p, "CartelCiudadela", Vector2i(21, 41), ["LA CIUDADELA.", "Fortaleza renacentista con forma de estrella. Hoy es un parque; las murallas solo protegen del viento."])
	_sign(p, "CartelSur", Vector2i(26, 53), ["↓ Ruta 21 · Viñedos de La Rioja.", "Logroño, la calle Laurel y, después, Valladolid."])

	p.spawn("default", Vector2i(31, 12))
	p.spawn("from_ruta_20", Vector2i(31, 0))
	p.spawn("from_ruta_21", Vector2i(23, 55))
	p.trainer("Mozo", &"pamplona_mozo", Vector2i(40, 34), LEFT, 3)
	p.trainer("Peregrino", &"pamplona_peregrino", Vector2i(29, 10), RIGHT, 3)
	p.npc("Pastelera", "npc_woman", Vector2i(20, 22), DOWN, PackedStringArray([
		"Los encierros de San Fermín se corren con periódico enrollado y pañuelo rojo. El periódico es para dar a los toros. No lo hagas.",
		"El resto del año, Pamplona es tranquilísima. Demasiado. Por eso guardamos energía para julio."]))
	p.npc("Navarro", "npc_old_man", Vector2i(32, 24), DOWN, PackedStringArray([
		"Fermín, Fermina, Fermintxu. Aquí en julio nos llamamos todos igual.",
		"¿Del Osasuna o de qué? Bueno, eres de fuera. Se te perdona."]))
	load("res://maps/_pintura/servicios_locales.gd").apply(p, "pamplona", "pamplona/exterior", JsonFile.read_dict("res://maps/_pintura/locales.json")["pamplona"])
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
