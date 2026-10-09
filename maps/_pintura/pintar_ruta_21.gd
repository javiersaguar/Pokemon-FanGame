extends SceneTree
## Ruta 21: viñedos de La Rioja. Norte arriba; entrada de Pamplona reservada al Agente 5.
## Los calados se representan con fachadas; interiores y servicios pendientes.
const OUT := "res://maps/ruta_21/exterior.tscn"
const SIZE := Vector2i(48, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var p := Pintor.new("Ruta21", SIZE, _data(), 2121)
	p.fill_grass(0.25)
	for y: int in [13, 23, 27, 31, 46, 50, 54]:
		p.soil(Rect2i(2, y, 18, 3))
		p.soil(Rect2i(28, y, 18, 3))
	p.terrain(Pintor.cells(Rect2i(22, 0, 4, 64)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(8, 18, 30, 3)), ExteriorTiles.TERRAIN_PATH)
	p.terrain(Pintor.cells(Rect2i(8, 40, 30, 3)), ExteriorTiles.TERRAIN_PATH)
	# Ebro en el norte: el camino cruza por un vado seco de cuatro casillas.
	p.water(Rect2i(0, 6, 22, 4))
	p.water(Rect2i(26, 6, 22, 4))
	p.build_water()
	# Espalderas separadas por calles de trabajo. Se puede recorrer cada hilera.
	for y: int in [14, 24, 28, 32, 47, 51, 55]:
		for x: int in [3, 5, 7, 9, 11, 13, 15, 17, 29, 31, 33, 35, 37, 39, 41, 43]:
			p.object(&"cepa_rioja", Vector2i(x, y))
	# Logroño y las bodegas/calados: asentamientos comprimidos, sin interiores ficticios.
	p.object(&"casa_granero", Vector2i(9, 17))
	p.object(&"casa_roja_chimenea", Vector2i(32, 17))
	p.object(&"casa_madera", Vector2i(9, 39))
	p.object(&"casa_dos_aguas", Vector2i(32, 39))
	p.terrain(Pintor.cells(Rect2i(2, 58, 14, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(32, 58, 14, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"arbol_redondo", Vector2i(2, 39))
	p.object(&"arbol_redondo", Vector2i(42, 39))
	p.spawn("default", Vector2i(24, 1))
	p.spawn("from_pamplona", Vector2i(24, 0))
	p.spawn("from_ruta_22", Vector2i(24, 63))
	p.trainer("Vendimiador", &"ruta21_vendimiador", Vector2i(18, 20), 2, 3)
	p.trainer("Sumiller", &"ruta21_sumiller", Vector2i(31, 41), 1, 3)
	_sign(p, "Laurel", Vector2i(29, 20), ["LOGROÑO · CALLE LAUREL", "Pincho, vino y otro pincho. El gimnasio más cerca: caminar hasta casa."])
	_sign(p, "Calado", Vector2i(14, 39), ["CALADOS DE LA RIOJA", "El vino envejece bajo tierra. Tu nómina también, pero sin denominación de origen."])
	_sign(p, "Salida", Vector2i(27, 62), ["RUTA 21 · VIÑEDOS DE LA RIOJA", "Sur: Burgos y Atapuerca. Norte: Pamplona."])
	p.npc("Bodeguera", "npc_old_woman", Vector2i(14, 18), 0, PackedStringArray(["El campo no tiene teletrabajo. A la uva no le vale que estés conectado.", "Si buscas sombra, vete a la bodega. Aquí el sol también ficha."]))
	print("Ruta21: ", error_string(p.save(OUT)))
	quit()
func _data() -> MapData:
	var d := MapData.new()
	d.id = &"ruta_21/exterior"
	d.display_name = "Ruta 21 · Viñedos de La Rioja"
	d.zone_id = &"ruta_21"
	d.encounter_table = &"ruta_21"
	d.region_map_position = Vector2i(17, 5)
	return d
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
