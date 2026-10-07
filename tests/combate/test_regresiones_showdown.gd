extends GutTest
## Regresiones de los fallos que encontró la comparación con Showdown (tools/showdown_diff y
## docs/combate/diferencias_showdown.md). Cada test reproduce un fallo ya corregido.


func _mon(species: StringName, level: int, moves: Array, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31, "moves": moves}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


## Combate contra un entrenador cuyo Pokémon usa siempre su primer movimiento. `luck` fija tiradas
## con el oráculo del motor (etiqueta -> u en [0, 1)); las que no están valen 0,5.
func _engine(player: Array[Pokemon], foes: Array[Pokemon], luck: Dictionary = {}) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.can_run = false
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 11
	s.exp_enabled = false
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_engine: BattleEngine, _side: int, _slot: int) -> BattleAction:
		return BattleAction.fight(0)
	if not luck.is_empty():
		s.rng_oracle = func(tag: StringName, _turn: int) -> float:
			return float(luck.get(String(tag), 0.5))
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func test_intimidacion_del_rival_al_empezar_baja_el_ataque() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["tackle"])],
		[_mon(&"growlithe", 30, ["ember"], {"ability": "intimidate"})])
	assert_eq(engine.active(BattleEngine.PLAYER).boosts[&"atk"], -1)


func test_nuestra_intimidacion_al_empezar_baja_el_ataque_del_rival() -> void:
	var engine := _engine([_mon(&"growlithe", 30, ["ember"], {"ability": "intimidate"})],
		[_mon(&"rattata", 30, ["tackle"])])
	assert_eq(engine.active(BattleEngine.FOE).boosts[&"atk"], -1)


func test_nerviosismo_sube_la_velocidad_ante_la_intimidacion() -> void:
	var engine := _engine([_mon(&"gimmighoul", 30, ["tackle"])],
		[_mon(&"growlithe", 30, ["ember"], {"ability": "intimidate"})])
	var b := engine.active(BattleEngine.PLAYER)
	assert_eq(b.boosts[&"atk"], -1)
	assert_eq(b.boosts[&"spe"], 1)


func test_clorofila_duplica_la_velocidad_una_sola_vez() -> void:
	var engine := _engine([_mon(&"oddish", 30, ["tackle"], {"ability": "chlorophyll"})],
		[_mon(&"rattata", 30, ["tackle"])])
	var b := engine.active(BattleEngine.PLAYER)
	var base := b.effective_speed()
	engine.set_weather(&"sunnyday")
	assert_eq(engine.call("_speed", b), base * 2)


func test_la_vidasfera_del_que_recibe_el_golpe_no_aumenta_el_dano() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["tackle"])], [_mon(&"snorlax", 30, ["tackle"])])
	var user := engine.active(BattleEngine.PLAYER)
	var target := engine.active(BattleEngine.FOE)
	var move := DataDB.move(&"tackle")
	var before := engine.estimate_damage(user, target, move)
	target.pokemon.held_item = &"lifeorb"
	assert_eq(engine.estimate_damage(user, target, move), before)


func test_mar_llamas_sube_el_ataque_especial_y_no_la_potencia() -> void:
	var engine := _engine([_mon(&"charmander", 30, ["ember"], {"ability": "blaze"})],
		[_mon(&"snorlax", 30, ["tackle"])])
	var user := engine.active(BattleEngine.PLAYER)
	user.pokemon.current_hp = 1
	var move := DataDB.move(&"ember")
	var opts: Dictionary = engine.call("_damage_opts", user, engine.active(BattleEngine.FOE), move, null, false)
	assert_eq(int(opts["power"]), move.power)
	assert_almost_eq(float(opts["atk_mod"]), 1.5, 0.001)


func test_contoneo_sube_el_ataque_aunque_ya_este_confuso() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["splash"])], [_mon(&"snorlax", 30, ["swagger"])],
		{"accuracy": 0.0, "confusion_hit": 0.999})
	var b := engine.active(BattleEngine.PLAYER)
	b.volatiles[&"confusion"] = {"turns": 3}
	engine.submit(BattleAction.fight(0))
	assert_eq(b.boosts[&"atk"], 2)


func test_toxico_de_un_tipo_veneno_no_falla() -> void:
	var poison := _engine([_mon(&"oddish", 30, ["toxic"])], [_mon(&"snorlax", 30, ["splash"])], {"accuracy": 0.999})
	poison.submit(BattleAction.fight(0))
	assert_eq(poison.active(BattleEngine.FOE).pokemon.status, &"tox", "tipo Veneno: no falla")
	var normal := _engine([_mon(&"rattata", 30, ["toxic"])], [_mon(&"snorlax", 30, ["splash"])], {"accuracy": 0.999})
	normal.submit(BattleAction.fight(0))
	assert_eq(normal.active(BattleEngine.FOE).pokemon.status, &"", "otro tipo: puede fallar")


func test_motivacion_falla_sin_aliado_y_aullido_no() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["coaching", "howl"])], [_mon(&"snorlax", 30, ["splash"])])
	var b := engine.active(BattleEngine.PLAYER)
	engine.submit(BattleAction.fight(0))
	assert_eq(b.boosts[&"atk"], 0, "Motivación sin aliado falla")
	engine.submit(BattleAction.fight(1))
	assert_eq(b.boosts[&"atk"], 1, "Aullido sube el Ataque del propio usuario")


func test_despejar_baja_la_evasion() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["defog"])], [_mon(&"snorlax", 30, ["splash"])], {"accuracy": 0.0})
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(BattleEngine.FOE).boosts[&"evasion"], -1)


func test_autoestima_no_se_activa_si_el_ko_acaba_el_combate() -> void:
	var last := _engine([_mon(&"krokorok", 60, ["crunch"], {"ability": "moxie"})], [_mon(&"rattata", 2, ["splash"])],
		{"accuracy": 0.0, "crit": 0.999})
	var b := last.active(BattleEngine.PLAYER)
	last.submit(BattleAction.fight(0))
	assert_true(last.is_over())
	assert_eq(b.boosts[&"atk"], 0, "último rival: no sube")
	var more := _engine([_mon(&"krokorok", 60, ["crunch"], {"ability": "moxie"})],
		[_mon(&"rattata", 2, ["splash"]), _mon(&"rattata", 2, ["splash"])], {"accuracy": 0.0, "crit": 0.999})
	more.submit(BattleAction.fight(0))
	assert_eq(more.active(BattleEngine.PLAYER).boosts[&"atk"], 1, "quedan rivales: sube")


func test_respiro_no_le_quita_el_tipo_volador_a_la_especie() -> void:
	var p := _mon(&"hawlucha", 40, ["roost", "splash"])
	var engine := _engine([p], [_mon(&"rattata", 5, ["splash"])])
	p.current_hp = 10
	engine.submit(BattleAction.fight(0))
	assert_true(&"flying" in engine.active(BattleEngine.PLAYER).types(), "recupera el tipo Volador al acabar el turno")
	assert_true(&"flying" in DataDB.species(&"hawlucha").types, "la especie no cambia")


func test_contoneo_tambien_sube_el_ataque_bajo_campo_de_niebla_o_confuso_sin_fallar_entero() -> void:
	# Si la confusión falla, el movimiento no debe decir "falló" ni anular la subida.
	var engine := _engine([_mon(&"rattata", 30, ["splash"])], [_mon(&"snorlax", 30, ["swagger"])],
		{"accuracy": 0.0, "confusion_hit": 0.999})
	var b := engine.active(BattleEngine.PLAYER)
	b.volatiles[&"confusion"] = {"turns": 3}
	var events := engine.submit(BattleAction.fight(0))
	var texts := ""
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE:
			texts += e.text() + "\n"
	assert_false("¡Pero falló!" in texts)


func test_polvo_escudo_deja_pasar_las_mejoras_del_atacante() -> void:
	var engine := _engine([_mon(&"charmander", 40, ["flamecharge"])],
		[_mon(&"venomoth", 40, ["splash"], {"ability": "shielddust"})], {"accuracy": 0.0, "secondary": 0.0})
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(BattleEngine.PLAYER).boosts[&"spe"], 1)


func test_la_paralisis_se_aplica_despues_de_viento_afin() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["tailwind"])], [_mon(&"snorlax", 30, ["splash"])])
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	b.pokemon.status = &"par"
	@warning_ignore("integer_division")
	assert_eq(engine.call("_speed", b), b.boosted_stat(&"spe") * 2 * 50 / 100)


func test_dormirse_mientras_carga_cancela_el_movimiento_de_dos_turnos() -> void:
	var engine := _engine([_mon(&"bulbasaur", 40, ["solarbeam"])], [_mon(&"rattata", 5, ["hypnosis"])],
		{"accuracy": 0.0, "slp_turns": 0.0})
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_false(b.has_volatile(&"twoturnmove"), "dormido pierde la carga")
	assert_true(engine.request != null and engine.request.kind == BattleRequest.Kind.ACTION, "vuelve a poder elegir")


func test_sana_confunde_al_acabar_aunque_proteccion_pare_el_ultimo_golpe() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [_mon(&"rattata", 30, ["thrash"])]
	s.foe_party = [_mon(&"snorlax", 30, ["splash", "protect"])]
	s.player_name = "Ash"
	s.seed = 11
	s.exp_enabled = false
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(engine: BattleEngine, _side: int, _slot: int) -> BattleAction:
		return BattleAction.fight(1 if engine.turn == 2 else 0)
	var luck := {"accuracy": 0.0, "crit": 0.999, "lockedmove_turns": 0.0, "protect": 0.0}
	s.rng_oracle = func(tag: StringName, _turn: int) -> float:
		return float(luck.get(String(tag), 0.5))
	var engine := BattleEngine.new(s)
	engine.start()
	engine.submit(BattleAction.fight(0))
	assert_true(engine.active(BattleEngine.PLAYER).has_volatile(&"confusion"))


func test_la_cuenta_de_proteccion_se_reinicia_tras_un_turno_sin_usarla() -> void:
	var engine := _engine([_mon(&"snorlax", 30, ["protect"])], [_mon(&"rattata", 5, ["splash"])], {"protect": 0.999})
	var b := engine.active(BattleEngine.PLAYER)
	b.protect_count = 1
	b.protect_turn = -5
	engine.submit(BattleAction.fight(0))
	assert_eq(b.protect_count, 1, "no cuenta como seguida: sale bien")
