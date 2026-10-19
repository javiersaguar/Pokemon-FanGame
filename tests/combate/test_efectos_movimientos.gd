extends GutTest
## Movimientos con script de la petición 81 (los más usados en partida): estados que impiden
## movimientos, Reserva, robo de objetos, golpes según peso y velocidad, contraataques, dos turnos,
## campos, pantallas, tipos y estadísticas cambiadas. Mecánicas comprobadas con Showdown y Bulbapedia.


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


func _damage_to(events: Array[BattleEvent], side: int, source: String = "move") -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == side and e.value("source") == source:
			total += int(e.value("amount"))
	return total


func _power(engine: BattleEngine, move_id: StringName, user: Battler, target: Battler) -> int:
	return int(engine._damage_opts(user, target, DataDB.move(move_id), Effects.move(move_id), false)["power"])


func test_los_nuevos_scripts_cargan() -> void:
	for id: StringName in [&"torment", &"taunt", &"stockpile", &"spitup", &"swallow", &"knockoff", &"aquaring",
			&"charge", &"foulplay", &"payback", &"dig", &"dive", &"fling", &"lowkick", &"counter", &"gyroball", &"beatup",
			&"fakeout", &"yawn", &"encore", &"electroball", &"facade", &"blizzard", &"covet", &"endure", &"lockon",
			&"mist", &"rollout", &"throatchop", &"belch", &"copycat", &"heavyslam", &"imprison", &"quickguard"]:
		assert_not_null(Effects.move(id), String(id))


func test_mofa_impide_los_movimientos_de_estado() -> void:
	var engine := _engine([_mon(&"murkrow", 40, ["taunt", "peck"])], [_mon(&"snorlax", 30, ["tackle", "growl"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "ha caído en la Mofa")
	var foe := engine.active(1)
	assert_true(foe.has_volatile(&"taunt"))
	assert_eq(foe.usable_moves(), [0], "solo Placaje: Gruñido es de estado")
	for i: int in 3:
		engine.submit(BattleAction.fight(1))
	assert_false(foe.has_volatile(&"taunt"), "se acaba a los 3 turnos")


func test_tormento_impide_repetir() -> void:
	var engine := _engine([_mon(&"murkrow", 40, ["torment", "peck"])], [_mon(&"snorlax", 30, ["tackle", "lick"])])
	engine.submit(BattleAction.fight(0))
	var foe := engine.active(1)
	assert_true(foe.has_volatile(&"torment"))
	var last := foe.last_move
	assert_ne(last, &"")
	assert_false(engine.move_index_of(foe, last) in foe.usable_moves(), "no puede repetir %s" % last)


func test_anulacion_y_otra_vez() -> void:
	var engine := _engine([_mon(&"gengar", 50, ["disable", "encore"])], [_mon(&"snorlax", 30, ["tackle", "growl"])], false, 5)
	engine.active(1).last_move = &"tackle"
	engine.submit(BattleAction.fight(1))
	var foe := engine.active(1)
	assert_true(foe.has_volatile(&"encore"), "Otra Vez sobre el último movimiento")
	var encored := engine.move_index_of(foe, StringName(foe.volatiles[&"encore"]["move"]))
	assert_eq(foe.usable_moves(), [encored], "solo puede repetirlo")
	var engine2 := _engine([_mon(&"gengar", 50, ["disable"])], [_mon(&"snorlax", 30, ["tackle", "growl"])])
	engine2.active(1).last_move = &"tackle"
	var events := engine2.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "Se ha anulado")
	assert_false(0 in engine2.active(1).usable_moves(), "Placaje anulado")


func test_reserva_escupir_y_tragar() -> void:
	var p := _mon(&"swalot", 40, ["stockpile", "spitup", "swallow"])
	var engine := _engine([p], [_mon(&"snorlax", 40, ["splash"])])
	var me := engine.active(0)
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(0))
	assert_eq(int(me.volatiles[&"stockpile"]["layers"]), 2)
	assert_eq(me.boosts[&"def"], 2)
	assert_eq(_power(engine, &"spitup", me, engine.active(1)), 200, "Escupir: 100 por reserva")
	engine.submit(BattleAction.fight(1))
	assert_false(me.has_volatile(&"stockpile"), "se gasta")
	assert_eq(me.boosts[&"def"], 0, "y se pierde lo que subió")
	var events := engine.submit(BattleAction.fight(2))
	assert_string_contains(_texts(events), "no ha conseguido tragar")


func test_desarme_quita_el_objeto_y_se_devuelve_al_jugador() -> void:
	var engine := _engine([_mon(&"snorlax", 50, ["splash"], {"item": "leftovers"})], [_mon(&"sneasel", 50, ["knockoff"])], true)
	var mine := engine.active(0)
	assert_eq(_power(engine, &"knockoff", engine.active(1), mine), 97, "65 × 1,5")
	engine.submit(BattleAction.fight(0))
	assert_eq(mine.pokemon.held_item, &"", "se lo quita")
	engine.end_battle(BattleResult.WIN)
	assert_eq(mine.pokemon.held_item, &"leftovers", "contra un entrenador, se devuelve al acabar")


func test_antojo_roba_si_no_lleva_nada() -> void:
	var foe := _mon(&"snorlax", 30, ["splash"], {"item": "oranberry"})
	var engine := _engine([_mon(&"meowth", 40, ["covet"])], [foe])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).pokemon.held_item, &"oranberry")
	assert_eq(foe.held_item, &"")


func test_acua_aro_y_arraigo_curan_al_final_del_turno() -> void:
	var p := _mon(&"vaporeon", 40, ["aquaring", "ingrain"])
	var engine := _engine([p], [_mon(&"magikarp", 5, ["splash"])])
	p.take_damage(64)
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_texts(events).contains("Acua Aro"), true)
	assert_eq(p.current_hp, p.max_hp() - 64 + p.max_hp() / 16)
	engine.submit(BattleAction.fight(1))
	assert_true(engine.active(0).has_volatile(&"ingrain"))
	assert_false(engine.request.can_switch and engine.request.can_run, "Arraigo no deja huir")


func test_carga_dobla_el_siguiente_electrico() -> void:
	var engine := _engine([_mon(&"pikachu", 40, ["charge", "thundershock"])], [_mon(&"snorlax", 40, ["splash"])])
	var me := engine.active(0)
	engine.submit(BattleAction.fight(0))
	assert_true(me.has_volatile(&"charge"))
	assert_eq(me.boosts[&"spd"], 1)
	assert_eq(_power(engine, &"thundershock", me, engine.active(1)), 80)
	engine.submit(BattleAction.fight(1))
	assert_false(me.has_volatile(&"charge"), "se gasta con el golpe")


func test_juego_sucio_usa_el_ataque_del_objetivo() -> void:
	var engine := _engine([_mon(&"sableye", 40, ["foulplay"])], [_mon(&"machamp", 40, ["splash"])])
	var me := engine.active(0)
	var foe := engine.active(1)
	var opts := engine._damage_opts(me, foe, DataDB.move(&"foulplay"), Effects.move(&"foulplay"), false)
	assert_eq(opts["attacker"], foe)
	var strong := DamageCalc.calculate(me, foe, DataDB.move(&"foulplay"), false, 0, opts)
	foe.boosts[&"atk"] = 2
	var stronger := DamageCalc.calculate(me, foe, DataDB.move(&"foulplay"), false, 0, opts)
	assert_gt(stronger, strong, "los cambios de Ataque del objetivo cuentan")


func test_potencia_segun_peso_y_velocidad() -> void:
	var engine := _engine([_mon(&"machop", 40, ["lowkick", "heavyslam", "gyroball", "electroball"])], [_mon(&"snorlax", 40, ["splash"])])
	var me := engine.active(0)
	var snorlax := engine.active(1)
	assert_eq(_power(engine, &"lowkick", me, snorlax), 120, "Snorlax pesa 460 kg")
	assert_eq(_power(engine, &"heavyslam", me, snorlax), 40, "Machop pesa mucho menos")
	assert_eq(_power(engine, &"heavyslam", snorlax, me), 120, "al revés, 120")
	var gyro := _power(engine, &"gyroball", snorlax, me)
	assert_eq(gyro, mini(150, int(25.0 * engine.speed_of(me) / engine.speed_of(snorlax)) + 1))
	assert_eq(_power(engine, &"electroball", snorlax, me), 40, "Snorlax es más lento")


func test_contraataque_devuelve_el_doble() -> void:
	var p := _mon(&"wobbuffet", 50, ["counter", "mirrorcoat"])
	var engine := _engine([p], [_mon(&"machop", 30, ["karatechop"])])
	var events := engine.submit(BattleAction.fight(0))
	var taken := _damage_to(events, 0)
	assert_gt(taken, 0)
	assert_eq(_damage_to(events, 1), taken * 2, "el doble del daño físico")
	var engine2 := _engine([_mon(&"wobbuffet", 50, ["counter"])], [_mon(&"snorlax", 30, ["splash"])])
	assert_string_contains(_texts(engine2.submit(BattleAction.fight(0))), "¡Pero falló!", "sin daño recibido, falla")


func test_sorpresa_solo_el_primer_turno() -> void:
	var engine := _engine([_mon(&"persian", 40, ["fakeout"])], [_mon(&"snorlax", 40, ["tackle"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_gt(_damage_to(events, 1), 0)
	assert_string_contains(_texts(events), "retrocedió")
	events = engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "¡Pero falló!")


func test_bostezo_duerme_al_turno_siguiente() -> void:
	var engine := _engine([_mon(&"slowpoke", 40, ["yawn", "tackle"])], [_mon(&"snorlax", 40, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "se está adormilando")
	assert_eq(engine.active(1).pokemon.status, &"")
	engine.submit(BattleAction.fight(1))
	assert_eq(engine.active(1).pokemon.status, &"slp")


func test_excavar_esquiva_y_terremoto_le_alcanza() -> void:
	var engine := _engine([_mon(&"sandslash", 40, ["dig"])], [_mon(&"snorlax", 40, ["tackle"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "bajo tierra")
	assert_string_contains(_texts(events), "ha fallado", "bajo tierra no le alcanza Placaje")
	var effect := Effects.condition(&"twoturnmove")
	var state := {"invulnerable": "underground"}
	assert_false(effect.on_try_hit(engine, engine.active(0), state, engine.active(1), DataDB.move(&"tackle")))
	assert_true(effect.on_try_hit(engine, engine.active(0), state, engine.active(1), DataDB.move(&"earthquake")))
	var under := _engine([_mon(&"golem", 40, ["earthquake"])], [_mon(&"sandslash", 40, ["dig"])])
	under.active(1).volatiles[&"twoturnmove"] = state
	assert_eq(Effects.condition(&"twoturnmove").damage_modifier(under, under.active(0), under.active(1), DataDB.move(&"earthquake"), false), 2.0)


func test_aguante_resiste_con_un_ps() -> void:
	var p := _mon(&"rattata", 10, ["endure"])
	var engine := _engine([p], [_mon(&"machamp", 70, ["crosschop"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(p.current_hp, 1)


func test_fijar_blanco_no_falla() -> void:
	var engine := _engine([_mon(&"magneton", 40, ["lockon", "zapcannon"])], [_mon(&"snorlax", 40, ["splash"])])
	engine.submit(BattleAction.fight(0))
	var me := engine.active(0)
	assert_true(me.has_volatile(&"lockon"))
	me.boosts[&"accuracy"] = -6
	assert_true(engine._accuracy_hits(me, engine.active(1), DataDB.move(&"zapcannon")), "acierta seguro")


func test_neblina_impide_que_el_rival_baje_caracteristicas() -> void:
	var engine := _engine([_mon(&"lapras", 40, ["mist", "closecombat"])], [_mon(&"pidgey", 40, ["growl"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_true(engine.has_side_condition(0, &"mist"))
	assert_eq(engine.active(0).boosts[&"atk"], 0, "Gruñido no le baja el Ataque")
	assert_string_contains(_texts(events), "neblina")


func test_rodar_dobla_cada_turno() -> void:
	var engine := _engine([_mon(&"geodude", 40, ["rollout"])], [_mon(&"blissey", 60, ["splash"])], false, 2)
	var me := engine.active(0)
	var foe := engine.active(1)
	assert_eq(_power(engine, &"rollout", me, foe), 30)
	me.volatiles[&"rollout"] = {"id": "rollout", "move": "rollout", "hits": 2, "turns": 0}
	assert_eq(_power(engine, &"rollout", me, foe), 120)
	me.volatiles[&"defensecurl"] = {"id": "defensecurl", "turns": 0}
	assert_eq(_power(engine, &"rollout", me, foe), 240, "con Rizo Defensa, el doble")


func test_golpe_mordaza_impide_sonido() -> void:
	var engine := _engine([_mon(&"sneasel", 45, ["throatchop"])], [_mon(&"exploud", 50, ["uproar", "tackle"])])
	engine.submit(BattleAction.fight(0))
	var foe := engine.active(1)
	assert_true(foe.has_volatile(&"throatchop"))
	assert_false(0 in foe.usable_moves(), "Alboroto es de sonido")


func test_eructo_necesita_una_baya() -> void:
	var engine := _engine([_mon(&"swalot", 40, ["belch"])], [_mon(&"snorlax", 40, ["splash"])])
	assert_string_contains(_texts(engine.submit(BattleAction.fight(0))), "¡Pero falló!")
	engine.active(0).ate_berry = true
	assert_gt(_damage_to(engine.submit(BattleAction.fight(0)), 1), 0)


func test_cerca_sella_los_movimientos_compartidos() -> void:
	var engine := _engine([_mon(&"bronzong", 40, ["imprison", "tackle"])], [_mon(&"snorlax", 40, ["tackle", "lick"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).usable_moves(), [1], "Placaje sellado")


func test_anticipo_bloquea_la_prioridad() -> void:
	var engine := _engine([_mon(&"hitmontop", 40, ["quickguard"])], [_mon(&"rattata", 40, ["quickattack"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_damage_to(events, 0), 0, "Ataque Rápido bloqueado")


func test_tambor_maximiza_el_ataque() -> void:
	var p := _mon(&"snorlax", 50, ["bellydrum"])
	var engine := _engine([p], [_mon(&"magikarp", 5, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).boosts[&"atk"], 6)
	assert_eq(p.current_hp, p.max_hp() - p.max_hp() / 2)


func test_demolicion_rompe_las_pantallas() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["brickbreak"])], [_mon(&"mrmime", 50, ["reflect"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "Reflejo", "Mr. Mime, más rápido, pone Reflejo")
	assert_string_contains(_texts(events), "Se ha roto la barrera")
	assert_false(engine.has_side_condition(1, &"reflect"), "Demolición lo rompe al golpear")


func test_niebla_clara_mas_psique_y_reversion() -> void:
	var engine := _engine([_mon(&"weezing", 50, ["clearsmog", "psychup", "topsyturvy"])], [_mon(&"snorlax", 50, ["splash"])])
	var foe := engine.active(1)
	foe.boosts[&"atk"] = 3
	engine.submit(BattleAction.fight(1))
	assert_eq(engine.active(0).boosts[&"atk"], 3, "Más Psique copia")
	engine.submit(BattleAction.fight(2))
	assert_eq(foe.boosts[&"atk"], -3, "Reversión invierte")
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"atk"], 0, "Niebla Clara anula")


func test_rencor_quita_pp() -> void:
	var engine := _engine([_mon(&"gengar", 50, ["spite"])], [_mon(&"snorlax", 50, ["tackle"])], false, 4)
	var foe := engine.active(1)
	foe.last_move = &"tackle"
	var before := foe.pokemon.moves[0].pp
	engine.submit(BattleAction.fight(0))
	assert_lt(foe.pokemon.moves[0].pp, before - 1)


func test_corte_furia_dobla_si_se_repite() -> void:
	var engine := _engine([_mon(&"scyther", 50, ["furycutter"])], [_mon(&"blissey", 70, ["splash"])], false, 1)
	var me := engine.active(0)
	assert_eq(_power(engine, &"furycutter", me, engine.active(1)), 40)
	engine.submit(BattleAction.fight(0))
	engine.turn += 1
	assert_eq(_power(engine, &"furycutter", me, engine.active(1)), 80, "seguido, el doble")


func test_campo_de_hierba_cura_y_potencia() -> void:
	var p := _mon(&"bulbasaur", 40, ["grassyterrain", "vinewhip"])
	var engine := _engine([p], [_mon(&"snorlax", 40, ["splash"])])
	p.take_damage(40)
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.terrain(), &"grassyterrain")
	assert_eq(p.current_hp, p.max_hp() - 40 + p.max_hp() / 16)
	assert_eq(_power(engine, &"vinewhip", engine.active(0), engine.active(1)), DamageCalc.modify(45, 1.3))


func test_leviton_y_antiaereo() -> void:
	var engine := _engine([_mon(&"magnezone", 50, ["magnetrise"])], [_mon(&"golem", 50, ["earthquake"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_true(engine.active(0).has_volatile(&"magnetrise"))
	assert_false(engine.is_grounded(engine.active(0)))
	events = engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "No afecta")
	var down := _engine([_mon(&"onix", 50, ["smackdown"])], [_mon(&"pidgeot", 40, ["splash"])])
	down.submit(BattleAction.fight(0))
	assert_true(down.is_grounded(down.active(1)), "Antiaéreo derriba al volador")


func test_mal_de_ojo_impide_huir() -> void:
	var engine := _engine([_mon(&"snorlax", 50, ["splash"]), _mon(&"pidgey", 5, ["tackle"])], [_mon(&"umbreon", 50, ["meanlook"])])
	engine.submit(BattleAction.fight(0))
	assert_false(engine.request.can_switch)
	assert_false(engine.request.can_run)


func test_anegar_cambia_el_tipo() -> void:
	var engine := _engine([_mon(&"vaporeon", 50, ["soak"])], [_mon(&"charmander", 20, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).types(), [&"water"] as Array[StringName])


func test_puno_furia_y_poder_reserva() -> void:
	var engine := _engine([_mon(&"primeape", 50, ["ragefist", "storedpower"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	assert_eq(_power(engine, &"ragefist", me, engine.active(1)), 50)
	engine.times_hit[me.pokemon.uid] = 3
	assert_eq(_power(engine, &"ragefist", me, engine.active(1)), 200)
	me.boosts[&"atk"] = 2
	me.boosts[&"spe"] = 1
	assert_eq(_power(engine, &"storedpower", me, engine.active(1)), 80)


func test_liofilizacion_es_supereficaz_contra_agua() -> void:
	var engine := _engine([_mon(&"glaceon", 50, ["freezedry"])], [_mon(&"vaporeon", 50, ["splash"])])
	var opts := engine._damage_opts(engine.active(0), engine.active(1), DataDB.move(&"freezedry"), Effects.move(&"freezedry"), false)
	assert_eq(float(opts["effectiveness"]), 2.0)


func test_reciclaje_recupera_la_baya() -> void:
	var p := _mon(&"snorlax", 50, ["recycle"], {"item": "sitrusberry"})
	var engine := _engine([p], [_mon(&"magikarp", 5, ["splash"])])
	engine.consume_held_item(engine.active(0))
	assert_true(engine.active(0).ate_berry)
	engine.submit(BattleAction.fight(0))
	assert_eq(p.held_item, &"sitrusberry")


func test_truco_intercambia_los_objetos() -> void:
	var engine := _engine([_mon(&"alakazam", 50, ["trick"], {"item": "choicescarf"})], [_mon(&"snorlax", 50, ["splash"], {"item": "leftovers"})])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).pokemon.held_item, &"leftovers")
	assert_eq(engine.active(1).pokemon.held_item, &"choicescarf")


func test_teletransporte_huye_de_un_salvaje() -> void:
	var engine := _engine([_mon(&"abra", 20, ["teleport"])], [_mon(&"snorlax", 30, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.is_over())
	assert_eq(engine.result.outcome, BattleResult.RUN)


func test_isoguardia_reparte_las_defensas() -> void:
	var engine := _engine([_mon(&"shuckle", 50, ["guardsplit", "powertrick"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	var foe := engine.active(1)
	var total := me.pokemon.stat(&"def") + foe.pokemon.stat(&"def")
	engine.submit(BattleAction.fight(0))
	assert_eq(me.boosted_stat(&"def"), total / 2)
	assert_eq(foe.boosted_stat(&"def"), total / 2)


func test_maldicion_de_fantasma_y_de_otro_tipo() -> void:
	var ghost := _mon(&"gengar", 50, ["curse"])
	var engine := _engine([ghost], [_mon(&"snorlax", 50, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_true(engine.active(1).has_volatile(&"curse"))
	assert_eq(_damage_to(events, 1, "curse"), engine.active(1).pokemon.max_hp() / 4)
	var normal := _engine([_mon(&"snorlax", 50, ["curse"])], [_mon(&"magikarp", 5, ["splash"])])
	normal.submit(BattleAction.fight(0))
	assert_eq(normal.active(0).boosts[&"atk"], 1)
	assert_eq(normal.active(0).boosts[&"spe"], -1)


func test_premonicion_golpea_dos_turnos_despues() -> void:
	var engine := _engine([_mon(&"alakazam", 50, ["futuresight", "calmmind"])], [_mon(&"snorlax", 50, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "ha previsto un ataque")
	assert_eq(_damage_to(events, 1, "futuresight"), 0)
	events = engine.submit(BattleAction.fight(1))
	assert_eq(_damage_to(events, 1, "futuresight"), 0)
	events = engine.submit(BattleAction.fight(1))
	assert_gt(_damage_to(events, 1, "futuresight"), 0, "llega al final del segundo turno")


func test_paliza_un_golpe_por_compañero_sano() -> void:
	var a := _mon(&"sneasel", 40, ["beatup"])
	var b := _mon(&"pidgey", 10, ["tackle"])
	var c := _mon(&"rattata", 10, ["tackle"])
	c.set_status(&"psn")
	var engine := _engine([a, b, c], [_mon(&"snorlax", 50, ["splash"])])
	assert_eq(Effects.move(&"beatup").hit_count(engine, engine.active(0), engine.active(1), DataDB.move(&"beatup")), 2, "el envenenado no cuenta")


func test_lanzamiento_lanza_el_objeto() -> void:
	var p := _mon(&"ambipom", 40, ["fling"], {"item": "flameorb"})
	var engine := _engine([p], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(p.held_item, &"", "se pierde")
	assert_eq(engine.active(1).pokemon.status, &"brn", "la Llamasfera quema")
	var empty := _engine([_mon(&"ambipom", 40, ["fling"])], [_mon(&"snorlax", 50, ["splash"])])
	assert_string_contains(_texts(empty.submit(BattleAction.fight(0))), "¡Pero falló!", "sin objeto falla")
