class_name LearnMoveScreen
extends ChoiceScreen
var request: Dictionary

static func choose(request_data: Dictionary) -> int:
	var screen := LearnMoveScreen.new()
	screen.request = request_data
	SceneManager.push_menu(screen)
	var index: int = await screen.chosen
	SceneManager.pop_menu(screen)
	var moves: Array = request_data.get("moves", [])
	if index < 0 or index >= moves.size(): return -1
	if not await Dialogue.ask_yes_no("¿Olvidar %s para aprender %s?" % [moves[index].get("name", "?"), request_data.get("move_name", "?")]):
		return await choose(request_data)
	return index

func _ready() -> void:
	caption = "¿Qué movimiento olvidas?"
	for move: Dictionary in request.get("moves", []):
		choices.append(str(move.get("name", "?")))
		notes.append(describe(StringName(move.get("id", "")), int(move.get("pp", 0)), int(move.get("max_pp", 0))))
	choices.append("No aprender")
	notes.append(describe(StringName(request.get("move_id", ""))))
	super._ready()
	label("Nuevo: %s" % request.get("move_name", "?"), Rect2(12, 159, 140, 13), Color("fff4d8"), 8)

static func describe(id: StringName, pp := -1, maximum := -1) -> String:
	if not DataDB.has_move(id): return String(id)
	var move := DataDB.move(id)
	return "%s\n%s / %s\nPP %d/%d\nPot. %s\nPrec. %s\n%s" % [move.name, DataDB.type_name(move.type), ["Físico", "Especial", "Estado"][move.category], pp if pp >= 0 else move.pp, maximum if maximum >= 0 else move.pp, str(move.power) if move.power > 0 else "--", str(move.accuracy) if move.accuracy > 0 else "--", move.description]
