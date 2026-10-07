extends GutTest
func after_each() -> void:
	GameState.reset()
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func test_available_buttons_follow_engine_request_and_z_move_indices() -> void:
	assert_eq(BattleMechanics.available({},0),[&""])
	var request := {"can_mega":true,"z_moves":[1],"can_dynamax":true,"can_tera":true}
	assert_eq(BattleMechanics.available(request,0),[&"",&"mega",&"dynamax",&"tera"])
	assert_eq(BattleMechanics.available(request,1),[&"",&"mega",&"z",&"dynamax",&"tera"])
	assert_eq(BattleMechanics.action(2,1,&"z"),{"type":&"fight","move_slot":2,"target_slot":1,"z":true})
func test_transform_events_use_new_sprite_hp_and_revert_size_on_end() -> void:
	var scene := preload("res://src/battle/scene/battle_scene.tscn").instantiate() as BattleScene
	scene.fast = true
	add_child_autofree(scene)
	scene._box.text_speed = 0
	await scene._play_event({"type":&"switch_in","side":0,"slot":0,"data":{"species":&"charizard","party_index":0,"name":"Chispa","hp":30,"max_hp":60}})
	await scene._play_event({"type":&"mega","side":0,"slot":0,"data":{"species":&"charizardmegax","hp":30,"max_hp":60}})
	assert_eq(scene._player_sprite.species_id,&"charizardmegax")
	assert_eq(scene._player_box.pokemon_name,"Chispa")
	assert_eq(scene._player_box.mechanic,&"mega")
	await scene._play_event({"type":&"dynamax","side":0,"slot":0,"data":{"hp":60,"max_hp":120}})
	assert_eq(scene._player_sprite.scale,Vector2(2,2))
	assert_eq(scene._player_box.hp,60)
	assert_eq(scene._player_box.max_hp,120)
	await scene._play_event({"type":&"dynamax_end","side":0,"slot":0,"data":{"hp":25,"max_hp":60}})
	assert_eq(scene._player_sprite.scale,Vector2.ONE)
	assert_eq(scene._player_box.hp,25)
	assert_eq(scene._player_box.max_hp,60)
func test_tera_marker_survives_withdraw_and_returns_to_correct_member() -> void:
	var scene := preload("res://src/battle/scene/battle_scene.tscn").instantiate() as BattleScene
	scene.fast = true
	add_child_autofree(scene)
	scene._box.text_speed = 0
	var data := {"species":&"charmander","party_index":0,"name":"Chispa","hp":20,"max_hp":20}
	await scene._play_event({"type":&"switch_in","side":0,"slot":0,"data":data})
	await scene._play_event({"type":&"tera","side":0,"slot":0,"data":{"type":&"water"}})
	await scene._play_event({"type":&"switch_out","side":0,"slot":0,"data":{}})
	var other := data.duplicate(); other.party_index = 1
	await scene._play_event({"type":&"switch_in","side":0,"slot":0,"data":other})
	assert_eq(scene._player_box.mechanic,&"")
	await scene._play_event({"type":&"switch_in","side":0,"slot":0,"data":data})
	assert_eq(scene._player_box.mechanic,&"tera")
	assert_eq(scene._player_box.tera_type,&"water")
func test_original_mega_resources_and_reduced_fx_cleanup() -> void:
	var original := "res://assets/sprites/ui/battle/gimmicks/mega.png"
	var texture: Texture2D = load(original)
	assert_eq(texture.get_size(),Vector2(26,34))
	var sprite := BattlePokemonSprite.new()
	add_child_autofree(sprite)
	sprite.set_pokemon({"species":&"pidgey"})
	sprite.set_big(true)
	assert_eq(sprite.rotation,0.0)
	assert_eq(sprite.position,sprite.position.round())

func test_mechanic_button_selection_and_cancel_send_only_chosen_flag() -> void:
	var scene := preload("res://src/battle/scene/battle_scene.tscn").instantiate() as BattleScene
	scene.fast = true
	add_child_autofree(scene)
	scene._box.text_speed = 0
	var selected: Array[StringName] = []
	var choose := func() -> void: selected.append(await scene._choose_mechanic({"can_mega":true,"can_tera":true},0))
	choose.call()
	await wait_process_frames(3)
	assert_true(scene._list_menu.get_child(1) is BattleButton)
	scene._list_menu.select(1)
	var down := InputEventJoypadButton.new()
	down.button_index = JOY_BUTTON_A; down.pressed = true
	Input.parse_input_event(down)
	var up := down.duplicate() as InputEventJoypadButton
	up.pressed = false
	Input.parse_input_event(up)
	await wait_process_frames(3)
	assert_eq(selected,[&"mega"])
	selected.clear()
	choose.call()
	await wait_process_frames(3)
	down = InputEventJoypadButton.new()
	down.button_index = JOY_BUTTON_B; down.pressed = true
	Input.parse_input_event(down)
	up = down.duplicate() as InputEventJoypadButton; up.pressed = false
	Input.parse_input_event(up)
	await wait_process_frames(3)
	assert_eq(selected,[&"cancel"])
