class_name WorldTravel
extends RefCounted
static func record_visit(map: MapRoot) -> void:
	GameState.set_flag(StringName("visited_map:" + String(map.get_map_id())))
static func destinations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for destination: Dictionary in GameState.world_config.get("field", {}).get("flight_destinations", []):
		if GameState.flag(StringName("visited_map:" + str(destination.get("map", "")))):
			result.append(destination.duplicate(true))
	return result
static func fly(id: StringName) -> Error:
	var map := SceneManager.current_map
	if map == null or map.data == null or not map.data.can_fly_from or not FieldActions.available(&"fly", map):
		return ERR_UNAVAILABLE
	for destination: Dictionary in destinations():
		if str(destination.get("id", "")) == String(id):
			var target := StringName(destination.get("map", ""))
			if not SceneManager.map_exists(target):
				return ERR_FILE_NOT_FOUND
			await SceneManager.change_map(target, StringName(destination.get("spawn", "default")))
			return OK
	return ERR_DOES_NOT_EXIST
