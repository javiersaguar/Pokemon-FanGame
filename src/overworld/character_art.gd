class_name CharacterArt
extends RefCounted
## Atlas intactos: retrato de combate y dieciséis poses del mapa por personaje.
const CONFIG := "res://data/character_art.json"
static var _characters: Dictionary = {}
static var _loaded := false

static func entries() -> Dictionary:
	if not _loaded:
		_loaded = true
		_characters = JsonFile.read_dict(CONFIG).get("characters", {})
	return _characters.duplicate(true)

static func info(id: StringName) -> Dictionary:
	return entries().get(String(id), {})

static func resolve(ids: Array) -> StringName:
	for id: Variant in ids:
		if not info(StringName(str(id))).is_empty(): return StringName(str(id))
	return &""

static func texture(id: StringName, rect: Array) -> AtlasTexture:
	var data := info(id)
	if data.is_empty() or rect.size() != 4 or not ResourceLoader.exists(str(data.get("atlas", ""))): return null
	var atlas := AtlasTexture.new()
	atlas.atlas = load(str(data.atlas))
	atlas.region = Rect2(float(rect[0]),float(rect[1]),float(rect[2]),float(rect[3]))
	return atlas

static func battle_texture(id: StringName) -> AtlasTexture:
	return texture(id, info(id).get("battle_rect", []))

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
