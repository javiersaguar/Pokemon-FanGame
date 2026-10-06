class_name PartyScreen
extends ChoiceScreen

static func open() -> void:
	var screen := PartyScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

static func pick_member(title := "Elige un Pokémon") -> int:
	var names := PackedStringArray()
	var details := PackedStringArray()
	var icons: Array[Texture2D] = []
	for p: Pokemon in GameState.party.members:
		names.append("%s / Nv%d" % [p.display_name(), p.level])
		details.append("PS %d/%d\n%s" % [p.current_hp, p.max_hp(), p.species().name])
		icons.append(UiTextures.pokemon_icon(p))
	return await ChoiceScreen.pick(title, names, details, icons)

func _refresh() -> void:
	caption = "Equipo / %s" % GameState.player_name
	choices.clear()
	notes.clear()
	images.clear()
	for p: Pokemon in GameState.party.members:
		choices.append("%s / Nv%d" % [p.display_name(), p.level])
		var held := DataDB.item(p.held_item).name if DataDB.has_item(p.held_item) else "Ninguno"
		notes.append("%s\nPS %d/%d\nEstado: %s\nObjeto: %s" % [p.species().name, p.current_hp, p.max_hp(), String(p.status) if p.status != &"" else "Bien", held])
		images.append(UiTextures.pokemon_icon(p))
	super._refresh()

func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2:
			_refresh()
			continue
		if index < 0:
			_done = true
			closed.emit()
			return
		var p: Pokemon = GameState.party.get_at(index)
		var action := await ChoiceScreen.pick(p.display_name(), ["Datos", "Mover", "Dar objeto", "Quitar objeto", "Acciones de campo", "Volver"])
		match action:
			0: await SummaryScreen.open(SceneManager.ui_layer, GameState.party.members, index)
			1:
				var target := await pick_member("Mover a la posición...")
				if target >= 0: GameState.party.move(index, target)
			2:
				var item := await BagScreen.pick_item(false)
				if item != &"":
					var error := PartyItems.equip(p, item)
					await Dialogue.say("Objeto equipado." if error == OK else "No se puede equipar: %s." % error_string(error))
			3:
				var error := PartyItems.take(p)
				await Dialogue.say("Objeto guardado en la mochila." if error == OK else "No se puede quitar: %s." % error_string(error))
			4: await _field_actions()
		_refresh()
		menu.select(clampi(index, 0, maxi(choices.size() - 1, 0)))

func _field_actions() -> void:
	var available := PackedStringArray()
	var actions: Array[StringName] = []
	var current_map: MapRoot = SceneManager.current_map
	if FieldActions.available(&"bike", current_map):
		available.append("Bicicleta")
		actions.append(&"bike")
	if available.is_empty():
		await Dialogue.say("No hay acciones de campo disponibles aquí.")
		return
	var index := await ChoiceScreen.pick("Acciones de campo", available)
	if index >= 0 and is_instance_valid(SceneManager.player):
		SceneManager.player.set_transport_mode(&"walk" if FieldActions.transport() == actions[index] else actions[index])
