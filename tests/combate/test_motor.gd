extends GutTest
## BattleEngine: flujo de turnos, orden, estados, captura, huida, experiencia y combates completos.


func _mon(species: StringName, level: int, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


func _wild(player: Array[Pokemon], foe: Pokemon, seed_value: int = 1) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = player
	s.foe_party = [foe]
	s.player_name = "Ash"
	s.seed = seed_value
	return s


func _trainer(player: Array[Pokemon], foes: Array[Pokemon], seed_value: int = 1) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.can_run = false
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.ai_level = 1
	s.seed = seed_value
	s.trainers = [{"display_name": "Vendedor de Chupachups Manolo", "base_money": 24, "lose_text": "¿Uno de fresa?", "win_text": ""}]
	return s


## Juega hasta el final con `policy(request, engine) -> BattleAction`. Devuelve todos los eventos.
func _play(engine: BattleEngine, policy: Callable, max_steps: int = 200) -> Array[BattleEvent]:
	var events := engine.start()
	var steps := 0
	while not engine.is_over() and steps < max_steps:
		events.append_array(engine.submit(policy.call(engine.request, engine)))
		steps += 1
	assert_true(engine.is_over(), "el combate termina")
	return events


func _play_rest(engine: BattleEngine) -> void:
	while not engine.is_over():
		engine.submit(_attack_first(engine.request, engine))


## Ataca siempre con el primer movimiento, cambia al primero disponible y no aprende movimientos.
func _attack_first(req: BattleRequest, engine: BattleEngine) -> BattleAction:
	match req.kind:
		BattleRequest.Kind.SWITCH:
			return BattleAction.switch_to(engine.side(0).first_able_index())
		BattleRequest.Kind.LEARN_MOVE:
			return BattleAction.learn_move(-1)
	return BattleAction.fight(req.usable_moves[0] if not req.usable_moves.is_empty() else -1)


func _types(events: Array[BattleEvent]) -> Array[StringName]:
	var out: Array[StringName] = []
	for e: BattleEvent in events:
		out.append(e.type)
	return out


func _texts(events: Array[BattleEvent]) -> String:
	var lines: PackedStringArray = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE:
			lines.append(e.text())
	return "\n".join(lines)


func _first(events: Array[BattleEvent], type: StringName) -> BattleEvent:
	for e: BattleEvent in events:
		if e.type == type:
			return e
	return null


func test_inicio_salvaje() -> void:
	var engine := BattleEngine.new(_wild([_mon(&"pikachu", 10)], _mon(&"pidgey", 3)))
	var events := engine.start()
	assert_eq(events[0].type, BattleEvent.SWITCH_IN)
	assert_eq(events[0].side, 1)
	assert_true(events[0].value("wild"))
	assert_eq(events[1].text(), "¡Un Pidgey salvaje apareció!")
	assert_eq(events[2].text(), "¡Adelante, Pikachu!")
	assert_eq(events[3].type, BattleEvent.SWITCH_IN)
	assert_eq(events[3].value("max_hp"), engine.active(0).pokemon.max_hp())
	assert_not_null(engine.request)
	assert_eq(engine.request.kind, BattleRequest.Kind.ACTION)
	assert_true(engine.request.can_run)
	assert_eq(engine.request.usable_moves.size(), engine.active(0).pokemon.moves.size())


func test_combate_salvaje_completo_con_experiencia() -> void:
	var pikachu := _mon(&"pikachu", 10, {"moves": ["thundershock"]})
	var exp_before := pikachu.exp
	var engine := BattleEngine.new(_wild([pikachu], _mon(&"pidgey", 3)))
	var events := _play(engine, _attack_first)
	assert_eq(engine.result.outcome, BattleResult.WIN)
	assert_gt(pikachu.exp, exp_before, "gana experiencia")
	assert_true(BattleEvent.FAINT in _types(events))
	assert_true(BattleEvent.EXP in _types(events))
	assert_eq(events.back().type, BattleEvent.END)
	assert_eq(engine.result.seen_species, [&"pidgey"] as Array[StringName])
	assert_string_contains(_texts(events), "¡El Pidgey salvaje se debilitó!")
	assert_string_contains(_texts(events), "puntos de experiencia")
	assert_gt(pikachu.evs.values().reduce(func(a: int, b: int) -> int: return a + b, 0), 0, "gana EVs")


func test_misma_semilla_mismo_combate() -> void:
	var a := _play(BattleEngine.new(_wild([_mon(&"charmander", 8)], _mon(&"bulbasaur", 8), 777)), _attack_first)
	var b := _play(BattleEngine.new(_wild([_mon(&"charmander", 8)], _mon(&"bulbasaur", 8), 777)), _attack_first)
	assert_eq(str(a), str(b))
	var c := _play(BattleEngine.new(_wild([_mon(&"charmander", 8)], _mon(&"bulbasaur", 8), 778)), _attack_first)
	assert_ne(str(a), str(c), "otra semilla, otro combate")


func test_prioridad_antes_que_velocidad() -> void:
	var slow := _mon(&"rattata", 5, {"moves": ["quickattack"]})
	slow.apply_spec({"evs": 0})
	var fast := _mon(&"jolteon", 50, {"moves": ["tackle"]})
	var engine := BattleEngine.new(_wild([slow], fast))
	engine.start()
	var events := engine.submit(BattleAction.fight(0))
	var first_move := _first(events, BattleEvent.MOVE)
	assert_eq(first_move.side, 0, "Ataque Rápido va primero aunque sea más lento")


func test_velocidad_y_paralisis() -> void:
	var player := _mon(&"jolteon", 30, {"moves": ["tackle"]})
	var foe := _mon(&"snorlax", 30, {"moves": ["tackle"]})
	var engine := BattleEngine.new(_wild([player], foe))
	engine.start()
	assert_eq(_first(engine.submit(BattleAction.fight(0)), BattleEvent.MOVE).side, 0, "el más rápido primero")
	var b := engine.active(0)
	var spe := b.effective_speed()
	b.pokemon.set_status(&"par")
	assert_eq(b.effective_speed(), spe / 2, "la parálisis divide la Velocidad entre 2")


func test_huida() -> void:
	var engine := BattleEngine.new(_wild([_mon(&"jolteon", 30)], _mon(&"pidgey", 2)))
	engine.start()
	var events := engine.submit(BattleAction.run())
	assert_true(engine.is_over())
	assert_eq(engine.result.outcome, BattleResult.RUN)
	assert_true(_first(events, BattleEvent.FLEE).value("success"))


func test_no_se_huye_de_entrenadores() -> void:
	var engine := BattleEngine.new(_trainer([_mon(&"pikachu", 10)], [_mon(&"swirlix", 4)]))
	engine.start()
	assert_false(engine.request.can_run)


func test_master_ball_siempre_captura() -> void:
	for seed_value: int in [1, 2, 3]:
		var foe := _mon(&"mewtwo", 70)
		var engine := BattleEngine.new(_wild([_mon(&"pikachu", 5)], foe, seed_value))
		engine.start()
		assert_true(engine.can_use_item(&"masterball"))
		var events := engine.submit(BattleAction.use_item(&"masterball"))
		while not engine.is_over():
			events.append_array(engine.submit(_attack_first(engine.request, engine)))
		assert_eq(engine.result.outcome, BattleResult.CAUGHT)
		assert_eq(engine.result.caught_pokemon, foe)
		assert_eq(foe.ball, &"masterball")
		assert_true(_first(events, BattleEvent.CATCH).value("caught"))
		assert_string_contains(_texts(events), "¡Ya está! ¡Has atrapado a Mewtwo!")


func test_formula_de_captura() -> void:
	assert_eq(CatchCalc.shake_threshold(255.0), 65536)
	assert_almost_eq(CatchCalc.catch_value(100, 100, 255, 1.0, &""), 85.0, 0.01, "PS llenos: 1/3 del ratio")
	assert_almost_eq(CatchCalc.catch_value(100, 1, 45, 1.5, &"slp"), 45 * 1.5 * 2.5 * 298.0 / 300.0, 0.01)
	assert_gt(CatchCalc.shake_threshold(100.0), CatchCalc.shake_threshold(10.0))
	var foe := Battler.new(_mon(&"magikarp", 5), 1, 0, 0)
	assert_almost_eq(CatchCalc.ball_multiplier(DataDB.item(&"netball"), foe), 3.5, 0.01, "Malla Ball contra Agua")
	assert_almost_eq(CatchCalc.ball_multiplier(DataDB.item(&"quickball"), foe, {"turn": 1}), 5.0, 0.01)
	assert_almost_eq(CatchCalc.ball_multiplier(DataDB.item(&"quickball"), foe, {"turn": 3}), 1.0, 0.01)
	assert_almost_eq(CatchCalc.ball_multiplier(DataDB.item(&"ultraball"), foe), 2.0, 0.01)


func test_las_balls_no_valen_contra_entrenadores() -> void:
	var engine := BattleEngine.new(_trainer([_mon(&"pikachu", 10)], [_mon(&"swirlix", 4)]))
	engine.start()
	assert_false(engine.can_use_item(&"pokeball"))


func test_combate_de_entrenador_da_dinero() -> void:
	var engine := BattleEngine.new(_trainer([_mon(&"pikachu", 20, {"moves": ["thunderbolt"]})], [_mon(&"swirlix", 4), _mon(&"milcery", 6)]))
	var events := _play(engine, _attack_first)
	assert_eq(engine.result.outcome, BattleResult.WIN)
	assert_eq(engine.result.money_won, 24 * 6, "base_money × nivel del último Pokémon")
	assert_true(BattleEvent.TRAINER_SPEECH in _types(events))
	assert_string_contains(_texts(events), "¡Vendedor de Chupachups Manolo te desafía!")
	assert_string_contains(_texts(events), "¡Vendedor de Chupachups Manolo sacó a Milcery!")
	assert_string_contains(_texts(events), "¡El Swirlix enemigo se debilitó!")


func test_derrota_y_cambio_forzado() -> void:
	var weak := _mon(&"caterpie", 2, {"moves": ["stringshot"]})
	var weak2 := _mon(&"weedle", 2, {"moves": ["stringshot"]})
	var engine := BattleEngine.new(_wild([weak, weak2], _mon(&"machamp", 60, {"moves": ["closecombat"]})))
	engine.start()
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.request.kind, BattleRequest.Kind.SWITCH, "se pide el cambio tras el debilitado")
	engine.submit(BattleAction.switch_to(1))
	assert_eq(engine.active(0).pokemon, weak2)
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over())
	assert_eq(engine.result.outcome, BattleResult.LOSE)


func test_forcejeo_sin_pp() -> void:
	var p := _mon(&"pikachu", 30, {"moves": ["thundershock"]})
	p.moves[0].pp = 0
	var engine := BattleEngine.new(_wild([p], _mon(&"snorlax", 30, {"moves": ["tackle"]})))
	engine.start()
	assert_true(engine.request.usable_moves.is_empty())
	var events := engine.submit(BattleAction.fight(-1))
	var used: Array[String] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MOVE and e.side == 0:
			used.append(str(e.value("move")))
	assert_eq(used, ["struggle"] as Array[String])
	var recoil := false
	for e: BattleEvent in events:
		recoil = recoil or (e.type == BattleEvent.DAMAGE and e.side == 0 and e.value("source") == "struggle")
	assert_true(recoil, "Forcejeo hace daño al usuario")


func test_estados_y_residuales() -> void:
	var p := _mon(&"bulbasaur", 20, {"moves": ["growl"]})
	var foe := _mon(&"rattata", 20, {"moves": ["tailwhip"]})
	var engine := BattleEngine.new(_wild([p], foe))
	engine.start()
	foe.set_status(&"psn")
	var events := engine.submit(BattleAction.fight(0))
	var poison := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.value("source") == "psn":
			poison = int(e.value("amount"))
	assert_eq(poison, foe.max_hp() / 8, "el veneno quita 1/8")
	var b := engine.active(1)
	foe.set_status(&"tox")
	b.toxic_stage = 0
	var tox: Array[int] = []
	for i: int in 2:
		for e: BattleEvent in engine.submit(BattleAction.fight(0)):
			if e.type == BattleEvent.DAMAGE and e.value("source") == "tox":
				tox.append(int(e.value("amount")))
	assert_eq(tox, [maxi(1, foe.max_hp() / 16), 2 * maxi(1, foe.max_hp() / 16)] as Array[int], "Tóxico va en aumento")


func test_inmunidades_de_tipo_y_estado() -> void:
	var p := _mon(&"pikachu", 20, {"moves": ["thunderwave", "thundershock"]})
	var engine := BattleEngine.new(_wild([p], _mon(&"geodude", 20, {"moves": ["defensecurl"]})))
	engine.start()
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "No afecta al Geodude salvaje...", "Onda Trueno no afecta a Tierra")
	events = engine.submit(BattleAction.fight(1))
	assert_string_contains(_texts(events), "No afecta al Geodude salvaje...")
	assert_eq(engine.active(1).pokemon.current_hp, engine.active(1).pokemon.max_hp())


func test_cambios_de_caracteristicas() -> void:
	var p := _mon(&"charmander", 20, {"moves": ["growl", "swordsdance"]})
	var engine := BattleEngine.new(_wild([p], _mon(&"rattata", 20, {"moves": ["tailwhip"]}), 5))
	engine.start()
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).boosts[&"atk"], -1)
	assert_string_contains(_texts(events), "¡El Ataque del Rattata salvaje bajó!")
	assert_eq(engine.active(0).boosts[&"def"], -1, "Látigo del rival")
	assert_string_contains(_texts(events), "¡La Defensa de Charmander bajó!")
	events = engine.submit(BattleAction.fight(1))
	assert_eq(engine.active(0).boosts[&"atk"], 2)
	assert_string_contains(_texts(events), "¡El Ataque de Charmander subió mucho!")


func test_ia_nivel_1_elige_el_movimiento_que_mas_dana() -> void:
	var foe := _mon(&"pikachu", 30, {"moves": ["growl", "tackle", "thunderbolt", "thundershock"]})
	var engine := BattleEngine.new(_trainer([_mon(&"gyarados", 30)], [foe]))
	engine.start()
	var action := BattleAI.choose_action(engine, 1, 0, 1)
	assert_eq(action.move_index, 2, "Rayo")
	var target_ground := BattleEngine.new(_trainer([_mon(&"geodude", 30)], [foe]))
	target_ground.start()
	assert_eq(BattleAI.choose_action(target_ground, 1, 0, 1).move_index, 1, "Placaje si lo eléctrico no afecta")


func test_subida_de_nivel_y_aprender_movimiento() -> void:
	var p := _mon(&"charmander", 3, {"moves": ["scratch", "growl", "leer", "tackle"]})
	p.exp = p.exp_at_next_level() - 1
	var engine := BattleEngine.new(_wild([p], _mon(&"magikarp", 30, {"moves": ["splash"]}), 3))
	engine.start()
	engine.active(1).pokemon.current_hp = 1
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(p.level, 4)
	assert_true(BattleEvent.LEVEL_UP in _types(events))
	assert_eq(engine.request.kind, BattleRequest.Kind.LEARN_MOVE, "Ascuas, pero ya sabe 4")
	assert_eq(engine.request.move_id, &"ember")
	events = engine.submit(BattleAction.learn_move(1))
	assert_eq(p.move_ids(), [&"scratch", &"ember", &"leer", &"tackle"] as Array[StringName])
	assert_string_contains(_texts(events), "¡Charmander ha olvidado Gruñido!")
	_play_rest(engine)
	assert_eq(engine.result.outcome, BattleResult.WIN)


func test_evolucion_pendiente_al_terminar() -> void:
	var p := _mon(&"charmander", 15, {"moves": ["ember"]})
	p.exp = p.exp_at_next_level() - 1
	var engine := BattleEngine.new(_wild([p], _mon(&"bulbasaur", 20, {"moves": ["growl"]}), 9))
	engine.start()
	engine.active(1).pokemon.current_hp = 1
	_play(engine, _attack_first)
	assert_eq(p.level, 16)
	assert_eq(engine.result.pending_evolutions.size(), 1)
	assert_eq(engine.result.pending_evolutions[0]["to"], "charmeleon")


func test_repartir_experiencia() -> void:
	var lead := _mon(&"pikachu", 20, {"moves": ["thunderbolt"]})
	var bench := _mon(&"bulbasaur", 20)
	var bench_exp := bench.exp
	var s := _wild([lead, bench], _mon(&"pidgey", 10))
	s.exp_share = true
	_play(BattleEngine.new(s), _attack_first)
	assert_gt(bench.exp, bench_exp, "el que no ha luchado también gana experiencia")
	var bench2 := _mon(&"bulbasaur", 20)
	var exp2 := bench2.exp
	var s2 := _wild([_mon(&"pikachu", 20, {"moves": ["thunderbolt"]}), bench2], _mon(&"pidgey", 10))
	s2.exp_share = false
	_play(BattleEngine.new(s2), _attack_first)
	assert_eq(bench2.exp, exp2, "sin Repartir Experiencia, no")


func test_pociones_en_combate() -> void:
	var p := _mon(&"pikachu", 20, {"moves": ["growl"]})
	var engine := BattleEngine.new(_wild([p], _mon(&"magikarp", 5, {"moves": ["splash"]})))
	engine.start()
	assert_false(engine.can_use_item(&"potion", 0), "con los PS llenos no tiene efecto")
	p.take_damage(30)
	assert_true(engine.can_use_item(&"potion", 0))
	var events := engine.submit(BattleAction.use_item(&"potion", 0))
	assert_eq(p.current_hp, p.max_hp() - 10)
	assert_eq(_first(events, BattleEvent.HEAL).value("amount"), 20)
	assert_string_contains(_texts(events), "¡Ash ha usado Poción!")


func test_combate_completo_con_semilla_fija() -> void:
	# Mismo combate largo dos veces: mismo resultado y mismos turnos.
	var run := func() -> Array:
		var mine: Array[Pokemon] = [_mon(&"charmander", 12), _mon(&"pidgey", 10)]
		var foes: Array[Pokemon] = [_mon(&"bulbasaur", 12), _mon(&"rattata", 11)]
		var engine := BattleEngine.new(_trainer(mine, foes, 2026))
		var events := _play(engine, _attack_first)
		return [engine.result.outcome, engine.result.turns, events.size(), mine[0].current_hp, foes[0].current_hp]
	var first: Array = run.call()
	assert_eq(run.call(), first)
	assert_true(first[0] in [BattleResult.WIN, BattleResult.LOSE])
