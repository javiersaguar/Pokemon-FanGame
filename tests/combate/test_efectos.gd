extends GutTest
## Sistema de efectos (Fase 9.1) y movimientos con script: clima, campos, condiciones de bando,
## volátiles, movimientos de dos turnos, bloqueados, de recarga, de cambio y de potencia variable.


func _mon(species: StringName, level: int, moves: Array, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31, "moves": moves}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


func _engine(player: Array[Pokemon], foes: Array[Pokemon], trainer: bool = false, seed_value: int = 3) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER if trainer else BattleSetup.Kind.WILD
	s.can_run = not trainer
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = seed_value
	if trainer:
		s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func _texts(events: Array[BattleEvent]) -> String:
	var lines: PackedStringArray = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE:
			lines.append(e.text())
	return "\n".join(lines)


func _find(events: Array[BattleEvent], type: StringName, side: int = -2) -> Array[BattleEvent]:
	var out: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == type and (side == -2 or e.side == side):
			out.append(e)
	return out


func _damage_to(events: Array[BattleEvent], side: int, source: String = "move") -> int:
	var total := 0
	for e: BattleEvent in _find(events, BattleEvent.DAMAGE, side):
		if e.value("source") == source:
			total += int(e.value("amount"))
	return total


func test_todos_los_scripts_cargan() -> void:
	for file: String in DirAccess.get_files_at(Effects.MOVES_DIR):
		if file.ends_with(".gd"):
			assert_not_null(Effects.move(StringName(file.get_basename())), file)
	for file: String in DirAccess.get_files_at(Effects.CONDITIONS_DIR):
		if file.ends_with(".gd"):
			assert_not_null(Effects.condition(StringName(file.get_basename())), file)
	assert_null(Effects.move(&"tackle"), "los movimientos de datos no tienen script")


func test_danza_lluvia_potencia_el_agua_y_dura_cinco_turnos() -> void:
	var engine := _engine([_mon(&"squirtle", 30, ["raindance", "watergun"])], [_mon(&"snorlax", 30, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(engine.weather(), &"raindance")
	assert_eq(_find(events, BattleEvent.WEATHER)[0].value("weather"), "raindance")
	assert_string_contains(_texts(events), "¡Ha empezado a llover!")
	var squirtle := engine.active(0)
	var snorlax := engine.active(1)
	var opts := engine._damage_opts(squirtle, snorlax, DataDB.move(&"watergun"), null, false)
	assert_eq(opts["weather"], 1.5)
	var dry := DamageCalc.calculate(squirtle, snorlax, DataDB.move(&"watergun"), false, 0)
	var wet := DamageCalc.calculate(squirtle, snorlax, DataDB.move(&"watergun"), false, 0, opts)
	assert_gt(wet, dry)
	var all := events
	for i: int in 5:
		all.append_array(engine.submit(BattleAction.fight(1)))
	assert_eq(engine.weather(), &"")
	assert_string_contains(_texts(all), "Ha dejado de llover.")


func test_proteccion_bloquea_y_falla_si_mueve_el_ultimo() -> void:
	# Los dos usan Protección: Jolteon (más rápido) se protege y a Snorlax ya no le queda nadie detrás.
	var slow := _mon(&"snorlax", 30, ["protect"])
	var engine := _engine([slow], [_mon(&"jolteon", 30, ["protect"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡El Jolteon salvaje se está protegiendo!")
	assert_string_contains(_texts(events), "¡Pero falló!", "Jolteon ya se ha movido: no queda nadie")
	var fast := _mon(&"jolteon", 30, ["protect"])
	var engine2 := _engine([fast], [_mon(&"snorlax", 30, ["tackle"])])
	events = engine2.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Jolteon se ha protegido!")
	assert_eq(fast.current_hp, fast.max_hp())
	assert_false(engine2.active(0).has_volatile(&"protect"), "dura solo un turno")


func test_drenadoras() -> void:
	var player := _mon(&"bulbasaur", 30, ["leechseed", "splash"])
	var foe := _mon(&"rattata", 30, ["splash"])
	var engine := _engine([player], [foe])
	player.take_damage(20)
	var events := engine.submit(BattleAction.fight(0))
	assert_true(engine.active(1).has_volatile(&"leechseed"))
	assert_eq(_damage_to(events, 1, "leechseed"), foe.max_hp() / 8)
	assert_string_contains(_texts(events), "¡Las drenadoras han restado salud al Rattata salvaje!")
	assert_eq(player.current_hp, player.max_hp() - 20 + foe.max_hp() / 8)
	var grass := _engine([_mon(&"bulbasaur", 30, ["leechseed"])], [_mon(&"oddish", 30, ["splash"])])
	assert_string_contains(_texts(grass.submit(BattleAction.fight(0))), "No afecta al Oddish salvaje...")


func test_giro_fuego_atrapa_y_dana() -> void:
	var engine := _engine([_mon(&"charmander", 30, ["firespin"])], [_mon(&"snorlax", 30, ["splash"]), ], false)
	var foe := engine.active(1)
	var events := engine.submit(BattleAction.fight(0))
	assert_true(foe.has_volatile(&"partiallytrapped"))
	assert_eq(_damage_to(events, 1, "partiallytrapped"), foe.pokemon.max_hp() / 8)
	var trapped := _engine([_mon(&"snorlax", 30, ["splash"]), _mon(&"pidgey", 5, ["tackle"])], [_mon(&"charmander", 50, ["firespin"])])
	trapped.submit(BattleAction.fight(0))
	assert_true(trapped.active(0).has_volatile(&"partiallytrapped"))
	assert_false(trapped.request.can_switch, "atrapado: no puede cambiar")
	assert_false(trapped.request.can_run, "ni huir")


func test_reflejo_reduce_el_dano_fisico() -> void:
	var engine := _engine([_mon(&"snorlax", 50, ["reflect", "splash"])], [_mon(&"machamp", 50, ["tackle"])])
	var mine := engine.active(0)
	var foe := engine.active(1)
	var normal := DamageCalc.calculate(foe, mine, DataDB.move(&"tackle"), false, 0, engine._damage_opts(foe, mine, DataDB.move(&"tackle"), null, false))
	engine.submit(BattleAction.fight(0))
	assert_true(engine.has_side_condition(0, &"reflect"))
	var screened := DamageCalc.calculate(foe, mine, DataDB.move(&"tackle"), false, 0, engine._damage_opts(foe, mine, DataDB.move(&"tackle"), null, false))
	assert_almost_eq(float(screened), normal / 2.0, 1.0)
	var crit := DamageCalc.calculate(foe, mine, DataDB.move(&"tackle"), true, 0, engine._damage_opts(foe, mine, DataDB.move(&"tackle"), null, true))
	assert_gt(crit, screened, "el crítico ignora Reflejo")


func test_rayo_solar_carga_un_turno_salvo_con_sol() -> void:
	var p := _mon(&"bulbasaur", 30, ["solarbeam", "sunnyday"])
	var engine := _engine([p], [_mon(&"snorlax", 30, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Bulbasaur está absorbiendo luz!")
	assert_eq(_find(events, BattleEvent.TURN).size(), 2, "el segundo turno va solo, sin pedir acción")
	var hits := 0
	for e: BattleEvent in _find(events, BattleEvent.DAMAGE, 1):
		hits += 1
	assert_eq(hits, 1, "golpea en el segundo turno")
	assert_eq(p.moves[0].pp, p.moves[0].max_pp() - 1, "gasta PP una sola vez")
	events = engine.submit(BattleAction.fight(1))
	events = engine.submit(BattleAction.fight(0))
	assert_false(_texts(events).contains("absorbiendo luz"), "con sol dispara sin cargar")
	assert_eq(_find(events, BattleEvent.DAMAGE, 1).size(), 1)


func test_hiperrayo_obliga_a_recargar() -> void:
	var engine := _engine([_mon(&"snorlax", 50, ["hyperbeam"])], [_mon(&"blissey", 50, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Snorlax necesita recuperarse!")
	assert_eq(_find(events, BattleEvent.TURN).size(), 2)


func test_golpe_se_bloquea_y_acaba_en_confusion() -> void:
	var p := _mon(&"tauros", 50, ["thrash", "tackle"])
	var engine := _engine([p], [_mon(&"blissey", 60, ["splash"])], false, 11)
	var events := engine.submit(BattleAction.fight(0))
	var turns := _find(events, BattleEvent.TURN).size()
	assert_between(turns, 2, 3, "2-3 turnos seguidos sin pedir acción")
	assert_string_contains(_texts(events), "¡Tauros está agotado!")
	assert_true(engine.active(0).has_volatile(&"confusion"))


func test_ida_y_vuelta_pide_el_cambio_a_mitad_de_turno() -> void:
	var a := _mon(&"scyther", 40, ["uturn"])
	var b := _mon(&"pidgey", 40, ["tackle"])
	var engine := _engine([a, b], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.request.kind, BattleRequest.Kind.SWITCH)
	assert_eq(engine.request.reason, &"uturn")
	assert_false(engine.request.can_run)
	var events := engine.submit(BattleAction.switch_to(1))
	assert_eq(engine.active(0).pokemon, b)
	assert_eq(_find(events, BattleEvent.SWITCH_OUT, 0).size(), 1)
	assert_eq(engine.request.kind, BattleRequest.Kind.ACTION)


func test_relevo_pasa_los_cambios_de_caracteristicas() -> void:
	var a := _mon(&"jolteon", 40, ["swordsdance", "batonpass"])
	var b := _mon(&"pidgey", 40, ["tackle"])
	var engine := _engine([a, b], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(1))
	assert_eq(engine.request.reason, &"batonpass")
	engine.submit(BattleAction.switch_to(1))
	assert_eq(engine.active(0).pokemon, b)
	assert_eq(engine.active(0).boosts[&"atk"], 2)


func test_danos_fijos_y_potencia_variable() -> void:
	var engine := _engine([_mon(&"rattata", 30, ["superfang", "endeavor", "flail"])], [_mon(&"snorlax", 30, ["splash"])])
	var foe := engine.active(1)
	var hp := foe.pokemon.current_hp
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_damage_to(events, 1), hp / 2, "Superdiente: la mitad de lo que le queda")
	var user := engine.active(0)
	user.pokemon.current_hp = 5
	events = engine.submit(BattleAction.fight(1))
	assert_eq(foe.pokemon.current_hp, 5, "Esfuerzo: los mismos PS que el usuario")
	var flail := Effects.move(&"flail")
	user.pokemon.current_hp = 1
	assert_eq(flail.base_power(engine, user, foe, DataDB.move(&"flail"), 0), 200)
	user.pokemon.current_hp = user.pokemon.max_hp()
	assert_eq(flail.base_power(engine, user, foe, DataDB.move(&"flail"), 0), 20)


func test_descanso() -> void:
	var p := _mon(&"snorlax", 40, ["rest", "tackle"])
	var engine := _engine([p], [_mon(&"rattata", 10, ["splash"])])
	p.take_damage(50)
	p.set_status(&"par")
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(p.current_hp, p.max_hp())
	assert_eq(p.status, &"slp")
	assert_string_contains(_texts(events), "¡Snorlax se ha echado a dormir y está como nuevo!")
	events = engine.submit(BattleAction.fight(1))
	events.append_array(engine.submit(BattleAction.fight(1)))
	assert_eq(p.status, &"slp", "duerme dos turnos")
	events = engine.submit(BattleAction.fight(1))
	assert_eq(p.status, &"", "al tercero se despierta y ataca")


func test_campo_de_niebla() -> void:
	var engine := _engine([_mon(&"clefairy", 40, ["mistyterrain", "thunderwave"])], [_mon(&"rattata", 40, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.terrain(), &"mistyterrain")
	var events := engine.submit(BattleAction.fight(1))
	assert_eq(engine.active(1).pokemon.status, &"")
	assert_string_contains(_texts(events), "se ha protegido con el Campo de Niebla")
	var dragon := DataDB.move(&"dragonbreath")
	var opts := engine._damage_opts(engine.active(1), engine.active(0), dragon, null, false)
	assert_eq(opts["power"], DamageCalc.modify(dragon.power, 0.5), "Dragón a la mitad contra los que tocan el suelo")


func test_viento_afin_dobla_la_velocidad() -> void:
	var engine := _engine([_mon(&"pidgey", 30, ["tailwind", "tackle"])], [_mon(&"jolteon", 30, ["splash"])])
	var pidgey := engine.active(0)
	var before := engine.speed_of(pidgey)
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.speed_of(pidgey), before * 2)


func test_red_viscosa_al_entrar() -> void:
	var foes: Array[Pokemon] = [_mon(&"rattata", 5, ["splash"]), _mon(&"pidgey", 5, ["splash"])]
	var engine := _engine([_mon(&"spinarak", 40, ["stickyweb", "tackle"])], foes, true)
	engine.submit(BattleAction.fight(0))
	assert_true(engine.has_side_condition(1, &"stickyweb"))
	var events := engine.submit(BattleAction.fight(1))
	assert_string_contains(_texts(events), "¡El Rattata enemigo se debilitó!")
	assert_false(_texts(events).contains("red viscosa"), "Pidgey vuela: no la pisa")
	var foes2: Array[Pokemon] = [_mon(&"rattata", 5, ["splash"]), _mon(&"sentret", 5, ["splash"])]
	var engine2 := _engine([_mon(&"spinarak", 40, ["stickyweb", "tackle"])], foes2, true)
	engine2.submit(BattleAction.fight(0))
	events = engine2.submit(BattleAction.fight(1))
	assert_string_contains(_texts(events), "¡El Sentret enemigo ha caído en una red viscosa!")
	assert_eq(engine2.active(1).boosts[&"spe"], -1)


func test_remolino_acaba_un_combate_salvaje() -> void:
	var engine := _engine([_mon(&"pidgey", 30, ["whirlwind"])], [_mon(&"rattata", 30, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over())
	assert_eq(engine.result.outcome, BattleResult.RUN)


func test_golpe_bajo_falla_contra_un_movimiento_de_estado() -> void:
	var engine := _engine([_mon(&"absol", 40, ["suckerpunch"])], [_mon(&"rattata", 30, ["tailwhip"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Pero falló!")
	var engine2 := _engine([_mon(&"absol", 40, ["suckerpunch"])], [_mon(&"rattata", 30, ["tackle"])])
	events = engine2.submit(BattleAction.fight(0))
	assert_gt(_damage_to(events, 1), 0)


func test_atraccion_y_alboroto() -> void:
	var engine := _engine([_mon(&"clefairy", 40, ["attract"], {"gender": "female"})], [_mon(&"rattata", 30, ["splash"], {"gender": "male"})])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.active(1).has_volatile(&"attract"))
	var same := _engine([_mon(&"clefairy", 40, ["attract"], {"gender": "male"})], [_mon(&"rattata", 30, ["splash"], {"gender": "male"})])
	assert_string_contains(_texts(same.submit(BattleAction.fight(0))), "¡Pero falló!")
	var noisy := _engine([_mon(&"loudred", 40, ["uproar"])], [_mon(&"rattata", 5, ["spore"])])
	var events := noisy.submit(BattleAction.fight(0))
	assert_true(noisy.active(0).has_volatile(&"uproar"))
	assert_ne(noisy.active(0).pokemon.status, &"slp")
	assert_string_contains(_texts(events), "alboroto")


func test_deseo_cura_al_final_del_turno_siguiente() -> void:
	var p := _mon(&"togepi", 40, ["wish", "splash"])
	var engine := _engine([p], [_mon(&"rattata", 5, ["splash"])])
	p.take_damage(p.max_hp() - 1)
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(p.current_hp, 1, "aún no")
	events = engine.submit(BattleAction.fight(1))
	assert_string_contains(_texts(events), "¡El deseo de Togepi se ha hecho realidad!")
	assert_eq(p.current_hp, 1 + p.max_hp() / 2)


func test_persecucion_golpea_al_que_se_retira() -> void:
	var a := _mon(&"snorlax", 30, ["tackle"])
	var b := _mon(&"pidgey", 30, ["tackle"])
	var engine := _engine([a, b], [_mon(&"absol", 30, ["pursuit"])])
	var events := engine.submit(BattleAction.switch_to(1))
	var moves := _find(events, BattleEvent.MOVE, 1)
	assert_eq(moves.size(), 1)
	var damage := _find(events, BattleEvent.DAMAGE, 0)
	assert_eq(damage.size(), 1)
	assert_lt(events.find(moves[0]), events.find(_find(events, BattleEvent.SWITCH_OUT, 0)[0]), "antes del cambio")
	assert_lt(a.current_hp, a.max_hp(), "le pega al que se va")
	assert_eq(b.current_hp, b.max_hp())


func test_sintesis_segun_el_clima() -> void:
	var p := _mon(&"bulbasaur", 40, ["synthesis", "raindance"])
	var engine := _engine([p], [_mon(&"rattata", 5, ["splash"])])
	engine.submit(BattleAction.fight(1))
	p.current_hp = 1
	engine.submit(BattleAction.fight(0))
	assert_eq(p.current_hp, 1 + roundi(p.max_hp() * 0.25), "con lluvia, 1/4")


func test_espejo_copia_el_ultimo_movimiento() -> void:
	var engine := _engine([_mon(&"jolteon", 40, ["mirrormove"])], [_mon(&"rattata", 30, ["tackle"])])
	engine.submit(BattleAction.fight(0))
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Jolteon usó Placaje!")


func test_mismo_combate_con_efectos_mismo_resultado() -> void:
	var run := func() -> String:
		var engine := _engine([_mon(&"bulbasaur", 30, ["leechseed", "solarbeam", "sunnyday", "synthesis"])],
			[_mon(&"charmander", 30, ["firespin", "protect", "flail"])], false, 99)
		var all: Array[BattleEvent] = []
		for i: int in 12:
			if engine.is_over():
				break
			var r := engine.request
			all.append_array(engine.submit(BattleAction.fight(r.usable_moves[i % r.usable_moves.size()]) if r.kind == BattleRequest.Kind.ACTION else BattleAction.learn_move(-1)))
		return str(all)
	assert_eq(run.call(), run.call())
