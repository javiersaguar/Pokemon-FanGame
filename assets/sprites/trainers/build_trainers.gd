extends SceneTree
## Monta los entrenadores Panchito con las piezas del pack 11 (fuera del repo,
## docs/arte/recursos_terceros.md): superpone las capas de cada receta
## (recetas.json) tal cual, sin reescalar ni dibujar nada.
##   godot --headless --path . -s res://assets/sprites/trainers/build_trainers.gd [-- --recursos=<ruta>] [-- --solo=<id>]

const DEFAULT_RESOURCES := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
const PACK := "11_character_customization_gen4/pokemon png/"
const RECIPES := "res://assets/sprites/trainers/recetas.json"
const OUTPUTS := {
	"frente": "res://assets/sprites/trainers/%s.png",
	"espalda": "res://assets/sprites/trainers/%s_back.png",
	"mapa": "res://assets/sprites/characters/%s.png",
	"correr": "res://assets/sprites/characters/%s_run.png",
}

var _resources := DEFAULT_RESOURCES
var _errors := 0


func _initialize() -> void:
	var only := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--recursos="):
			_resources = arg.get_slice("=", 1)
		elif arg.begins_with("--solo="):
			only = arg.get_slice("=", 1)
	var recipes: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RECIPES))
	var count := 0
	for id: String in recipes:
		if id.begins_with("_") or (only != "" and id != only):
			continue
		for view: String in OUTPUTS:
			if recipes[id].has(view):
				count += _build(OUTPUTS[view] % id, recipes[id][view])
	print("build_trainers: %d PNG, %d errores" % [count, _errors])
	quit(1 if _errors > 0 else 0)


func _build(out_path: String, layers: Array) -> int:
	var out: Image = null
	for layer: String in layers:
		var path := _resources.path_join(PACK + layer)
		var img := Image.load_from_file(path)
		if img == null:
			_errors += 1
			push_error("build_trainers: falta la capa '%s'" % path)
			return 0
		img.convert(Image.FORMAT_RGBA8)
		if out == null:
			out = Image.create_empty(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
		elif img.get_size() != out.get_size():
			_errors += 1
			push_error("build_trainers: '%s' mide %s y la base %s" % [layer, img.get_size(), out.get_size()])
			return 0
		out.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
	out.save_png(out_path)
	print("  %s (%dx%d)" % [out_path, out.get_width(), out.get_height()])
	return 1
