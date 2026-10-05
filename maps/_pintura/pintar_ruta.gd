extends SceneTree
## Pinta la ruta de muestra (maps/muestras/ruta.tscn) para la prueba de nivel
## gráfico (respuesta 17 de Javier: varios niveles de altura con acantilados y
## escaleras, caminos menos rectos, más variedad de zonas).
## Tres niveles: abajo (la entrada), el del medio (meseta grande) y arriba (meseta
## dentro de la meseta), unidos por escaleras.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta.gd -- --force

const OUT := "res://maps/muestras/ruta.tscn"
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"muestras/ruta"
	data.display_name = "Ruta de muestra"
	data.encounter_table = &"test_outdoor"
	var p: RefCounted = painter.new("RutaMuestra", Vector2i(40, 48), data, 1987)
	p.fill_grass()

	# Caminos de tierra, en L y en T, de la entrada (abajo) a la salida (arriba).
	p.terrain(rects([
		Rect2i(18, 34, 3, 14), Rect2i(14, 38, 5, 2),                      # nivel bajo
		Rect2i(18, 28, 3, 6), Rect2i(10, 28, 9, 3), Rect2i(10, 20, 3, 8),  # nivel medio
		Rect2i(13, 20, 12, 2), Rect2i(23, 20, 3, 2),
		Rect2i(23, 12, 3, 6), Rect2i(18, 10, 8, 3), Rect2i(18, 0, 3, 10),  # nivel alto
	]), ExteriorTiles.TERRAIN_PATH)

	# Hierba alta con formas distintas en cada nivel.
	p.terrain(rects([
		Rect2i(4, 36, 7, 5), Rect2i(6, 41, 4, 1), Rect2i(23, 39, 6, 4), Rect2i(25, 37, 3, 2),
		Rect2i(14, 23, 5, 4), Rect2i(27, 23, 7, 5), Rect2i(30, 28, 4, 2),
		Rect2i(11, 7, 6, 5), Rect2i(26, 3, 4, 6),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	p.pond(Rect2i(30, 35, 5, 4), [Vector2i(31, 36), Vector2i(33, 37)])
	p.pond(Rect2i(4, 23, 5, 4), [Vector2i(5, 24), Vector2i(7, 25), Vector2i(6, 25)])
	p.soil(Rect2i(20, 25, 4, 3))

	# Alturas: meseta grande (nivel medio) y otra dentro (nivel alto), con escaleras.
	p.plateau(Rect2i(2, -2, 36, 36), [19, 20])
	p.plateau(Rect2i(8, -2, 24, 22), [24, 25])
	# Una mesa de roca suelta en el nivel alto, con un árbol encima.
	p.plateau(Rect2i(27, 11, 4, 5))

	p.ledge(4, 12, 43)

	# Bosque de pinos: bordes y bosquetes que hacen pasillos.
	for r: Rect2i in [Rect2i(0, 0, 4, 48), Rect2i(36, 0, 4, 48), Rect2i(4, 0, 14, 4), Rect2i(22, 0, 14, 4),
			Rect2i(4, 44, 14, 4), Rect2i(22, 44, 14, 4), Rect2i(12, 34, 4, 4), Rect2i(32, 40, 4, 4),
			Rect2i(4, 28, 4, 4), Rect2i(4, 4, 4, 16), Rect2i(32, 4, 4, 16), Rect2i(22, 28, 4, 4)]:
		p.forest(r)
	p.build_forest()

	# Árboles sueltos con volumen y adornos.
	p.object(&"arbol_redondo", Vector2i(28, 15))
	p.object(&"arbol_verde", Vector2i(16, 43))
	p.object(&"manzano", Vector2i(29, 31))
	p.object(&"arbol_doble", Vector2i(10, 15))
	p.object(&"cerezo_grande", Vector2i(13, 18))
	p.object(&"arbol_verde", Vector2i(29, 9))
	p.object(&"arbol_redondo", Vector2i(26, 43))
	p.object(&"arbustos", Vector2i(5, 33))
	p.object(&"pino", Vector2i(9, 17))
	p.object(&"arbol_redondo", Vector2i(21, 17))
	p.object(&"arbustos", Vector2i(13, 4))
	p.flowers(Rect2i(21, 36, 2, 2), 0.3)
	p.flowers(Rect2i(9, 25, 2, 2), 0.5)
	p.flowers(Rect2i(16, 14, 3, 2), 0.3)
	p.flowers(Rect2i(26, 26, 1, 2), 0.2)
	p.deco(Vector2i(17, 45), ExteriorTiles.SIGN)
	p.deco(Vector2i(25, 35), ExteriorTiles.ROCK)
	p.deco(Vector2i(14, 31), ExteriorTiles.STUMP)
	p.deco(Vector2i(28, 18), ExteriorTiles.LOG_LEFT[0])
	p.deco(Vector2i(29, 18), ExteriorTiles.LOG_LEFT[1])
	p.sprinkle(Rect2i(0, 0, 40, 48), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL,
		ExteriorTiles.WHITE_FLOWERS])

	# Personajes de muestra.
	p.sign_text("Cartel", Vector2i(17, 45), PackedStringArray(["RUTA DE MUESTRA"]))
	p.spawn("default", Vector2i(19, 41))
	p.npc("Pescador", "npc_fisherman", Vector2i(29, 37), RIGHT, PackedStringArray(["Aquí pican poco..."]))
	p.npc("Entrenador", "trainer", Vector2i(16, 29), LEFT, PackedStringArray(["¡Desde arriba se ve toda la ruta!"]))
	p.npc("Chica", "npc_lass", Vector2i(21, 39), LEFT, PackedStringArray(["Las escaleras suben a la meseta."]))
	p.npc("Chico", "npc_youngster", Vector2i(21, 13), DOWN, PackedStringArray(["¡Qué alto estamos!"]))
	return p
