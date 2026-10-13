extends GutTest


func before_each() -> void:
	GameState.reset()


func after_each() -> void:
	GameState.reset()


func test_topes_por_medalla_y_caramelo_infinito_sin_consumir_mochila() -> void:
	assert_eq(GymProgression.next_ace_level([]), 15)
	GameState.new_game({"mode": GameState.MODE_RANDOMLOCKE, "randomlocke": {"settings": {"locke_rules": true, "level_cap": true}}})
	var pokemon := Pokemon.create(&"pikachu", 14)
	assert_eq(BattleSetup.wild(&"pidgey", 4).next_ace_level, 15)
	assert_eq(GameState.bag.count(&"rarecandy"), 0)
	assert_true(FieldItemUse.can_use(&"rarecandy", pokemon))
	assert_eq(FieldItemUse.use(&"rarecandy", pokemon), OK)
	assert_eq(pokemon.level, 15)
	assert_eq(GameState.bag.count(&"rarecandy"), 0)
	assert_false(FieldItemUse.can_use(&"rarecandy", pokemon))
	GameState.add_badge(&"medalla_libertad")
	assert_eq(GymProgression.next_ace_level(GameState.badges), 22)
	assert_eq(BattleSetup.wild(&"pidgey", 4).next_ace_level, 22)
	assert_eq(FieldItemUse.use(&"rarecandy", pokemon), OK)
	assert_eq(pokemon.level, 16)
	for badge: StringName in [&"medalla_palanca", &"medalla_tirantes", &"medalla_arte", &"medalla_quedate", &"medalla_txapela", &"medalla_pucela"]:
		GameState.add_badge(badge)
	assert_eq(GymProgression.next_ace_level(GameState.badges), 54)
	GameState.add_badge(&"medalla_zorro")
	assert_eq(GymProgression.next_ace_level(GameState.badges), 100)


func test_modo_dificil_sube_nivel_ia_y_se_guarda_sin_mutar_entrenador() -> void:
	GameState.new_game({"hard_mode": true})
	var id := &"gym1_padretarjeta"
	var original := DataDB.trainer(id)
	var base_level := int(original.party[0].level)
	var base_ai := int(BattleSetup.trainer_info(id).ai_level)
	var hard := BattleSetup.trainer(id)
	assert_eq(hard.foe_party[0].level, mini(100, ceili(base_level * 1.1)))
	assert_eq(hard.ai_level, base_ai + 1)
	assert_eq(int(DataDB.trainer(id).party[0].level), base_level)
	var wild := Pokemon.create(&"pidgey", 5)
	var hard_wild := BattleSetup.wild(wild)
	assert_eq(hard_wild.foe_party[0].level, 6)
	assert_eq(hard_wild.ai_level, 1)
	assert_eq(wild.level, 5)
	assert_eq(BattleSetup.wild(&"pidgey", 5, {"tutorial": true}).foe_party[0].level, 5)
	var saved := GameState.to_dict()
	GameState.from_dict(saved)
	assert_true(GameState.hard_mode)
	var old := SaveManager._migrate({"save_version": 4, "state": saved.duplicate(true)})
	assert_eq(old.save_version, GameState.SAVE_VERSION)
	assert_false(bool(old.state.hard_mode))


func test_partidas_nuevas_tienen_tope_sin_reinterpretar_codigos_de_preset() -> void:
	var previous := RandomizerSettings.from_preset("clasico")
	assert_false(previous.level_cap)
	var next := RandomizerSettings.for_new_game("clasico")
	assert_true(next.level_cap)
	assert_eq(next.preset, RandomizerSettings.CUSTOM)
	var code := SeedCode.encode(42, next)
	assert_true(code.length() > SeedCode.encode(42, previous).length())
	assert_true((SeedCode.decode(code).settings as RandomizerSettings).level_cap)
	assert_false(RandomizerSettings.for_new_game("solo_aleatorio").locke_rules)
	GameState.new_game()
	var pokemon := Pokemon.create(&"pikachu", 14)
	assert_false(FieldItemUse.can_use(&"rarecandy", pokemon))
	GameState.bag.add(&"rarecandy")
	assert_eq(FieldItemUse.use(&"rarecandy", pokemon), OK)
	assert_eq(pokemon.level, 15)
	assert_eq(GameState.bag.count(&"rarecandy"), 0)
