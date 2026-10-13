class_name BagScreen
extends MenuScreen
const POCKETS: Array[StringName] = [&"items", &"medicine", &"pokeballs", &"machines", &"berries", &"mail", &"battle", &"key"]
const NAMES := ["Objetos", "Medicinas", "Poké Balls", "MT/MO", "Bayas", "Correo", "Combate", "Objetos clave"]

static func open() -> void:
	var screen := BagScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

static func pick_item(include_keys := true, pocket: StringName = &"") -> StringName:
	var ids: Array[StringName] = []
	for id: StringName in GameState.bag.all_items():
		var item := DataDB.item(id)
		if (include_keys or not item.is_key_item()) and (pocket == &"" or item.pocket == pocket): ids.append(id)
	if FieldItemUse.infinite_candy(&"rarecandy") and &"rarecandy" not in ids and (pocket == &"" or pocket == &"medicine"):
		ids.append(&"rarecandy")
	return await choose_from(ids, "Mochila")

static func choose_from(ids: Array[StringName], title: String, prices := false, shop_id: StringName = &"") -> StringName:
	var names := PackedStringArray()
	var notes := PackedStringArray()
	var icons: Array[Texture2D] = []
	for id: StringName in ids:
		var item := DataDB.item(id)
		var count: int = ShopTransactions.price(shop_id, id) if prices else GameState.bag.count(id)
		names.append("%s / ∞" % item.name if not prices and FieldItemUse.infinite_candy(id) else "%s / %d%s" % [item.name, count, " ₽" if prices else ""])
		notes.append(item.description)
		icons.append(UiTextures.item(id))
	var index := await ChoiceScreen.pick(title, names, notes, icons)
	return ids[index] if index >= 0 else &""

func _ready() -> void:
	heading.text = "Mochila"
	menu = make_menu(NAMES, Rect2(14, 39, 228, 116), 2)
	run.call_deferred()

func run() -> void:
	while is_inside_tree():
		var pocket := await menu.choose()
		if pocket < 0:
			closed.emit()
			return
		while true:
			var item := await pick_item(true, POCKETS[pocket])
			if item == &"": break
			await _manage(item)

func _manage(id: StringName) -> void:
	var item := DataDB.item(id)
	var action := await ChoiceScreen.pick(item.name, ["Usar", "Volver"] if FieldItemUse.infinite_candy(id) else ["Usar", "Dar", "Tirar", "Volver"])
	if FieldItemUse.infinite_candy(id) and action != 0: return
	match action:
		0:
			if item.field_use == &"no_target":
				var error := FieldItemUse.use(id)
				await Dialogue.say("Objeto utilizado." if error == OK else "Este objeto no puede usarse aquí.")
			else:
				var index := await PartyScreen.pick_member()
				if index < 0: return
				var p: Pokemon = GameState.party.get_at(index)
				if item.pocket == &"machines":
					var learned := await MoveLessonScreen.use_machine(p,id)
					if learned != ERR_SKIP: await Dialogue.say("Movimiento aprendido." if learned == OK else "No tendría efecto.")
					return
				if item.effect == &"evolution":
					var target := EvolutionRules.item_target(p, id, {"time": Clock.period()})
					if target != &"": await EvolutionScreen.open(p, {"to": target, "method": "item"}, id)
					else: await Dialogue.say("No tendría efecto.")
					return
				var move := -1
				if item.effect == &"restore_pp" and not bool(item.param("all_moves", false)):
					var moves := PackedStringArray()
					for slot: MoveSlot in p.moves: moves.append("%s / %d/%d PP" % [slot.data().name, slot.pp, slot.max_pp()])
					move = await ChoiceScreen.pick("Movimiento", moves)
					if move < 0: return
				var before_level := p.level
				var error := FieldItemUse.use(id, p, move)
				await Dialogue.say("Objeto utilizado." if error == OK else "No tendría efecto.")
				if error == OK and item.effect == &"level_up" and p.level > before_level:
					for level: int in range(before_level + 1, p.level + 1):
						for learned: StringName in DataDB.moves_learned_at(p.species_id, level):
							if p.has_move(learned): continue
							if not p.try_learn(learned):
								var request := {"move_id": learned, "move_name": DataDB.move(learned).name, "moves": EngineDriver._moves_of(p)}
								var forgotten := await LearnMoveScreen.choose(request)
								if forgotten >= 0: p.replace_move(forgotten, learned)
					var evolution := EvolutionRules.level_up_evolution(p, {"time": Clock.period()})
					if not evolution.is_empty(): await EvolutionScreen.open(p, evolution)
		1:
			var index := await PartyScreen.pick_member("Dar a...")
			if index >= 0:
				var error := PartyItems.equip(GameState.party.get_at(index), id)
				await Dialogue.say("Objeto equipado." if error == OK else "No se puede dar este objeto.")
		2:
			if item.is_key_item():
				await Dialogue.say("Los objetos clave no se pueden tirar.")
				return
			var count := await QuantityPicker.pick("Tirar %s" % item.name, GameState.bag.count(id))
			if count > 0 and await Dialogue.ask_yes_no("¿Tirar %d unidades de %s?" % [count, item.name]): GameState.bag.remove(id, count)
