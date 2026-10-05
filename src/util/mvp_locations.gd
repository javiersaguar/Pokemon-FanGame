class_name MvpLocations
extends RefCounted
## Roles del guion: test/real usan los mismos eventos sin rutas en los scripts.
static func target(role: StringName, profile: String = "") -> Dictionary:
	var cfg: Dictionary = GameState.world_config.get("mvp_locations", {})
	if profile.is_empty():
		profile = str(cfg.get("profile", "test"))
	return cfg.get("profiles", {}).get(profile, {}).get(String(role), {}).duplicate()

static func validate(profile: String) -> PackedStringArray:
	var errors := PackedStringArray()
	var roles: Dictionary = GameState.world_config.get("mvp_locations", {}).get("profiles", {}).get(profile, {})
	if roles.is_empty():
		return ["Perfil de mapas desconocido: %s" % profile]
	for role: String in roles:
		var place: Dictionary = roles[role]
		var path := MapRoot.path_from_id(StringName(place.get("map", "")))
		if not ResourceLoader.exists(path):
			errors.append("%s: falta %s" % [role, path])
			continue
		var scene := load(path) as PackedScene
		var map := scene.instantiate() as MapRoot
		if map == null:
			errors.append("%s: raíz no MapRoot" % role)
			continue
		var spawn := str(place.get("spawn", "default"))
		if map.get_node_or_null("Spawns/" + spawn) == null:
			errors.append("%s: falta aparición %s" % [role, spawn])
		map.free()
	return errors

static func activate(profile: String) -> PackedStringArray:
	var errors := validate(profile)
	if errors.is_empty():
		GameState.world_config.mvp_locations.profile = profile
	return errors

static func new_game_config() -> Dictionary:
	var cfg: Dictionary = GameState.world_config.get("new_game", {}).duplicate()
	var start := target(&"start")
	if not start.is_empty():
		cfg.merge(start, true)
	var heal := target(&"healing")
	if not heal.is_empty():
		cfg["healing_map"] = heal.get("map", "")
		cfg["healing_spawn"] = heal.get("spawn", "default")
	return cfg
