extends GutTest
var main: Node
var menu: PlaytestMenu
func before_each() -> void:
	GameState.reset()
	SaveManager.test_session_active = false
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	menu = Debug._preferred_panel as PlaytestMenu
func after_each() -> void:
	Debug.close()
	if menu.session.active and menu.session.available(): await menu.session.finish()
	SaveManager.test_session_active = false
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	MapLoader.clear()
func _press(button: JoyButton) -> void:
	for down: bool in [true,false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		event.pressed = down
		Input.parse_input_event(event)
func test_habilidad_oculta_se_elige_con_mando_y_aplicar_objeto_la_conserva() -> void:
	assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
	assert_eq(menu.session.set_member(0,0,{"species":"pikachu","level":50,"ability":"static","moves":["tackle"]}),OK)
	Debug.open()
	menu.pages.current_tab = 1
	menu._choose_ability()
	await wait_process_frames(3)
	var picker := SceneManager.top_menu() as PlaytestPicker
	assert_not_null(picker)
	if picker == null: return
	var index := -1
	for i: int in picker.shown.size():
		if picker.shown[i].id == "lightningrod": index = i
	assert_gte(index,0)
	if index < 0: return
	picker.shown[index].note = str(picker.shown[index].note).repeat(3)
	picker.list.select(index)
	picker.list.item_selected.emit(index)
	await wait_process_frames(3)
	assert_true(picker.note.text.contains("Cobertura"))
	assert_true(picker.detail_hint.visible)
	picker.list.grab_focus()
	_press(JOY_BUTTON_START)
	await wait_process_frames(2)
	assert_gt(picker.detail_scroll.scroll_vertical,0,"Start permite leer toda la descripción")
	assert_eq(menu.spec.ability,"static","Leer no aplica ni elige habilidad")
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	assert_eq(menu.spec.ability,"lightningrod")
	assert_eq(GameState.party.get_at(0).ability_id(),&"static","Es un borrador hasta Aplicar")
	menu._apply_member()
	assert_eq(GameState.party.get_at(0).ability_id(),&"lightningrod")
	menu.spec.item = "leftovers"
	menu._apply_member()
	assert_eq(GameState.party.get_at(0).ability_id(),&"lightningrod")
	assert_eq(GameState.party.get_at(0).held_item,&"leftovers")
func test_set_por_nivel_es_borrador_y_una_habilidad_ilegal_no_reemplaza_al_pokemon() -> void:
	assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
	assert_eq(menu.session.set_member(0,0,{"species":"pikachu","level":50,"ability":"static","moves":["tackle"]}),OK)
	var uid: String = GameState.party.get_at(0).uid
	assert_eq(menu.session.set_member(0,0,{"species":"pikachu","level":50,"ability":"overgrow","moves":["tackle"]}),ERR_INVALID_DATA)
	assert_eq(GameState.party.get_at(0).uid,uid)
	menu.spec.level = 25
	menu._moves_for_level()
	assert_eq(GameState.party.get_at(0).moves.size(),1)
	assert_eq(menu.spec.moves.size(),4)
	var moveset: Array = menu.spec.moves.duplicate()
	menu._apply_member()
	assert_eq(GameState.party.get_at(0).level,25)
	assert_eq(GameState.party.get_at(0).moves.map(func(m: MoveSlot) -> String: return String(m.id)),moveset)
	assert_eq(GameState.party.get_at(0).ability_id(),&"static")
