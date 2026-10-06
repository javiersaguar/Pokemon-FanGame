extends GutTest
## Megaevolución: piedra, pulsera, una vez por bando, forma y vuelta a la especie base.


func _mon(species: StringName, level: int, moves: Array, item: String = "") -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var p := Pokemon.create(species, level, rng)
	var spec := {"nature": "hardy", "ivs": 31, "moves": moves}
	if item != "":
		spec["item"] = item
	p.apply_spec(spec)
	return p


func _wild(player: Array, foes: Array, mega: bool) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party.assign(player)
	s.foe_party.assign(foes)
	s.player_name = "Javi"
	s.seed = 5
	s.mega_bracelet = mega
	return s


func _fight(mega: bool) -> BattleAction:
	var action := BattleAction.fight(0)
	action.mega = mega
	return action


func _first_move_side(events: Array) -> int:
	for event: BattleEvent in events:
		if event.type == BattleEvent.MOVE:
			return event.side
	return -1


func test_la_pulsera_y_la_piedra_cambian_forma_y_velocidad() -> void:
	var bee := _mon(&"beedrill", 50, ["tackle"], "beedrillite")
	var slow := BattleEngine.new(_wild([bee], [_mon(&"fearow", 50, ["tackle"])], false))
	slow.start()
	assert_false(slow.request.can_mega)
	var without := slow.submit(_fight(true))
	assert_eq(bee.species_id, &"beedrill")
	assert_eq(_first_move_side(without), BattleEngine.FOE)

	var fast_bee := _mon(&"beedrill", 50, ["tackle"], "beedrillite")
	var fast := BattleEngine.new(_wild([fast_bee], [_mon(&"fearow", 50, ["tackle"])], true))
	fast.start()
	assert_true(fast.request.can_mega)
	var before := fast_bee.stat(&"atk")
	var events := fast.submit(_fight(true))
	assert_eq(fast_bee.species_id, &"beedrillmega")
	assert_eq(fast.active(BattleEngine.PLAYER).ability, &"adaptability")
	assert_gt(fast_bee.stat(&"atk"), before)
	assert_eq(_first_move_side(events), BattleEngine.PLAYER)
	var mega_at := -1
	var move_at := -1
	for i: int in events.size():
		var event: BattleEvent = events[i]
		if mega_at < 0 and event.type == BattleEvent.MEGA and event.value("species") == "beedrillmega":
			mega_at = i
		if move_at < 0 and event.type == BattleEvent.MOVE:
			move_at = i
	assert_gt(mega_at, -1)
	assert_lt(mega_at, move_at)


func test_charizard_elige_la_forma_de_su_piedra() -> void:
	var x := _mon(&"charizard", 50, ["tackle"], "charizarditex")
	var engine := BattleEngine.new(_wild([x], [_mon(&"snorlax", 50, ["splash"])], true))
	engine.start()
	engine.submit(_fight(true))
	assert_false(engine.is_over())
	assert_eq(x.species_id, &"charizardmegax")
	assert_true(engine.active(BattleEngine.PLAYER).has_type(&"dragon"))


func test_rayquaza_megaevoluciona_con_el_movimiento() -> void:
	var ray := _mon(&"rayquaza", 50, ["dragonascent"])
	var engine := BattleEngine.new(_wild([ray], [_mon(&"snorlax", 50, ["splash"])], true))
	engine.start()
	engine.submit(_fight(true))
	assert_false(engine.is_over())
	assert_eq(ray.species_id, &"rayquazamega")
	assert_eq(engine.active(BattleEngine.PLAYER).ability, &"deltastream")


func test_solo_una_vez_y_al_cambiar_vuelve_a_su_especie() -> void:
	var venu := _mon(&"venusaur", 40, ["tackle"], "venusaurite")
	var bee := _mon(&"beedrill", 40, ["tackle"], "beedrillite")
	var engine := BattleEngine.new(_wild([venu, bee], [_mon(&"magikarp", 20, ["splash"])], true))
	engine.start()
	engine.submit(_fight(true))
	assert_eq(venu.species_id, &"venusaurmega")
	engine.submit(BattleAction.switch_to(1))
	assert_eq(venu.species_id, &"venusaur")
	var again := BattleAction.fight(0)
	again.mega = true
	engine.submit(again)
	assert_eq(bee.species_id, &"beedrill")


func test_al_ganar_el_equipo_vuelve_a_su_especie() -> void:
	var bee := _mon(&"beedrill", 50, ["tackle"], "beedrillite")
	var karp := _mon(&"magikarp", 5, ["splash"])
	karp.current_hp = 1
	var engine := BattleEngine.new(_wild([bee], [karp], true))
	engine.start()
	var events := engine.submit(_fight(true))
	assert_true(engine.is_over())
	assert_eq(bee.species_id, &"beedrill")
	var mega := false
	for event: BattleEvent in events:
		if event.type == BattleEvent.MEGA:
			mega = true
	assert_true(mega)


func test_el_rival_megaevoluciona_y_al_ganar_vuelve_la_especie() -> void:
	var foe := _mon(&"venusaur", 30, ["tackle"], "venusaurite")
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [_mon(&"beedrill", 50, ["splash"], "beedrillite")]
	s.foe_party = [foe]
	s.seed = 5
	s.ai_level = 1
	s.mega_bracelet = true
	var engine := BattleEngine.new(s)
	engine.start()
	var action := BattleAction.fight(0)
	action.mega = true
	var events := engine.submit(action)
	assert_false(engine.is_over())
	var foe_mega := false
	for event: BattleEvent in events:
		if event.type == BattleEvent.MEGA and event.side == BattleEngine.FOE:
			foe_mega = event.value("species") == "venusaurmega"
	assert_true(foe_mega)
	assert_eq(foe.species_id, &"venusaurmega")
	assert_eq(foe.ability_id(), &"thickfat")
