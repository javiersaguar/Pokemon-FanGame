class_name PokedexScreen
extends ChoiceScreen
var species: Array[StringName] = []

static func open() -> void:
	var screen := PokedexScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _refresh() -> void:
	caption = "Pokédex / %d vistos / %d capt." % [GameState.pokedex.seen_count(), GameState.pokedex.caught_count()]
	if species.is_empty():
		species = DataDB.regional_dex()
		if species.is_empty(): species = DataDB.species_ids(false)
	choices.clear()
	notes.clear()
	images.clear()
	for id: StringName in species:
		var data := DataDB.species(id)
		var seen: bool = GameState.pokedex.is_seen(id)
		choices.append("%03d %s%s" % [DataDB.regional_number(id) if DataDB.regional_number(id) > 0 else data.num, data.name if seen else "???", " / C" if GameState.pokedex.is_caught(id) else ""])
		if seen:
			notes.append("%s\n%s\n%s" % [data.name, " / ".join(data.types.map(func(id: StringName) -> String: return DataDB.type_name(id))), "Capturado" if GameState.pokedex.is_caught(id) else "Visto"])
			var path := "res://assets/sprites/pokemon/icons/%s.png" % id
			var sheet := load(path) as Texture2D if ResourceLoader.exists(path) else null
			var icon := AtlasTexture.new()
			if sheet:
				icon.atlas = sheet
				icon.region = Rect2(0, 0, sheet.get_width() / 2, sheet.get_height())
			images.append(icon if sheet else null)
		else:
			notes.append("Aún no visto.")
			images.append(null)
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
		var id := species[page * ROWS + index]
		if not GameState.pokedex.is_seen(id): continue
		AudioManager.play_cry(id)
		await PokedexEntry.open(id)
