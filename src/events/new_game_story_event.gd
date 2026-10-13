class_name NewGameStoryEvent
extends MvpStoryEvent
## Inicio de Spain: camino propio a Moncloa, oferta por ID y tutorial portátil.
static func story_config() -> Dictionary:
	return JsonFile.read_dict("res://data/new_game_story.json")

func run() -> void:
	if str(param("stage", "professor")) == "intro":
		await intro()
		return
	if not GameState.flag(&"story_intro_done"):
		await intro()
	GameState.set_flag(&"story_bedroom_done")
	await laboratory()
	if not GameState.flag(&"starter_chosen"):
		if GameState.locke != null and not GameState.locke.pending.is_empty(): return
		var selected := await pick_starter()
		if selected < 0: return
		await receive_starter(selected)
	if not GameState.flag(&"starter_chosen"): return
	if not GameState.flag(&"rival_intro_done"):
		await rival()
	if GameState.flag(&"rival_intro_done"):
		await rewards()

func intro() -> void:
	if GameState.flag(&"story_intro_done"): return
	await super.intro()
	await say(str(story_config().directions))

func travel(_destination: String) -> void:
	# Las rutas de B se recorren andando. La intro no lleva al laboratorio de prueba.
	pass

func pick_starter() -> int:
	var labels := PackedStringArray()
	for id: StringName in DataDB.starter_ids():
		labels.append(DataDB.species(DataDB.starter(id)).name)
	return await Dialogue.ask(str(story_config().starter_prompt), labels, WorldNames.value(&"professor"))

func receive_starter(index: int) -> void:
	var event: StoryEvent = load("res://src/events/common/choose_starter_event.gd").new()
	event.source = source
	event.map = map
	event.player = player
	event.params = {"slot": DataDB.starter_ids()[index], "index": index + 1}
	await event.run()

func say(text: String, values: Dictionary = {}) -> void:
	if text.begins_with("¡Bienvenido al mundo Pokémon!"):
		text = str(story_config().opening)
	if text == "Ya puedes salir a explorar. La enfermera y la tienda están en la sala de pruebas.":
		text = str(story_config().after)
	await super.say(text, values)
