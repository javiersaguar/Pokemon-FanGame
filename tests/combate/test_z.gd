extends GutTest
## Movimientos Z: pulsera, cristal, una vez por combate y potencia de la tabla oficial.


func _mon(species: StringName, level: int, moves: Array, item: String = "") -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var p := Pokemon.create(species, level, rng)
	var spec := {"nature": "hardy", "ivs": 31, "moves": moves}
	if item != "":
		spec["item"] = item
	p.apply_spec(spec)
	return p


func _setup(player: Pokemon, foe: Pokemon, ring: bool) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = [player]
	s.foe_party = [foe]
	s.seed = 9
	s.z_ring = ring
	return s


func _z() -> BattleAction:
	var action := BattleAction.fight(0)
	action.z = true
	return action


func _move_id(events: Array) -> String:
	for event: BattleEvent in events:
		if event.type == BattleEvent.MOVE and event.side == BattleEngine.PLAYER:
			return str(event.value("move"))
	return ""


func _damage(events: Array) -> int:
	for event: BattleEvent in events:
		if event.type == BattleEvent.DAMAGE and event.side == BattleEngine.FOE:
			return int(event.value("amount"))
	return 0


func test_sin_pulsera_el_placaje_sigue_siendo_placaje() -> void:
	var engine := BattleEngine.new(_setup(
		_mon(&"rattata", 50, ["tackle"], "normaliumz"),
		_mon(&"snorlax", 50, ["splash"]), false))
	engine.start()
	assert_eq(engine.request.z_moves.size(), 0)
	var events := engine.submit(_z())
	assert_eq(_move_id(events), "tackle")


func test_el_cristal_de_tipo_sube_la_potencia_y_solo_una_vez() -> void:
	var plain := BattleEngine.new(_setup(
		_mon(&"rattata", 50, ["tackle"]),
		_mon(&"snorlax", 50, ["splash"]), true))
	plain.start()
	var normal := _damage(plain.submit(BattleAction.fight(0)))
	var engine := BattleEngine.new(_setup(
		_mon(&"rattata", 50, ["tackle"], "normaliumz"),
		_mon(&"snorlax", 50, ["splash"]), true))
	engine.start()
	assert_eq(engine.request.z_moves, [0])
	var events := engine.submit(_z())
	assert_eq(_move_id(events), "breakneckblitz")
	assert_gt(_damage(events), normal)
	var again := engine.submit(_z())
	assert_eq(_move_id(again), "tackle")


func test_el_estado_z_aplica_su_efecto_aunque_el_movimiento_no_haga_nada() -> void:
	var engine := BattleEngine.new(_setup(
		_mon(&"rattata", 40, ["splash"], "normaliumz"),
		_mon(&"magikarp", 5, ["splash"]), true))
	engine.start()
	engine.submit(_z())
	assert_eq(engine.active(BattleEngine.PLAYER).boosts[&"atk"], 3)


func test_la_agilidad_z_quita_las_bajadas() -> void:
	var engine := BattleEngine.new(_setup(
		_mon(&"abra", 40, ["agility"], "psychiumz"),
		_mon(&"magikarp", 5, ["splash"]), true))
	engine.start()
	engine.active(BattleEngine.PLAYER).boosts[&"atk"] = -2
	engine.submit(_z())
	var user := engine.active(BattleEngine.PLAYER)
	assert_eq(user.boosts[&"spe"], 2)
	assert_eq(user.boosts[&"atk"], 0)


func test_el_cristal_de_pikachu_solo_cambia_su_movimiento() -> void:
	var wrong := BattleEngine.new(_setup(
		_mon(&"pikachu", 40, ["tackle"], "pikaniumz"),
		_mon(&"snorlax", 50, ["splash"]), true))
	wrong.start()
	assert_eq(wrong.request.z_moves.size(), 0)
	var right := BattleEngine.new(_setup(
		_mon(&"pikachu", 40, ["volttackle"], "pikaniumz"),
		_mon(&"snorlax", 80, ["splash"]), true))
	right.start()
	var events := right.submit(_z())
	assert_eq(_move_id(events), "catastropika")


func test_el_entrenador_rival_tambien_usa_el_poder_z() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [_mon(&"snorlax", 50, ["splash"])]
	s.foe_party = [_mon(&"rattata", 50, ["tackle"], "normaliumz")]
	s.seed = 9
	s.ai_level = 1
	var engine := BattleEngine.new(s)
	engine.start()
	var events := engine.submit(BattleAction.fight(0))
	var used := false
	for event: BattleEvent in events:
		if event.type == BattleEvent.ZMOVE and event.side == BattleEngine.FOE:
			used = event.value("move") == "breakneckblitz"
	assert_true(used)
