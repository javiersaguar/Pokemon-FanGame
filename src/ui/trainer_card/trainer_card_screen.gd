class_name TrainerCardScreen
extends MenuScreen
var _active_frame := 0
static func open() -> void:
	var screen := TrainerCardScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)
func _ready() -> void:
	heading.text = "Tarjeta de entrenador"
	panel(Rect2(8,33,240,130))
	var hours := int(GameState.play_time) / 3600
	var minutes := int(GameState.play_time) / 60 % 60
	label("%s\nID %05d / %s\nDinero: %d ₽\nTiempo: %02d:%02d\nPokédex: %d vistos / %d capt." % [GameState.player_name,GameState.trainer_id,"RandomLocke" if GameState.is_randomlocke() else "Normal",GameState.money,hours,minutes,GameState.pokedex.seen_count(),GameState.pokedex.caught_count()],Rect2(17,40,222,68),Color("382a38"),8)
	label("Medallas: %d" % GameState.badges.size(),Rect2(17,112,222,12),Color("382a38"),8)
	var text := "Sin medallas"
	if not GameState.badges.is_empty(): text = "C: consultar las medallas obtenidas"
	var badges_label := label(text,Rect2(17,128,222,29),Color("382a38"),8)
	badges_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.text = "C: estuche / B: volver"
	_active_frame = Engine.get_process_frames()
func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() <= _active_frame + 1: return
	if event.is_action_pressed(&"cancel"): closed.emit()
	elif event.is_action_pressed(&"menu"):
		get_viewport().set_input_as_handled()
		_show_badges()
		return
	else: return
	get_viewport().set_input_as_handled()
func _show_badges() -> void:
	var names := PackedStringArray()
	var notes := PackedStringArray()
	for id: StringName in GameState.badges:
		names.append(String(id))
		notes.append("Medalla obtenida y guardada en la partida. Nombre e ilustración definitivos pendientes.")
	if names.is_empty(): names.append("Sin medallas"); notes.append("Todavía no has obtenido ninguna medalla.")
	await ChoiceScreen.pick("Estuche de medallas",names,notes)
