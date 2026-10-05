class_name MvpStoryEvent
extends StoryEvent
## Historia portátil. Mapas y todos los IDs vienen de world.mvp_story/DataDB.

func config() -> Dictionary:
	return GameState.world_config.get("mvp_story", {})

func run() -> void:
	match str(param("stage", "professor")):
		"intro": await intro()
		"bedroom": await bedroom()
		"laboratory": await laboratory()
		"rival": await rival()
		"rewards": await rewards()
		"professor":
			if not GameState.flag(&"story_intro_done"):
				await intro()
			elif not GameState.flag(&"story_bedroom_done"):
				await say("Sal de tu habitación para venir al laboratorio de pruebas.")
			elif not GameState.flag(&"story_lab_intro_done"):
				await laboratory()
			elif not GameState.flag(&"starter_chosen"):
				await say("Elige una de las tres Poké Balls.")
			elif not GameState.flag(&"rival_intro_done"):
				await say("Tu rival te espera para el combate de iniciación.")
			else:
				await rewards()

func intro() -> void:
	if GameState.flag(&"story_intro_done"):
		return
	await say("¡Bienvenido al mundo Pokémon! Soy el profesor {professor}.", {"professor": config().get("professor_name", "POR DEFINIR")})
	var gender := await choose("¿Cómo quieres empezar?", PackedStringArray(["Chico", "Chica"]))
	GameState.player_gender = &"female" if gender == 1 else &"male"
	# Identidades explícitas en sala; flujo definitivo pide teclado de A3.
	GameState.player_name = str(param("player_name", "")).strip_edges()
	if GameState.player_name.is_empty():
		GameState.player_name = await request_name(&"player", GameState.player_name)
	GameState.rival_name = str(param("rival_name", "")).strip_edges()
	if GameState.rival_name.is_empty():
		GameState.rival_name = await request_name(&"rival", GameState.rival_name)
	await say("¡{player}, tu aventura empieza ahora! Tu rival se llama {rival}.")
	GameState.set_flag(&"story_intro_done")
	GameState.set_var(&"story_progress", 10)
	await travel("bedroom")

func bedroom() -> void:
	if not GameState.flag(&"story_intro_done") or GameState.flag(&"story_bedroom_done"):
		return
	await say("Sales de tu habitación. El profesor te espera en el laboratorio.")
	GameState.set_flag(&"story_bedroom_done")
	GameState.set_var(&"story_progress", 20)
	await travel("laboratory")

func laboratory() -> void:
	if not GameState.flag(&"story_bedroom_done") or GameState.flag(&"story_lab_intro_done"):
		return
	await say("En estas Poké Balls están {starter:starter_1}, {starter:starter_2} y {starter:starter_3}. Elige a tu compañero.")
	GameState.set_flag(&"story_lab_intro_done")
	GameState.set_var(&"story_progress", 30)

func rival_setup() -> BattleSetup:
	var index := str(GameState.var_int(&"starter"))
	var trainer_id := StringName(config().get("rival_by_starter", {}).get(index, ""))
	if trainer_id == &"" or not DataDB.has_trainer(trainer_id):
		return null
	return BattleSetup.trainer(trainer_id, {"can_lose": true, "locke_rules": false})

func rival() -> void:
	if not GameState.flag(&"starter_chosen") or GameState.flag(&"rival_intro_done"):
		return
	var setup := rival_setup()
	if setup == null or setup.foe_party.is_empty():
		push_warning("MvpStory: faltan datos del equipo rival para el inicial elegido.")
		return
	await say("¡{player}! Vamos a probar nuestros Pokémon.")
	var outcome: StringName = await battle(setup, {"tutorial": true})
	if outcome not in [SceneManager.OUTCOME_WIN, SceneManager.OUTCOME_LOSE]:
		return
	Cutscene.heal_party()
	GameState.set_flag(&"rival_intro_done")
	GameState.set_var(&"story_progress", 40)
	await say("Ya hemos terminado el combate de iniciación. El profesor te espera.")

func rewards() -> void:
	if not GameState.flag(&"rival_intro_done") or GameState.flag(&"story_rewards_done"):
		return
	if not GameState.flag(&"got_pokedex"):
		GameState.set_flag(&"got_pokedex")
		await say("Aquí tienes tu Pokédex. Registra a los Pokémon que encuentres.")
	var reward: Dictionary = config().get("reward", {})
	var quantity := int(reward.get("quantity", 0)) if reward.get("quantity") != null else 0
	if quantity <= 0:
		await say("La cantidad del regalo de Poké Balls está POR DEFINIR.")
		return
	var placement_id := StringName(reward.get("placement_id", ""))
	var base_item := StringName(DataDB.item_placements().get(String(placement_id), ""))
	var item := DataDB.placed_item(placement_id, base_item)
	if item == &"" or not DataDB.has_item(item):
		push_warning("MvpStory: falta la colocación del regalo '%s'." % placement_id)
		return
	if not await give_item(item, quantity):
		return
	GameState.set_flag(&"story_rewards_done")
	GameState.set_var(&"story_progress", 50)
	await say("Ya puedes salir a explorar. La enfermera y la tienda están en la sala de pruebas.")

# Tests sustituyen solo presentación, manteniendo eventos y motor reales.
func say(text: String, values: Dictionary = {}) -> void:
	await Dialogue.say(text, config().get("professor_name", "POR DEFINIR"), values)
func choose(text: String, options: PackedStringArray) -> int:
	return await Dialogue.ask(text, options, null, Dialogue.NO_CANCEL)
func request_name(kind: StringName, initial: String) -> String:
	return await Cutscene.request_name(kind, initial)
func travel(destination: String) -> void:
	var target: Dictionary = config().get(destination, {})
	if target.is_empty():
		return
	await Cutscene.teleport(StringName(target.get("map", "")), StringName(target.get("spawn", "default")))
func battle(setup: BattleSetup, context: Dictionary) -> StringName:
	return await SceneManager.start_battle(setup, context)
func give_item(item: StringName, quantity: int) -> bool:
	return await Cutscene.give_item(item, quantity)
