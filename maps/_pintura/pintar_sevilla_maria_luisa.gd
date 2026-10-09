extends SceneTree
## Pinta Sevilla · María Luisa (maps/sevilla/maria_luisa.tscn) con el plano real
## docs/mundo/planos/sevilla.svg (norte arriba; docs/mundo/ciudades/sevilla.md): la Plaza de España con
## su canal, sus puentes y los bancos de azulejos de las provincias, y al sur el Parque de María Luisa,
## con sus glorietas, el estanque de los lotos, la isleta de los patos y la hierba alta. Se une sin
## fundido con Sevilla · Centro por el norte.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_sevilla_maria_luisa.gd -- --force

const OUT := "res://maps/sevilla/maria_luisa.tscn"
const SIZE := Vector2i(56, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_sevilla_maria_luisa: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"sevilla/maria_luisa"
	data.display_name = "Sevilla · Plaza de España"
	data.zone_id = &"sevilla"
	data.encounter_table = &"sevilla"
	data.region_map_position = Vector2i(8, 20)
	var p: RefCounted = painter.new("SevillaMariaLuisa", SIZE, data, 1929)
	p.fill_grass(0.25)
	p.connect_edge("north", &"sevilla/centro", 10, Vector2i(20, 36))

	# La plaza, pavimentada, con el canal y sus puentes (los huecos).
	p.paving(Rect2i(0, 0, 56, 20))
	p.build_paving()
	p.water(Rect2i(12, 14, 7, 2))
	p.water(Rect2i(21, 14, 14, 2))
	p.water(Rect2i(37, 14, 7, 2))
	p.build_water(0.3)
	p.object(&"plaza_espana", Vector2i(22, 10))
	for cell: Vector2i in [Vector2i(10, 12), Vector2i(44, 12), Vector2i(16, 9), Vector2i(38, 9)]:
		p.object(&"farola_verde", cell)
	p.object(&"fuente_plaza", Vector2i(26, 19))         # la fuente de Vicente Traver
	for cell: Vector2i in [Vector2i(3, 9), Vector2i(50, 9), Vector2i(3, 19), Vector2i(50, 19)]:
		p.object(&"manzano", cell)                         # naranjos
	for cell: Vector2i in [Vector2i(10, 6), Vector2i(43, 6)]:
		p.object(&"palmera", cell)
	for cell: Vector2i in [Vector2i(6, 13), Vector2i(46, 13)]:
		p.object(&"banco", cell)

	# El parque: caminos, estanques, glorietas, árboles y hierba alta.
	p.terrain(rects([Rect2i(26, 20, 4, 28), Rect2i(4, 32, 48, 3)]), ExteriorTiles.TERRAIN_PATH)
	p.pond(Rect2i(8, 22, 8, 6), [Vector2i(10, 24), Vector2i(12, 25), Vector2i(13, 23), Vector2i(11, 26)])
	p.pond(Rect2i(38, 37, 10, 7), [Vector2i(40, 40), Vector2i(44, 41)])
	p.terrain(rects([Rect2i(36, 22, 12, 7), Rect2i(4, 38, 14, 6)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	for r: Rect2i in [Rect2i(0, 44, 56, 4), Rect2i(52, 20, 4, 24), Rect2i(0, 20, 2, 12)]:
		p.forest(r)
	p.build_forest()
	for cell: Vector2i in [Vector2i(19, 25), Vector2i(31, 38), Vector2i(20, 41), Vector2i(48, 31)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"cerezo_grande", Vector2i(31, 30))
	for cell: Vector2i in [Vector2i(22, 30), Vector2i(34, 25), Vector2i(2, 37), Vector2i(49, 37)]:
		p.object(&"palmera", cell)
	p.object(&"fuente_cano", Vector2i(24, 40))
	p.object(&"banco", Vector2i(20, 37))
	p.hedge(32, 35, 42)
	p.flowers(Rect2i(16, 29, 3, 2), 0.4)
	p.flowers(Rect2i(36, 30, 4, 1), 0.5)

	# --- Carteles (bancos de azulejos de las provincias) ---
	p.deco(Vector2i(20, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelPlaza", Vector2i(20, 12), PackedStringArray(["PLAZA DE ESPAÑA (1929).",
		"Hecha para la Exposición Iberoamericana. Salió en Star Wars: aquí aterrizó una reina galáctica.",
		"Y aquí aterriza cada día un autobús de cruceristas."]))
	p.deco(Vector2i(8, 17), ExteriorTiles.SIGN)
	p.sign_text("BancoHuelva", Vector2i(8, 17), PackedStringArray(["BANCO DE HUELVA (azulejos).",
		"De aquí salieron las carabelas de Colón. Hoy sale el ferry a Canarias, que tarda casi lo mismo."]))
	p.deco(Vector2i(47, 17), ExteriorTiles.SIGN)
	p.sign_text("BancoSegovia", Vector2i(47, 17), PackedStringArray(["BANCO DE SEGOVIA (azulejos).",
		"El Acueducto, el cochinillo y un pueblo que se llama San Miguel de Bernuy. Te suena, ¿verdad?"]))
	p.deco(Vector2i(25, 21), ExteriorTiles.SIGN)
	p.sign_text("CartelParque", Vector2i(25, 21), PackedStringArray(["PARQUE DE MARÍA LUISA.",
		"Lo donó la infanta María Luisa en 1893. Las palomas lo ocuparon en 1894 y no se han ido."]))
	p.deco(Vector2i(37, 36), ExteriorTiles.SIGN)
	p.sign_text("CartelIsleta", Vector2i(37, 36), PackedStringArray(["ISLETA DE LOS PATOS.",
		"Prohibido dar pan a los patos. Los Psyduck, en cambio, aceptan tapas."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(27, 1))
	p.spawn("from_centro", Vector2i(27, 0))
	p.trainer("Curro", &"sevilla_palomas", Vector2i(34, 18), LEFT, 3)
	p.trainer("Pepe", &"sevilla_tuno", Vector2i(10, 33), RIGHT, 3)
	p.npc("Barquero", "npc_fisherman", Vector2i(20, 16), UP, PackedStringArray([
		"¿Barca por el canal? Seis euros los 35 minutos. Los remos los pones tú y los selfis también."]))
	p.npc("Abuelo", "npc_old_man", Vector2i(40, 33), DOWN, PackedStringArray([
		"Antes venía a echar de comer a las palomas. Ahora las palomas me echan de comer a mí: me roban el bocadillo."]))
	return p
