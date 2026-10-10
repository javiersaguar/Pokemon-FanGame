extends GutTest
## La sesión usa mundo/motor/archivos reales y restaura también cambios sin guardar.
const SLOT := 96
var main: Node
var session: PlaytestSession
var original_preferences: Dictionary

func before_each() -> void:
	SaveManager.test_session_active = false
	SaveManager.delete_save(SLOT)
	GameState.reset()
	original_preferences = UiPreferences.values.duplicate(true)
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	session = PlaytestSession.new()

func after_each() -> void:
	Debug.close()
	SaveManager.test_session_active = false
	SaveManager.delete_save(SLOT)
	SaveManager.delete_save(SLOT+1)
	for key: String in original_preferences: UiPreferences.set_value(key,original_preferences[key],false)
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null

func test_la_partida_sin_guardar_y_ranura_no_se_tocan() -> void:
	await SceneManager.start_new_game(&"test/test_room", &"default", {"slot":SLOT})
	GameState.player_name = "Original"
	GameState.party.add(Pokemon.create(&"squirtle",13))
	GameState.party.get_at(0).current_hp = 7
	GameState.bag.add(&"potion",2)
	GameState.set_flag(&"mi_prueba_original")
	GameState.set_var(&"mi_valor",42)
	GameState.set_var(&"battle_style","shift")
	assert_eq(SaveManager.save_game(),OK)
	var saved := FileAccess.get_file_as_string(SaveManager.slot_path(SLOT))
	var index := FileAccess.get_file_as_string(SaveManager.INDEX_PATH)
	GameState.money = 1234 # Este cambio no está en la ranura: también debe volver.
	var pokemon_uid: String = GameState.party.get_at(0).uid
	var tile := GameState.player_tile
	assert_eq(await session.begin(&"test/test_room"),OK)
	assert_true(session.active)
	assert_eq(GameState.slot,0)
	assert_eq(SaveManager.save_game(SLOT),ERR_UNAUTHORIZED)
	assert_eq(SaveManager.load_game(SLOT),ERR_UNAUTHORIZED)
	assert_eq(SaveManager.copy_slot(SLOT,SLOT+1),ERR_UNAUTHORIZED)
	SaveManager.delete_save(SLOT)
	GameState.money = 999
	GameState.bag.add(&"potion",70)
	GameState.set_var(&"mi_valor",0)
	assert_eq(await session.finish(),OK)
	assert_false(SaveManager.test_session_active)
	assert_eq(GameState.slot,SLOT)
	assert_eq(GameState.player_name,"Original")
	assert_eq(GameState.money,1234)
	assert_eq(GameState.party.size(),1)
	assert_eq(GameState.party.get_at(0).uid,pokemon_uid)
	assert_eq(GameState.party.get_at(0).current_hp,7)
	assert_eq(GameState.bag.count(&"potion"),2)
	assert_true(GameState.flag(&"mi_prueba_original"))
	assert_eq(GameState.var_int(&"mi_valor"),42)
	assert_eq(GameState.var_str(&"battle_style"),"shift")
	assert_eq(GameState.player_tile,tile)
	assert_false(GameState.input_locked)
	assert_eq(FileAccess.get_file_as_string(SaveManager.slot_path(SLOT)),saved)
	assert_eq(FileAccess.get_file_as_string(SaveManager.INDEX_PATH),index)
	assert_false(SaveManager.has_save(SLOT+1))

func test_original_randomlocke_recupera_rom_y_reglas() -> void:
	var rom := Randomizer.generate(137,RandomizerSettings.from_preset("solo_aleatorio"))
	assert_eq(await SceneManager.start_randomlocke(rom,SLOT,false),OK)
	GameState.party.add(Pokemon.create(&"pikachu",20))
	var patch := GameState.rom_patch.duplicate(true)
	var code: String = GameState.randomlocke.seed_code
	assert_eq(await session.begin(&"test/test_room"),OK)
	assert_false(DataDB.has_patch())
	assert_false(GameState.is_randomlocke())
	assert_eq(await session.finish(),OK)
	assert_true(DataDB.has_patch())
	assert_true(GameState.is_randomlocke())
	assert_eq(GameState.rom_patch,patch)
	assert_eq(GameState.randomlocke.seed_code,code)
	assert_not_null(GameState.locke)

func test_desde_titulo_y_destino_invalido_no_pierde_el_original() -> void:
	await SceneManager.go_to_title()
	assert_eq(await session.begin(&"inexistente/exterior"),ERR_FILE_NOT_FOUND)
	assert_false(session.active)
	assert_false(SaveManager.test_session_active)
	assert_false(GameState.in_game)
	assert_eq(await session.begin(&"test/test_room"),OK)
	assert_true(GameState.in_game)
	assert_eq(await session.finish(),OK)
	assert_false(GameState.in_game)
	assert_true(is_instance_valid(SceneManager._title))

func test_equipo_configurado_se_usa_en_combate_real() -> void:
	assert_eq(await session.begin(&"test/test_room"),OK)
	assert_eq(session.set_member(0,0,{"species":"charizard","level":60,"shiny":true,"item":"charizarditex","moves":["swordsdance","flamethrower","protect","growl"]}),OK)
	assert_eq(session.set_member(1,0,{"species":"magikarp","level":50,"moves":["splash","tackle"]}),OK)
	var setup := session.battle_setup(&"",true,{"double":true,"mega":true,"z":true,"dynamax":true,"tera":true,"environment":"city"})
	assert_not_null(setup)
	assert_eq(setup.format,BattleSetup.Format.DOUBLE)
	assert_eq(setup.player_party[0].species_id,&"charizard")
	assert_eq(setup.player_party[0].level,60)
	assert_eq(setup.player_party[0].held_item,&"charizarditex")
	assert_eq(setup.player_party[0].moves[0].id,&"swordsdance")
	assert_true(setup.player_party[0].shiny)
	assert_eq(setup.foe_party.size(),2)
	assert_ne(setup.foe_party[0].uid,session.foes[0].uid)
	assert_ne(session.battle_setup(&"",true,{}).foe_party[0].uid,setup.foe_party[0].uid)
	assert_true(setup.mega_bracelet and setup.z_ring and setup.dynamax and setup.tera)
	assert_true(setup.can_lose)
	var engine := BattleEngine.new(setup)
	engine.start()
	var action := BattleAction.fight(0)
	var events := engine.submit(action)
	if setup.format == BattleSetup.Format.DOUBLE: events.append_array(engine.submit(BattleAction.fight(0)))
	assert_true(events.any(func(event: BattleEvent) -> bool: return event.type == &"boost" and event.side == 0 and event.data.stat == "atk" and event.data.amount == 2))
	var before: Dictionary = GameState.party.to_dict()
	assert_eq(session.set_member(0,0,{"species":"charizard","moves":["no_existe"]}),ERR_INVALID_DATA)
	assert_eq(GameState.party.to_dict(),before)
	assert_eq(await session.finish(),OK)

func test_mapa_y_llegadas_catalogados_son_usables() -> void:
	var entries := PlaytestSession.maps()
	assert_true(entries.any(func(entry: Dictionary) -> bool: return entry.id == "mostoles/exterior"))
	assert_true(entries.any(func(entry: Dictionary) -> bool: return entry.id == "madrid/retiro"))
	assert_eq(await session.begin(&"getafe/exterior"),OK)
	for id: StringName in [&"mostoles/exterior",&"madrid/retiro",&"sevilla/centro"]:
		var spawns := PlaytestSession.spawns(id)
		assert_false(spawns.is_empty())
		if spawns.is_empty(): continue
		assert_eq(await SceneManager.change_map(id,spawns[0]),OK)
		assert_eq(SceneManager.current_map.get_map_id(),id)
	assert_eq(await session.finish(),OK)

func test_no_se_suspende_un_combate_y_f9_se_registra() -> void:
	assert_eq(await session.begin(&"test/test_room"),OK)
	SceneManager.in_battle = true
	assert_eq(await session.finish(),ERR_BUSY)
	assert_null(session.battle_setup(&"",true,{}))
	assert_true(session.active)
	SceneManager.in_battle = false
	assert_eq(await session.finish(),OK)
	Debug.open()
	assert_true(Debug._preferred_panel is PlaytestMenu)
	assert_eq(Debug._tabs.get_current_tab_control(),Debug._preferred_panel)
	Debug.close()

func test_f9_entrar_inicia_el_pueblo_y_conserva_el_borrador_del_editor() -> void:
	var menu := Debug._preferred_panel as PlaytestMenu
	Debug.open()
	menu.start_button.pressed.emit()
	for i: int in 240:
		await wait_physics_frames(1)
		if menu.session.active and not menu.session.working: break
	assert_true(menu.session.active)
	assert_eq(GameState.map_id,&"pueblo_inicial/exterior")
	assert_false(Debug.is_open)
	Debug.open()
	menu.spec.moves = ["swordsdance","flamethrower","protect","growl"]
	menu._update_editor()
	Debug.close()
	Debug.open()
	assert_eq(menu.spec.moves,["swordsdance","flamethrower","protect","growl"])
	Debug.close()
	assert_eq(await menu.session.finish(),OK)

func test_no_admite_una_segunda_sesion_y_las_formas_son_distinguibles() -> void:
	assert_eq(await session.begin(&"test/test_room"),OK)
	var other := PlaytestSession.new()
	assert_eq(await other.begin(&"test/test_room"),ERR_BUSY)
	var menu := Debug._preferred_panel as PlaytestMenu
	var forms := menu._catalogue("species").filter(func(entry: Dictionary) -> bool: return str(entry.id).begins_with("charizard"))
	var names: Array = forms.map(func(entry: Dictionary) -> String: return str(entry.label))
	assert_gt(forms.size(),1)
	var unique := {}
	for value: String in names: unique[value] = true
	assert_eq(names.size(),unique.size())
	assert_eq(await session.finish(),OK)
