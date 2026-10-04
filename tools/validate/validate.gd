extends SceneTree
## Validador de datos desde la línea de comandos (sale con código 1 si hay errores):
##   godot --headless --path . -s res://tools/validate/validate.gd


func _initialize() -> void:
	# Los autoloads (DataDB) existen a partir del primer frame; el validador se carga después.
	await process_frame
	var validator: Script = load("res://tools/validate/data_validator.gd")
	var result: Object = validator.call("run")
	print(result.call("report"))
	quit(1 if not (result.get("errors") as PackedStringArray).is_empty() else 0)
