extends GutTest
const SCENE := preload("res://src/battle/scene/battle_scene.tscn")
var done := false
var outcome: StringName
func after_each() -> void:
	GameState.reset()
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func _press(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action; down.pressed = true
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action; up.pressed = false
	Input.parse_input_event(up)
func test_double_real_scene_requests_both_slots_and_targets_second_foe() -> void:
	GameState.reset()
	for id: StringName in [&"charmander",&"bulbasaur"]: GameState.party.add(Pokemon.create(id,30))
	var setup := BattleSetup.wild(&"pidgey",2,{"double":true,"seed":7,"exp_enabled":false})
	setup.foe_party.append(Pokemon.create(&"rattata",2))
	var scene := SCENE.instantiate() as BattleScene
	scene.fast = true
	add_child_autofree(scene)
	done = false
	var requests: Array[int] = []
	var battle := func() -> void:
		outcome = await scene.run(setup)
		done = true
	battle.call()
	for frame: int in 800:
		if done: break
		await wait_process_frames(2)
		var menu: GridMenu
		if scene._command_menu.is_choosing:
			var slot: int = scene._driver.request().slot
			if slot not in requests: requests.append(slot)
			menu = scene._command_menu
			menu.select(BattleScene.Command.FIGHT)
		elif scene._move_menu.is_choosing: menu = scene._move_menu; menu.select(0)
		elif scene._list_menu.is_choosing: menu = scene._list_menu; menu.select(menu.get_child_count()-1)
		if menu: _press(&"accept")
	assert_true(done)
	assert_eq(outcome,&"win")
	assert_eq(requests,[0,1])
	assert_eq(scene._second_sprites.size(),2)
	assert_ne(scene._sprite(0,0),scene._sprite(0,1))
func test_slot_events_do_not_damage_or_hide_the_other_pokemon() -> void:
	var scene := SCENE.instantiate() as BattleScene
	scene.fast = true
	add_child_autofree(scene)
	scene._info = {"format":&"double"}
	scene._configure_field()
	for slot: int in 2:
		await scene._play_event({"type":&"switch_in","side":1,"slot":slot,"data":{"species":&"pidgey","name":"Rival %d" % slot,"hp":20,"max_hp":20}})
	await scene._play_event({"type":&"damage","side":1,"slot":1,"data":{"hp":5}})
	assert_eq(scene._data_box(1,0).hp,20)
	assert_eq(scene._data_box(1,1).hp,5)
	assert_eq(scene.target_slots({"moves":[{"id":&"tackle"}]},0),[0,1])
	assert_eq(scene.target_slots({"moves":[{"id":&"growl"}]},0),[0])
	await scene._play_event({"type":&"faint","side":1,"slot":1,"data":{}})
	assert_true(scene._sprite(1,0).visible)
	assert_false(scene._sprite(1,1).visible)
	assert_eq(scene.target_slots({"moves":[{"id":&"tackle"}]},0),[0])
func test_engine_driver_uses_current_request_and_all_active_members() -> void:
	GameState.reset()
	GameState.party.add(Pokemon.create(&"charmander",20))
	GameState.party.add(Pokemon.create(&"bulbasaur",20))
	GameState.party.add(Pokemon.create(&"pidgey",20))
	var setup := BattleSetup.wild(&"pidgey",3,{"double":true})
	setup.foe_party.append(Pokemon.create(&"rattata",3))
	var driver := EngineDriver.new(setup)
	driver.start()
	driver.submit({"type":&"fight","move_slot":0,"target_slot":1})
	assert_eq(driver.request().slot,1)
	assert_eq(driver.player_active().name,"Bulbasaur")
	assert_true(driver.player_party()[0].active)
	assert_true(driver.player_party()[1].active)
	assert_false(driver.player_party()[2].active)
func test_trainer_pair_combines_both_parties_in_one_setup() -> void:
	var a := TrainerNPC.new()
	var b := TrainerNPC.new()
	a.trainer_id = &"ruta1_manolo"
	b.trainer_id = &"rival_lab_1"
	var group: Array[TrainerNPC] = [a,b]
	var setup: BattleSetup = load("res://src/overworld/trainers/trainer_challenge_event.gd").group_setup(group)
	assert_eq(setup.format,BattleSetup.Format.DOUBLE)
	assert_eq(setup.trainers.size(),2)
	assert_eq(setup.foe_party.size(),DataDB.trainer(a.trainer_id).party.size()+DataDB.trainer(b.trainer_id).party.size())
	a.free(); b.free()
