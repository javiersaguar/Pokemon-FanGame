extends GutTest


func _mon(species: StringName, level: int) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	return Pokemon.create(species, level, rng)


func test_amistad_hora_objeto_movimiento_clima_y_lugar() -> void:
	var golbat := _mon(&"golbat", 30)
	golbat.friendship = 160
	assert_eq(EvolutionRules.level_up_target(golbat), &"crobat")
	var eevee := _mon(&"eevee", 20)
	eevee.friendship = 200
	assert_eq(EvolutionRules.level_up_target(eevee, {"time": &"day"}), &"espeon")
	assert_eq(EvolutionRules.level_up_target(eevee, {"time": &"night"}), &"umbreon")
	var swirlix := _mon(&"swirlix", 20)
	swirlix.held_item = &"whippeddream"
	assert_eq(EvolutionRules.level_up_target(swirlix), &"slurpuff")
	var yanma := _mon(&"yanma", 30)
	yanma.apply_spec({"moves": ["ancientpower"]})
	assert_eq(EvolutionRules.level_up_target(yanma), &"yanmega")
	var sliggoo := _mon(&"sliggoo", 50)
	assert_eq(EvolutionRules.level_up_target(sliggoo, {"weather": &"rain"}), &"goodra")
	assert_eq(EvolutionRules.level_up_target(sliggoo), &"")
	var nosepass := _mon(&"nosepass", 20)
	assert_eq(EvolutionRules.level_up_target(nosepass, {"location": &"magnetic_field"}), &"probopass")
	var milcery := _mon(&"milcery", 15)
	milcery.held_item = &"strawberrysweet"
	assert_eq(EvolutionRules.special_target(milcery, {}), &"")
	assert_eq(EvolutionRules.special_target(milcery, {"spin": true}), &"alcremie")


func test_recordador_tutor_y_mt() -> void:
	var charmander := _mon(&"charmander", 16)
	charmander.moves.clear()
	charmander.try_learn(&"scratch")
	assert_true(&"ember" in MoveLessons.relearnable(charmander))
	assert_true(MoveLessons.teach(charmander, &"ember"))
	assert_true(charmander.has_move(&"ember"))
	assert_eq(MoveLessons.machine_move(&"tm01"), &"megakick")
	assert_false(MoveLessons.use_machine(charmander, &"tm01"))
	var bulbasaur := _mon(&"bulbasaur", 20)
	bulbasaur.apply_spec({"moves": ["tackle"]})
	var solar := MoveLessons.machine_move(&"tm11")
	assert_eq(solar, &"solarbeam")
	assert_true(MoveLessons.use_machine(bulbasaur, &"tm11"))
	assert_true(bulbasaur.has_move(&"solarbeam"))
	var tutors := MoveLessons.tutor_moves(bulbasaur.species_id)
	assert_false(tutors.is_empty())
	assert_true(MoveLessons.use_tutor(bulbasaur, tutors[0]))
	assert_gt(MoveLessons.machine_ids().size(), 100)


func test_la_mt_del_parche_sigue_pudiendo_sustituir_a_la_base() -> void:
	assert_eq(DataDB.tm_move(&"tm01"), &"megakick")
