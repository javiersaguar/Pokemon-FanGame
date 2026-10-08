extends SceneTree
@warning_ignore_start("integer_division")
## Catálogo de las piezas de una hoja de tiles de RPG Maker (por defecto, los
## edificios del pack 01, HGSS for RMXP): quita los colores de relleno, separa
## cada pieza (grupos de píxeles opacos que se tocan) y escribe en
## tools/cache/edificios/:
##   - <hoja>.json: rectángulo de cada pieza (en píxeles de la hoja, a ×1),
##   - <hoja>_contacto_N.png: hojas de contacto con las piezas numeradas, para
##     verlas y ponerles nombre.
## No dibuja ni modifica arte: solo recorta para mirar.
##   godot --headless --path . -s res://tools/mundo/catalogo_edificios.gd [-- --hoja=<ruta> --min=400]

const DEFAULT_SHEET := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos/01_hgss_for_rmxp/HGSS for RMXP/BuildingsRMXP.png"
const KEYS := ["ff00ff", "f05ba1", "fff568"]
const SEPARATORS := ["ffffff", "1e1d1f"]
const OUT := "res://tools/cache/edificios/"
## Separación máxima (px) para unir trozos de una misma pieza (sombras, ventanas sueltas).
const JOIN := 3
const SHEET_W := 1600


func _initialize() -> void:
	var sheet_path := DEFAULT_SHEET
	var min_area := 400
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--hoja="):
			sheet_path = arg.get_slice("=", 1)
		elif arg.begins_with("--min="):
			min_area = int(arg.get_slice("=", 1))
	var img := Image.load_from_file(sheet_path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	# Columnas separadoras de la hoja (blancas o con la línea de puntos): no son arte.
	var separator := PackedByteArray()
	separator.resize(w)
	for x: int in w:
		var only_background := true
		for y: int in h:
			var html := img.get_pixel(x, y).to_html(false)
			if not (html in KEYS or html in SEPARATORS):
				only_background = false
				break
		separator[x] = 1 if only_background else 0
	var opaque := PackedByteArray()
	opaque.resize(w * h)
	for y: int in h:
		for x: int in w:
			var c := img.get_pixel(x, y)
			opaque[y * w + x] = 1 if separator[x] == 0 and c.a > 0.05 and not (c.to_html(false) in KEYS) else 0
	# Grupos por casillas de 4x4 px (más rápido y une detalles cercanos).
	var cell := 4
	var gw := ceili(w / float(cell))
	var gh := ceili(h / float(cell))
	var filled := PackedByteArray()
	filled.resize(gw * gh)
	for gy: int in gh:
		for gx: int in gw:
			var n := 0
			for y: int in range(gy * cell, mini(gy * cell + cell, h)):
				for x: int in range(gx * cell, mini(gx * cell + cell, w)):
					n += opaque[y * w + x]
			filled[gy * gw + gx] = 1 if n >= 3 else 0
	var label := PackedInt32Array()
	label.resize(gw * gh)
	var rects: Array[Rect2i] = []
	for gy: int in gh:
		for gx: int in gw:
			if filled[gy * gw + gx] == 0 or label[gy * gw + gx] != 0:
				continue
			var id := rects.size() + 1
			var stack: Array[Vector2i] = [Vector2i(gx, gy)]
			label[gy * gw + gx] = id
			var r := Rect2i(gx, gy, 1, 1)
			while not stack.is_empty():
				var p: Vector2i = stack.pop_back()
				r = r.merge(Rect2i(p, Vector2i.ONE))
				for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var q := p + d
					if q.x < 0 or q.y < 0 or q.x >= gw or q.y >= gh:
						continue
					if filled[q.y * gw + q.x] == 1 and label[q.y * gw + q.x] == 0:
						label[q.y * gw + q.x] = id
						stack.append(q)
			rects.append(Rect2i(r.position * cell, r.size * cell))
	# Une rectángulos que se solapan o casi se tocan.
	var merged := true
	while merged:
		merged = false
		for i: int in rects.size():
			for j: int in range(i + 1, rects.size()):
				if rects[i].grow(JOIN).intersects(rects[j]):
					rects[i] = rects[i].merge(rects[j])
					rects.remove_at(j)
					merged = true
					break
			if merged:
				break
	var pieces: Array[Rect2i] = []
	for r: Rect2i in rects:
		var clipped := r.intersection(Rect2i(0, 0, w, h))
		if clipped.get_area() >= min_area:
			pieces.append(clipped)
	pieces.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x * 10000 + a.position.y < b.position.x * 10000 + b.position.y)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var base := sheet_path.get_file().get_basename()
	var list := []
	for i: int in pieces.size():
		var r := pieces[i]
		list.append({"n": i + 1, "x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y})
	var f := FileAccess.open(OUT + base + ".json", FileAccess.WRITE)
	f.store_string(JSON.stringify(list, "\t"))
	f.close()
	_contact_sheets(img, pieces, base)
	print("%d piezas" % pieces.size())
	quit()


func _contact_sheets(img: Image, pieces: Array[Rect2i], base: String) -> void:
	# Limpia el relleno para ver las piezas sobre gris.
	var clean := img.duplicate() as Image
	for y: int in clean.get_height():
		for x: int in clean.get_width():
			if clean.get_pixel(x, y).to_html(false) in KEYS:
				clean.set_pixel(x, y, Color(0, 0, 0, 0))
	var font := ThemeDB.fallback_font
	var page := 0
	var cursor := Vector2i(4, 4)
	var row_h := 0
	var sheet := _page()
	var labels := []
	for i: int in pieces.size():
		var r := pieces[i]
		var cell := r.size + Vector2i(0, 14)
		if cursor.x + cell.x > SHEET_W:
			cursor = Vector2i(4, cursor.y + row_h + 6)
			row_h = 0
		if cursor.y + cell.y > 1200:
			_save_page(sheet, labels, base, page)
			page += 1
			sheet = _page()
			labels = []
			cursor = Vector2i(4, 4)
			row_h = 0
		sheet.blend_rect(clean, r, cursor + Vector2i(0, 14))
		labels.append([str(i + 1), cursor])
		cursor.x += cell.x + 8
		row_h = maxi(row_h, cell.y)
	_save_page(sheet, labels, base, page)


func _page() -> Image:
	var img := Image.create_empty(SHEET_W, 1200, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.78, 0.8, 0.82))
	return img


func _save_page(sheet: Image, labels: Array, base: String, page: int) -> void:
	# Los números se dibujan con un viewport para usar la fuente; aquí basta con
	# marcarlos como bloques: se escriben en un .txt al lado y en la imagen con dígitos.
	for l: Array in labels:
		_draw_number(sheet, String(l[0]), l[1])
	sheet.save_png(ProjectSettings.globalize_path(OUT + "%s_contacto_%d.png" % [base, page]))


const DIGITS := {
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"],
	"8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "111"],
}


## Números de 3x5 px a ×2 (solo para la hoja de contacto, que no es arte del juego).
func _draw_number(img: Image, text: String, at: Vector2i) -> void:
	var x := at.x
	img.fill_rect(Rect2i(at, Vector2i(text.length() * 8 + 2, 12)), Color(1, 1, 1))
	for ch: String in text:
		var rows: Array = DIGITS[ch]
		for ry: int in 5:
			for rx: int in 3:
				if rows[ry][rx] == "1":
					img.fill_rect(Rect2i(x + 1 + rx * 2, at.y + 1 + ry * 2, 2, 2), Color(0.8, 0, 0))
		x += 8
