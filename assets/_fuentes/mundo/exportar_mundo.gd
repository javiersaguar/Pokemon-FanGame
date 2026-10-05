extends SceneTree
## Exporta el arte del mundo dibujado a mano en texto (assets/_fuentes/mundo/*.px2)
## a PNG a ×2 (vecino más próximo), la escala de los packs (docs/arte/BIBLIA.md §2).
## Mismo formato que los .px del Agente 3 (tools/arte/exportar.gd: @leyenda con
## colores de la paleta maestra, @salida y el dibujo después de ---); la extensión
## distinta evita que su exportador, que saca los .px a 1:1, los pise.
##   godot --headless --path . -s res://assets/_fuentes/mundo/exportar_mundo.gd

const SOURCES := "res://assets/_fuentes/mundo/"
const SCALE := 2

var _colors := {}
var _errors := 0


func _initialize() -> void:
	var palette_tool: GDScript = load("res://tools/arte/paleta.gd")
	var palette: Dictionary = palette_tool.call(&"load_palette", "res://assets/arte/paleta.json")
	for ramp: Dictionary in palette.get("ramps", []):
		for i: int in ramp["colors"].size():
			_colors[ramp["names"][i]] = ramp["colors"][i]
	var count := 0
	for file: String in DirAccess.get_files_at(SOURCES):
		if file.get_extension() == "px2":
			count += _export(SOURCES + file)
	print("Exportados %d PNG del mundo, %d errores." % [count, _errors])
	quit(1 if _errors > 0 else 0)


func _export(path: String) -> int:
	var legend := {".": Color(0, 0, 0, 0)}
	var outputs := PackedStringArray()
	var rows := PackedStringArray()
	var in_drawing := false
	for raw: String in FileAccess.get_file_as_string(path).split("\n"):
		var line := raw.strip_edges(false, true)
		if in_drawing:
			if line != "":
				rows.append(line)
		elif line.strip_edges() == "---":
			in_drawing = true
		elif line.begins_with("@leyenda"):
			_parse_legend(line.substr(8), legend, path)
		elif line.begins_with("@salida"):
			outputs.append(line.substr(7).strip_edges())
	if rows.is_empty() or outputs.is_empty():
		return _fail(path, "falta el dibujo (después de ---) o @salida")
	var width := rows[0].length()
	var img := Image.create_empty(width, rows.size(), false, Image.FORMAT_RGBA8)
	for y: int in rows.size():
		if rows[y].length() != width:
			return _fail(path, "la fila %d no mide %d" % [y + 1, width])
		for x: int in width:
			if not legend.has(rows[y][x]):
				return _fail(path, "el símbolo '%s' (fila %d) no está en la leyenda" % [rows[y][x], y + 1])
			img.set_pixel(x, y, legend[rows[y][x]])
	img.resize(width * SCALE, rows.size() * SCALE, Image.INTERPOLATE_NEAREST)
	for output: String in outputs:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
		img.save_png(output)
	return outputs.size()


## "a = piedra_1@70  b = hierba_2" → {"a": Color con alfa 70/255, "b": Color}
func _parse_legend(text: String, into: Dictionary, path: String) -> void:
	var tokens := text.replace("=", " = ").split(" ", false)
	for i: int in range(0, tokens.size() - 2, 3):
		var value := tokens[i + 2]
		if value == "transparente":
			into[tokens[i]] = Color(0, 0, 0, 0)
			continue
		var color_name := value.get_slice("@", 0)
		if not _colors.has(color_name):
			_fail(path, "el color '%s' no está en la paleta" % color_name)
			continue
		var color: Color = _colors[color_name]
		if value.contains("@"):
			color.a8 = int(value.get_slice("@", 1))
		into[tokens[i]] = color


func _fail(path: String, reason: String) -> int:
	_errors += 1
	print("✗ %s: %s" % [path, reason])
	return 0
