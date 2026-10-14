extends SceneTree
## Ruta 20 · Sierra de Aralar (docs/mundo/rutas.md). Baja desde Bilbao por el norte (columnas 34–37)
## hasta Pamplona por el sur (columnas 30–33), en zigzag por el hayedo (pinos del pack hasta que haya
## hayas). Por el camino: los pastos de las ovejas latxas con la borda del pastor, la plaza del deporte
## rural (troncos de los aizkolaris y piedras de los harrijasotzailes) y el santuario de San Miguel de
## Aralar en lo alto.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_20.gd -- --force

const OUT := "res://maps/ruta_20/exterior.tscn"
const SIZE := Vector2i(48, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_20: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	d.id = &"ruta_20/exterior"
	d.display_name = "Ruta 20 · Sierra de Aralar"
	d.zone_id = &"ruta_20"
	d.encounter_table = &"ruta_20"
	d.region_map_position = Vector2i(18, 3)
	var p := Pintor.new("Ruta20", SIZE, d, 2020)
	p.fill_grass(0.28)
	p.connect_edge("north", &"bilbao/exterior", 0, Vector2i(34, 38))
	p.connect_edge("south", &"pamplona/exterior", 0, Vector2i(30, 34))

	p.terrain(rects([
		Rect2i(34, 0, 4, 18),    # desde Bilbao
		Rect2i(10, 14, 28, 4),   # hacia el oeste, por el hayedo
		Rect2i(10, 14, 4, 20),   # baja
		Rect2i(10, 30, 24, 4),   # hacia el este, por los pastos
		Rect2i(30, 30, 4, 26),   # baja a Pamplona
		Rect2i(20, 6, 2, 8),     # subida al santuario
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(16, 20, 18, 8),
		Rect2i(36, 34, 10, 12),
		Rect2i(2, 36, 8, 10),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Hayedo: bosque cerrado alrededor del camino.
	p.forest(Rect2i(0, 0, 18, 12))
	p.forest(Rect2i(24, 0, 10, 12))
	p.forest(Rect2i(40, 0, 8, 30))
	p.forest(Rect2i(0, 18, 8, 14))
	p.forest(Rect2i(0, 48, 28, 8))
	p.forest(Rect2i(36, 48, 12, 8))
	p.forest(Rect2i(16, 36, 12, 8))

	# San Miguel de Aralar, en lo alto, en un claro.
	p.object(&"ermita_virgen_del_rio", Vector2i(19, 5))
	# Los pastos de las latxas, con la borda y la valla.
	p.object(&"casa_paja", Vector2i(16, 29))
	p.fence(24, 33, 28)
	# La plaza del deporte rural: troncos y piedras para levantar.
	for x: int in [36, 38]:
		p.deco(Vector2i(x, 20), ExteriorTiles.LOG_LEFT[0])
		p.deco(Vector2i(x + 1, 20), ExteriorTiles.LOG_LEFT[1])
	for at: Vector2i in [Vector2i(36, 24), Vector2i(38, 24), Vector2i(37, 26)]:
		p.deco(at, ExteriorTiles.ROCK)
	p.object(&"arbol_redondo", Vector2i(26, 46))
	p.flowers(Rect2i(22, 9, 4, 2))
	p.build_forest()

	_sign(p, "CartelNorte", Vector2i(38, 2), ["↑ Bilbao."])
	_sign(p, "CartelSantuario", Vector2i(22, 12), ["SAN MIGUEL DE ARALAR.",
		"Santuario románico en lo alto de la sierra. Dicen que el arcángel bajó aquí. Con este frío, subió enseguida."])
	_sign(p, "CartelDeporteRural", Vector2i(35, 18), ["HERRI KIROLAK · DEPORTE RURAL VASCO.",
		"Aizkolaris (troncos con hacha), harrijasotzailes (piedras de doscientos kilos) y sokatira. Aquí se apuesta todo."])
	_sign(p, "CartelPastos", Vector2i(22, 29), ["PASTOS DE ARALAR.", "Ovejas latxas: de su leche sale el queso Idiazabal. De su lana, nada que puedas permitirte."])
	_sign(p, "CartelSur", Vector2i(34, 52), ["↓ Pamplona.", "Si es julio, corre. Si no es julio, corre igual: llueve."])

	p.spawn("default", Vector2i(35, 4))
	p.spawn("from_bilbao", Vector2i(35, 0))
	p.spawn("from_pamplona", Vector2i(31, 55))
	p.trainer("Aizkolari", &"ruta20_aizkolari", Vector2i(37, 22), LEFT, 3)
	p.trainer("Pastor", &"ruta20_pastor", Vector2i(26, 26), DOWN, 3)
	p.trainer("Harrijasotzaile", &"ruta20_harrijasotzaile", Vector2i(29, 40), RIGHT, 3)
	p.npc("Artzain", "pastor", Vector2i(14, 26), RIGHT, PackedStringArray([
		"Las latxas suben al monte en primavera y bajan en otoño. Yo, al revés: subo en otoño a buscarlas.",
		"El Idiazabal de verdad está ahumado en la borda. El del súper huele a humo de mechero."]))
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
