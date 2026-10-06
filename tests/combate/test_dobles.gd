extends GutTest
## Combates dobles: dos en el campo, daño repartido, aliado, redirección y compañero.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _double(player: Array, foes: Array) -> BattleSetup:
	var s := BattleSetup.new()
	s.format = BattleSetup.Format.DOUBLE
	s.kind = BattleSetup.Kind.WILD
	s.player_party.assign(player)
	s.foe_party.assign(foes)
	s.player_name = "Javi"
	s.seed = 3
	return s


func test_salen_dos_y_el_acido_se_reparte() -> void:
	var single := BattleSetup.new()
	single.kind = BattleSetup.Kind.WILD
	single.player_party = [_mon(&"bulbasaur", 40, ["acid"])]
	single.foe_party = [_mon(&"rattata", 40, ["splash"])]
	single.seed = 3
	var alone := BattleEngine.new(single)
	alone.start()
	var alone_events := alone.submit(BattleAction.fight(0))
	var alone_damage := 0
	for event: BattleEvent in alone_events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.FOE:
			alone_damage = int(event.value("amount"))
	assert_gt(alone_damage, 0)

	var spread := BattleEngine.new(_double(
		[_mon(&"bulbasaur", 40, ["acid"]), _mon(&"pidgey", 5, ["splash"])],
		[_mon(&"rattata", 40, ["splash"]), _mon(&"sentret", 40, ["splash"])]))
	var intro := spread.start()
	var foes := 0
	for event: BattleEvent in intro:
		if event.type == BattleEvent.SWITCH_IN and event.side == BattleEngine.FOE:
			foes += 1
	assert_eq(foes, 2)
	assert_eq(spread.request.slot, 0)
	spread.submit(BattleAction.fight(0))
	assert_eq(spread.request.slot, 1)
	var events := spread.submit(BattleAction.fight(0))
	var hits := 0
	var amount := 0
	for event: BattleEvent in events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.FOE:
			hits += 1
			amount = int(event.value("amount"))
	assert_eq(hits, 2, "el ácido golpea a los dos rivales")
	assert_lt(amount, alone_damage, "repartido, cada uno recibe menos")


func test_el_aliado_recibe_el_movimiento_de_apoyo() -> void:
	var engine := BattleEngine.new(_double(
		[_mon(&"clefairy", 20, ["aromaticmist"]), _mon(&"pikachu", 20, ["splash"])],
		[_mon(&"rattata", 10, ["splash"]), _mon(&"sentret", 10, ["splash"])]))
	engine.start()
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(BattleEngine.PLAYER, 1).boosts[&"spd"], 1)


func test_un_objetivo_caido_pasa_al_otro() -> void:
	var engine := BattleEngine.new(_double(
		[_mon(&"pikachu", 30, ["tackle"]), _mon(&"pidgey", 5, ["splash"])],
		[_mon(&"geodude", 30, ["splash"]), _mon(&"sentret", 20, ["splash"])]))
	engine.start()
	engine.active(BattleEngine.FOE, 1).pokemon.current_hp = 0
	var before := engine.active(BattleEngine.FOE, 0).pokemon.current_hp
	engine.submit(BattleAction.fight(0, 1))
	engine.submit(BattleAction.fight(0))
	assert_lt(engine.active(BattleEngine.FOE, 0).pokemon.current_hp, before)


func test_el_companero_lo_juega_la_ia() -> void:
	var s := _double(
		[_mon(&"pikachu", 20, ["thunderbolt"]), _mon(&"charmander", 20, ["ember"])],
		[_mon(&"geodude", 15, ["splash"]), _mon(&"sentret", 15, ["splash"])])
	s.ally_ai = true
	var engine := BattleEngine.new(s)
	engine.start()
	assert_eq(engine.request.slot, 0)
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.turn, 1, "el compañero no pide otra acción")
	assert_lt(engine.party(BattleEngine.PLAYER)[1].moves[0].pp, engine.party(BattleEngine.PLAYER)[1].moves[0].max_pp())
