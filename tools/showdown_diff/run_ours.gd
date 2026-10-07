extends SceneTree
## Juega en nuestro BattleEngine los combates de tools/showdown_diff (ver README):
##   godot --headless --path . -s res://tools/showdown_diff/run_ours.gd -- --specs=<json> --out=<json>
##   godot --headless --path . -s res://tools/showdown_diff/run_ours.gd -- --capabilities=<json>
## La lógica está en ours_runner.gd, que se carga cuando ya existen los autoloads (DataDB).


func _initialize() -> void:
	await process_frame
	var args := {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and "=" in arg:
			args[arg.substr(2, arg.find("=") - 2)] = arg.substr(arg.find("=") + 1)
	var runner: Script = load("res://tools/showdown_diff/ours_runner.gd")
	var code := 0
	if args.has("capabilities"):
		code = runner.call("dump_capabilities", args["capabilities"])
	elif args.has("specs") and args.has("out"):
		code = runner.call("run_file", args["specs"], args["out"])
	else:
		printerr("Uso: run_ours.gd -- --specs=<json> --out=<json> | --capabilities=<json>")
		code = 2
	quit(code)
