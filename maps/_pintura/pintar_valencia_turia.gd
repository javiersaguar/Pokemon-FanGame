extends SceneTree
## Pinta Valencia · Jardín del Turia (maps/valencia/turia.tscn): el antiguo cauce del río, convertido en
## un parque largo tras la riada de 1957, de oeste a este: entra desde las Torres de Serranos (Ciutat
## Vella, al sur), sigue entre árboles, hierba alta y caminos, y termina en la Ciudad de las Artes y las
## Ciencias (Palau de les Arts, Hemisfèric y Museu de les Ciències) sobre sus láminas de agua. Por el
## este se sale hacia la Malvarrosa.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_valencia_turia.gd -- --force

const OUT := "res://maps/valencia/turia.tscn"
const SIZE := Vector2i(84, 36)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_valencia_turia: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"valencia/turia"
	data.display_name = "Valencia · Jardín del Turia"
	data.zone_id = &"valencia"
	data.encounter_table = &"valencia"
	data.region_map_position = Vector2i(22, 14)
	var p: RefCounted = painter.new("ValenciaTuria", SIZE, data, 1957)
	p.fill_grass(0.25)
	p.connect_edge("south", &"valencia/ciutat_vella", 8, Vector2i(20, 30))
	p.connect_edge("east", &"valencia/malvarrosa", -4, Vector2i(26, 34))

	# Las avenidas a los dos lados del antiguo cauce y la explanada de la Ciudad de las Artes.
	p.paving(Rect2i(0, 0, SIZE.x, 4))
	p.paving(Rect2i(0, 32, SIZE.x, 4))
	p.paving(Rect2i(40, 26, 44, 6))
	p.build_paving()
	# Caminos, hierba alta y arboledas del jardín.
	p.terrain(rects([Rect2i(0, 16, 44, 2), Rect2i(22, 4, 2, 28), Rect2i(10, 8, 2, 8)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(2, 6, 7, 8), Rect2i(13, 19, 8, 9), Rect2i(26, 6, 10, 8), Rect2i(28, 20, 8, 8),
		Rect2i(52, 5, 20, 7), Rect2i(44, 13, 10, 3)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	for r: Rect2i in [Rect2i(0, 20, 10, 10), Rect2i(36, 4, 4, 12), Rect2i(14, 4, 6, 4), Rect2i(78, 4, 6, 14)]:
		p.forest(r)
	p.build_forest()
	for cell: Vector2i in [Vector2i(11, 24), Vector2i(26, 20), Vector2i(37, 19), Vector2i(38, 30)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(41, 10), Vector2i(45, 11), Vector2i(74, 16), Vector2i(58, 16), Vector2i(66, 16)]:
		p.object(&"palmera", cell)

	# La Ciudad de las Artes y las Ciencias.
	p.object(&"palau_arts", Vector2i(42, 25))
	p.object(&"hemisferic", Vector2i(55, 25))
	p.object(&"museu_ciencies", Vector2i(66, 25))

	# --- Carteles ---
	p.deco(Vector2i(24, 31), ExteriorTiles.SIGN)
	p.sign_text("CartelTuria", Vector2i(24, 31), PackedStringArray(["JARDÍ DEL TÚRIA.",
		"Nueve kilómetros de parque donde antes había un río. Dentro, el Gulliver gigante: tú eres el liliputiense."]))
	p.deco(Vector2i(53, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelArtes", Vector2i(53, 27), PackedStringArray(["CIUTAT DE LES ARTS I LES CIÈNCIES.",
		"Calatrava, 1998. Costó tres veces lo previsto. El ojo del Hemisfèric aún no se lo cree."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(24, 34))
	p.spawn("from_ciutat_vella", Vector2i(24, 35))
	p.trainer("Andrea", &"vlc_corredora", Vector2i(30, 17), LEFT, 4)
	p.trainer("Amparo", &"vlc_abuela", Vector2i(12, 17), RIGHT, 3)
	p.npc("Guia", "npc_man", Vector2i(62, 30), DOWN, PackedStringArray([
		"El Oceanogràfic está aquí al lado: el acuario más grande de Europa. Los Pokémon de agua hacen cola para entrar."]))
	return p
