extends SceneTree
@warning_ignore_start("integer_division")
## Monta el tileset de exteriores a partir de los packs de terceros (fuera del
## repo, ver docs/arte/recursos_terceros.md). NO dibuja nada: copia casillas de los
## packs tal cual, convierte en transparentes los colores clave (rosa, magenta y
## amarillo de relleno) y recompone las piezas de 16 px de los autotiles de RMXP.
## Escala (decisión de Javier): 02 ya viene a ×2 y se copia igual; 01, 03 y 04
## vienen a ×1 y se duplica cada píxel (×2 exacto, vecino más próximo).
##
## Uso (en este orden):
##   godot --headless --path . -s res://assets/tilesets/exterior/build_exterior.gd -- --paso=png [--recursos=<ruta>]
##   godot --headless --path . --import
##   godot --headless --path . -s res://assets/tilesets/exterior/build_exterior.gd -- --paso=tileset

const T := 32
const DEFAULT_RESOURCES := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
const OUT := "res://assets/tilesets/exterior/"

const GEN4_TILESET := "02_public_gen4_tileset/Gen 4 Pack/Tilesets/Custom Outside tileset.png"
const GEN4_AUTOTILES := "02_public_gen4_tileset/Gen 4 Pack/Autotiles/"
const HGSS_BUILDINGS := "01_hgss_for_rmxp/HGSS for RMXP/BuildingsRMXP.png"
const TREES := "03_big_tree_pack/alpatrees.png"
const FLORA := "04_big_flora_pack/tileset.png"

## Colores de relleno de las hojas (no son arte: marcan lo vacío).
const KEYS_HGSS := ["ff00ff", "f05ba1", "fff568"]
const CHECKER_GEN4 := ["ffaec9", "efe4b0"]

## Franjas de filas del pack 02 que se copian: [primera fila, nº de filas].
const GEN4_BANDS := [[0, 9], [19, 1], [31, 5], [46, 11]]

## Casas del pack 01: rectángulo en píxeles de la hoja a ×1, trozos que se borran
## porque son de la pieza de al lado en la hoja y casilla de la puerta (relativa a
## la de abajo a la izquierda; se puede pisar para entrar).
const HOUSES := {
	"casa_pequena": [Rect2i(736, 0, 112, 96), [Rect2i(828, 0, 20, 96)], Vector2i(2, -1)],
	"casa_grande": [Rect2i(736, 112, 128, 128), [], Vector2i(2, -1)],
	"casa_escalera": [Rect2i(736, 240, 128, 128), [Rect2i(736, 240, 8, 128)], Vector2i(2, -2)],
}
## Árboles del pack 03: zona a ×1 (se recorta a lo visible) y ancho en casillas
## de la base que choca.
const TREE_AREAS := {
	"cerezo_grande": [Rect2i(304, 79, 65, 65), 2],
	"cerezo": [Rect2i(262, 55, 33, 57), 2],
	"arbol_redondo": [Rect2i(210, 0, 36, 48), 2],
	"arbol_verde": [Rect2i(114, 0, 34, 64), 2],
	"arbol_doble": [Rect2i(156, 0, 54, 64), 2],
	"manzano": [Rect2i(320, 206, 48, 50), 2],
	"pino": [Rect2i(68, 176, 34, 80), 2],
	"arbustos": [Rect2i(208, 158, 48, 30), 2],
}
## Flora del pack 04 copiada por zonas (×1): flores en columna, setos y nenúfares.
const FLORA_AREAS := [Rect2i(80, 16, 48, 336), Rect2i(80, 400, 48, 64), Rect2i(0, 224, 48, 48),
	Rect2i(16, 192, 64, 32)]

var _resources := DEFAULT_RESOURCES


func _initialize() -> void:
	await process_frame
	var step := "png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--recursos="):
			_resources = arg.get_slice("=", 1)
		elif arg.begins_with("--paso="):
			step = arg.get_slice("=", 1)
	if step == "png":
		_build_pngs()
	else:
		var builder: GDScript = load("res://assets/tilesets/exterior/exterior_tileset_builder.gd")
		builder.call(&"build")
	quit()


# --- Paso 1: PNG ---

func _build_pngs() -> void:
	_save(_gen4(), "gen4.png")
	_save(_autotiles(), "autotiles.png")
	_save(_animated(), "animados.png")
	var objects := {}
	_save(_houses(objects), "casas.png")
	_save(_trees(objects), "arboles.png")
	_save(_flora(), "flora.png")
	var file := FileAccess.open(OUT + "objetos.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(objects, "\t", true) + "\n")
	file.close()
	print("objetos.json: %d objetos" % objects.size())


func _gen4() -> Image:
	var src := _load(GEN4_TILESET)
	var rows := 0
	for band: Array in GEN4_BANDS:
		rows += int(band[1])
	var out := _empty(src.get_width(), rows * T)
	var y := 0
	for band: Array in GEN4_BANDS:
		var region := Rect2i(0, int(band[0]) * T, src.get_width(), int(band[1]) * T)
		out.blit_rect(src, region, Vector2i(0, y))
		y += region.size.y
	_clear_checker_tiles(out)
	return out


## Compone los 47 casos de cada autotile de RMXP (96×128) a partir de sus piezas
## de 16 px, igual que hace RPG Maker al dibujarlos.
func _autotiles() -> Image:
	var out := _empty(8 * T, 12 * T)
	var masks := AutotileMasks.all()
	var sets := ["grass.png", "dirt path.png"]
	for s: int in sets.size():
		var src := _load(GEN4_AUTOTILES + sets[s])
		for i: int in masks.size():
			var cell := Vector2i(i % 8, s * 6 + i / 8)
			_compose_autotile(src, masks[i], out, cell * T)
	return out


func _compose_autotile(src: Image, mask: int, out: Image, at: Vector2i) -> void:
	var h := T / 2
	var quarters := AutotileMasks.quarters(mask)
	for q: int in 4:
		var piece: Vector2i = quarters[q]
		var dst := at + Vector2i((q % 2) * h, (q / 2) * h)
		out.blit_rect(src, Rect2i(piece * h, Vector2i(h, h)), dst)


func _animated() -> Image:
	var out := _empty(4 * T, 3 * T)
	var files := ["Flowers1.png", "Flowers2.png", "water shine.png"]
	for i: int in files.size():
		var src := _load(GEN4_AUTOTILES + files[i])
		out.blit_rect(src, Rect2i(0, 0, src.get_width(), T), Vector2i(0, i * T))
	return out


func _houses(objects: Dictionary) -> Image:
	var src := _load(HGSS_BUILDINGS)
	_key_out(src, KEYS_HGSS)
	var parts := {}
	var width := 0
	var height := 0
	for id: String in HOUSES:
		var rect: Rect2i = HOUSES[id][0]
		var piece := src.get_region(rect)
		for erase: Rect2i in HOUSES[id][1]:
			piece.fill_rect(Rect2i(erase.position - rect.position, erase.size), Color(0, 0, 0, 0))
		var part := _double(piece)
		parts[id] = part
		width += part.get_width()
		height = maxi(height, part.get_height())
	var out := _empty(width, height)
	var x := 0
	for id: String in parts:
		var part: Image = parts[id]
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i(x, 0))
		var size := part.get_size() / T
		var door: Vector2i = HOUSES[id][2]
		objects[id] = {"source": ExteriorTiles.SRC_CASAS, "coords": [x / T, 0], "size": [size.x, size.y],
			"footprint": _solid_cells(part), "door": [door.x, door.y]}
		x += part.get_width()
	return out


func _trees(objects: Dictionary) -> Image:
	var src := _load(TREES)
	var parts := {}
	for id: String in TREE_AREAS:
		var area: Rect2i = TREE_AREAS[id][0]
		var content := _content_rect(src, area)
		var art := _double(src.get_region(content))
		var cells := Vector2i(ceili(art.get_width() / float(T)), ceili(art.get_height() / float(T)))
		var box := _empty(cells.x * T, cells.y * T)
		# Centrado en horizontal y apoyado abajo: así el tronco cae en la base.
		box.blit_rect(art, Rect2i(Vector2i.ZERO, art.get_size()),
			Vector2i((box.get_width() - art.get_width()) / 2, box.get_height() - art.get_height()))
		parts[id] = box
	var out := _empty(24 * T, 12 * T)
	var cursor := Vector2i.ZERO
	var row_height := 0
	for id: String in parts:
		var part: Image = parts[id]
		var size := part.get_size() / T
		if cursor.x + size.x > 24:
			cursor = Vector2i(0, cursor.y + row_height)
			row_height = 0
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), cursor * T)
		var base_width: int = mini(int(TREE_AREAS[id][1]), size.x)
		# Base centrada: si no cuadra (árbol de 3 de ancho y base de 2), una menos.
		if (size.x - base_width) % 2 == 1:
			base_width = maxi(base_width - 1, 1)
		var start := (size.x - base_width) / 2
		var footprint := []
		for dx: int in range(start, start + base_width):
			footprint.append([dx, 0])
		objects[id] = {"source": ExteriorTiles.SRC_ARBOLES, "coords": [cursor.x, cursor.y],
			"size": [size.x, size.y], "footprint": footprint}
		cursor.x += size.x
		row_height = maxi(row_height, size.y)
	return out.get_region(Rect2i(0, 0, out.get_width(), (cursor.y + row_height) * T))


func _flora() -> Image:
	var src := _load(FLORA)
	var parts: Array[Image] = []
	var height := 0
	for area: Rect2i in FLORA_AREAS:
		var part := _double(src.get_region(area))
		parts.append(part)
		height += part.get_height()
	var out := _empty(4 * T, height)
	var y := 0
	for part: Image in parts:
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i(0, y))
		y += part.get_height()
	return out


# --- Utilidades de imagen (copiar, no dibujar) ---

func _load(relative: String) -> Image:
	var path := _resources.path_join(relative)
	var img := Image.load_from_file(path)
	if img == null:
		push_error("build_exterior: no se pudo abrir '%s'." % path)
		quit(1)
	img.convert(Image.FORMAT_RGBA8)
	return img


static func _empty(w: int, h: int) -> Image:
	return Image.create_empty(w, h, false, Image.FORMAT_RGBA8)


static func _double(img: Image) -> Image:
	var out := img.duplicate() as Image
	out.resize(img.get_width() * 2, img.get_height() * 2, Image.INTERPOLATE_NEAREST)
	return out


static func _key_out(img: Image, keys: Array) -> void:
	for y: int in img.get_height():
		for x: int in img.get_width():
			if img.get_pixel(x, y).to_html(false) in keys:
				img.set_pixel(x, y, Color(0, 0, 0, 0))


## Casillas que son solo el cuadriculado de relleno del pack 02 → transparentes.
static func _clear_checker_tiles(img: Image) -> void:
	for ty: int in img.get_height() / T:
		for tx: int in img.get_width() / T:
			var only_checker := true
			for y: int in range(ty * T, ty * T + T, 2):
				for x: int in range(tx * T, tx * T + T, 2):
					if not (img.get_pixel(x, y).to_html(false) in CHECKER_GEN4):
						only_checker = false
						break
				if not only_checker:
					break
			if only_checker:
				img.fill_rect(Rect2i(tx * T, ty * T, T, T), Color(0, 0, 0, 0))


## Rectángulo con píxeles visibles dentro de `area`.
static func _content_rect(img: Image, area: Rect2i) -> Rect2i:
	var used := Rect2i()
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			if img.get_pixel(x, y).a > 0.05:
				var px := Rect2i(x, y, 1, 1)
				used = px if used.size == Vector2i.ZERO else used.merge(px)
	return used


## Casillas de una casa que son pared o tejado (más de un 40 % de píxeles opacos;
## las sombras son semitransparentes y no cuentan), relativas a la de abajo a la izquierda.
static func _solid_cells(img: Image) -> Array:
	var rows := img.get_height() / T
	var out := []
	for ty: int in rows:
		for tx: int in img.get_width() / T:
			var solid := 0
			var total := 0
			for y: int in range(ty * T, ty * T + T, 2):
				for x: int in range(tx * T, tx * T + T, 2):
					total += 1
					if img.get_pixel(x, y).a > 0.9:
						solid += 1
			if solid > total * 0.4:
				out.append([tx, ty - (rows - 1)])
	return out


func _save(img: Image, file_name: String) -> void:
	var err := img.save_png(ProjectSettings.globalize_path(OUT + file_name))
	print("%s: %s (%dx%d)" % [file_name, error_string(err), img.get_width(), img.get_height()])
