extends SceneTree
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await process_frame
	root.size = Vector2i(512,384)
	var args := OS.get_cmdline_user_args()
	var id := args[0] if not args.is_empty() else "rajoy"
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	var manager = root.get_node("SceneManager")
	manager.register_main(main)
	manager._fade.hide()
	var battle := args.size() > 1 and args[1] == "battle"
	if battle:
		var screen = load("res://src/battle/scene/battle_entry_transition.gd").new()
		screen.kind = &"trainer"
		screen.info = {"trainers":[load("res://src/battle/engine/battle_setup.gd").trainer_info(StringName(id))]}
		root.add_child(screen)
		screen.set_progress(0.4)
	else:
		var screen = load("res://src/ui/playtest/character_art_preview.gd").new()
		screen.art_id = StringName(id)
		screen.walking = false
		manager.push_menu(screen)
	await process_frame
	await create_timer(0.1).timeout
	var path := "res://docs/arte/comparativas/personaje_%s%s.png" % [id,"_entrada" if battle else ""]
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	print("Captura: ",path)
	quit()
