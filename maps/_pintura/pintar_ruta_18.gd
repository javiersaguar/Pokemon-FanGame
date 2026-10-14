extends SceneTree
## Ruta 18 · Asturias y Picos de Europa (docs/mundo/rutas.md). Entra por el oeste desde la Ruta 17
## (filas 8–11) y sale por el este a Santander (filas 20–23). Al norte, los Picos: una meseta con los
## lagos de Covadonga y, encima, otra con la nieve del Naranjo de Bulnes. Abajo, los prados de las
## vacas, el pueblo de la sidrería y el río Sella, el del descenso en canoa.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_18.gd -- --force

const OUT := "res://maps/ruta_18/exterior.tscn"
const SIZE := Vector2i(72, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_18: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	d.id = &"ruta_18/exterior"
	d.display_name = "Ruta 18 · Asturias y Picos de Europa"
	d.zone_id = &"ruta_18"
	d.encounter_table = &"ruta_18"
	d.region_map_position = Vector2i(10, 2)
	var p := Pintor.new("Ruta18", SIZE, d, 1818)
	p.fill_grass(0.26)
	p.connect_edge("west", &"ruta_17/exterior", 0, Vector2i(8, 12))
	p.connect_edge("east", &"santander/exterior", 0, Vector2i(20, 24))

	# Bosque en los bordes, con hueco en las dos salidas.
	p.forest(Rect2i(0, 0, 20, 6))
	p.forest(Rect2i(0, 14, 10, 18))
	p.forest(Rect2i(50, 0, 22, 18))
	p.forest(Rect2i(0, 32, 56, 2))
	p.forest(Rect2i(60, 32, 12, 2))

	# El Sella, al sur: canoas en verano, encuentros de agua todo el año.
	p.water(Rect2i(0, 34, 72, 6))
	p.build_water(0.3)

	p.terrain(rects([
		Rect2i(0, 8, 18, 4),     # desde la Ruta 17
		Rect2i(14, 8, 4, 16),    # baja al valle
		Rect2i(14, 20, 58, 4),   # hacia Santander
		Rect2i(34, 15, 2, 5),    # subida a los Picos
		Rect2i(56, 24, 4, 9),    # bajada al Sella
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(10, 26, 20, 6),
		Rect2i(36, 25, 16, 7),
		Rect2i(62, 25, 10, 7),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Picos de Europa: meseta con los lagos y, encima, la cumbre nevada.
	p.plateau(Rect2i(20, 0, 30, 15), [34, 35])
	p.pond(Rect2i(23, 3, 6, 4))
	p.pond(Rect2i(42, 2, 6, 4))
	p.plateau(Rect2i(30, 0, 10, 8), [34, 35])
	p.snow(Rect2i(31, 0, 8, 6))
	p.forest(Rect2i(32, 0, 6, 4), true)
	p.terrain(rects([Rect2i(22, 8, 7, 4)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"iglesia_san_miguel", Vector2i(42, 12))

	# El pueblo de la sidrería, junto al camino.
	p.object(&"casa_teja", Vector2i(19, 19))
	p.object(&"casa_roja_chimenea", Vector2i(26, 19))
	p.object(&"casa_granero", Vector2i(44, 19))
	p.object(&"arbol_redondo", Vector2i(31, 18))
	p.object(&"arbol_redondo", Vector2i(52, 31))
	p.object(&"manzano", Vector2i(32, 30))
	p.object(&"manzano", Vector2i(34, 28))
	p.flowers(Rect2i(20, 24, 4, 2))
	p.build_forest()

	_sign(p, "CartelOeste", Vector2i(2, 12), ["← Ruta 17 · Galicia interior.", "Si oyes una gaita, vas bien."])
	_sign(p, "CartelPicos", Vector2i(36, 18), ["PICOS DE EUROPA · COVADONGA.",
		"Arriba, los lagos Enol y Ercina y la cumbre del Naranjo de Bulnes. La basílica, la cueva y la Santina, más abajo."])
	_sign(p, "CartelSidreria", Vector2i(25, 24), ["SIDRERÍA.", "Se escancia desde lo alto, sin mirar. Lo que cae al suelo se llama «culín perdido»."])
	_sign(p, "CartelSella", Vector2i(55, 30), ["DESCENSO DEL SELLA.", "Primer sábado de agosto: miles de canoas y una fiesta en Ribadesella. El resto del año, el río es tuyo."])
	_sign(p, "CartelEste", Vector2i(68, 19), ["→ Santander.", "Rabas, Sardinero y el Palacio de la Magdalena."])

	p.spawn("default", Vector2i(16, 18))
	p.spawn("from_ruta_17", Vector2i(0, 9))
	p.spawn("from_santander", Vector2i(71, 21))
	p.trainer("Escanciador", &"ruta18_escanciador", Vector2i(28, 24), UP, 3)
	p.trainer("Vaqueira", &"ruta18_vaqueira", Vector2i(44, 24), RIGHT, 3)
	p.trainer("Montanero", &"ruta18_montanero", Vector2i(38, 9), LEFT, 3)
	p.npc("Guia", "npc_man", Vector2i(33, 16), DOWN, PackedStringArray([
		"Arriba están los lagos. Si hay niebla, no se ve nada; si no hay niebla, tampoco, porque hay coches.",
		"En verano se sube en autobús: el coche particular está prohibido. Como en el centro de Madrid, pero con vacas."]))
	p.npc("Paisano", "npc_old_man", Vector2i(12, 22), RIGHT, PackedStringArray([
		"Asturias es España; lo demás, tierra conquistada. Eso dicen aquí, y lo dicen en serio.",
		"¿Quieres un culín? Es de manzana. O sea, es fruta."]))
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
