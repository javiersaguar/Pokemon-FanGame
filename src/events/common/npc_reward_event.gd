extends StoryEvent
## Objeto de cortesía configurable; resolución R.2 y una entrega por partida.
func run() -> void:
	var rewards := JsonFile.read_dict("res://data/npc_rewards.json")
	var cfg: Dictionary = rewards.get(str(param("reward_id","")),{})
	if cfg.is_empty(): return
	var flag := StringName(cfg.get("flag",""))
	if flag == &"": return
	if GameState.flag(flag):
		await Dialogue.say("¡Que te vaya bien! Ya te di el objeto de cortesía.",source_entity())
		return
	var placement := StringName(cfg.get("placement",""))
	var item := DataDB.placed_item(placement,&"")
	# Conserva las ROM anteriores al cambio del nombre de este NPC.
	if item == &"" and cfg.has("legacy_placement"):
		item = DataDB.placed_item(StringName(cfg.legacy_placement),&"")
	if item == &"": item = StringName(DataDB.item_placements().get(String(placement),""))
	var quantity := int(cfg.get("quantity",0))
	if not DataDB.has_item(item) or quantity <= 0: return
	if not await Dialogue.ask_yes_no("Tengo un objeto de cortesía. ¿Lo quieres?",source_entity()): return
	if GameState.bag.count(item)+quantity > Bag.MAX_COUNT:
		await Dialogue.say("No te cabe. Vuelve cuando tengas espacio.",source_entity())
		return
	if GameState.bag.add(item,quantity) != quantity: return
	GameState.set_flag(flag)
	AudioManager.play_se(&"menu_accept")
	await Dialogue.say("¡{player} ha recibido {item}!",source_entity(),{"item":DataDB.item(item).name if quantity == 1 else "%d %s" % [quantity,DataDB.item(item).name_plural]})
