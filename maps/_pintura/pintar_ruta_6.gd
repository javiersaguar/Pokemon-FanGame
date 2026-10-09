extends SceneTree
## Pinta la Ruta 6 · Medinaceli y Calatayud (maps/ruta_6/exterior.tscn), por la A-2 hacia Zaragoza
## (docs/mundo/rutas.md): el páramo vacío de Soria; Medinaceli en lo alto de su cerro con el arco
## romano de tres vanos; un pueblo de la España vaciada con casas en venta y su último vecino; y
## Calatayud con la torre mudéjar de la Colegiata de Santa María y el mesón de la Dolores, junto al
## río Jalón. Se une sin fundido con la Ruta 5 por el oeste.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_6.gd -- --force

const OUT := "res://maps/ruta_6/exterior.tscn"
const SIZE := Vector2i(72, 34)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_6: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_6/exterior"
	data.display_name = "Ruta 6 · Medinaceli y Calatayud"
	data.zone_id = &"ruta_6"
	data.encounter_table = &"ruta_6"
	data.region_map_position = Vector2i(18, 8)
	var p: RefCounted = painter.new("Ruta6", SIZE, data, 1975)
	p.fill_grass(0.3)
	p.connect_edge("west", &"ruta_5/exterior", -4, Vector2i(18, 22))

	# La carretera (A-2 vieja) cruza el páramo de oeste a este; calles de Calatayud.
	p.paving(Rect2i(0, 18, 72, 4))
	p.build_paving()
	# Caminos de tierra al cerro de Medinaceli y al pueblo vaciado.
	p.terrain(rects([Rect2i(20, 16, 2, 2), Rect2i(38, 8, 2, 10), Rect2i(30, 8, 8, 2)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(2, 23, 14, 6), Rect2i(24, 24, 12, 6), Rect2i(42, 2, 10, 6), Rect2i(64, 2, 8, 8)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	for r: Rect2i in [Rect2i(0, 2, 4, 3), Rect2i(46, 24, 4, 3), Rect2i(16, 28, 5, 3)]:
		p.soil(r)
	p.water(Rect2i(36, 30, 36, 4))   # el río Jalón
	p.build_water(0.25)

	# El cerro de Medinaceli, con su escalera.
	p.plateau(Rect2i(8, -2, 22, 18), [20, 21])

	# Medinaceli: el arco romano y unas casas de piedra.
	p.object(&"arco_medinaceli", Vector2i(14, 12))
	p.object(&"casa_naranja", Vector2i(23, 11))
	p.object(&"casa_granero", Vector2i(9, 11))
	# El pueblo de la España vaciada.
	p.object(&"casa_roja_chimenea", Vector2i(31, 17))
	p.object(&"casa_madera", Vector2i(41, 17))
	p.object(&"casa_dos_aguas", Vector2i(46, 17))
	# Calatayud: la torre mudéjar de la Colegiata, el mesón de la Dolores y casas.
	p.object(&"torre_mudejar", Vector2i(56, 17))
	p.object(&"casa_granero", Vector2i(60, 17))      # el mesón de la Dolores
	p.object(&"casa_roja", Vector2i(64, 17))

	for cell: Vector2i in [Vector2i(5, 16), Vector2i(36, 6), Vector2i(57, 6), Vector2i(4, 31), Vector2i(30, 31)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(2, 9), Vector2i(34, 2), Vector2i(50, 12), Vector2i(12, 30), Vector2i(41, 27),
			Vector2i(62, 9)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 == 0 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	# --- Carteles ---
	p.deco(Vector2i(1, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(1, 17), PackedStringArray(["RUTA 6 · MEDINACELI Y CALATAYUD",
		"← Guadalajara   → Zaragoza. Próxima gasolinera: quién sabe."]))
	p.deco(Vector2i(22, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelArco", Vector2i(22, 13), PackedStringArray(["ARCO ROMANO DE MEDINACELI (siglo I).",
		"El único de tres vanos de España. Tiene más años que todos los vecinos juntos. Y más que vecinos."]))
	p.deco(Vector2i(36, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelVenta", Vector2i(36, 17), PackedStringArray(["SE VENDE. Casa de pueblo con corral.",
		"Precio: 6000 €. O que vengas a vivir. Lo que prefieras, de verdad."]))
	p.deco(Vector2i(59, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelDolores", Vector2i(59, 17), PackedStringArray(["MESÓN DE LA DOLORES · Calatayud.",
		"«Si vas a Calatayud...». Ya, ya. Todos nos la sabemos."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 19))
	p.spawn("from_ruta_5", Vector2i(0, 19))
	p.trainer("Cirilo", &"ruta6_pastor", Vector2i(10, 22), UP, 3)
	p.trainer("Anselmo", &"ruta6_jubilado", Vector2i(50, 22), UP, 3)
	p.npc("UltimoVecino", "npc_old_man", Vector2i(44, 18), DOWN, PackedStringArray([
		"Soy el último vecino del pueblo. El alcalde, el cura y el del bar: todo yo.",
		"Si te quedas, te hago concejal. Hay sitio de sobra en el pleno."]))
	return p
