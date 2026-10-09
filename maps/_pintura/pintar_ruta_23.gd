extends SceneTree
## Ruta 23 · Cuéllar y Tierra de Pinares. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/ruta_23/exterior.tscn"
const SIZE := Vector2i(64, 40)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"ruta_23/exterior"
	d.display_name = "Ruta 23 · Cuéllar y Tierra de Pinares"
	d.zone_id = &"ruta_23"
	d.encounter_table = &"ruta_23"
	d.region_map_position = Vector2i(12, 8)
	var p := Pintor.new("Ruta23", SIZE, d, 2122)
	p.fill_grass(0.22)
	p.paving(Rect2i(4, 4, 21, 14))
	p.build_paving()
	p.plateau(Rect2i(3, 2, 23, 16), [16, 17])
	p.terrain(Pintor.cells(Rect2i(0, 18, 64, 4)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(16, 12, 2, 6)), ExteriorTiles.TERRAIN_PATH)
	p.object(&"castillo_cuellar", Vector2i(10, 11))
	p.object(&"iglesia_san_miguel", Vector2i(19, 11))
	p.object(&"casa_roja_chimenea", Vector2i(5, 28))
	p.object(&"casa_granero", Vector2i(20, 28))
	p.object(&"tienda_verde", Vector2i(28, 16))
	p.object(&"banco", Vector2i(8, 13))
	p.object(&"farola_verde", Vector2i(5, 17))
	p.forest(Rect2i(33, 0, 31, 14))
	p.forest(Rect2i(0, 29, 64, 11))
	p.build_forest()
	for at: Vector2i in [Vector2i(35, 17), Vector2i(40, 26), Vector2i(47, 17), Vector2i(55, 26)]:
		p.object(&"pino", at)
	p.terrain(Pintor.cells(Rect2i(31, 23, 12, 4)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(49, 23, 12, 4)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.flowers(Rect2i(6, 29, 10, 3))
	p.spawn("default", Vector2i(1, 20))
	p.spawn("from_valladolid", Vector2i(0, 20))
	p.spawn("from_san_miguel", Vector2i(63, 20))
	p.connect_edge("west", &"valladolid/exterior", 12, Vector2i(18, 22))
	p.connect_edge("east", &"pueblo_inicial/exterior", 13, Vector2i(18, 22))
	p.trainer("Resinero", &"ruta23_resinero", Vector2i(36, 23), 3, 2)
	p.trainer("Jinete", &"ruta23_jinete", Vector2i(47, 22), 1, 3)
	_sign(p, "Castillo", Vector2i(15, 12), ["CASTILLO DE LOS DUQUES DE ALBURQUERQUE", "Castillo, palacio e instituto. La clase de Historia aquí tiene ventaja de campo."])
	_sign(p, "Cuellar", Vector2i(25, 20), ["CUÉLLAR · TIERRA DE PINARES", "Este: San Miguel de Bernuy. Oeste: Valladolid."])
	_sign(p, "Mercadona", Vector2i(32, 17), ["MERCADONA · CUÉLLAR", "Para comprar sin ir hasta Segovia. Interior pendiente."])
	p.npc("Vecino", "npc_man", Vector2i(8, 21), 0, PackedStringArray(["En Cuéllar los encierros salen al campo, acompañados por caballos.", "Yo corro cuando anuncian el cierre del supermercado."]))
	print("Ruta 23 · Cuéllar y Tierra de Pinares: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
