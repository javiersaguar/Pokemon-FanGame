class_name UiTextures
extends RefCounted

static func item(id: StringName) -> Texture2D:
	var path := "res://assets/sprites/items/%s.png" % id
	return load(path) if ResourceLoader.exists(path) else null

static func pokemon_icon(p: Pokemon) -> Texture2D:
	var path := "res://assets/sprites/pokemon/%s/%s.png" % ["icons_shiny" if p.shiny else "icons", p.species_id]
	if not ResourceLoader.exists(path): return null
	var texture := load(path) as Texture2D
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, texture.get_width() / 2, texture.get_height())
	return atlas
