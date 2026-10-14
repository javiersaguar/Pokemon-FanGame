class_name TrainerPortraits
extends RefCounted
## Retratos unidos al mismo portador: entran, salen y se ocultan juntos.
const PAIR_MAX := Vector2(112,180)
const SEPARATION := (PAIR_MAX.x + 8.0) * 0.5

static func configure_group(root: Sprite2D, trainers: Array, feet := false, photos := false) -> void:
	var previous := root.get_node_or_null(^"PartnerTrainer")
	if previous != null: previous.free()
	root.texture = null
	root.visible = false
	if trainers.is_empty(): return
	var pair := trainers.size() > 1
	_paint(root,trainers[0],PAIR_MAX if pair else CharacterArt.BATTLE_MAX,feet,photos)
	if not pair: return
	if root.texture == null:
		_paint(root,trainers[1],CharacterArt.BATTLE_MAX,feet,photos)
		return
	var partner := Sprite2D.new()
	partner.name = "PartnerTrainer"
	_paint(partner,trainers[1],PAIR_MAX,feet,photos)
	root.add_child(partner)
	if partner.texture == null: return
	var factor := root.scale.x
	root.offset.x -= SEPARATION / factor
	var baseline := 0.0 if feet else (root.texture.get_height()*factor-partner.texture.get_height()*partner.scale.y)*0.5
	partner.position = Vector2(SEPARATION / factor,baseline / factor)
	partner.scale /= root.scale

static func names(trainers: Array) -> String:
	var values := PackedStringArray()
	for trainer: Dictionary in trainers:
		var fallback := str(trainer.get("display_name", "Entrenador"))
		values.append(str(trainer.get("name", fallback)) if trainers.size() > 1 else fallback)
	return " y ".join(values)

static func _paint(sprite: Sprite2D, trainer: Dictionary, maximum: Vector2, feet: bool, photos: bool) -> void:
	var photo: Texture2D = RealPhoto.load_texture(str(trainer.get("real_photo", ""))) if photos else null
	var art := CharacterArt.battle_texture(StringName(trainer.get("art_id", "")))
	var texture: Texture2D = photo if photo != null else art if art != null else PlaceholderArt.load_texture(str(trainer.get("battle_sprite", "")))
	sprite.texture = texture
	sprite.visible = texture != null
	sprite.centered = not feet
	sprite.offset = Vector2.ZERO
	sprite.scale = Vector2.ONE
	if texture == null: return
	if feet: sprite.offset = Vector2(-texture.get_width()*0.5,-texture.get_height()).round()
	var photo_limit := maximum.min(RealPhoto.MAX_SIZE)
	var factor := minf(photo_limit.x/texture.get_width(),photo_limit.y/texture.get_height()) if photo != null else CharacterArt.display_scale(texture.get_size(),maximum)
	sprite.scale = Vector2.ONE * factor
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if photo != null else CanvasItem.TEXTURE_FILTER_PARENT_NODE
