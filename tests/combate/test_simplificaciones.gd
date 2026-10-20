extends GutTest
## Las simplificaciones del bloque 2 de la petición 81, corregidas una a una (contrastadas con Showdown
## y Bulbapedia): Cede Paso y Último Lugar en dobles, Premonición, Mimético, Plegaria Vital, Gravedad,
## Fijar Blanco, Dracoflechas, Sustituto con retroceso y drenaje, y Metrónomo.


func _mon(species: StringName, level: int, moves: Array, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31, "moves": moves}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


func _setup(player: Array[Pokemon], foes: Array[Pokemon], double: bool = false, foe_moves: Array = []) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	if double:
		s.format = BattleSetup.Format.DOUBLE
	if not foe_moves.is_empty():
		s.foe_controller = func(_engine: BattleEngine, _side: int, slot: int) -> BattleAction:
			return foe_moves[slot] as BattleAction
	return s


func _start(s: BattleSetup) -> BattleEngine:
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


## Un turno en dobles: las dos acciones del jugador.
func _turn2(engine: BattleEngine, a: BattleAction, b: BattleAction) -> Array[BattleEvent]:
	var events: Array[BattleEvent] = engine.submit(a)
	events.append_array(engine.submit(b))
	return events


func _movers(events: Array[BattleEvent]) -> Array[String]:
	var out: Array[String] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MOVE:
			out.append("%d:%d" % [e.side, e.slot])
	return out


func _hits(events: Array[BattleEvent], side: int, slot: int, source: String = "move") -> int:
	var n := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == side and e.slot == slot and e.value("source") == source:
			n += 1
	return n


func _amount(events: Array[BattleEvent], type: StringName, side: int, source: String) -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == type and e.side == side and e.value("source") == source:
			total += int(e.value("amount"))
	return total


func test_cede_paso_adelanta_al_rival_lento_en_dobles() -> void:
	var s := _setup([_mon(&"jolteon", 50, ["afteryou", "splash"]), _mon(&"snorlax", 50, ["splash"])],
		[_mon(&"pikachu", 50, ["splash"]), _mon(&"shuckle", 50, ["splash"])], true,
		[BattleAction.fight(0), BattleAction.fight(0)])
	var engine := _start(s)
	var order := _movers(_turn2(engine, BattleAction.fight(0, 1), BattleAction.fight(0)))
	assert_eq(order.slice(0, 2), ["0:0", "1:1"] as Array[String], "Shuckle actúa justo después de Cede Paso: %s" % [order])


func test_ultimo_lugar_retrasa_al_rival_rapido_en_dobles() -> void:
	var s := _setup([_mon(&"jolteon", 50, ["quash", "splash"]), _mon(&"snorlax", 50, ["splash"])],
		[_mon(&"pikachu", 50, ["splash"]), _mon(&"shuckle", 50, ["splash"])], true,
		[BattleAction.fight(0), BattleAction.fight(0)])
	var engine := _start(s)
	var order := _movers(_turn2(engine, BattleAction.fight(0, 0), BattleAction.fight(0)))
	assert_eq(order.back(), "1:0", "Pikachu, más rápido que Snorlax y Shuckle, acaba el último: %s" % [order])


func _future_sight_damage(boost: bool) -> int:
	var s := _setup([_mon(&"alakazam", 50, ["futuresight", "nastyplot", "splash"])],
		[_mon(&"snorlax", 50, ["splash"])], false, [BattleAction.fight(0)])
	var engine := _start(s)
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(1 if boost else 2))
	return _amount(engine.submit(BattleAction.fight(2)), BattleEvent.DAMAGE, BattleEngine.FOE, "futuresight")


func test_premonicion_calcula_el_dano_al_golpear() -> void:
	var plain := _future_sight_damage(false)
	var boosted := _future_sight_damage(true)
	assert_gt(plain, 0)
	assert_gt(boosted, int(plain * 1.5), "Maquinación entre medias cuenta: %d → %d" % [plain, boosted])


func test_mimetico_se_pierde_al_retirarse() -> void:
	var slow := _mon(&"slowpoke", 50, ["mimic", "splash"])
	var s := _setup([slow, _mon(&"snorlax", 50, ["splash"])], [_mon(&"rattata", 50, ["tackle"])], false,
		[BattleAction.fight(0)])
	var engine := _start(s)
	engine.submit(BattleAction.fight(0))
	assert_eq(slow.moves[0].id, &"tackle", "copia Placaje")
	engine.submit(BattleAction.switch_to(1))
	assert_eq(slow.moves[0].id, &"mimic", "al retirarse recupera Mimético")


func test_plegaria_vital_deja_elegir_a_quien_revivir() -> void:
	var b := _mon(&"pikachu", 50, ["splash"])
	var c := _mon(&"eevee", 50, ["splash"])
	b.current_hp = 0
	c.current_hp = 0
	var s := _setup([_mon(&"pawmot", 50, ["revivalblessing"]), b, c], [_mon(&"snorlax", 50, ["splash"])], false,
		[BattleAction.fight(0)])
	var engine := _start(s)
	engine.submit(BattleAction.fight(0))
	assert_not_null(engine.request)
	assert_eq(engine.request.reason, &"revivalblessing")
	engine.submit(BattleAction.switch_to(2))
	assert_eq(c.current_hp, c.max_hp() / 2, "revive al elegido con la mitad de los PS")
	assert_true(b.is_fainted(), "el otro sigue debilitado")


func test_gravedad_sube_la_precision() -> void:
	assert_eq(Effects.condition(&"gravity").modify_accuracy(null, null, null, null, 60), 100)
	# Con el azar fijado en 0,9: Onda Certera (70) falla sin Gravedad y acierta con ella (×5/3).
	for with_gravity: bool in [false, true]:
		var s := _setup([_mon(&"alakazam", 50, ["gravity", "focusblast", "splash"])],
			[_mon(&"snorlax", 50, ["splash"])], false, [BattleAction.fight(0)])
		s.rng_oracle = func(tag: StringName, _turn: int) -> float: return 0.9 if tag == &"accuracy" else 0.5
		var engine := _start(s)
		engine.submit(BattleAction.fight(0 if with_gravity else 2))
		var events := engine.submit(BattleAction.fight(1))
		assert_eq(_hits(events, BattleEngine.FOE, 0) > 0, with_gravity, "Gravedad: %s" % with_gravity)


func test_fijar_blanco_alcanza_al_que_vuela() -> void:
	var s := _setup([_mon(&"jolteon", 50, ["lockon", "thunderbolt"])], [_mon(&"pidgeot", 50, ["fly"])], false,
		[BattleAction.fight(0)])
	var engine := _start(s)
	engine.submit(BattleAction.fight(0))
	var events := engine.submit(BattleAction.fight(1))
	assert_gt(_hits(events, BattleEngine.FOE, 0), 0, "el Rayo alcanza a Pidgeot en el aire")


func test_dracoflechas_reparte_en_dobles() -> void:
	var foes: Array[Pokemon] = [_mon(&"snorlax", 50, ["splash"]), _mon(&"snorlax", 50, ["splash"])]
	var s := _setup([_mon(&"dragapult", 50, ["dragondarts"]), _mon(&"snorlax", 50, ["splash"])], foes, true,
		[BattleAction.fight(0), BattleAction.fight(0)])
	var events := _turn2(_start(s), BattleAction.fight(0, 0), BattleAction.fight(0))
	assert_eq([_hits(events, 1, 0), _hits(events, 1, 1)], [1, 1], "un dardo a cada rival")
	# Si el elegido es inmune (Hada), los dos dardos van al otro.
	foes = [_mon(&"clefable", 50, ["splash"]), _mon(&"snorlax", 50, ["splash"])]
	s = _setup([_mon(&"dragapult", 50, ["dragondarts"]), _mon(&"snorlax", 50, ["splash"])], foes, true,
		[BattleAction.fight(0), BattleAction.fight(0)])
	var eng2 := _start(s)
	events = _turn2(eng2, BattleAction.fight(0, 0), BattleAction.fight(0))
	assert_eq([_hits(events, 1, 0), _hits(events, 1, 1)], [0, 2], "los dos al que se puede alcanzar")


func test_el_dano_al_sustituto_cuenta_para_drenaje_y_retroceso() -> void:
	for move: String in ["gigadrain", "doubleedge"]:
		var user := _mon(&"snorlax", 50, [move])
		user.current_hp = user.max_hp() / 2
		var s := _setup([user], [_mon(&"jolteon", 50, ["substitute", "splash"])], false, [BattleAction.fight(0)])
		var engine := _start(s)
		var events := engine.submit(BattleAction.fight(0))
		if move == "gigadrain":
			assert_gt(_amount(events, BattleEvent.HEAL, BattleEngine.PLAYER, "drain"), 0, "Gigadrenado cura al dar al sustituto")
		else:
			assert_gt(_amount(events, BattleEvent.DAMAGE, BattleEngine.PLAYER, "recoil"), 0, "Doble Filo tiene retroceso")


func test_metronomo_usa_la_lista_de_la_novena_generacion() -> void:
	var pool := preload("res://src/battle/effects/moves/metronome.gd").pool()
	var unobtainable := 0
	for id: StringName in pool:
		var m := DataDB.move(id)
		assert_true(m.nonstandard in [&"", &"unobtainable"], String(id))
		if m.nonstandard == &"unobtainable":
			unobtainable += 1
	assert_gt(unobtainable, 0, "los no disponibles también valen")
	assert_false(&"metronome" in pool)
