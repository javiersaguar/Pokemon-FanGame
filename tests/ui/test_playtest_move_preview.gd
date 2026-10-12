extends GutTest
var main: Node
var menu: PlaytestMenu
var preferences: Dictionary
func before_each() -> void:
	GameState.reset()
	SaveManager.test_session_active = false
	preferences = UiPreferences.values.duplicate(true)
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	menu = Debug._preferred_panel as PlaytestMenu
	assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
func after_each() -> void:
	var picker := SceneManager.top_menu() as PlaytestPicker
	if picker: picker._complete("")
	await wait_process_frames(2)
	var view := SceneManager.top_menu() as PlaytestMovePreview
	if view:
		view.request_close()
		await wait_until(func() -> bool: return not SceneManager.is_menu_open(),3.0)
	Debug.close()
	if menu.session.active and menu.session.available(): await menu.session.finish()
	for key: String in preferences: UiPreferences.set_value(key,preferences[key],false)
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
func _open() -> PlaytestMovePreview:
	Debug.open()
	menu._preview_moves()
	await wait_process_frames(3)
	return SceneManager.top_menu() as PlaytestMovePreview
func test_mando_repite_desde_ambos_lados_y_no_consume_ps_pp_objetos_o_preferencias() -> void:
	var party: Dictionary = GameState.party.to_dict().duplicate(true)
	var foes := menu.session.foes.map(func(p: Pokemon) -> Dictionary: return p.to_dict())
	var bag: Dictionary = GameState.bag.to_dict().duplicate(true)
	var view := await _open()
	assert_not_null(view)
	if not view: return
	for entry: Array in [[0,&"surf"],[1,&"hydropump"],[0,&"protect"],[1,&"recover"]]:
		view.side_pick.select(entry[0])
		view.move_id = entry[1]
		view._refresh()
		_press(JOY_BUTTON_A)
		await wait_process_frames(2)
		assert_true(view._busy)
		await wait_until(func() -> bool: return not view._busy,3.0)
		await wait_process_frames(2)
		assert_eq(view.battle._fx.get_child_count(),0)
	assert_eq(GameState.party.to_dict(),party)
	assert_eq(menu.session.foes.map(func(p: Pokemon) -> Dictionary: return p.to_dict()),foes)
	assert_eq(GameState.bag.to_dict(),bag)
	assert_eq(UiPreferences.values,preferences)
	_press(JOY_BUTTON_B)
	await wait_process_frames(3)
	assert_false(SceneManager.is_menu_open())
	assert_false(GameState.is_input_locked_by(&"menu"))
	assert_true(Debug.is_open)
	assert_true(menu.session.active)
func test_cancelar_durante_el_efecto_cierra_limpio_y_reducida_no_crea_particulas() -> void:
	var view := await _open()
	assert_not_null(view)
	if not view: return
	view.move_id = &"swordsdance"
	view._refresh()
	_press(JOY_BUTTON_A)
	await wait_process_frames(2)
	_press(JOY_BUTTON_B)
	await wait_process_frames(2)
	assert_true(view._close_pending)
	await wait_until(func() -> bool: return not SceneManager.is_menu_open(),3.0)
	assert_false(GameState.is_input_locked_by(&"menu"))
	assert_true(Debug.is_open)
	UiPreferences.set_value("reduce_animations",true,false)
	view = await _open()
	assert_not_null(view)
	if not view: return
	assert_true(view.fast_pick.button_pressed)
	var count := view.battle._fx.get_child_count()
	await view.replay()
	assert_eq(view.battle._fx.get_child_count(),count)
	assert_false(view._busy)
	_press(JOY_BUTTON_B)
	await wait_process_frames(3)
	assert_false(SceneManager.is_menu_open())
func test_selector_busca_puno_hielo_y_cancelar_conserva_el_movimiento_y_el_equipo() -> void:
	var party: Dictionary = GameState.party.to_dict().duplicate(true)
	var view := await _open()
	assert_not_null(view)
	if not view: return
	view._choose_move()
	await wait_process_frames(3)
	var picker := SceneManager.top_menu() as PlaytestPicker
	assert_not_null(picker)
	if not picker: return
	picker.search.text = "puño hielo"
	picker._filter(picker.search.text)
	assert_eq(picker.shown.size(),1)
	picker.list.grab_focus()
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	assert_eq(view.move_id,&"icepunch")
	assert_false(view._busy,"Elegir no reproduce a través del menú de debajo")
	assert_true(view.replay_button.has_focus())
	view._choose_move()
	await wait_process_frames(3)
	_press(JOY_BUTTON_B)
	await wait_process_frames(3)
	assert_eq(view.move_id,&"icepunch")
	assert_eq(GameState.party.to_dict(),party)
