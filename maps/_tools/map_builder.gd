class_name MapBuilder
extends RefCounted
@warning_ignore_start("integer_division")
## Ayuda para montar mapas por código con el tileset de exteriores (los mapas de
## muestra y la sala de pruebas). Después se retocan en el editor: el código solo
## coloca casillas del TileSet y escenas de entidades, no dibuja nada.

const T := Grid.TILE
const NPC_SCENE := "res://src/overworld/npc/npc.tscn"
const ITEM_SCENE := "res://src/overworld/item_ball/item_ball.tscn"
const SIGN_SCENE := "res://src/overworld/sign/sign.tscn"
const FOLLOWER_SCENE := "res://src/overworld/follower/follower.tscn"
const WARP_SCRIPT := "res://src/overworld/warp/warp.gd"
const MAP_ROOT_SCRIPT := "res://src/overworld/map_root.gd"
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
var _objects_catalog: Dictionary


func _init(map_name: String, map_size: Vector2i, data: MapData, seed_value: int = 1) -> void:
	size = map_size
	rng.seed = seed_value
	var tileset: TileSet = load(ExteriorTiles.TILESET)
	_objects_catalog = ExteriorTiles.objects()
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
		err = ResourceSaver.save(scene, path)
	root.free()
	return err


# --- Suelo ---

## Hierba en todo el mapa, con sus 3 variantes repartidas sin patrón.
func fill_grass() -> void:
	for y: int in size.y:
		for x: int in size.x:
			var roll := rng.randf()
			var variant := 0 if roll < 0.8 else (1 if roll < 0.9 else 2)
			ground.set_cell(Vector2i(x, y), ExteriorTiles.SRC_GEN4, ExteriorTiles.GRASS[variant])


## Pinta un terreno de autotile (hierba alta o camino): Godot elige las casillas
## de borde según los vecinos.
func terrain(cell_list: Array[Vector2i], terrain_id: int) -> void:
	ground.set_cells_terrain_connect(cell_list, ExteriorTiles.TERRAIN_SET, terrain_id, false)


## Textura de casillas sueltas (adoquines): `origin` es su esquina en el atlas y
## `period`, cuántas variantes hay. Se reparten al azar para que no se vea un
## dibujo repetido.
func pattern(rect: Rect2i, origin: Vector2i, period: Vector2i, layer: TileMapLayer = null) -> void:
	for cell: Vector2i in cells(rect):
		(layer if layer else ground).set_cell(cell, ExteriorTiles.SRC_GEN4,
			origin + Vector2i(rng.randi() % period.x, rng.randi() % period.y))


## Recuadro 3×3 estirado a `rect` (esquinas, bordes y centro).
func nine_slice(rect: Rect2i, origin: Vector2i, layer: TileMapLayer = null, source: int = ExteriorTiles.SRC_GEN4) -> void:
	for cell: Vector2i in cells(rect):
		var cx := 0 if cell.x == rect.position.x else (2 if cell.x == rect.end.x - 1 else 1)
		var cy := 0 if cell.y == rect.position.y else (2 if cell.y == rect.end.y - 1 else 1)
		(layer if layer else ground).set_cell(cell, source, origin + Vector2i(cx, cy))


## Estanque: agua con su orilla, brillos animados y algún nenúfar.
func pond(rect: Rect2i, lilies: Array = []) -> void:
	nine_slice(rect, ExteriorTiles.POND)
	var inner := rect.grow(-1)
	for cell: Vector2i in cells(inner):
		if rng.randf() < 0.35:
			decor.set_cell(cell, ExteriorTiles.SRC_ANIM, ExteriorTiles.WATER_SHINE)
	for i: int in lilies.size():
		decor.set_cell(lilies[i], ExteriorTiles.SRC_FLORA, Vector2i(i % 3, 25 + (i / 3) % 3))


# --- Bosque, mesetas y bordillos ---

## Bosque de pinos del pack 02. Cada árbol ocupa 2 columnas (x par = mitad
## izquierda); las filas se encadenan solas. Usa x e y pares y tamaños pares.
func forest(rect: Rect2i) -> void:
	for cell: Vector2i in cells(rect):
		_forest[cell] = true


func build_forest() -> void:
	var o := ExteriorTiles.FOREST_ORIGIN
	for cell: Vector2i in _forest:
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
		# La copa que sobresale por la izquierda del bosque.
		var left := cell + Vector2i.LEFT
		if cell.x % 2 == 0 and not _forest.has(left) and row >= 1 and row <= 4:
			above.set_cell(left, ExteriorTiles.SRC_GEN4, o + Vector2i(0, row))


## Meseta con pared de roca y escaleras en las columnas `stairs_x`.
func plateau(rect: Rect2i, stairs_x: Array = []) -> void:
	var p := ExteriorTiles.PLATEAU
	for cell: Vector2i in cells(rect):
		var cx := 0 if cell.x == rect.position.x else (2 if cell.x == rect.end.x - 1 else 1)
		var cy: int
		if cell.y == rect.position.y:
			cy = 0
		elif cell.y >= rect.end.y - 2:
			cy = 2 + (cell.y - (rect.end.y - 2))
		else:
			cy = 1
		var coords := p + Vector2i(cx, cy)
		if cy >= 2 and cell.x in stairs_x:
			coords = ExteriorTiles.STAIRS[cy - 2]
		decor.set_cell(cell, ExteriorTiles.SRC_GEN4, coords)


## Bordillo de x0 a x1 (incluidos) en la fila y: se salta hacia abajo.
func ledge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var piece := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(Vector2i(x, y), ExteriorTiles.SRC_GEN4, ExteriorTiles.LEDGE[piece])


# --- Objetos y adornos ---

## Casa o árbol grande: `cell` es su casilla de abajo a la izquierda.
func object(id: StringName, cell: Vector2i) -> Dictionary:
	var o: Dictionary = _objects_catalog[id]
	objects.set_cell(cell, o["source"], o["coords"])
	return o


func deco(cell: Vector2i, coords: Vector2i, source: int = ExteriorTiles.SRC_GEN4, layer: TileMapLayer = null) -> void:
	(layer if layer else decor).set_cell(cell, source, coords)


## Flor de 2 casillas de la flora (cabeza arriba): `top` es su casilla en flora.png.
func tall_flower(cell: Vector2i, top: Vector2i) -> void:
	decor.set_cell(cell + Vector2i.UP, ExteriorTiles.SRC_FLORA, top)
	decor.set_cell(cell, ExteriorTiles.SRC_FLORA, top + Vector2i.DOWN)


## Seto de la flora (2 de alto) de x0 a x1 en la fila de abajo `y`.
func hedge(x0: int, x1: int, y: int) -> void:
	for x: int in range(x0, x1 + 1):
		var col := 0 if x == x0 else (2 if x == x1 else 1)
		decor.set_cell(Vector2i(x, y - 1), ExteriorTiles.SRC_FLORA, Vector2i(col, 21))
		decor.set_cell(Vector2i(x, y), ExteriorTiles.SRC_FLORA, Vector2i(col, 24))


## Adornos sueltos (matojos, florecillas) en la hierba libre.
func sprinkle(rect: Rect2i, chance: float, pieces: Array) -> void:
	for cell: Vector2i in cells(rect):
		if is_free_grass(cell) and rng.randf() < chance:
			decor.set_cell(cell, ExteriorTiles.SRC_GEN4, pieces[rng.randi() % pieces.size()])


func flowers(rect: Rect2i, white_chance: float = 0.3) -> void:
	for cell: Vector2i in cells(rect):
		var coords := ExteriorTiles.FLOWERS_WHITE if rng.randf() < white_chance else ExteriorTiles.FLOWERS_RED
		decor.set_cell(cell, ExteriorTiles.SRC_ANIM, coords)


func is_free_grass(cell: Vector2i) -> bool:
	var data := ground.get_cell_tile_data(cell)
	return data != null and data.get_custom_data("terrain") == "grass" and decor.get_cell_source_id(cell) == -1 \
		and not _forest.has(cell)


# --- Entidades ---

func spawn(spawn_name: String, cell: Vector2i) -> void:
	var marker := Marker2D.new()
	marker.name = spawn_name
	marker.position = Grid.to_world(cell)
	root.get_node(^"Spawns").add_child(marker)


func npc(npc_name: String, sheet: String, cell: Vector2i, facing: int, lines: PackedStringArray,
		props: Dictionary = {}) -> Node:
	var node: Node2D = (load(NPC_SCENE) as PackedScene).instantiate()
	node.name = npc_name
	node.position = Grid.to_world(cell)
	node.set(&"sprite_sheet", load(CHARACTERS + sheet + ".png"))
	node.set(&"initial_facing", facing)
	node.set(&"display_name", props.get("display_name", ""))
	node.set(&"lines", lines)
	for key: String in props:
		if key != "display_name":
			node.set(StringName(key), props[key])
	entities.add_child(node)
	return node


func follower(follower_name: String, species: StringName, shiny: bool, leader: String, cell: Vector2i) -> void:
	var node: Node2D = (load(FOLLOWER_SCENE) as PackedScene).instantiate()
	node.name = follower_name
	node.position = Grid.to_world(cell)
	entities.add_child(node)
	node.set(&"species", species)
	node.set(&"shiny", shiny)
	node.set(&"leader_path", NodePath("../" + leader))


func item(item_name: String, cell: Vector2i, item_id: StringName, hidden: bool = false) -> void:
	var node: Node2D = (load(ITEM_SCENE) as PackedScene).instantiate()
	node.name = item_name
	node.position = Grid.to_world(cell)
	node.set(&"item_id", item_id)
	node.set(&"hidden_item", hidden)
	entities.add_child(node)


## Cartel: la casilla de dibujo va en el TileSet; la entidad solo pone el texto.
func sign(sign_name: String, cell: Vector2i, lines: PackedStringArray) -> void:
	var node: Node2D = (load(SIGN_SCENE) as PackedScene).instantiate()
	node.name = sign_name
	node.position = Grid.to_world(cell)
	node.set(&"lines", lines)
	entities.add_child(node)


## `facing`: Warp.Facing (0 = mantener).
func warp(warp_name: String, cell: Vector2i, target_map: StringName, target_spawn: StringName,
		facing: int = 0) -> void:
	var node := Node2D.new()
	node.set_script(load(WARP_SCRIPT))
	node.name = warp_name
	node.position = Grid.to_world(cell)
	node.set(&"target_map", target_map)
	node.set(&"target_spawn", target_spawn)
	node.set(&"arrival_facing", facing)
	root.get_node(^"Warps").add_child(node)


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


## Para que PackedScene guarde los nodos hijos (los de las escenas instanciadas
## conservan su propia escena).
static func _own(node: Node, owner_node: Node) -> void:
	for child: Node in node.get_children():
		child.owner = owner_node
		if child.scene_file_path.is_empty():
			_own(child, owner_node)
