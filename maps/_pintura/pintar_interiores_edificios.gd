extends SceneTree
## Un interior distinto para cada edificio con puerta de cada ciudad.
## La sala es de 16×12 (la cámara fija). El mobiliario sale del tileset de
## Akizakura16. No coloca personajes famosos ni abre combates de gimnasio.
## Uso: -- [ciudad o mapa ...] [--solo-nuevas] [--rutas]
##   --solo-nuevas  deja como están las puertas que ya tienen interior (no rehace casas ni locales)
##   --rutas        incluye también las rutas (por defecto, solo ciudades y pueblos)

const TILESET := "res://assets/tilesets/interior/interior.tres"
const SIZE := Vector2i(16, 12)
const FLOORS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(2, 5), Vector2i(1, 9), Vector2i(2, 13),
	Vector2i(1, 17), Vector2i(2, 21), Vector2i(1, 25), Vector2i(2, 29),
	Vector2i(1, 33), Vector2i(2, 37), Vector2i(1, 41), Vector2i(2, 45),
	Vector2i(1, 49), Vector2i(2, 53), Vector2i(1, 57), Vector2i(2, 61),
]
const WALLS: Array[int] = [4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74]
const SHELVES: Array[Rect2i] = [
	Rect2i(5, 0, 3, 3), Rect2i(5, 3, 3, 3), Rect2i(5, 6, 3, 3), Rect2i(5, 9, 3, 3),
	Rect2i(5, 12, 3, 3), Rect2i(5, 15, 3, 3), Rect2i(5, 18, 3, 3),
]
const BEDS: Array[Rect2i] = [
	Rect2i(0, 40, 2, 2), Rect2i(2, 40, 2, 2), Rect2i(4, 40, 2, 2),
	Rect2i(0, 43, 2, 2), Rect2i(2, 43, 2, 2), Rect2i(4, 43, 2, 2),
]
const TABLES: Array[Rect2i] = [Rect2i(3, 59, 3, 2), Rect2i(6, 59, 2, 2)]
const PLANTS: Array[Rect2i] = [Rect2i(0, 36, 1, 2), Rect2i(2, 36, 1, 2)]
const COUNTERS: Array[Rect2i] = [Rect2i(5, 6, 3, 1), Rect2i(5, 12, 3, 1), Rect2i(5, 18, 3, 1), Rect2i(5, 24, 3, 1)]
const ZONES: Array[Rect2i] = [
	Rect2i(1, 2, 6, 5), Rect2i(10, 2, 5, 5), Rect2i(1, 9, 6, 2), Rect2i(10, 9, 5, 2),
]
## La casa azul de la Moncloa queda detrás de la verja: la calle no llega a la puerta.
const SKIP_DOORS := {"madrid/moncloa": [Vector2i(5, 8)]}

var _locales: Dictionary = {}
var _catalog: Dictionary = {}
var _by_cell: Dictionary = {}
var _state := 1
var _made := 0
var _repainted := 0
var _detailed := 0
var _linked := 0
var _only_new := false
var _routes := false


func _initialize() -> void:
	await process_frame
	_locales = JsonFile.read_dict("res://maps/_pintura/locales.json")
	_catalog = ExteriorTiles.objects()
	for id: String in _catalog:
		var o: Dictionary = _catalog[id]
		_by_cell["%s:%s" % [o["source"], o["coords"]]] = id
	var only := PackedStringArray()
	_only_new = "--solo-nuevas" in OS.get_cmdline_user_args()
	_routes = "--rutas" in OS.get_cmdline_user_args()
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--"):
			only.append(arg)
	var dirty: Dictionary = {}
	for path: String in _city_maps():
		var map_id := path.trim_prefix("res://maps/").trim_suffix(".tscn")
		var city := map_id.get_slice("/", 0)
		if not only.is_empty() and city not in only and map_id not in only:
			continue
		if not map_id.ends_with("/exterior") and map_id.find("/") < 0:
			continue
		_scan(map_id, dirty)
	for map_id: String in dirty:
		var root: Node = dirty[map_id]
		var packed := PackedScene.new()
		var err := packed.pack(root)
		if err != OK:
			push_error("%s: %s" % [map_id, error_string(err)])
			continue
		print("exterior ", map_id, " ", error_string(ResourceSaver.save(packed, "res://maps/%s.tscn" % map_id)))
		root.free()
	print("salas nuevas %d, casas rehechas %d, locales detallados %d, puertas enlazadas %d" % [_made, _repainted, _detailed, _linked])
	quit()


func _scan(map_id: String, dirty: Dictionary) -> void:
	var path := "res://maps/%s.tscn" % map_id
	if not ResourceLoader.exists(path):
		return
	var root: Node = (load(path) as PackedScene).instantiate()
	var data := root.get("data") as MapData
	if data == null or not data.outdoor:
		root.free()
		return
	var objects := root.get_node_or_null(^"Entities/Objects") as TileMapLayer
	var ground := root.get_node_or_null(^"Ground") as TileMapLayer
	if objects == null or ground == null:
		root.free()
		return
	var bounds := ground.get_used_rect()
	var changed := false if _only_new else _strip_salas(root)
	var city := map_id.get_slice("/", 0)
	var city_name := _city_name(city)
	var place := data.display_name if data.display_name != "" else city_name
	var seen := {}
	for cell: Vector2i in objects.get_used_cells():
		var object_id := _object_at(objects, cell)
		if object_id == "":
			continue
		var offset: Vector2i = _catalog[object_id]["door"]
		if offset.x < 0:
			continue
		var door := cell + offset
		if not bounds.has_point(door) or not bounds.has_point(door + Vector2i.DOWN) or seen.has(door):
			continue
		if _skip_door(map_id, door):
			continue
		seen[door] = true
		var warp := _warp_at(root, door)
		if warp != null and _only_new:
			continue
		if warp == null:
			var interior := "%s/sala_%s_%d_%d" % [city, _zone_slug(map_id), door.x, door.y]
			_paint_new(interior, object_id, map_id, city, city_name, place, data.zone_id, "from_sala_%d_%d" % [door.x, door.y])
			_link(root, door, "Sala%d_%d" % [door.x, door.y], interior, "from_sala_%d_%d" % [door.x, door.y])
			_linked += 1
			_made += 1
			changed = true
			continue
		var target := String(warp.target_map)
		if _has_plaque(target):
			continue
		if _is_generic_house(target):
			_repaint_house(target, object_id, city_name, place)
			_repainted += 1
		else:
			_detail_existing(target, object_id, city_name, place)
			_detailed += 1
	if changed:
		dirty[map_id] = root
	else:
		root.free()


func _paint_new(interior: String, object_id: String, exterior: String, city: String, city_name: String, place: String, zone: StringName, return_spawn: String) -> void:
	var theme := _theme(object_id)
	_state = maxi(1, _hash("%s|%s" % [interior, object_id]))
	if theme == "clinic":
		_paint_clinic(interior, exterior, city_name, zone, return_spawn, place)
		return
	var label := _label(object_id)
	var d := _data(interior, "%s · %s" % [label, city_name], zone)
	var p := Pintor.new("Sala", SIZE, d, _state)
	_shell(p, FLOORS[_randi() % FLOORS.size()], WALLS[_randi() % WALLS.size()], FLOORS[_randi() % FLOORS.size()])
	var reserved := _spine()
	_furnish(p, theme, reserved)
	var sheets := _sheets(theme, city, exterior)
	var pool := _lines(theme, label, city_name, place)
	p.npc("Vecino", sheets[0], Vector2i(3, 6), 0, PackedStringArray([pool[0], pool[1]]), {"display_name": _role(theme, true)})
	p.npc("Vecina", sheets[1], Vector2i(12, 6), 0, PackedStringArray([pool[2], pool[3]]), {"display_name": _role(theme, false)})
	_sign(p, label, city_name, object_id)
	_heading(p, "%s / %s" % [label, city_name])
	p.spawn("default", Vector2i(8, 10))
	p.warp("Salida", Vector2i(8, 11), StringName(exterior), StringName(return_spawn))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	print(interior, " ", error_string(p.save("res://maps/%s.tscn" % interior)))


func _paint_clinic(interior: String, exterior: String, city_name: String, zone: StringName, return_spawn: String, place: String) -> void:
	var d := _data(interior, "Centro Pokémon · " + city_name, zone)
	var p := Pintor.new("Centro", SIZE, d, _state)
	_shell(p, FLOORS[_randi() % FLOORS.size()], WALLS[_randi() % WALLS.size()], Vector2i(1, 21))
	for at: Vector2i in [Vector2i(2, 3), Vector2i(12, 3)]:
		_stamp(p, at, 2, BEDS[_randi() % BEDS.size()], {})
	_stamp(p, Vector2i(2, 8), 2, TABLES[0], {})
	_stamp(p, Vector2i(11, 7), 3, Rect2i(0, 31, 2, 3), {})
	_counter(p, Vector2i(6, 4))
	var nurse_place := "Centro Pokémon de " + city_name
	p.npc("Enfermera", "nurse", Vector2i(8, 3), 0, PackedStringArray(), {
		"display_name": "Enfermería",
		"event": load("res://src/events/common/heal_party_event.gd"),
		"event_params": {"place": nurse_place, "spawn": "recovery"},
	})
	p.spawn("recovery", Vector2i(8, 5))
	p.npc("Paciente", "npc_woman", Vector2i(5, 8), 0, PackedStringArray([
		"Aquí curan al equipo y el terminal abre las cajas.",
		place + " queda a la puerta.",
	]))
	var terminal: Node2D = load("res://src/overworld/sign/sign.tscn").instantiate()
	terminal.set_script(load("res://src/overworld/hospital_terminal.gd"))
	terminal.name = "PC"
	terminal.position = Grid.to_world(Vector2i(12, 9))
	p.entities.add_child(terminal)
	_sign(p, "Centro Pokémon", city_name, "centro_pokemon")
	_heading(p, "CENTRO POKÉMON / " + city_name)
	p.spawn("default", Vector2i(8, 10))
	p.warp("Salida", Vector2i(8, 11), StringName(exterior), StringName(return_spawn))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	print(interior, " ", error_string(p.save("res://maps/%s.tscn" % interior)))


func _repaint_house(interior: String, object_id: String, city_name: String, place: String) -> void:
	var old: Node = (load("res://maps/%s.tscn" % interior) as PackedScene).instantiate()
	var data := old.get("data") as MapData
	var salida := old.get_node(^"Warps/Salida") as Warp
	var exterior := String(salida.target_map)
	var back := String(salida.target_spawn)
	var zone := data.zone_id
	var reward := ""
	for node: Node in old.get_node(^"Entities").get_children():
		var params: Variant = node.get("event_params")
		if params is Dictionary and (params as Dictionary).has("reward_id"):
			reward = str((params as Dictionary)["reward_id"])
	old.free()
	_state = maxi(1, _hash("%s|%s|casa" % [interior, object_id]))
	var label := _label(object_id)
	var d := _data(interior, "%s · %s" % [label, city_name], zone)
	var p := Pintor.new("Casa", SIZE, d, _state)
	_shell(p, FLOORS[_randi() % FLOORS.size()], WALLS[_randi() % WALLS.size()], FLOORS[_randi() % FLOORS.size()])
	var reserved := _spine()
	_furnish(p, "home", reserved)
	var city := interior.get_slice("/", 0)
	var sheets := _sheets("home", city, exterior)
	var pool := _lines("home", label, city_name, place)
	p.npc("Vecino", sheets[0], Vector2i(3, 6), 0, PackedStringArray([pool[0], pool[1]]), {"display_name": "Vecino"})
	if reward != "":
		p.npc("Anfitrion", sheets[1], Vector2i(12, 6), 0, PackedStringArray(), {
			"display_name": "Anfitriona",
			"event": load("res://src/events/common/npc_reward_event.gd"),
			"event_params": {"reward_id": reward},
		})
	else:
		p.npc("Vecina", sheets[1], Vector2i(12, 6), 0, PackedStringArray([pool[2], pool[3]]), {"display_name": "Vecina"})
	_sign(p, label, city_name, object_id)
	_heading(p, "%s / %s" % [label, city_name])
	p.spawn("default", Vector2i(8, 10))
	p.warp("Salida", Vector2i(8, 11), StringName(exterior), StringName(back))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN
	print("casa ", interior, " ", error_string(p.save("res://maps/%s.tscn" % interior)))


func _detail_existing(interior: String, object_id: String, city_name: String, place: String) -> void:
	var path := "res://maps/%s.tscn" % interior
	if not ResourceLoader.exists(path):
		print("sin sala ", interior)
		return
	var root: Node = (load(path) as PackedScene).instantiate()
	_state = maxi(1, _hash("detalle|" + interior))
	var ground := root.get_node(^"Ground") as TileMapLayer
	var decor := root.get_node(^"Decor") as TileMapLayer
	var floor := FLOORS[_randi() % FLOORS.size()]
	for cell: Vector2i in ground.get_used_cells():
		ground.set_cell(cell, 0, floor)
	var rug := FLOORS[_randi() % FLOORS.size()]
	for cell: Vector2i in [Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6), Vector2i(6, 7), Vector2i(9, 7)]:
		if decor.get_cell_source_id(cell) < 0:
			ground.set_cell(cell, 0, rug)
	var blocked := {}
	for cell: Vector2i in decor.get_used_cells():
		blocked[cell] = true
	var entities := root.get_node(^"Entities") as Node2D
	for node: Node in entities.get_children():
		if node is TileMapLayer:
			continue
		var at := Grid.to_tile((node as Node2D).position)
		blocked[at] = true
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			blocked[at + step] = true
	for y: int in [9, 10, 11]:
		blocked[Vector2i(8, y)] = true
	for at: Vector2i in [Vector2i(1, 2), Vector2i(4, 2), Vector2i(13, 9), Vector2i(14, 9)]:
		if _stamp_on(decor, at, 2, PLANTS[_randi() % PLANTS.size()], blocked):
			break
	for at: Vector2i in [Vector2i(1, 2), Vector2i(4, 2), Vector2i(10, 2), Vector2i(9, 2)]:
		if _stamp_on(decor, at, 2, SHELVES[_randi() % SHELVES.size()], blocked):
			break
	for at: Vector2i in [Vector2i(1, 9), Vector2i(10, 9), Vector2i(4, 9)]:
		if _stamp_on(decor, at, 2, TABLES[_randi() % TABLES.size()], blocked):
			break
	var spot := _free_spot(blocked)
	if spot.x >= 0 and entities.get_node_or_null(^"Visitante") == null:
		var visitor: Node2D = (load("res://src/overworld/npc/npc.tscn") as PackedScene).instantiate()
		visitor.name = "Visitante"
		visitor.position = Grid.to_world(spot)
		visitor.set(&"sprite_sheet", load("res://assets/sprites/characters/npc_lass.png"))
		visitor.set(&"initial_facing", 0)
		visitor.set(&"lines", PackedStringArray([
			"%s, en %s. %s" % [_label(object_id), city_name, place],
			"La salida sigue siendo el hueco del sur.",
		]))
		visitor.set(&"display_name", "Visitante")
		entities.add_child(visitor)
		visitor.owner = root
	if entities.get_node_or_null(^"PlacaCiudad") == null:
		var sign_at := _free_spot(blocked)
		if sign_at.x >= 0:
			var sign: Node2D = (load("res://src/overworld/sign/sign.tscn") as PackedScene).instantiate()
			sign.name = "PlacaCiudad"
			sign.position = Grid.to_world(sign_at)
			sign.set(&"only_from_below", false)
			sign.set(&"lines", PackedStringArray([_blurb(object_id, _label(object_id), city_name), place]))
			entities.add_child(sign)
			sign.owner = root
			blocked[sign_at] = true
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("detalle ", interior, " ", error_string(err))
	root.free()


func _shell(p: Pintor, floor: Vector2i, wall_row: int, rug: Vector2i) -> void:
	var tiles: TileSet = load(TILESET)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, SIZE)):
		p.ground.set_cell(at, 0, floor)
	for x: int in range(5, 11):
		for y: int in range(5, 8):
			p.ground.set_cell(Vector2i(x, y), 0, rug)
	for x: int in SIZE.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall_row - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall_row))
		if x != 8:
			p.decor.set_cell(Vector2i(x, 11), 1, Vector2i(1, wall_row))
	for y: int in range(2, 11):
		p.decor.set_cell(Vector2i(0, y), 1, Vector2i(1, wall_row), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
		p.decor.set_cell(Vector2i(15, y), 1, Vector2i(1, wall_row), TileSetAtlasSource.TRANSFORM_TRANSPOSE)


func _furnish(p: Pintor, theme: String, reserved: Dictionary) -> void:
	var start := _randi() % ZONES.size()
	var n := 0
	for kind: String in _recipe(theme):
		var piece := _pick(kind, _randi())
		var placed := false
		for step: int in ZONES.size():
			if _try_stamp(p, ZONES[(start + step + n) % ZONES.size()], int(piece["source"]), piece["rect"], reserved):
				placed = true
				break
		n += 1


func _recipe(theme: String) -> PackedStringArray:
	match theme:
		"home":
			return PackedStringArray(["bed", "shelf", "sofa", "table", "plant", "cabinet"])
		"shop":
			return PackedStringArray(["shelf", "shelf", "counter", "table", "plant", "cabinet"])
		"nave":
			return PackedStringArray(["chair", "chair", "sofa", "plant", "plant", "table"])
		"gym":
			return PackedStringArray(["cabinet", "plant", "table", "chair", "bed"])
		"civic":
			return PackedStringArray(["table", "shelf", "cabinet", "chair", "plant"])
		"culture":
			return PackedStringArray(["sofa", "shelf", "plant", "table", "chair"])
		"transit":
			return PackedStringArray(["chair", "chair", "plant", "cabinet", "table"])
		"arena":
			return PackedStringArray(["chair", "sofa", "plant", "table", "cabinet"])
		_:
			return PackedStringArray(["plant", "chair", "table", "shelf", "sofa"])


func _pick(kind: String, n: int) -> Dictionary:
	match kind:
		"shelf":
			return {"source": 2, "rect": SHELVES[n % SHELVES.size()]}
		"bed":
			return {"source": 2, "rect": BEDS[n % BEDS.size()]}
		"table":
			return {"source": 2, "rect": TABLES[n % TABLES.size()]}
		"plant":
			return {"source": 2, "rect": PLANTS[n % PLANTS.size()]}
		"sofa":
			return {"source": 2, "rect": Rect2i(3, 52, 3, 2)}
		"chair":
			return {"source": 2, "rect": Rect2i(6, 52, 2, 2)}
		"cabinet":
			return {"source": 2, "rect": Rect2i(0, 25, 4, 2)}
		"counter":
			return {"source": 3, "rect": COUNTERS[n % COUNTERS.size()]}
		_:
			return {"source": 2, "rect": PLANTS[0]}


func _try_stamp(p: Pintor, zone: Rect2i, source: int, rect: Rect2i, reserved: Dictionary) -> bool:
	if rect.size.x > zone.size.x or rect.size.y > zone.size.y:
		return false
	var options: Array[Vector2i] = []
	for y: int in range(zone.position.y, zone.end.y - rect.size.y + 1):
		for x: int in range(zone.position.x, zone.end.x - rect.size.x + 1):
			var fits := true
			for dy: int in rect.size.y:
				for dx: int in rect.size.x:
					if reserved.has(Vector2i(x + dx, y + dy)):
						fits = false
			if fits:
				options.append(Vector2i(x, y))
	if options.is_empty():
		return false
	_stamp(p, options[_randi() % options.size()], source, rect, reserved)
	return true


func _stamp(p: Pintor, at: Vector2i, source: int, rect: Rect2i, reserved: Dictionary) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			var cell := at + Vector2i(x, y)
			p.decor.set_cell(cell, source, rect.position + Vector2i(x, y))
			reserved[cell] = true


func _stamp_on(decor: TileMapLayer, at: Vector2i, source: int, rect: Rect2i, blocked: Dictionary) -> bool:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			var cell := at + Vector2i(x, y)
			if cell.x < 1 or cell.x > 14 or cell.y < 2 or cell.y > 10 or blocked.has(cell):
				return false
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			var cell := at + Vector2i(x, y)
			decor.set_cell(cell, source, rect.position + Vector2i(x, y))
			blocked[cell] = true
	return true


func _counter(p: Pintor, at: Vector2i) -> void:
	for x: int in 3:
		p.decor.set_cell(at + Vector2i(x, 0), 3, Vector2i(5 + x, 6))


func _spine() -> Dictionary:
	var reserved := {}
	for y: int in range(5, 12):
		for x: int in [7, 8, 9]:
			reserved[Vector2i(x, y)] = true
	for x: int in range(2, 14):
		reserved[Vector2i(x, 7)] = true
		reserved[Vector2i(x, 8)] = true
	for cell: Vector2i in [Vector2i(3, 6), Vector2i(12, 6), Vector2i(14, 8), Vector2i(8, 10), Vector2i(8, 11)]:
		reserved[cell] = true
	return reserved


func _sign(p: Pintor, label: String, city_name: String, object_id: String) -> void:
	var node: Node2D = (load("res://src/overworld/sign/sign.tscn") as PackedScene).instantiate()
	node.name = "PlacaSala"
	node.position = Grid.to_world(Vector2i(14, 8))
	node.set(&"only_from_below", false)
	node.set(&"lines", PackedStringArray([_blurb(object_id, label, city_name), "La salida está al sur."]))
	p.entities.add_child(node)


func _heading(p: Pintor, title: String) -> void:
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(16, 4)
	label.size = Vector2(480, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = title.to_upper()
	label.add_theme_font_override("font", load("res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("303048"))
	label.add_theme_color_override("font_shadow_color", Color("fff4d8"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	p.root.add_child(label)


func _data(id: String, display: String, zone: StringName) -> MapData:
	var d := MapData.new()
	d.id = StringName(id)
	d.display_name = display
	d.zone_id = zone if zone != &"" else StringName(id.get_slice("/", 0))
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	return d


func _lines(theme: String, label: String, city_name: String, place: String) -> PackedStringArray:
	var openers: PackedStringArray = _openers(theme, label, city_name, place)
	var details := _details(theme)
	var a := _randi() % details.size()
	var b := _randi() % details.size()
	var c := _randi() % openers.size()
	var d := (_randi() + 1) % openers.size()
	return PackedStringArray([openers[c], details[a], openers[d], details[b]])


func _openers(theme: String, label: String, city_name: String, place: String) -> PackedStringArray:
	var where := "%s, en %s. %s." % [label, city_name, place]
	match theme:
		"home":
			return PackedStringArray([
				"Pasa. " + where,
				"Esta es la casa. " + where,
				"Cierra al salir. " + where,
			])
		"shop":
			return PackedStringArray([
				"Mira sin prisa. La caja de la ciudad está en el Mercadona. " + where,
				"Hoy no paso venta aquí. " + where,
			])
		"nave":
			return PackedStringArray([
				"Baja la voz. " + where,
				"La nave grande sigue al fondo. " + where,
			])
		"gym":
			return PackedStringArray([
				"La pista está libre. El reto de la medalla no se celebra en esta sala. " + where,
				"Puedes entrenar el paso, no el combate. " + where,
			])
		"transit":
			return PackedStringArray([
				"El andén no sale de esta sala. " + where,
				"Se espera aquí. " + where,
			])
		"arena":
			return PackedStringArray([
				"Hoy no hay función. " + where,
				"El graderío está al otro lado. " + where,
			])
		"civic":
			return PackedStringArray([
				"La ventanilla de hoy es esta. " + where,
				"Los papeles se quedan en la mesa. " + where,
			])
		"culture":
			return PackedStringArray([
				"Las salas de dentro guardan lo que se enseña. " + where,
				"Esto es el vestíbulo. " + where,
			])
		_:
			return PackedStringArray([
				where,
				"Se puede cruzar hasta la salida. " + where,
			])


func _details(theme: String) -> PackedStringArray:
	match theme:
		"home":
			return PackedStringArray([
				"La mesa está arrimada para que se pueda pasar.",
				"El cuadro es de la feria del año pasado.",
				"Por la ventana se oye la calle y poco más.",
				"El suelo se friega los domingos.",
				"El vecino de arriba arrastra sillas por la noche.",
				"Dejé la planta junto a la pared para no tropezar.",
			])
		"shop":
			return PackedStringArray([
				"Las estanterías son de muestra: el precio está en el Mercadona.",
				"El género de esta semana ya está colocado.",
				"No toques el mostrador por detrás.",
				"Si buscas Poké Balls, pregunta en la caja de la ciudad.",
			])
		"nave":
			return PackedStringArray([
				"Los bancos están para sentarse, no para moverlos.",
				"Huele a piedra y a cera.",
				"La luz entra por lo alto.",
				"Fuera se oye la plaza.",
			])
		"gym":
			return PackedStringArray([
				"Las colchonetas están secas.",
				"No hay medalla en esta habitación.",
				"El vestuario es esta misma sala.",
			])
		"transit":
			return PackedStringArray([
				"El panel de horarios está apagado.",
				"El siguiente paso es volver a la calle.",
				"Hay sitio para esperar sentado.",
			])
		_:
			return PackedStringArray([
				"Se puede rodear los muebles sin atascarse.",
				"La placa de la pared dice el nombre del sitio.",
				"Si te pierdes, el hueco del sur devuelve a la calle.",
				"Esta sala no es igual que la de la puerta de al lado.",
			])


func _blurb(object_id: String, label: String, city_name: String) -> String:
	var notes := {
		"sagrada_familia": "Sagrada Familia. Las torres se ven desde media ciudad. Esto es el zaguán.",
		"camp_nou": "Camp Nou. El campo está al otro lado. Hoy no hay partido.",
		"museo_prado": "Museo del Prado. Los cuadros siguen en las salas de dentro. Esto es el vestíbulo.",
		"palacio_real": "Palacio Real. El patio queda fuera. Esta es la antesala.",
		"estacion_atocha": "Atocha. Los trenes salen del vestíbulo grande. Aquí se espera.",
		"boca_metro": "Metro. El andén no está abierto. Se espera aquí arriba.",
		"catedral_sevilla": "Catedral de Sevilla. La Giralda queda a la espalda. Esta sala huele a piedra.",
		"catedral_barcelona": "Catedral de Barcelona. El claustro queda dentro. Esto es la antesala.",
		"catedral_malaga": "Catedral de Málaga. La nave principal sigue al fondo.",
		"catedral_palma": "Catedral de Palma. El mar no se ve desde esta sala.",
		"catedral_valladolid": "Catedral de Valladolid. Esta sala sí tiene techo.",
		"catedral_ibiza": "Catedral de Ibiza. Dalt Vila queda arriba. Esta sala da al puerto.",
		"catedral_santa_ana": "Santa Ana. Vegueta está a la puerta. Dentro se está fresco.",
		"catedral_almudena": "La Almudena da al palacio. Esta es la capilla de la entrada.",
		"basilica_pilar": "El Pilar. El Ebro queda al norte. Esta capilla lateral está en calma.",
		"la_seo": "La Seo mira al Pilar. Esta es una sala lateral.",
		"micalet_catedral": "El Miguelete se sube por otra puerta. Aquí se espera.",
		"san_pablo_valladolid": "San Pablo. La fachada es de escultura. Dentro, esta sala es de paso.",
		"ayuntamiento_valladolid": "Ayuntamiento. La plaza queda a la espalda. Aquí se espera turno.",
		"casa_correos": "Casa de Correos. El reloj de la Puerta del Sol está en la fachada.",
		"edificio_metropolis": "Metrópolis. La cúpula queda arriba. Esta planta es un vestíbulo.",
		"edificio_carrion": "Edificio Carrión. La Gran Vía queda abajo. Esta planta es una oficina.",
		"palacio_cibeles": "Cibeles. La torre del reloj queda arriba. Esta sala es de paso.",
		"palacio_cristal": "Palacio de Cristal. El Retiro se ve por los cristales.",
		"palacio_infantado": "Palacio del Infantado. Esta sala da al patio.",
		"mercado_central": "Mercado Central. Los puestos abren a la nave. Aquí se guarda el género.",
		"mercado_san_miguel": "Mercado de San Miguel. La nave de hierro está al otro lado de esta entrada.",
		"boqueria": "La Boquería. La Rambla queda a la espalda. Los puestos están cubiertos.",
		"universidad_alcala": "Universidad de Alcalá. El patio queda al otro lado. Esta aula está vacía.",
		"monasterio_escorial": "El Escorial. El patio de los Reyes queda fuera. Esta sala es de paso.",
		"monasterio_montserrat": "Montserrat. La montaña queda fuera. Esta sala es de acogida.",
		"templo_debod": "Templo de Debod. El templo está al aire libre. Esta es la sala de la entrada.",
		"castillo_bellver": "Bellver. La planta es redonda. Esta habitación da al patio.",
		"castillo_cuellar": "Castillo de Cuéllar. Esta sala da al patio de armas.",
		"maestranza": "La Maestranza. El ruedo está al fondo. Aquí se espera a la sombra.",
		"teatro_real": "Teatro Real. El patio de butacas no se ve desde el foyer.",
		"congreso": "Congreso. El hemiciclo no se visita hoy. Esta es una antesala.",
		"casa_batllo": "Casa Batlló. La fachada da a la calle. Esta sala se queda en la planta baja.",
		"la_pedrera": "La Pedrera. Los patios de luz quedan en el centro.",
		"lonja_seda": "La Lonja. El salón de contrataciones sigue al fondo. Esto es el zaguán.",
		"dolmen_antequera": "Dolmen de Antequera. Esta cámara es la de la entrada.",
		"molino_mancha": "Molino. Las aspas quedan fuera. Dentro está la estancia.",
		"ermita_virgen_del_rio": "Ermita. El río queda cerca. La sala es pequeña.",
		"magdalena_getafe": "La Magdalena da a la plaza de Getafe. Esta es la nave de la entrada.",
		"san_salvador_leganes": "San Salvador. La plaza queda fuera.",
		"asuncion_mostoles": "La Asunción está en el centro de Móstoles. Esta sala es la de la puerta.",
		"iglesia_san_miguel": "San Miguel. La nave es pequeña y fresca.",
		"club_ibiza": "El puerto queda al otro lado. Aquí se espera a la sombra.",
		"casa_ibicenca": "Casa ibicenca. El porche blanco da a la calle. Dentro se está fresco.",
		"casa_panaderia": "Panadería. El horno está al fondo. Hoy el género no se vende en esta sala.",
		"faro": "Faro. La linterna está arriba. Esta sala es la de la base.",
	}
	if notes.has(object_id):
		return str(notes[object_id])
	return "%s · %s." % [label, city_name]


func _label(object_id: String) -> String:
	var names := {
		"casa_roja": "Casa roja", "casa_roja_chimenea": "Casa de la chimenea", "casa_roja_pequena": "Casa roja pequeña",
		"casa_azul": "Casa azul", "casa_azul_pequena": "Casa azul pequeña", "casa_naranja": "Casa naranja",
		"casa_rosa": "Casa rosa", "casa_gris": "Casa gris", "casa_madera": "Casa de madera",
		"casa_paja": "Casa de paja", "casa_paja_2": "Casa de paja", "casa_teja": "Casa de teja",
		"casa_tejado_azul": "Casa de tejado azul", "casa_tejado_azul_2": "Casa de tejado azul",
		"casa_tejado_rojo": "Casa de tejado rojo", "casa_grande": "Casa grande", "casa_pequena": "Casa pequeña",
		"casa_escalera": "Casa de la escalera", "casa_granero": "Granero", "casa_dos_aguas": "Casa de dos aguas",
		"casa_ibicenca": "Casa ibicenca", "casa_panaderia": "Panadería", "casa_batllo": "Casa Batlló",
		"bloque_pisos": "Portal", "bloque_verde": "Portal verde", "bloque_verde_2": "Portal verde",
		"atico_jardin": "Ático", "cabana": "Cabaña", "tienda_verde": "Tienda verde", "tienda_verde_2": "Tienda verde",
		"tienda_azul": "Tienda azul", "tienda_naranja": "Tienda naranja", "tienda_morada": "Tienda morada",
		"tienda_flores": "Floristería", "puesto_mercado": "Puesto", "grandes_almacenes": "Grandes almacenes",
		"gimnasio_madera": "Gimnasio", "oficinas_azules": "Oficinas", "oficinas_verdes": "Oficinas",
		"centro_pokemon": "Centro Pokémon", "centro_pokemon_grande": "Centro Pokémon",
		"boca_metro": "Metro", "faro": "Faro", "torre_socorrista": "Torre de socorro",
		"torre_octogonal": "Torre", "velero": "Velero", "arco": "Arco", "teatro": "Teatro",
		"barraca": "Barraca", "palau_ducal_gandia": "Palau Ducal dels Borja", "iglesia_altea": "Iglesia de Altea",
		"rascacielos_benidorm": "Apartamentos", "intempo": "Intempo", "castillo_santa_barbara": "Castillo de Santa Bárbara",
		"concatedral_san_nicolas": "Concatedral de San Nicolás", "casa_carbonell": "Casa Carbonell",
		"basilica_elche": "Basílica de Santa María", "catedral_murcia": "Catedral de Murcia",
	}
	if names.has(object_id):
		return str(names[object_id])
	return object_id.replace("_", " ").capitalize()


func _theme(object_id: String) -> String:
	var rules: Array = [
		["centro_pokemon", "clinic"], ["catedral", "nave"], ["basilica", "nave"], ["iglesia", "nave"],
		["monasterio", "nave"], ["ermita", "nave"], ["micalet", "nave"], ["la_seo", "nave"],
		["san_pablo", "nave"], ["san_salvador", "nave"], ["magdalena", "nave"], ["asuncion", "nave"],
		["sagrada_familia", "nave"], ["templo", "nave"], ["gimnasio", "gym"], ["tienda", "shop"],
		["mercado", "shop"], ["boqueria", "shop"], ["puesto", "shop"], ["panaderia", "shop"],
		["grandes_almacenes", "shop"], ["casa_correos", "civic"], ["casa_batllo", "culture"],
		["casa_carbonell", "culture"], ["barraca", "home"], ["rascacielos", "home"], ["intempo", "home"], ["palau", "civic"],
		["casa_", "home"], ["cabana", "home"], ["bloque", "home"],
		["atico", "home"], ["granero", "home"], ["palacio", "civic"], ["ayuntamiento", "civic"],
		["congreso", "civic"], ["universidad", "civic"], ["oficinas", "civic"], ["edificio", "civic"],
		["museo", "culture"], ["teatro", "culture"], ["estacion", "transit"], ["boca_metro", "transit"],
		["camp_nou", "arena"], ["maestranza", "arena"], ["club", "arena"], ["castillo", "monument"],
		["faro", "monument"], ["torre", "monument"], ["molino", "monument"], ["dolmen", "monument"],
		["arco", "monument"], ["velero", "monument"],
	]
	for rule: Array in rules:
		if object_id.find(String(rule[0])) >= 0:
			return String(rule[1])
	return "monument"


func _role(theme: String, first: bool) -> String:
	match theme:
		"shop":
			return "Dependiente" if first else "Cliente"
		"nave":
			return "Custodio" if first else "Visitante"
		"gym":
			return "Monitor" if first else "Alumno"
		"transit":
			return "Taquillero" if first else "Viajero"
		"civic":
			return "Ordenanza" if first else "Vecino"
		"culture":
			return "Acomodador" if first else "Visitante"
		"arena":
			return "Taquillero" if first else "Aficionado"
		"home":
			return "Vecino" if first else "Vecina"
		_:
			return "Guía" if first else "Visitante"


func _sheets(theme: String, city: String, map_id: String) -> PackedStringArray:
	var pair := PackedStringArray(["npc_man", "npc_woman"])
	match theme:
		"shop":
			pair = PackedStringArray(["clerk", "npc_lass"])
		"nave":
			pair = PackedStringArray(["npc_old_man", "npc_old_woman"])
		"gym":
			pair = PackedStringArray(["crossfitero", "estudianteinge"])
		"transit":
			pair = PackedStringArray(["npc_man", "npc_youngster"])
		"culture":
			pair = PackedStringArray(["npc_lass", "npc_old_man"])
		"arena":
			pair = PackedStringArray(["npc_boy", "npc_man"])
		"monument":
			pair = PackedStringArray(["arqueologo", "npc_old_woman"])
		"civic":
			pair = PackedStringArray(["npc_man", "npc_woman"])
		_:
			pair = PackedStringArray(["npc_woman", "npc_old_man"])
	if city == "sevilla" and theme == "home":
		pair[1] = "flamenca"
	elif city == "sevilla" and theme == "nave":
		pair[0] = "costalero"
	elif theme == "arena" or theme == "shop":
		if map_id.find("malvarrosa") >= 0 or city == "playa_del_ingles" or city == "ibiza":
			pair[1] = "npc_fisherman"
	elif map_id.find("retiro") >= 0 or map_id.find("maria_luisa") >= 0 or map_id.find("turia") >= 0:
		pair[0] = "guarda_parque"
	return pair


func _city_name(city: String) -> String:
	if _locales.has(city) and (_locales[city] as Dictionary).has("name"):
		return str((_locales[city] as Dictionary)["name"])
	if city == "pueblo_inicial":
		return "Pueblo"
	return city.replace("_", " ").capitalize()


func _zone_slug(map_id: String) -> String:
	var parts := map_id.split("/")
	if parts.size() < 2:
		return "ciudad"
	return parts[parts.size() - 1].replace("exterior", "calle")


func _hash(text: String) -> int:
	var h := 2166136261
	for i: int in text.length():
		h = int((h ^ text.unicode_at(i)) * 16777619) & 0x7fffffff
	return maxi(1, h)


func _randi() -> int:
	_state = int((_state * 1103515245 + 12345) & 0x7fffffff)
	return _state


func _free_spot(blocked: Dictionary) -> Vector2i:
	for spot: Vector2i in [Vector2i(4, 6), Vector2i(11, 6), Vector2i(2, 6), Vector2i(6, 9), Vector2i(10, 9), Vector2i(4, 9)]:
		if blocked.has(spot):
			continue
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next: Vector2i = spot + step
			if next.x < 1 or next.x > 14 or next.y < 2 or next.y > 10:
				continue
			if not blocked.has(next):
				return spot
	return Vector2i(-1, -1)


func _has_plaque(interior: String) -> bool:
	var path := "res://maps/%s.tscn" % interior
	if not ResourceLoader.exists(path):
		return false
	var text := FileAccess.get_file_as_string(path)
	return text.find("PlacaSala") >= 0 or text.find("PlacaCiudad") >= 0


func _is_generic_house(interior: String) -> bool:
	var path := "res://maps/%s.tscn" % interior
	if not ResourceLoader.exists(path):
		return false
	if not interior.get_file().begins_with("casa_"):
		return false
	return FileAccess.get_file_as_string(path).find("display_name = \"Casa ·") >= 0


func _object_at(objects: TileMapLayer, cell: Vector2i) -> String:
	var source := objects.get_cell_source_id(cell)
	if source < 0:
		return ""
	return str(_by_cell.get("%s:%s" % [source, objects.get_cell_atlas_coords(cell)], ""))


func _warp_at(root: Node, tile: Vector2i) -> Warp:
	var warps := root.get_node_or_null(^"Warps")
	if warps == null:
		return null
	for child: Node in warps.get_children():
		if child is Warp and (child as Warp).contains_tile(tile):
			return child as Warp
	return null


func _skip_door(map_id: String, door: Vector2i) -> bool:
	if not SKIP_DOORS.has(map_id):
		return false
	for blocked: Vector2i in SKIP_DOORS[map_id]:
		if blocked == door:
			return true
	return false


func _strip_salas(root: Node) -> bool:
	var removed := false
	var warps := root.get_node(^"Warps")
	var doomed: Array[Node] = []
	for child: Node in warps.get_children():
		if not str(child.name).begins_with("Sala"):
			continue
		var target := str(child.get("target_map"))
		if target.find("/sala_") < 0:
			continue
		var file := ProjectSettings.globalize_path("res://maps/%s.tscn" % target)
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)
		doomed.append(child)
		removed = true
	for child: Node in doomed:
		warps.remove_child(child)
		child.free()
	doomed.clear()
	var spawns := root.get_node(^"Spawns")
	for child: Node in spawns.get_children():
		if str(child.name).begins_with("from_sala_"):
			doomed.append(child)
			removed = true
	for child: Node in doomed:
		spawns.remove_child(child)
		child.free()
	return removed


func _link(root: Node, door: Vector2i, warp_name: String, interior: String, spawn_name: String) -> void:
	var warps := root.get_node(^"Warps")
	if warps.get_node_or_null(NodePath(warp_name)) == null and _warp_at(root, door) == null:
		var warp := Node2D.new()
		warp.set_script(load("res://src/overworld/warp/warp.gd"))
		warp.name = warp_name
		warp.position = Grid.to_world(door)
		warp.set(&"target_map", StringName(interior))
		warp.set(&"target_spawn", &"default")
		warp.set(&"arrival_facing", Warp.Facing.UP)
		warp.set(&"sound", &"door")
		warps.add_child(warp)
		warp.owner = root
	var spawns := root.get_node(^"Spawns")
	if spawns.get_node_or_null(NodePath(spawn_name)) == null:
		var marker := Marker2D.new()
		marker.name = spawn_name
		marker.position = Grid.to_world(door + Vector2i.DOWN)
		spawns.add_child(marker)
		marker.owner = root


func _map(dirty: Dictionary, map_id: String) -> Node:
	if dirty.has(map_id):
		return dirty[map_id]
	var path := "res://maps/%s.tscn" % map_id
	if not ResourceLoader.exists(path):
		return null
	var root: Node = (load(path) as PackedScene).instantiate()
	dirty[map_id] = root
	return root


func _city_maps() -> PackedStringArray:
	var out := PackedStringArray()
	_collect("res://maps", out)
	return out


func _collect(dir_path: String, out: PackedStringArray) -> void:
	var folder := DirAccess.open(dir_path)
	if folder == null:
		return
	for file_name: String in folder.get_files():
		if not file_name.ends_with(".tscn"):
			continue
		var path := dir_path.path_join(file_name)
		var id := path.trim_prefix("res://maps/")
		if (id.begins_with("ruta_") and not _routes) or id.begins_with("maritima") or id.begins_with("test/") or id.begins_with("muestras/"):
			continue
		out.append(path)
	for sub: String in folder.get_directories():
		if sub.begins_with("_") or sub == "test" or sub == "muestras" or (sub.begins_with("ruta_") and not _routes) or sub == "maritima_1":
			continue
		_collect(dir_path.path_join(sub), out)
