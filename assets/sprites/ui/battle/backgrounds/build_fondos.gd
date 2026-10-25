extends SceneTree
@warning_ignore_start("integer_division")
## Monta los fondos de combate de data/battle_backgrounds.json (Agente 4; respuesta 12 de Javier:
## "fondo con entorno y bases, como el bosque de Añil"; respuesta 24: "hacer igual cueva, agua,
## ciudad, interior y las versiones de noche"). Nunca dibuja arte:
##   1. Copia byte a byte los fondos del pack 10 (ORAS/XY para EBDX, 384×308) y, los que ese pack no
##      trae, los de Elite Battle: DX (pack 16), en backgrounds/<nombre>.png.
##   2. Copia byte a byte los elementos de EBDX (cielos de cada momento del día, sol, estrellas,
##      montañas, decorados, niebla, público...) en backgrounds/capas/<nombre>.png.
##   3. Compone cada frente (backgrounds/frente_*.png) superponiendo, sin reescalar, árboles del
##      pack 03 a ×1 (con el retoque de verdes del tileset, como en el mapa) y piezas que vienen a ×2
##      exacto (muebles de Akizakura16 y los .px2 a mano del proyecto), puestas a ×1 cogiendo un píxel
##      de cada bloque de 2×2: el mismo dibujo, a la escala del fondo.
##   4. forest.png (la ficha del Pokémon) = el fondo Field con el frente de hierba, como antes.
## Escribe la procedencia (archivo original y SHA-256) en data/battle_background_assets.json.
##   godot --headless --path . -s res://assets/sprites/ui/battle/backgrounds/build_fondos.gd [-- --recursos=<ruta> --solo=<composición>]

const DEFAULT_RESOURCES := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
const OUT := "res://assets/sprites/ui/battle/backgrounds/"
const LAYERS_OUT := OUT + "capas/"
const DATA := "res://data/battle_backgrounds.json"
const MANIFEST := "res://data/battle_background_assets.json"
const PACK10 := "10_fondos_combate/Battlebacks/"
const EBDX := "16_elite_battle_dx/Graphics/EBDX/Battlebacks/"
const TREES := "03_big_tree_pack/alpatrees.png"
const PIECES := "res://data/interiores/_piezas.json"
const INTERIOR_SHEETS := ["res://assets/tilesets/interior/suelos.png", "res://assets/tilesets/interior/paredes.png",
	"res://assets/tilesets/interior/muebles.png", "res://assets/tilesets/interior/mostradores.png"]
const OWN_GYM := "res://assets/tilesets/interior/gimnasios/propios/"
const HAND_MADE := "res://assets/tilesets/exterior/hecho_a_mano/"
const ExteriorBuild := preload("res://assets/tilesets/exterior/build_exterior.gd")
const SIZE := Vector2i(384, 308)

## Fondo → archivo original (pack 10 si lo trae; si no, EBDX).
const BACKDROPS := {
	"field": PACK10 + "battlebg/Field.png", "cave": PACK10 + "battlebg/Cave.png",
	"city": PACK10 + "battlebg/City.png", "indoor_a": PACK10 + "battlebg/IndoorA.png",
	"sand": PACK10 + "battlebg/Sand.png", "snow": PACK10 + "battlebg/Snow.png",
	"water": PACK10 + "battlebg/Water.png", "forest_denso": PACK10 + "battlebg/Forest.png",
	"mountain": PACK10 + "battlebg/Mountain.png", "cave_dark": PACK10 + "battlebg/CaveDark.png",
	"indoor_b": PACK10 + "battlebg/IndoorB.png", "champion": EBDX + "battlebg/Champion.png",
	"dance_floor": EBDX + "battlebg/DanceFloor.png", "darkness": EBDX + "battlebg/Darkness.png",
	"sapphire": EBDX + "battlebg/Sapphire.png",
}
## Capa → elemento original.
const LAYERS := {
	"cielo_amanecer": PACK10 + "elements/skyDawn.png", "cielo_dia": PACK10 + "elements/skyDay.png",
	"cielo_noche": PACK10 + "elements/skyNight.png", "sombra": PACK10 + "elements/shade.png",
	"sol": EBDX + "elements/sun.png", "estrella": EBDX + "elements/star.png",
	"montana": EBDX + "elements/mountain.png", "montana_b": EBDX + "elements/mountainB.png",
	"montana_c": EBDX + "elements/mountainC.png", "decor001": EBDX + "elements/decor001.png",
	"decor002": EBDX + "elements/decor002.png", "decor003": EBDX + "elements/decor003.png",
	"decor003a": EBDX + "elements/decor003a.png", "decor004": EBDX + "elements/decor004.png",
	"decor005": EBDX + "elements/decor005.png", "decor006": EBDX + "elements/decor006.png",
	"decor007": EBDX + "elements/decor007.png", "decor008": EBDX + "elements/decor008.png",
	"decor009": EBDX + "elements/decor009.png", "niebla": EBDX + "elements/fog.png",
	"niebla_oscura": EBDX + "elements/darkFog.png", "publico": EBDX + "elements/crowd.png",
	"publico_claro": EBDX + "elements/crowd_d.png", "disco": EBDX + "elements/discoBg.png",
	"sombra_bosque": EBDX + "elements/forestShade.png", "base001": EBDX + "elements/base001.png",
	"base001a": EBDX + "elements/base001a.png",
}
## Árboles del pack 03 (×1), como en build_exterior.gd, más los nevados y el seco.
const TREE_AREAS := {
	"redondo": Rect2i(210, 0, 36, 48), "verde": Rect2i(114, 0, 34, 64), "doble": Rect2i(156, 0, 54, 64),
	"pino": Rect2i(68, 176, 34, 80), "manzano": Rect2i(320, 206, 48, 50), "arbustos": Rect2i(208, 158, 48, 30),
	"nevado": Rect2i(0, 176, 64, 80), "nevado_pequeno": Rect2i(212, 197, 40, 59), "seco": Rect2i(273, 113, 30, 47),
}

var _resources := DEFAULT_RESOURCES
var _only := ""
var _trees: Image
var _pieces: Dictionary
var _sheets: Array[Image] = []
var _manifest := {}
var _errors := 0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--recursos="):
			_resources = arg.get_slice("=", 1)
		elif arg.begins_with("--solo="):
			_only = arg.get_slice("=", 1)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	var recipes: Dictionary = data["composiciones"]
	if _only != "" and (not recipes.has(_only) or _only.begins_with("_")):
		push_error("build_fondos: composición desconocida: %s" % _only)
		quit(1)
		return
	if _only == "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LAYERS_OUT))
		for id: String in BACKDROPS:
			_copy(BACKDROPS[id], OUT + id + ".png")
		for id: String in LAYERS:
			_copy(LAYERS[id], LAYERS_OUT + id + ".png")
	else:
		# Una composición no regenera las demás a partir de fachadas que puedan
		# haber cambiado mientras otro frente trabajaba en sus fondos.
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		_manifest = saved.get("archivos", {}).duplicate(true)
	_trees = ExteriorBuild._retouched(_load_resource(TREES))
	_pieces = JSON.parse_string(FileAccess.get_file_as_string(PIECES))
	for path: String in INTERIOR_SHEETS:
		_sheets.append(_load_project(path))
	for id: String in recipes:
		if id.begins_with("_") or (_only != "" and id != _only):
			continue
		var out := Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
		for entry: Variant in recipes[id]:
			_place(out, entry)
		out.save_png(OUT + id + ".png")
		_manifest[id + ".png"] = {"compuesto": "data/battle_backgrounds.json → composiciones." + id}
		print("build_fondos: %s%s.png" % [OUT, id])
	if _only == "" or _only == "frente_hierba":
		var forest := _load_project(OUT + "field.png")
		var front := Image.load_from_file(ProjectSettings.globalize_path(OUT + "frente_hierba.png"))
		forest.blend_rect(front, Rect2i(Vector2i.ZERO, SIZE), Vector2i.ZERO)
		forest.save_png(OUT + "forest.png")
		_manifest["forest.png"] = {"compuesto": "field.png + frente_hierba.png (la ficha del Pokémon)"}
	var file := FileAccess.open(MANIFEST, FileAccess.WRITE)
	file.store_string(JSON.stringify({"_doc": "Procedencia de los fondos de combate (build_fondos.gd). Copias byte a byte de los packs, con su SHA-256; los frentes son composiciones de piezas de los packs y de los .px2 a mano.", "archivos": _manifest}, " ", true) + "\n")
	file.close()
	print("build_fondos: %d errores" % _errors)
	quit(1 if _errors > 0 else 0)


func _copy(relative: String, target: String) -> void:
	var source := _resources.path_join(relative)
	var err := DirAccess.copy_absolute(source, ProjectSettings.globalize_path(target))
	if err != OK:
		push_error("build_fondos: no se pudo copiar %s (%s)" % [source, error_string(err)])
		_errors += 1
		return
	var key := target.trim_prefix(OUT)
	_manifest[key] = {"origen": relative, "sha256": FileAccess.get_sha256(source)}


func _place(out: Image, entry: Variant) -> void:
	if entry is Dictionary:
		var d: Dictionary = entry
		if d.has("pared"):
			_wall(out, String(d["pared"]), int(d["abajo"]), int(d.get("filas", 4)))
		elif d.has("fila"):
			var piece := _piece(String(d["fila"]))
			var x := int(d["desde"])
			while x < int(d["hasta"]):
				_blend(out, piece, Vector2i(x, int(d["y"]) - piece.get_height()))
				x += int(d["paso"])
		return
	var e: Array = entry
	var img := _piece(String(e[0]))
	if img == null:
		return
	if e.size() > 3 and bool(e[3]):
		img.flip_x()
	_blend(out, img, Vector2i(int(e[1]) - img.get_width() / 2, int(e[2]) - img.get_height()))


func _blend(out: Image, img: Image, at: Vector2i) -> void:
	if img != null:
		out.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), at)


## La pieza a la escala del fondo (×1).
func _piece(ref: String) -> Image:
	var kind := ref.get_slice(":", 0)
	var id := ref.get_slice(":", 1)
	match kind:
		"arbol":
			if TREE_AREAS.has(id):
				return _trees.get_region(TREE_AREAS[id])
		"mueble":
			var m: Dictionary = _pieces["muebles"].get(id, {})
			if not m.is_empty():
				var r: Array = m["rect"]
				return _half(_sheets[int(m["fuente"])].get_region(Rect2i(int(r[0]) * 32, int(r[1]) * 32, int(r[2]) * 32, int(r[3]) * 32)))
		"propio":
			if ResourceLoader.exists(OWN_GYM + id + ".png"):
				return _half(_load_project(OWN_GYM + id + ".png"))
		"mano":
			if ResourceLoader.exists(HAND_MADE + id + ".png"):
				return _half(_load_project(HAND_MADE + id + ".png"))
	push_error("build_fondos: no existe la pieza '%s'" % ref)
	_errors += 1
	return null


## La cara del muro del bloque `name` (paredes.png de Akizakura16): la fila de arriba repetida y el
## zócalo abajo, a lo ancho del fondo.
func _wall(out: Image, name: String, bottom: int, rows: int) -> void:
	var block := int(_pieces["paredes"].get(name, -1))
	if block < 0:
		push_error("build_fondos: no existe la pared '%s'" % name)
		_errors += 1
		return
	var face := _half(_sheets[1].get_region(Rect2i(0, (block * 5 + 3) * 32, 32, 64)))
	var upper := face.get_region(Rect2i(0, 0, 16, 16))
	var lower := face.get_region(Rect2i(0, 16, 16, 16))
	for x in range(0, SIZE.x, 16):
		_blend(out, lower, Vector2i(x, bottom - 16))
		for r in range(1, rows):
			_blend(out, upper, Vector2i(x, bottom - 16 * (r + 1)))


## Las piezas a ×2 exacto, a ×1: un píxel de cada bloque de 2×2.
func _half(img: Image) -> Image:
	var out := Image.create_empty(img.get_width() / 2, img.get_height() / 2, false, Image.FORMAT_RGBA8)
	for y in out.get_height():
		for x in out.get_width():
			out.set_pixel(x, y, img.get_pixel(x * 2, y * 2))
	return out


func _load_resource(relative: String) -> Image:
	var img := Image.load_from_file(_resources.path_join(relative))
	img.convert(Image.FORMAT_RGBA8)
	return img


func _load_project(path: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	img.convert(Image.FORMAT_RGBA8)
	return img
