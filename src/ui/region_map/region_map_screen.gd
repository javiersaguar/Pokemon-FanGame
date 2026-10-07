class_name RegionMapScreen
extends ChoiceScreen
var destinations: Array[Dictionary] = []
static func open() -> void:
	var screen := RegionMapScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)
func _refresh() -> void:
	caption = "Destinos / %s" % str(GameState.world_config.get("names",{}).get("region","POR DEFINIR"))
	destinations = WorldTravel.destinations()
	choices.clear()
	notes.clear()
	for destination: Dictionary in destinations:
		choices.append(str(destination.get("name",destination.get("id",""))))
		notes.append("Visitado / %s\nA: volar si tienes la acción disponible." % str(destination.get("map","")))
	if destinations.is_empty(): choices.append("Sin destinos"); notes.append("Todavía no hay destinos de vuelo disponibles.")
	super._refresh()
	menu.set_disabled(0,destinations.is_empty())
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2: _refresh(); continue
		if index < 0: _done = true; closed.emit(); return
		var destination := destinations[page*ROWS+index]
		if await Dialogue.ask_yes_no("¿Volar a %s?" % str(destination.get("name",destination.get("id","")))):
			var error: Error = await WorldTravel.fly(StringName(destination.id))
			if error != OK: await Dialogue.say("No puedes volar a este destino ahora.")
			else: _done = true; closed.emit(); return
