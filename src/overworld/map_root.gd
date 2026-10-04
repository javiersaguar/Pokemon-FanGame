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
