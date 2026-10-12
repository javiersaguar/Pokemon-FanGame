class_name PCScreen
extends ChoiceScreen
var moving := PCStorage.NO_SLOT

static func open() -> void:
	var screen := PCScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

static func deposit_member(index: int, box: int, slot: int) -> Error:
	var p: Pokemon = GameState.party.get_at(index)
	if p == null or box < 0 or box >= GameState.pc.box_count() or slot < 0 or slot >= GameState.pc.box_size(): return ERR_INVALID_PARAMETER
	if GameState.pc.get_pokemon(box, slot) != null: return ERR_ALREADY_EXISTS
	if GameState.party.size() <= 1 or (not p.is_fainted() and GameState.party.able_count() <= 1): return ERR_UNAVAILABLE
	GameState.pc.set_pokemon(box, slot, p)
	GameState.party.remove_at(index)
	return OK

static func withdraw_member(box: int, slot: int) -> Error:
	var p: Pokemon = GameState.pc.get_pokemon(box, slot)
	if p == null: return ERR_DOES_NOT_EXIST
	if GameState.party.is_full(): return ERR_OUT_OF_MEMORY
	GameState.party.add(p)
	GameState.pc.take(box, slot)
	return OK

func _refresh() -> void:
	caption = "PC / %s%s" % [GameState.pc.box_name(GameState.pc.current_box), " / moviendo" if moving != PCStorage.NO_SLOT else ""]
	choices.clear()
	notes.clear()
	images.clear()
	for slot: int in GameState.pc.box_size():
		var p: Pokemon = GameState.pc.get_pokemon(GameState.pc.current_box, slot)
		choices.append("%02d / %s" % [slot + 1, p.display_name() if p else "Vacío"])
		notes.append("%s / Nv%d\nPS %d/%d\nObjeto: %s" % [p.species().name, p.level, p.current_hp, p.max_hp(), DataDB.item(p.held_item).name if DataDB.has_item(p.held_item) else "Ninguno"] if p else "A: depositar desde el equipo. Al mover, A intercambia con este hueco.")
		images.append(UiTextures.pokemon_icon(p) if p else null)
	super._refresh()
	hint.text = "Izq/Der: huecos / C: dejar o coger / B: volver"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"menu") and menu.is_choosing and Engine.get_process_frames() != menu._active_frame:
		get_viewport().set_input_as_handled()
		menu._finish(-3)
	else: super._unhandled_input(event)

func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2: _refresh(); continue
		if index == -3:
			var action := await ChoiceScreen.pick("PC", ["Dejar un Pokémon", "Coger un Pokémon", "Caja anterior", "Caja siguiente", "Elegir caja", "Renombrar caja", "Cancelar movimiento", "Volver"])
			match action:
				0: await _deposit_from_party()
				1: await _withdraw_to_party()
				2, 3: GameState.pc.current_box = wrapi(GameState.pc.current_box + (-1 if action == 2 else 1), 0, GameState.pc.box_count()); page = 0
				4:
					var names := PackedStringArray()
					for box: int in GameState.pc.box_count(): names.append(GameState.pc.box_name(box))
					var chosen := await ChoiceScreen.pick("Elegir caja", names)
					if chosen >= 0: GameState.pc.current_box = chosen; page = 0
				5:
					var name := await NameKeyboard.ask(SceneManager.ui_layer,"Nombre de la caja",GameState.pc.box_name(GameState.pc.current_box),true,12)
					if not name.strip_edges().is_empty(): GameState.pc.rename_box(GameState.pc.current_box,name)
				6: moving = PCStorage.NO_SLOT
			_refresh()
			continue
		if index < 0:
			if moving != PCStorage.NO_SLOT: moving = PCStorage.NO_SLOT; _refresh(); continue
			_done = true
			closed.emit()
			return
		var slot := page * ROWS + index
		var box: int = GameState.pc.current_box
		var p: Pokemon = GameState.pc.get_pokemon(box,slot)
		if moving != PCStorage.NO_SLOT:
			GameState.pc.move(moving.x,moving.y,box,slot)
			moving = PCStorage.NO_SLOT
		elif p == null:
			var member := await PartyScreen.pick_member("Depositar en el PC")
			if member >= 0:
				var error := deposit_member(member,box,slot)
				if error != OK: await Dialogue.say("No puedes depositarlo aquí. Conserva al menos un Pokémon capaz de combatir.")
		else:
			var action := await ChoiceScreen.pick(p.display_name(), ["Datos", "Retirar", "Mover", "Liberar", "Volver"])
			match action:
				0: await SummaryScreen.open(SceneManager.ui_layer,[p],0)
				1:
					if withdraw_member(box,slot) != OK: await Dialogue.say("El equipo está lleno.")
				2: moving = Vector2i(box,slot)
				3:
					if await Dialogue.ask_yes_no("¿Liberar a %s? No podrás recuperarlo." % p.display_name()):
						if await Dialogue.ask_yes_no("¿Confirmas que quieres liberarlo?"): GameState.pc.release(box,slot)
		_refresh()
		menu.select(index)


func _deposit_from_party() -> void:
	var member := await PartyScreen.pick_member("Dejar en el PC")
	if member < 0:
		return
	var p: Pokemon = GameState.party.get_at(member)
	if p == null:
		return
	if GameState.party.size() <= 1 or (not p.is_fainted() and GameState.party.able_count() <= 1):
		await Dialogue.say("Conserva al menos un Pokémon capaz de combatir.")
		return
	if GameState.pc.is_full():
		await Dialogue.say("El PC está lleno.")
		return
	var placed: Vector2i = GameState.pc.deposit(p)
	if placed == PCStorage.NO_SLOT:
		await Dialogue.say("No hay hueco libre.")
		return
	GameState.party.remove_at(member)
	GameState.pc.current_box = placed.x
	await Dialogue.say("%s se ha quedado en %s." % [p.display_name(), GameState.pc.box_name(placed.x)])


func _withdraw_to_party() -> void:
	var names := PackedStringArray()
	var slots: Array[Vector2i] = []
	for slot: int in GameState.pc.box_size():
		var p: Pokemon = GameState.pc.get_pokemon(GameState.pc.current_box, slot)
		if p == null:
			continue
		names.append("%s / Nv%d" % [p.display_name(), p.level])
		slots.append(Vector2i(GameState.pc.current_box, slot))
	if names.is_empty():
		await Dialogue.say("Esta caja está vacía.")
		return
	names.append("Volver")
	var pick := await ChoiceScreen.pick("Coger de %s" % GameState.pc.box_name(GameState.pc.current_box), names)
	if pick < 0 or pick >= slots.size():
		return
	if withdraw_member(slots[pick].x, slots[pick].y) != OK:
		await Dialogue.say("El equipo está lleno.")
