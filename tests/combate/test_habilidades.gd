extends GutTest
## Habilidades de las especies en uso (fase 9.5, segunda parte): un test por familia, contrastado con
## Showdown y Bulbapedia. Las habilidades se ponen a mano en el Battler para no depender del hueco.


func _mon(species: StringName, level: int, moves: Array, spec: Dictionary = {}) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31, "moves": moves}
	full.merge(spec, true)
	p.apply_spec(full)
	return p


func _engine(player: Array[Pokemon], foes: Array[Pokemon], foe_move: int = 0, oracle: Dictionary = {}) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_e: BattleEngine, _side: int, _slot: int) -> BattleAction: return BattleAction.fight(foe_move)
	if not oracle.is_empty():
		s.rng_oracle = func(tag: StringName, _turn: int) -> float: return float(oracle.get(tag, oracle.get("*", 0.5)))
	var engine := BattleEngine.new(s)
	engine.start()
	return engine


func _sum(events: Array[BattleEvent], type: StringName, side: int, source: String = "") -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == type and e.side == side and (source == "" or e.value("source") == source):
			total += int(e.value("amount"))
	return total


func _text(events: Array[BattleEvent]) -> String:
	var out: PackedStringArray = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE:
			out.append(e.text())
	return "\n".join(out)


## Daño que hace `move` de un Pokémon a otro con las habilidades dadas (mismo azar en cada llamada).
func _hit(atk: StringName, move: String, def: StringName, atk_ability: StringName, def_ability: StringName) -> int:
	var engine := _engine([_mon(atk, 50, [move])], [_mon(def, 50, ["splash"])], 0, {"*": 0.5, "crit": 0.99, "secondary": 0.99})
	engine.active(0).ability = atk_ability
	engine.active(1).ability = def_ability
	return _sum(engine.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, BattleEngine.FOE, "move")


func test_todas_las_habilidades_en_uso_tienen_efecto() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/species_in_use.json"))
	var ids: Array = data.get("species", data.keys()) if data is Dictionary else data
	var missing: PackedStringArray = []
	for sid: Variant in ids:
		if not DataDB.has_species(StringName(str(sid))):
			continue
		for a: StringName in DataDB.species(StringName(str(sid))).abilities.values():
			if a != &"" and Effects.ability(a) == null and String(a) not in missing:
				missing.append(String(a))
	gut.p("Habilidades en uso sin efecto: %s" % ", ".join(missing))
	assert_eq(missing.size(), 0, "todas con efecto")


func test_absorcion_e_inmunidades() -> void:
	var engine := _engine([_mon(&"jolteon", 50, ["thunderbolt", "earthquake", "hypervoice"])], [_mon(&"lanturn", 50, ["splash"])])
	var foe := engine.active(1)
	foe.ability = &"voltabsorb"
	foe.pokemon.current_hp = foe.pokemon.max_hp() / 2
	var events := engine.submit(BattleAction.fight(0))
	assert_eq(_sum(events, BattleEvent.DAMAGE, 1, "move"), 0)
	assert_gt(_sum(events, BattleEvent.HEAL, 1), 0, "Absorbe Elec cura")
	foe.ability = &"lightningrod"
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"spa"], 1, "Pararrayos sube el Ataque Especial")
	foe.ability = &"levitate"
	assert_eq(_sum(engine.submit(BattleAction.fight(1)), BattleEvent.DAMAGE, 1, "move"), 0, "Levitación")
	foe.ability = &"soundproof"
	assert_eq(_sum(engine.submit(BattleAction.fight(2)), BattleEvent.DAMAGE, 1, "move"), 0, "Insonorizar")


func test_robustez_aguanta_y_bloquea_fulminantes() -> void:
	var engine := _engine([_mon(&"machamp", 80, ["closecombat", "fissure"])], [_mon(&"geodude", 20, ["splash"])], 0,
		{"*": 0.5, "crit": 0.99, "accuracy": 0.0})
	var foe := engine.active(1)
	foe.ability = &"sturdy"
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.pokemon.current_hp, 1, "aguanta con 1 PS")
	assert_true(Effects.ability(&"sturdy").immune_to(engine, foe, {}, DataDB.move(&"fissure")))


func test_inmunidad_a_estados_y_volatiles() -> void:
	var engine := _engine([_mon(&"jolteon", 50, ["thunderwave", "confuseray"])], [_mon(&"persian", 50, ["splash"])])
	var foe := engine.active(1)
	foe.ability = &"limber"
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.pokemon.status, &"", "Flexibilidad")
	foe.ability = &"owntempo"
	engine.submit(BattleAction.fight(1))
	assert_false(foe.has_volatile(&"confusion"), "Ritmo Propio")


func test_intimidacion_foco_interno_y_guardian() -> void:
	for pair: Array in [[&"innerfocus", 0], [&"guarddog", 1], [&"intimidate", -1]]:
		var me := _mon(&"gyarados", 50, ["splash"])
		var foe := _mon(&"lucario", 50, ["splash"])
		var engine := _engine([_mon(&"rattata", 50, ["splash"]), me], [foe])
		engine.active(1).ability = pair[0]
		engine.active(0).ability = &"runaway"
		me.ability_slot = "0"
		engine.submit(BattleAction.switch_to(1))
		assert_eq(engine.active(1).boosts[&"atk"], pair[1], "Intimidación contra %s" % pair[0])


func test_caracteristicas_y_potencia() -> void:
	var plain := _hit(&"azumarill", "aquajet", &"snorlax", &"thickfat", &"immunity")
	assert_almost_eq(float(_hit(&"azumarill", "aquajet", &"snorlax", &"hugepower", &"immunity")) / plain, 2.0, 0.15, "Potencia")
	var fire := _hit(&"arcanine", "flamethrower", &"snorlax", &"intimidate", &"immunity")
	assert_almost_eq(float(_hit(&"arcanine", "flamethrower", &"snorlax", &"intimidate", &"thickfat")) / fire, 0.5, 0.08, "Sebo")
	var punch := _hit(&"scizor", "bulletpunch", &"snorlax", &"swarm", &"immunity")
	assert_almost_eq(float(_hit(&"scizor", "bulletpunch", &"snorlax", &"technician", &"immunity")) / punch, 1.5, 0.12, "Experto")
	var stab := _hit(&"porygonz", "hyperbeam", &"snorlax", &"download", &"immunity")
	assert_almost_eq(float(_hit(&"porygonz", "hyperbeam", &"snorlax", &"adaptability", &"immunity")) / stab, 4.0 / 3.0, 0.08, "Adaptable")
	var full := _hit(&"machamp", "closecombat", &"dragonite", &"guts", &"innerfocus")
	assert_almost_eq(float(_hit(&"machamp", "closecombat", &"dragonite", &"guts", &"multiscale")) / full, 0.5, 0.08, "Compensación")


func test_contacto_piel_tosca_y_electricidad_estatica() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["tackle"])], [_mon(&"garchomp", 50, ["splash"])], 0, {"*": 0.0, "crit": 0.99})
	engine.active(1).ability = &"roughskin"
	var events := engine.submit(BattleAction.fight(0))
	assert_gt(_sum(events, BattleEvent.DAMAGE, 0, "ability"), 0, "Piel Tosca")
	engine.active(1).ability = &"static"
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).pokemon.status, &"par", "Elec. Estática al tocar")


func test_entrada_tiempo_descarga_y_rastro() -> void:
	var engine := _engine([_mon(&"pelipper", 50, ["splash"], {"ability": "drizzle"})], [_mon(&"snorlax", 50, ["splash"])])
	assert_eq(engine.weather(), &"raindance", "Llovizna")
	var down := _engine([_mon(&"porygon2", 50, ["splash"], {"ability": "download"})], [_mon(&"blissey", 50, ["splash"])])
	assert_eq(down.active(0).boosts[&"atk"], 1, "Descarga: Blissey tiene menos Defensa")
	var trace := _engine([_mon(&"gardevoir", 50, ["splash"], {"ability": "trace"})], [_mon(&"pelipper", 50, ["splash"], {"ability": "drizzle"})])
	assert_eq(trace.active(0).ability, &"drizzle", "Rastro copia")


func test_final_del_turno_impulso_y_antidoto() -> void:
	var engine := _engine([_mon(&"yanmega", 50, ["splash"])], [_mon(&"gliscor", 50, ["splash"])])
	engine.active(0).ability = &"speedboost"
	var gliscor := engine.active(1)
	gliscor.ability = &"poisonheal"
	gliscor.pokemon.status = &"psn"
	gliscor.pokemon.current_hp = gliscor.pokemon.max_hp() / 2
	var before := gliscor.pokemon.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).boosts[&"spe"], 1, "Impulso")
	assert_gt(gliscor.pokemon.current_hp, before, "Antídoto cura en vez de dañar")


func test_prioridad_bromista_contra_siniestro() -> void:
	var engine := _engine([_mon(&"sableye", 50, ["willowisp"])], [_mon(&"umbreon", 50, ["splash"])])
	var me := engine.active(0)
	me.ability = &"prankster"
	assert_eq(engine.move_priority(me, DataDB.move(&"willowisp")), 1)
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).pokemon.status, &"", "no afecta a los de tipo Siniestro")


func test_criticos_armadura_batalla() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["tackle"])], [_mon(&"kabutops", 50, ["splash"])], 0, {"*": 0.5, "crit": 0.0})
	engine.active(1).ability = &"battlearmor"
	var crits := 0
	for e: BattleEvent in engine.submit(BattleAction.fight(0)):
		if e.type == BattleEvent.DAMAGE and e.side == 1 and bool(e.value("critical", false)):
			crits += 1
	assert_eq(crits, 0)


func test_niveles_respondon_tenacidad_y_cuerpo_puro() -> void:
	var engine := _engine([_mon(&"rattata", 50, ["growl", "swordsdance"])], [_mon(&"snorlax", 50, ["splash"])])
	var foe := engine.active(1)
	foe.ability = &"contrary"
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"atk"], 1, "Respondón")
	foe.ability = &"defiant"
	foe.boosts[&"atk"] = 0
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"atk"], 1, "Tenacidad: −1 y +2")
	foe.ability = &"clearbody"
	foe.boosts[&"atk"] = 0
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"atk"], 0, "Cuerpo Puro")
	engine.active(0).ability = &"simple"
	engine.submit(BattleAction.fight(1))
	assert_eq(engine.active(0).boosts[&"atk"], 4, "Simple dobla la Danza Espada")


func test_formas_disfraz() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["ironhead"])], [_mon(&"mimikyu", 50, ["splash"])], 0, {"*": 0.5, "crit": 0.99})
	var foe := engine.active(1)
	foe.ability = &"disguise"
	var hp := foe.pokemon.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.pokemon.species_id, &"mimikyubusted")
	assert_eq(hp - foe.pokemon.current_hp, foe.pokemon.max_hp() / 8, "solo 1/8 de sus PS")


func test_rompemoldes_y_gas_reactivo() -> void:
	var engine := _engine([_mon(&"excadrill", 50, ["earthquake"])], [_mon(&"bronzong", 50, ["splash"])], 0, {"*": 0.5, "crit": 0.99})
	engine.active(0).ability = &"moldbreaker"
	engine.active(1).ability = &"levitate"
	assert_gt(_sum(engine.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move"), 0, "Rompemoldes pasa por alto Levitación")
	var gas := _engine([_mon(&"weezing", 50, ["splash"])], [_mon(&"gyarados", 50, ["splash"])])
	gas.active(0).ability = &"neutralizinggas"
	gas.active(1).ability = &"intimidate"
	assert_null(gas.ability_effect(gas.active(1)), "Gas Reactivo anula las demás")


func test_muro_magico_y_regeneracion() -> void:
	var engine := _engine([_mon(&"clefable", 50, ["splash"]), _mon(&"rattata", 50, ["splash"])], [_mon(&"snorlax", 50, ["splash"])])
	var me := engine.active(0)
	me.ability = &"magicguard"
	me.pokemon.status = &"psn"
	var hp := me.pokemon.current_hp
	engine.submit(BattleAction.fight(0))
	assert_eq(me.pokemon.current_hp, hp, "Muro Mágico: sin daño por veneno")
	me.ability = &"regenerator"
	me.pokemon.current_hp = 10
	engine.submit(BattleAction.switch_to(1))
	assert_eq(me.pokemon.current_hp, 10 + me.pokemon.max_hp() / 3, "Regeneración al retirarse")
