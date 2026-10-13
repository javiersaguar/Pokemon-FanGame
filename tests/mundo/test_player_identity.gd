extends GutTest
var config: Dictionary

func before_each() -> void:
	config = GameState.world_config.duplicate(true)
	GameState.reset()

func after_each() -> void:
	GameState.world_config = config
	GameState.reset()

func test_four_identities_persist_in_json_and_decide_gender_and_origin() -> void:
	for id: String in PlayerIdentity.catalogue():
		GameState.new_game({"player_character": id})
		var info := PlayerIdentity.info(StringName(id))
		assert_eq(GameState.player_gender, StringName(info.gender))
		assert_eq(GameState.map_id, StringName(info.start_map))
		var data: Dictionary = JSON.parse_string(JSON.stringify(GameState.to_dict()))
		GameState.reset()
		GameState.from_dict(data)
		assert_eq(GameState.player_character, StringName(id))
		assert_eq(GameState.player_gender, StringName(info.gender))
		assert_eq(GameState.map_id, StringName(info.start_map))
	assert_eq(PlayerIdentity.ids(&"male"), [&"cayetano", &"cani"] as Array[StringName])
	assert_eq(PlayerIdentity.ids(&"female"), [&"cayetana", &"choni"] as Array[StringName])

func test_v2_save_migration_keeps_legacy_gender_position_and_modules() -> void:
	GameState.new_game()
	GameState.player_gender = &"female"
	GameState.party.add(Pokemon.create(&"eevee", 5))
	var state := GameState.to_dict()
	state.player.erase("character")
	var migrated := SaveManager._migrate({"save_version": 2, "state": state.duplicate(true)})
	assert_eq(migrated.save_version, GameState.SAVE_VERSION)
	GameState.from_dict(migrated.state)
	assert_eq(GameState.player_character, &"")
	assert_eq(GameState.player_gender, &"female")
	assert_eq(GameState.party.members[0].species_id, &"eevee")
	assert_eq(GameState.to_dict().position, state.position)

func test_atlas_has_front_back_and_every_direction_with_transparency() -> void:
	for id: String in PlayerIdentity.catalogue():
		var identity := StringName(id)
		for kind: StringName in [&"front", &"back"]:
			var pose := PlayerIdentity.texture(identity, kind)
			assert_not_null(pose)
			if pose: assert_false(pose.get_image().is_invisible())
		var frames := PlayerIdentity.walk_frames(identity)
		assert_eq(frames.size(), 16)
		for frame: AtlasTexture in frames:
			assert_gt(frame.get_width(), 0)
			assert_gt(frame.get_height(), 0)
			assert_ne(frame.get_image().detect_alpha(), Image.ALPHA_NONE)
		var sprite := ProtagonistSprite.new()
		add_child_autofree(sprite)
		sprite.set_identity(identity)
		for dir: Vector2i in Character.DIRECTIONS:
			sprite.facing = dir
			for col: int in [0, 1, 3]:
				sprite._show(col)
				assert_almost_eq(sprite.texture.get_height() * sprite.scale.y, 56.0, 0.01)
				assert_almost_eq((sprite.offset.y + sprite.texture.get_height()/2.0) * sprite.scale.y, 16.0, 0.01)
		sprite.set_identity(&"")
		assert_eq(sprite.hframes, 4)
		assert_eq(sprite.vframes, 4)
		assert_eq(sprite.scale, Vector2.ONE)

func test_invalid_identity_start_does_not_replace_the_current_game() -> void:
	GameState.new_game()
	GameState.player_name = "Partida anterior"
	var before := GameState.to_dict()
	assert_eq(await SceneManager.start_new_game(&"", &"", {"player_character": "inexistente"}), ERR_INVALID_PARAMETER)
	assert_eq(GameState.to_dict(), before)
