extends SceneTree
## Pinta Madrid · Retiro y Paseo del Prado (maps/madrid/retiro.tscn), con el plano real
## docs/mundo/planos/madrid_centro.svg (norte arriba): la calle de Alcalá llega de la Gran Vía a la
## glorieta de Cibeles (la fuente, el Palacio de Cibeles = Ayuntamiento, el Banco de España) y sigue
## hasta la Plaza de la Independencia con la Puerta de Alcalá; el Paseo de Recoletos y del Prado baja
## de norte a sur con Neptuno, el Museo del Prado y el Jardín Botánico; la Carrera de San Jerónimo
## llega de Sol al Congreso y sus leones; al sur, la glorieta y la estación de Atocha; al este, el
## Parque del Retiro con el Estanque Grande, el monumento a Alfonso XII y el Palacio de Cristal.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_retiro.gd -- --force

const OUT := "res://maps/madrid/retiro.tscn"
const SIZE := Vector2i(72, 60)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_retiro: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"madrid/retiro"
	data.display_name = "Madrid · Retiro y Prado"
	data.zone_id = &"madrid"
	data.encounter_table = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridRetiro", SIZE, data, 1868)
	p.fill_grass(0.2)
	p.connect_edge("west", &"madrid/centro", 8, Vector2i(12, 20))   # Alcalá ⇄ Gran Vía
	p.connect_edge("west", &"madrid/centro", 2, Vector2i(28, 34))   # San Jerónimo ⇄ Sol
	p.connect_edge("east", &"ruta_5/exterior", 8, Vector2i(0, 14))   # por el norte del Retiro, hacia la A-2

	# --- Baldosas: Alcalá, Cibeles, la Independencia, el Paseo del Prado, San Jerónimo y Atocha ---
	for r: Rect2i in [Rect2i(0, 14, 48, 4), Rect2i(6, 10, 18, 14), Rect2i(28, 18, 18, 10), Rect2i(10, 0, 8, 50),
			Rect2i(0, 30, 10, 3), Rect2i(0, 48, 32, 12), Rect2i(18, 32, 12, 2), Rect2i(18, 45, 14, 2)]:
		p.paving(r)
	p.build_paving()

	# --- El Retiro: paseos de tierra, hierba alta, arboledas, el Estanque y el lago del Palacio de Cristal ---
	p.terrain(rects([Rect2i(46, 14, 3, 42), Rect2i(46, 33, 24, 2), Rect2i(64, 14, 2, 40), Rect2i(46, 54, 24, 2),
		Rect2i(48, 14, 18, 1)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(66, 2, 6, 10), Rect2i(50, 36, 12, 4), Rect2i(67, 36, 5, 14), Rect2i(36, 38, 8, 8),
		Rect2i(49, 56, 14, 4)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.water(Rect2i(50, 22, 14, 10))
	p.water(Rect2i(50, 49, 12, 4))
	p.build_water(0.3)
	for r: Rect2i in [Rect2i(52, 0, 12, 8), Rect2i(68, 14, 4, 20), Rect2i(40, 50, 6, 10), Rect2i(66, 52, 6, 8)]:
		p.forest(r)
	p.build_forest()

	# --- Monumentos ---
	p.object(&"cibeles", Vector2i(13, 19))
	p.object(&"palacio_cibeles", Vector2i(24, 13))
	p.object(&"puerta_alcala", Vector2i(34, 25))
	p.object(&"monumento_alfonso_xii", Vector2i(51, 21))
	p.object(&"palacio_cristal", Vector2i(52, 47))
	p.object(&"fuente_neptuno", Vector2i(12, 36))
	p.object(&"congreso", Vector2i(0, 29))
	p.object(&"leon_congreso", Vector2i(2, 32))
	p.object(&"leon_congreso", Vector2i(6, 32))
	p.object(&"museo_prado", Vector2i(18, 44))
	p.object(&"estacion_atocha", Vector2i(14, 58))

	# --- Edificios ---
	for b: Array in [
		[&"oficinas_azules", Vector2i(1, 13)],      # Banco de España
		[&"bloque_verde_2", Vector2i(36, 13)],      # Casa de América
		[&"oficinas_azules", Vector2i(21, 31)],     # Hotel Ritz
		[&"bloque_verde_2", Vector2i(33, 37)],      # Casón del Buen Retiro
		[&"bloque_pisos", Vector2i(1, 47)],
		[&"tienda_verde", Vector2i(34, 59)],        # Mercadona de Atocha
	]:
		p.object(b[0], b[1])

	# Jardín Botánico (setos y árboles) y arbolado del Paseo del Prado.
	for y: int in [49, 52]:
		p.hedge(33, 39, y)
	for cell: Vector2i in [Vector2i(8, 40), Vector2i(8, 46), Vector2i(18, 28), Vector2i(44, 30), Vector2i(44, 4),
			Vector2i(48, 4), Vector2i(62, 45), Vector2i(50, 47)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(5, 22), Vector2i(22, 22), Vector2i(29, 52), Vector2i(1, 52)]:
		p.object(&"farola_verde", cell)
	p.flowers(Rect2i(28, 28, 4, 1), 0.4)
	p.sprinkle(Rect2i(40, 0, 32, 60), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(19, 21), ExteriorTiles.SIGN)
	p.sign_text("CartelCibeles", Vector2i(19, 21), PackedStringArray(["PLAZA DE CIBELES.",
		"Aquí celebra los títulos el Real Madrid. Los del Atlético, en Neptuno. Los del resto, en casa."]))
	p.deco(Vector2i(34, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelAyuntamiento", Vector2i(34, 13), PackedStringArray(["AYUNTAMIENTO DE MADRID.",
		"El alcalde atiende a los vecinos con cita previa. La próxima, en 2031."]))
	p.deco(Vector2i(42, 26), ExteriorTiles.SIGN)
	p.sign_text("CartelPuerta", Vector2i(42, 26), PackedStringArray(["PUERTA DE ALCALÁ (1778).",
		"Ahí está, ahí está, viendo pasar el tiempo."]))
	p.deco(Vector2i(10, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelCongreso", Vector2i(10, 30), PackedStringArray(["CONGRESO DE LOS DIPUTADOS.",
		"Los leones se hicieron fundiendo cañones. Los diputados, fundiendo presupuestos."]))
	p.deco(Vector2i(33, 44), ExteriorTiles.SIGN)
	p.sign_text("CartelPrado", Vector2i(33, 44), PackedStringArray(["MUSEO DEL PRADO.",
		"Velázquez, Goya, El Bosco... Y una cola que llega hasta Atocha."]))
	p.deco(Vector2i(28, 58), ExteriorTiles.SIGN)
	p.sign_text("CartelAtocha", Vector2i(28, 58), PackedStringArray(["ESTACIÓN DE ATOCHA. AVE y Cercanías.",
		"Próximas salidas: Valladolid, Málaga y Barcelona. Retraso estimado: sí."]))
	p.deco(Vector2i(49, 20), ExteriorTiles.SIGN)
	p.sign_text("CartelEstanque", Vector2i(49, 20), PackedStringArray(["ESTANQUE GRANDE DEL RETIRO.",
		"Alquiler de barcas: 8 € los 45 minutos. Con Surf, gratis."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_gran_via", Vector2i(0, 15))
	p.spawn("from_sol", Vector2i(0, 31))
	p.trainer("Emilio", &"madrid_palomas", Vector2i(49, 40), RIGHT, 3)
	p.trainer("Iker", &"madrid_patinetero", Vector2i(13, 27), DOWN, 4)
	p.trainer("Borja", &"madrid_crossfitero", Vector2i(60, 34), LEFT, 4)
	p.npc("Periodista", "npc_man", Vector2i(8, 31), LEFT, PackedStringArray([
		"¡Señoría, señoría! Una pregunta... ¡Se ha ido corriendo otra vez!",
		"Aquí a la puerta siempre hay alguien con un micrófono. Ojo con lo que dices."]))
	p.npc("Barquero", "npc_fisherman", Vector2i(62, 32), UP, PackedStringArray([
		"Las barcas del Retiro: cuarenta y cinco minutos remando para dar una vuelta. Como la política."]))
	p.npc("Revisor", "revisorcercanias", Vector2i(23, 59), DOWN, PackedStringArray([
		"El Cercanías C-5 a Móstoles, Leganés y Getafe sale... cuando salga.",
		"Y el AVE, cuando el Ministerio diga. Hoy dice que no."]))
	return p
