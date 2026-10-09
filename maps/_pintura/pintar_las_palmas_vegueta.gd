extends SceneTree
## Pinta Las Palmas de Gran Canaria · Vegueta y Triana (maps/las_palmas/vegueta_triana.tscn) con el plano
## real docs/mundo/planos/las_palmas.svg (norte arriba; docs/mundo/ciudades/las_palmas.md): al norte,
## Triana, con la calle Mayor de casas modernistas, el Parque de San Telmo y su quiosco, el Centro Pokémon y
## el estanco; al sur, Vegueta, el barrio fundacional, con la Catedral de Santa Ana y sus perros de bronce,
## la Casa de Colón y el Mercado de Vegueta; al este, el Atlántico por la Avenida Marítima. Se une sin
## fundido con Las Canteras (norte) y con la Ruta 15 (sur).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_las_palmas_vegueta.gd -- --force

const OUT := "res://maps/las_palmas/vegueta_triana.tscn"
const SIZE := Vector2i(56, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_las_palmas_vegueta: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"las_palmas/vegueta_triana"
	data.display_name = "Las Palmas · Vegueta y Triana"
	data.zone_id = &"las_palmas"
	data.encounter_table = &"las_palmas"
	data.region_map_position = Vector2i(3, 23)
	var p: RefCounted = painter.new("LasPalmasVegueta", SIZE, data, 1478)
	p.fill_grass(0.15)
	p.connect_edge("north", &"las_palmas/canteras", 8, Vector2i(16, 32))
	p.connect_edge("south", &"ruta_15/exterior", -8, Vector2i(20, 28))

	p.paving(Rect2i(0, 0, 48, 48))
	p.build_paving()
	p.water(Rect2i(50, 0, 6, 48))                      # el Atlántico, por la Avenida Marítima
	p.build_water(0.25)
	p.soil(Rect2i(48, 0, 2, 48))

	# Triana: la calle Mayor (x 14-15), casas modernistas, el Parque de San Telmo y los locales.
	for b: Array in [[&"casa_teja", Vector2i(2, 9)], [&"casa_tejado_azul", Vector2i(8, 8)], [&"edificio_cupula", Vector2i(17, 9)],
			[&"casa_teja", Vector2i(23, 9)], [&"centro_pokemon", Vector2i(2, 20)], [&"tienda_morada", Vector2i(9, 20)],
			[&"casa_tejado_azul_2", Vector2i(17, 20)], [&"casa_madera", Vector2i(23, 20)]]:
		p.object(b[0], b[1])
	p.object(&"fuente_cano", Vector2i(36, 9))            # el quiosco del Parque de San Telmo
	for cell: Vector2i in [Vector2i(30, 8), Vector2i(41, 8), Vector2i(30, 16), Vector2i(41, 16)]:
		p.object(&"palmera", cell)
	p.object(&"banco", Vector2i(34, 15))
	# Vegueta: la Catedral de Santa Ana con sus perros de bronce, la Casa de Colón y el mercado.
	p.object(&"catedral_santa_ana", Vector2i(18, 38))
	for cell: Vector2i in [Vector2i(16, 41), Vector2i(25, 41)]:
		p.object(&"busto", cell)                         # los perros de Santa Ana
	p.object(&"casa_madera", Vector2i(30, 38))           # Casa de Colón
	p.object(&"casa_granero", Vector2i(35, 38))
	p.object(&"puesto_mercado", Vector2i(40, 38))        # Mercado de Vegueta
	for b: Array in [[&"casa_madera", Vector2i(2, 36)], [&"casa_granero", Vector2i(7, 36)], [&"casa_madera", Vector2i(2, 47)],
			[&"casa_dos_aguas", Vector2i(36, 47)], [&"casa_madera", Vector2i(41, 47)]]:
		p.object(b[0], b[1])
	for cell: Vector2i in [Vector2i(46, 12), Vector2i(46, 26), Vector2i(46, 40)]:
		p.object(&"palmera", cell)

	# --- Carteles ---
	p.deco(Vector2i(27, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelCatedral", Vector2i(27, 39), PackedStringArray(["CATEDRAL DE SANTA ANA.",
		"Cuatro siglos de obras: gótica por dentro, neoclásica por fuera. Delante, ocho perros de bronce.",
		"Son los presa canarios que dieron nombre a las islas. O eso dicen los perros."]))
	p.deco(Vector2i(29, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelColon", Vector2i(29, 39), PackedStringArray(["CASA DE COLÓN.",
		"Colón paró aquí en tres de sus cuatro viajes. A reparar la Pinta y a por papas arrugadas."]))
	p.deco(Vector2i(13, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelTriana", Vector2i(13, 11), PackedStringArray(["CALLE MAYOR DE TRIANA.",
		"Casas modernistas, tiendas y la calle peatonal más comercial de la isla. Y el tabaco, más barato."]))
	p.deco(Vector2i(33, 10), ExteriorTiles.SIGN)
	p.sign_text("CartelSanTelmo", Vector2i(33, 10), PackedStringArray(["PARQUE DE SAN TELMO.",
		"Aquí paran las guaguas a todo el sur de la isla. La de Playa del Inglés sale cuando sale."]))
	p.deco(Vector2i(19, 46), ExteriorTiles.SIGN)
	p.sign_text("CartelSur", Vector2i(19, 46), PackedStringArray(["↓ Ruta 15 · Costa de Gran Canaria y Playa del Inglés.",
		"Allí canta Quevedo: GIMNASIO POKÉMON DE LAS PALMAS."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(24, 1))
	p.spawn("from_canteras", Vector2i(24, 0))
	p.spawn("from_ruta_15", Vector2i(26, 47))
	p.trainer("Echedey", &"lp_guaguero", Vector2i(33, 18), LEFT, 3)
	p.trainer("Ingrid", &"lp_turista", Vector2i(12, 40), RIGHT, 3)
	p.npc("Vendedora", "npc_woman", Vector2i(42, 39), DOWN, PackedStringArray([
		"¡Papas arrugadas con mojo, mi niño! El mojo picón pica. El verde, también, pero disimula."]))
	p.npc("Abuelo", "npc_old_man", Vector2i(21, 41), DOWN, PackedStringArray([
		"En Vegueta se fundó la ciudad en 1478. Desde entonces, lo único que no ha cambiado es la cola del Mercado."]))
	return p
