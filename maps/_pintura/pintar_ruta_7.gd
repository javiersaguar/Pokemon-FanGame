extends SceneTree
## Pinta la Ruta 7 · Los Monegros (maps/ruta_7/exterior.tscn), de Zaragoza hacia Lleida y Montserrat
## (docs/mundo/rutas.md): el desierto de yesos de Aragón, con sus cerros pelados (mesetas), la arena
## que lo cubre todo, matorral seco (hierba alta) y, en medio de la nada, el escenario del festival de
## música electrónica con sus ravers. Se une sin fundido con Zaragoza por el oeste.
## El viento y las tormentas de polvo quedan pendientes: los climas aún no tienen textura.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_7.gd -- --force

const OUT := "res://maps/ruta_7/exterior.tscn"
const SIZE := Vector2i(72, 34)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_7: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ruta_7/exterior"
	data.display_name = "Ruta 7 · Los Monegros"
	data.zone_id = &"ruta_7"
	data.encounter_table = &"ruta_7"
	data.region_map_position = Vector2i(23, 7)
	var p: RefCounted = painter.new("Ruta7", SIZE, data, 2012)
	p.fill_grass(0.1)
	p.connect_edge("west", &"zaragoza/exterior", 0, Vector2i(14, 18))

	# El desierto: arena de lado a lado.
	p.soil(Rect2i(0, 0, SIZE.x, SIZE.y))
	# Matorral seco donde salen los Pokémon y la pista de tierra.
	p.terrain(rects([Rect2i(6, 2, 10, 6), Rect2i(30, 24, 12, 7), Rect2i(56, 3, 10, 7), Rect2i(18, 22, 6, 9)]),
		ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(rects([Rect2i(0, 14, 72, 4)]), ExteriorTiles.TERRAIN_PATH)
	# Cerros de yeso (mesetas) a los lados de la pista.
	p.plateau(Rect2i(20, -2, 14, 12), [26, 27])
	p.plateau(Rect2i(44, 20, 12, 14), [])
	p.plateau(Rect2i(62, 22, 10, 12), [])

	p.object(&"escenario_festival", Vector2i(40, 12))
	for cell: Vector2i in [Vector2i(3, 10), Vector2i(12, 28), Vector2i(36, 4), Vector2i(53, 10), Vector2i(67, 12),
			Vector2i(28, 20), Vector2i(60, 30)]:
		p.deco(cell, ExteriorTiles.ROCK_BROWN if cell.x % 2 else ExteriorTiles.ROCK)
	for cell: Vector2i in [Vector2i(10, 20), Vector2i(38, 2), Vector2i(66, 18)]:
		p.deco(cell, ExteriorTiles.STUMP)
	p.deco(Vector2i(4, 22), ExteriorTiles.LOG_LEFT[0])
	p.deco(Vector2i(5, 22), ExteriorTiles.LOG_LEFT[1])

	# --- Carteles ---
	p.deco(Vector2i(1, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(1, 13), PackedStringArray(["RUTA 7 · LOS MONEGROS",
		"← Zaragoza   → Lleida y Montserrat. Próxima sombra: 60 km."]))
	p.deco(Vector2i(39, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelFestival", Vector2i(39, 13), PackedStringArray(["FESTIVAL DEL DESIERTO DE LOS MONEGROS.",
		"22 horas de música electrónica en mitad de la nada. Trae agua. Y tapones."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_zaragoza", Vector2i(0, 15))
	p.trainer("Kike", &"ruta7_raver", Vector2i(42, 18), UP, 2)
	p.trainer("Vane", &"ruta7_raver_f", Vector2i(46, 18), UP, 2)
	p.npc("Raver", "raver", Vector2i(44, 13), DOWN, PackedStringArray([
		"¿Que dónde está el baño? Querido, esto es Los Monegros: el baño es todo lo que ves."]))
	p.npc("Agricultor", "npc_old_man", Vector2i(14, 13), DOWN, PackedStringArray([
		"Aquí antes no crecía nada. Ahora, con el regadío, crece algo. Y con el festival, crece la basura."]))
	return p
