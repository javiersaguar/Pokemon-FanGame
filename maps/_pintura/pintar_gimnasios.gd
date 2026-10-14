extends SceneTree
## Pinta los gimnasios por dentro (docs/DECISIONES_JAVIER_2026-10-14.md): por cada gimnasio, varias salas
## en fila y la del líder, según maps/_pintura/gimnasios_salas.json (lo genera el script de datos con los
## entrenadores de data/trainers/gimnasios.json).
##
## El puzle: cada sala es un zigzag de tres tramos separados por tabiques. El paso de un tramo al
## siguiente lo tapa un vigilante que solo se aparta al ganar al entrenador de ese tramo
## (MapEntity.hidden_if_flag con su flag de derrota), así que no se llega al líder sin ganar a todos.
## Las salas pares van en espejo.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_gimnasios.gd [-- ciudad ...]

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const SPEC := "res://maps/_pintura/gimnasios_salas.json"
const LEADER_EVENT := "res://src/events/gym_leader_event.gd"
const AYUSO_EVENT := "res://src/events/gym1_ayuso_event.gd"
const SIZE := Vector2i(16, 12)
const FLOORS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(2, 5), Vector2i(1, 9), Vector2i(2, 13), Vector2i(1, 17), Vector2i(2, 21),
	Vector2i(1, 25), Vector2i(2, 29), Vector2i(1, 33), Vector2i(2, 37), Vector2i(1, 41), Vector2i(2, 45),
	Vector2i(1, 49), Vector2i(2, 53), Vector2i(1, 57), Vector2i(2, 61),
]
const WALLS: Array[int] = [4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74]
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3
## Dónde entra cada gimnasio desde la calle: mapa y aparición a la que se vuelve al salir.
const ENTRADAS := {
	"madrid": ["madrid/centro", "from_sala_39_31"], "barcelona": ["barcelona/les_corts", "from_sala_26_40"],
	"valencia": ["valencia/malvarrosa", "from_sala_43_20"], "sevilla": ["sevilla/rio", "from_sala_9_31"],
	"playa_del_ingles": ["playa_del_ingles/exterior", "from_gimnasio"], "bilbao": ["bilbao/exterior", "from_san_mames"],
	"valladolid": ["valladolid/exterior", "from_sala_35_18"], "malaga": ["malaga/exterior", "from_gimnasio"],
}


func _initialize() -> void:
	await process_frame
	var spec := JsonFile.read_dict(SPEC)
	var only := Array(OS.get_cmdline_user_args())
	for city: String in spec:
		if not only.is_empty() and city not in only:
			continue
		var gym: Dictionary = spec[city]
		var rooms: Array = gym["salas"]
		for i: int in rooms.size():
			_room(city, gym, i, rooms.size())
		_leader_room(city, gym, rooms.size())
	quit()


func _id(city: String, index: int, total: int) -> String:
	return "%s/gimnasio_lider" % city if index >= total else "%s/gimnasio_%d" % [city, index + 1]


func _shell(city: String, gym: Dictionary, map_id: String, title: String) -> Pintor:
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = title.capitalize()
	d.zone_id = StringName(city)
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Gimnasio", SIZE, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	var floor_tile: Vector2i = FLOORS[int(gym["suelo"]) % FLOORS.size()]
	var wall: int = WALLS[int(gym["pared"]) % WALLS.size()]
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, SIZE)):
		p.ground.set_cell(at, 0, floor_tile)
	for x: int in SIZE.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall))
		if x != 8:
			p.decor.set_cell(Vector2i(x, 11), 1, Vector2i(1, wall))
	for y: int in range(2, 11):
		for x: int in [0, 15]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(8, 4)
	label.size = Vector2(SIZE.x * 32 - 16, 24)
	label.text = title.replace(" · ", ": ")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("fff4d8"))
	label.add_theme_color_override("font_shadow_color", Color("303048"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	p.root.add_child(label)
	p.spawn("default", Vector2i(8, 10))
	return p


## Tabiques y tramos. Devuelve, por tramo, [casilla del entrenador, hacia dónde mira, casilla del paso].
func _zigzag(p: Pintor, gym: Dictionary, mirrored: bool, sections: int) -> Array:
	var wall: int = WALLS[int(gym["pared"]) % WALLS.size()]
	var gap_a := 2 if mirrored else 13
	var gap_b := 13 if mirrored else 2
	if sections >= 1:
		for x: int in range(1, 15):
			if x != gap_a:
				p.decor.set_cell(Vector2i(x, 7), 1, Vector2i(1, wall))
	if sections >= 2:
		for x: int in range(1, 15):
			if x != gap_b:
				p.decor.set_cell(Vector2i(x, 4), 1, Vector2i(1, wall))
	# Mobiliario del tramo de entrada, en el lado contrario al entrenador, y plantas en las esquinas.
	var prop := Rect2i(3, 52, 3, 2) if int(gym["suelo"]) % 2 == 0 else Rect2i(3, 59, 3, 2)
	_piece(p, Vector2i(3 if mirrored else 10, 9), prop)
	_piece(p, Vector2i(1, 9), Rect2i(0, 36, 1, 2))
	_piece(p, Vector2i(14, 9), Rect2i(2, 36, 1, 2))
	var out: Array = [
		[Vector2i(11 if mirrored else 4, 9), LEFT if mirrored else RIGHT, Vector2i(gap_a, 7)],
		[Vector2i(4 if mirrored else 11, 5), RIGHT if mirrored else LEFT, Vector2i(gap_b, 4)],
		[Vector2i(11 if mirrored else 5, 3), LEFT if mirrored else RIGHT, Vector2i(8, 2)],
	]
	return out


func _gate(p: Pintor, gym: Dictionary, index: int, cell: Vector2i, trainer: Dictionary) -> void:
	p.npc("Vigilante%d" % index, str(gym["guardia"]), cell, DOWN, PackedStringArray([
		"Por aquí no se pasa todavía.", "Primero tienes que ganar a %s. Aquí se entra por orden, como en todas partes menos en la lista de espera." % trainer["nombre"]]),
		{"hidden_if_flag": StringName("trainer_defeated:%s" % str(trainer["id"]))})


func _room(city: String, gym: Dictionary, index: int, total: int) -> void:
	var room: Dictionary = gym["salas"][index]
	var map_id := _id(city, index, total)
	var p := _shell(city, gym, map_id, str(room["titulo"]))
	var trainers: Array = room["entrenadores"]
	var sections := _zigzag(p, gym, index % 2 == 1, mini(trainers.size(), 2))
	for i: int in trainers.size():
		var t: Dictionary = trainers[i]
		p.trainer("Entrenador%d" % (i + 1), StringName(str(t["id"])), sections[i][0], sections[i][1], 2)
		_gate(p, gym, i + 1, sections[i][2], t)
		if city == "madrid" and index == 0 and i == 0:
			# El gimnasio 1 no abre hasta que Ayuso da paso en el Quirón.
			p.root.get_node("Entities/Entrenador1").set(&"visible_if_flag", &"quiron_superado")
			p.npc("Ujier", "tertuliano", Vector2i(9, 10), LEFT, PackedStringArray([
				"La presidenta está de visita en el hospital Quirón. Sin su permiso aquí no combate nadie.",
				"Vuelva cuando ella le haya dado paso. Y con cita previa, a ser posible."]), {"hidden_if_flag": &"quiron_superado"})
	_doors(p, city, index, total)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


func _leader_room(city: String, gym: Dictionary, total: int) -> void:
	var map_id := _id(city, total, total)
	var p := _shell(city, gym, map_id, str(gym["lider_titulo"]))
	var before: Array = gym.get("lider_previos", [])
	var sections := _zigzag(p, gym, total % 2 == 1, mini(before.size(), 2))
	for i: int in before.size():
		var t: Dictionary = before[i]
		p.trainer("Entrenador%d" % (i + 1), StringName(str(t["id"])), sections[i][0], sections[i][1], 2)
		_gate(p, gym, i + 1, sections[i][2], t)
	var leader := Vector2i(8, 2)
	if city == "madrid":
		p.npc("Ayuso", "ayuso", leader, DOWN, PackedStringArray(), {"event": load(AYUSO_EVENT), "display_name": "Ayuso"})
	else:
		p.trainer("Lider", StringName(str(gym["lider"])), leader, DOWN, 0)
		p.root.get_node("Entities/Lider").set(&"challenge_event", load(LEADER_EVENT))
	_doors(p, city, total, total)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


## Salida por abajo (a la calle o a la sala anterior) y, si no es la del líder, puerta arriba a la siguiente.
func _doors(p: Pintor, city: String, index: int, total: int) -> void:
	if index == 0:
		var entry: Array = ENTRADAS[city]
		if str(entry[0]) != "":
			p.warp("Salida", Vector2i(8, 11), StringName(str(entry[0])), StringName(str(entry[1])))
			p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	else:
		p.warp("Salida", Vector2i(8, 11), StringName(_id(city, index - 1, total)), &"from_arriba")
		p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	if index < total:
		p.decor.erase_cell(Vector2i(8, 1))
		p.spawn("from_arriba", Vector2i(8, 2))
		p.warp("Siguiente", Vector2i(8, 1), StringName(_id(city, index + 1, total)), &"default")
		p.root.get_node("Warps/Siguiente").arrival_facing = Warp.Facing.UP


func _piece(p: Pintor, at: Vector2i, rect: Rect2i) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), 2, rect.position + Vector2i(x, y))
