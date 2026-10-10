extends SceneTree
## Ruta 24 · La Mancha: composición provisional, norte arriba.
const OUT := "res://maps/ruta_24/exterior.tscn"
const SIZE := Vector2i(48, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"ruta_24/exterior"
	d.display_name = "Ruta 24 · La Mancha"
	d.zone_id = &"ruta_24"
	d.encounter_table = &"ruta_24"
	d.region_map_position = Vector2i(14, 14)
	var p := Pintor.new("Ruta24", SIZE, d, 2124)
	p.fill_grass(0.20)
	# Cerro Calderico al oeste; Campo de Criptana queda al este, comprimido.
	p.plateau(Rect2i(0, -1, 21, 23), [16, 17])
	p.terrain(Pintor.cells(Rect2i(24, 0, 4, 64)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(9, 22, 19, 4)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(16, 10, 2, 12)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(28, 31, 18, 3)), ExteriorTiles.TERRAIN_PATH)
	for x: int in [2, 6, 10, 14, 18]:
		p.object(&"molino_mancha", Vector2i(x, 10))
	for x: int in [32, 36, 40]:
		p.object(&"molino_mancha", Vector2i(x, 30))
	# Parcelas de secano: suelo del pack, vallados con pasos laterales.
	p.soil(Rect2i(2, 32, 18, 11))
	p.soil(Rect2i(32, 43, 13, 13))
	for y: int in [34, 38, 42]:
		p.fence(3, 18, y)
	for y: int in [46, 50, 54]:
		p.fence(33, 43, y)
	p.object(&"casa_granero", Vector2i(3, 59))
	p.object(&"casa_madera", Vector2i(34, 16))
	p.terrain(Pintor.cells(Rect2i(3, 46, 15, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(32, 4, 12, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	for at: Vector2i in [Vector2i(21, 33), Vector2i(20, 57), Vector2i(31, 37), Vector2i(45, 18)]:
		p.object(&"arbol_redondo", at)
	p.flowers(Rect2i(30, 58, 8, 4))
	p.spawn("default", Vector2i(25, 1))
	p.spawn("from_getafe", Vector2i(25, 0))
	p.spawn("from_puertollano", Vector2i(25, 63))
	p.connect_edge("south", &"puertollano/exterior", 10, Vector2i(24, 28))
	p.connect_edge("north", &"getafe/exterior", 22, Vector2i(24, 28))
	p.trainer("Caballero", &"ruta24_caballero", Vector2i(20, 24), 1, 3)
	p.trainer("Escudero", &"ruta24_escudero", Vector2i(29, 32), 3, 3)
	_sign(p, "Consuegra", Vector2i(14, 13), ["CONSUEGRA · CERRO CALDERICO", "Molinos blancos sobre la cresta. Sus aspas molían cereal, no entrenadores."])
	_sign(p, "Criptana", Vector2i(37, 34), ["CAMPO DE CRIPTANA · SIERRA DE LOS MOLINOS", "El mapa reúne dos conjuntos de La Mancha; las distancias están comprimidas."])
	_sign(p, "Sur", Vector2i(29, 62), ["RUTA 24 · LA MANCHA", "Norte: Getafe. Sur: Puertollano."])
	p.npc("Agricultora", "npc_old_woman", Vector2i(8, 44), 0, PackedStringArray(["La llanura parece vacía hasta que te toca recorrerla con calor.", "Los molinos aprovechaban el viento para moler el cereal."]))
	print("Ruta 24 · La Mancha: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
