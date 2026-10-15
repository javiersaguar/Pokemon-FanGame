extends SceneTree
## Pinta la Liga del Palacio Real (decisión de Javier: Alto Mando Iniesta, Nadal, Gasol y Alonso, y al final el
## Líder Supremo, Pedro Sánchez): una sala por miembro, en fila. Cada sala tiene la puerta de abajo a la anterior
## y un paso arriba a la siguiente, que tapa un ujier hasta que ganas al de la sala (colocado por datos, con
## "oculto_si" en data/personajes_en_el_mapa.json). La primera sala vuelve al interior del Palacio
## (madrid/sala_palacio_real_23_30, del Agente 1); su paso hacia la Liga se pide en docs/ESTADO.md.
## Los personajes se colocan por datos. Arte, muebles y carteles provisionales hasta que los apruebe Javier.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_liga.gd [-- --force]

const TILESET := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const ROOM := Vector2i(16, 12)
const PALACE := "madrid/sala_palacio_real_23_30"
const SHELF := Rect2i(5, 0, 3, 3)
const SHELF_2 := Rect2i(5, 6, 3, 3)
const TABLE := Rect2i(3, 59, 3, 2)
const DESK := Rect2i(6, 59, 2, 2)
const PLANT := Rect2i(0, 36, 1, 2)
const PLANT_2 := Rect2i(2, 36, 1, 2)
const SOFA := Rect2i(3, 52, 3, 2)
## id, título, suelo, fila de la pared y los dos carteles (posición y texto).
const ROOMS := [
	["madrid/liga_iniesta", "Liga Pokémon · Sala de Iniesta", Vector2i(1, 33), 14,
		["Johannesburgo, 11 de julio de 2010. Minuto 116.", "En la vitrina, la bota del gol. Sin limpiar, por si acaso."],
		["Alto Mando · Psíquico.", "Iniesta ve el pase antes de que exista."]],
	["madrid/liga_nadal", "Liga Pokémon · Sala de Nadal", Vector2i(2, 45), 19,
		["Catorce Roland Garros.", "La arcilla de este suelo se barre entre combate y combate. Y las botellas, en fila."],
		["Alto Mando · Tierra.", "Nadal no deja de correr hasta la última bola."]],
	["madrid/liga_gasol", "Liga Pokémon · Sala de Gasol", Vector2i(1, 49), 29,
		["Dos anillos de la NBA.", "La canasta está a 3,05 metros. Para Gasol, a la altura de la cintura."],
		["Alto Mando · Dragón.", "Desde arriba se ve todo el combate."]],
	["madrid/liga_alonso", "Liga Pokémon · Sala de Alonso", Vector2i(2, 53), 39,
		["Garaje del número 14.", "En la pizarra: «El 33 está al caer». Fecha borrada y vuelta a escribir varias veces."],
		["Alto Mando · Eléctrico y Acero.", "Si te pasa, no hay quien le coja."]],
	["madrid/liga_sanchez", "Liga Pokémon · Salón de Columnas", Vector2i(1, 57), 49,
		["SALÓN DE COLUMNAS DEL PALACIO REAL.", "Aquí se firmó la entrada de España en la Comunidad Europea, en 1985."],
		["Por la ventana se ve el Falcon aparcado en la Plaza de la Armería.", "El motor sigue encendido. Por si hay que irse."]],
]


func _initialize() -> void:
	await process_frame
	var force := "--force" in OS.get_cmdline_user_args()
	for room: Array in ROOMS:
		if FileAccess.file_exists("res://maps/%s.tscn" % room[0]) and not force:
			push_error("pintar_liga: '%s' ya existe; usa -- --force (se pierden las puertas enlazadas después)." % room[0])
			quit(1)
			return
	for i: int in ROOMS.size():
		var previous: String = PALACE if i == 0 else ROOMS[i - 1][0]
		var next: String = ROOMS[i + 1][0] if i + 1 < ROOMS.size() else ""
		_paint(ROOMS[i], previous, i == 0, next, i)
	quit()


func _paint(room: Array, previous: String, first: bool, next: String, index: int) -> void:
	var map_id: String = room[0]
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = room[1]
	d.zone_id = &"madrid"
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
	var floor: Vector2i = room[2]
	var wall_row: int = room[3]
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
	# Muebles a los lados, con el pasillo central libre.
	_piece(p, Vector2i(1, 2), SHELF if index % 2 == 0 else SHELF_2)
	_piece(p, Vector2i(12, 2), SHELF_2 if index % 2 == 0 else SHELF)
	_piece(p, Vector2i(2, 7), TABLE if index != 4 else SOFA)
	_piece(p, Vector2i(11, 7), TABLE if index != 4 else SOFA)
	_piece(p, Vector2i(1, 9), PLANT)
	_piece(p, Vector2i(14, 9), PLANT_2)
	if index == 4:
		_piece(p, Vector2i(5, 4), DESK)
		_piece(p, Vector2i(9, 4), DESK)
	# Puerta de abajo: a la sala anterior (la primera, al interior del Palacio).
	var door := Vector2i(8, ROOM.y - 1)
	p.decor.erase_cell(door)
	p.warp("Salida", door, StringName(previous), &"desde_liga" if first else &"desde_siguiente")
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	p.spawn("default", door + Vector2i.UP)
	# Paso de arriba: a la sala siguiente.
	if next != "":
		var cell := Vector2i(8, 0)
		p.decor.erase_cell(cell)
		p.decor.erase_cell(cell + Vector2i.DOWN)
		p.warp("Siguiente", cell, StringName(next), &"default")
		p.root.get_node(^"Warps/Siguiente").arrival_facing = Warp.Facing.UP
		p.spawn("desde_siguiente", Vector2i(8, 2))
	var first_sign: Array = room[4]
	var second_sign: Array = room[5]
	p.sign_text("Cartel", Vector2i(4, 1), PackedStringArray(first_sign))
	p.sign_text("Cartel2", Vector2i(11, 1), PackedStringArray(second_sign))
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(16, 4)
	label.size = Vector2(ROOM.x * 32 - 32, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = String(room[1]).to_upper()
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("303048"))
	p.root.add_child(label)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


func _piece(p: Pintor, at: Vector2i, rect: Rect2i, source: int = 2) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), source, rect.position + Vector2i(x, y))
