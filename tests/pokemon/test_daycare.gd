extends GutTest


func _mon(species: StringName, gender: String, item: String = "") -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var p := Pokemon.create(species, 20, rng)
	var spec := {"gender": gender, "ivs": 31, "nature": "hardy"}
	if item != "":
		spec["item"] = item
	p.apply_spec(spec)
	return p


func test_compatibilidad_por_grupo_sexo_y_ditto() -> void:
	var male := _mon(&"bulbasaur", "male")
	var female := _mon(&"ivysaur", "female")
	assert_true(Daycare.compatible(male, female))
	assert_eq(Daycare.egg_species(male, female), &"bulbasaur")
	assert_false(Daycare.compatible(male, _mon(&"bulbasaur", "male")))
	assert_true(Daycare.compatible(Pokemon.create(&"ditto", 10), _mon(&"charmander", "male")))
	assert_false(Daycare.compatible(Pokemon.create(&"ditto", 10), Pokemon.create(&"ditto", 10)))
	assert_false(Daycare.compatible(Pokemon.create(&"ditto", 10), Pokemon.create(&"mew", 10)))
	assert_eq(Daycare.egg_percent(male, female), 20)
	female.original_trainer = "otro"
	assert_eq(Daycare.egg_percent(male, female), 50)


func test_hereda_piedra_eterna_lazo_y_movimiento_huevo() -> void:
	var mother := _mon(&"ivysaur", "female", "everstone")
	mother.ball = &"greatball"
	var father := _mon(&"bulbasaur", "male", "destinyknot")
	father.apply_spec({"moves": ["tackle", "curse"], "ivs": 0})
	var care := Daycare.new(4)
	care.deposit(mother)
	care.deposit(father)
	care.egg_ready = true
	var egg := care.take_egg()
	assert_eq(egg.species_id, &"bulbasaur")
	assert_eq(egg.nature, &"hardy")
	assert_eq(egg.ball, &"greatball")
	assert_true(egg.has_move(&"curse"))
	var from_father := 0
	for stat: StringName in SpeciesData.STATS:
		if egg.ivs[stat] == 0:
			from_father += 1
	assert_gte(from_father, 1)
	var fixed := 0
	for stat: StringName in SpeciesData.STATS:
		if egg.ivs[stat] == 0 or egg.ivs[stat] == 31:
			fixed += 1
	assert_gte(fixed, 5)


func test_cuerpo_llama_cuenta_el_paso_doble_y_masuda_son_seis_tiradas() -> void:
	var care := Daycare.new(8)
	care.deposit(_mon(&"bulbasaur", "male"))
	care.deposit(_mon(&"bulbasaur", "female"))
	care.walk(128, false)
	assert_eq(care.steps, 128)
	assert_false(care.egg_ready)
	var fast := Daycare.new(8)
	fast.deposit(_mon(&"bulbasaur", "male"))
	fast.deposit(_mon(&"bulbasaur", "female"))
	fast.walk(128, true)
	assert_eq(fast.steps, 0)
	assert_eq(Daycare.shiny_rolls(false), 1)
	assert_eq(Daycare.shiny_rolls(true), 6)


func test_el_pokerus_pasa_al_de_al_lado() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var sick := _mon(&"pidgey", "male")
	sick.pokerus = 1
	var healthy := _mon(&"pidgey", "female")
	var party: Array[Pokemon] = [sick, healthy]
	var caught := false
	for _i: int in 20:
		Daycare.spread_pokerus(party, rng)
		if healthy.pokerus == 1:
			caught = true
			break
	assert_true(caught)
