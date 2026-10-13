class_name ProtagonistSprite
extends CharacterSprite
## Regiones de una hoja intacta; alterna pasos sin pintar ni alterar el asset.
var identity: StringName = &""
var poses: Array[AtlasTexture] = []

func set_identity(id: StringName) -> void:
	identity = id
	poses = PlayerIdentity.walk_frames(id)
	if poses.is_empty():
		hframes = 4
		vframes = 4
		scale = Vector2.ONE
		return
	hframes = 1
	vframes = 1
	walk_texture = poses[0]
	run_texture = null
	_show(0)

func _show(column: int) -> void:
	if poses.is_empty():
		super(column)
		return
	texture = poses[ROWS.get(facing, 0) * 4 + column]
	_fit_to_tile()

func _fit_to_tile() -> void:
	if poses.is_empty():
		super()
		return
	if texture:
		scale = Vector2.ONE * (56.0 / texture.get_height())
		offset = Vector2(0, 16.0 / scale.y - texture.get_height() / 2.0)
		_apply_bush()
