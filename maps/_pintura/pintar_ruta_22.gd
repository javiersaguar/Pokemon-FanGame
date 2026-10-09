extends SceneTree
## Ruta 22 · Burgos y Atapuerca. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/ruta_22/exterior.tscn"
const SIZE := Vector2i(48, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"ruta_22/exterior"
	d.display_name = "Ruta 22 · Burgos y Atapuerca"
	d.zone_id = &"ruta_22"
	d.encounter_table = &"ruta_22"
	d.region_map_position = Vector2i(14, 5)
	var p := Pintor.new("Ruta22", SIZE, d, 2122)
	p.fill_grass(0.23)
	p.paving(Rect2i(1, 18, 20, 15))
	p.build_paving()
	p.terrain(Pintor.cells(Rect2i(22, 0, 4, 64)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(5, 28, 35, 3)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(38, 12, 2, 16)), ExteriorTiles.TERRAIN_PATH)
	p.plateau(Rect2i(29, -2, 18, 26), [38, 39])
	# Atapuerca queda al este de Burgos; la trinchera revela cortes de la sierra.
	for y: int in [7, 11, 15]:
		p.soil(Rect2i(32, y, 4, 2))
		p.soil(Rect2i(41, y, 4, 2))
		p.deco(Vector2i(33, y), ExteriorTiles.ROCK)
		p.deco(Vector2i(42, y), ExteriorTiles.ROCK_BROWN)
	p.object(&"catedral_burgos", Vector2i(6, 26))
	p.object(&"casa_roja_chimenea", Vector2i(15, 26))
	p.object(&"casa_madera", Vector2i(1, 16))
	p.object(&"casa_granero", Vector2i(15, 16))
	p.object(&"banco", Vector2i(11, 30))
	p.object(&"farola_verde", Vector2i(3, 31))
	p.object(&"farola_verde", Vector2i(19, 31))
	p.object(&"arbol_redondo", Vector2i(4, 5))
	p.object(&"arbol_redondo", Vector2i(12, 5))
	p.flowers(Rect2i(5, 40, 12, 3))
	# Arlanzón al sur del casco antiguo; corredor pisable sobre el agua.
	p.water(Rect2i(0, 34, 22, 5))
	p.water(Rect2i(26, 34, 22, 5))
	p.build_water()
	p.object_under(&"puente_piedra", Vector2i(21, 38))
	p.forest(Rect2i(0, 42, 8, 22))
	p.forest(Rect2i(40, 42, 8, 22))
	p.build_forest()
	p.terrain(Pintor.cells(Rect2i(10, 46, 10, 8)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(28, 54, 10, 8)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.spawn("default", Vector2i(24, 1))
	p.spawn("from_ruta_21", Vector2i(24, 0))
	p.spawn("from_valladolid", Vector2i(24, 63))
	p.connect_edge("north", &"ruta_21/exterior", 0, Vector2i(22, 26))
	p.trainer("Arqueologo", &"ruta22_arqueologa", Vector2i(40, 17), 1, 2)
	p.trainer("Paleontologo", &"ruta22_paleontologo", Vector2i(18, 43), 2, 3)
	_sign(p, "Atapuerca", Vector2i(37, 22), ["ATAPUERCA · TRINCHERA DEL FERROCARRIL", "El tren descubrió los fósiles. Hoy descubrir un tren que llegue a tiempo sería otro hallazgo."])
	_sign(p, "Catedral", Vector2i(5, 27), ["CATEDRAL DE BURGOS · SANTA MARÍA", "Dos agujas y una obra que empezó en 1221. Tu ayuntamiento todavía está en el estudio previo."])
	_sign(p, "Sur", Vector2i(27, 61), ["RUTA 22 · BURGOS Y ATAPUERCA", "Sur: Valladolid. Norte: los viñedos de La Rioja."])
	p.npc("Investigador", "npc_man", Vector2i(33, 19), 2, PackedStringArray(["Aquí se excava con paciencia. Un fósil no se arranca a golpes.", "Los huesos antiguos tienen más historia que mi contrato de investigación."]))
	print("Ruta 22 · Burgos y Atapuerca: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
