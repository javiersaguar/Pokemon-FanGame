extends SceneTree
## Pinta Las Palmas de Gran Canaria · Las Canteras (maps/las_palmas/canteras.tscn) con el plano real
## docs/mundo/planos/las_palmas.svg (norte arriba; docs/mundo/ciudades/las_palmas.md): al oeste el
## Atlántico, la playa de Las Canteras con la Barra (la barrera de roca que deja el agua tranquila) y el
## paseo con palmeras; al norte, La Isleta volcánica; en medio, el barrio con el Mercado del Puerto y los
## locales; al este, el Castillo de la Luz y el Puerto de La Luz, donde atraca el ferry de Huelva. Se une
## sin fundido con Vegueta y Triana (sur).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_las_palmas_canteras.gd -- --force

const OUT := "res://maps/las_palmas/canteras.tscn"
const SIZE := Vector2i(64, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_las_palmas_canteras: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"las_palmas/canteras"
	data.display_name = "Las Palmas · Las Canteras"
	data.zone_id = &"las_palmas"
	data.encounter_table = &"las_palmas"
	data.region_map_position = Vector2i(3, 23)
	var p: RefCounted = painter.new("LasPalmasCanteras", SIZE, data, 1478)
	p.fill_grass(0.15)
	p.connect_edge("south", &"las_palmas/vegueta_triana", -8, Vector2i(24, 40))

	# El barrio, pavimentado, con el pantalán del ferry; la playa; el mar a los dos lados.
	p.paving(Rect2i(18, 10, 29, 38))
	p.build_paving()
	p.soil(Rect2i(10, 8, 8, 40))                       # la playa de Las Canteras
	p.water(Rect2i(0, 0, 10, 48))                      # el Atlántico
	p.water(Rect2i(52, 0, 12, 24))
	p.water(Rect2i(47, 24, 17, 24))                    # el Puerto de La Luz
	p.build_water(0.2)
	for cell: Vector2i in [Vector2i(4, 14), Vector2i(5, 17), Vector2i(4, 20), Vector2i(6, 23), Vector2i(5, 26),
			Vector2i(4, 29), Vector2i(6, 32), Vector2i(5, 35)]:
		p.deco(cell, ExteriorTiles.ROCK)               # la Barra
	# La Isleta: malpaís volcánico con su montaña, hierba alta y rocas negras.
	p.plateau(Rect2i(20, -2, 18, 12), [28, 29])
	p.terrain(rects([Rect2i(10, 0, 8, 7), Rect2i(40, 0, 10, 8)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	for cell: Vector2i in [Vector2i(22, 2), Vector2i(26, 4), Vector2i(31, 1), Vector2i(35, 5), Vector2i(24, 6),
			Vector2i(33, 3), Vector2i(38, 9), Vector2i(50, 2)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 == 0 else ExteriorTiles.ROCK_BROWN)

	# El Castillo de la Luz, el ferry de Huelva y el barrio.
	p.object(&"castillo_luz", Vector2i(41, 15))
	p.object(&"ferry", Vector2i(48, 40))
	for b: Array in [[&"puesto_mercado", Vector2i(24, 20)], [&"tienda_verde", Vector2i(30, 20)],
			[&"tienda_naranja", Vector2i(36, 21)], [&"edificio_cristal", Vector2i(21, 34)], [&"bloque_pisos", Vector2i(31, 32)],
			[&"bloque_verde", Vector2i(38, 32)], [&"oficinas_azules", Vector2i(22, 46)], [&"bloque_pisos", Vector2i(39, 46)]]:
		p.object(b[0], b[1])
	for y: int in [14, 20, 26, 32, 38, 44]:
		p.object(&"palmera", Vector2i(18, y))          # el paseo de Las Canteras
	for cell: Vector2i in [Vector2i(13, 18), Vector2i(12, 36)]:
		p.object(&"sombrilla", cell)

	# --- Carteles ---
	p.deco(Vector2i(21, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelCanteras", Vector2i(21, 11), PackedStringArray(["PLAYA DE LAS CANTERAS.",
		"Tres kilómetros de arena con la Barra, que para las olas. Las de turistas, no."]))
	p.deco(Vector2i(46, 16), ExteriorTiles.SIGN)
	p.sign_text("CartelCastillo", Vector2i(46, 16), PackedStringArray(["CASTILLO DE LA LUZ (siglo XV).",
		"Defendía la isla de piratas. Hoy la defiende de cruceros. Con el mismo éxito."]))
	p.deco(Vector2i(44, 37), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(44, 37), PackedStringArray(["FERRY · Las Palmas → Huelva.",
		"La pasarela está al final del pantalán. ¡Bienvenido a Canarias, mi niño!"]))
	p.deco(Vector2i(29, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelIsleta", Vector2i(29, 11), PackedStringArray(["LA ISLETA.",
		"Volcanes apagados y barrio de pescadores. Lo más caliente ahora es el alquiler."]))

	# --- Apariciones, ferry, entrenadores y vecinos ---
	p.spawn("default", Vector2i(46, 36))
	p.spawn("from_ferry", Vector2i(46, 36))
	p.spawn("from_vegueta", Vector2i(31, 47))
	p.warp("FerryHuelva", Vector2i(46, 38), &"huelva/exterior", &"from_ferry", &"")
	p.trainer("Aday", &"lp_surfista", Vector2i(12, 24), RIGHT, 3)
	p.trainer("Yaiza", &"lp_nadadora", Vector2i(15, 41), UP, 3)
	p.npc("Pescador", "npc_fisherman", Vector2i(23, 12), DOWN, PackedStringArray([
		"En La Isleta se pesca la vieja, que es un pescado, no tu suegra. Aunque a veces se parecen."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(28, 24), DOWN, PackedStringArray([
		"¡Mi niño! ¿Vienes en el ferry de Huelva? Pues ahora a coger la guagua, que aquí el autobús se llama así."]))
	return p
