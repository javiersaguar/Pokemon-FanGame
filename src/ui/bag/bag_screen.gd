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
	return await choose_from(ids, "Mochila")

static func choose_from(ids: Array[StringName], title: String, prices := false, shop_id: StringName = &"") -> StringName:
	var names := PackedStringArray()
	var notes := PackedStringArray()
	var icons: Array[Texture2D] = []
	for id: StringName in ids:
		var item := DataDB.item(id)
		var count: int = ShopTransactions.price(shop_id, id) if prices else GameState.bag.count(id)
		names.append("%s / %d%s" % [item.name, count, " ₽" if prices else ""])
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
	var action := await ChoiceScreen.pick(item.name, ["Usar", "Dar", "Tirar", "Volver"])
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
				var error := FieldItemUse.use(id, p, move)
				await Dialogue.say("Objeto utilizado." if error == OK else "No tendría efecto.")
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
