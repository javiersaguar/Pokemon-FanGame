extends GutTest
## Entradas físicas del mando y búsquedas reales del catálogo, sin tocar partidas.
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
	SaveManager.test_session_active = false
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null

func _press(button: JoyButton) -> void:
	for down: bool in [true, false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		event.pressed = down
		Input.parse_input_event(event)

func _picker(kind: String) -> PlaytestPicker:
	var picker := PlaytestPicker.new()
	picker.entries = menu._catalogue(kind)
	SceneManager.push_menu(picker)
	return picker

func test_a_del_mando_activa_entrar_sin_raton() -> void:
	Debug.open()
	await wait_process_frames(3)
	menu.start_button.grab_focus()
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	assert_true(menu.session.active, "A debe activar el botón que tiene el foco")
	if menu.session.active:
		await wait_until(func() -> bool: return not menu.session.working, 4.0)
		assert_eq(await menu.session.finish(), OK)

func test_busqueda_espanola_sin_tildes_y_con_palabras_separadas() -> void:
	var picker := _picker("moves")
	picker._filter(" ATAQUE rapido ")
	assert_true(picker.shown.any(func(entry: Dictionary) -> bool: return entry.id == "quickattack"))
	picker._filter("puno fuego")
	assert_true(picker.shown.any(func(entry: Dictionary) -> bool: return entry.id == "firepunch"))
	SceneManager.pop_menu(picker)
	await wait_process_frames(2)
	picker = _picker("species")
	picker._filter("CHARIZARD mega X")
	assert_eq(picker.shown.map(func(entry: Dictionary) -> String: return entry.id), ["charizardmegax"])

func test_mando_b_cancela_busqueda_y_a_elige_una_sola_vez() -> void:
	var picker := _picker("moves")
	var answers: Array[String] = []
	picker.completed.connect(func(id: String) -> void: answers.append(id))
	await wait_process_frames(3)
	assert_true(picker.search.has_focus())
	_press(JOY_BUTTON_B)
	await wait_process_frames(2)
	assert_eq(answers, [""], "B cierra también al escribir en el buscador")
	SceneManager.pop_menu(picker)
	await wait_process_frames(2)
	picker = _picker("moves")
	answers.clear()
	picker.completed.connect(func(id: String) -> void: answers.append(id))
	picker._filter("ataque rápido")
	picker.list.grab_focus()
	await wait_process_frames(2)
	_press(JOY_BUTTON_A)
	await wait_process_frames(2)
	assert_eq(answers, ["quickattack"])

func test_quitar_movimiento_cancela_o_edita_sin_huecos_y_conserva_el_ultimo() -> void:
	assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
	assert_eq(menu.session.set_member(0,0,{"species":"pikachu","level":50,"moves":["tackle","growl","quickattack","thunderbolt"]}),OK)
	Debug.open()
	menu.pages.current_tab = 1
	await wait_process_frames(3)
	menu.remove_move_button.grab_focus()
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	assert_true(SceneManager.top_menu() is PlaytestPicker)
	_press(JOY_BUTTON_B)
	await wait_process_frames(3)
	assert_eq(menu.spec.moves,["tackle","growl","quickattack","thunderbolt"])
	for remaining: int in [3,2,1]:
		menu.remove_move_button.grab_focus()
		_press(JOY_BUTTON_A)
		await wait_process_frames(3)
		var picker := SceneManager.top_menu() as PlaytestPicker
		assert_not_null(picker)
		if picker == null: break
		picker.list.select(1)
		picker.list.grab_focus()
		_press(JOY_BUTTON_A)
		await wait_process_frames(3)
		assert_eq(menu.spec.moves.size(),remaining)
	assert_eq(menu.spec.moves,["tackle"])
	assert_true(menu.remove_move_button.disabled)
	assert_eq(GameState.party.get_at(0).moves.size(),4,"El editor espera Aplicar")
	menu._remove_move()
	assert_false(SceneManager.is_menu_open(),"No permite quitar el último movimiento")
	menu._apply_member()
	assert_eq(GameState.party.get_at(0).moves.map(func(m: MoveSlot) -> String: return String(m.id)),["tackle"])
	menu.side_pick.selected = 1
	menu.member_pick.selected = 0
	assert_eq(menu.session.set_member(1,0,{"species":"magikarp","level":50,"moves":["tackle","splash"]}),OK)
	await wait_process_frames(3)
	menu.remove_move_button.grab_focus()
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	var picker := SceneManager.top_menu() as PlaytestPicker
	assert_not_null(picker)
	if picker != null:
		picker.list.select(0)
		picker.list.grab_focus()
		_press(JOY_BUTTON_A)
		await wait_process_frames(3)
		menu._apply_member()
	assert_eq(menu.session.foes[0].moves.map(func(m: MoveSlot) -> String: return String(m.id)),["splash"])
	assert_eq(await menu.session.finish(),OK)
