extends GutTest
## Pokemon: estadísticas, experiencia, movimientos, evolución y guardado (Fase 6).


func _rng(seed_value: int = 1234) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


## Ejemplo clásico de Bulbapedia: Garchomp Nv. 78, Firme.
func _garchomp() -> Pokemon:
	var p := Pokemon.create(&"garchomp", 78, _rng())
	p.apply_spec({
		"nature": "adamant",
		"ivs": {"hp": 24, "atk": 12, "def": 30, "spa": 16, "spd": 23, "spe": 5},
		"evs": {"hp": 74, "atk": 190, "def": 91, "spa": 48, "spd": 84, "spe": 23},
	})
	return p


func test_formulas_de_estadisticas() -> void:
	var p := _garchomp()
	assert_eq(p.max_hp(), 289)
	assert_eq(p.stat(&"atk"), 278)
	assert_eq(p.stat(&"def"), 193)
	assert_eq(p.stat(&"spa"), 135)
	assert_eq(p.stat(&"spd"), 171)
	assert_eq(p.stat(&"spe"), 171)
	assert_eq(p.current_hp, 289)


func test_shedinja_siempre_tiene_1_ps() -> void:
	assert_eq(Pokemon.create(&"shedinja", 50, _rng()).max_hp(), 1)


func test_niveles_de_caracteristicas() -> void:
	assert_eq(StatCalc.apply_stage(100, 1), 150)
	assert_eq(StatCalc.apply_stage(100, 6), 400)
	assert_eq(StatCalc.apply_stage(100, -1), 66)
	assert_eq(StatCalc.apply_stage(100, -6), 25)
	assert_eq(StatCalc.apply_accuracy_stage(100, 1), 133)
	assert_eq(StatCalc.apply_accuracy_stage(100, -1), 75)


func test_creacion_reproducible_y_valida() -> void:
	var a := Pokemon.create(&"pikachu", 12, _rng(99))
	var b := Pokemon.create(&"pikachu", 12, _rng(99))
	assert_eq(a.ivs, b.ivs)
	assert_eq(a.nature, b.nature)
	assert_eq(a.gender, b.gender)
	assert_eq(a.move_ids(), b.move_ids())
	assert_eq(a.exp, DataDB.exp_for_level(&"medium_fast", 12))
	assert_between(a.moves.size(), 1, 4)
	assert_true(a.gender in [Pokemon.MALE, Pokemon.FEMALE])
	assert_eq(Pokemon.create(&"magnemite", 5, _rng()).gender, Pokemon.GENDERLESS)
	for stat: StringName in SpeciesData.STATS:
		assert_between(a.ivs[stat], 0, 31)
		assert_eq(a.evs[stat], 0)


func test_ficha_de_entrenador() -> void:
	var p := Pokemon.from_spec({
		"species": "pikachu", "level": 15,
		"moves": ["quickattack", "thundershock", "doubleteam", "thunderwave"],
		"item": "oranberry", "ability": "lightningrod", "ivs": 31, "nature": "timid",
		"nickname": "Chispas", "shiny": true,
	}, _rng())
	assert_eq(p.level, 15)
	assert_eq(p.move_ids(), [&"quickattack", &"thundershock", &"doubleteam", &"thunderwave"] as Array[StringName])
	assert_eq(p.held_item, &"oranberry")
	assert_eq(p.ability_slot, "H")
	assert_eq(p.ability_id(), &"lightningrod")
	assert_eq(p.ivs[&"spe"], 31)
	assert_eq(p.display_name(), "Chispas")
	assert_true(p.shiny)
	assert_eq(Pokemon.from_spec({"species": "raichu", "form": "alola", "level": 30}, _rng()).species_id, &"raichualola")


func test_experiencia_y_varios_niveles_de_golpe() -> void:
	var p := Pokemon.create(&"pikachu", 5, _rng())
	p.take_damage(5)
	var hp_lost := p.max_hp() - p.current_hp
	var ups := p.gain_exp(300)
	assert_eq(p.level, 7)
	assert_eq(ups.size(), 2)
	assert_eq(ups[0]["level"], 6)
	assert_eq(ups[1]["level"], 7)
	assert_eq(p.max_hp() - p.current_hp, hp_lost, "se conserva el daño recibido")
	assert_eq(p.exp_at_level_start(), 343)
	assert_eq(p.exp_at_next_level(), 512)


func test_aprende_movimientos_al_subir() -> void:
	var p := Pokemon.create(&"charmander", 3, _rng())
	assert_false(p.has_move(&"ember"))
	var ups := p.set_level(4)
	assert_eq(ups[0]["new_moves"], [&"ember"] as Array[StringName])
	assert_true(p.try_learn(&"ember"))
	assert_true(p.has_move(&"ember"))
	assert_false(p.try_learn(&"ember"), "no lo aprende dos veces")


func test_formula_de_experiencia_gen7() -> void:
	# Mismo nivel: (2L+10)/(L+Lp+10) = 1 → floor(b·L/5) + 1.
	assert_eq(ExpCalc.battle_exp(64, 5, 5, true), 65)
	assert_eq(ExpCalc.battle_exp(64, 5, 5, false), 33, "Repartir Experiencia: la mitad")
	assert_gt(ExpCalc.battle_exp(64, 10, 5, true), ExpCalc.battle_exp(64, 10, 10, true), "más nivel del rival → más exp")
	assert_eq(ExpCalc.battle_exp(64, 5, 5, true, 1.5), 97)


func test_evs_con_limites() -> void:
	var p := Pokemon.create(&"pikachu", 5, _rng())
	assert_eq(p.add_evs(&"atk", 300), 252)
	assert_eq(p.add_evs(&"spe", 252), 252)
	assert_eq(p.add_evs(&"hp", 252), 6, "máximo 510 en total")
	assert_eq(p.total_evs(), 510)


func test_guardar_y_cargar_identico() -> void:
	var p := _garchomp()
	p.nickname = "Tiburón"
	p.take_damage(40)
	p.set_status(&"slp", 2)
	p.moves[0].pp -= 3
	var copy := Pokemon.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(copy.to_dict(), p.to_dict())
	assert_eq(copy.stats(), p.stats())
	assert_eq(copy.current_hp, p.current_hp)


func test_curacion_y_debilitado() -> void:
	var p := Pokemon.create(&"bulbasaur", 10, _rng())
	p.take_damage(9999)
	assert_true(p.is_fainted())
	assert_eq(p.heal(10), 0, "un debilitado no se cura con pociones")
	assert_true(p.revive(0.5))
	assert_eq(p.current_hp, p.max_hp() / 2)
	p.set_status(&"psn")
	p.moves[0].pp = 0
	p.heal_full()
	assert_eq(p.current_hp, p.max_hp())
	assert_eq(p.status, &"")
	assert_eq(p.moves[0].pp, p.moves[0].max_pp())


func test_evoluciones() -> void:
	var kadabra := Pokemon.create(&"kadabra", 36, _rng())
	assert_eq(EvolutionRules.level_up_target(kadabra), &"")
	kadabra.set_level(37)
	assert_eq(EvolutionRules.level_up_target(kadabra), &"alakazam", "sustituye al intercambio")

	var onix := Pokemon.create(&"onix", 20, _rng())
	assert_eq(EvolutionRules.level_up_target(onix), &"")
	onix.held_item = &"metalcoat"
	var evo := EvolutionRules.level_up_evolution(onix)
	assert_eq(StringName(evo["to"]), &"steelix")
	EvolutionRules.evolve(onix, evo)
	assert_eq(onix.species_id, &"steelix")
	assert_eq(onix.held_item, &"", "el objeto se gasta")

	var eevee := Pokemon.create(&"eevee", 20, _rng())
	assert_eq(EvolutionRules.item_target(eevee, &"waterstone"), &"vaporeon")
	assert_eq(EvolutionRules.item_target(eevee, &"moonstone"), &"")
	eevee.friendship = 200
	assert_eq(EvolutionRules.level_up_target(eevee, {"time": &"day"}), &"espeon")
	assert_eq(EvolutionRules.level_up_target(eevee, {"time": &"night"}), &"umbreon")
	assert_eq(EvolutionRules.level_up_target(eevee, {"time": &"evening"}), &"")

	var pikachu := Pokemon.create(&"pikachu", 20, _rng())
	assert_eq(EvolutionRules.item_target(pikachu, &"thunderstone"), &"raichu", "la evolución regional de Alola no se aplica")


func test_shedinja() -> void:
	var nincada := Pokemon.create(&"nincada", 20, _rng())
	assert_eq(EvolutionRules.level_up_target(nincada), &"ninjask")
	assert_eq(EvolutionRules.shed_species(&"nincada", &"ninjask"), &"shedinja")


func test_evolucionar_conserva_el_dano() -> void:
	var p := Pokemon.create(&"charmander", 16, _rng())
	p.take_damage(10)
	var lost := p.max_hp() - p.current_hp
	p.evolve_to(&"charmeleon")
	assert_eq(p.species_id, &"charmeleon")
	assert_eq(p.max_hp() - p.current_hp, lost)
