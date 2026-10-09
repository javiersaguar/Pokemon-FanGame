class_name Pintor
extends RefCounted
@warning_ignore_start("integer_division")
## Pinta mapas por código con el tileset de exteriores (Agente 4). Solo coloca
## casillas y objetos del TileSet (arte de los packs) en las capas del mapa; no
## dibuja nada. Las entidades (NPCs, warps...) son del Agente 1; aquí solo se
## ponen en los mapas de muestra, para enseñar el conjunto.
## Estructura del mapa: la de MapRoot (docs/contratos.md §5).

const T := Grid.TILE
const MAP_ROOT_SCRIPT := "res://src/overworld/map_root.gd"
const NPC_SCENE := "res://src/overworld/npc/npc.tscn"
const TRAINER_SCENE := "res://src/overworld/trainers/trainer_npc.tscn"
const SIGN_SCENE := "res://src/overworld/sign/sign.tscn"
const FOLLOWER_SCENE := "res://src/overworld/follower/follower.tscn"
const CHARACTERS := "res://assets/sprites/characters/"

var root: Node2D
var ground: TileMapLayer
var decor: TileMapLayer
var objects: TileMapLayer
var above: TileMapLayer
var entities: Node2D
var size: Vector2i
var rng := RandomNumberGenerator.new()
var _forest := {}
var _paving := {}
var _water := {}
## Casillas que tapa cada objeto grande (para no poner adornos debajo).
var _covered := {}
var _catalog: Dictionary


func _init(map_name: String, map_size: Vector2i, data: MapData, seed_value: int = 1) -> void:
	size = map_size
	rng.seed = seed_value
	var tileset: TileSet = load(ExteriorTiles.TILESET)
	_catalog = ExteriorTiles.objects()
	root = Node2D.new()
	root.set_script(load(MAP_ROOT_SCRIPT))
	root.name = map_name
	root.set(&"data", data)
	ground = _layer("Ground", tileset, root)
	decor = _layer("Decor", tileset, root)
	entities = _node("Entities", root)
	entities.y_sort_enabled = true
	objects = _layer("Objects", tileset, entities)
	objects.y_sort_enabled = true
	above = _layer("Above", tileset, root)
	above.z_index = 10
	_node("Warps", root)
	_node("Spawns", root)
	_node("Triggers", root)


func save(path: String) -> Error:
	_own(root, root)
	var scene := PackedScene.new()
	var err := scene.pack(root)
	if err == OK:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
		err = ResourceSaver.save(scene, path)
	root.free()
	return err


# --- Suelo ---

## Hierba en todo el mapa, con sus variantes repartidas sin patrón.
func fill_grass(variant_chance: float = 0.22) -> void:
	for y: int in size.y:
		for x: int in size.x:
			var variant := 0
			if rng.randf() < variant_chance:
				variant = 1 + rng.randi() % (ExteriorTiles.GRASS.size() - 1)
			ground.set_cell(Vector2i(x, y), ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[variant])


## Terreno de autotile (hierba alta o camino de tierra): Godot elige los bordes.
func terrain(cell_list: Array[Vector2i], terrain_id: int) -> void:
	ground.set_cells_terrain_connect(cell_list, ExteriorTiles.TERRAIN_SET, terrain_id, false)


## Calle de baldosas: se marcan las casillas y build_paving() elige bordes y
## esquinas según las vecinas (así los cruces y las calles en L salen bien).
func paving(rect: Rect2i) -> void:
	for cell: Vector2i in cells(rect):
		_paving[cell] = true


func build_paving() -> void:
	var o := ExteriorTiles.PAVING_STONE
	for cell: Vector2i in _paving:
		var left := _paving.has(cell + Vector2i.LEFT)
		var right := _paving.has(cell + Vector2i.RIGHT)
		var up := _paving.has(cell + Vector2i.UP)
		var down := _paving.has(cell + Vector2i.DOWN)
		var cx := 1 if left == right else (0 if not left else 2)
		var cy := 1 if up == down else (0 if not up else 2)
		ground.set_cell(cell, ExteriorTiles.SRC_GEN4, o + Vector2i(cx, cy))


## Agua con orilla (ríos, embalses, mar): se marcan las casillas y build_water() elige la pieza del
## estanque del pack 02 según las vecinas. Fuera del mapa cuenta como agua (el río sigue). Las
## esquinas hacia dentro no existen en el pack: ahí va agua sin orilla.
func water(rect: Rect2i) -> void:
	for cell: Vector2i in cells(rect):
		_water[cell] = true


func build_water(shine_chance: float = 0.2) -> void:
	var o := ExteriorTiles.POND
	for cell: Vector2i in _water:
		var left := _is_water(cell + Vector2i.LEFT)
		var right := _is_water(cell + Vector2i.RIGHT)
		var up := _is_water(cell + Vector2i.UP)
		var down := _is_water(cell + Vector2i.DOWN)
		var cx := 1 if left == right else (0 if not left else 2)
		var cy := 1 if up == down else (0 if not up else 2)
		ground.set_cell(cell, ExteriorTiles.SRC_GEN4, o + Vector2i(cx, cy))
		_covered[cell] = true
		if cx == 1 and cy == 1 and rng.randf() < shine_chance:
			decor.set_cell(cell, ExteriorTiles.SRC_ANIM, ExteriorTiles.WATER_SHINE)


func _is_water(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= size.x or cell.y >= size.y:
		return true
	return _water.has(cell)


## Recuadro 3×3 estirado a `rect` (esquinas, bordes y centro).
func nine_slice(rect: Rect2i, origin: Vector2i, layer: TileMapLayer = null,
		source: int = ExteriorTiles.SRC_GEN4) -> void:
	for cell: Vector2i in cells(rect):
		var cx := 0 if cell.x == rect.position.x else (2 if cell.x == rect.end.x - 1 else 1)
		var cy := 0 if cell.y == rect.position.y else (2 if cell.y == rect.end.y - 1 else 1)
		(layer if layer else ground).set_cell(cell, source, origin + Vector2i(cx, cy))


## Estanque: agua con su orilla, brillos animados y nenúfares.
func pond(rect: Rect2i, lilies: Array = []) -> void:
	nine_slice(rect, ExteriorTiles.POND)
	for cell: Vector2i in cells(rect.grow(-1)):
		if rng.randf() < 0.35:
			decor.set_cell(cell, ExteriorTiles.SRC_ANIM, ExteriorTiles.WATER_SHINE)
	for i: int in lilies.size():
		decor.set_cell(lilies[i], ExteriorTiles.SRC_FLORA, Vector2i(i % 3, 25 + (i / 3) % 3))


# --- Alturas ---

## Meseta del pack 02: borde de tierra arriba y a los lados y pared de roca de 2
## filas abajo, con escaleras en las columnas `stairs_x`. El interior se deja sin
## casilla en Decor: se ve el suelo de Ground (hierba, caminos, hierba alta) y
## se puede pisar. Para varios niveles, se pintan una dentro de otra (de fuera a
## dentro). Las filas o columnas fuera del mapa no se ven.
func plateau(rect: Rect2i, stairs_x: Array = []) -> void:
	var o := ExteriorTiles.PLATEAU
	for cell: Vector2i in cells(rect):
		var cx := 0 if cell.x == rect.position.x else (2 if cell.x == rect.end.x - 1 else 1)
		var cy: int
		if cell.y == rect.position.y:
			cy = 0
		elif cell.y >= rect.end.y - 2:
			cy = 2 + (cell.y - (rect.end.y - 2))
		else:
			cy = 1
		if cx == 1 and cy == 1:
			decor.erase_cell(cell)
			continue
		var coords := o + Vector2i(cx, cy)
		if cy >= 2 and cell.x in stairs_x:
			coords = ExteriorTiles.STAIRS[cy - 2]
		decor.set_cell(cell, ExteriorTiles.SRC_GEN4, coords)
		_covered[cell] = true


## Bordillo de x0 a x1 (incluidas) en la fila y: se salta hacia abajo.
func ledge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var piece := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(Vector2i(x, y), ExteriorTiles.SRC_GEN4, ExteriorTiles.LEDGE[piece])
		_covered[Vector2i(x, y)] = true


## Mancha de tierra (recuadro 3×3 del pack 02).
func soil(rect: Rect2i) -> void:
	nine_slice(rect, ExteriorTiles.SAND_PATCH)


# --- Bosque ---

## Bosque de pinos del pack 02 (árboles de 2 columnas). Usa x e y pares y
## tamaños pares; las zonas que se tocan se unen solas. `snowy` = pinos nevados.
func forest(rect: Rect2i, snowy: bool = false) -> void:
	for cell: Vector2i in cells(rect):
		_forest[cell] = ExteriorTiles.SNOW_FOREST_ORIGIN if snowy else ExteriorTiles.FOREST_ORIGIN


## Suelo nevado (sus variantes repartidas). En la nieve salen Pokémon, como en la hierba alta.
func snow(rect: Rect2i) -> void:
	for cell: Vector2i in cells(rect):
		var pieces := ExteriorTiles.SNOW
		ground.set_cell(cell, ExteriorTiles.SRC_GEN4, pieces[rng.randi() % pieces.size()])


func build_forest() -> void:
	for cell: Vector2i in _forest:
		var o: Vector2i = _forest[cell]
		var col: int
		if cell.x % 2 == 0:
			col = 1 if not _forest.has(cell + Vector2i.LEFT) else 3
		else:
			col = 4 if not _forest.has(cell + Vector2i.RIGHT) else 2
		var row: int
		if cell.y % 2 == 0:
			if not _forest.has(cell + Vector2i.UP):
				row = 0
			else:
				row = 2 if _forest.has(cell + Vector2i(0, 2)) else 4
		else:
			if not _forest.has(cell + Vector2i.DOWN):
				row = 5
			else:
				row = 1 if not _forest.has(cell + Vector2i(0, -2)) else 3
		decor.set_cell(cell, ExteriorTiles.SRC_GEN4, o + Vector2i(col, row))
		var left := cell + Vector2i.LEFT
		if cell.x % 2 == 0 and not _forest.has(left) and row >= 1 and row <= 4:
			above.set_cell(left, ExteriorTiles.SRC_GEN4, o + Vector2i(0, row))


# --- Objetos y adornos ---

## Casa, árbol o pieza de valla: `cell` es su casilla de abajo a la izquierda.
func object(id: StringName, cell: Vector2i) -> Dictionary:
	var o: Dictionary = _catalog[id]
	objects.set_cell(cell, o["source"], o["coords"])
	var object_size: Vector2i = o["size"]
	for dy: int in object_size.y:
		for dx: int in object_size.x:
			_covered[cell + Vector2i(dx, -dy)] = true
	return o


## Casilla de la puerta de una casa colocada en `cell` (abajo a la izquierda).
func door_of(id: StringName, cell: Vector2i) -> Vector2i:
	return cell + (_catalog[id]["door"] as Vector2i)


## Valla de madera de x0 a x1 (incluidas) con la base en la fila y.
func fence(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var id := &"valla"
		if x == x0:
			id = &"valla_izquierda"
		elif x == x1:
			id = &"valla_derecha"
		object(id, Vector2i(x, y))


func deco(cell: Vector2i, coords: Vector2i, source: int = ExteriorTiles.SRC_GEN4) -> void:
	decor.set_cell(cell, source, coords)


## Flores animadas del pack 02 (rojas y blancas).
func flowers(rect: Rect2i, white_chance: float = 0.3) -> void:
	for cell: Vector2i in cells(rect):
		decor.set_cell(cell, ExteriorTiles.SRC_ANIM,
			ExteriorTiles.FLOWERS_WHITE if rng.randf() < white_chance else ExteriorTiles.FLOWERS_RED)


## Flor alta de la flora (cabeza arriba): `top` es su casilla en flora.png.
func tall_flower(cell: Vector2i, top: Vector2i) -> void:
	decor.set_cell(cell + Vector2i.UP, ExteriorTiles.SRC_FLORA, top)
	decor.set_cell(cell, ExteriorTiles.SRC_FLORA, top + Vector2i.DOWN)


## Seto de la flora (2 de alto) de x0 a x1 con la base en la fila y.
func hedge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var col := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(Vector2i(x, y - 1), ExteriorTiles.SRC_FLORA, Vector2i(col, 21))
		decor.set_cell(Vector2i(x, y), ExteriorTiles.SRC_FLORA, Vector2i(col, 24))


## Matojos y florecillas sueltos en la hierba libre.
func sprinkle(rect: Rect2i, chance: float, pieces: Array) -> void:
	for cell: Vector2i in cells(rect):
		if is_free_grass(cell) and rng.randf() < chance:
			decor.set_cell(cell, ExteriorTiles.SRC_GEN4, pieces[rng.randi() % pieces.size()])


func is_free_grass(cell: Vector2i) -> bool:
	var data := ground.get_cell_tile_data(cell)
	return data != null and data.get_custom_data("terrain") == "grass" and decor.get_cell_source_id(cell) == -1 \
		and not _forest.has(cell) and not _covered.has(cell)


# --- Entidades (solo en los mapas de muestra) ---

func spawn(spawn_name: String, cell: Vector2i) -> void:
	var marker := Marker2D.new()
	marker.name = spawn_name
	marker.position = Grid.to_world(cell)
	root.get_node(^"Spawns").add_child(marker)


func npc(npc_name: String, sheet: String, cell: Vector2i, facing: int, lines: PackedStringArray,
		props: Dictionary = {}) -> void:
	var node: Node2D = (load(NPC_SCENE) as PackedScene).instantiate()
	node.name = npc_name
	node.position = Grid.to_world(cell)
	node.set(&"sprite_sheet", load(CHARACTERS + sheet + ".png"))
	node.set(&"initial_facing", facing)
	node.set(&"lines", lines)
	for key: String in props:
		node.set(StringName(key), props[key])
	entities.add_child(node)


## Entrenador de data/trainers/*.json: su sprite sale de su clase. Te ve a `sight` casillas.
func trainer(node_name: String, trainer_id: StringName, cell: Vector2i, facing: int, sight: int = 4) -> void:
	var node: Node2D = (load(TRAINER_SCENE) as PackedScene).instantiate()
	node.name = node_name
	node.position = Grid.to_world(cell)
	node.set(&"trainer_id", trainer_id)
	node.set(&"initial_facing", facing)
	node.set(&"sight_range", sight)
	entities.add_child(node)


## Conexión sin fundido con el mapa vecino por un borde (MapConnection); `span` = solo un tramo del
## borde [desde, hasta), para que un borde lleve a varios mapas.
func connect_edge(edge: String, target_map: StringName, offset: int = 0, span: Vector2i = Vector2i.ZERO) -> void:
	var c := MapConnection.new()
	c.edge = edge
	c.target_map = target_map
	c.offset = offset
	c.span = span
	root.get(&"data").connections.append(c)


func follower(follower_name: String, species: StringName, shiny: bool, leader: String, cell: Vector2i) -> void:
	var node: Node2D = (load(FOLLOWER_SCENE) as PackedScene).instantiate()
	node.name = follower_name
	node.position = Grid.to_world(cell)
	entities.add_child(node)
	node.set(&"species", species)
	node.set(&"shiny", shiny)
	node.set(&"leader_path", NodePath("../" + leader))


func sign_text(sign_name: String, cell: Vector2i, lines: PackedStringArray) -> void:
	var node: Node2D = (load(SIGN_SCENE) as PackedScene).instantiate()
	node.name = sign_name
	node.position = Grid.to_world(cell)
	node.set(&"lines", lines)
	entities.add_child(node)


# --- Utilidades ---

static func cells(rect: Rect2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			out.append(Vector2i(x, y))
	return out


func _layer(layer_name: String, tileset: TileSet, parent: Node) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = tileset
	parent.add_child(layer)
	return layer


func _node(node_name: String, parent: Node) -> Node2D:
	var node := Node2D.new()
	node.name = node_name
	parent.add_child(node)
	return node


static func _own(node: Node, owner_node: Node) -> void:
	for child: Node in node.get_children():
		child.owner = owner_node
		if child.scene_file_path.is_empty():
			_own(child, owner_node)
