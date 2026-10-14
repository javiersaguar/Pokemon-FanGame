class_name CharacterArt
extends RefCounted
## Atlas intactos: retrato de combate y dieciséis poses del mapa por personaje.
const CONFIG := "res://data/character_art.json"
const BATTLE_MAX := Vector2(176,180)
static var _characters: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if not _loaded:
		_loaded = true
		_characters = JsonFile.read_dict(CONFIG).get("characters", {})

static func entries() -> Dictionary:
	_ensure_loaded()
	return _characters.duplicate(true)

static func info(id: StringName) -> Dictionary:
	_ensure_loaded()
	var data: Dictionary = _characters.get(String(id), {})
	return data.duplicate(true)

static func resolve(ids: Array) -> StringName:
	_ensure_loaded()
	for id: Variant in ids:
		if _characters.has(str(id)): return StringName(str(id))
	return &""

static func texture(id: StringName, rect: Array, source: String = "") -> AtlasTexture:
	_ensure_loaded()
	var data: Dictionary = _characters.get(String(id), {})
	if data.is_empty() or rect.size() != 4: return null
	var path := source if not source.is_empty() else str(data.get("atlas", ""))
	if not ResourceLoader.exists(path): return null
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path)
	atlas.region = Rect2(float(rect[0]),float(rect[1]),float(rect[2]),float(rect[3]))
	return atlas

static func battle_texture(id: StringName) -> AtlasTexture:
	var data := info(id)
	return texture(id, data.get("battle_rect", []), str(data.get("battle_atlas", "")))

static func walk_frames(id: StringName) -> Array[AtlasTexture]:
	var frames: Array[AtlasTexture] = []
	var size := Vector2.ZERO
	for rect: Array in info(id).get("walk_frames", []):
		var pose := texture(id, rect)
		frames.append(pose)
		if pose != null: size = size.max(pose.region.size)
	size += Vector2(8,8)
	for pose: AtlasTexture in frames:
		if pose == null: continue
		var padding := size - pose.region.size
		pose.margin = Rect2(Vector2(roundf(padding.x * 0.5),padding.y - 4),padding)
	return frames

static func display_scale(size: Vector2, maximum: Vector2) -> float:
	var factor := 1.0
	while size.x * factor > maximum.x or size.y * factor > maximum.y:
		factor *= 0.5
	return factor
