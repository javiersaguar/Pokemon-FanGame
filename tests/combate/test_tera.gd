extends GutTest
## Teratipo: una vez por bando, cambia la defensa y el STAB (2 si ya tenía ese tipo).


func _mon(species: StringName, level: int, moves: Array, tera: String = "") -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 14
	var p := Pokemon.create(species, level, rng)
	var spec := {"nature": "hardy", "ivs": 31, "moves": moves}
	if tera != "":
		spec["tera_type"] = tera
	p.apply_spec(spec)
	return p


func _setup(player: Pokemon, foe: Pokemon, enabled: bool) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = [player]
	s.foe_party = [foe]
	s.seed = 6
	s.tera = enabled
	return s


func _tera() -> BattleAction:
	var action := BattleAction.fight(0)
	action.tera = true
	return action


func _player_damage(events: Array) -> int:
	for event: BattleEvent in events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.PLAYER:
			return int(event.value("amount"))
	return 0


func _foe_damage(events: Array) -> int:
	for event: BattleEvent in events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.FOE:
			return int(event.value("amount"))
	return 0


func test_sin_el_ajuste_no_cambia_de_tipo() -> void:
	var engine := BattleEngine.new(_setup(
		_mon(&"charmander", 40, ["ember"], "fire"),
		_mon(&"snorlax", 50, ["splash"]), false))
	engine.start()
	assert_false(engine.request.can_tera)
	engine.submit(_tera())
	assert_eq(engine.active(BattleEngine.PLAYER).tera_active, &"")
	assert_true(engine.active(BattleEngine.PLAYER).has_type(&"fire"))


func test_el_mismo_tipo_pega_mas_y_uno_nuevo_conserva_el_stab_original() -> void:
	var plain := BattleEngine.new(_setup(
		_mon(&"charmander", 50, ["ember"]),
		_mon(&"snorlax", 80, ["splash"]), true))
	plain.start()
	var normal := _foe_damage(plain.submit(BattleAction.fight(0)))
	var same := BattleEngine.new(_setup(
		_mon(&"charmander", 50, ["ember"], "fire"),
		_mon(&"snorlax", 80, ["splash"]), true))
	same.start()
	assert_true(same.request.can_tera)
	var events := same.submit(_tera())
	assert_eq(same.active(BattleEngine.PLAYER).tera_active, &"fire")
	assert_gt(_foe_damage(events), normal)
	var other := BattleEngine.new(_setup(
		_mon(&"charmander", 50, ["ember"], "water"),
		_mon(&"snorlax", 80, ["splash"]), true))
	other.start()
	var kept := _foe_damage(other.submit(_tera()))
	assert_eq(other.active(BattleEngine.PLAYER).tera_active, &"water")
	assert_false(other.active(BattleEngine.PLAYER).has_type(&"fire"))
	assert_eq(kept, normal)


func test_el_agua_le_hace_menos_si_pasa_a_ser_agua() -> void:
	var open := BattleEngine.new(_setup(
		_mon(&"charmander", 50, ["ember"]),
		_mon(&"slowpoke", 20, ["watergun"]), false))
	open.start()
	var weak := _player_damage(open.submit(BattleAction.fight(0)))
	var closed := BattleEngine.new(_setup(
		_mon(&"charmander", 50, ["ember"], "water"),
		_mon(&"slowpoke", 20, ["watergun"]), true))
	closed.start()
	var resisted := _player_damage(closed.submit(_tera()))
	assert_lt(resisted, weak)
	assert_gt(resisted, 0)


func test_estelar_queda_pendiente_y_solo_una_vez_por_bando() -> void:
	var stellar := BattleEngine.new(_setup(
		_mon(&"charmander", 30, ["ember"], "stellar"),
		_mon(&"snorlax", 40, ["splash"]), true))
	stellar.start()
	assert_false(stellar.request.can_tera)
	var first := _mon(&"charmander", 30, ["ember"], "fire")
	var second := _mon(&"squirtle", 30, ["tackle"], "water")
	var ready := _setup(first, _mon(&"snorlax", 40, ["splash"]), true)
	ready.player_party.append(second)
	var engine := BattleEngine.new(ready)
	engine.start()
	engine.submit(_tera())
	assert_eq(first.species_id, &"charmander")
	engine.submit(BattleAction.switch_to(1))
	var again := BattleAction.fight(0)
	again.tera = true
	engine.submit(again)
	assert_eq(engine.active(BattleEngine.PLAYER).tera_active, &"")
