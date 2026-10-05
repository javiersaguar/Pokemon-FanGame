extends RefCounted
## Lógica del validador de arte (Fase A.8), compartida por tools/arte/validar.gd
## y por tests/ui/test_arte.gd. Revisa los PNG de assets/ con las reglas de
## tools/arte/reglas.json: tamaño canónico y, si es arte propio, colores de la
## paleta maestra.

const RULES_PATH := "res://tools/arte/reglas.json"
const PALETTE_PATH := "res://assets/arte/paleta.json"
const ROOT := "res://assets/"
const PaletteTool := preload("res://tools/arte/paleta.gd")

var errors: PackedStringArray = []
var warnings: PackedStringArray = []
var checked := 0

var _rules: Dictionary
var _palette: Dictionary = {}


## Revisa todo assets/. Devuelve false si no se pueden leer las reglas o la paleta.
func run(root := ROOT) -> bool:
	_rules = JsonFile.read_dict(RULES_PATH)
	for ramp: Dictionary in PaletteTool.load_palette(PALETTE_PATH).get("ramps", []):
		for color: Color in ramp["colors"]:
			_palette[_key(color)] = true
	if _rules.is_empty() or _palette.is_empty():
		return false
	for path: String in _png_files(root):
		_check(path)
	return true


func _check(path: String) -> void:
	if _starts_with_any(path, _rules.get("exclude", [])):
		return
	checked += 1
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		_fail(path, "no se puede leer")
		return
	var size := Vector2i(img.get_width(), img.get_height())
	var placeholder := _starts_with_any(path, _rules.get("placeholder", []))
	var pack_exceptions: Dictionary = _rules.get("pack_exceptions", {})
	var rule := _rule_for(path)
	if rule.is_empty():
		_warn(path, "sin regla de tamaño (añádela a tools/arte/reglas.json)")
	else:
		var problem := _size_problem(size, rule)
		if problem != "":
			if placeholder:
				_warn(path, "placeholder: " + problem)
			elif pack_exceptions.has(path):
				_warn(path, "%s (%s)" % [problem, pack_exceptions[path]])
			else:
				_fail(path, problem)
	if placeholder or _starts_with_any(path, _rules.get("third_party", [])):
		return
	var outside := _colors_outside_palette(img)
	if outside > 0:
		_fail(path, "%d colores fuera de la paleta maestra" % outside)


func _size_problem(size: Vector2i, rule: Dictionary) -> String:
	if rule.has("size"):
		var exact := _vec(rule["size"])
		return "" if size == exact else "mide %s y debe medir %s" % [_fmt(size), _fmt(exact)]
	if rule.has("sizes"):
		for option: Array in rule["sizes"]:
			if size == _vec(option):
				return ""
		return "mide %s; tamaños válidos: %s" % [_fmt(size), ", ".join(rule["sizes"].map(func(o: Array) -> String: return _fmt(_vec(o))))]
	if rule.has("grid"):
		var grid := _vec(rule["grid"])
		if size.x > 0 and size.y > 0 and size.x % grid.x == 0 and size.y % grid.y == 0 \
				and size.x / grid.x == size.y / grid.y:
			return ""
		return "mide %s y no es una rejilla de %d×%d cuadros cuadrados" % [_fmt(size), grid.x, grid.y]
	var frames: Array = rule.get("frames", [rule["frame"]] if rule.has("frame") else [])
	if rule.has("multiple_of"):
		frames = [rule["multiple_of"]]
	if frames.is_empty():
		return ""
	for option: Array in frames:
		var frame := _vec(option)
		if size.x % frame.x == 0 and size.y % frame.y == 0 and size.x > 0 and size.y > 0:
			return ""
	return "mide %s y no es múltiplo de %s" % [_fmt(size), " ni de ".join(frames.map(func(o: Array) -> String: return _fmt(_vec(o))))]


func _colors_outside_palette(img: Image) -> int:
	var seen: Dictionary = {}
	for y: int in img.get_height():
		for x: int in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a8 == 0:
				continue
			var key := _key(c)
			if not _palette.has(key):
				seen[key] = true
	return seen.size()


func _rule_for(path: String) -> Dictionary:
	var best: Dictionary = {}
	var best_len := -1
	for rule: Dictionary in _rules.get("rules", []):
		var prefix := str(rule["path"])
		if path.begins_with(prefix) and prefix.length() > best_len:
			best = rule
			best_len = prefix.length()
	return best


func _png_files(dir_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	for sub: String in DirAccess.get_directories_at(dir_path):
		out.append_array(_png_files(dir_path + sub + "/"))
	for file: String in DirAccess.get_files_at(dir_path):
		if file.get_extension().to_lower() == "png":
			out.append(dir_path + file)
	return out


func _fail(path: String, reason: String) -> void:
	errors.append("%s: %s" % [path, reason])


func _warn(path: String, reason: String) -> void:
	warnings.append("%s: %s" % [path, reason])


static func _starts_with_any(path: String, prefixes: Array) -> bool:
	for prefix: Variant in prefixes:
		if path.begins_with(str(prefix)):
			return true
	return false


static func _key(c: Color) -> int:
	return (c.r8 << 16) | (c.g8 << 8) | c.b8


static func _vec(pair: Array) -> Vector2i:
	return Vector2i(int(pair[0]), int(pair[1]))


static func _fmt(v: Vector2i) -> String:
	return "%d×%d" % [v.x, v.y]
