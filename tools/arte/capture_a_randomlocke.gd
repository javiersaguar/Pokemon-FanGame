extends SceneTree
## Captura las opciones de dificultad y el Caramelo Raro infinito desde las pantallas reales.

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	root.size = Vector2i(512, 384)
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	manager.register_main(main)
	manager._fade.hide()
	var candy := OS.get_cmdline_user_args().has("--candy")
	if candy:
		state.new_game({"mode": &"randomlocke", "randomlocke": {"settings": {"locke_rules": true, "level_cap": true}}})
		var ids: Array[StringName] = [&"rarecandy"]
		load("res://src/ui/bag/bag_screen.gd").call("choose_from", ids, "Mochila")
	else:
		state.reset()
		load("res://src/ui/widgets/choice_screen.gd").call("pick", "Dificultad", PackedStringArray(["Normal", "Difícil"]), PackedStringArray(["Niveles e IA habituales.", "Rivales con un 10 % más de nivel e IA +1."]))
	await process_frame
	await process_frame
	await create_timer(0.1).timeout
	var path := "res://docs/arte/comparativas/a_%s.png" % ("caramelos_infinitos" if candy else "modo_dificil")
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	print("Captura: ", path)
	quit()
