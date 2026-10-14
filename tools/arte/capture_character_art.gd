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
	var battle := args.size() > 1 and args[1] in ["battle","duo"]
	var before := "--sin-arte" in args
	if battle:
		var screen = load("res://src/battle/scene/battle_entry_transition.gd").new()
		screen.kind = &"trainer"
		var trainers: Array = []
		for member: String in id.split("+"):
			var member_id := StringName(member)
			if root.get_node("DataDB").has_trainer(member_id):
				var info: Dictionary = load("res://src/battle/engine/battle_setup.gd").trainer_info(member_id)
				if before: info["art_id"] = &""
				trainers.append(info)
			else:
				var art := CharacterArt.info(member_id)
				if art.is_empty():
					push_error("No hay entrenador ni atlas para '%s'." % member)
					quit(1)
					return
				var art_name := str(art.get("name", member))
				trainers.append({"id":member,"art_id":member,"display_name":art_name,
					"name":art_name.trim_prefix("Zona Gemelos: ")})
		screen.info = {"trainers":trainers}
		root.add_child(screen)
		screen.set_progress(0.4)
	else:
		var screen = load("res://src/ui/playtest/character_art_preview.gd").new()
		screen.art_id = StringName(id)
		screen.walking = false
		manager.push_menu(screen)
	await process_frame
	await create_timer(0.1).timeout
	var path := "res://docs/arte/comparativas/personaje_%s%s%s.png" % [id,"_antes" if before else "","_entrada" if battle else ""]
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	print("Captura: ",path)
	quit()
