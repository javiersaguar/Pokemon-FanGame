extends SceneTree
## Ruta 26 · El Torcal de Antequera: composición provisional, norte arriba.
const OUT := "res://maps/ruta_26/exterior.tscn"
const SIZE := Vector2i(48, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"ruta_26/exterior"
	d.display_name = "Ruta 26 · El Torcal de Antequera"
	d.zone_id = &"ruta_26"
	d.encounter_table = &"ruta_26"
	d.region_map_position = Vector2i(12, 21)
	var p := Pintor.new("Ruta26", SIZE, d, 2124)
	p.fill_grass(0.18)
	p.soil(Rect2i(1, 1, 46, 62))
	# Dólmenes al norte de este tramo; Torcal al sur, como en la geografía real.
	p.plateau(Rect2i(2, 2, 18, 10), [9, 10])
	p.object(&"dolmen_antequera", Vector2i(8, 9))
	p.terrain(Pintor.cells(Rect2i(24, 0, 4, 64)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(9, 9, 2, 7)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(9, 13, 19, 3)), ExteriorTiles.TERRAIN_PATH)
	p.object(&"casa_madera", Vector2i(34, 10))
	# Reparto manual de hitos calizos, dejando pasos de dos casillas entre bases.
	for at: Vector2i in [Vector2i(3, 25), Vector2i(8, 27), Vector2i(13, 24), Vector2i(18, 27), Vector2i(32, 25), Vector2i(38, 23), Vector2i(43, 27),
			Vector2i(4, 35), Vector2i(9, 33), Vector2i(15, 36), Vector2i(20, 34), Vector2i(31, 35), Vector2i(36, 33), Vector2i(42, 36),
			Vector2i(3, 44), Vector2i(8, 42), Vector2i(14, 45), Vector2i(19, 43), Vector2i(32, 44), Vector2i(38, 43), Vector2i(43, 45),
			Vector2i(4, 53), Vector2i(10, 51), Vector2i(16, 54), Vector2i(21, 52), Vector2i(31, 53), Vector2i(37, 51), Vector2i(42, 54)]:
		p.object(&"roca_torcal", at)
	p.terrain(Pintor.cells(Rect2i(3, 57, 15, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(32, 14, 12, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.spawn("default", Vector2i(25, 1))
	p.spawn("from_ruta_25", Vector2i(25, 0))
	p.spawn("from_malaga", Vector2i(25, 63))
	p.connect_edge("north", &"ruta_25/exterior", 0, Vector2i(24, 28))
	p.trainer("Guia", &"ruta26_guia", Vector2i(21, 14), 1, 3)
	p.trainer("Escaladora", &"ruta26_escaladora", Vector2i(29, 43), 3, 3)
	_sign(p, "Dolmen", Vector2i(13, 13), ["DÓLMENES DE ANTEQUERA", "Cámaras bajo túmulos de tierra. La entrada es una representación compacta; interior pendiente."])
	_sign(p, "Torcal", Vector2i(29, 24), ["EL TORCAL · PAISAJE KÁRSTICO", "Estratos de caliza modelados por el agua. Aquí se comprimen Antequera y el Torcal."])
	_sign(p, "Sur", Vector2i(29, 62), ["SUR · MÁLAGA", "El enlace abrirá al pintar la ciudad."])
	print("Ruta 26 · El Torcal de Antequera: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
