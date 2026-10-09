extends SceneTree
## Pinta la Ruta 12 · Sierra Nevada y Granada (maps/ruta_12/exterior.tscn), de Murcia (este) hacia el
## mar de olivos (oeste) por la A-92 (docs/mundo/rutas.md): el altiplano seco de Guadix y Baza con sus
## casas cueva; Sierra Nevada en dos alturas, con nieve, pinos nevados, la estación de esquí de
## Pradollano y el Pico Veleta arriba del todo; y la vega de Granada, con la Alhambra en su colina y
## un cortijo en plena boda. La unión con Murcia la hace el Agente 5 (aparición from_murcia en el
## borde este, filas 26-28); se une sin fundido con la Ruta 13 por el oeste.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_12.gd -- --force

const OUT := "res://maps/ruta_12/exterior.tscn"
const SIZE := Vector2i(72, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_12: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_12/exterior"
	data.display_name = "Ruta 12 · Sierra Nevada y Granada"
	data.zone_id = &"ruta_12"
	data.encounter_table = &"ruta_12"
	data.region_map_position = Vector2i(17, 20)
	var p: RefCounted = painter.new("Ruta12", SIZE, data, 1238)
	p.fill_grass(0.25)
	p.connect_edge("west", &"ruta_13/exterior", 0, Vector2i(20, 30))

	# La A-92: camino de tierra con curvas de este a oeste, y el desvío a las escaleras de la sierra.
	p.terrain(rects([Rect2i(56, 26, 16, 3), Rect2i(40, 28, 18, 3), Rect2i(20, 26, 22, 3), Rect2i(0, 24, 22, 3),
		Rect2i(34, 22, 2, 4), Rect2i(9, 21, 1, 3)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(2, 28, 12, 6), Rect2i(24, 31, 10, 4), Rect2i(58, 30, 10, 5), Rect2i(60, 18, 8, 6),
		Rect2i(52, 10, 6, 6)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	# El altiplano de Guadix: tierra seca.
	for r: Rect2i in [Rect2i(54, 5, 5, 3), Rect2i(63, 6, 5, 4), Rect2i(64, 13, 4, 3), Rect2i(44, 32, 6, 3)]:
		p.soil(r)

	# Sierra Nevada: la sierra (con la estación de esquí) y el Veleta encima, todo nevado.
	p.snow(Rect2i(19, 0, 32, 20))
	p.plateau(Rect2i(18, -2, 34, 24), [34, 35])
	p.plateau(Rect2i(30, -2, 14, 11), [36, 37])

	# Bosques: pinos nevados en la sierra, pinos en los bordes y pasillos en el borde oeste.
	for r: Rect2i in [Rect2i(20, 0, 8, 6), Rect2i(44, 0, 6, 4), Rect2i(20, 14, 4, 4), Rect2i(46, 12, 4, 6),
			Rect2i(28, 12, 4, 4), Rect2i(38, 12, 4, 4), Rect2i(44, 6, 2, 4), Rect2i(24, 16, 2, 4)]:
		p.forest(r, true)
	for cell: Vector2i in [Vector2i(33, 15), Vector2i(43, 17), Vector2i(29, 2), Vector2i(48, 10)]:
		p.deco(cell, ExteriorTiles.ROCK)
	for r: Rect2i in [Rect2i(0, 0, 18, 6), Rect2i(52, 0, 20, 4), Rect2i(0, 36, 72, 4), Rect2i(0, 6, 2, 14),
			Rect2i(0, 30, 2, 6), Rect2i(14, 30, 6, 6), Rect2i(68, 30, 4, 6), Rect2i(68, 4, 4, 18)]:
		p.forest(r)
	p.build_forest()

	# La Alhambra en la colina de la Sabika, y el cortijo de la boda en la vega.
	p.object(&"alhambra", Vector2i(4, 12))
	p.object(&"casa_dos_aguas", Vector2i(8, 21))
	p.fence(3, 8, 23)
	p.fence(10, 16, 23)
	p.object(&"banco", Vector2i(12, 21))
	p.object(&"banco", Vector2i(12, 17))
	p.object(&"farola_rosa", Vector2i(16, 16))
	p.object(&"farola_rosa", Vector2i(3, 18))
	p.flowers(Rect2i(12, 14, 4, 1), 0.5)
	p.flowers(Rect2i(4, 15, 3, 2), 0.4)
	for cell: Vector2i in [Vector2i(14, 9), Vector2i(60, 15), Vector2i(43, 25)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"arbol_verde", Vector2i(36, 35))
	for cell: Vector2i in [Vector2i(56, 9), Vector2i(66, 11), Vector2i(48, 24), Vector2i(26, 23), Vector2i(62, 25),
			Vector2i(21, 32)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 == 0 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(69, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(69, 25), PackedStringArray(["RUTA 12 · SIERRA NEVADA Y GRANADA",
		"← Granada y el mar de olivos   → Murcia. Cadenas obligatorias si nieva. Y si no, también."]))
	p.deco(Vector2i(61, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelGuadix", Vector2i(61, 25), PackedStringArray(["GUADIX · CASAS CUEVA.",
		"Se alquila cueva. 20 grados todo el año. Ventanas: ninguna. Precio: el de un ático en Madrid."]))
	p.deco(Vector2i(36, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelPradollano", Vector2i(36, 23), PackedStringArray(["ESTACIÓN DE ESQUÍ DE SIERRA NEVADA · PRADOLLANO.",
		"La estación más al sur de Europa. El forfait, el más al norte de tu presupuesto."]))
	p.deco(Vector2i(38, 6), ExteriorTiles.SIGN)
	p.sign_text("CartelVeleta", Vector2i(38, 6), PackedStringArray(["PICO VELETA · 3.396 m.",
		"El Mulhacén es más alto. Pero no tiene cartel, así que gana el Veleta."]))
	p.deco(Vector2i(12, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelAlhambra", Vector2i(12, 12), PackedStringArray(["LA ALHAMBRA.",
		"Palacio y fortaleza nazarí. Las entradas se agotan con tres meses de antelación.",
		"Los bots de reventa las compran con seis."]))
	p.deco(Vector2i(2, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelBoda", Vector2i(2, 23), PackedStringArray(["CORTIJO EL OLIVAR · HOY, BODA.",
		"Aviso de los novios: aquí los besos se piden antes de darlos.",
		"Sí, también va por ti, el del palco."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(70, 27))
	p.spawn("from_murcia", Vector2i(71, 27))
	p.spawn("from_ruta_13", Vector2i(0, 25))
	p.trainer("Iker", &"ruta12_esquiador", Vector2i(26, 10), RIGHT, 4)
	p.trainer("Paqui", &"ruta12_montanera", Vector2i(34, 3), DOWN, 3)
	p.trainer("Rocio", &"ruta12_invitada", Vector2i(14, 22), LEFT, 3)
	p.npc("Camarero", "npc_man", Vector2i(16, 20), LEFT, PackedStringArray([
		"Llevo sirviendo jamón desde las doce. La boda empezó a las doce y cuarto.",
		"Y el padrino ha pedido otra ronda para «calentar el micrófono»."]))
	p.npc("Abuela", "npc_old_woman", Vector2i(5, 19), RIGHT, PackedStringArray([
		"En mis tiempos una boda era una misa y un bocadillo. Ahora hay photocall, barra libre y un dron.",
		"El dron ha grabado más besos de la cuenta, dicen."]))
	p.npc("Guia", "npc_lass", Vector2i(10, 13), LEFT, PackedStringArray([
		"¿La Alhambra? Desde aquí se ve gratis. Dentro, 19 euros. Y con cita, como el médico."]))
	p.npc("Pastor", "npc_old_man", Vector2i(58, 13), DOWN, PackedStringArray([
		"Mi abuelo vivía en una cueva por pobre. Mi nieto vive en una por moda. Paga más que el abuelo."]))
	return p
