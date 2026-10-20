extends GutTest
## Los movimientos normales que aún no usaba nadie (85 de la petición 81): un caso por familia.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _engine(player: Array[Pokemon], foes: Array[Pokemon], foe_move: int = 0) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_e: BattleEngine, _side: int, _slot: int) -> BattleAction: return BattleAction.fight(foe_move)
	s.rng_oracle = func(tag: StringName, _turn: int) -> float: return 0.99 if tag in [&"crit", &"secondary"] else 0.5
	var engine := BattleEngine.new(s)
	engine.start()
	engine.active(0).ability = &"runaway"
	engine.active(1).ability = &"runaway"
	return engine


func _damage(events: Array[BattleEvent], side: int, source: String = "move") -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == side and e.value("source") == source:
			total += int(e.value("amount"))
	return total


func test_ya_solo_falta_forcejeo() -> void:
	var missing: PackedStringArray = []
	for id: StringName in DataDB.move_ids():
		var m := DataDB.move(id)
		if m.needs_script and not Effects.has_move(id) and m.nonstandard == &"" and id != &"struggle":
			missing.append(String(id))
	assert_eq(missing.size(), 0, ", ".join(missing))


func test_potencia_segun_el_objetivo() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["crushgrip"])], [_mon(&"snorlax", 50, ["splash"])])
	var foe := engine.active(1)
	assert_eq(Effects.move(&"crushgrip").base_power(engine, engine.active(0), foe, DataDB.move(&"crushgrip"), 0), 120)
	foe.pokemon.current_hp = foe.pokemon.max_hp() / 2
	assert_eq(Effects.move(&"crushgrip").base_power(engine, engine.active(0), foe, DataDB.move(&"crushgrip"), 0),
		120 * foe.pokemon.current_hp / foe.pokemon.max_hp(), "proporcional a los PS que le quedan")
	foe.pokemon.status = &"psn"
	assert_eq(Effects.move(&"barbbarrage").base_power(engine, engine.active(0), foe, DataDB.move(&"barbbarrage"), 60), 120)


func test_plancha_corporal_usa_la_defensa() -> void:
	var opts := {}
	Effects.move(&"bodypress").modify_damage_opts(null, null, null, DataDB.move(&"bodypress"), opts)
	assert_eq(opts.get("atk_stat"), &"def")


func test_metalaser_cuesta_la_mitad_de_los_ps() -> void:
	var engine := _engine([_mon(&"metagross", 50, ["steelbeam"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	engine.submit(BattleAction.fight(0))
	assert_eq(me.pokemon.current_hp, me.pokemon.max_hp() - ceili(me.pokemon.max_hp() / 2.0))


func test_hacha_de_piedra_deja_trampa_rocas() -> void:
	var engine := _engine([_mon(&"kleavor", 50, ["stoneaxe"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.has_side_condition(1, &"stealthrock"))


func test_en_salazon_dana_cada_turno() -> void:
	var engine := _engine([_mon(&"garganacl", 50, ["saltcure", "splash"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.active(1).has_volatile(&"saltcure"))
	assert_gt(_damage(engine.submit(BattleAction.fight(1)), 1, "saltcure"), 0)


func test_meteorrayo_carga_y_sube_el_ataque_especial() -> void:
	var engine := _engine([_mon(&"clefable", 50, ["meteorbeam"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).boosts[&"spa"], 1)


func test_cambiaalmas_intercambia_niveles() -> void:
	var engine := _engine([_mon(&"manaphy", 50, ["heartswap"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.active(1).boosts[&"atk"] = 2
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).boosts[&"atk"], 2)
	assert_eq(engine.active(1).boosts[&"atk"], 0)


func test_desahogo_dobla_si_le_bajaron_algo() -> void:
	var engine := _engine([_mon(&"thievul", 50, ["lashout"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	me.lowered_turn = engine.turn
	assert_eq(Effects.move(&"lashout").base_power(engine, me, engine.active(1), DataDB.move(&"lashout"), 75), 150)


func test_cataclismo_quita_la_mitad() -> void:
	var engine := _engine([_mon(&"tinglu", 50, ["ruination"])], [_mon(&"snorlax", 50, ["splash"])])
	var foe := engine.active(1)
	var hp := foe.pokemon.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.pokemon.current_hp, hp - hp / 2)


func test_movimientos_dinamax_hacen_su_efecto() -> void:
	var engine := _engine([_mon(&"charizard", 50, ["flamethrower"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	var effect := Effects.move(&"maxflare")
	assert_not_null(effect)
	effect.on_after_hit(engine, me, engine.active(1), DataDB.move(&"maxflare"), 10)
	assert_eq(engine.weather(), &"sunnyday", "Llamarada Dinamax pone sol")
	Effects.move(&"maxairstream").on_after_hit(engine, me, engine.active(1), DataDB.move(&"maxairstream"), 10)
	assert_eq(me.boosts[&"spe"], 1, "Viento Dinamax sube la Velocidad")
	Effects.move(&"maxstrike").on_after_hit(engine, me, engine.active(1), DataDB.move(&"maxstrike"), 10)
	assert_eq(engine.active(1).boosts[&"spe"], -1, "Ataque Dinamax la baja al rival")
