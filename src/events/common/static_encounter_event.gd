class_name StaticEncounterEvent
extends StoryEvent
## ID de datos y flag técnica compartida con el NPC; especie siempre de DataDB.
func run() -> void:
	var id := StringName(param("static_id", ""))
	if id == &"" or GameState.flag(StringName("static_done:" + String(id))):
		return
	var spec := DataDB.static_encounter(id)
	if spec.is_empty() or not (GameState.party is Party) or GameState.party.able_count() == 0:
		return
	var pokemon := Pokemon.from_spec(spec)
	if pokemon == null:
		return
	var outcome := await battle(BattleSetup.wild(pokemon),
		{"source": "static", "static_id": String(id)})
	if outcome in [SceneManager.OUTCOME_WIN, SceneManager.OUTCOME_CAUGHT]:
		GameState.set_flag(StringName("static_done:" + String(id)))

func battle(setup: BattleSetup, context: Dictionary) -> StringName:
	return await SceneManager.start_battle(setup, context)
