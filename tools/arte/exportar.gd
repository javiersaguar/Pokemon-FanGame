extends SceneTree
## Exporta el pixel art hecho a mano en texto (assets/_fuentes/**/*.px) a PNG.
## Cada píxel se elige a mano con un símbolo de la leyenda; los colores salen de
## la paleta maestra (assets/arte/paleta.json). Es la "exportación reproducible"
## de la Fase A.4 para el arte propio que se dibuja en texto.
##   godot --headless --path . -s res://tools/arte/exportar.gd
##
## Formato de un .px:
##   # comentario
##   @leyenda  . = transparente   a = ui_1   b = ui_2@200   (nombre de la paleta[@alfa])
##   @salida res://assets/sprites/ui/x.png              (una o varias)
##   @salida res://assets/sprites/ui/y.png  r=teja_4     (cambia símbolos solo en esa salida)
##   @frames 3                                           (opcional: el dibujo son N frames en horizontal)
##   ---
##   filas del dibujo (todas del mismo ancho)

const SOURCES := "res://assets/_fuentes/"
const PaletteTool := preload("res://tools/arte/paleta.gd")

var _colors: Dictionary = {}
var _errors := 0


func _initialize() -> void:
	for ramp: Dictionary in PaletteTool.load_palette("res://assets/arte/paleta.json").get("ramps", []):
		for i: int in ramp["colors"].size():
			_colors[ramp["names"][i]] = ramp["colors"][i]
	var count := 0
	for path: String in _files(SOURCES):
		count += _export(path)
	print("Exportados %d PNG, %d errores." % [count, _errors])
	quit(1 if _errors > 0 else 0)


func _export(path: String) -> int:
	var legend: Dictionary = {".": Color(0, 0, 0, 0)}
	var outputs: Array = []
	var rows := PackedStringArray()
	var in_drawing := false
	for raw: String in FileAccess.get_file_as_string(path).split("\n"):
		var line := raw.strip_edges(false, true)
		if in_drawing:
			if line != "":
				rows.append(line)
			continue
		line = line.strip_edges()
		if line == "---":
			in_drawing = true
		elif line.begins_with("@leyenda"):
			_parse_pairs(line.substr(8), legend, path)
		elif line.begins_with("@salida"):
			var parts := line.substr(7).strip_edges().split(" ", false, 1)
			var overrides: Dictionary = {}
			if parts.size() > 1:
				_parse_pairs(parts[1], overrides, path)
			outputs.append({"path": parts[0], "overrides": overrides})
	if rows.is_empty() or outputs.is_empty():
		_fail(path, "falta el dibujo (después de ---) o @salida")
		return 0
	var width := rows[0].length()
	for row: String in rows:
		if row.length() != width:
			_fail(path, "todas las filas tienen que medir %d (hay una de %d)" % [width, row.length()])
			return 0
	var done := 0
	for output: Dictionary in outputs:
		var symbols := legend.duplicate()
		symbols.merge(output["overrides"], true)
		var img := Image.create_empty(width, rows.size(), false, Image.FORMAT_RGBA8)
		for y: int in rows.size():
			for x: int in width:
				var symbol := rows[y][x]
				if not symbols.has(symbol):
					_fail(path, "el símbolo '%s' (fila %d) no está en la leyenda" % [symbol, y + 1])
					return done
				img.set_pixel(x, y, symbols[symbol])
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(str(output["path"]).get_base_dir()))
		img.save_png(output["path"])
		done += 1
	return done


## "a = ui_1   b = ui_2@200" → {"a": Color, "b": Color con alfa 200/255}
func _parse_pairs(text: String, into: Dictionary, path: String) -> void:
	var tokens := text.replace("=", " = ").split(" ", false)
	var i := 0
	while i + 2 < tokens.size():
		var symbol := tokens[i]
		var value := tokens[i + 2]
		if tokens[i + 1] != "=" or symbol.length() != 1:
			_fail(path, "leyenda mal escrita cerca de '%s'" % symbol)
			return
		if value == "transparente":
			into[symbol] = Color(0, 0, 0, 0)
		else:
			var name := value.get_slice("@", 0)
			if not _colors.has(name):
				_fail(path, "el color '%s' no está en la paleta" % name)
				return
			var color: Color = _colors[name]
			if value.contains("@"):
				color.a8 = int(value.get_slice("@", 1))
			into[symbol] = color
		i += 3


func _files(dir_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	if not DirAccess.dir_exists_absolute(dir_path):
		return out
	for sub: String in DirAccess.get_directories_at(dir_path):
		out.append_array(_files(dir_path + sub + "/"))
	for file: String in DirAccess.get_files_at(dir_path):
		if file.get_extension() == "px":
			out.append(dir_path + file)
	return out


func _fail(path: String, reason: String) -> void:
	_errors += 1
	print("✗ %s: %s" % [path, reason])
