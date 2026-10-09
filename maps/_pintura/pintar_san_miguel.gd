extends SceneTree
## Pinta San Miguel de Bernuy, el pueblo inicial (maps/pueblo_inicial/exterior.tscn), siguiendo el
## plano real de OpenStreetMap (docs/mundo/planos/san_miguel_de_bernuy.svg) y su ficha
## (docs/mundo/ciudades/san_miguel_de_bernuy.md): el embalse de las Vencías al norte, el río Duratón
## por el oeste, la iglesia de San Miguel Arcángel arriba con el cementerio al lado, la Plaza de
## España con el Ayuntamiento, la calle Real hacia el sur, la ermita de la Virgen del Río, el
## embarcadero de las canoas, las choperas de la ribera y los pinares de la Tierra de Pinares.
## Escala: una casilla ≈ 12 m (el casco real mide unos 300 × 450 m).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_san_miguel.gd -- --force

const OUT := "res://maps/pueblo_inicial/exterior.tscn"
const SIZE := Vector2i(44, 50)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_san_miguel: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"pueblo_inicial/exterior"
	data.display_name = "San Miguel de Bernuy"
	data.zone_id = &"pueblo_inicial"
	data.region_map_position = Vector2i(13, 8)
	var p: RefCounted = painter.new("SanMiguelDeBernuy", SIZE, data, 1975)
	p.fill_grass(0.18)
	p.connect_edge("west", &"ruta_23/exterior", -13, Vector2i(31, 35))
	p.spawn("from_ruta_23", Vector2i(0, 32))
	p.connect_edge("south", &"ruta_1/exterior")  # la calle Real sigue en la Ruta 1, mismas columnas

	# Agua: la cola del embalse de las Vencías (norte) y el río Duratón (oeste), que entra en él.
	p.water(Rect2i(0, 0, 22, 8))
	p.water(Rect2i(4, 8, 6, 23))
	p.water(Rect2i(4, 35, 6, 15))

	# Pinares de la Tierra de Pinares al norte y al este, con el hueco de la carretera de Fuentidueña.
	p.forest(Rect2i(34, 0, 10, 8))
	p.forest(Rect2i(42, 8, 2, 22))
	p.forest(Rect2i(42, 34, 2, 16))

	# Calles: la de la iglesia, la Plaza de España, la calle Real (al sur), la calle de la Fuente
	# (al este de la plaza) y la calle que cruza del río a la carretera de Fuentidueña (este).
	p.paving(Rect2i(18, 15, 3, 1))
	p.paving(Rect2i(23, 15, 4, 1))
	p.paving(Rect2i(15, 16, 14, 7))
	p.paving(Rect2i(20, 23, 3, 27))
	p.paving(Rect2i(23, 23, 19, 1))
	p.paving(Rect2i(0, 31, 44, 4))
	p.build_paving()

	# Edificios (casilla de abajo a la izquierda). Las casas son todas de DPPt (pack 02), como el
	# suelo (respuesta 17 de Javier); la iglesia y la ermita están dibujadas a mano
	# (assets/_fuentes/mundo/*.px2). Las puertas miran al sur, a una calle o a un camino.
	var buildings := [
		[&"iglesia_san_miguel", Vector2i(16, 14)],
		[&"casa_naranja", Vector2i(23, 15)],          # Ayuntamiento
		[&"casa_granero", Vector2i(27, 15)],
		[&"casa_roja_chimenea", Vector2i(35, 15)],
		[&"edificio_cupula", Vector2i(29, 22)],       # el bar de la plaza
		[&"casa_madera", Vector2i(37, 22)],
		[&"casa_roja", Vector2i(11, 30)],             # casa del jugador
		[&"casa_azul_pequena", Vector2i(24, 30)],     # casa del rival
		[&"casa_dos_aguas", Vector2i(30, 30)],
		[&"casa_granero", Vector2i(35, 30)],
		[&"casa_madera", Vector2i(24, 40)],           # consultorio (el médico viene los martes)
		[&"casa_dos_aguas", Vector2i(29, 40)],
		[&"casa_roja_chimenea", Vector2i(35, 40)],    # casa de Javier
		[&"casa_tejado_rojo", Vector2i(11, 47)],      # Molino Grande del Duratón (laboratorio)
		[&"ermita_virgen_del_rio", Vector2i(25, 48)],
	]
	for b: Array in buildings:
		p.object(b[0], b[1])

	# Caminos de tierra de las puertas a las calles, el de las eras y el del embarcadero.
	var dirt: Array[Vector2i] = []
	for y: int in range(29, 31):
		dirt.append(Vector2i(12, y))      # casa del jugador
	for y: int in range(16, 23):
		dirt.append(Vector2i(36, y))      # casa de la calle de la Fuente
	for x: int in range(23, 41):
		dirt.append(Vector2i(x, 41))      # camino de las eras
	for y: int in range(47, 49):
		dirt.append(Vector2i(13, y))      # Molino (laboratorio)
	for x: int in range(14, 20):
		dirt.append(Vector2i(x, 48))
	for x: int in range(23, 27):
		dirt.append(Vector2i(x, 49))      # ermita
	for y: int in range(34, 37):
		dirt.append(Vector2i(10, y))      # embarcadero
	p.terrain(dirt, ExteriorTiles.TERRAIN_PATH)

	p.build_water()
	# Paso occidental de Ruta 23: mismo puente de piedra, orientación horizontal.
	var bridge: Dictionary = ExteriorTiles.objects()[&"puente_piedra"]
	p.decor.set_cell(Vector2i(10, 31), bridge.source, bridge.coords, TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	p.build_forest()

	# Plaza de España: el caño de agua potable en el centro, un banco y farolas.
	p.object(&"fuente_cano", Vector2i(21, 18))
	p.object(&"banco", Vector2i(16, 22))
	for cell: Vector2i in [Vector2i(15, 18), Vector2i(27, 18), Vector2i(27, 22)]:
		p.object(&"farola_verde", cell)
	p.object(&"farola_verde_2", Vector2i(23, 34))
	p.object(&"farola_verde_2", Vector2i(18, 34))

	# Cementerio junto a la iglesia, cercado.
	p.fence(11, 15, 9)
	p.fence(11, 15, 14)
	p.flowers(Rect2i(12, 10, 3, 3), 0.9)

	# Chopos de la ribera (las choperas del Duratón), en las dos orillas, y árboles del pueblo.
	for y: int in range(12, 50, 4):
		if y in [32, 36]:
			continue  # acceso al puente; las demás choperas se conservan
		p.object(&"arbol_verde", Vector2i(0, y))
		p.object(&"arbol_verde", Vector2i(2, y + 2))
	for y: int in [20, 40]:
		p.object(&"arbol_verde", Vector2i(10, y))
	p.object(&"manzano", Vector2i(12, 22))
	p.object(&"arbol_redondo", Vector2i(34, 22))
	p.object(&"arbol_redondo", Vector2i(39, 30))
	p.object(&"arbol_redondo", Vector2i(40, 40))
	p.object(&"arbol_redondo", Vector2i(18, 43))
	p.object(&"arbustos", Vector2i(32, 15))
	p.object(&"pino", Vector2i(31, 49))

	# Ruinas románicas río abajo: Los Sampedros y Las Ermitonas (piedras sueltas).
	for cell: Vector2i in [Vector2i(23, 3), Vector2i(24, 2), Vector2i(26, 3), Vector2i(28, 5), Vector2i(29, 4),
			Vector2i(31, 5)]:
		p.deco(cell, ExteriorTiles.ROCK if (cell.x + cell.y) % 2 == 0 else ExteriorTiles.ROCK_BROWN)

	# Huertos junto al río, eras al sureste y flores.
	p.soil(Rect2i(12, 35, 5, 3))
	p.soil(Rect2i(34, 44, 6, 4))
	p.flowers(Rect2i(14, 23, 1, 1), 0.3)
	p.flowers(Rect2i(26, 24, 2, 1), 0.5)
	p.flowers(Rect2i(34, 17, 2, 1), 0.6)
	p.flowers(Rect2i(24, 42, 3, 1), 0.4)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# Carteles.
	p.deco(Vector2i(19, 46), ExteriorTiles.ROUTE_SIGN[0])
	p.deco(Vector2i(19, 47), ExteriorTiles.ROUTE_SIGN[1])
	p.sign_text("CartelPueblo", Vector2i(19, 47), PackedStringArray(["SAN MIGUEL DE BERNUY", "Tierra de Fuentidueña · 840 m de altitud."]))
	p.sign_text("CartelIglesia", Vector2i(21, 15), PackedStringArray(["Iglesia de San Miguel Arcángel.", "Siglo XIII, románica. Retablo mayor del siglo XVIII."]))
	p.sign_text("CartelEmbalse", Vector2i(21, 8), PackedStringArray(["Embalse de las Vencías.", "Aquí empiezan las Hoces del Duratón."]))
	p.sign_text("CartelRuinas", Vector2i(27, 6), PackedStringArray(["Los Sampedros y Las Ermitonas.", "Ruinas de ermitas románicas."]))
	p.sign_text("CartelCanoas", Vector2i(11, 34), PackedStringArray(["ALQUILER DE CANOAS", "Baja el Duratón entre las Hoces."]))
	p.sign_text("CartelCarretera", Vector2i(41, 30), PackedStringArray(["Carretera de Fuentidueña.", "Cortada por obras (desde 2019)."]))

	# Apariciones (las puertas y las salidas las usan los warps y el guion del MVP).
	p.spawn("default", Vector2i(21, 20))
	p.spawn("from_home", Vector2i(12, 29))
	p.spawn("from_rival_home", Vector2i(25, 30))
	p.spawn("from_lab", Vector2i(13, 47))
	p.spawn("from_route", Vector2i(21, 48))

	# Vecinos.
	p.npc("Jubilado1", "npc_old_man", Vector2i(25, 20), LEFT, PackedStringArray([
		"Aquí éramos quinientos. Ahora somos ciento cincuenta y el médico viene los martes."]))
	p.npc("Jubilado2", "npc_old_man", Vector2i(24, 20), RIGHT, PackedStringArray([
		"¿Mus? Venga, que el de enfrente se ha ido a Madrid y no vuelve."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(17, 19), DOWN, PackedStringArray([
		"Para el Mercadona hay que ir a Cuéllar. Y el autobús pasa un día a la semana."]))
	p.npc("Piraguista", "npc_fisherman", Vector2i(10, 35), RIGHT, PackedStringArray([
		"Desde aquí se baja en canoa hasta las Hoces. Con Surf, algún día, hasta Madrid."]))
	p.npc("Nino", "npc_boy", Vector2i(22, 27), LEFT, PackedStringArray([
		"¡En las fiestas de la Virgen del Río hay orquesta y peñas!"]))
	p.npc("Javier", "npc_man", Vector2i(37, 41), DOWN, PackedStringArray([
		"Soy Javier Saguar. Este juego lo he hecho yo, y este es mi pueblo.",
		"Cuando tengas siete medallas, vuelve y combatimos."]))
	return p
