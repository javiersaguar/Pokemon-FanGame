extends GutTest
## Fase 9.5: habilidades, objetos equipados y trampas de las especies en uso.


func _mon(species: StringName, level: int, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
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
	s.seed = 2
	return s


func _damage_of(events: Array) -> int:
	for event: BattleEvent in events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.FOE:
			return int(event.value("amount"))
	return 0


func test_intimida_al_entrar() -> void:
	var engine := BattleEngine.new(_wild([_mon(&"gyarados", 20)], _mon(&"pidgey", 10)))
	engine.start()
	assert_eq(engine.active(BattleEngine.FOE).boosts[&"atk"], -1)


func test_espesura_aumenta_el_ataque_con_pocos_ps() -> void:
	var low := _mon(&"bulbasaur", 30, {"moves": ["vinewhip"]})
	var full := _mon(&"bulbasaur", 30, {"moves": ["vinewhip"]})
	var wall := _mon(&"snorlax", 50, {"moves": ["splash"]})
	var other := _mon(&"snorlax", 50, {"moves": ["splash"]})
	var pinched := BattleEngine.new(_wild([low], wall))
	pinched.start()
	pinched.active(BattleEngine.PLAYER).pokemon.current_hp = 1
	var weak := _damage_of(pinched.submit(BattleAction.fight(0)))
	var healthy := BattleEngine.new(_wild([full], other))
	healthy.start()
	healthy.active(BattleEngine.PLAYER).ability = &""
	var normal := _damage_of(healthy.submit(BattleAction.fight(0)))
	assert_gt(weak, normal)


func test_el_insomnio_impide_dormir() -> void:
	var engine := BattleEngine.new(_wild([_mon(&"hoothoot", 12)], _mon(&"pidgey", 8)))
	engine.start()
	assert_false(engine.set_status(engine.active(BattleEngine.PLAYER), &"slp"))
	assert_eq(engine.active(BattleEngine.PLAYER).pokemon.status, &"")


func test_puas_y_trampa_rocas_al_entrar() -> void:
	var lead := _mon(&"pidgey", 20)
	var next := _mon(&"rattata", 20)
	var engine := BattleEngine.new(_wild([lead, next], _mon(&"caterpie", 2, {"moves": ["stringshot"]})))
	engine.start()
	assert_true(engine.add_side_condition(BattleEngine.PLAYER, &"spikes", engine.active(BattleEngine.FOE)))
	var before := next.max_hp()
	engine.submit(BattleAction.switch_to(1))
	assert_lt(next.current_hp, before)
	assert_eq(next.current_hp, before - maxi(1, before / 8))

	var flyer := _mon(&"charizard", 40)
	var rocks := BattleEngine.new(_wild([_mon(&"pidgey", 10), flyer], _mon(&"caterpie", 2)))
	rocks.start()
	assert_true(rocks.add_side_condition(BattleEngine.PLAYER, &"stealthrock", rocks.active(BattleEngine.FOE)))
	var full_hp := flyer.max_hp()
	rocks.submit(BattleAction.switch_to(1))
	assert_eq(flyer.current_hp, full_hp - maxi(1, int(full_hp * 4.0 / 8.0)))


func test_banda_focus_restos_y_eleccion() -> void:
	var sash := _mon(&"pikachu", 20, {"moves": ["thunderbolt"], "item": "focussash"})
	var foe := _mon(&"machamp", 70, {"moves": ["splash"]})
	var engine := BattleEngine.new(_wild([sash], foe))
	engine.start()
	foe.current_hp = 1
	# El rival no golpea: el jugador recibe el daño de un ataque propio simulado.
	engine.deal_damage(engine.active(BattleEngine.PLAYER), sash.max_hp(), &"move")
	assert_eq(sash.current_hp, 1)
	assert_eq(sash.held_item, &"")

	var rested := _mon(&"pikachu", 30, {"moves": ["splash"], "item": "leftovers"})
	var quiet := BattleEngine.new(_wild([rested], _mon(&"pidgey", 3, {"moves": ["splash"]})))
	quiet.start()
	rested.current_hp = rested.max_hp() - 30
	var hp := rested.current_hp
	quiet.submit(BattleAction.fight(0))
	assert_eq(rested.current_hp, hp + maxi(1, rested.max_hp() / 16))

	var band := _mon(&"pikachu", 20, {"moves": ["tackle", "thunderbolt"], "item": "choiceband"})
	var locked := BattleEngine.new(_wild([band], _mon(&"geodude", 20, {"moves": ["splash"]})))
	locked.start()
	locked.submit(BattleAction.fight(0))
	assert_eq(locked.active(BattleEngine.PLAYER).choice_move, &"tackle")
	assert_eq(locked.request.usable_moves.size(), 1)
	assert_eq(locked.request.usable_moves[0], 0)
