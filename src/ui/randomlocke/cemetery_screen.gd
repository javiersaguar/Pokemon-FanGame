class_name CemeteryScreen
extends ChoiceScreen
var snapshot: Dictionary = {}
var records: Array = []
static func open(state: Dictionary = {}) -> void:
	var screen := CemeteryScreen.new()
	screen.snapshot = state.duplicate(true) if not state.is_empty() else (GameState.locke.rules.snapshot() if GameState.locke != null else {})
	SceneManager.push_menu(screen)
	await screen.chosen
	SceneManager.pop_menu(screen)
func _ready() -> void:
	records = snapshot.get("cemetery",[]).duplicate(true)
	caption = "Cementerio / %d" % records.size()
	for grave: Dictionary in records:
		var id := StringName(grave.get("species",""))
		var name_text := str(grave.get("nickname",""))
		if name_text.is_empty(): name_text = DataDB.species(id).name if DataDB.has_species(id) else str(id)
		choices.append("%s / Nv. %d" % [name_text,int(grave.get("level",1))])
		notes.append("%s\n%s\nZona: %s\nRival: %s" % [DataDB.species(id).name if DataDB.has_species(id) else str(id),str(grave.get("epitaph","")),str(grave.get("zone_id","--")),str(grave.get("opponent","--"))])
		images.append(UiTextures.pokemon_icon(Pokemon.from_dict(grave)))
	super._ready()
	if records.is_empty(): _body.text = "Todavía no hay Pokémon en el Cementerio."
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2:
			_refresh()
			continue
		if index < 0:
			_done = true
			chosen.emit(-1)
			return
		await Dialogue.say(str(records[page*ROWS+index].get("epitaph","")))
