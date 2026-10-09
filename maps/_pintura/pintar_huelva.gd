extends SceneTree
## Pinta Huelva (maps/huelva/exterior.tscn) con el plano real docs/mundo/planos/huelva.svg (norte arriba):
## la ciudad sobre la ría, con la Casa Colón, la iglesia de la Merced, el Barrio Obrero de casas inglesas
## de la compañía de Riotinto y los locales; al sur, la ría del Odiel y el Tinto con el Muelle del Tinto
## (el embarcadero de mineral de hierro), el cartel de las carabelas de Colón y el puerto con el ferry a
## Canarias; al suroeste, la Punta del Sebo con el Monumento a la Fe Descubridora. Se une sin fundido con
## la Ruta 14 (este); el ferry lleva a Las Palmas · Las Canteras.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_huelva.gd -- --force

const OUT := "res://maps/huelva/exterior.tscn"
const SIZE := Vector2i(64, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_huelva: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"huelva/exterior"
	data.display_name = "Huelva"
	data.zone_id = &"huelva"
	data.encounter_table = &"huelva"
	data.region_map_position = Vector2i(6, 20)
	var p: RefCounted = painter.new("Huelva", SIZE, data, 1492)
	p.fill_grass(0.2)
	p.connect_edge("east", &"ruta_14/exterior", 0, Vector2i(16, 28))

	# La ciudad, pavimentada, y el pantalán del ferry; la ría alrededor.
	p.paving(Rect2i(14, 0, 50, 34))
	p.paving(Rect2i(52, 34, 2, 7))
	p.build_paving()
	p.water(Rect2i(0, 0, 12, 28))
	p.water(Rect2i(0, 28, 4, 20))
	p.water(Rect2i(14, 34, 11, 14))
	p.water(Rect2i(27, 34, 25, 14))
	p.water(Rect2i(54, 34, 10, 14))
	p.water(Rect2i(4, 42, 10, 6))
	p.build_water(0.25)
	# El Muelle del Tinto entra en la ría (debajo, un pasillo de tierra para andar por el tablero).
	p.terrain(Pintor.cells(Rect2i(25, 34, 2, 8)), ExteriorTiles.TERRAIN_PATH)
	p.object_under(&"muelle_tinto", Vector2i(24, 41))

	# La Punta del Sebo con el Monumento a la Fe Descubridora.
	p.object(&"fe_descubridora", Vector2i(7, 40))
	p.flowers(Rect2i(5, 36, 2, 2), 0.3)
	# El ferry a Canarias.
	p.object(&"ferry", Vector2i(46, 47))

	# La ciudad: Casa Colón, la Merced, el Barrio Obrero y los locales.
	p.object(&"palacio_infantado", Vector2i(16, 12))     # Casa Colón
	p.object(&"catedral_ibiza", Vector2i(28, 12))        # iglesia de la Merced
	for x: int in [36, 42, 48, 54]:
		p.object(&"casa_roja_chimenea", Vector2i(x, 9))  # Barrio Obrero (Reina Victoria)
	p.fence(36, 58, 11)
	p.object(&"centro_pokemon", Vector2i(16, 26))
	p.object(&"tienda_verde", Vector2i(24, 26))          # Mercadona
	p.object(&"tienda_morada", Vector2i(30, 26))         # Estanco
	p.object(&"tienda_naranja", Vector2i(36, 27))        # Basic-Fit
	p.object(&"bloque_pisos", Vector2i(44, 31))
	for cell: Vector2i in [Vector2i(14, 33), Vector2i(41, 18), Vector2i(58, 18), Vector2i(22, 18)]:
		p.object(&"palmera", cell)

	# --- Carteles ---
	p.deco(Vector2i(29, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelTinto", Vector2i(29, 33), PackedStringArray(["MUELLE DEL TINTO (1876).",
		"Por aquí salía el mineral de Riotinto hacia Inglaterra. Los ingleses se llevaron el mineral y nos dejaron el fútbol."]))
	p.deco(Vector2i(10, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelColon", Vector2i(10, 39), PackedStringArray(["MONUMENTO A LA FE DESCUBRIDORA · PUNTA DEL SEBO.",
		"Colón mira a América. Bueno, mira a Mazagón, que está más cerca."]))
	p.deco(Vector2i(36, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelCarabelas", Vector2i(36, 33), PackedStringArray(["MUELLE DE LAS CARABELAS, enfrente, en Palos.",
		"Réplicas de la Niña, la Pinta y la Santa María. Salieron en 1492; hoy se alquilan para bodas."]))
	p.deco(Vector2i(54, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(54, 33), PackedStringArray(["FERRY · Huelva → Las Palmas de Gran Canaria.",
		"Treinta y tantas horas de travesía. La pasarela está al final del pantalán."]))
	p.deco(Vector2i(35, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelObrero", Vector2i(35, 12), PackedStringArray(["BARRIO OBRERO (REINA VICTORIA).",
		"Casas inglesas de la compañía de Riotinto. Té a las cinco no hay: hay choco frito."]))
	p.deco(Vector2i(62, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(62, 15), PackedStringArray(["HUELVA · CUNA DEL DESCUBRIMIENTO.",
		"Aquí se fundó el Recreativo, el club de fútbol más antiguo de España. → Ruta 14 · Doñana."]))

	# --- Apariciones, ferry, entrenadores y vecinos ---
	p.spawn("default", Vector2i(62, 21))
	p.spawn("from_ruta_14", Vector2i(63, 21))
	p.spawn("from_ferry", Vector2i(52, 39))
	p.warp("FerryCanarias", Vector2i(53, 40), &"las_palmas/canteras", &"from_ferry", &"")
	p.trainer("Juanma", &"huelva_marinero", Vector2i(52, 22), LEFT, 3)
	p.trainer("Lucia", &"huelva_regatista", Vector2i(20, 32), RIGHT, 3)
	p.npc("Choquero", "npc_fisherman", Vector2i(26, 31), DOWN, PackedStringArray([
		"En Huelva nos llaman choqueros por los chocos. Y gamba blanca, la mejor del mundo. Lo dice todo el mundo... de Huelva."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(46, 14), DOWN, PackedStringArray([
		"Mi abuelo trabajaba en las minas de Riotinto. Los ingleses le enseñaron a jugar al fútbol y a no cobrar las horas extra."]))
	return p
