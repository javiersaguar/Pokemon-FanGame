extends SceneTree
## Pinta Barcelona · Ciutat Vella (maps/barcelona/ciutat_vella.tscn) con el plano real
## docs/mundo/planos/barcelona_centro.svg (norte arriba): La Rambla baja de la Plaça de Catalunya
## (unida sin fundido con el Eixample) entre plátanos hasta el Monumento a Colón; al oeste, el Raval
## con la Boqueria, el Liceu y el estanco; al este, el Barri Gòtic con la Catedral y la Plaça Reial; al
## sur, el Port Vell con la terminal y el FERRY A PALMA; al este, la playa de la Barceloneta con el
## Centro Pokémon. El mar (con Surf y caña) rodea el puerto y la playa.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_barcelona_ciutat_vella.gd -- --force

const OUT := "res://maps/barcelona/ciutat_vella.tscn"
const SIZE := Vector2i(72, 60)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_barcelona_ciutat_vella: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"barcelona/ciutat_vella"
	data.display_name = "Barcelona · Ciutat Vella"
	data.zone_id = &"barcelona"
	data.encounter_table = &"barcelona"
	data.region_map_position = Vector2i(28, 8)
	var p: RefCounted = painter.new("BarcelonaCiutatVella", SIZE, data, 1493)
	p.fill_grass(0.1)
	p.connect_edge("north", &"barcelona/eixample", 0, Vector2i(26, 38))

	p.paving(Rect2i(0, 0, 54, 52))
	p.build_paving()
	p.soil(Rect2i(54, 2, 6, 50))                 # la playa de la Barceloneta
	p.water(Rect2i(60, 0, 12, 52))               # el Mediterráneo
	p.water(Rect2i(0, 52, 72, 8))                # el Port Vell
	p.build_water(0.3)

	for b: Array in [
		# El Raval, al oeste de La Rambla.
		[&"bloque_pisos", Vector2i(3, 13)], [&"oficinas_azules", Vector2i(10, 13)], [&"boqueria", Vector2i(19, 13)],
		[&"bloque_pisos", Vector2i(3, 27)], [&"bloque_verde_2", Vector2i(10, 26)], [&"teatro", Vector2i(21, 27)],
		[&"bloque_pisos", Vector2i(3, 40)], [&"tienda_morada", Vector2i(22, 40)],
		[&"oficinas_azules", Vector2i(4, 49)],       # Estació Marítima (terminal de ferris)
		# El Barri Gòtic, al este.
		[&"catedral_barcelona", Vector2i(40, 22)], [&"bloque_verde_2", Vector2i(44, 6)],
		[&"soportales", Vector2i(37, 35)], [&"soportales", Vector2i(41, 35)], [&"soportales", Vector2i(45, 35)],
		[&"centro_pokemon", Vector2i(47, 49)],       # Centro Pokémon de la Barceloneta
	]:
		p.object(b[0], b[1])
	p.object(&"monumento_colon", Vector2i(31, 51))
	p.object(&"ferry", Vector2i(6, 59))
	p.object(&"torre_socorrista", Vector2i(56, 28))
	p.object(&"sombrilla", Vector2i(55, 12))
	p.object(&"sombrilla", Vector2i(55, 42))
	# Los plátanos de La Rambla, la fuente de la Plaça Reial y farolas.
	for y: int in [4, 10, 16, 22, 28, 34]:
		p.object(&"arbol_redondo", Vector2i(28, y))
		p.object(&"arbol_redondo", Vector2i(34, y))
	p.object(&"fuente_plaza", Vector2i(41, 40))
	for cell: Vector2i in [Vector2i(26, 46), Vector2i(36, 46), Vector2i(52, 30)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(27, 14), ExteriorTiles.SIGN)
	p.sign_text("CartelBoqueria", Vector2i(27, 14), PackedStringArray(["MERCAT DE LA BOQUERIA.",
		"Zumos de fruta a 5 euros y jamón para turistas. Los de aquí compran en el de su barrio."]))
	p.deco(Vector2i(39, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelCatedral", Vector2i(39, 23), PackedStringArray(["CATEDRAL DE BARCELONA.",
		"En el claustro viven trece ocas blancas, una por cada año de Santa Eulalia."]))
	p.deco(Vector2i(30, 50), ExteriorTiles.SIGN)
	p.sign_text("CartelColon", Vector2i(30, 50), PackedStringArray(["MONUMENTO A COLÓN (1888).",
		"Señala al mar... hacia el sur. América está al oeste. Detalles."]))
	p.deco(Vector2i(12, 50), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(12, 50), PackedStringArray(["TERMINAL DE FERRIS.",
		"Barcelona → Palma de Mallorca. Diario. Ocho horas de travesía y un mareo de regalo."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(31, 1))
	p.spawn("from_eixample", Vector2i(31, 0))
	p.trainer("Nando", &"bcn_carterista", Vector2i(31, 20), DOWN, 4)
	p.trainer("Sophie", &"bcn_banyista", Vector2i(57, 34), LEFT, 2)
	p.npc("Estatua", "npc_man", Vector2i(32, 8), DOWN, PackedStringArray([
		"(La estatua humana no se mueve.)",
		"...¿Una monedita? ¡Pues sigo sin moverme!"]))
	p.npc("Taquilla", "npc_lass", Vector2i(13, 51), DOWN, PackedStringArray([
		"Ferry a Palma de Mallorca. La pasarela está a tu derecha.",
		"Ocho horas de travesía. Trae biodramina."]))
	p.spawn("from_ferry", Vector2i(14, 50))
	p.warp("FerryPalma", Vector2i(14, 51), &"palma/exterior", &"from_ferry", &"")
	return p
