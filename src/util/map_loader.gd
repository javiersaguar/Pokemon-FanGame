class_name MapLoader
extends RefCounted
## Cache de escenas (no instancias): cada entrada conserva estado propio del mapa.
const CACHE_LIMIT := 16
static var _cache: Dictionary = {}

static func clear() -> void:
	_cache.clear()

## No entra al árbol ni altera partida; el consumidor libera o incorpora `map`.
static func prepare(map_id: StringName) -> Dictionary:
	var started := Time.get_ticks_usec()
	var path := MapRoot.path_from_id(map_id)
	if map_id == &"" or not ResourceLoader.exists(path):
		return {"error": ERR_FILE_NOT_FOUND}
	if not _cache.has(map_id):
		var resource := load(path) as PackedScene
		if resource == null:
			return {"error": ERR_INVALID_DATA}
		if _cache.size() >= CACHE_LIMIT:
			_cache.erase(_cache.keys()[0])
		_cache[map_id] = resource
	var instance: Node = _cache[map_id].instantiate()
	if not instance is MapRoot:
		instance.free()
		return {"error": ERR_INVALID_DATA}
	var map := instance as MapRoot
	if map.data == null or map.get_ground() == null or map.get_ground().get_used_rect().size == Vector2i.ZERO or map.get_map_id() != map_id:
		map.free()
		return {"error": ERR_INVALID_DATA}
	return {"error": OK, "map": map, "prepare_usec": Time.get_ticks_usec() - started}

static func spawn_tile(map: MapRoot, spawn_id: StringName) -> Variant:
	var spawn := map.get_node_or_null(NodePath("Spawns/" + String(spawn_id))) as Node2D
	if spawn == null:
		return null
	return Grid.to_tile(map.to_local(spawn.global_position))

static func valid_tile(map: MapRoot, tile: Variant) -> bool:
	return tile is Vector2i and map.get_ground().get_used_rect().has_point(tile) and map.get_ground().get_cell_source_id(tile) >= 0

static func check_spawn(map_id: StringName, spawn: StringName) -> Error:
	var result := prepare(map_id)
	if result.error != OK:
		return result.error
	var map: MapRoot = result.map
	var valid := valid_tile(map, spawn_tile(map, spawn))
	map.free()
	return OK if valid else ERR_INVALID_DATA

static func check_position(state: Dictionary) -> Error:
	var position: Variant = state.get("position", {})
	if not position is Dictionary:
		return ERR_INVALID_DATA
	var tile: Variant = position.get("tile", [])
	if not tile is Array or tile.size() != 2:
		return ERR_INVALID_DATA
	for value: Variant in tile:
		if not (value is int or value is float) or float(value) != floorf(float(value)):
			return ERR_INVALID_DATA
	var result := prepare(StringName(position.get("map", "")))
	if result.error != OK:
		return result.error
	var map: MapRoot = result.map
	var valid := valid_tile(map, Vector2i(int(tile[0]), int(tile[1])))
	map.free()
	return OK if valid else ERR_INVALID_DATA
