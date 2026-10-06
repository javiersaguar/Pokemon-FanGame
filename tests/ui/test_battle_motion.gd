extends GutTest

func test_transition_selects_wild_trainer_and_explicit_leader_without_guessing_names() -> void:
	assert_eq(BattleEntryTransition.select_kind({"kind": &"wild"}), &"wild")
	assert_eq(BattleEntryTransition.select_kind({"kind": &"trainer", "trainers": [{"display_name": "Líder, nombre de prueba"}]}), &"trainer")
	assert_eq(BattleEntryTransition.select_kind({"kind": &"trainer", "transition": &"leader"}), &"leader")

func test_native_transition_images_and_integer_positions() -> void:
	var screen := BattleEntryTransition.new()
	screen.kind = &"leader"
	screen.info = {"transition": &"leader"}
	add_child_autofree(screen)
	for value: float in [0.0, 0.13, 0.5, 0.86, 1.0]:
		screen.set_progress(value)
		for child: Node in screen.get_children():
			if child is Sprite2D:
				assert_eq(child.scale, Vector2.ONE)
				assert_eq(child.rotation, 0.0)
				assert_eq(child.position, child.position.round())
	assert_eq(screen._back.texture.get_size(), Vector2(512, 384))
	assert_eq(screen.modulate.a, 0.0)

func test_fast_transition_adds_no_nodes_or_input_lock() -> void:
	var count := get_child_count()
	var locked := GameState.input_locked
	await BattleEntryTransition.play(self, {"kind": &"wild"}, true)
	assert_eq(get_child_count(), count)
	assert_eq(GameState.input_locked, locked)

func test_transition_resources_match_original_pack_sizes_and_hashes() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_assets.json"))
	for entry: Dictionary in manifest.files:
		var path: String = "res://" + entry.target
		assert_eq(FileAccess.get_sha256(path), entry.sha256)
		var texture: Texture2D = load(path)
		assert_eq(texture.get_size(), Vector2(entry.size[0], entry.size[1]))

func test_normal_transition_finishes_and_removes_overlay_without_changing_game_lock() -> void:
	GameState.lock_input(&"motion_test")
	var count := get_child_count()
	await BattleEntryTransition.play(self, {"kind": &"wild"})
	await wait_process_frames(2)
	assert_eq(get_child_count(), count)
	assert_true(GameState.is_input_locked_by(&"motion_test"))
	GameState.unlock_input(&"motion_test")

func test_all_eighteen_types_have_native_frames_and_effects_release_nodes() -> void:
	var types: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_types.json"))
	assert_eq(types.size(), 18)
	for type: String in types:
		for kind: int in [BattleFx.Kind.BURST, BattleFx.Kind.ORB, BattleFx.Kind.SPARKLE]:
			var fx := BattleFx.create(self, kind, Vector2(110,260), Vector2(360,100), BattleFx.type_profile(StringName(type)))
			for t: float in [0.0,0.25,0.51,1.0]:
				fx.progress = t
				for sprite: Sprite2D in fx.particles:
					assert_eq(sprite.scale, Vector2.ONE)
					assert_eq(sprite.rotation, 0.0)
					assert_eq(sprite.position, sprite.position.round())
					assert_lt(sprite.frame, sprite.hframes * sprite.vframes)
			fx.queue_free()
	await wait_process_frames(2)
	var count := get_child_count()
	await BattleFx.move(self, Vector2.ZERO, Vector2(10,20), {"type": &"fire", "category": &"special"}, 0.05)
	await wait_process_frames(2)
	assert_eq(get_child_count(), count)
	await BattleFx.move(self, Vector2.ZERO, Vector2.ONE, {}, 0.0)
	assert_eq(get_child_count(), count, "fast no crea efectos")

func test_specific_mvp_sequences_cover_configured_moves_and_restore_user_position() -> void:
	var mvp: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_mvp.json"))
	for id: String in mvp.moves:
		var spec := BattleMoveAnimation.sequence(StringName(id))
		assert_false(spec.is_empty(), id)
		assert_true(ResourceLoader.exists(BattleFx.DIR+str(spec.asset)+".png"), id)
	assert_true(BattleMoveAnimation.sequence(&"not_a_move").is_empty())
	var user := BattlePokemonSprite.new()
	user.back = true
	user.position = Vector2(110,280)
	add_child_autofree(user)
	user.set_pokemon({"species": &"squirtle"})
	var target := BattlePokemonSprite.new()
	target.position = Vector2(360,180)
	add_child_autofree(target)
	target.set_pokemon({"species": &"bulbasaur"})
	var count := get_child_count()
	assert_true(await BattleMoveAnimation.play(self,user,target,{"move":&"splash"},false))
	await wait_process_frames(2)
	assert_eq(user.position,user.home(), "Salpicadura devuelve el Pokémon a su lugar")
	assert_eq(get_child_count(), count)
	assert_true(await BattleMoveAnimation.play(self,user,target,{"move":&"ember"},true))
	assert_eq(get_child_count(),count, "fast omite secuencia específica")
	assert_false(await BattleMoveAnimation.play(self,user,target,{"move":&"icebeam"},false), "fuera del MVP usa genérica")
