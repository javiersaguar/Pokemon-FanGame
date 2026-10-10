extends SceneTree
## Ruta 25 · Despeñaperros: composición provisional, norte arriba.
const OUT := "res://maps/ruta_25/exterior.tscn"
const SIZE := Vector2i(48, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"ruta_25/exterior"
	d.display_name = "Ruta 25 · Despeñaperros"
	d.zone_id = &"ruta_25"
	d.encounter_table = &"ruta_25"
	d.region_map_position = Vector2i(14, 17)
	var p := Pintor.new("Ruta25", SIZE, d, 2124)
	p.fill_grass(0.22)
	# Montoro al noroeste, comprimido respecto al desfiladero real.
	p.plateau(Rect2i(-1, -1, 22, 25), [11, 12])
	p.pond(Rect2i(2, 3, 14, 15))
	p.nine_slice(Rect2i(2, 18, 15, 3), ExteriorTiles.PAVING_STONE)
	p.object(&"casa_madera", Vector2i(16, 20))
	p.plateau(Rect2i(37, 12, 12, 36), [40, 41])
	p.plateau(Rect2i(-1, 35, 20, 27), [10, 11])
	# Curvas amplias, con cuatro casillas en los extremos y todos los codos.
	for rect: Rect2i in [Rect2i(24, 0, 4, 27), Rect2i(10, 24, 26, 4), Rect2i(32, 24, 4, 15), Rect2i(20, 35, 16, 4), Rect2i(20, 35, 4, 17), Rect2i(20, 48, 8, 4), Rect2i(24, 48, 4, 16)]:
		p.terrain(Pintor.cells(rect), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(11, 19, 2, 6)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(40, 38, 2, 10)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(10, 54, 2, 8)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(32, 50, 11, 7)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(3, 29, 13, 4)), ExteriorTiles.TERRAIN_TALL_GRASS)
	for at: Vector2i in [Vector2i(22, 9), Vector2i(20, 19), Vector2i(29, 30), Vector2i(16, 49), Vector2i(30, 59)]:
		p.object(&"pino", at)
	p.object(&"casa_granero", Vector2i(3, 55))
	p.spawn("default", Vector2i(25, 1))
	p.spawn("from_puertollano", Vector2i(25, 0))
	p.spawn("from_ruta_26", Vector2i(25, 63))
	p.connect_edge("north", &"puertollano/exterior", 10, Vector2i(24, 28))
	p.trainer("Camionero", &"ruta25_camionero", Vector2i(29, 26), 3, 3)
	p.trainer("Montanera", &"ruta25_montanera", Vector2i(30, 38), 1, 3)
	_sign(p, "Montoro", Vector2i(17, 22), ["EMBALSE DEL MONTORO", "Representación comprimida al noroeste del desfiladero; no están juntos en la realidad."])
	_sign(p, "Organos", Vector2i(39, 49), ["DESPEÑAPERROS · SIERRA MORENA", "Los Órganos son paredes de cuarcita. Estos riscos usan todavía las piezas existentes."])
	_sign(p, "Sur", Vector2i(29, 62), ["SUR · RUTA 26, ANTEQUERA", "El enlace abrirá al pintar la ruta."])
	print("Ruta 25 · Despeñaperros: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
