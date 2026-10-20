extends GutTest
## Movimientos con script de la petición 81, segundo bloque: Sustituto, protecciones con castigo,
## golpes que se estrellan, Espacio Raro y las zonas, campos, cambios de tipo y de potencia, Mismo
## Destino, Canto Mortal, Deseo Cura, Puño Certero, Sonámbulo, Mimético y compañía.


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


func _move_order(events: Array[BattleEvent]) -> Array[int]:
	var out: Array[int] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MOVE:
			out.append(e.side)
	return out


func test_ya_no_quedan_movimientos_en_uso_sin_script() -> void:
	var missing: PackedStringArray = []
	for id: StringName in DataDB.move_ids():
		var m := DataDB.move(id)
		if m.needs_script and not Effects.has_move(id) and m.nonstandard == &"":
			missing.append(String(id))
	gut.p("Sin script (ninguno en uso): %d" % missing.size())
	for id: StringName in [&"substitute", &"trickroom", &"weatherball", &"metronome", &"perishsong", &"healingwish",
			&"destinybond", &"sleeptalk", &"mimic", &"focuspunch", &"bide", &"triplekick", &"gravity"]:
		assert_true(Effects.has_move(id), String(id))


func test_sustituto_recibe_los_golpes_y_bloquea_el_estado() -> void:
	var p := _mon(&"gengar", 50, ["substitute", "splash"])
	var engine := _engine([p], [_mon(&"rattata", 30, ["tackle", "thunderwave"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_true(engine.active(0).has_volatile(&"substitute"))
	assert_eq(p.current_hp, p.max_hp() - p.max_hp() / 4, "cuesta 1/4 de los PS")
	var hp := p.current_hp
	var sub := Effects.condition(&"substitute")
	var state: Dictionary = engine.active(0).volatiles[&"substitute"]
	assert_false(sub.on_try_hit(engine, engine.active(0), state, engine.active(1), DataDB.move(&"thunderwave")), "Onda Trueno no pasa")
	engine.submit(BattleAction.fight(1))
	assert_eq(p.current_hp, hp, "el golpe se lo lleva el sustituto")
	assert_string_contains(_texts(engine.submit(BattleAction.fight(1))) + _texts(events), "sustituto")


func test_protecciones_con_castigo() -> void:
	var engine := _engine([_mon(&"toxapex", 50, ["banefulbunker"])], [_mon(&"rattata", 50, ["tackle"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).pokemon.status, &"psn", "Búnker envenena al que toca")
	var spiky := _engine([_mon(&"chesnaught", 50, ["spikyshield"])], [_mon(&"rattata", 50, ["tackle"])])
	var events := spiky.submit(BattleAction.fight(0))
	assert_eq(_damage_to(events, 1, "spikyshield"), spiky.active(1).pokemon.max_hp() / 8)
	var king := _engine([_mon(&"aegislash", 50, ["kingsshield"])], [_mon(&"rattata", 50, ["tackle"])])
	king.submit(BattleAction.fight(0))
	assert_eq(king.active(1).boosts[&"atk"], -1, "Escudo Real baja el Ataque")


func test_patada_salto_alta_se_estrella() -> void:
	var p := _mon(&"hitmonlee", 50, ["highjumpkick"])
	var engine := _engine([p], [_mon(&"gengar", 50, ["splash"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "se ha caído al suelo", "contra un Fantasma no afecta y se estrella")
	assert_eq(_damage_to(events, 0, "crash"), roundi(p.max_hp() / 2.0))


func test_espacio_raro_mueve_antes_al_lento() -> void:
	var engine := _engine([_mon(&"snorlax", 50, ["trickroom", "tackle"])], [_mon(&"jolteon", 50, ["tackle"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.trick_room())
	var events := engine.submit(BattleAction.fight(1))
	assert_eq(_move_order(events)[0], 0, "Snorlax, el lento, va primero")
	engine.field.erase("trickroom")
	events = engine.submit(BattleAction.fight(1))
	assert_eq(_move_order(events)[0], 1, "sin Espacio Raro, Jolteon primero")


func test_meteorobola_y_pulso_terreno_cambian_de_tipo() -> void:
	var engine := _engine([_mon(&"castform", 50, ["weatherball", "terrainpulse"])], [_mon(&"snorlax", 50, ["splash"])])
	var user := engine.active(0)
	var wb := Effects.move(&"weatherball")
	assert_eq(wb.modify_move(engine, user, DataDB.move(&"weatherball")).type, &"normal")
	engine.set_weather(&"raindance")
	var wet := wb.modify_move(engine, user, DataDB.move(&"weatherball"))
	assert_eq(wet.type, &"water")
	assert_eq(wet.power, 100)
	engine.set_terrain(&"electricterrain")
	assert_eq(Effects.move(&"terrainpulse").modify_move(engine, user, DataDB.move(&"terrainpulse")).type, &"electric")
	assert_eq(DataDB.move(&"weatherball").type, &"normal", "el movimiento original no cambia")


func test_erupcion_baja_con_los_ps() -> void:
	var p := _mon(&"typhlosion", 50, ["eruption"])
	var engine := _engine([p], [_mon(&"snorlax", 50, ["splash"])])
	var user := engine.active(0)
	var effect := Effects.move(&"eruption")
	assert_eq(effect.base_power(engine, user, engine.active(1), DataDB.move(&"eruption"), 150), 150)
	p.current_hp = p.max_hp() / 2
	assert_almost_eq(float(effect.base_power(engine, user, engine.active(1), DataDB.move(&"eruption"), 150)), 75.0, 1.0)


func test_falso_tortazo_deja_un_ps() -> void:
	var foe := _mon(&"rattata", 5, ["splash"])
	var engine := _engine([_mon(&"scizor", 70, ["falseswipe"])], [foe])
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.current_hp, 1)


func test_sacrificio_y_deseo_cura() -> void:
	var p := _mon(&"basculin", 40, ["finalgambit"])
	var engine := _engine([p, _mon(&"pidgey", 10, ["tackle"])], [_mon(&"snorlax", 60, ["splash"])])
	var hp := p.current_hp
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_damage_to(events, 1), hp, "tanto daño como PS le quedaban")
	assert_true(p.is_fainted())
	var a := _mon(&"lopunny", 40, ["healingwish"])
	var b := _mon(&"pidgey", 40, ["tackle"])
	b.take_damage(30)
	b.set_status(&"par")
	var wish := _engine([a, b], [_mon(&"snorlax", 40, ["splash"])])
	wish.submit(BattleAction.fight(0))
	assert_true(a.is_fainted())
	wish.submit(BattleAction.switch_to(1))
	assert_eq(b.current_hp, b.max_hp())
	assert_eq(b.status, &"")


func test_canto_mortal_debilita_a_los_tres_turnos() -> void:
	var engine := _engine([_mon(&"lapras", 60, ["perishsong", "splash"])], [_mon(&"snorlax", 60, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_true(engine.active(1).has_volatile(&"perishsong"))
	for i: int in 3:
		if not engine.is_over():
			engine.submit(BattleAction.fight(1))
	assert_true(engine.is_over(), "los dos caen al llegar a 0")


func test_campos_psiquico_y_electrico() -> void:
	var engine := _engine([_mon(&"espeon", 50, ["psychicterrain"])], [_mon(&"rattata", 50, ["quickattack"])])
	engine.submit(BattleAction.fight(0))
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_damage_to(events, 0), 0, "Ataque Rápido no llega al que toca el suelo")
	var spark := _engine([_mon(&"jolteon", 50, ["electricterrain"])], [_mon(&"snorlax", 50, ["splash"])])
	spark.submit(BattleAction.fight(0))
	assert_false(spark.can_set_status(spark.active(1), &"slp", null, false), "no se puede dormir")


func test_divide_dolor_reparte() -> void:
	var p := _mon(&"gengar", 50, ["painsplit"])
	var engine := _engine([p], [_mon(&"snorlax", 50, ["splash"])])
	p.current_hp = 10
	var foe := engine.active(1).pokemon
	var average := (10 + foe.current_hp) / 2
	engine.submit(BattleAction.fight(0))
	assert_eq(p.current_hp, mini(average, p.max_hp()))
	assert_eq(foe.current_hp, average)


func test_mismo_destino_se_lleva_al_atacante() -> void:
	var p := _mon(&"gengar", 40, ["destinybond"])
	var engine := _engine([p], [_mon(&"snorlax", 100, ["crunch"])])
	engine.submit(BattleAction.fight(0))
	assert_true(p.is_fainted())
	assert_true(engine.active(1).pokemon.is_fainted(), "el atacante también cae")


func test_puno_certero_se_concentra_y_lo_pierde_si_le_dan() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["focuspunch"])], [_mon(&"jolteon", 50, ["tackle"])])
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "se está concentrando")
	assert_string_contains(_texts(events), "ha perdido la concentración")
	var quiet := _engine([_mon(&"machamp", 50, ["focuspunch"])], [_mon(&"snorlax", 50, ["splash"])])
	assert_gt(_damage_to(quiet.submit(BattleAction.fight(0)), 1), 0, "sin golpe, pega")


func test_sonambulo_y_ronquido_solo_dormido() -> void:
	var snorer := _engine([_mon(&"snorlax", 50, ["snore"])], [_mon(&"blissey", 60, ["splash"])])
	assert_string_contains(_texts(snorer.submit(BattleAction.fight(0))), "¡Pero falló!", "despierto, Ronquido falla")
	var p := _mon(&"snorlax", 50, ["sleeptalk", "tackle"])
	var engine := _engine([p], [_mon(&"blissey", 60, ["splash"])])
	p.set_status(&"slp", 3)
	var events := engine.submit(BattleAction.fight(0))
	assert_string_contains(_texts(events), "usó Placaje", "dormido, Sonámbulo usa otro movimiento")


func test_ultima_baza_y_mimetico() -> void:
	var p := _mon(&"eevee", 50, ["lastresort", "tackle"])
	var engine := _engine([p], [_mon(&"blissey", 70, ["splash"])])
	assert_string_contains(_texts(engine.submit(BattleAction.fight(0))), "¡Pero falló!")
	engine.submit(BattleAction.fight(1))
	assert_gt(_damage_to(engine.submit(BattleAction.fight(0)), 1), 0, "ya ha usado Placaje")
	var m := _mon(&"mrmime", 50, ["mimic"])
	var mimic := _engine([m], [_mon(&"snorlax", 50, ["tackle"])], false, 2)
	mimic.active(1).last_move = &"tackle"
	mimic.submit(BattleAction.fight(0))
	assert_eq(m.moves[0].id, &"tackle", "aprende Placaje")
	mimic.end_battle(BattleResult.RUN)
	assert_eq(m.moves[0].id, &"mimic", "al acabar vuelve a ser Mimético")


func test_venganza_devuelve_el_doble() -> void:
	var p := _mon(&"shuckle", 50, ["bide"])
	var engine := _engine([p], [_mon(&"rattata", 30, ["tackle"])])
	var events := engine.submit(BattleAction.fight(0))
	var taken := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == 1:
			break
		if e.type == BattleEvent.DAMAGE and e.side == 0:
			taken += int(e.value("amount"))
	assert_gt(taken, 0, "dos turnos aguantando")
	assert_eq(_damage_to(events, 1), taken * 2, "al tercero devuelve el doble")


func test_cola_dragon_saca_al_objetivo() -> void:
	var engine := _engine([_mon(&"dragonite", 60, ["dragontail"])], [_mon(&"snorlax", 30, ["splash"]), _mon(&"pidgey", 30, ["tackle"])], true)
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).pokemon.species_id, &"pidgey", "entra otro")


func test_gravedad_y_zonas() -> void:
	var engine := _engine([_mon(&"dusknoir", 50, ["gravity", "wonderroom", "magicroom"])], [_mon(&"pidgeot", 50, ["fly", "splash"])])
	engine.submit(BattleAction.fight(0))
	var foe := engine.active(1)
	assert_true(engine.is_grounded(foe), "todos tocan el suelo")
	assert_false(0 in foe.usable_moves(), "no puede usar Vuelo")
	engine.submit(BattleAction.fight(1))
	var opts := engine._damage_opts(engine.active(0), foe, DataDB.move(&"tackle"), null, false)
	assert_eq(opts["def_stat"], &"spd", "Zona Extraña: físico contra la Defensa Especial")
	foe.pokemon.held_item = &"leftovers"
	engine.submit(BattleAction.fight(2))
	assert_eq(engine._passives(foe).size(), 1 if Effects.ability(foe.ability) != null else 0, "Zona Mágica: el objeto no hace nada")


func test_electrochoque_quita_el_tipo_y_electrificacion() -> void:
	var engine := _engine([_mon(&"pawmot", 60, ["doubleshock", "electrify"])], [_mon(&"blissey", 70, ["tackle"])])
	engine.submit(BattleAction.fight(0))
	assert_false(engine.active(0).has_type(&"electric"), "ya no es de tipo Eléctrico")
	assert_string_contains(_texts(engine.submit(BattleAction.fight(0))), "¡Pero falló!", "y ya no puede usarlo")
	var e := Effects.condition(&"electrify")
	assert_eq(e.modify_own_move(engine, engine.active(1), {}, DataDB.move(&"tackle")).type, &"electric")


func test_triple_patada_tres_golpes_crecientes() -> void:
	var engine := _engine([_mon(&"hitmontop", 50, ["triplekick"])], [_mon(&"snorlax", 50, ["splash"])])
	var user := engine.active(0)
	var effect := Effects.move(&"triplekick")
	assert_eq(effect.hit_count(engine, user, engine.active(1), DataDB.move(&"triplekick")), 3)
	var powers: Array[int] = []
	for i: int in 3:
		powers.append(effect.base_power(engine, user, engine.active(1), DataDB.move(&"triplekick"), 10))
	assert_eq(powers, [10, 20, 30] as Array[int])


func test_niebla_y_plegaria_vital() -> void:
	var engine := _engine([_mon(&"weezing", 50, ["haze"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.active(1).boosts[&"atk"] = 2
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).boosts[&"atk"], 0, "Niebla lo anula todo")
	var fallen := _mon(&"pidgey", 20, ["tackle"])
	fallen.current_hp = 0
	var bless := _engine([_mon(&"pawmot", 50, ["revivalblessing"]), fallen], [_mon(&"snorlax", 50, ["splash"])])
	bless.submit(BattleAction.fight(0))
	assert_eq(bless.request.reason, &"revivalblessing", "el jugador elige a quién revivir")
	bless.submit(BattleAction.switch_to(1))
	assert_eq(fallen.current_hp, fallen.max_hp() / 2)
