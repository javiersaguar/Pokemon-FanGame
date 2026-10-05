extends GutTest
## Integración del mundo, con el motor y adaptador reales; sin pantallas nuevas.

const SLOT := 97

func before_each() -> void:
	GameState.new_game({"mode": "randomlocke", "randomlocke": {"settings": {"nickname_required": false, "gifts_count": false}, "families": {"bulbasaur": "bulbasaur", "ivysaur": "bulbasaur"}}})
	GameState.map_id = &"test/test_outdoor"
	GameState.player_name = "Javi"
	GameState.party.add(Pokemon.create(&"pikachu", 10))
	GameState.locke.rules.register_owned("pikachu")

func after_each() -> void:
	SaveManager.delete_save(SLOT)
	GameState.reset()
	SaveManager.apply_rom_patch()

func test_registra_antes_de_combate_y_una_zona_entre_plantas() -> void:
	var a := SceneManager.prepare_battle(BattleSetup.wild(&"bulbasaur", 3), {"zone_id": "ruta_1"}) as LockeBattleDriver
	assert_eq(GameState.locke.rules.zone_status("ruta_1"), "pending")
	assert_true(GameState.locke.can_catch(a.encounter))
	a.inner.engine.result.outcome = &"run"
	a.finish()
	assert_eq(GameState.locke.rules.zone_status("ruta_1"), "lost")
	var b := SceneManager.prepare_battle(BattleSetup.wild(&"pidgey", 3), {"zone_id": "ruta_1"}) as LockeBattleDriver
	assert_false(b.can_use_item(&"pokeball"), "misma zona, aunque cambie mapa/planta")
	GameState.bag.add(&"pokeball", 1)
	assert_eq(b.submit({"type": &"item", "item": &"pokeball"}), [])
	assert_eq(GameState.bag.count(&"pokeball"), 1, "no gasta Ball ni turno")
	assert_eq(b.inner.engine.turn, 0)

func test_captura_duplicados_por_familia_y_shiny() -> void:
	var driver := SceneManager.prepare_battle(BattleSetup.wild(&"bulbasaur", 3), {"zone_id": "uno"}) as LockeBattleDriver
	driver.inner.engine.result.caught_pokemon = driver.inner.setup.foe_party[0]
	driver.inner.engine.result.outcome = &"caught"
	driver.finish()
	driver.finish()
	assert_eq(GameState.party.size(), 2, "resultado idempotente")
	assert_eq(GameState.locke.rules.zone_status("uno"), "caught")
	assert_false(GameState.locke.begin(Pokemon.create(&"ivysaur", 20), "dos").allowed)
	assert_eq(GameState.locke.rules.zone_status("dos"), "available")
	var shiny := Pokemon.create(&"ivysaur", 20)
	shiny.shiny = true
	assert_true(GameState.locke.begin(shiny, "uno").allowed)
	assert_eq(GameState.locke.rules.zone_status("uno"), "caught", "shiny no restaura zona")

func test_mote_pendiente_guardable_y_resolucion_no_inventada() -> void:
	GameState.new_game({"mode": "randomlocke", "randomlocke": {"settings": {}, "families": {"pidgey": "pidgey"}}})
	var pokemon := Pokemon.create(&"pidgey", 5)
	var encounter := GameState.locke.begin(pokemon, "ruta")
	assert_eq(GameState.locke.receive(pokemon, encounter), "pending")
	assert_eq(GameState.party.size(), 0)
	assert_eq(GameState.locke.complete_capture(encounter.encounter_id, "  "), "")
	var saved := JSON.parse_string(JSON.stringify(GameState.to_dict())) as Dictionary
	GameState.from_dict(saved)
	assert_true(GameState.is_input_locked_by(&"locke_nickname"))
	assert_eq(GameState.locke.complete_capture(encounter.encounter_id, "Panchi"), "party")
	assert_eq(GameState.party.get_at(0).nickname, "Panchi")
	assert_false(GameState.is_input_locked_by(&"locke_nickname"))
	assert_eq(GameState.locke.rules.zone_status("ruta"), "caught")

func test_inicial_poseido_no_consume_zona_y_regalo_configurable() -> void:
	var initial := Pokemon.create(&"bulbasaur", 5)
	assert_eq(await Cutscene.give_pokemon(initial, false, "starter"), "party")
	assert_true(GameState.flag(&"starter_chosen"))
	assert_false(GameState.locke.rules.can_catch("libre", "ivysaur"))
	assert_eq(GameState.locke.rules.zone_status("test/test_outdoor"), "available")
	var gift := Pokemon.create(&"pidgey", 5)
	var encounter := GameState.locke.begin(gift, "libre", "gift")
	assert_eq(GameState.locke.receive(gift, encounter), "party")
	assert_eq(GameState.locke.rules.zone_status("libre"), "available", "gifts_count=false")

func test_muertes_idempotentes_cementerio_pc_y_no_curar() -> void:
	var pokemon := GameState.party.get_at(0) as Pokemon
	pokemon.current_hp = 0
	var grave := GameState.locke.death(pokemon, {"zone_id": "ruta", "opponent": "Rival", "turn": 2})
	assert_eq(grave.uid, pokemon.uid)
	assert_ne(grave.epitaph, "")
	GameState.locke.death(pokemon, {})
	GameState.pc.deposit(pokemon)
	GameState.locke.remove_dead()
	Cutscene.heal_party()
	assert_eq(GameState.party.size(), 0)
	assert_eq(GameState.pc.count(), 0)
	assert_eq(pokemon.current_hp, 0)
	assert_eq(GameState.locke.rules.snapshot().death_count, 1)
	assert_eq(GameState.locke.rules.snapshot().cemetery[0].opponent, "Rival")
	assert_true(GameState.locke.check_game_over())
	assert_eq(GameState.randomlocke.status, "finished")
	assert_eq(SaveManager.save_game(SLOT), OK)
	assert_eq(SaveManager.slot_summary(SLOT).status, "finished")
	assert_eq(await SceneManager.continue_game(SLOT), ERR_UNAUTHORIZED)

func test_superviviente_pc_y_permadeath_desactivada() -> void:
	var pokemon := GameState.party.get_at(0) as Pokemon
	pokemon.current_hp = 0
	GameState.pc.deposit(Pokemon.create(&"pidgey", 5))
	GameState.locke.death(pokemon, {"zone_id": "ruta"})
	GameState.locke.remove_dead()
	assert_false(GameState.locke.check_game_over(), "PC utilizable evita game over")
	GameState.new_game({"mode": "randomlocke", "randomlocke": {"settings": {"permadeath": false}, "families": {"pikachu": "pikachu"}}})
	pokemon = Pokemon.create(&"pikachu", 5)
	pokemon.current_hp = 0
	GameState.party.add(pokemon)
	assert_eq(GameState.locke.death(pokemon, {}), {})
	assert_false(GameState.locke.check_game_over())
	Cutscene.heal_party()
	assert_gt(pokemon.current_hp, 0)
	var setup := BattleSetup.wild(&"pidgey", 3)
	SceneManager.prepare_battle(setup)
	assert_false(setup.locke_rules)

func test_tutorial_excluido_y_modo_normal_sin_adaptador() -> void:
	var setup := BattleSetup.trainer(&"rival_lab_1", {"can_lose": true})
	assert_same(SceneManager.prepare_battle(setup, {"tutorial": true}), setup)
	assert_false(setup.locke_rules)
	assert_null(setup.locke, "tutorial excluye también EXP/objetos/modo")
	assert_true(setup.tutorial)
	assert_eq(GameState.locke.rules.snapshot().encounters, {})
	GameState.new_game()
	setup = BattleSetup.wild(&"pidgey", 3)
	assert_null(GameState.locke)
	assert_same(SceneManager.prepare_battle(setup), setup)

func test_zone_id_export_y_respaldo() -> void:
	var map := MapRoot.new()
	map.data = MapData.new()
	map.data.id = &"cueva/planta_1"
	assert_eq(map.get_zone_id(), &"cueva/planta_1")
	map.data.zone_id = &"cueva"
	assert_eq(map.get_zone_id(), &"cueva")
	map.free()

func test_death_del_motor_real_llega_a_cementerio() -> void:
	var setup := BattleSetup.wild(&"mewtwo", 90, {"seed": 47})
	var lead := GameState.party.get_at(0) as Pokemon
	lead.current_hp = 1
	var driver := SceneManager.prepare_battle(setup, {"zone_id": "ruta"}) as LockeBattleDriver
	driver.start()
	for turn: int in 10:
		if driver.is_over():
			break
		driver.submit({"type": &"fight", "move_slot": 0})
	assert_true(driver.is_over())
	driver.finish()
	assert_eq(GameState.locke.rules.snapshot().death_count, 1)
	assert_eq(GameState.party.size(), 0)
	assert_eq(GameState.randomlocke.status, "finished")

func test_migracion_v1_conserva_zonas_muertes_y_rom() -> void:
	var state := GameState.to_dict()
	state.randomlocke = {"zones": {"ruta": "lost"}, "deaths": 2, "settings": {"nickname_required": false}, "families": {"pikachu": "pikachu"}}
	var file := FileAccess.open(SaveManager.slot_path(SLOT), FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version": 1, "state": state}))
	file.close()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_eq(GameState.locke.rules.zone_status("ruta"), "lost")
	assert_eq(GameState.randomlocke.deaths, 2, "no inventa lápidas del legado")
	assert_eq(GameState.locke.rules.snapshot().cemetery, [])
	assert_eq(SaveManager.save_game(SLOT), OK)
	GameState.reset()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_eq(GameState.randomlocke.deaths, 2)

func test_equipo_y_pc_llenos_no_gastan_ball_ni_dejan_mote_sin_salida() -> void:
	while not GameState.party.is_full():
		GameState.party.add(Pokemon.create(&"rattata", 2))
	var filler := Pokemon.create(&"pidgey", 2)
	for box: int in GameState.pc.box_count():
		for slot: int in GameState.pc.box_size():
			GameState.pc.set_pokemon(box, slot, filler)
	var driver := SceneManager.prepare_battle(BattleSetup.wild(&"bulbasaur", 3), {"zone_id": "ruta"}) as LockeBattleDriver
	driver.start()
	GameState.bag.add(&"pokeball", 1)
	assert_false(driver.can_use_item(&"pokeball"))
	assert_eq(driver.submit({"type": &"item", "item": &"pokeball"}), [])
	assert_eq(GameState.bag.count(&"pokeball"), 1)
	assert_eq(GameState.locke.pending, {})
