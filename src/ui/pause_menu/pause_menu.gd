class_name PauseMenu
extends MenuScreen
const LABELS := ["Volver", "Guardar", "Cargar partida", "Menú inicial", "Equipo", "Mochila", "Pokédex", "Opciones", "PC", "Tarjeta", "Mapa"]
const SCREENS := {4: &"PartyScreen", 5: &"BagScreen", 6: &"PokedexScreen", 8: &"PCScreen", 9: &"TrainerCardScreen", 10: &"RegionMapScreen"}

func _ready() -> void:
	heading.text = "Pausa / %s" % GameState.player_name
	menu = make_menu(LABELS, Rect2(14, 35, 230, 132), 2)
	for index: int in SCREENS:
		menu.set_disabled(index, GlobalClasses.find(SCREENS[index]) == null)
	run.call_deferred()

func run() -> void:
	while is_inside_tree():
		var choice := await menu.choose()
		match choice:
			-1, 0:
				SceneManager.pop_menu(self)
				return
			1:
				var slot := await SaveSlotsScreen.choose(&"save", SaveManager.current_slot())
				if slot > 0:
					var error := SaveManager.save_game(slot)
					await Dialogue.say("Partida guardada." if error == OK else "No se pudo guardar: %s." % error_string(error))
			2:
				var slot := await SaveSlotsScreen.choose()
				if slot > 0:
					_runtime().load_from_pause(slot, self)
					return
			3:
				if await Dialogue.ask_yes_no("¿Volver al menú inicial? El progreso sin guardar se perderá."):
					SceneManager.pop_menu(self)
					SceneManager.go_to_title()
					return
			7:
				var options := OptionsScreen.new()
				SceneManager.push_menu(options)
				await options.closed
				SceneManager.pop_menu(options)
			_:
				if SCREENS.has(choice):
					await GlobalClasses.find(SCREENS[choice]).call(&"open")

func _runtime() -> UiRuntime:
	for node: Node in SceneManager.ui_layer.get_children():
		if node is UiRuntime: return node
	return null
