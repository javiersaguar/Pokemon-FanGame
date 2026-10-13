class_name PlayerIdentity
extends RefCounted
## Identidad visual persistente; las partidas antiguas conservan su aspecto.
const PATH := "res://data/protagonistas.json"

static func catalogue() -> Dictionary:
	return JsonFile.read_dict(PATH).get("characters", {})

static func info(id: StringName) -> Dictionary:
	return catalogue().get(String(id), {}).duplicate(true)

static func ids(gender: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: String in catalogue():
		if StringName(info(StringName(id)).gender) == gender:
			out.append(StringName(id))
	return out

static func destination(id: StringName) -> Dictionary:
	var data := info(id)
	if data.is_empty(): return {}
	return {"map": data.start_map, "spawn": data.start_spawn,
		"healing_map": data.start_map, "healing_spawn": data.start_spawn}

static func texture(id: StringName, kind: StringName) -> AtlasTexture:
	var data := info(id)
	if data.is_empty() or not ResourceLoader.exists(data.atlas): return null
	var sheet := load(data.atlas) as Texture2D
	var cell := Vector2(sheet.get_width() / float(data.columns), sheet.get_height() / float(data.rows))
	var rect: Array = data.walk_region if kind == &"walk" else (data.back_cell if kind == &"back" else data.front_cell)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(Vector2(rect[0], rect[1]) * cell, Vector2(rect[2], rect[3]) * cell if rect.size() == 4 else cell)
	if kind != &"walk" and data.has("front_rect"):
		var pixel_rect: Array = data.back_rect if kind == &"back" else data.front_rect
		atlas.region = Rect2(pixel_rect[0], pixel_rect[1], pixel_rect[2], pixel_rect[3])
	return atlas

static func walk_frames(id: StringName) -> Array[AtlasTexture]:
	var out: Array[AtlasTexture] = []
	var data := info(id)
	if data.is_empty() or not ResourceLoader.exists(data.atlas): return out
	var source := load(data.atlas) as Texture2D
	var image := source.get_image()
	for region: Array in data.get("walk_frames", []):
		var rect := Rect2i(region[0], region[1], region[2], region[3])
		var used := image.get_region(rect).get_used_rect()
		var atlas := AtlasTexture.new()
		atlas.atlas = source
		atlas.region = Rect2(rect.position + used.position, used.size)
		out.append(atlas)
	return out
