extends GutTest
## Simplificaciones de la sesión del 20 de octubre, corregidas una a una: Votos combinados, Vasto Impacto
## en dobles, aspecto de Transformación, Nube Nueve contra la arena, Velo Flor en el aliado, Humedad en
## todo el campo, absorciones en los movimientos a varios, Ilusión en los mensajes, Rumia, Servicio
## Habitación al empezar el Espacio Raro y Anticura contra el drenaje.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _start(player: Array[Pokemon], foes: Array[Pokemon], double: bool = false, foe_actions: Array = []) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	if double:
		s.format = BattleSetup.Format.DOUBLE
	s.foe_controller = func(_e: BattleEngine, _side: int, slot: int) -> BattleAction:
		return (foe_actions[slot] as BattleAction) if slot < foe_actions.size() else BattleAction.fight(0)
	s.rng_oracle = func(tag: StringName, _turn: int) -> float: return 0.99 if tag in [&"crit", &"secondary"] else 0.0
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func _turn2(engine: BattleEngine, a: BattleAction, b: BattleAction) -> Array[BattleEvent]:
	var events: Array[BattleEvent] = engine.submit(a)
	events.append_array(engine.submit(b))
	return events


func _sum(events: Array[BattleEvent], type: StringName, side: int, slot: int = -1, source: String = "") -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == type and e.side == side and (slot < 0 or e.slot == slot) and (source == "" or e.value("source") == source):
			total += int(e.value("amount"))
	return total


func _text(events: Array[BattleEvent]) -> String:
	var out: PackedStringArray = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE:
			out.append(e.text())
	return "\n".join(out)


func test_votos_combinados_en_dobles() -> void:
	var engine := _start([_mon(&"charizard", 50, ["firepledge"]), _mon(&"venusaur", 50, ["grasspledge"])],
		[_mon(&"snorlax", 60, ["splash"]), _mon(&"snorlax", 60, ["splash"])], true)
	var events := _turn2(engine, BattleAction.fight(0, 0), BattleAction.fight(0, 0))
	assert_true(_text(events).contains("espera a su compañero"))
	assert_true(engine.has_side_condition(1, &"firepledgecombo"), "Fuego + Planta: mar de llamas en el bando rival")


func test_vasto_impacto_alcanza_a_los_dos_con_campo_psiquico() -> void:
	var engine := _start([_mon(&"alakazam", 50, ["expandingforce"]), _mon(&"snorlax", 50, ["splash"])],
		[_mon(&"snorlax", 60, ["splash"]), _mon(&"snorlax", 60, ["splash"])], true)
	engine.set_terrain(&"psychicterrain")
	var events := _turn2(engine, BattleAction.fight(0, 0), BattleAction.fight(0))
	assert_gt(_sum(events, BattleEvent.DAMAGE, 1, 0, "move"), 0)
	assert_gt(_sum(events, BattleEvent.DAMAGE, 1, 1, "move"), 0, "también el otro rival")


func test_transformacion_cambia_el_aspecto() -> void:
	var engine := _start([_mon(&"ditto", 50, ["transform"])], [_mon(&"snorlax", 50, ["splash"])])
	var shown := ""
	for e: BattleEvent in engine.submit(BattleAction.fight(0)):
		if e.type == BattleEvent.FORME and e.side == 0:
			shown = str(e.value("species"))
	assert_eq(shown, "snorlax")


func test_nube_nueve_quita_el_dano_de_la_arena() -> void:
	var engine := _start([_mon(&"golduck", 50, ["splash"])], [_mon(&"snorlax", 50, ["splash"])])
	engine.active(0).ability = &"cloudnine"
	engine.active(1).ability = &"immunity"
	engine.set_weather(&"sandstorm")
	assert_eq(_sum(engine.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, -1, "sandstorm"), 0)


func test_velo_flor_protege_al_aliado_de_tipo_planta() -> void:
	var engine := _start([_mon(&"bulbasaur", 50, ["splash"]), _mon(&"florges", 50, ["splash"])],
		[_mon(&"jolteon", 50, ["thunderwave"]), _mon(&"snorlax", 50, ["splash"])], true,
		[BattleAction.fight(0, 0), BattleAction.fight(0)])
	engine.active(0, 0).ability = &"overgrow"
	engine.active(0, 1).ability = &"flowerveil"
	_turn2(engine, BattleAction.fight(0), BattleAction.fight(0))
	assert_eq(engine.active(0, 0).pokemon.status, &"", "Onda Trueno no le afecta")


func test_humedad_en_todo_el_campo() -> void:
	var engine := _start([_mon(&"electrode", 50, ["explosion"]), _mon(&"quagsire", 50, ["splash"])],
		[_mon(&"snorlax", 60, ["splash"]), _mon(&"snorlax", 60, ["splash"])], true)
	engine.active(0, 1).ability = &"damp"
	var events := _turn2(engine, BattleAction.fight(0, 0), BattleAction.fight(0))
	assert_false(engine.active(0, 0).is_fainted(), "Explosión no sale: Humedad la tiene su aliado")
	assert_true(_text(events).contains("Humedad"))


func test_absorcion_en_todos_los_objetivos() -> void:
	var engine := _start([_mon(&"blastoise", 50, ["surf"]), _mon(&"snorlax", 50, ["splash"])],
		[_mon(&"snorlax", 60, ["splash"]), _mon(&"vaporeon", 60, ["splash"])], true)
	var vaporeon := engine.active(1, 1)
	vaporeon.ability = &"waterabsorb"
	vaporeon.pokemon.current_hp = vaporeon.pokemon.max_hp() / 2
	var events := _turn2(engine, BattleAction.fight(0, 0), BattleAction.fight(0))
	assert_eq(_sum(events, BattleEvent.DAMAGE, 1, 1, "move"), 0, "Absorbe Agua en el segundo objetivo")
	assert_gt(_sum(events, BattleEvent.HEAL, 1, 1), 0)


func test_ilusion_tambien_en_los_mensajes() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [_mon(&"zoroark", 50, ["splash"]), _mon(&"pikachu", 50, ["splash"])]
	s.foe_party = [_mon(&"snorlax", 50, ["splash"])]
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.player_party[0].ability_slot = "0"
	var engine := BattleEngine.new(s)
	var text := _text(engine.start())
	assert_true(text.contains("Adelante, Pikachu"), text)
	assert_false(text.contains("Zoroark"), "no se descubre al salir")


func test_rumia_vuelve_a_aplicar_cualquier_baya() -> void:
	var engine := _start([_mon(&"tauros", 50, ["splash"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	engine.eat_berry(me, &"liechiberry")
	assert_eq(me.boosts[&"atk"], 1, "la baya Lichi otra vez")


func test_servicio_habitacion_al_empezar_el_espacio_raro() -> void:
	var p := _mon(&"slowbro", 50, ["trickroom"])
	p.held_item = &"roomservice"
	var engine := _start([p], [_mon(&"snorlax", 50, ["splash"])])
	engine.active(1).ability = &"immunity"
	engine.submit(BattleAction.fight(0))
	assert_true(engine.trick_room())
	assert_eq(engine.active(0).boosts[&"spe"], -1)
	assert_eq(p.held_item, &"", "se gasta")


func test_anticura_corta_el_drenaje() -> void:
	var engine := _start([_mon(&"venusaur", 50, ["gigadrain"])], [_mon(&"snorlax", 60, ["splash"])])
	var me := engine.active(0)
	me.pokemon.current_hp = me.pokemon.max_hp() / 2
	me.volatiles[&"healblock"] = {"turns": 3}
	assert_eq(_sum(engine.submit(BattleAction.fight(0)), BattleEvent.HEAL, 0), 0)
