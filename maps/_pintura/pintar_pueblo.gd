extends SceneTree
## Pinta el pueblo de muestra (maps/muestras/pueblo.tscn) para la prueba de nivel
## gráfico (respuesta 17 de Javier: denso, saturado y coherente, en estilo DPPt,
## con calles, vallas, casas completas, árboles con volumen y sombras).
## Pide `-- --force` si el mapa ya existe, porque lo sobrescribe.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_pueblo.gd -- --force

const OUT := "res://maps/muestras/pueblo.tscn"
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_pueblo: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"muestras/pueblo"
	data.display_name = "Pueblo de muestra"
	var p: RefCounted = painter.new("PuebloMuestra", Vector2i(34, 30), data, 2026)
	p.fill_grass()

	# Bosque alrededor, con los huecos de las salidas al norte y al sur.
	for r: Rect2i in [Rect2i(0, 0, 14, 4), Rect2i(18, 0, 16, 4), Rect2i(0, 4, 4, 22), Rect2i(30, 4, 4, 22),
			Rect2i(0, 26, 14, 4), Rect2i(18, 26, 16, 4)]:
		p.forest(r)

	# Calles de baldosas: la que cruza de norte a sur y la mayor, de este a oeste.
	p.paving(Rect2i(14, 0, 3, 30))
	p.paving(Rect2i(4, 14, 26, 3))
	p.build_paving()

	# Caminos de tierra de las puertas a la calle.
	var houses := {&"casa_roja": Vector2i(4, 11), &"casa_azul": Vector2i(18, 11),
		&"casa_azul_pequena": Vector2i(25, 11), &"casa_tejado_rojo": Vector2i(22, 24)}
	var dirt: Array[Vector2i] = []
	for id: StringName in [&"casa_roja", &"casa_azul", &"casa_azul_pequena"]:
		var door: Vector2i = p.door_of(id, houses[id])
		for y: int in range(door.y + 1, 14):
			dirt.append(Vector2i(door.x, y))
	var lab_door: Vector2i = p.door_of(&"casa_tejado_rojo", houses[&"casa_tejado_rojo"])
	for y: int in range(17, 26):
		dirt.append(Vector2i(21, y))
	for x: int in range(22, lab_door.x + 1):
		dirt.append(Vector2i(x, 25))
	dirt.append(lab_door + Vector2i.DOWN)
	p.terrain(dirt, ExteriorTiles.TERRAIN_PATH)

	p.pond(Rect2i(5, 18, 5, 4), [Vector2i(6, 19), Vector2i(8, 20), Vector2i(7, 20)])
	p.build_forest()

	# Casas completas de DPPt.
	for id: StringName in houses:
		p.object(id, houses[id])

	# Vallas delante de las casas, con hueco en cada camino, y a lo largo de la
	# calle junto al estanque.
	p.fence(6, 12, 13)
	p.fence(20, 25, 13)
	p.fence(27, 29, 13)
	p.fence(4, 9, 17)

	# Árboles con volumen.
	p.object(&"arbol_redondo", Vector2i(11, 7))
	p.object(&"arbustos", Vector2i(11, 10))
	p.object(&"cerezo_grande", Vector2i(10, 24))
	p.object(&"arbol_redondo", Vector2i(4, 25))
	p.object(&"manzano", Vector2i(18, 20))
	p.object(&"arbol_redondo", Vector2i(18, 25))
	p.object(&"arbol_doble", Vector2i(27, 4))
	p.object(&"arbustos", Vector2i(5, 4))

	# Flores animadas, tulipanes y adornos.
	p.flowers(Rect2i(11, 11, 2, 2), 0.4)
	# Flores en los jardines, detrás de las vallas.
	for r: Rect2i in [Rect2i(9, 12, 3, 1), Rect2i(6, 12, 2, 1), Rect2i(20, 12, 6, 1), Rect2i(27, 12, 3, 1)]:
		p.flowers(r, 0.45)
	p.flowers(Rect2i(10, 18, 3, 2), 0.3)
	p.flowers(Rect2i(6, 23, 4, 1))
	p.flowers(Rect2i(4, 18, 1, 4), 0.5)
	p.flowers(Rect2i(18, 21, 3, 1), 0.5)
	p.flowers(Rect2i(17, 22, 1, 3), 0.3)
	p.flowers(Rect2i(26, 17, 3, 1), 0.4)
	p.flowers(Rect2i(25, 25, 4, 1), 0.3)
	p.flowers(Rect2i(19, 4, 6, 1), 0.6)
	for i: int in 4:
		p.tall_flower(Vector2i(6 + i, 25), Vector2i(i % 3, 6 + 2 * (i / 3)))
	p.deco(Vector2i(13, 11), ExteriorTiles.ROUTE_SIGN[0])
	p.deco(Vector2i(13, 12), ExteriorTiles.ROUTE_SIGN[1])
	p.sprinkle(Rect2i(0, 0, 34, 30), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# Vecinos y un Pokémon shiny que acompaña al abuelo (solo en la muestra).
	p.sign_text("Cartel", Vector2i(13, 12), PackedStringArray(["PUEBLO DE MUESTRA"]))
	p.spawn("default", Vector2i(16, 15))
	p.npc("Vecina", "npc_kimono_girl", Vector2i(10, 17), LEFT, PackedStringArray(["¡Qué bonito está el estanque!"]))
	p.npc("Abuelo", "npc_old_man", Vector2i(24, 15), LEFT, PackedStringArray(["Mi Furret es de un color muy raro."]))
	p.follower("FurretShiny", &"furret", true, "Abuelo", Vector2i(25, 15))
	p.npc("Nina", "npc_girl", Vector2i(20, 22), DOWN, PackedStringArray(["Me encantan las flores."]))
	p.npc("Nino", "npc_boy", Vector2i(8, 12), DOWN, PackedStringArray(["¡Esa casa es la del profesor!"]))
	return p
