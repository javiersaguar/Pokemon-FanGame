extends SceneTree
## Pinta los mapas nuevos que necesitan los personajes decididos por Javier (docs/DECISIONES_JAVIER_2026-10-13.md, §4):
## - El piso de Gabriel Rufián en Barcelona: el salón (barcelona/casa_rufian) y su habitación propia
##   (barcelona/habitacion_rufian), donde está escondido Vito Quiles. Se sube desde el portal 10_31 del
##   Eixample (barcelona/sala_eixample_10_31), con maps/_tools/abrir_paso.gd.
## - La cárcel de Soto del Real: el exterior (soto_del_real/exterior, con la sierra detrás) y el módulo de
##   ingresos (soto_del_real/carcel), donde están Ábalos y Koldo más adelante. Se llega por el borde norte del
##   Bernabéu (la carretera de Colmenar), con maps/_tools/conectar_borde.gd.
## Los personajes se colocan por datos (data/personajes_en_el_mapa.json). Arte y textos provisionales hasta que
## los apruebe Javier.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_personajes.gd [-- --force]

const TILESET := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const ROOM := Vector2i(16, 12)
const OUTSIDE := Vector2i(36, 30)
const MAPS: Array[String] = ["barcelona/casa_rufian", "barcelona/habitacion_rufian", "soto_del_real/carcel", "soto_del_real/exterior"]
const SOFA := Rect2i(3, 52, 3, 2)
const CHAIR := Rect2i(6, 52, 2, 2)
const SHELF := Rect2i(5, 0, 3, 3)
const SHELF_2 := Rect2i(5, 3, 3, 3)
const BED := Rect2i(0, 40, 2, 2)
const TABLE := Rect2i(3, 59, 3, 2)
const DESK := Rect2i(6, 59, 2, 2)
const PLANT := Rect2i(0, 36, 1, 2)
const CABINET := Rect2i(0, 25, 4, 2)
const DOWN := 0
const UP := 3


func _initialize() -> void:
	await process_frame
	var force := "--force" in OS.get_cmdline_user_args()
	for id: String in MAPS:
		if FileAccess.file_exists("res://maps/%s.tscn" % id) and not force:
			push_error("pintar_personajes: '%s' ya existe; usa -- --force (se pierden las puertas enlazadas después)." % id)
			quit(1)
			return
	_salon()
	_habitacion()
	_carcel()
	_exterior()
	quit()


# --- Salas interiores (16×12, puerta abajo en el centro) ---

func _room(map_id: String, title: String, zone: StringName, floor: Vector2i, wall_row: int) -> Pintor:
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = title
	d.zone_id = zone
	d.outdoor = false
	d.fixed_camera = true
	d.can_run = false
	d.can_bike = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new(map_id.replace("/", "_"), ROOM, d)
	var tiles: TileSet = load(TILESET)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, ROOM)):
		p.ground.set_cell(at, 0, floor)
	for x: int in ROOM.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall_row - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall_row))
		if x != 8:
			p.decor.set_cell(Vector2i(x, ROOM.y - 1), 1, Vector2i(1, wall_row))
	for y: int in range(2, ROOM.y - 1):
		for x: int in [0, ROOM.x - 1]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, wall_row), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(16, 4)
	label.size = Vector2(ROOM.x * 32 - 32, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = title.to_upper()
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("303048"))
	p.root.add_child(label)
	return p


func _piece(p: Pintor, at: Vector2i, rect: Rect2i, source: int = 2) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), source, rect.position + Vector2i(x, y))


## Puerta de abajo: vuelve a `target` por su aparición `spawn_name`.
func _exit(p: Pintor, target: String, spawn_name: String) -> void:
	var door := Vector2i(8, ROOM.y - 1)
	p.decor.erase_cell(door)
	p.warp("Salida", door, StringName(target), StringName(spawn_name))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	p.spawn("default", door + Vector2i.UP)


## Paso en la pared del fondo hacia otra sala.
func _link(p: Pintor, warp_name: String, target: String, spawn_name: String) -> void:
	var cell := Vector2i(8, 0)
	p.decor.erase_cell(cell)
	p.decor.erase_cell(cell + Vector2i.DOWN)
	p.warp(warp_name, cell, StringName(target), StringName(spawn_name))
	p.root.get_node(NodePath("Warps/" + warp_name)).arrival_facing = Warp.Facing.UP


func _save(p: Pintor, map_id: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://maps/%s" % map_id.get_base_dir()))
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


func _salon() -> void:
	var p := _room("barcelona/casa_rufian", "Piso de Gabriel Rufián · Eixample", &"barcelona", Vector2i(1, 25), 24)
	_piece(p, Vector2i(2, 3), SOFA)
	_piece(p, Vector2i(3, 6), DESK)
	_piece(p, Vector2i(12, 2), SHELF)
	_piece(p, Vector2i(11, 7), TABLE)
	_piece(p, Vector2i(11, 9), CHAIR)
	_piece(p, Vector2i(1, 9), PLANT)
	_piece(p, Vector2i(14, 9), PLANT)
	_exit(p, "barcelona/sala_eixample_10_31", "desde_casa_rufian")
	_link(p, "Habitacion", "barcelona/habitacion_rufian", "default")
	p.spawn("desde_habitacion", Vector2i(8, 2))
	p.sign_text("Estelada", Vector2i(4, 1), PackedStringArray([
		"En la pared, una estelada enmarcada. Debajo, una foto de Rufián en el Congreso con una impresora.",
		"«Me iré en dieciocho meses», dice la dedicatoria. Está fechada en 2016."]))
	p.sign_text("Estanteria", Vector2i(13, 5), PackedStringArray([
		"Libros firmados por Gabriel Rufián. Dedicados a Gabriel Rufián."]))
	_save(p, "barcelona/casa_rufian")


func _habitacion() -> void:
	var p := _room("barcelona/habitacion_rufian", "Habitación de Gabriel Rufián", &"barcelona", Vector2i(2, 37), 9)
	_piece(p, Vector2i(2, 3), BED)
	_piece(p, Vector2i(10, 2), CABINET)
	_piece(p, Vector2i(4, 2), SHELF_2)
	_piece(p, Vector2i(12, 7), DESK)
	_piece(p, Vector2i(1, 9), PLANT)
	_exit(p, "barcelona/casa_rufian", "desde_habitacion")
	p.sign_text("Armario", Vector2i(14, 1), PackedStringArray([
		"El armario de Rufián. Dentro se oye respirar...",
		"...y una voz que pregunta: «¿Cuándo vas a dimitir?»."]))
	_save(p, "barcelona/habitacion_rufian")


func _carcel() -> void:
	var p := _room("soto_del_real/carcel", "Centro Penitenciario Madrid V · Soto del Real", &"soto_del_real", Vector2i(1, 41), 34)
	_piece(p, Vector2i(12, 2), SHELF)
	_piece(p, Vector2i(2, 7), TABLE)
	_piece(p, Vector2i(11, 7), TABLE)
	_piece(p, Vector2i(2, 9), CHAIR)
	_piece(p, Vector2i(12, 9), CHAIR)
	_piece(p, Vector2i(1, 2), PLANT)
	_exit(p, "soto_del_real/exterior", "from_carcel")
	p.npc("Funcionario", "policia", Vector2i(6, 9), DOWN, PackedStringArray([
		"Centro Penitenciario Madrid V. Módulo de ingresos.",
		"Por aquí han pasado futbolistas, raperos, banqueros, ministros... y sus asesores."]), {"display_name": "Funcionario"})
	p.sign_text("Tablon", Vector2i(4, 1), PackedStringArray([
		"TABLÓN DEL MÓDULO.",
		"Visitas: de diez a doce. Prohibido entrar cajas de mascarillas, sobres y chistorras."]))
	_save(p, "soto_del_real/carcel")


# --- Exterior (36×30): la carretera de Colmenar llega del Bernabéu por el sur ---

func _exterior() -> void:
	var d := MapData.new()
	d.id = &"soto_del_real/exterior"
	d.display_name = "Soto del Real · Cárcel"
	d.zone_id = &"soto_del_real"
	d.region_map_position = Vector2i(14, 10)
	var p := Pintor.new("SotoDelReal", OUTSIDE, d, 2807)
	p.fill_grass(0.25)
	p.connect_edge("south", &"madrid/bernabeu", 0, Vector2i(16, 20))
	# La sierra (La Pedriza y Guadarrama) detrás de la cárcel y bosque a los lados.
	p.forest(Rect2i(0, 0, OUTSIDE.x, 4))
	p.forest(Rect2i(0, 4, 3, OUTSIDE.y - 4))
	p.forest(Rect2i(OUTSIDE.x - 3, 4, 3, OUTSIDE.y - 4))
	p.build_forest()
	# La carretera desde el sur hasta la puerta, y el camino a la entrada principal.
	var road: Array[Vector2i] = []
	road.append_array(Pintor.cells(Rect2i(16, 14, 4, OUTSIDE.y - 14)))
	road.append_array(Pintor.cells(Rect2i(6, 18, 24, 2)))
	p.terrain(road, ExteriorTiles.TERRAIN_PATH)
	# Los módulos (naves) y el edificio de ingresos, con la verja delante y la puerta abierta.
	p.object(&"nave_logistica", Vector2i(4, 12))
	p.object(&"nave_logistica", Vector2i(22, 12))
	p.object(&"oficinas_azules", Vector2i(15, 13))
	for x: int in range(4, 32):
		if x < 16 or x > 19:
			p.object(&"verja", Vector2i(x, 16))
	# La Pedriza: rocas sueltas junto a la carretera.
	for cell: Vector2i in [Vector2i(8, 22), Vector2i(11, 25), Vector2i(25, 23), Vector2i(28, 26), Vector2i(6, 27)]:
		p.deco(cell, ExteriorTiles.ROCK_BROWN)
	for cell: Vector2i in [Vector2i(7, 24), Vector2i(26, 21), Vector2i(29, 24)]:
		p.object(&"pino", cell)
	p.sprinkle(Rect2i(3, 17, 30, 13), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])
	# Carteles.
	p.deco(Vector2i(21, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelCarcel", Vector2i(21, 17), PackedStringArray([
		"CENTRO PENITENCIARIO MADRID V · SOTO DEL REAL.",
		"Aquí han estado futbolistas, banqueros, ministros y algún asesor. Hoy, de visita, tú."]))
	p.deco(Vector2i(15, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelCarretera", Vector2i(15, 27), PackedStringArray([
		"CARRETERA DE COLMENAR.", "↓ Madrid · La Castellana y el Bernabéu.", "↑ Soto del Real y La Pedriza."]))
	# La puerta del edificio de ingresos lleva al módulo.
	var door: Vector2i = p.door_of(&"oficinas_azules", Vector2i(15, 13))
	p.warp("Carcel", door, &"soto_del_real/carcel", &"default")
	p.root.get_node(^"Warps/Carcel").arrival_facing = Warp.Facing.UP
	p.spawn("from_carcel", door + Vector2i.DOWN)
	p.spawn("default", Vector2i(17, OUTSIDE.y - 2))
	p.npc("Guardia", "policia", Vector2i(14, 17), DOWN, PackedStringArray([
		"Prisión de Soto del Real. Las visitas, por la puerta del edificio de ingresos.",
		"Dicen que hay dos del Clan que entran y salen. Como el Team Rocket, pero con más abogados."]), {"display_name": "Guardia"})
	_save_exterior(p, "soto_del_real/exterior")


func _save_exterior(p: Pintor, map_id: String) -> void:
	_save(p, map_id)
