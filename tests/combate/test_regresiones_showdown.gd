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


## Combate con Saña contra un Snorlax que usa Salpicadura (y Protección el turno `protect_turn`).
## `luck_by_turn(tag, turn)` contesta el oráculo.
func _thrash_engine(luck_by_turn: Callable, protect_turn: int = -1, status: StringName = &"") -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	var mon := _mon(&"rattata", 30, ["thrash"])
	mon.status = status
	s.player_party = [mon]
	s.foe_party = [_mon(&"snorlax", 30, ["splash", "protect"])]
	s.player_name = "Ash"
	s.seed = 11
	s.exp_enabled = false
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(engine: BattleEngine, _side: int, _slot: int) -> BattleAction:
		return BattleAction.fight(1 if engine.turn == protect_turn else 0)
	s.rng_oracle = luck_by_turn
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func test_sana_confunde_al_acabar_aunque_la_paralisis_impida_el_ultimo_golpe() -> void:
	var engine := _thrash_engine(func(tag: StringName, turn: int) -> float:
		match String(tag):
			"accuracy": return 0.0
			"crit": return 0.999
			"lockedmove_turns": return 0.0
			"par": return 0.0 if turn == 2 else 0.999
		return 0.5, -1, &"par")
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_eq(engine.turn, 2, "el turno 2 lo juega solo (bloqueado)")
	assert_false(b.has_volatile(&"lockedmove"))
	assert_true(b.has_volatile(&"confusion"), "fatiga aunque no se moviera el último turno")


func test_sana_parada_antes_del_ultimo_turno_acaba_sin_confusion() -> void:
	var engine := _thrash_engine(func(tag: StringName, _turn: int) -> float:
		match String(tag):
			"accuracy": return 0.0
			"crit": return 0.999
			"lockedmove_turns": return 0.999
			"protect": return 0.0
		return 0.5, 2)
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_eq(engine.turn, 2)
	assert_false(b.has_volatile(&"lockedmove"), "Protección corta el arrebato")
	assert_false(b.has_volatile(&"confusion"), "no era el último turno: sin fatiga")


func test_sana_de_tres_turnos_confunde_tras_el_tercero() -> void:
	var engine := _thrash_engine(func(tag: StringName, _turn: int) -> float:
		match String(tag):
			"accuracy": return 0.0
			"crit": return 0.999
			"lockedmove_turns": return 0.999
		return 0.5)
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_eq(engine.turn, 3, "golpea los turnos 1, 2 y 3 sin pedir acción")
	assert_true(b.has_volatile(&"confusion"))


func test_golpe_bajo_falla_si_el_objetivo_tiene_que_recargar() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [_mon(&"snorlax", 50, ["splash", "suckerpunch"])]
	s.foe_party = [_mon(&"rattata", 50, ["hyperbeam"])]
	s.player_name = "Ash"
	s.seed = 11
	s.exp_enabled = false
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_engine: BattleEngine, _side: int, _slot: int) -> BattleAction:
		return BattleAction.fight(0)
	s.rng_oracle = func(tag: StringName, _turn: int) -> float:
		return {"accuracy": 0.0, "crit": 0.999}.get(String(tag), 0.5)
	var engine := BattleEngine.new(s)
	engine.start()
	engine.submit(BattleAction.fight(0))
	var foe := engine.active(BattleEngine.FOE)
	assert_true(foe.has_volatile(&"mustrecharge"))
	var hp := foe.pokemon.current_hp
	engine.submit(BattleAction.fight(1))
	assert_eq(foe.pokemon.current_hp, hp, "Golpe Bajo falla contra quien recarga")


func test_rafaga_escamas_no_mejora_si_el_golpe_acaba_el_combate() -> void:
	var engine := _engine([_mon(&"dragonite", 80, ["scaleshot"])], [_mon(&"rattata", 5, ["splash"])],
		{"accuracy": 0.0})
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_true(engine.is_over())
	assert_eq(b.boosts[&"def"], 0, "Showdown aplica el selfBoost después de procesar el KO")
	assert_eq(b.boosts[&"spe"], 0)


func test_a_bocajarro_si_baja_las_defensas_en_el_golpe_final() -> void:
	var engine := _engine([_mon(&"machamp", 80, ["closecombat"])], [_mon(&"rattata", 5, ["splash"])],
		{"accuracy": 0.0})
	engine.submit(BattleAction.fight(0))
	var b := engine.active(BattleEngine.PLAYER)
	assert_true(engine.is_over())
	assert_eq(b.boosts[&"def"], -1, "es efecto del golpe: se aplica antes de procesar el KO")


func test_el_final_de_turno_se_corta_cuando_un_bando_se_queda_sin_pokemon() -> void:
	var player := _mon(&"snorlax", 30, ["splash"])
	player.status = &"brn"
	var foe := _mon(&"rattata", 30, ["splash"])
	foe.status = &"psn"
	foe.current_hp = 1
	var engine := _engine([player], [foe])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over(), "el veneno debilita al último rival")
	assert_eq(player.current_hp, player.max_hp(), "la quemadura del ganador ya no llega")


func test_el_veneno_va_antes_que_la_quemadura_al_final_del_turno() -> void:
	# Nuestro Pokémon es más rápido, pero el veneno (orden 9) va antes que la quemadura (orden 10).
	var player := _mon(&"jolteon", 50, ["splash"])
	player.status = &"brn"
	player.current_hp = 1
	var foe := _mon(&"snorlax", 30, ["splash"])
	foe.status = &"psn"
	foe.current_hp = 1
	var engine := _engine([player], [foe])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over())
	assert_eq(engine.result.outcome, BattleResult.WIN, "el rival cae por el veneno antes de la quemadura")


func test_mudar_cura_con_un_33_por_ciento() -> void:
	var player := _mon(&"dratini", 30, ["splash"], {"ability": "shedskin"})
	player.status = &"par"
	var engine := _engine([player], [_mon(&"rattata", 30, ["splash"])], {"shedskin": 0.332, "par": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(player.status, &"par", "33/100 y no 1/3: con 0,332 no cura")


func test_nerviosismo_sube_la_velocidad_con_cada_golpe() -> void:
	var engine := _engine([_mon(&"toxel", 60, ["splash"], {"ability": "rattled"})],
		[_mon(&"heracross", 30, ["pinmissile"])], {"accuracy": 0.0, "multihit": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(BattleEngine.PLAYER).boosts[&"spe"], 2, "Pin Misil golpea 2 veces: +2")


func test_casco_dentado_hace_dano_con_cada_golpe() -> void:
	var holder := _mon(&"snorlax", 60, ["splash"], {"item": "rockyhelmet"})
	var foe := _mon(&"rattata", 30, ["doublekick"])
	var engine := _engine([holder], [foe], {"accuracy": 0.0, "crit": 0.999})
	var start := foe.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(start - foe.current_hp, 2 * maxi(1, foe.max_hp() / 6), "Doble Patada: dos golpes, dos veces el Casco")


# --- Objetos (comparación con --items) ---

func test_las_bayas_de_sabor_se_comen_a_un_cuarto_de_los_ps() -> void:
	var holder := _mon(&"snorlax", 50, ["splash"], {"item": "aguavberry"})
	holder.current_hp = holder.max_hp() * 2 / 5
	var engine := _engine([holder], [_mon(&"rattata", 5, ["tackle"])], {"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(holder.held_item, &"aguavberry", "al 40 % todavía no se la come")


func test_atania_despierta_tras_descanso() -> void:
	var holder := _mon(&"snorlax", 50, ["rest"], {"item": "chestoberry"})
	holder.current_hp = 10
	var engine := _engine([holder], [_mon(&"rattata", 5, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(holder.status, &"", "se come la Atania y se despierta")
	assert_eq(holder.current_hp, holder.max_hp())
	assert_eq(holder.held_item, &"")


func test_el_drenaje_cura_antes_del_casco_dentado() -> void:
	var user := _mon(&"fomantis", 60, ["leechlife"])
	var engine := _engine([user], [_mon(&"snorlax", 60, ["splash"], {"item": "rockyhelmet"})],
		{"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(user.current_hp, user.max_hp() - user.max_hp() / 6, "con los PS al máximo, el drenaje no cura y luego llega el Casco")


func test_puas_van_al_campo_rival_aunque_no_quede_nadie() -> void:
	var player := _mon(&"jolteon", 50, ["doubleedge"])
	player.current_hp = 1
	var engine := _engine([player, _mon(&"rattata", 30, ["tackle"])], [_mon(&"snorlax", 30, ["spikes"])],
		{"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_true(player.is_fainted(), "cae por el retroceso")
	assert_true(engine.has_side_condition(BattleEngine.PLAYER, &"spikes"))


func test_superdiente_no_lo_reduce_la_baya_chilan() -> void:
	var holder := _mon(&"snorlax", 50, ["splash"], {"item": "chilanberry"})
	var engine := _engine([holder], [_mon(&"rattata", 50, ["superfang"])], {"accuracy": 0.0})
	var start := holder.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(holder.current_hp, start - start / 2)
	assert_eq(holder.held_item, &"chilanberry", "con daño fijo no se la come")


func test_nerviosismo_no_sube_si_la_intimidacion_no_baja_nada() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["splash"]), _mon(&"growlithe", 30, ["ember"], {"ability": "intimidate"})],
		[_mon(&"gimmighoul", 30, ["splash"], {"ability": "rattled"})])
	var foe := engine.active(BattleEngine.FOE)
	foe.boosts[&"atk"] = -6
	foe.boosts[&"spe"] = 0
	engine.submit(BattleAction.switch_to(1))
	assert_eq(foe.boosts[&"spe"], 0, "a −6 no le baja el Ataque: Nerviosismo no se activa")


func test_el_panuelo_eleccion_no_bloquea_si_retrocede() -> void:
	var holder := _mon(&"rattata", 30, ["tackle", "quickattack"], {"item": "choicescarf"})
	var engine := _engine([holder], [_mon(&"meowth", 60, ["fakeout"])], {"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(BattleEngine.PLAYER).choice_move, &"", "retrocedió sin usar el movimiento")


func test_picoteo_se_come_la_baya_y_cura_aunque_tenga_los_ps_altos() -> void:
	var user := _mon(&"rookidee", 60, ["pluck"])
	user.current_hp = user.max_hp() / 2
	var victim := _mon(&"hitmonlee", 60, ["splash"], {"item": "aguavberry", "ability": "unburden"})
	var engine := _engine([user], [victim], {"accuracy": 0.0, "crit": 0.999})
	var hp := user.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(victim.held_item, &"")
	assert_eq(user.current_hp, mini(user.max_hp(), hp + user.max_hp() / 3), "le hace efecto aunque no esté a un cuarto")
	assert_true(engine.active(BattleEngine.FOE).unburdened, "quitarle la baya activa Liviano")


func test_picoteo_roba_la_baya_antes_de_que_se_la_coma_su_dueno() -> void:
	var victim := _mon(&"snorlax", 60, ["splash"], {"item": "oranberry"})
	victim.current_hp = victim.max_hp() / 2 + 5
	var user := _mon(&"rookidee", 60, ["pluck"])
	user.current_hp = 20
	var engine := _engine([user], [victim], {"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	assert_eq(user.current_hp, 30, "la Aranja cura 10 PS al que picotea")


func test_tras_caer_los_dos_la_intimidacion_encuentra_al_nuevo_rival() -> void:
	var engine := _engine([_mon(&"voltorb", 80, ["explosion"]), _mon(&"growlithe", 30, ["ember"], {"ability": "intimidate"})],
		[_mon(&"rattata", 5, ["splash"]), _mon(&"raticate", 30, ["tackle"])], {"accuracy": 0.0, "crit": 0.999})
	engine.submit(BattleAction.fight(0))
	if engine.request != null and engine.request.kind == BattleRequest.Kind.SWITCH:
		engine.submit(BattleAction.switch_to(1))
	assert_eq(engine.active(BattleEngine.FOE).pokemon.species_id, &"raticate")
	assert_eq(engine.active(BattleEngine.FOE).boosts[&"atk"], -1)


func test_las_puas_toxicas_no_envenenan_con_velo_sagrado() -> void:
	var engine := _engine([_mon(&"ariados", 50, ["splash"])], [_mon(&"rattata", 30, ["splash"]), _mon(&"sandile", 30, ["splash"])])
	engine.add_side_condition(BattleEngine.FOE, &"toxicspikes", engine.active(BattleEngine.PLAYER))
	engine.add_side_condition(BattleEngine.FOE, &"safeguard", engine.active(BattleEngine.FOE))
	engine._put_in(BattleEngine.FOE, 1, false)
	assert_eq(engine.active(BattleEngine.FOE).pokemon.status, &"", "Velo Sagrado: la fuente es el rival")


func test_aguijon_letal_no_sube_si_el_ko_acaba_el_combate() -> void:
	var engine := _engine([_mon(&"leavanny", 80, ["fellstinger"])], [_mon(&"rattata", 5, ["splash"])], {"accuracy": 0.0})
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over())
	assert_eq(engine.active(BattleEngine.PLAYER).boosts[&"atk"], 0)


func test_tornado_hace_el_doble_a_quien_vuela() -> void:
	var luck := {"accuracy": 0.0, "crit": 0.999, "damage_roll": 0.999}
	var air := _engine([_mon(&"noibat", 60, ["fly", "splash"])], [_mon(&"pidgey", 10, ["gust"])], luck)
	var ground := _engine([_mon(&"noibat", 60, ["fly", "splash"])], [_mon(&"pidgey", 10, ["gust"])], luck)
	var a := air.active(BattleEngine.PLAYER).pokemon
	var g := ground.active(BattleEngine.PLAYER).pokemon
	air.submit(BattleAction.fight(0))
	ground.submit(BattleAction.fight(1))
	var hit_air := a.max_hp() - a.current_hp
	var hit_ground := g.max_hp() - g.current_hp
	assert_gt(hit_ground, 0)
	assert_almost_eq(hit_air, 2 * hit_ground, 1)
