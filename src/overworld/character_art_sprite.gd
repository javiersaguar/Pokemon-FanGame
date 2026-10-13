@tool
class_name CharacterArtSprite
extends CharacterSprite
var poses: Array[AtlasTexture] = []

func set_art(id: StringName) -> void:
	poses = CharacterArt.walk_frames(id)
	if poses.size() != 16: return
	hframes = 1
	vframes = 1
	walk_texture = poses[0]
	run_texture = null
	_show(0)

func _show(column: int) -> void:
	if poses.size() != 16:
		super(column)
		return
	texture = poses[ROWS.get(facing, 0) * 4 + column]
	_fit_to_tile()

func _fit_to_tile() -> void:
	if poses.is_empty() or texture == null:
		super()
		return
	var factor := CharacterArt.display_scale(texture.get_size() - Vector2(8,8), Vector2(64, 64))
	scale = Vector2.ONE * factor
	offset = Vector2(0, 16.0 / factor - texture.get_height() / 2.0)
	_apply_bush()
