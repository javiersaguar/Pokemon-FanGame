extends SceneTree
## Pinta la Ruta 5 · Corredor del Henares (maps/ruta_5/exterior.tscn), de Madrid hacia Zaragoza por la
## A-2 (docs/mundo/rutas.md): al oeste, el polígono de naves logísticas; en medio, Alcalá de Henares
## con la Universidad (Colegio Mayor de San Ildefonso), la Plaza de Cervantes y la casa natal de
## Cervantes; al este, Guadalajara con el Palacio del Infantado. Al sur corre el río Henares. Se une
## sin fundido con el Retiro de Madrid por el oeste.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_5.gd -- --force

const OUT := "res://maps/ruta_5/exterior.tscn"
const SIZE := Vector2i(72, 32)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_5: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_5/exterior"
	data.display_name = "Ruta 5 · Corredor del Henares"
	data.zone_id = &"ruta_5"
	data.encounter_table = &"ruta_5"
	data.region_map_position = Vector2i(15, 11)
	var p: RefCounted = painter.new("Ruta5", SIZE, data, 1547)
	p.fill_grass(0.2)
	p.connect_edge("west", &"madrid/retiro", -8, Vector2i(8, 22))
	p.connect_edge("east", &"ruta_6/exterior", 4, Vector2i(14, 18))

	# La vía de servicio de la A-2, las plazas de Alcalá y la de Guadalajara.
	for r: Rect2i in [Rect2i(0, 14, 72, 4), Rect2i(24, 13, 22, 1), Rect2i(37, 18, 9, 8), Rect2i(50, 13, 14, 1)]:
		p.paving(r)
	p.build_paving()
	p.terrain(rects([Rect2i(26, 18, 2, 8), Rect2i(64, 18, 2, 10)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(13, 20, 10, 8), Rect2i(47, 19, 6, 9), Rect2i(66, 19, 6, 9), Rect2i(14, 2, 8, 4)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	p.water(Rect2i(0, 29, 72, 3))
	p.build_water(0.25)
	for r: Rect2i in [Rect2i(38, 0, 12, 4), Rect2i(66, 0, 6, 6)]:
		p.forest(r)
	p.build_forest()

	# Polígono logístico.
	p.object(&"nave_logistica", Vector2i(2, 12))
	p.object(&"nave_logistica", Vector2i(2, 24))
	# Alcalá de Henares.
	p.object(&"universidad_alcala", Vector2i(26, 12))
	p.object(&"casa_naranja", Vector2i(29, 25))      # casa natal de Cervantes
	p.object(&"soportales", Vector2i(33, 24))         # la calle Mayor porticada
	p.object(&"busto", Vector2i(40, 23))              # Cervantes en su plaza (provisional)
	p.object(&"casa_roja_chimenea", Vector2i(19, 12))
	# Guadalajara.
	p.object(&"palacio_infantado", Vector2i(52, 12))
	p.object(&"casa_roja_chimenea", Vector2i(64, 12))
	p.object(&"casa_dos_aguas", Vector2i(46, 12))
	p.object(&"bloque_pisos", Vector2i(56, 27))
	for cell: Vector2i in [Vector2i(37, 21), Vector2i(44, 21), Vector2i(23, 27), Vector2i(62, 27)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(37, 25), Vector2i(43, 25)]:
		p.object(&"farola_verde", cell)
	p.flowers(Rect2i(41, 19, 2, 1), 0.4)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(1, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(1, 13), PackedStringArray(["RUTA 5 · CORREDOR DEL HENARES (A-2)",
		"← Madrid   → Alcalá de Henares, Guadalajara y Zaragoza"]))
	p.deco(Vector2i(24, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelUniversidad", Vector2i(24, 12), PackedStringArray(["UNIVERSIDAD DE ALCALÁ.",
		"Fundada por el cardenal Cisneros en 1499. Aquí se entrega el Premio Cervantes."]))
	p.deco(Vector2i(28, 26), ExteriorTiles.SIGN)
	p.sign_text("CartelCervantes", Vector2i(28, 26), PackedStringArray(["MUSEO CASA NATAL DE CERVANTES.",
		"Aquí nació en 1547 el autor del Quijote. Aún no ha cobrado los derechos."]))
	p.deco(Vector2i(50, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelInfantado", Vector2i(50, 12), PackedStringArray(["PALACIO DEL INFANTADO · Guadalajara.",
		"De los Mendoza, siglo XV. Fachada de puntas de diamante: ni el Bernabéu."]))
	p.deco(Vector2i(70, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelEste", Vector2i(70, 13), PackedStringArray(["→ Ruta 6 · Medinaceli y Calatayud.",
		"La España vaciada empieza aquí. Llena el depósito."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_madrid", Vector2i(0, 15))
	p.trainer("Wilmer", &"ruta5_repartidor", Vector2i(14, 18), UP, 3)
	p.trainer("Nuria", &"ruta5_opositora", Vector2i(39, 19), DOWN, 3)
	p.trainer("Alex", &"ruta5_estudiante", Vector2i(46, 18), LEFT, 3)
	p.npc("Guia", "npc_old_man", Vector2i(30, 13), DOWN, PackedStringArray([
		"En Alcalá anidan cigüeñas en cada torre. Ellas no pagan el IBI, pero vuelven todos los años."]))
	p.npc("Camionero", "npc_man", Vector2i(12, 13), DOWN, PackedStringArray([
		"Llevo diecisiete horas en la A-2. Si llego a Zaragoza, me hago un altar en el Pilar."]))
	return p
