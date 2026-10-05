class_name MapRoot
extends Node2D
## Raíz de cada escena de mapa. Estructura esperada (ver docs/contratos.md):
##   Ground, Decor, Above (TileMapLayer) · Entities (Node2D con y_sort, con
##   Objects dentro: TileMapLayer con y_sort para casas y árboles) ·
##   Warps · Spawns (Marker2D por spawn_id) · Triggers

const MAPS_DIR := "res://maps/"
## Capas de casillas en orden de prioridad para la custom data (terrain...).
## Objects (dentro de Entities, con y-sort) lleva casas y árboles.
const TILE_LAYERS: Array[StringName] = [&"Decor", &"Entities/Objects", &"Ground"]
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


## Ids de todos los mapas de maps/, ordenados.
static func list_all() -> Array[StringName]:
	var out: Array[StringName] = []
	_collect(MAPS_DIR, out)
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


static func _collect(dir_path: String, out: Array[StringName]) -> void:
	for entry: String in ResourceLoader.list_directory(dir_path):
		if entry.ends_with("/"):
			_collect(dir_path + entry, out)
		elif entry.ends_with(".tscn"):
			out.append(id_from_path(dir_path + entry))


## Identidad persistente de captura: export > tabla de datos > ID del mapa.
func get_zone_id() -> StringName:
	if data != null and data.zone_id != &"":
		return data.zone_id
	if data != null and data.encounter_table != &"" and DataDB.has_encounter_table(data.encounter_table):
		var table := DataDB.encounter_table(data.encounter_table)
		if str(table.get("zone_id", "")) != "":
			return StringName(table.zone_id)
	return get_map_id()


func get_display_name() -> String:
	return WorldNames.resolve(data.display_name) if data else String(get_map_id())


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


## Valor de la custom data `key` en la casilla: el de la primera capa de
## TILE_LAYERS que lo tenga puesto (no vacío). Así un adorno de Decor sin terreno
## (flores, brillos del agua) no tapa la hierba alta o el agua de Ground.
func tile_custom_data(tile: Vector2i, key: StringName, default: Variant = null) -> Variant:
	for layer_name: StringName in TILE_LAYERS:
		var layer := get_layer(layer_name)
		if layer == null or layer.tile_set == null:
			continue
		if layer.tile_set.get_custom_data_layer_by_name(key) == -1:
			continue
		var tile_data := layer.get_cell_tile_data(tile)
		if tile_data:
			var value: Variant = tile_data.get_custom_data(key)
			if not _is_unset(value):
				return value
	return default


static func _is_unset(value: Variant) -> bool:
	match typeof(value):
		TYPE_NIL:
			return true
		TYPE_BOOL:
			return not value
		TYPE_STRING, TYPE_STRING_NAME:
			return String(value).is_empty()
	return false


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


func get_triggers() -> Array[Trigger]:
	var out: Array[Trigger] = []
	var triggers := get_node_or_null(^"Triggers")
	if triggers:
		for child: Node in triggers.get_children():
			if child is Trigger:
				out.append(child)
	return out


## Primer disparador de pisar que esté en `tile` y se pueda disparar.
func trigger_at(tile: Vector2i) -> Trigger:
	for trigger: Trigger in get_triggers():
		if trigger.mode == Trigger.Mode.STEP and trigger.contains_tile(tile) and trigger.can_fire():
			return trigger
	return null


func enter_triggers() -> Array[Trigger]:
	var out: Array[Trigger] = []
	for trigger: Trigger in get_triggers():
		if trigger.mode == Trigger.Mode.ON_ENTER and trigger.can_fire():
			out.append(trigger)
	return out

func connection_at(tile: Vector2i) -> MapConnection:
	if data == null or get_ground() == null:
		return null
	var bounds := get_ground().get_used_rect()
	for connection: MapConnection in data.connections:
		if connection.matches(tile, bounds):
			return connection
	return null
