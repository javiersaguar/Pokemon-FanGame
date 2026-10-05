extends GutTest
## Reglas Locke dentro del combate: muerte, tope de experiencia, modo fijo y objetos.


func after_each() -> void:
	GameState.reset()


func _mon(species: StringName, level: int, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


func _wild(player: Array[Pokemon], foe: Pokemon) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = player
	s.foe_party = [foe]
	s.player_name = "Javi"
	s.seed = 1
	return s


func _trainer(player: Array[Pokemon], foes: Array[Pokemon]) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.can_run = false
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Javi"
	s.ai_level = 1
	s.seed = 1
	s.trainers = [{"display_name": "Rival", "base_money": 16, "lose_text": "", "win_text": ""}]
	return s


func _died(events: Array) -> int:
	var n := 0
	for event: BattleEvent in events:
		if event.type == BattleEvent.POKEMON_DIED:
			n += 1
	return n


func test_una_muerte_por_uid_y_el_tutorial_no_cuenta() -> void:
	var weak := _mon(&"caterpie", 2, {"moves": ["stringshot"]})
	var same := _mon(&"weedle", 2, {"moves": ["stringshot"]})
	same.uid = weak.uid
	var s := _wild([weak, same], _mon(&"machamp", 60, {"moves": ["closecombat"]}))
	s.locke_rules = true
	var engine := BattleEngine.new(s)
	var events := engine.start()
	events.append_array(engine.submit(BattleAction.fight(0)))
	assert_eq(engine.request.kind, BattleRequest.Kind.SWITCH)
	events.append_array(engine.submit(BattleAction.switch_to(1)))
	events.append_array(engine.submit(BattleAction.fight(0)))
	assert_eq(_died(events), 1, "el mismo uid solo muere una vez")
	assert_eq(engine.result.deaths.size(), 1)

	var tutorial := _wild([_mon(&"caterpie", 2, {"moves": ["stringshot"]})], _mon(&"machamp", 50, {"moves": ["closecombat"]}))
	tutorial.locke_rules = true
	tutorial.tutorial = true
	tutorial.locke = LockeRules.new({"locke_rules": true, "permadeath": true, "level_cap": true})
	tutorial.next_ace_level = 2
	var quiet := BattleEngine.new(tutorial)
	var quiet_events := quiet.start()
	quiet_events.append_array(quiet.submit(BattleAction.fight(0)))
	assert_eq(_died(quiet_events), 0, "el tutorial no emite pokemon_died")
	assert_eq(quiet.result.deaths.size(), 0)


func test_la_experiencia_se_queda_en_el_tope() -> void:
	var mine := _mon(&"pikachu", 5, {"moves": ["thunderbolt"]})
	var foe := _mon(&"blissey", 5, {"moves": ["pound"]})
	foe.current_hp = 1
	var open := _wild([mine], foe)
	var uncapped := BattleEngine.new(open)
	uncapped.start()
	uncapped.submit(BattleAction.fight(0))
	assert_gt(mine.level, 6, "sin tope sube más de un nivel")

	var capped_mon := _mon(&"pikachu", 5, {"moves": ["thunderbolt"]})
	var capped_foe := _mon(&"blissey", 5, {"moves": ["pound"]})
	capped_foe.current_hp = 1
	var limited := _wild([capped_mon], capped_foe)
	limited.locke = LockeRules.new({"locke_rules": true, "level_cap": true})
	limited.next_ace_level = 6
	var engine := BattleEngine.new(limited)
	engine.start()
	engine.submit(BattleAction.fight(0))
	assert_eq(capped_mon.level, 6)
	assert_eq(capped_mon.exp, DataDB.exp_for_level(capped_mon.exp_group(), 6))


func test_el_modo_fijo_no_avisa_y_el_cambio_se_puede_rechazar() -> void:
	var lead := _mon(&"pikachu", 40, {"moves": ["thunderbolt"]})
	var bench := _mon(&"pidgey", 5)
	var first := _mon(&"caterpie", 2)
	first.current_hp = 1
	var second := _mon(&"weedle", 3)
	var shift := _trainer([lead, bench], [first, second])
	shift.battle_style = &"shift"
	var engine := BattleEngine.new(shift)
	engine.start()
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.request.kind, BattleRequest.Kind.SWITCH)
	assert_eq(engine.request.reason, &"shift")
	engine.submit(BattleAction.switch_to(-1))
	assert_eq(engine.active(BattleEngine.PLAYER).pokemon.uid, lead.uid)
	assert_eq(engine.active(BattleEngine.FOE).pokemon.species_id, &"weedle")

	var forced_lead := _mon(&"pikachu", 40, {"moves": ["thunderbolt"]})
	var forced_first := _mon(&"caterpie", 2)
	forced_first.current_hp = 1
	var forced := _trainer([forced_lead, _mon(&"pidgey", 5)], [forced_first, _mon(&"weedle", 3)])
	forced.battle_style = &"shift"
	forced.locke = LockeRules.new({"locke_rules": true, "fixed_battle": true})
	var fixed := BattleEngine.new(forced)
	fixed.start()
	fixed.submit(BattleAction.fight(0))
	assert_eq(fixed.request.kind, BattleRequest.Kind.ACTION, "el modo fijo no pregunta")
	assert_eq(fixed.active(BattleEngine.FOE).pokemon.species_id, &"weedle")


func test_los_objetos_se_limitan_y_las_balls_siguen() -> void:
	var mine := _mon(&"pikachu", 10, {"moves": ["thunderbolt"]})
	var foe := _mon(&"pidgey", 3)
	var s := _wild([mine], foe)
	s.locke = LockeRules.new({"locke_rules": true, "battle_items": "limited", "battle_item_limit": 1})
	var engine := BattleEngine.new(s)
	engine.start()
	mine.current_hp = 1
	assert_true(engine.can_use_item(&"potion"))
	assert_true(engine.can_use_item(&"pokeball"))
	engine.submit(BattleAction.use_item(&"potion"))
	assert_false(engine.can_use_item(&"potion"), "el límite cuenta el uso")
	assert_true(engine.can_use_item(&"pokeball"), "la Ball no gasta el límite")

	var banned := _wild([_mon(&"pikachu", 10)], _mon(&"pidgey", 3))
	banned.locke = LockeRules.new({"locke_rules": true, "battle_items": "forbidden"})
	var closed := BattleEngine.new(banned)
	closed.start()
	closed.party(BattleEngine.PLAYER)[0].current_hp = 1
	assert_false(closed.can_use_item(&"potion"))
	assert_true(closed.can_use_item(&"pokeball"))


func test_el_setup_lee_las_reglas_de_la_partida() -> void:
	GameState.new_game({"mode": "randomlocke", "randomlocke": {"settings": {
		"locke_rules": true, "permadeath": true, "level_cap": true, "fixed_battle": true,
		"battle_items": "limited", "battle_item_limit": 2,
	}, "families": {}}})
	GameState.randomlocke["next_ace_level"] = 18
	var s := BattleSetup.wild(&"pidgey", 3, {"battle_style": "shift"})
	assert_true(s.locke_rules)
	assert_not_null(s.locke)
	assert_eq(s.next_ace_level, 18)
	assert_eq(s.locke.battle_mode(), "fixed")
	assert_eq(s.locke.level_cap(s.next_ace_level), 18)
	var engine := BattleEngine.new(s)
	assert_false(engine._style_is_shift(), "el fijo de Locke gana al estilo del jugador")

	GameState.new_game({"mode": "randomlocke", "randomlocke": {"settings": {"permadeath": false}, "families": {}}})
	var soft := BattleSetup.wild(&"pidgey", 3)
	assert_false(soft.locke_rules, "sin muerte permanente no hay pokemon_died")
	assert_not_null(soft.locke)
