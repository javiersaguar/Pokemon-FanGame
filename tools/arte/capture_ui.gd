extends SceneTree
## Capturas de pantallas reales, sin modificar sprites ni datos persistentes.
var screen: Control
var runtime: Control
var main: Node
var case_name := "options"

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	await process_frame
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--screen="):
			case_name = arg.trim_prefix("--screen=")
	root.size = Vector2i(512, 384)
	if case_name in ["shift", "forced"]:
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		screen.fast = true
		root.add_child(screen)
		screen._box.text_speed = 0
		screen._driver = load("res://src/battle/scene/dev/fake_battle.gd").new({}, 7)
		screen._background.set_environment(&"grass")
		screen.get_node("Canvas/Curtain").hide()
		screen._ask_player({"kind": &"switch", "reason": &"shift" if case_name == "shift" else &"faint"})
	elif case_name.begins_with("title") or case_name in ["splash", "notice", "intro", "main_menu", "credits"]:
		if case_name == "credits":
			screen = load("res://src/ui/title/title_screen.gd").new()
			screen.skip_sequence = true
		else:
			screen = load("res://src/ui/title/title_screen.gd").new()
			screen.skip_sequence = true
			if case_name.begins_with("title_"):
				screen.logo_variant = int(case_name.trim_prefix("title_"))
		root.add_child(screen)
		if case_name == "credits":
			screen.show_subscreen(load("res://src/ui/title/credits_screen.gd").new())
		if case_name in ["splash", "notice", "intro", "main_menu"]:
			screen.set_stage(&"menu" if case_name == "main_menu" else StringName(case_name))
		await create_timer(0.35).timeout
	elif case_name in ["slots", "pause"]:
		var manager = root.get_node("SceneManager")
		var state = root.get_node("GameState")
		var saves = root.get_node("SaveManager")
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		manager.register_main(main)
		await manager.start_new_game(&"", &"", {"slot": 1})
		state.player_name = "Javier"
		await RenderingServer.frame_post_draw
		manager.world_snapshot = manager.capture_screen()
		saves.save_game(1)
		var settings = load("res://src/randomizer/randomizer_settings.gd").from_preset("clasico")
		var rom = load("res://src/randomizer/randomizer.gd").generate(42, settings)
		await manager.start_randomlocke(rom, 2, false)
		state.player_name = "Javi"
		await RenderingServer.frame_post_draw
		manager.world_snapshot = manager.capture_screen()
		saves.save_game(2)
		screen = load("res://src/ui/saves/save_slots_screen.gd" if case_name == "slots" else "res://src/ui/pause_menu/pause_menu.gd").new()
		manager.push_menu(screen)
	elif case_name == "name":
		screen = load("res://src/ui/name/name_keyboard.gd").new()
		screen.kind = &"player"
		screen.initial = "Javier"
		root.add_child(screen)
	else:
		screen = load("res://src/ui/options/options_screen.gd").new()
		root.add_child(screen)
		runtime = load("res://src/ui/ui_runtime.gd").new()
		root.add_child(runtime)
		if case_name == "run_notice":
			runtime._run_changed(true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "res://docs/arte/comparativas/a3_%s.png" % case_name
	image.save_png(path)
	print("Captura: ", path)
	screen.queue_free()
	if runtime:
		runtime.queue_free()
	if main:
		root.get_node("SceneManager")._leave_game()
		main.queue_free()
	await process_frame
	quit.call_deferred()
