extends SceneTree
## Capturas de pantallas reales, sin modificar sprites ni datos persistentes.
var screen: Control
var runtime: Control
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
	await process_frame
	quit.call_deferred()
