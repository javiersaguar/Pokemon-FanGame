extends SceneTree
## Pinta Madrid · Palacio Real (maps/madrid/palacio_real.tscn), donde está la LIGA POKÉMON (decisión de
## Javier), con el plano real docs/mundo/planos/madrid_palacio_real.svg (norte arriba): los Jardines
## de Sabatini al norte; el Palacio Real con su fachada sur a la Plaza de la Armería, cerrada por la
## verja; la Catedral de la Almudena al sur; el Campo del Moro y el Mirador de la Cornisa al oeste;
## la calle de Bailén y la Plaza de Oriente (Felipe IV a caballo, las estatuas de los reyes y el
## Teatro Real) al este, y la calle del Arenal, que sale por el este hacia Sol.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_palacio_real.gd -- --force

const OUT := "res://maps/madrid/palacio_real.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_palacio_real: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"madrid/palacio_real"
	data.display_name = "Madrid · Palacio Real"
	data.zone_id = &"madrid"
	data.encounter_table = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridPalacioReal", SIZE, data, 1764)
	p.fill_grass(0.15)
	p.connect_edge("east", &"madrid/centro", -14, Vector2i(38, 48))

	# --- Baldosas: Plaza de la Armería, la explanada de la Almudena, Bailén, Plaza de Oriente y Arenal ---
	for r: Rect2i in [Rect2i(10, 31, 28, 24), Rect2i(36, 0, 4, 56), Rect2i(40, 38, 24, 10), Rect2i(2, 42, 8, 8),
			Rect2i(40, 14, 16, 4), Rect2i(40, 34, 16, 4), Rect2i(52, 18, 4, 16), Rect2i(40, 18, 4, 16)]:
		p.paving(r)
	p.build_paving()

	# Campo del Moro: senda, hierba alta y bosque en la cuesta hacia el Manzanares.
	p.terrain(rects([Rect2i(5, 18, 2, 24)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(2, 20, 3, 8), Rect2i(7, 30, 3, 8)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	for r: Rect2i in [Rect2i(0, 0, 4, 16), Rect2i(0, 16, 2, 26), Rect2i(0, 50, 10, 6), Rect2i(8, 0, 2, 16)]:
		p.forest(r)
	p.build_forest()

	# Jardines de Sabatini: setos en hileras y las fuentes gemelas.
	for y: int in [3, 7, 11]:
		p.hedge(12, 20, y)
		p.hedge(26, 34, y)
	p.object(&"fuente_plaza", Vector2i(21, 9))
	p.object(&"fuente_plaza", Vector2i(21, 15))
	for cell: Vector2i in [Vector2i(11, 16), Vector2i(31, 16), Vector2i(4, 16)]:
		p.object(&"arbol_redondo", cell)

	# El Palacio, la verja de la Plaza de la Armería (con la puerta abierta) y la Almudena.
	p.object(&"palacio_real", Vector2i(14, 30))
	for x: int in range(10, 38):
		if x < 22 or x > 25:
			p.object(&"verja", Vector2i(x, 41))
	p.object(&"catedral_almudena", Vector2i(19, 54))

	# Plaza de Oriente: Felipe IV a caballo en el centro, los reyes alrededor, jardines y el Teatro Real.
	p.object(&"felipe_iv", Vector2i(47, 30))
	for x: int in [44, 46, 48, 50]:
		p.object(&"estatua_rey", Vector2i(x, 21))
		p.object(&"estatua_rey", Vector2i(x, 33))
	p.flowers(Rect2i(44, 26, 3, 2), 0.3)
	p.flowers(Rect2i(50, 26, 2, 2), 0.3)
	p.object(&"teatro_real", Vector2i(56, 25))
	p.object(&"bloque_pisos", Vector2i(44, 11))     # Real Monasterio de la Encarnación (provisional)
	p.object(&"oficinas_azules", Vector2i(52, 11))  # el Senado
	for cell: Vector2i in [Vector2i(57, 33), Vector2i(61, 33), Vector2i(41, 12), Vector2i(60, 12),
			Vector2i(44, 52), Vector2i(52, 52), Vector2i(60, 52)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(12, 33), Vector2i(34, 33), Vector2i(41, 41), Vector2i(57, 41)]:
		p.object(&"farola_verde", cell)
	# Mirador de la Cornisa, sobre la Casa de Campo.
	p.object(&"banco", Vector2i(3, 45))
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.04, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(20, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelPalacio", Vector2i(20, 32), PackedStringArray(["PALACIO REAL DE MADRID.",
		"3418 habitaciones. Aquí está la LIGA POKÉMON.",
		"Solo pasan los entrenadores con las ocho medallas que llegan por la Calle de la Victoria."]))
	p.deco(Vector2i(29, 43), ExteriorTiles.SIGN)
	p.sign_text("CartelAlmudena", Vector2i(29, 43), PackedStringArray(["CATEDRAL DE LA ALMUDENA.",
		"Se empezó en 1883 y se terminó en 1993. Ciento diez años: casi lo que tarda una obra del Ministerio."]))
	p.deco(Vector2i(8, 43), ExteriorTiles.SIGN)
	p.sign_text("CartelCornisa", Vector2i(8, 43), PackedStringArray(["MIRADOR DE LA CORNISA.",
		"Abajo, el Campo del Moro y la Casa de Campo. Al fondo, la sierra."]))
	p.deco(Vector2i(51, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelOriente", Vector2i(51, 29), PackedStringArray(["PLAZA DE ORIENTE.",
		"Felipe IV a caballo. Galileo ayudó a calcular cómo se sostiene el caballo encabritado."]))
	p.deco(Vector2i(55, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelTeatro", Vector2i(55, 25), PackedStringArray(["TEATRO REAL. Hoy: «Carmen».",
		"Entradas agotadas desde 1850."]))

	# --- Apariciones y vecinos ---
	p.spawn("default", Vector2i(62, 42))
	p.spawn("from_centro", Vector2i(63, 42))
	p.npc("Guardia1", "npc_man", Vector2i(21, 31), DOWN, PackedStringArray([
		"Guardia Real. Al Palacio solo entran los que llegan por la Calle de la Victoria.",
		"Con las ocho medallas. Y con corbata."]))
	p.npc("Guardia2", "npc_man", Vector2i(26, 31), DOWN, PackedStringArray([
		"El Alto Mando os espera dentro: Iniesta, Nadal, Gasol y Alonso.",
		"Y al final, el Líder Supremo. Dicen que llega en Falcon a la Plaza de la Armería."]))
	p.npc("Turista", "turistachanclas_f", Vector2i(30, 37), UP, PackedStringArray([
		"¿El rey vive aquí? ¿No? ¿Y entonces quién paga la luz de 3418 habitaciones?"]))
	p.npc("Pintor", "npc_old_man", Vector2i(7, 45), LEFT, PackedStringArray([
		"Pinto el atardecer desde la Cornisa. Velázquez lo hacía mejor, pero cobraba más."]))
	return p
