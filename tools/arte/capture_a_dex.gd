extends SceneTree
## Captura el primer y último folio de la Pokédex real para su revisión visual.

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
	state.reset()
	var last := OS.get_cmdline_user_args().has("--last")
	for id: StringName in ([&"pecharunt"] if last else [&"bulbasaur", &"ivysaur", &"venusaur"]):
		state.pokedex.mark_seen(id, true)
	var screen = load("res://src/ui/pokedex/pokedex_screen.gd").new()
	if last: screen.page = 170
	manager.push_menu(screen)
	await process_frame
	await process_frame
	await create_timer(0.1).timeout
	var suffix := "final" if last else "inicio"
	var path := "res://docs/arte/comparativas/a_pokedex_%s.png" % suffix
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	print("Captura: ", path, " / ", screen.species.size(), " especies")
	quit()
