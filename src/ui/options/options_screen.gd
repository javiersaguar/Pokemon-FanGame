class_name OptionsScreen
extends MenuScreen

func _ready() -> void:
	heading.text = "Opciones"
	panel(Rect2(8, 33, 240, 59))
	label("R / Y: alternar correr\nShift / B: correr (o andar si está activado)", Rect2(16, 42, 224, 42), Color("382a38"), 8)
	menu = make_menu([run_label(), "Volver"], Rect2(16, 105, 224, 48))
	run.call_deferred()

func run_label() -> String:
	return "Correr siempre: %s" % ("Sí" if GameState.always_run else "No")

func run() -> void:
	while is_inside_tree():
		var choice := await menu.choose()
		if choice != 0:
			closed.emit()
			return
		GameState.set_always_run(not GameState.always_run)
		(menu.get_child(0) as BattleButton).text = run_label()
