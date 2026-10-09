extends SceneTree
## Pinta la Ruta 3 · Puerto de Navacerrada (maps/ruta_3/exterior.tscn), de Segovia hacia El Escorial
## (docs/mundo/rutas.md): se llega por arriba al puerto (1858 m), nevado, con la estación de
## esquí; se baja por escaleras al pinar de granito de la ladera y, abajo, al Valle de
## Cuelgamuros, con la basílica excavada en la roca y la cruz encima. En la nieve salen Pokémon,
## como en la hierba alta. Se une sin fundido con la Ruta 2 por el norte (mismas columnas).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_3.gd -- --force

const OUT := "res://maps/ruta_3/exterior.tscn"
const SIZE := Vector2i(36, 80)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_3: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_3/exterior"
	data.display_name = "Ruta 3 · Puerto de Navacerrada"
	data.zone_id = &"ruta_3"
	data.encounter_table = &"ruta_3"
	data.region_map_position = Vector2i(13, 10)
	var p: RefCounted = painter.new("Ruta3", SIZE, data, 1858)
	p.fill_grass(0.2)
	p.connect_edge("north", &"ruta_2/exterior")
	p.connect_edge("south", &"ruta_4/exterior")

	# --- El puerto, nevado (arriba) ---
	p.snow(Rect2i(0, 0, SIZE.x, 26))

	# --- La ladera (en medio) y el valle (abajo): caminos y hierba alta ---
	p.terrain(rects([
		Rect2i(20, 28, 2, 9), Rect2i(14, 35, 8, 2), Rect2i(14, 37, 2, 13),
		Rect2i(14, 52, 2, 4), Rect2i(14, 56, 9, 2), Rect2i(20, 58, 3, 22), Rect2i(16, 68, 4, 2),
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(22, 30, 8, 5), Rect2i(6, 38, 6, 8), Rect2i(17, 40, 8, 7), Rect2i(24, 60, 4, 8),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.paving(Rect2i(0, 67, 16, 6))
	p.build_paving()

	# Alturas: la ladera (meseta grande) con el puerto dentro (arriba), y la roca de Cuelgamuros.
	p.plateau(Rect2i(-2, -2, 40, 54), [14, 15])
	p.plateau(Rect2i(-2, -2, 40, 30), [20, 21])
	p.plateau(Rect2i(-2, 52, 16, 14))

	# Pinos nevados en el puerto, pinar de Valsaín en la ladera y en el valle.
	for r: Rect2i in [Rect2i(0, 0, 8, 14), Rect2i(0, 14, 4, 10), Rect2i(30, 14, 6, 10), Rect2i(8, 0, 4, 4),
			Rect2i(12, 16, 4, 4), Rect2i(18, 4, 2, 4), Rect2i(24, 16, 2, 4), Rect2i(8, 18, 2, 4), Rect2i(34, 0, 2, 8)]:
		p.forest(r, true)
	for r: Rect2i in [Rect2i(0, 28, 4, 20), Rect2i(32, 28, 4, 20), Rect2i(6, 28, 6, 8), Rect2i(28, 38, 4, 8),
			Rect2i(0, 54, 4, 10), Rect2i(10, 54, 2, 8), Rect2i(24, 52, 12, 6), Rect2i(28, 64, 8, 16),
			Rect2i(0, 74, 8, 6)]:
		p.forest(r)
	p.build_forest()

	# Estación de esquí: el refugio y la cafetería.
	p.object(&"casa_madera", Vector2i(24, 10))
	p.object(&"casa_granero", Vector2i(29, 10))

	# Valle de Cuelgamuros: la basílica excavada en la roca y la cruz encima.
	p.object(&"cruz_cuelgamuros", Vector2i(5, 61))
	p.object(&"basilica_cuelgamuros", Vector2i(2, 66))

	# Granito de la sierra.
	for cell: Vector2i in [Vector2i(13, 4), Vector2i(28, 21), Vector2i(5, 25), Vector2i(17, 23), Vector2i(21, 14), Vector2i(26, 37),
			Vector2i(13, 46), Vector2i(30, 48), Vector2i(17, 60), Vector2i(25, 72), Vector2i(10, 76)]:
		p.deco(cell, ExteriorTiles.ROCK)
	for cell: Vector2i in [Vector2i(12, 30), Vector2i(23, 47), Vector2i(18, 64)]:
		p.deco(cell, ExteriorTiles.ROCK_BROWN)
	p.object(&"arbol_redondo", Vector2i(18, 33))
	p.object(&"arbustos", Vector2i(25, 71))
	p.sprinkle(Rect2i(0, 28, SIZE.x, 52), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(17, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelPuerto", Vector2i(17, 2), PackedStringArray(["PUERTO DE NAVACERRADA · 1858 m.",
		"Límite entre Segovia y Madrid. Cadenas obligatorias (y paciencia)."]))
	p.deco(Vector2i(23, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelEsqui", Vector2i(23, 11), PackedStringArray(["ESTACIÓN DE ESQUÍ.",
		"Abierta los días que nieva. Cerrada los días que no. Hoy: depende."]))
	p.deco(Vector2i(13, 70), ExteriorTiles.SIGN)
	p.sign_text("CartelCuelgamuros", Vector2i(13, 70), PackedStringArray(["VALLE DE CUELGAMUROS.",
		"Basílica excavada en el granito y cruz de 150 metros.",
		"El inquilino más famoso se mudó en 2019. Dejó la cruz."]))
	p.deco(Vector2i(19, 78), ExteriorTiles.SIGN)
	p.sign_text("CartelSur", Vector2i(19, 78), PackedStringArray(["↓ Ruta 4 · El Escorial y Galapagar.",
		"↑ Puerto de Navacerrada."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(21, 2))
	p.spawn("from_route_2", Vector2i(21, 0))
	p.trainer("Borja", &"ruta3_borja", Vector2i(16, 13), RIGHT, 4)
	p.trainer("Lucia", &"ruta3_lucia", Vector2i(16, 42), LEFT, 2)
	p.npc("Cafetero", "camarero", Vector2i(33, 11), LEFT, PackedStringArray([
		"Chocolate con churros: doce euros. Es el precio de la altitud."]))
	p.npc("Guia", "npc_old_man", Vector2i(10, 69), DOWN, PackedStringArray([
		"Cuelgamuros, antes Valle de los Caídos. Ahora lo quieren resignificar.",
		"Yo vengo a ver si resignifican también el aparcamiento, que es carísimo."]))
	return p
