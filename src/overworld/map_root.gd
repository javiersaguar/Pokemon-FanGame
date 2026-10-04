class_name MapRoot
extends Node2D
## Raíz de cada escena de mapa. Estructura esperada (ver docs/contratos.md):
##   Ground, Decor, Above (TileMapLayer) · Entities (Node2D con y_sort) ·
##   Warps · Spawns (Marker2D por spawn_id) · Triggers

const MAPS_DIR := "res://maps/"
const DEFAULT_SPAWN := &"default"

@export var data: MapData


## Id del mapa: data.id o, si está vacío, la ruta de la escena dentro de maps/.
func get_map_id() -> StringName:
	if data and data.id != &"":
		return data.id
	return id_from_path(scene_file_path)


static func id_from_path(path: String) -> StringName:
	if path.begins_with(MAPS_DIR):
		path = path.substr(MAPS_DIR.length())
	return StringName(path.get_basename())


static func path_from_id(map_id: StringName) -> String:
	return MAPS_DIR + String(map_id) + ".tscn"


func get_display_name() -> String:
	return data.display_name if data else String(get_map_id())


func get_ground() -> TileMapLayer:
	return get_node_or_null(^"Ground") as TileMapLayer


func get_entities() -> Node2D:
	return get_node_or_null(^"Entities") as Node2D


## Spawn por id. Si no existe, el spawn por defecto o el primero que haya.
func get_spawn(spawn_id: StringName) -> Node2D:
	var spawns := get_node_or_null(^"Spawns")
	if spawns == null or spawns.get_child_count() == 0:
		push_error("MapRoot %s: no tiene spawns." % get_map_id())
		return null
	var spawn := spawns.get_node_or_null(NodePath(String(spawn_id))) as Node2D
	if spawn == null:
		if spawn_id != DEFAULT_SPAWN:
			push_error("MapRoot %s: no existe el spawn '%s'." % [get_map_id(), spawn_id])
		spawn = spawns.get_node_or_null(NodePath(String(DEFAULT_SPAWN))) as Node2D
	return spawn if spawn else spawns.get_child(0) as Node2D


## Rectángulo del mapa en píxeles (según las casillas usadas de Ground).
func get_bounds() -> Rect2i:
	var ground := get_ground()
	if ground == null:
		return Rect2i()
	var used := ground.get_used_rect()
	return Rect2i(used.position * Grid.TILE, used.size * Grid.TILE)


func get_layer(layer_name: StringName) -> TileMapLayer:
	return get_node_or_null(NodePath(String(layer_name))) as TileMapLayer


## Valor de la custom data `key` en la casilla. Decor tiene prioridad sobre Ground.
func tile_custom_data(tile: Vector2i, key: StringName, default: Variant = null) -> Variant:
	for layer_name: StringName in [&"Decor", &"Ground"]:
		var layer := get_layer(layer_name)
		if layer == null or layer.tile_set == null:
			continue
		if layer.tile_set.get_custom_data_layer_by_name(key) == -1:
			continue
		var tile_data := layer.get_cell_tile_data(tile)
		if tile_data:
			return tile_data.get_custom_data(key)
	return default


## Tipo de terreno de la casilla ("grass", "tall_grass", "water", "counter"...).
func terrain_at(tile: Vector2i) -> String:
	return str(tile_custom_data(tile, &"terrain", ""))


func is_encounter_tile(tile: Vector2i) -> bool:
	return bool(tile_custom_data(tile, &"encounter", false))


func get_warps() -> Array[Warp]:
	var out: Array[Warp] = []
	var warps := get_node_or_null(^"Warps")
	if warps:
		for child: Node in warps.get_children():
			if child is Warp:
				out.append(child)
	return out


func warp_at(tile: Vector2i) -> Warp:
	for warp: Warp in get_warps():
		if warp.contains_tile(tile):
			return warp
	return null
