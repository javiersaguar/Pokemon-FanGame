class_name MoveLessonScreen
extends ChoiceScreen
## El mundo decide dónde se ofrecen las lecciones. Esta pantalla no cobra ni inventa tutores.
var move_ids: Array[StringName] = []
func _ready() -> void:
	for id: StringName in move_ids:
		choices.append(DataDB.move(id).name)
		notes.append(LearnMoveScreen.describe(id))
	super._ready()
static func replacement(p: Pokemon, id: StringName) -> int:
	if p.moves.size() < Pokemon.MAX_MOVES:
		return -1 if await Dialogue.ask_yes_no("¿Aprender %s?" % DataDB.move(id).name) else -2
	var moves: Array[Dictionary] = []
	for slot: MoveSlot in p.moves: moves.append({"id":slot.id,"name":slot.data().name,"pp":slot.pp,"max_pp":slot.max_pp()})
	var chosen := await LearnMoveScreen.choose({"moves":moves,"move_id":id,"move_name":DataDB.move(id).name})
	return chosen if chosen >= 0 else -2
static func use_machine(p: Pokemon, item_id: StringName) -> Error:
	var id := MoveLessons.machine_move(item_id)
	if id == &"" or not MoveLessons.can_learn_machine(p.species_id,id) or p.has_move(id): return ERR_UNAVAILABLE
	var replace_index := await replacement(p,id)
	if replace_index == -2: return ERR_SKIP
	return FieldItemUse.use(item_id,p,replace_index)
static func open_recordador(p: Pokemon) -> bool:
	return await _open(p,MoveLessons.relearnable(p),"Recordar movimiento")
static func open_tutor(p: Pokemon, offered: Array[StringName]) -> bool:
	var available: Array[StringName] = []
	for id: StringName in offered:
		if MoveLessons.can_tutor(p,id): available.append(id)
	return await _open(p,available,"Tutor de movimientos",true)
static func _open(p: Pokemon, available: Array[StringName], title: String, tutor := false) -> bool:
	if available.is_empty(): return false
	if GameState.locke != null and GameState.locke.rules.snapshot().deaths.has(p.uid): return false
	var screen := MoveLessonScreen.new()
	screen.caption = title; screen.move_ids = available
	SceneManager.push_menu(screen)
	var index: int = await screen.chosen
	SceneManager.pop_menu(screen)
	if index < 0: return false
	var replace_index := await replacement(p,available[index])
	if replace_index == -2: return false
	return MoveLessons.use_tutor(p,available[index],replace_index) if tutor else MoveLessons.teach(p,available[index],replace_index)
