extends SceneTree
## Monta los mapas de muestra de la prueba de nivel gráfico (DIRECTRICES §7):
## maps/test/muestra_ruta.tscn y maps/test/muestra_pueblo.tscn. Pide `-- --force`
## si ya existen, porque los sobrescribe (después se retocan en el editor).
## Uso: godot --headless --path . -s res://maps/_tools/build_muestras.gd -- --force

const ROUTE := "res://maps/test/muestra_ruta.tscn"
const TOWN := "res://maps/test/muestra_pueblo.tscn"
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	var force := "--force" in OS.get_cmdline_user_args()
	for path: String in [ROUTE, TOWN]:
		if FileAccess.file_exists(path) and not force:
			push_error("build_muestras: '%s' ya existe; usa -- --force para sobrescribirlo." % path)
			quit(1)
			return
	var builder: GDScript = load("res://maps/_tools/map_builder.gd")
	print("%s: %s" % [ROUTE, error_string(_route(builder).save(ROUTE))])
	print("%s: %s" % [TOWN, error_string(_town(builder).save(TOWN))])
	quit()


func _data(id: StringName, display_name: String, encounters: StringName = &"") -> MapData:
	var data := MapData.new()
	data.id = id
	data.display_name = display_name
	data.encounter_table = encounters
	return data


## Ruta: bosque de pinos alrededor, camino de tierra, hierba alta, estanque,
## meseta con escaleras, bordillo y árboles variados delante del bosque.
func _route(builder: GDScript) -> RefCounted:
	var m: RefCounted = builder.new("MuestraRuta", Vector2i(36, 30),
		_data(&"test/muestra_ruta", "Ruta de muestra", &"test_outdoor"), 7)
	m.fill_grass()
	for r: Rect2i in [Rect2i(0, 0, 6, 30), Rect2i(30, 0, 6, 30), Rect2i(6, 0, 8, 4), Rect2i(22, 0, 8, 4),
			Rect2i(6, 26, 6, 4), Rect2i(20, 26, 10, 4), Rect2i(6, 4, 4, 4), Rect2i(26, 22, 4, 4),
			Rect2i(28, 4, 2, 4)]:
		m.forest(r)
	var path: Array[Vector2i] = []
	for r: Rect2i in [Rect2i(14, 19, 3, 11), Rect2i(14, 17, 8, 3), Rect2i(19, 0, 3, 18)]:
		path.append_array(MapBuilder.cells(r))
	m.terrain(path, ExteriorTiles.TERRAIN_PATH)
	var grass: Array[Vector2i] = []
	for r: Rect2i in [Rect2i(7, 19, 6, 6), Rect2i(23, 5, 5, 5), Rect2i(10, 4, 4, 3)]:
		grass.append_array(MapBuilder.cells(r))
	m.terrain(grass, ExteriorTiles.TERRAIN_TALL_GRASS)
	m.pond(Rect2i(22, 18, 6, 4), [Vector2i(23, 19), Vector2i(26, 20), Vector2i(24, 20)])
	m.plateau(Rect2i(6, 9, 7, 7), [9])
	m.ledge(22, 29, 15)
	m.build_forest()
	m.object(&"arbol_redondo", Vector2i(7, 12))
	m.object(&"arbol_redondo", Vector2i(15, 7))
	m.object(&"arbol_verde", Vector2i(14, 14))
	m.object(&"pino", Vector2i(28, 14))
	m.object(&"arbol_doble", Vector2i(23, 13))
	m.object(&"arbustos", Vector2i(17, 25))
	m.object(&"manzano", Vector2i(7, 18))
	m.flowers(Rect2i(17, 21, 2, 3))
	m.flowers(Rect2i(10, 11, 2, 1), 0.6)
	m.flowers(Rect2i(15, 2, 3, 1))
	m.deco(Vector2i(13, 27), ExteriorTiles.SIGN)
	m.deco(Vector2i(17, 12), ExteriorTiles.ROCK)
	m.deco(Vector2i(21, 23), ExteriorTiles.STUMP)
	m.deco(Vector2i(10, 17), ExteriorTiles.LOG_LEFT[0])
	m.deco(Vector2i(11, 17), ExteriorTiles.LOG_LEFT[1])
	m.sprinkle(Rect2i(0, 0, 36, 30), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL,
		ExteriorTiles.WHITE_FLOWERS])
	m.sign("Cartel", Vector2i(13, 27), PackedStringArray(["RUTA DE MUESTRA\nPrueba de nivel gráfico."]))
	m.spawn("default", Vector2i(15, 28))
	m.npc("Entrenador", "trainer", Vector2i(18, 9), RIGHT, PackedStringArray(["¡Esta ruta tiene de todo!"]),
		{"display_name": "Entrenador"})
	m.npc("Chico", "npc_youngster", Vector2i(24, 17), DOWN,
		PackedStringArray(["Desde el bordillo se baja de un salto, pero no se puede subir."]),
		{"wander": true, "wander_radius": 2})
	m.npc("Pescador", "npc_fisherman", Vector2i(24, 23), UP, PackedStringArray(["Aquí pican poco..."]))
	m.item("Pocion", Vector2i(11, 12), &"potion")
	return m


## Pueblo: casas de HGSS, plaza de baldosas, caminos de adoquines, cerezos,
## setos, flores animadas, vecinos y un Pokémon shiny que acompaña a uno de ellos.
func _town(builder: GDScript) -> RefCounted:
	var m: RefCounted = builder.new("MuestraPueblo", Vector2i(34, 28),
		_data(&"test/muestra_pueblo", "Pueblo de muestra"), 11)
	m.fill_grass()
	for r: Rect2i in [Rect2i(0, 0, 14, 4), Rect2i(18, 0, 4, 4), Rect2i(30, 0, 4, 28), Rect2i(0, 4, 4, 24),
			Rect2i(4, 24, 10, 4), Rect2i(18, 24, 12, 4)]:
		m.forest(r)
	m.pattern(Rect2i(14, 0, 4, 28), ExteriorTiles.COBBLE_LIGHT, Vector2i(4, 2))
	m.pattern(Rect2i(4, 11, 26, 2), ExteriorTiles.COBBLE_LIGHT, Vector2i(4, 2))
	m.pattern(Rect2i(12, 9, 8, 6), ExteriorTiles.COBBLE_LIGHT, Vector2i(4, 2))
	m.nine_slice(Rect2i(12, 9, 8, 6), ExteriorTiles.PAVING, m.decor)
	m.build_forest()
	var small: Dictionary = m.object(&"casa_pequena", Vector2i(5, 10))
	m.object(&"casa_grande", Vector2i(21, 10))
	m.object(&"casa_escalera", Vector2i(21, 22))
	m.object(&"arbol_verde", Vector2i(23, 2))
	m.object(&"arbol_redondo", Vector2i(26, 2))
	m.object(&"cerezo", Vector2i(5, 18))
	m.object(&"manzano", Vector2i(9, 20))
	m.object(&"cerezo_grande", Vector2i(4, 23))
	m.object(&"cerezo", Vector2i(18, 22))
	m.hedge(4, 12, 14)
	m.flowers(Rect2i(8, 15, 3, 2))
	m.flowers(Rect2i(19, 15, 2, 4), 0.5)
	m.flowers(Rect2i(12, 4, 2, 2), 0.2)
	for i: int in 2:
		m.tall_flower(Vector2i(12 + i, 7), Vector2i(i, 6))
		m.tall_flower(Vector2i(18 + i, 7), Vector2i(i, 8))
	m.deco(Vector2i(13, 8), ExteriorTiles.ROUTE_SIGN[0])
	m.deco(Vector2i(13, 9), ExteriorTiles.ROUTE_SIGN[1])
	m.sprinkle(Rect2i(0, 0, 34, 28), 0.04, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])
	m.sign("Cartel", Vector2i(13, 9), PackedStringArray(["PUEBLO DE MUESTRA\nDonde empieza la prueba de nivel gráfico."]))
	if small["door"].x >= 0:
		m.warp("PuertaCasa", Vector2i(5, 10) + small["door"], &"test/test_room", &"default", 4)
	m.spawn("default", Vector2i(16, 13))
	m.npc("Vecina", "npc_kimono_girl", Vector2i(18, 13), LEFT, PackedStringArray(["¡Qué bonitos están los cerezos!"]),
		{"wander": true, "wander_radius": 2})
	m.npc("Abuelo", "npc_old_man", Vector2i(24, 13), LEFT,
		PackedStringArray(["Mi Furret es de un color muy raro. Dicen que es shiny."]))
	m.follower("FurretShiny", &"furret", true, "Abuelo", Vector2i(25, 13))
	m.npc("Nina", "npc_girl", Vector2i(12, 22), LEFT, PackedStringArray(["Me encantan las flores."]))
	m.npc("Nino", "npc_boy", Vector2i(29, 13), LEFT, PackedStringArray(["¡Esa casa tiene escalera!"]))
	m.item("Pocion", Vector2i(11, 22), &"potion")
	return m
