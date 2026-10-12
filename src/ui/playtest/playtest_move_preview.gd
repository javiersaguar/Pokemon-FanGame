class_name PlaytestMovePreview
extends Control
## Escena real para revisar presentación; no ejecuta turnos ni modifica Pokémon.
signal closed
var player: Dictionary = {}
var foe: Dictionary = {}
var environment: StringName = &"grass"
var move_id: StringName = &"surf"
var entries: Array[Dictionary] = []
var battle: BattleScene
var heading: Label
var note: Label
var choose_button: Button
var replay_button: Button
var back_button: Button
var side_pick: OptionButton
var fast_pick: CheckBox
var _busy := false
var _close_pending := false
var _choosing := false
var _closed := false
var _input_ready_frame := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = PlaytestPicker.menu_theme()
	battle = load("res://src/battle/scene/battle_scene.tscn").instantiate()
	add_child(battle)
	battle._background.set_environment(environment)
	battle._apply_bases()
	battle.get_node("Canvas/Curtain").hide()
	battle._box.hide()
	battle._player_sprite.set_pokemon(player)
	battle._foe_sprite.set_pokemon(foe)
	battle._player_box.show_pokemon(player)
	battle._foe_box.show_pokemon(foe)
	battle._player_box.show()
	battle._foe_box.show()
	heading = Label.new()
	heading.position = Vector2(8,2)
	heading.size = Vector2(496,22)
	heading.clip_text = true
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.add_theme_color_override(&"font_color",Color("fff4d8"))
	heading.add_theme_color_override(&"font_shadow_color",Color("303048"))
	add_child(heading)
	var panel := PanelContainer.new()
	panel.position = Vector2(8,296)
	panel.size = Vector2(496,80)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation",2)
	panel.add_child(box)
	var actions := HBoxContainer.new()
	box.add_child(actions)
	choose_button = _button(actions,"Elegir movimiento",_choose_move)
	choose_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choose_button.clip_text = true
	replay_button = _button(actions,"Repetir",replay)
	replay_button.tooltip_text = "Z/A: reproducir la animación."
	back_button = _button(actions,"Volver",request_close)
	back_button.tooltip_text = "X/B: volver a F9."
	var options := HBoxContainer.new()
	box.add_child(options)
	side_pick = OptionButton.new()
	side_pick.add_item("Jugador")
	side_pick.add_item("Rival")
	side_pick.item_selected.connect(func(_index: int) -> void: _refresh())
	options.add_child(side_pick)
	fast_pick = CheckBox.new()
	fast_pick.text = "Rápida"
	fast_pick.button_pressed = UiPreferences.reduce_motion()
	options.add_child(fast_pick)
	note = Label.new()
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.clip_text = true
	note.tooltip_text = "Solo presentación. PS, PP y efectos de combate se conservan. Z/A repite; X/B vuelve."
	options.add_child(note)
	_refresh()
	_input_ready_frame = Engine.get_process_frames()+1
	replay_button.grab_focus()

func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 36
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _refresh() -> void:
	var move := DataDB.move(move_id)
	choose_button.text = move.name+" / elegir"
	choose_button.tooltip_text = move.description
	var user: Dictionary = player if side_pick.selected == 0 else foe
	var target: Dictionary = user if move.target in MoveData.SELF_TARGETS else (foe if side_pick.selected == 0 else player)
	heading.text = "%s / %s a %s" % [move.name,user.name,target.name]
	heading.tooltip_text = heading.text
	note.text = ("Propia" if not BattleMoveAnimation.sequence(move_id).is_empty() else "Por tipo")+" / solo animación"

func _controls() -> void:
	var blocked := _busy or _choosing or _close_pending
	replay_button.disabled = blocked
	choose_button.disabled = blocked
	side_pick.disabled = blocked
	fast_pick.disabled = blocked

func replay() -> void:
	if _busy or _choosing or _closed or Engine.get_process_frames() <= _input_ready_frame: return
	_busy = true
	_controls()
	note.text = "Reproduciendo…"
	var move := DataDB.move(move_id)
	var side := side_pick.selected
	var target := side if move.target in MoveData.SELF_TARGETS else 1-side
	battle.fast = fast_pick.button_pressed
	await battle._play_event({"type":&"move","side":side,"slot":0,"data":{"move":move_id,"type":move.type,"category":move.category,"target_side":target,"target_slot":0}})
	_busy = false
	if _close_pending:
		_finish_close()
		return
	_controls()
	_refresh()
	if fast_pick.button_pressed or UiPreferences.reduce_motion(): note.text = "Rápida / sin partículas"
	replay_button.grab_focus()

func _choose_move() -> void:
	if _busy or _choosing or _closed: return
	_choosing = true
	_controls()
	var id := await PlaytestPicker.pick("Animaciones de movimientos",entries)
	_choosing = false
	# No reutilizar A/Z del selector para activar el botón de debajo.
	_input_ready_frame = Engine.get_process_frames()+1
	if id != "": move_id = StringName(id)
	_controls()
	_refresh()
	replay_button.grab_focus()

func request_close() -> void:
	if _closed or _choosing: return
	if _busy:
		_close_pending = true
		_controls()
		note.text = "Volviendo…"
	else: _finish_close()

func _finish_close() -> void:
	if _closed: return
	_closed = true
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if SceneManager.top_menu() != self: return
	if event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		request_close()
	elif event.is_action_pressed(&"accept"):
		get_viewport().set_input_as_handled()
		replay()

func menu_resumed() -> void:
	replay_button.grab_focus()
