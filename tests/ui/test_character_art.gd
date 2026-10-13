extends GutTest
var _original: Dictionary

func before_each() -> void:
	_original = CharacterArt.entries()
	GameState.reset()

func after_each() -> void:
	CharacterArt._characters = _original
	GameState.reset()

func test_atlas_combate_y_mapa_tienen_regiones_reales_sin_deformar() -> void:
	for id: String in CharacterArt.entries():
		var portrait := CharacterArt.battle_texture(StringName(id))
		assert_not_null(portrait,id)
		var frames := CharacterArt.walk_frames(StringName(id))
		assert_eq(frames.size(),16,id)
		for frame: AtlasTexture in frames:
			assert_not_null(frame)
			assert_eq(frame.get_size(),frames[0].get_size())
		var sprite := CharacterArtSprite.new()
		add_child_autofree(sprite)
		sprite.set_art(StringName(id))
		sprite.facing = Vector2i.UP
		assert_eq((sprite.texture as AtlasTexture).region,frames[12].region)
		assert_lte(sprite.texture.get_height()*sprite.scale.y,64.0)

func test_entrenador_resuelve_su_clase_en_mapa_y_combate_sin_cambiar_colocacion() -> void:
	CharacterArt._characters["ayuso"] = _original.rajoy.duplicate(true)
	assert_eq(TrainerData.get_trainer(&"ayuso").art_id,&"ayuso")
	assert_eq(BattleSetup.trainer_info(&"ayuso").art_id,&"ayuso")
	var actor: TrainerNPC = load("res://src/overworld/trainers/trainer_npc.tscn").instantiate()
	actor.trainer_id = &"ayuso"
	actor.sight_range = 0
	add_child_autofree(actor)
	assert_true(actor.sprite is CharacterArtSprite)
	assert_eq((actor.sprite as CharacterArtSprite).poses.size(),16)
