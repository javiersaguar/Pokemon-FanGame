class_name Vestidor
extends RefCounted
@warning_ignore_start("integer_division")
## Viste un exterior que ya está pintado, sin repintarlo: bosque, relieve, agua, caminos, hierba
## alta, flores, árboles, vallas, vecinos, entrenadores y objetos. Conserva las puertas, las
## pasarelas, las apariciones, las conexiones de borde y los personajes colocados por datos.
## Lo usa maps/_tools/vestir_exterior.gd con una receta por mapa (maps/_pintura/vestir/*.gd).
## Solo coloca casillas y objetos del TileSet (arte de los packs y piezas a mano); no dibuja nada.

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3
## Bosque de pinos (verde y nevado): casillas del atlas gen4 que pinta Pintor.build_forest().
const GREEN_FOREST := Rect2i(2, 0, 4, 6)
const SNOW_FOREST := Rect2i(1, 33, 4, 6)
const GREEN_OVERHANG := Rect2i(1, 1, 1, 4)
const SNOW_OVERHANG := Rect2i(0, 34, 1, 4)
const POND_RECT := Rect2i(5, 6, 3, 3)
const ITEM_SCENE := "res://src/overworld/item_ball/item_ball.tscn"
## Obstáculos de campo (FieldObstacle) por acción, escollos (2×2, chocan) y agua de corriente.
const OBSTACLES := {
	"cut": "res://src/overworld/campo/corte.tscn",
	"rock_smash": "res://src/overworld/campo/golpe_roca.tscn",
	"strength": "res://src/overworld/campo/fuerza.tscn",
}
const REEF_SCENE := "res://src/overworld/campo/escollo.tscn"
## Atajos: tronco (paso de norte a sur, 2 de ancho) y cancela (paso de oeste a este, 2 de alto).
const SHORTCUT_LOG := "res://src/overworld/campo/atajo_tronco.tscn"
const SHORTCUT_GATE := "res://src/overworld/campo/atajo_valla.tscn"
const CURRENT_SCRIPT := "res://src/overworld/surf_current.gd"
const CURRENT_FRAMES := "res://src/overworld/campo/corriente_frames.tres"

var mid := ""
var map: Node2D
var ground: TileMapLayer
var decor: TileMapLayer
var objects: TileMapLayer
var above: TileMapLayer
var entities: Node2D
var bounds: Rect2i
var catalog := {}
var by_tile := {}
var rng := RandomNumberGenerator.new()
## Casillas libres al empezar o tras refrescar (consulta de física de los personajes).
var free := {}
## Casillas que nada puede tapar: puertas, pasarelas, apariciones, bordes, personajes y su vista.
var protected := {}
## Casillas que tapa el dibujo de algún objeto (copas, tejados, cepas...): ahí no se planta nada.
var covered := {}
## Puntos a los que hay que seguir llegando (casilla de cada cosa importante).
var anchors := {}
var forest := {}
var water := {}
var paving := {}
var _forest_dirty := false
var _water_dirty := {}
var _paving_dirty := {}
## Entidades nuevas: se añaden al final, con el mapa fuera del árbol (sus scripts usan autoloads).
var pending_entities: Array[Node2D] = []
## Casillas ocupadas por entidades nuevas (chocan como las de siempre).
var pending_cells := {}
var log_lines: PackedStringArray = []
## Recetas de mar: con Surf el agua cuenta como libre (la receta pide `var con_surf := true`).
var surf := false
## Casillas de los obstáculos de campo (nuevos y de antes): detrás solo puede quedar lo opcional.
var obstacle_cells: Array[Vector2i] = []
## Casillas de los atajos nuevos (abiertos, se comprueba que siga habiendo que pisar hierba).
var shortcut_cells: Array[Vector2i] = []
## Escollos y corrientes nuevos: van al nodo «Mar», debajo de las entidades.
var pending_sea: Array[Node2D] = []


func setup(the_map: Node2D, map_id: String) -> void:
	map = the_map
	mid = map_id
	rng.seed = hash(map_id)
	ground = map.get_node("Ground")
	decor = map.get_node("Decor")
	objects = map.get_node("Entities/Objects")
	above = map.get_node("Above")
	entities = map.get_node("Entities")
	bounds = ground.get_used_rect()
	catalog = ExteriorTiles.objects()
	for id: StringName in catalog:
		var o: Dictionary = catalog[id]
		by_tile[Vector3i(o.source, o.coords.x, o.coords.y)] = id
	for cell: Vector2i in decor.get_used_cells():
		if decor.get_cell_source_id(cell) != ExteriorTiles.SRC_GEN4:
			continue
		var c := decor.get_cell_atlas_coords(cell)
		if GREEN_FOREST.has_point(c):
			forest[cell] = ExteriorTiles.FOREST_ORIGIN
		elif SNOW_FOREST.has_point(c):
			forest[cell] = ExteriorTiles.SNOW_FOREST_ORIGIN
	for node: Node in entities.get_children():
		if node is Node2D and node.scene_file_path in OBSTACLES.values():
			obstacle_cells.append(Grid.to_tile((node as Node2D).position))
	for cell: Vector2i in ground.get_used_cells():
		if ground.get_cell_source_id(cell) == ExteriorTiles.SRC_GEN4 and POND_RECT.has_point(ground.get_cell_atlas_coords(cell)):
			water[cell] = true
		elif ground.get_cell_source_id(cell) == ExteriorTiles.SRC_GEN4 and Rect2i(ExteriorTiles.PAVING_STONE, Vector2i(3, 3)).has_point(ground.get_cell_atlas_coords(cell)):
			paving[cell] = true


## Recalcula las casillas libres y lo protegido. El mapa tiene que estar en el árbol y con la
## física al día (vestir_exterior.gd espera dos cuadros de física antes de llamar).
func scan(space: PhysicsDirectSpaceState2D) -> void:
	free.clear()
	for at: Vector2i in Pintor.cells(bounds):
		if ground.get_cell_source_id(at) < 0 or pending_cells.has(at):
			continue
		var q := PhysicsPointQueryParameters2D.new()
		q.position = map.to_global(Grid.to_world(at))
		q.collision_mask = 1 | 2 if surf else 1 | 2 | 8
		if space.intersect_point(q, 1).is_empty():
			free[at] = true
	covered.clear()
	for cell: Vector2i in objects.get_used_cells():
		_cover(cell, object_at(cell))
	_protect_all()


func _cover(cell: Vector2i, id: StringName) -> void:
	if id == &"":
		return
	var size: Vector2i = catalog[id].size
	for at: Vector2i in Pintor.cells(Rect2i(cell - Vector2i(0, size.y - 1), size)):
		covered[at] = true


## Rehace lo pendiente y vuelve a mirar la física (tras poner objetos que chocan).
func refresh() -> void:
	build()
	await map.get_tree().physics_frame
	await map.get_tree().physics_frame
	scan(map.get_world_2d().direct_space_state)


func _protect_all() -> void:
	protected.clear()
	anchors.clear()
	for warp: Node in map.get_node("Warps").get_children():
		var at := Grid.to_tile((warp as Node2D).position)
		_protect(at, 1)
		_protect_cell(at + Vector2i.DOWN)
		anchors[at] = "pasarela %s" % warp.name
	for spawn: Node in map.get_node("Spawns").get_children():
		var at := Grid.to_tile((spawn as Node2D).position)
		_protect(at, 1)
		anchors[at] = "aparición %s" % spawn.name
	for cell: Vector2i in objects.get_used_cells():
		var id := object_at(cell)
		if id == &"" or catalog[id].door.x < 0:
			continue
		var door: Vector2i = cell + catalog[id].door
		_protect_cell(door)
		_protect(door + Vector2i.DOWN, 1)
		anchors[door] = "puerta de %s" % id
	for node: Node in entities.get_children():
		if node == objects or not node is Node2D:
			continue
		_protect_entity(node as Node2D)
	for node: Node2D in pending_entities:
		_protect_entity(node)
	for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
		if entry.get("mapa", "") == mid and entry.has("casilla"):
			var at := Vector2i(int(entry.casilla[0]), int(entry.casilla[1]))
			_protect(at, 1)
			anchors[at + Vector2i.DOWN] = "personaje colocado %s" % entry.get("id", "?")
	for connection: Resource in map.get(&"data").connections:
		for at: Vector2i in edge_cells(connection):
			_protect(at, 1)
			if free.has(at):
				anchors[at] = "borde %s" % connection.edge


## Mueve un personaje, cartel u objeto que ya estaba (conserva su nombre, su id y sus datos).
func move(node_name: String, at: Vector2i, facing: int = -1) -> void:
	var node := entities.get_node_or_null(NodePath(node_name)) as Node2D
	if node == null:
		push_error("vestidor: no existe %s" % node_name)
		return
	var old := Grid.to_tile(node.position)
	if node.scene_file_path.ends_with("sign.tscn") and decor.get_cell_atlas_coords(old) == ExteriorTiles.SIGN:
		decor.erase_cell(old)
		decor.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SIGN)
	node.position = Grid.to_world(at)
	if facing >= 0:
		node.set(&"initial_facing", facing)
	free.erase(at)
	free[old] = true
	_protect_all()


func _protect_entity(node: Node2D) -> void:
	var at := Grid.to_tile(node.position)
	_protect(at, 1)
	if node.scene_file_path.ends_with("sign.tscn"):
		anchors[at + Vector2i.DOWN] = "cartel %s" % node.name
		_protect(at + Vector2i.DOWN, 1)
	else:
		for d: Vector2i in DIRS:
			if free.has(at + d):
				anchors[at + d] = "junto a %s" % node.name
				break
	var sight = node.get("sight_range")
	if sight != null:
		var facing := int(node.get("initial_facing"))
		var dir: Vector2i = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP][clampi(facing, 0, 3)]
		for n: int in range(1, int(sight) + 1):
			_protect_cell(at + dir * n)
	if node.get("wander") == true:
		_protect(at, int(node.get("wander_radius")))


func _protect(at: Vector2i, radius: int) -> void:
	for y: int in range(at.y - radius, at.y + radius + 1):
		for x: int in range(at.x - radius, at.x + radius + 1):
			protected[Vector2i(x, y)] = true


func _protect_cell(at: Vector2i) -> void:
	protected[at] = true


## Casillas del borde que lleva a otro mapa (todo el lado si no tiene tramo).
func edge_cells(connection: Resource) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var a: int = connection.span.x
	var b: int = connection.span.y
	if connection.span == Vector2i.ZERO:
		a = bounds.position.x if connection.edge in ["north", "south"] else bounds.position.y
		b = bounds.end.x if connection.edge in ["north", "south"] else bounds.end.y
	for value: int in range(a, b):
		match connection.edge:
			"north": out.append(Vector2i(value, bounds.position.y))
			"south": out.append(Vector2i(value, bounds.end.y - 1))
			"west": out.append(Vector2i(bounds.position.x, value))
			"east": out.append(Vector2i(bounds.end.x - 1, value))
	return out


# --- Consultas ---

func object_at(cell: Vector2i) -> StringName:
	var c := objects.get_cell_atlas_coords(cell)
	return by_tile.get(Vector3i(objects.get_cell_source_id(cell), c.x, c.y), &"")


func terrain(at: Vector2i) -> String:
	var data := ground.get_cell_tile_data(at)
	return str(data.get_custom_data("terrain")) if data != null else ""


func is_grass(at: Vector2i, grounds: Array = ["grass"]) -> bool:
	return terrain(at) in grounds and decor.get_cell_source_id(at) == -1 and not forest.has(at)


## Hierba (o el suelo dado) libre y sin nada encima (ni protegida ni bajo el dibujo de un objeto).
func open(at: Vector2i, grounds: Array = ["grass"]) -> bool:
	return bounds.has_point(at) and free.has(at) and is_grass(at, grounds) and not protected.has(at) and not covered.has(at)


func note(text: String) -> void:
	log_lines.append(text)


# --- Suelo ---

## Plano en texto: una letra por casilla, como el volcado de maps/_tools/mapa_ascii.gd. Las letras
## que no son de la leyenda dejan la casilla como está, así se parte del volcado y se cambia solo
## lo que toca. Leyenda: . hierba · , hierba alta · : camino · _ baldosa · T bosque · ~ agua ·
## s arena · * nieve · f flores · r piedra · y árbol suelto · b arbusto.
## Las casillas marcadas se limpian antes (quita árboles, vallas, adornos, bosque, mesetas y agua,
## nunca edificios, monumentos, puertas ni personajes). Es una corrutina: `await v.plan(...)`.
func plan(text: String, origin: Vector2i = Vector2i.ZERO, trees: Array = [&"arbol_verde", &"arbol_redondo", &"pino"]) -> void:
	var marks := {}
	var rows := text.trim_prefix("\n").split("\n")
	for y: int in rows.size():
		var row: String = rows[y]
		for x: int in row.length():
			var c := row[x]
			if c in ".,:_T~s*frby" and bounds.has_point(origin + Vector2i(x, y)):
				marks[origin + Vector2i(x, y)] = c
	var all: Array[Vector2i] = []
	for at: Vector2i in marks:
		all.append(at)
	clear_cells(all)
	var tall: Array[Vector2i] = []
	var paths: Array[Vector2i] = []
	var pav: Array[Vector2i] = []
	for at: Vector2i in marks:
		match marks[at]:
			",":
				tall.append(at)
			":":
				paths.append(at)
			"_":
				pav.append(at)
			"~":
				if not protected.has(at):
					water[at] = true
					for dy: int in range(-1, 2):
						for dx: int in range(-1, 2):
							_water_dirty[at + Vector2i(dx, dy)] = true
			"s":
				ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SAND_PATCH + Vector2i(1, 1))
			"*":
				ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SNOW[rng.randi() % ExteriorTiles.SNOW.size()])
	path(paths)
	paving_stone(pav)
	build()
	tall_grass(tall)
	await refresh()
	# Bosque en bloques de 2×2 alineados; lo que no cuadra, árboles sueltos.
	var leftover := {}
	for at: Vector2i in marks:
		if marks[at] == "T":
			leftover[at] = true
	for at: Vector2i in leftover.keys():
		if posmod(at.x, 2) != 0 or posmod(at.y, 2) != 0:
			continue
		var block: Array[Vector2i] = [at, at + Vector2i.RIGHT, at + Vector2i.DOWN, at + Vector2i.ONE]
		if not block.all(func(c: Vector2i) -> bool: return leftover.has(c) and _forest_ok(c, false)):
			continue
		for c: Vector2i in block:
			forest[c] = ExteriorTiles.SNOW_FOREST_ORIGIN if terrain(c) == "snow" else ExteriorTiles.FOREST_ORIGIN
			if terrain(c) != "snow":
				_set_grass(c)
			decor.erase_cell(c)
			free.erase(c)
		_forest_dirty = true
		for c: Vector2i in block:
			leftover.erase(c)
	var cand := {}
	for at: Vector2i in leftover:
		if open(at, ["grass", "snow", "sand"]):
			cand[at] = true
	_scatter_trees(cand, trees, 0)
	for at: Vector2i in leftover:
		if open(at, ["grass", "snow", "sand"]):
			object(&"arbustos", at - Vector2i(1, 0))
	for at: Vector2i in marks:
		match marks[at]:
			"f":
				if open(at):
					decor.set_cell(at, ExteriorTiles.SRC_ANIM, ExteriorTiles.FLOWERS_WHITE if rng.randf() < 0.35 else ExteriorTiles.FLOWERS_RED)
			"r":
				if open(at, ["grass", "sand", "snow"]):
					decor.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.ROCK if rng.randf() < 0.6 else ExteriorTiles.ROCK_BROWN)
					free.erase(at)
			"y":
				object(trees[rng.randi() % trees.size()], at)
			"b":
				object(&"arbustos", at - Vector2i(1, 0))
	build()


## Vuelve a dejar hierba (quita caminos, hierba alta, adornos de Decor, bosque y árboles sin puerta).
func clear(rect: Rect2i) -> void:
	clear_cells(Pintor.cells(rect.intersection(bounds)))


func clear_cells(cells: Array[Vector2i]) -> void:
	var touched_paths: Array[Vector2i] = []
	for at: Vector2i in cells:
		if not bounds.has_point(at):
			continue
		var id := object_at(at)
		var removable_object: bool = id != &"" and catalog[id].door.x < 0 \
				and catalog[id].source in [ExteriorTiles.SRC_ARBOLES, ExteriorTiles.SRC_VALLAS, ExteriorTiles.SRC_ADORNOS]
		if not free.has(at):
			# Solo se quita lo que se puede quitar: bosque, agua, Decor (mesetas, piedras) o un árbol.
			if protected.has(at) or not (forest.has(at) or water.has(at) or decor.get_cell_source_id(at) != -1 or removable_object):
				continue
		if terrain(at) in ["path", "tall_grass"]:
			touched_paths.append(at)
		_set_grass(at)
		decor.erase_cell(at)
		if forest.erase(at):
			_forest_dirty = true
		if water.erase(at):
			for dy: int in range(-1, 2):
				for dx: int in range(-1, 2):
					_water_dirty[at + Vector2i(dx, dy)] = true
		paving.erase(at)
		if removable_object:
			objects.erase_cell(at)
			for f: Vector2i in catalog[id].footprint:
				free[at + f] = true
	_refresh_terrain_around(touched_paths)
	covered.clear()
	for cell: Vector2i in objects.get_used_cells():
		_cover(cell, object_at(cell))


func _set_grass(at: Vector2i) -> void:
	var variant := 0
	if rng.randf() < 0.18:
		variant = 1 + rng.randi() % (ExteriorTiles.GRASS.size() - 1)
	ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[variant])


## Tras quitar camino o hierba alta, las vecinas rehacen su borde.
func _refresh_terrain_around(cells: Array[Vector2i]) -> void:
	var paths: Array[Vector2i] = []
	var grass: Array[Vector2i] = []
	for at: Vector2i in cells:
		for y: int in range(-1, 2):
			for x: int in range(-1, 2):
				var n := at + Vector2i(x, y)
				if terrain(n) == "path" and n not in paths:
					paths.append(n)
				elif terrain(n) == "tall_grass" and n not in grass:
					grass.append(n)
	if not paths.is_empty():
		ground.set_cells_terrain_connect(paths, ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_PATH, false)
	if not grass.is_empty():
		ground.set_cells_terrain_connect(grass, ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_TALL_GRASS, false)


func path(cells: Array[Vector2i]) -> void:
	ground.set_cells_terrain_connect(_inside(cells), ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_PATH, false)


## Hierba alta: nunca sobre lo protegido (puertas, bordes, personajes y su vista).
func tall_grass(cells: Array[Vector2i]) -> void:
	var ok: Array[Vector2i] = []
	for at: Vector2i in _inside(cells):
		if not protected.has(at) and terrain(at) in ["grass", "path", "tall_grass", "sand", "snow"] and not forest.has(at) \
				and decor.get_cell_source_id(at) == -1:
			ok.append(at)
	ground.set_cells_terrain_connect(ok, ExteriorTiles.TERRAIN_SET, ExteriorTiles.TERRAIN_TALL_GRASS, false)


## Paso obligado por hierba: todo lo transitable de `rect` pasa a hierba alta, salvo lo protegido
## (puertas, personajes, su vista...), que se avisa porque puede abrir un rodeo.
func grass_band(rect: Rect2i) -> void:
	var cells: Array[Vector2i] = []
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		if not free.has(at) or forest.has(at) or water.has(at):
			continue
		if protected.has(at):
			note("paso de hierba %s: %s protegida, queda sin hierba" % [rect, at])
			continue
		if decor.get_cell_source_id(at) != -1:
			decor.erase_cell(at)
		if terrain(at) not in ["grass", "path", "tall_grass", "sand", "snow"]:
			# Baldosa o adoquín: la carretera se corta y crece la hierba.
			paving.erase(at)
			_set_grass(at)
			for d: Vector2i in DIRS:
				_paving_dirty[at + d] = true
		cells.append(at)
	build()
	tall_grass(cells)


func is_encounter(at: Vector2i) -> bool:
	var data := ground.get_cell_tile_data(at)
	return data != null and bool(data.get_custom_data("encounter"))


## Coste mínimo en casillas de encuentro para ir de un borde con conexión a cada otro (como
## tools/mundo/auditar_composicion.gd, sin pisar pasarelas): {"A → B": coste o -1}.
func grass_costs() -> Dictionary:
	var walk := free.duplicate()
	for warp: Node in map.get_node("Warps").get_children():
		walk.erase(Grid.to_tile((warp as Node2D).position))
	var out := {}
	var connections: Array = map.get(&"data").connections
	for a: Resource in connections:
		var costs := {}
		var queue: Array[Vector2i] = []
		for at: Vector2i in edge_cells(a):
			if walk.has(at):
				costs[at] = 1 if is_encounter(at) else 0
				queue.append(at)
		while not queue.is_empty():
			var at: Vector2i = queue.pop_front()
			for d: Vector2i in DIRS:
				var n := at + d
				if not walk.has(n):
					continue
				var next := int(costs[at]) + (1 if is_encounter(n) else 0)
				if not costs.has(n) or next < int(costs[n]):
					costs[n] = next
					if is_encounter(n):
						queue.push_back(n)
					else:
						queue.push_front(n)
		for b: Resource in connections:
			if a == b:
				continue
			var best := -1
			for at: Vector2i in edge_cells(b):
				if costs.has(at) and (best < 0 or int(costs[at]) < best):
					best = int(costs[at])
			out["%s → %s" % [a.target_map, b.target_map]] = best
	return out


## Un camino sin hierba entre dos conexiones (para ver por dónde se rodea el paso), o vacío.
func grass_bypass(a: Resource, b: Resource) -> Array[Vector2i]:
	var walk := {}
	for at: Vector2i in free:
		if not is_encounter(at):
			walk[at] = true
	for warp: Node in map.get_node("Warps").get_children():
		walk.erase(Grid.to_tile((warp as Node2D).position))
	var came := {}
	var queue: Array[Vector2i] = []
	for at: Vector2i in edge_cells(a):
		if walk.has(at):
			came[at] = at
			queue.append(at)
	var goal := {}
	for at: Vector2i in edge_cells(b):
		goal[at] = true
	var cursor := 0
	while cursor < queue.size():
		var at := queue[cursor]
		cursor += 1
		if goal.has(at):
			var out: Array[Vector2i] = [at]
			while came[at] != at:
				at = came[at]
				out.push_front(at)
			return out
		for d: Vector2i in DIRS:
			var n := at + d
			if walk.has(n) and not came.has(n):
				came[n] = at
				queue.append(n)
	return []


## Calle de baldosas en espiga (con su borde de hierba).
func paving_stone(cells: Array[Vector2i]) -> void:
	for at: Vector2i in _inside(cells):
		paving[at] = true
		for d: Vector2i in [Vector2i.ZERO] + DIRS:
			_paving_dirty[at + d] = true


func sand(rect: Rect2i) -> void:
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SAND_PATCH + Vector2i(1, 1))


## Mancha de tierra con su borde (recuadro 3×3 del pack 02).
func soil(rect: Rect2i) -> void:
	for at: Vector2i in Pintor.cells(rect):
		var cx := 0 if at.x == rect.position.x else (2 if at.x == rect.end.x - 1 else 1)
		var cy := 0 if at.y == rect.position.y else (2 if at.y == rect.end.y - 1 else 1)
		ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SAND_PATCH + Vector2i(cx, cy))


func snow(rect: Rect2i) -> void:
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		if not protected.has(at) or free.has(at):
			ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SNOW[rng.randi() % ExteriorTiles.SNOW.size()])


## Agua con orilla (estanque, río, mar). Se rehace la orilla de las casillas tocadas.
func add_water(rect: Rect2i) -> void:
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		if protected.has(at):
			continue
		water[at] = true
		decor.erase_cell(at)
		for y: int in range(-1, 2):
			for x: int in range(-1, 2):
				_water_dirty[at + Vector2i(x, y)] = true


## Estanque rectangular con brillos y nenúfares (casillas absolutas).
func pond(rect: Rect2i, lilies: Array = []) -> void:
	add_water(rect)
	build()
	for at: Vector2i in Pintor.cells(rect.grow(-1)):
		if water.has(at) and rng.randf() < 0.3:
			decor.set_cell(at, ExteriorTiles.SRC_ANIM, ExteriorTiles.WATER_SHINE)
	for i: int in lilies.size():
		var at: Vector2i = lilies[i]
		if water.has(at):
			decor.set_cell(at, ExteriorTiles.SRC_FLORA, Vector2i(i % 3, 25 + (i / 3) % 3))


# --- Relieve ---

## Meseta del pack 02 (borde de tierra y pared de 2 filas abajo), con escalera en `stairs_x`.
func plateau(rect: Rect2i, stairs_x: Array = []) -> bool:
	var o := ExteriorTiles.PLATEAU
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		var edge := at.x == rect.position.x or at.x == rect.end.x - 1 or at.y == rect.position.y or at.y >= rect.end.y - 2
		if edge and (protected.has(at) or anchors.has(at)) and not (at.x in stairs_x and at.y >= rect.end.y - 2):
			note("AVISO: meseta %s no se pone: tapa %s, que está protegida" % [rect, at])
			return false
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		var cx := 0 if at.x == rect.position.x else (2 if at.x == rect.end.x - 1 else 1)
		var cy: int
		if at.y == rect.position.y:
			cy = 0
		elif at.y >= rect.end.y - 2:
			cy = 2 + (at.y - (rect.end.y - 2))
		else:
			cy = 1
		if forest.erase(at):
			_forest_dirty = true
		if cx == 1 and cy == 1:
			decor.erase_cell(at)
			continue
		var coords := o + Vector2i(cx, cy)
		if cy >= 2 and at.x in stairs_x:
			coords = ExteriorTiles.STAIRS[cy - 2]
		decor.set_cell(at, ExteriorTiles.SRC_GEN4, coords)
		if not (cy >= 2 and at.x in stairs_x):
			free.erase(at)
	return true


## Bordillo (se salta hacia abajo) de x0 a x1 en la fila y; no tapa lo protegido.
func ledge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var at := Vector2i(x, y)
		if protected.has(at):
			note("bordillo: %s protegida, se salta" % at)
			continue
		var piece := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.LEDGE[piece])


# --- Bosque ---

## Bosque de pinos en bloques de 2×2 alineados a casillas pares (como Pintor.forest()).
## Se salta los bloques que tocan algo protegido o que no es hierba libre.
func add_forest(rect: Rect2i, snowy: bool = false, strict: bool = true) -> int:
	var origin := ExteriorTiles.SNOW_FOREST_ORIGIN if snowy else ExteriorTiles.FOREST_ORIGIN
	var made := 0
	var r := rect.intersection(bounds)
	for y: int in range(r.position.y - posmod(r.position.y, 2), r.end.y, 2):
		for x: int in range(r.position.x - posmod(r.position.x, 2), r.end.x, 2):
			var block: Array[Vector2i] = [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]
			if not block.all(func(at: Vector2i) -> bool: return r.has_point(at)):
				continue
			if not block.all(func(at: Vector2i) -> bool: return _forest_ok(at, strict)):
				continue
			for at: Vector2i in block:
				if not forest.has(at):
					forest[at] = origin
					if terrain(at) != "snow":
						_set_grass(at)
					decor.erase_cell(at)
					free.erase(at)
					made += 1
	if made > 0:
		_forest_dirty = true
	return made


func _forest_ok(at: Vector2i, strict: bool) -> bool:
	if forest.has(at):
		return true
	if not bounds.has_point(at) or protected.has(at) or water.has(at):
		return false
	if strict:
		return open(at)
	return free.has(at) and terrain(at) in ["grass", "tall_grass", "path", "sand", "snow"]


## Relleno automático de la hierba vacía. Primero une con una red de paso todo lo importante
## (apariciones, puertas, pasarelas, bordes, personajes, carteles y cada mancha de hierba alta o
## camino) por el camino más corto, prefiriendo los caminos que ya hay. Lo que queda lejos de esa
## red (a `margen` casillas, con ruido para que el borde no sea recto) se rellena con el estilo:
##   "bosque" / "bosque_nevado": bloques de pinos de 2×2 y árboles sueltos en los huecos.
##   "arboleda": árboles sueltos al tresbolillo (opts "arboles": ids del catálogo).
##   "hileras": filas de un cultivo (opts "planta": id, "paso": Vector2i entre plantas).
##   "roquedal": piedras y matojos dispersos (opts "densidad").
## Otras opciones: "zona" (Rect2i), "excluir" (Array de Rect2i), "adornos" (probabilidad de
## matojos y flores en los márgenes), "claros" (probabilidad de cambiar un bloque de bosque
## del borde por un árbol suelto).
func fill(opts: Dictionary = {}) -> Dictionary:
	var margin: Array = opts.get("margen", [1, 2])
	var zone: Rect2i = opts.get("zona", bounds)
	var excluded: Array = opts.get("excluir", [])
	var style: String = opts.get("estilo", "bosque")
	var grounds: Array = opts.get("suelo", ["grass"])
	var start := Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)
	var graph := AStarGrid2D.new()
	graph.region = bounds
	graph.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	graph.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	graph.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	graph.update()
	for at: Vector2i in Pintor.cells(bounds):
		graph.set_point_solid(at, not free.has(at))
		if free.has(at):
			var t := terrain(at)
			graph.set_point_weight_scale(at, 1.0 if t in ["path", "stone", "sand", "stairs"] else (3.0 if t == "tall_grass" else 2.0))
	# Una ancla por cada mancha de suelo que no es hierba (camino, hierba alta, arena...).
	var targets: Array[Vector2i] = []
	for at: Vector2i in anchors:
		if free.has(at):
			targets.append(at)
	var seen := {}
	for at: Vector2i in free:
		if seen.has(at) or terrain(at) in grounds or terrain(at) == "":
			continue
		var t := terrain(at)
		var best := at
		var queue: Array[Vector2i] = [at]
		seen[at] = true
		var cursor := 0
		while cursor < queue.size():
			var c := queue[cursor]
			cursor += 1
			if c.distance_squared_to(start) < best.distance_squared_to(start):
				best = c
			for d: Vector2i in DIRS:
				var n := c + d
				if free.has(n) and not seen.has(n) and terrain(n) == t:
					seen[n] = true
					queue.append(n)
		targets.append(best)
	targets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.distance_squared_to(start) < b.distance_squared_to(start))
	var net := {start: true}
	for target: Vector2i in targets:
		if net.has(target):
			continue
		var origins: Array = net.keys()
		origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return a.distance_squared_to(target) < b.distance_squared_to(target))
		var best_route: Array[Vector2i] = []
		for origin: Vector2i in origins.slice(0, 6):
			var route := graph.get_id_path(origin, target)
			if not route.is_empty() and (best_route.is_empty() or route.size() < best_route.size()):
				best_route = route
		for at: Vector2i in best_route:
			net[at] = true
	# Lo que se queda libre: la red, el suelo que no es hierba, lo protegido y los edificios.
	var keep := {}
	for at: Vector2i in free:
		if terrain(at) not in grounds and terrain(at) != "":
			keep[at] = true
	for at: Vector2i in net:
		keep[at] = true
	for at: Vector2i in protected:
		keep[at] = true
	for cell: Vector2i in objects.get_used_cells():
		var id := object_at(cell)
		if id == &"":
			continue
		var o: Dictionary = catalog[id]
		if o.source in [ExteriorTiles.SRC_CASAS, ExteriorTiles.SRC_CASAS_DPPT, ExteriorTiles.SRC_EDIFICIOS] \
				or o.source >= ExteriorTiles.SRC_HECHO_A_MANO:
			for f: Vector2i in o.footprint:
				keep[cell + f] = true
	var noise := FastNoiseLite.new()
	noise.seed = rng.seed
	noise.frequency = 0.12
	var kept := {}
	for at: Vector2i in keep:
		var span := int(margin[1]) - int(margin[0])
		var r := int(margin[0]) + int(round((noise.get_noise_2d(at.x, at.y) * 0.5 + 0.5) * span))
		for dy: int in range(-r, r + 1):
			for dx: int in range(-r, r + 1):
				if absi(dx) + absi(dy) <= r:
					kept[at + Vector2i(dx, dy)] = true
	var cand := {}
	for at: Vector2i in Pintor.cells(zone.intersection(bounds)):
		if kept.has(at) or not open(at, grounds):
			continue
		if excluded.any(func(r: Rect2i) -> bool: return r.has_point(at)):
			continue
		cand[at] = true
	var made := {"bosque": 0, "arboles": 0, "adornos": 0, "red": net.size()}
	match style:
		"bosque", "bosque_nevado":
			var snowy := style == "bosque_nevado"
			var origin := ExteriorTiles.SNOW_FOREST_ORIGIN if snowy else ExteriorTiles.FOREST_ORIGIN
			for y: int in range(bounds.position.y - posmod(bounds.position.y, 2), bounds.end.y, 2):
				for x: int in range(bounds.position.x - posmod(bounds.position.x, 2), bounds.end.x, 2):
					var block: Array[Vector2i] = [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]
					if not block.all(func(at: Vector2i) -> bool: return cand.has(at)):
						continue
					for at: Vector2i in block:
						forest[at] = origin
						if terrain(at) != "snow":
							_set_grass(at)
						decor.erase_cell(at)
						free.erase(at)
						cand.erase(at)
					made.bosque += 4
			_forest_dirty = true
			made.arboles += _scatter_trees(cand, opts.get("arboles", [&"arbol_verde", &"arbol_redondo", &"pino", &"arbol_doble"]), 1, opts.get("sueltos", 0.4))
		"arboleda":
			made.arboles += _scatter_trees(cand, opts.get("arboles", [&"arbol_redondo", &"arbol_verde", &"cerezo"]), int(opts.get("hueco", 1)))
		"hileras":
			var plant: StringName = opts.get("planta", &"olivo")
			var step: Vector2i = opts.get("paso", Vector2i(3, 3))
			for at: Vector2i in cand.keys():
				if posmod(at.x, step.x) == 0 and posmod(at.y, step.y) == 0 and _fits(plant, at, cand):
					if object(plant, at):
						made.arboles += 1
		"roquedal":
			var density: float = opts.get("densidad", 0.12)
			for at: Vector2i in cand.keys():
				if rng.randf() < density:
					var piece: Vector2i = [ExteriorTiles.ROCK, ExteriorTiles.ROCK_BROWN, ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL][rng.randi() % 4]
					decor.set_cell(at, ExteriorTiles.SRC_GEN4, piece)
					if piece in [ExteriorTiles.ROCK, ExteriorTiles.ROCK_BROWN]:
						free.erase(at)
					made.adornos += 1
	# Matojos y flores en los márgenes que quedan de hierba.
	var deco_chance: float = opts.get("adornos", 0.06)
	if deco_chance > 0.0:
		for at: Vector2i in Pintor.cells(zone.intersection(bounds)):
			if not open(at, grounds) or net.has(at) or rng.randf() >= deco_chance:
				continue
			var roll := rng.randf()
			if roll < 0.45:
				decor.set_cell(at, ExteriorTiles.SRC_GEN4, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.MUSHROOMS][rng.randi() % 3])
			elif roll < 0.8:
				decor.set_cell(at, ExteriorTiles.SRC_ANIM, ExteriorTiles.FLOWERS_WHITE if rng.randf() < 0.4 else ExteriorTiles.FLOWERS_RED)
			else:
				decor.set_cell(at, ExteriorTiles.SRC_GEN4, [ExteriorTiles.WHITE_FLOWERS, ExteriorTiles.PINK_FLOWERS][rng.randi() % 2])
			made.adornos += 1
	build()
	note("relleno %s: %s" % [style, made])
	return made


## ¿Cabe la base del objeto en las casillas candidatas?
func _fits(id: StringName, at: Vector2i, cand: Dictionary) -> bool:
	for f: Vector2i in catalog[id].footprint:
		if not cand.has(at + f):
			return false
	return true


## Árboles sueltos en las casillas candidatas, separados `gap` casillas entre bases.
func _scatter_trees(cand: Dictionary, ids: Array, gap: int, chance: float = 1.0) -> int:
	var count := 0
	var cells: Array = cand.keys()
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y > b.y or (a.y == b.y and a.x < b.x))
	for at: Vector2i in cells:
		if not cand.has(at) or rng.randf() >= chance:
			continue
		var id: StringName = ids[rng.randi() % ids.size()]
		if not _fits(id, at, cand):
			continue
		if not object(id, at):
			continue
		count += 1
		var w: int = catalog[id].size.x
		for dy: int in range(-gap, gap + 1):
			for dx: int in range(-gap, w + gap):
				cand.erase(at + Vector2i(dx, dy))
	return count


func _rebuild_forest() -> void:
	for at: Vector2i in above.get_used_cells():
		if above.get_cell_source_id(at) != ExteriorTiles.SRC_GEN4:
			continue
		var c := above.get_cell_atlas_coords(at)
		if GREEN_OVERHANG.has_point(c) or SNOW_OVERHANG.has_point(c):
			above.erase_cell(at)
	for cell: Vector2i in forest:
		var o: Vector2i = forest[cell]
		var col: int
		if cell.x % 2 == 0:
			col = 1 if not forest.has(cell + Vector2i.LEFT) else 3
		else:
			col = 4 if not forest.has(cell + Vector2i.RIGHT) else 2
		var row: int
		if cell.y % 2 == 0:
			if not forest.has(cell + Vector2i.UP):
				row = 0
			else:
				row = 2 if forest.has(cell + Vector2i(0, 2)) else 4
		else:
			if not forest.has(cell + Vector2i.DOWN):
				row = 5
			else:
				row = 1 if not forest.has(cell + Vector2i(0, -2)) else 3
		decor.set_cell(cell, ExteriorTiles.SRC_GEN4, o + Vector2i(col, row))
		var left := cell + Vector2i.LEFT
		if cell.x % 2 == 0 and not forest.has(left) and row >= 1 and row <= 4:
			above.set_cell(left, ExteriorTiles.SRC_GEN4, o + Vector2i(0, row))


# --- Objetos y adornos ---

## Objeto del catálogo con su casilla de abajo a la izquierda. Comprueba que su base cabe en
## hierba libre y que no tapa nada protegido. Devuelve si se ha puesto.
func object(id: StringName, cell: Vector2i, force: bool = false) -> bool:
	if not catalog.has(id):
		push_error("vestidor: no existe el objeto %s" % id)
		return false
	var o: Dictionary = catalog[id]
	if not force:
		for f: Vector2i in o.footprint:
			var at: Vector2i = cell + f
			if not bounds.has_point(at) or not free.has(at) or protected.has(at) or forest.has(at) or water.has(at):
				return false
		var rect := Rect2i(cell - Vector2i(0, o.size.y - 1), o.size)
		for at: Vector2i in Pintor.cells(rect):
			if anchors.has(at) and not o.footprint.has(at - cell):
				return false
	objects.set_cell(cell, o.source, o.coords)
	for f: Vector2i in o.footprint:
		free.erase(cell + f)
	_cover(cell, id)
	return true


## Quita los objetos sin puerta de estos ids cuya casilla de anclaje cae en `rect` (para recolocar
## piedras o árboles de un pintor anterior). Nunca quita edificios con puerta.
func remove_objects(ids: Array, rect: Rect2i) -> int:
	var count := 0
	for cell: Vector2i in objects.get_used_cells():
		var id := object_at(cell)
		if id == &"" or not (id in ids) or not rect.has_point(cell) or catalog[id].door.x >= 0:
			continue
		objects.erase_cell(cell)
		for f: Vector2i in catalog[id].footprint:
			free[cell + f] = true
		count += 1
	covered.clear()
	for cell: Vector2i in objects.get_used_cells():
		_cover(cell, object_at(cell))
	return count


## Un adorno pequeño (una casilla de Decor). Solo en hierba libre salvo `force`.
func deco(at: Vector2i, coords: Vector2i, source: int = ExteriorTiles.SRC_GEN4, force: bool = false) -> bool:
	if not force and not open(at):
		return false
	decor.set_cell(at, source, coords)
	return true


func flowers(rect: Rect2i, white_chance: float = 0.3, density: float = 1.0) -> void:
	for at: Vector2i in Pintor.cells(rect):
		if open(at) and rng.randf() < density:
			decor.set_cell(at, ExteriorTiles.SRC_ANIM, ExteriorTiles.FLOWERS_WHITE if rng.randf() < white_chance else ExteriorTiles.FLOWERS_RED)


## Flor alta de la flora (dos casillas): `top` es su casilla de arriba en flora.png.
func tall_flower(at: Vector2i, top: Vector2i) -> void:
	if open(at) and bounds.has_point(at + Vector2i.UP) and decor.get_cell_source_id(at + Vector2i.UP) == -1:
		decor.set_cell(at + Vector2i.UP, ExteriorTiles.SRC_FLORA, top)
		decor.set_cell(at, ExteriorTiles.SRC_FLORA, top + Vector2i.DOWN)


## Seto (2 de alto, choca) de x0 a x1 con la base en la fila y.
func hedge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		if not open(Vector2i(x, y)):
			note("seto: %s ocupada" % Vector2i(x, y))
			continue
		var col := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(Vector2i(x, y - 1), ExteriorTiles.SRC_FLORA, Vector2i(col, 21))
		decor.set_cell(Vector2i(x, y), ExteriorTiles.SRC_FLORA, Vector2i(col, 24))
		free.erase(Vector2i(x, y))


func fence(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var id := &"valla"
		if x == x0:
			id = &"valla_izquierda"
		elif x == x1:
			id = &"valla_derecha"
		if not object(id, Vector2i(x, y)):
			note("valla: %s ocupada" % Vector2i(x, y))


## Valla vertical (postes uno encima de otro) de y0 a y1 en la columna x.
func fence_v(x: int, y0: int, y1: int) -> void:
	for y: int in range(y0, y1 + 1):
		if not object(&"valla", Vector2i(x, y)):
			note("valla: %s ocupada" % Vector2i(x, y))


## Matojos, setas, flores sueltas y piedras en la hierba libre.
func sprinkle(rect: Rect2i, chance: float, pieces: Array) -> void:
	for at: Vector2i in Pintor.cells(rect.intersection(bounds)):
		if open(at) and rng.randf() < chance:
			var piece = pieces[rng.randi() % pieces.size()]
			if piece is Vector3i:
				decor.set_cell(at, piece.z, Vector2i(piece.x, piece.y))
			else:
				decor.set_cell(at, ExteriorTiles.SRC_GEN4, piece)
			if piece in [ExteriorTiles.ROCK, ExteriorTiles.ROCK_BROWN, ExteriorTiles.STUMP, ExteriorTiles.STUMP_CUT]:
				free.erase(at)


# --- Entidades nuevas ---

func npc(node_name: String, sheet: String, at: Vector2i, facing: int, lines: PackedStringArray, props: Dictionary = {}) -> void:
	if _entity_exists(node_name):
		return
	var node: Node2D = (load(Pintor.NPC_SCENE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	node.set(&"sprite_sheet", load(Pintor.CHARACTERS + sheet + ".png"))
	node.set(&"initial_facing", facing)
	node.set(&"lines", lines)
	for key: String in props:
		node.set(StringName(key), props[key])
	_add_entity(node, at)


func trainer(node_name: String, trainer_id: StringName, at: Vector2i, facing: int, sight: int = 4) -> void:
	if _entity_exists(node_name):
		return
	var node: Node2D = (load(Pintor.TRAINER_SCENE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	node.set(&"trainer_id", trainer_id)
	node.set(&"initial_facing", facing)
	node.set(&"sight_range", sight)
	_add_entity(node, at)


## Objeto en el suelo (Poké Ball) u oculto (se encuentra pulsando en su casilla).
func item(node_name: String, item_id: StringName, at: Vector2i, hidden: bool = false, quantity: int = 1) -> void:
	if _entity_exists(node_name):
		return
	var node: Node2D = (load(ITEM_SCENE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	node.set(&"item_id", item_id)
	node.set(&"hidden_item", hidden)
	if quantity > 1:
		node.set(&"quantity", quantity)
	_add_entity(node, at, not hidden)


func sign(node_name: String, at: Vector2i, lines: PackedStringArray, coords: Vector2i = ExteriorTiles.SIGN) -> void:
	if _entity_exists(node_name):
		return
	decor.set_cell(at, ExteriorTiles.SRC_GEN4, coords)
	var node: Node2D = (load(Pintor.SIGN_SCENE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	node.set(&"lines", lines)
	_add_entity(node, at)


## Obstáculo de campo: arbolillo de Corte, roca de Golpe Roca o roca de Fuerza. Con `cleared_flag`
## desaparece para siempre al quitarlo; sin ella, vuelve al cargar el mapa.
func obstacle(node_name: String, action: String, at: Vector2i, cleared_flag: StringName = &"") -> void:
	if _entity_exists(node_name):
		return
	var node: Node2D = (load(OBSTACLES[action]) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	if cleared_flag != &"":
		node.set(&"cleared_flag", cleared_flag)
	_add_entity(node, at)
	obstacle_cells.append(at)


## Atajo que se abre más tarde: abre un hueco de dos casillas en un muro fino (bosque, seto, valla o
## piedras) de `wall` casillas que empieza en `from + dir` y lo tapa con un tronco (dir abajo) o una
## cancela (dir derecha) que solo se abre desde `open_side` y pone `flag` para siempre.
func shortcut(node_name: String, from: Vector2i, dir: Vector2i, wall: int, open_side: Vector2i, flag: StringName) -> void:
	if _entity_exists(node_name):
		return
	var side := Vector2i(dir.y, dir.x)
	var cells: Array[Vector2i] = []
	for s: int in 2:
		for i: int in range(1, wall + 1):
			cells.append(from + side * s + dir * i)
	clear_cells(cells)
	var at := from + dir
	var node: Node2D = (load(SHORTCUT_LOG if dir == Vector2i.DOWN else SHORTCUT_GATE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(at)
	node.set(&"hidden_if_flag", flag)
	node.set(&"open_side", open_side)
	for cell: Vector2i in cells:
		free[cell] = true
	_add_entity(node, at)
	pending_cells[at + side] = true
	free.erase(at + side)
	shortcut_cells.append_array([at, at + side])


## Escollo de 2×2 casillas (`at` es la de arriba a la izquierda): roca en el mar que choca.
func reef(at: Vector2i) -> void:
	var node: Node2D = (load(REEF_SCENE) as PackedScene).instantiate()
	node.name = "Escollo_%d_%d" % [at.x, at.y]
	node.position = Grid.to_world(at)
	pending_sea.append(node)
	for cell: Vector2i in Pintor.cells(Rect2i(at, Vector2i(2, 2))):
		if not free.has(cell) or protected.has(cell):
			note("AVISO: escollo en %s tapa %s" % [at, cell])
		pending_cells[cell] = true
		free.erase(cell)


## Corriente marina (SurfCurrent) en `rect`, con su agua revuelta casilla a casilla.
func current(rect: Rect2i, direction: Vector2i) -> void:
	var node := Node2D.new()
	node.set_script(load(CURRENT_SCRIPT))
	node.name = "Corriente_%d_%d" % [rect.position.x, rect.position.y]
	node.position = Grid.to_world(rect.position)
	node.set(&"direction", direction)
	node.set(&"size_tiles", rect.size)
	var frames: SpriteFrames = load(CURRENT_FRAMES)
	for cell: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, rect.size)):
		var sprite := AnimatedSprite2D.new()
		sprite.name = "Agua_%d_%d" % [cell.x, cell.y]
		sprite.sprite_frames = frames
		sprite.autoplay = "default"
		sprite.position = Vector2(cell * Grid.TILE)
		node.add_child(sprite)
	for cell: Vector2i in Pintor.cells(rect):
		if not water.has(cell) and not _is_sea(cell):
			note("AVISO: corriente fuera del agua en %s" % cell)
	pending_sea.append(node)


func _is_sea(at: Vector2i) -> bool:
	var data := ground.get_cell_tile_data(at)
	return data != null and data.get_custom_data(&"terrain") == "water"


func _entity_exists(node_name: String) -> bool:
	if entities.has_node(NodePath(node_name)):
		note("ya existe %s: no se repite" % node_name)
		return true
	return false


func _add_entity(node: Node2D, at: Vector2i, blocks: bool = true) -> void:
	if not free.has(at) and not (node.get("hidden_item") == true):
		note("AVISO: %s en %s no está libre" % [node.name, at])
	pending_entities.append(node)
	if blocks:
		pending_cells[at] = true
		free.erase(at)
	_protect_entity(node)


## Mete las entidades nuevas (con el mapa fuera del árbol) y les da dueño para guardarlas.
func commit_entities() -> void:
	for node: Node2D in pending_entities:
		entities.add_child(node)
		node.owner = map
	pending_entities.clear()
	if pending_sea.is_empty():
		return
	var sea := map.get_node_or_null(^"Mar") as Node2D
	if sea == null:
		sea = Node2D.new()
		sea.name = "Mar"
		map.add_child(sea)
		map.move_child(sea, entities.get_index())
		sea.owner = map
	for node: Node2D in pending_sea:
		sea.add_child(node)
		node.owner = map
		if node.scene_file_path == "":
			for child: Node in node.get_children():
				child.owner = map
	pending_sea.clear()


# --- Cierre ---

func build() -> void:
	if _forest_dirty:
		_rebuild_forest()
		_forest_dirty = false
	for at: Vector2i in _water_dirty:
		if not water.has(at):
			continue
		var left := _is_water(at + Vector2i.LEFT)
		var right := _is_water(at + Vector2i.RIGHT)
		var up := _is_water(at + Vector2i.UP)
		var down := _is_water(at + Vector2i.DOWN)
		var cx := 1 if left == right else (0 if not left else 2)
		var cy := 1 if up == down else (0 if not up else 2)
		ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.POND + Vector2i(cx, cy))
		free.erase(at)
	_water_dirty.clear()
	for at: Vector2i in _paving_dirty:
		if not paving.has(at):
			continue
		var left := paving.has(at + Vector2i.LEFT)
		var right := paving.has(at + Vector2i.RIGHT)
		var up := paving.has(at + Vector2i.UP)
		var down := paving.has(at + Vector2i.DOWN)
		var cx := 1 if left == right else (0 if not left else 2)
		var cy := 1 if up == down else (0 if not up else 2)
		ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.PAVING_STONE + Vector2i(cx, cy))
	_paving_dirty.clear()


func _is_water(at: Vector2i) -> bool:
	if not bounds.has_point(at):
		return true
	return water.has(at)


func _inside(cells: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for at: Vector2i in cells:
		if bounds.has_point(at):
			out.append(at)
	return out


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


## Mancha irregular (elipse con el borde mordido por ruido) centrada en `center`.
static func blob(center: Vector2i, radius: Vector2i, seed_value: int = 0, rough: float = 0.45) -> Array[Vector2i]:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value + center.x * 31 + center.y * 17
	noise.frequency = 0.3
	var out: Array[Vector2i] = []
	for y: int in range(-radius.y - 1, radius.y + 2):
		for x: int in range(-radius.x - 1, radius.x + 2):
			var d := pow(float(x) / maxf(radius.x, 0.5), 2) + pow(float(y) / maxf(radius.y, 0.5), 2)
			if d + noise.get_noise_2d(center.x + x, center.y + y) * rough <= 1.0:
				out.append(center + Vector2i(x, y))
	return out


## Bordes mordidos para las manchas rectangulares de hierba alta que ya hay en `zone`: añade
## bultos fuera y quita esquinas dentro, sin tocar lo protegido.
func roughen_tall_grass(zone: Rect2i, chance: float = 0.35, base: String = "grass") -> void:
	var grow: Array[Vector2i] = []
	var cut: Array[Vector2i] = []
	var noise := FastNoiseLite.new()
	noise.seed = rng.seed
	noise.frequency = 0.35
	for at: Vector2i in Pintor.cells(zone.intersection(bounds)):
		var n := noise.get_noise_2d(at.x, at.y) * 0.5 + 0.5
		if terrain(at) == "tall_grass":
			var outside := 0
			for d: Vector2i in DIRS:
				if terrain(at + d) != "tall_grass":
					outside += 1
			if outside >= 2 and n < chance * 0.8:
				cut.append(at)
		elif open(at, [base]):
			var touching := DIRS.filter(func(d: Vector2i) -> bool: return terrain(at + d) == "tall_grass").size()
			if touching >= 1 and n < chance:
				grow.append(at)
	for at: Vector2i in cut:
		if base == "sand":
			ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SAND_PATCH + Vector2i(1, 1))
		elif base == "snow":
			ground.set_cell(at, ExteriorTiles.SRC_GEN4, ExteriorTiles.SNOW[rng.randi() % ExteriorTiles.SNOW.size()])
		else:
			_set_grass(at)
	_refresh_terrain_around(cut)
	tall_grass(grow)


## Línea de casillas de `a` a `b` (en L: primero en horizontal), de `width` de ancho.
static func lane(a: Vector2i, b: Vector2i, width: int = 2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var x0 := mini(a.x, b.x)
	var x1 := maxi(a.x, b.x)
	for x: int in range(x0, x1 + width):
		for w: int in width:
			out.append(Vector2i(x, a.y + w))
	var y0 := mini(a.y, b.y)
	var y1 := maxi(a.y, b.y)
	for y: int in range(y0, y1 + width):
		for w: int in width:
			out.append(Vector2i(b.x + w, y))
	return out
