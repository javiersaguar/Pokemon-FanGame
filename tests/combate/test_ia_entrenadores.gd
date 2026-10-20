extends GutTest
## IA de los entrenadores (Fase 9.7): los de nivel alto (líderes, Alto Mando y Pedro Sánchez) usan bien
## movimientos, objetos de su ficha y cambios. Se prueba con combates simulados (BalanceSim): el equipo
## de cada uno contra sí mismo, con la IA de su clase frente a una IA al azar.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _engine(player: Array[Pokemon], foes: Array[Pokemon], ai_level: int, items: Array = []) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.ai_level = ai_level
	s.trainers = [{"display_name": "Líder Prueba", "base_money": 10, "lose_text": "Vaya.", "items": items}]
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func test_usa_la_hiperpocion_de_su_ficha_con_pocos_ps() -> void:
	var foe := _mon(&"snorlax", 50, ["tackle"])
	var engine := _engine([_mon(&"rattata", 30, ["tackle"])], [foe], 2, ["hyperpotion"])
	foe.current_hp = foe.max_hp() / 5
	var used := false
	for e: BattleEvent in engine.submit(BattleAction.fight(0)):
		if e.type == BattleEvent.ITEM_USED and e.side == BattleEngine.FOE:
			used = true
	assert_true(used, "se cura con la Hiperpoción")
	assert_eq(engine.foe_items().size(), 0, "y se le gasta")


func test_no_usa_estados_que_no_hacen_nada() -> void:
	var engine := _engine([_mon(&"jolteon", 50, ["splash"])], [_mon(&"pikachu", 50, ["thunderwave", "thunderbolt"])], 3)
	engine.active(0).ability = &"quickfeet"  # Con Absorbe Elec, tampoco le valdría el Rayo.
	var action := BattleAI.choose_action(engine, BattleEngine.FOE, 0, 3)
	assert_eq(action.move_index, 1, "Onda Trueno no afecta a un Pokémon de tipo Eléctrico")


func test_entre_golpes_que_debilitan_elige_el_prioritario() -> void:
	var engine := _engine([_mon(&"rattata", 20, ["tackle"])], [_mon(&"scizor", 60, ["xscissor", "bulletpunch"])], 3)
	assert_eq(BattleAI.choose_action(engine, BattleEngine.FOE, 0, 3).move_index, 1, "Puño Bala, con prioridad")


func test_la_ia_de_los_lideres_gana_a_la_ia_al_azar() -> void:
	var report: PackedStringArray = []
	for trainer_id: StringName in [&"ayuso", &"laporta", &"iniesta", &"pedro_sanchez"]:
		if not DataDB.has_trainer(trainer_id):
			continue
		var party := BattleSetup.trainer(trainer_id).foe_party
		var result := BalanceSim.simulate(party, party, 20, 11, BattleSetup.trainer(trainer_id).ai_level, 0)
		report.append("%s: %d %%" % [trainer_id, result["win_percent"]])
		assert_gte(int(result["win_percent"]), 60, "%s gana a su propio equipo con IA al azar" % trainer_id)
	gut.p("IA de clase contra IA al azar (espejo, 20 combates): " + ", ".join(report))
