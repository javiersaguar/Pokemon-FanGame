extends SceneTree
## Detalla escenas existentes con piezas del catálogo; mantiene sus entidades y puertas.
## Uso: -- mapa... (ids sin res://maps/ ni .tscn).
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const PARKS := ["madrid/retiro", "sevilla/maria_luisa", "sevilla/rio", "valencia/turia",
	"las_palmas/canteras", "playa_del_ingles/exterior"]
const COAST := ["alicante", "ibiza", "las_palmas", "malaga", "murcia", "palma", "playa_del_ingles", "valencia"]
var catalog := {}
var by_tile := {}
var ground: TileMapLayer
var objects: TileMapLayer
var bounds: Rect2i
var occupied := {}
var protected := {}
var streets := {}
var free := {}
var graph: AStarGrid2D
var start: Vector2i
var report := {}

func _initialize() -> void:
	await process_frame
	var report_path := "res://docs/arte/comparativas/tejido_urbano_2026-10-14/detalle.json"
	if FileAccess.file_exists(report_path):
		report = JsonFile.read_dict(report_path)
	catalog = ExteriorTiles.objects()
	for id: StringName in catalog:
		var o: Dictionary = catalog[id]
		by_tile[Vector3i(o.source, o.coords.x, o.coords.y)] = id
	for mid: String in OS.get_cmdline_user_args():
		await _complete(mid)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/arte/comparativas/tejido_urbano_2026-10-14"))
	var file := FileAccess.open("res://docs/arte/comparativas/tejido_urbano_2026-10-14/detalle.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, " ", true) + "\n")
	file.close()
	quit.call_deferred()

func _complete(mid: String) -> void:
	var path := "res://maps/%s.tscn" % mid
	var map: Node2D = (load(path) as PackedScene).instantiate()
	if map.has_meta("detalle_urbano"):
		print(mid, ": ya detallado")
		map.free()
		return
	ground = map.get_node("Ground")
	objects = map.get_node("Entities/Objects")
	bounds = ground.get_used_rect()
	occupied.clear()
	protected.clear()
	streets.clear()
	free.clear()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	for at: Vector2i in Pintor.cells(bounds):
		if ground.get_cell_source_id(at) < 0:
			continue
		var query := PhysicsPointQueryParameters2D.new()
		query.position = map.to_global(Grid.to_world(at))
		query.collision_mask = 1 | 2 | 8
		if space.intersect_point(query, 1).is_empty():
			free[at] = true
	for node: Node in map.find_children("*", "TileMapLayer", true, false):
		if node == ground:
			continue
		var layer := node as TileMapLayer
		for at: Vector2i in layer.get_used_cells():
			var id := _object_id(layer, at)
			var size: Vector2i = catalog[id].size if id != &"" else Vector2i.ONE
			_occupy(Rect2i(at - Vector2i(0, size.y - 1), size))
	var hot: Array[Vector2i] = []
	for section: String in ["Warps", "Spawns", "Entities"]:
		for node: Node in map.get_node(section).get_children():
			if node is Node2D and not node is TileMapLayer:
				var at := Grid.to_tile(node.position)
				_reserve(at, 2)
				if section != "Entities":
					hot.append(at)
	for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
		if entry.get("mapa", "") == mid and entry.has("casilla"):
			_reserve(Vector2i(entry.casilla[0], entry.casilla[1]), 3)
	var data := map.get("data") as MapData
	for connection: MapConnection in data.connections:
		var pos := bounds.position
		var end := bounds.end - Vector2i.ONE
		var a := connection.span.x
		var b := connection.span.y
		if connection.span == Vector2i.ZERO:
			a = pos.x if connection.edge in ["north", "south"] else pos.y
			b = end.x + 1 if connection.edge in ["north", "south"] else end.y + 1
		for value: int in range(a, b):
			var at: Vector2i
			match connection.edge:
				"north": at = Vector2i(value, pos.y)
				"east": at = Vector2i(end.x, value)
				"south": at = Vector2i(value, end.y)
				"west": at = Vector2i(pos.x, value)
			_reserve(at, 2)
			hot.append(at)
	start = Grid.to_tile(map.get_node("Spawns/default").position)
	graph = AStarGrid2D.new()
	graph.region = bounds
	graph.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	graph.update()
	streets[start] = true
	for at: Vector2i in Pintor.cells(bounds):
		graph.set_point_solid(at, not free.has(at))
		if free.has(at):
			graph.set_point_weight_scale(at, 1.0 if _terrain(at) in ["stone", "path"] else 2.0)
	for at: Vector2i in hot:
		_connect(at)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(mid)
	var coastal := mid.get_slice("/", 0) in COAST
	var houses := 0
	var props := 0
	var people := 0
	var house_limit := 0 if mid in PARKS else (6 if bounds.size.x * bounds.size.y >= 3500 else 3)
	var palette: Array[StringName] = [&"casa_gris", &"casa_roja_pequena", &"casa_teja", &"bloque_pisos"]
	if mid.begins_with("pozuelo/"):
		palette = [&"casa_grande", &"casa_rosa", &"casa_tejado_azul_2"]
	elif mid.begins_with("orcasitas/"):
		palette = [&"bloque_pisos", &"casa_gris"]
	for pass_index: int in 3:
		if houses >= house_limit:
			break
		for y: int in range(bounds.position.y + 7, bounds.end.y - 3, 2):
			for x: int in range(bounds.position.x + 2, bounds.end.x - 6, 2):
				if houses >= house_limit:
					break
				var id: StringName = palette[(houses + pass_index) % palette.size()]
				var at := Vector2i(x, y)
				if not _can_place(id, at, true):
					continue
				var o: Dictionary = catalog[id]
				var door: Vector2i = at + o.door
				if graph.get_id_path(start, door + Vector2i.DOWN).is_empty():
					continue
				objects.set_cell(at, o.source, o.coords)
				_occupy(_rect(id, at))
				for cell: Vector2i in Pintor.cells(_rect(id, at)):
					if cell != door:
						graph.set_point_solid(cell)
				_connect(door)
				houses += 1
	# Mobiliario y arbolado a ambos lados de los paseos, separados de las entradas.
	var prop_palette: Array[StringName] = [&"farola_verde", &"arbol_redondo", &"banco", &"jardinera", &"cerezo"]
	if coastal:
		prop_palette = [&"farola_roja", &"palmera", &"banco", &"jardinera", &"arbol_redondo"]
	var candidates: Array = free.keys()
	# Orden determinista y espaciado: la semilla no depende del estado de la partida.
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var ra := _rank(a, rng.seed)
		var rb := _rank(b, rng.seed)
		return ra < rb or (ra == rb and (a.y < b.y or (a.y == b.y and a.x < b.x))))
	for candidate: Vector2i in candidates:
		if props >= clampi(bounds.size.x * bounds.size.y / 110, 12, 48):
			break
		var id: StringName = prop_palette[_rank(candidate, rng.seed) % prop_palette.size()]
		if not _can_place(id, candidate, false) or not _near_street(candidate, 5):
			continue
		var o: Dictionary = catalog[id]
		objects.set_cell(candidate, o.source, o.coords)
		_occupy(_rect(id, candidate))
		props += 1
	# Vecinos en zonas anchas: nunca en la línea central ni frente a una puerta.
	for at: Vector2i in candidates:
		if people >= (4 if house_limit >= 6 else 2):
			break
		if occupied.has(at) or protected.has(at) or not _near_street(at, 4):
			continue
		if _terrain(at) not in ["grass", "stone", "path"]:
			continue
		if DIRS.filter(func(d: Vector2i) -> bool: return free.has(at + d) and not occupied.has(at + d)).size() < 4:
			continue
		var npc: Node2D = (load(Pintor.NPC_SCENE) as PackedScene).instantiate()
		npc.name = "VecinoPaseo%d" % people
		npc.position = Grid.to_world(at)
		npc.set("sprite_sheet", load("res://assets/sprites/characters/%s.png" % ["npc_man", "npc_woman", "npc_boy", "npc_girl"][people]))
		npc.set("lines", PackedStringArray(["Las puertas dan a casas y locales. Puedes entrar a mirar."] if people % 2 == 0 else ["Si buscas la salida, sigue el paseo."]))
		map.get_node("Entities").add_child(npc)
		npc.owner = map
		_reserve(at, 2)
		people += 1
	_draw_streets(mid)
	report[mid] = {"casas": houses, "adornos": props, "vecinos": people, "paseo": streets.size()}
	map.set_meta("detalle_urbano", report[mid])
	root.remove_child(map)
	var packed := PackedScene.new()
	var error := packed.pack(map)
	if error == OK:
		error = ResourceSaver.save(packed, path)
	assert(error == OK, "%s: %s" % [mid, error_string(error)])
	map.free()
	print(mid, ": ", report[mid])
	await process_frame

func _rank(at: Vector2i, seed_value: int) -> int:
	return posmod(hash("%s:%s" % [at, seed_value]), 1000000)

func _object_id(layer: TileMapLayer, at: Vector2i) -> StringName:
	var coords := layer.get_cell_atlas_coords(at)
	return by_tile.get(Vector3i(layer.get_cell_source_id(at), coords.x, coords.y), &"")

func _rect(id: StringName, at: Vector2i) -> Rect2i:
	var size: Vector2i = catalog[id].size
	return Rect2i(at - Vector2i(0, size.y - 1), size)

func _occupy(rect: Rect2i) -> void:
	for at: Vector2i in Pintor.cells(rect):
		occupied[at] = true

func _reserve(at: Vector2i, radius: int) -> void:
	for cell: Vector2i in Pintor.cells(Rect2i(at - Vector2i(radius, radius), Vector2i.ONE * (radius * 2 + 1))):
		protected[cell] = true

func _terrain(at: Vector2i) -> String:
	var tile := ground.get_cell_tile_data(at)
	return str(tile.get_custom_data("terrain")) if tile != null else ""

func _can_place(id: StringName, at: Vector2i, house: bool) -> bool:
	var rect := _rect(id, at).grow(1 if house else 0)
	if not bounds.encloses(rect):
		return false
	for cell: Vector2i in Pintor.cells(rect):
		if not free.has(cell) or occupied.has(cell) or protected.has(cell):
			return false
		if _terrain(cell) not in ["grass", "stone", "path"]:
			return false
	if house:
		var door: Vector2i = at + catalog[id].door
		if not free.has(door + Vector2i.DOWN * 2):
			return false
	return true

func _connect(target: Vector2i) -> void:
	if not bounds.has_point(target):
		return
	var destination := target
	if not free.has(destination):
		for d: Vector2i in DIRS:
			if free.has(target + d):
				destination = target + d
				break
	if not free.has(start) or not free.has(destination):
		return
	var origins: Array = streets.keys()
	origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.distance_squared_to(destination) < b.distance_squared_to(destination))
	var path: Array[Vector2i] = []
	for origin: Vector2i in origins.slice(0, 8):
		var route := graph.get_id_path(origin, destination)
		if not route.is_empty() and (path.is_empty() or route.size() < path.size()):
			path = route
	for at: Vector2i in path:
		streets[at] = true
		_reserve(at, 1)

func _near_street(at: Vector2i, distance: int) -> bool:
	for d: Vector2i in DIRS:
		for n: int in range(1, distance + 1):
			if streets.has(at + d * n):
				return true
	return false

func _draw_streets(mid: String) -> void:
	var rural := mid.begins_with("pozuelo/")
	for at: Vector2i in streets:
		if _terrain(at) not in ["grass", "stone", "path"]:
			continue
		if rural:
			var origin := ExteriorTiles.PAVING_STONE
			var left := streets.has(at + Vector2i.LEFT)
			var right := streets.has(at + Vector2i.RIGHT)
			var up := streets.has(at + Vector2i.UP)
			var down := streets.has(at + Vector2i.DOWN)
			ground.set_cell(at, ExteriorTiles.SRC_GEN4, origin + Vector2i(1 if left == right else (0 if not left else 2), 1 if up == down else (0 if not up else 2)))
		else:
			ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.COBBLE_PINK + Vector2i(posmod(at.x, 4), posmod(at.y, 2)))

