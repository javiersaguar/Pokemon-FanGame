extends SceneTree
## Genera assets/arte/paleta.gpl y assets/arte/paleta.png a partir de
## assets/arte/paleta.json (la fuente de la paleta maestra).
##   godot --headless --path . -s res://tools/arte/paleta.gd

const SOURCE := "res://assets/arte/paleta.json"
const GPL := "res://assets/arte/paleta.gpl"
const PNG := "res://assets/arte/paleta.png"
const SWATCH := 16


func _initialize() -> void:
	var palette := load_palette(SOURCE)
	if palette.is_empty():
		push_error("paleta.gd: no se ha podido leer %s." % SOURCE)
		quit(1)
		return
	var lines := PackedStringArray(["GIMP Palette", "Name: %s" % palette["name"], "Columns: 6", "#"])
	var ramps: Array = palette["ramps"]
	var widest := 0
	for ramp: Dictionary in ramps:
		widest = maxi(widest, (ramp["colors"] as Array).size())
		for i: int in ramp["colors"].size():
			var c: Color = ramp["colors"][i]
			lines.append("%3d %3d %3d\t%s" % [c.r8, c.g8, c.b8, ramp["names"][i]])
	var file := FileAccess.open(GPL, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	var img := Image.create_empty(widest * SWATCH, ramps.size() * SWATCH, false, Image.FORMAT_RGBA8)
	for row: int in ramps.size():
		var colors: Array = ramps[row]["colors"]
		for col: int in colors.size():
			img.fill_rect(Rect2i(col * SWATCH, row * SWATCH, SWATCH, SWATCH), colors[col])
	img.save_png(PNG)
	print("Paleta: %d colores en %d rampas → %s y %s" % [count(palette), ramps.size(), GPL, PNG])
	quit(0)


## {name, ramps: [{id, colors: Array[Color], names: Array[String]}]} en el orden del JSON.
static func load_palette(path: String) -> Dictionary:
	var raw := JsonFile.read_dict(path)
	if raw.is_empty():
		return {}
	var custom_names: Dictionary = raw.get("names", {})
	var ramps: Array = []
	var source: Dictionary = raw.get("ramps", {})
	for id: String in source:
		var colors: Array = []
		var names: Array = []
		for i: int in source[id].size():
			colors.append(Color(str(source[id][i])))
			var custom: Array = custom_names.get(id, [])
			names.append(custom[i] if i < custom.size() else "%s_%d" % [id, i + 1])
		ramps.append({"id": id, "colors": colors, "names": names})
	return {"name": raw.get("name", "Paleta"), "ramps": ramps}


static func count(palette: Dictionary) -> int:
	var total := 0
	for ramp: Dictionary in palette["ramps"]:
		total += (ramp["colors"] as Array).size()
	return total
