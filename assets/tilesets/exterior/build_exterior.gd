extends SceneTree
@warning_ignore_start("integer_division")
## Monta el tileset de exteriores a partir de los packs de terceros (fuera del
## repo, ver docs/arte/recursos_terceros.md). NO dibuja nada: copia casillas de los
## packs tal cual, convierte en transparentes los colores clave (rosa, magenta y
## amarillo de relleno) y recompone las piezas de 16 px de los autotiles de RMXP.
## Escala (decisión de Javier): 02 ya viene a ×2 y se copia igual; 01, 03 y 04
## vienen a ×1 y se duplica cada píxel (×2 exacto, vecino más próximo).
## Color: los verdes de la naturaleza (packs 02, 03 y 04) llevan un retoque de
## paleta para que la hierba sea tan viva como la de Añil (ver GREEN_RETOUCH).
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
const HGSS_URBAN := "01_hgss_for_rmxp/HGSS for RMXP/UrbanRMXP.png"
const TREES := "03_big_tree_pack/alpatrees.png"
const FLORA := "04_big_flora_pack/tileset.png"

## Colores de relleno de las hojas (no son arte: marcan lo vacío).
const KEYS_HGSS := ["ff00ff", "f05ba1", "fff568"]
const CHECKER_GEN4 := ["ffaec9", "efe4b0"]

## Franjas de filas del pack 02 que se copian: [primera fila, nº de filas].
const GEN4_BANDS := [[0, 9], [19, 1], [31, 5], [46, 11], [242, 6]]

## Retoque de paleta de los verdes (respuesta 17 de Javier: el pueblo "plano y
## descolorido"; tiene que ser "saturado"). La hierba de DPPt tira a amarillo
## (tono 85°, saturación 0,36) y la de Añil es más verde y viva (105°, 0,43).
## El tono de los verdes se acerca al de Añil (`hue_target`, en fracción de vuelta)
## y se avivan un poco, con una transición suave en los bordes del intervalo para
## no crear saltos. No se dibuja nada: es una corrección de color de los píxeles
## del pack, como el retoque de paleta que Javier acepta para las casas.
const GREEN_RETOUCH := {"hue_from": 0.15, "hue_to": 0.40, "fade": 0.05, "hue_target": 0.285,
	"pull": 0.8, "saturation": 1.16, "value": 0.05}

## Casas de DPPt del pack 02 (estilo único con el suelo, respuesta 17): casilla
## de arriba a la izquierda, tamaño en casillas y puerta (relativa a la casilla de
## abajo a la izquierda; se pisa para entrar). Del rectángulo solo se copia el
## bloque principal, para no arrastrar trozos de las piezas vecinas de la hoja.
const HOUSES_DPPT := {
	"casa_roja": [Vector2i(0, 140), Vector2i(7, 7), Vector2i(1, -2)],
	"casa_azul": [Vector2i(0, 147), Vector2i(7, 7), Vector2i(1, -2)],
	"casa_azul_pequena": [Vector2i(0, 155), Vector2i(5, 6), Vector2i(1, -1)],
	"casa_naranja": [Vector2i(3, 68), Vector2i(4, 7), Vector2i(1, -1)],
	"casa_tejado_rojo": [Vector2i(0, 59), Vector2i(7, 7), Vector2i(2, -1)],
	"casa_roja_chimenea": [Vector2i(0, 133), Vector2i(5, 7), Vector2i(1, -1)],
	"casa_dos_aguas": [Vector2i(4, 108), Vector2i(4, 7), Vector2i(1, -1)],
	"casa_madera": [Vector2i(4, 87), Vector2i(4, 7), Vector2i(1, -1)],
	"casa_granero": [Vector2i(0, 236), Vector2i(4, 7), Vector2i(1, -1)],
	"edificio_cupula": [Vector2i(0, 97), Vector2i(5, 7), Vector2i(1, -1)],
}

## Valla de madera del pack 01 (×1): tramo horizontal de 3 piezas (izquierda,
## centro que se repite y derecha); cada pieza ocupa 2 casillas de alto (puntas
## arriba, base con su sombra abajo).
const FENCE_HGSS := Rect2i(448, 176, 48, 32)

## Casas del pack 01: rectángulo en píxeles de la hoja a ×1, trozos que se borran
## porque son de la pieza de al lado en la hoja y casilla de la puerta (relativa a
## la de abajo a la izquierda; se puede pisar para entrar).
const HOUSES := {
	"casa_pequena": [Rect2i(736, 0, 112, 96), [Rect2i(828, 0, 20, 96)], Vector2i(2, -1)],
	"casa_grande": [Rect2i(736, 112, 128, 128), [], Vector2i(2, -1)],
	"casa_escalera": [Rect2i(736, 240, 128, 128), [Rect2i(736, 240, 8, 128)], Vector2i(2, -2)],
}
## Edificios de ciudad del pack 01 (BuildingsRMXP.png, a ×1): rectángulo de la pieza en la hoja
## (números del catálogo de tools/mundo/catalogo_edificios.gd, ver docs/mundo/arte_ciudades.md) y
## puerta (relativa a la casilla de abajo a la izquierda; Vector2i(-1, -1) = se calcula: el centro de
## la fila de abajo). Del rectángulo solo se copia el bloque principal (lo que se toca), para no
## arrastrar trozos de la pieza vecina de la hoja.
const CITY_BUILDINGS := {
	"centro_pokemon": [Rect2i(28, 12, 92, 92), Vector2i(-1, -1)],
	"centro_pokemon_grande": [Rect2i(2320, 144, 104, 136), Vector2i(-1, -1)],
	"tienda_azul": [Rect2i(16, 268, 76, 76), Vector2i(-1, -1)],
	"tienda_morada": [Rect2i(16, 380, 76, 76), Vector2i(-1, -1)],
	"grandes_almacenes": [Rect2i(1168, 768, 120, 124), Vector2i(-1, -1)],
	"puesto_mercado": [Rect2i(1524, 164, 60, 72), Vector2i(-1, -1)],
	"oficinas_verdes": [Rect2i(2032, 1132, 108, 136), Vector2i(-1, -1)],
	"oficinas_azules": [Rect2i(1024, 352, 100, 120), Vector2i(-1, -1)],
	"bloque_pisos": [Rect2i(2176, 96, 96, 124), Vector2i(-1, -1)],
	"atico_jardin": [Rect2i(888, 552, 120, 96), Vector2i(-1, -1)],
	"teatro": [Rect2i(1024, 1028, 88, 88), Vector2i(-1, -1)],
	"gimnasio_madera": [Rect2i(2320, 1112, 120, 92), Vector2i(-1, -1)],
	"faro": [Rect2i(1600, 4, 128, 192), Vector2i(-1, -1)],
	"torre_octogonal": [Rect2i(1468, 352, 64, 112), Vector2i(-1, -1)],
	"velero": [Rect2i(1460, 1136, 88, 88), Vector2i(-1, -1)],
	"torre_socorrista": [Rect2i(1772, 124, 40, 68), Vector2i(-1, -1)],
	"arco": [Rect2i(1024, 176, 104, 84), Vector2i(-1, -1)],
	"casa_tejado_azul": [Rect2i(1612, 488, 76, 84), Vector2i(-1, -1)],
	"casa_tejado_azul_2": [Rect2i(1612, 580, 76, 88), Vector2i(-1, -1)],
	"casa_teja": [Rect2i(1896, 8, 100, 116), Vector2i(-1, -1)],
	"tienda_verde": [Rect2i(1900, 256, 76, 72), Vector2i(-1, -1)],
	"tienda_verde_2": [Rect2i(1900, 336, 76, 76), Vector2i(-1, -1)],
	"casa_roja_pequena": [Rect2i(2176, 1064, 68, 84), Vector2i(-1, -1)],
	"casa_rosa": [Rect2i(2176, 1176, 68, 84), Vector2i(-1, -1)],
	"tienda_naranja": [Rect2i(2188, 324, 80, 84), Vector2i(-1, -1)],
	"casa_gris": [Rect2i(2188, 456, 68, 84), Vector2i(-1, -1)],
	"tienda_flores": [Rect2i(2200, 228, 84, 92), Vector2i(-1, -1)],
	"casa_paja": [Rect2i(888, 948, 80, 108), Vector2i(-1, -1)],
	"casa_paja_2": [Rect2i(888, 1060, 80, 104), Vector2i(-1, -1)],
	"cabana": [Rect2i(1756, 204, 76, 76), Vector2i(-1, -1)],
}
## Adornos urbanos del pack 01 (UrbanRMXP.png, a ×1): farolas, fuentes, bancos, jardineras...
## (catálogo de tools/mundo/catalogo_edificios.gd con --hoja=UrbanRMXP.png). Solo se copia el
## bloque principal de cada rectángulo.
const URBAN_PROPS := {
	"farola_roja": Rect2i(592, 372, 20, 40),
	"farola_rosa": Rect2i(656, 372, 22, 40),
	"farola_verde": Rect2i(656, 180, 24, 44),
	"farola_verde_2": Rect2i(592, 188, 24, 36),
	"fuente_cano": Rect2i(592, 517, 32, 36),
	"fuente_plaza": Rect2i(764, 220, 56, 44),
	"banco": Rect2i(364, 848, 56, 18),
	"jardinera": Rect2i(642, 424, 60, 32),
	"sombrilla": Rect2i(752, 376, 72, 64),
	"busto": Rect2i(756, 484, 28, 48),
	"abeto_maceta": Rect2i(616, 572, 48, 64),
	"aerogenerador": Rect2i(744, 24, 40, 84),
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
	_save(_retouched(_gen4()), "gen4.png")
	_save(_retouched(_autotiles()), "autotiles.png")
	_save(_retouched(_animated()), "animados.png")
	var objects := {}
	_save(_houses(objects), "casas.png")
	_save(_retouched(_trees(objects)), "arboles.png")
	_save(_retouched(_flora()), "flora.png")
	_save(_retouched(_houses_dppt(objects)), "casas_dppt.png")
	_save(_fences(objects), "vallas.png")
	_save(_city_buildings(objects), "edificios.png")
	_save(_urban_props(objects), "adornos.png")
	_hand_made(objects)
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


## Casas de DPPt: se copian tal cual (el pack 02 ya va a ×2), una al lado de otra.
func _houses_dppt(objects: Dictionary) -> Image:
	var src := _load(GEN4_TILESET)
	var width := 0
	var height := 0
	for id: String in HOUSES_DPPT:
		var size: Vector2i = HOUSES_DPPT[id][1]
		width += size.x
		height = maxi(height, size.y)
	var out := _empty(width * T, height * T)
	var x := 0
	for id: String in HOUSES_DPPT:
		var origin: Vector2i = HOUSES_DPPT[id][0]
		var size: Vector2i = HOUSES_DPPT[id][1]
		var part := src.get_region(Rect2i(origin * T, size * T))
		_clear_checker_tiles(part)
		part = _main_block(part, false)
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i(x * T, 0))
		var door: Vector2i = HOUSES_DPPT[id][2]
		objects[id] = {"source": ExteriorTiles.SRC_CASAS_DPPT, "coords": [x, 0], "size": [size.x, size.y],
			"footprint": _solid_cells(part), "door": [door.x, door.y]}
		x += size.x
	return out


## Edificios de ciudad: el bloque principal de cada pieza a ×2, apoyado abajo en su caja de
## casillas, en filas de hasta 48 casillas de ancho.
func _city_buildings(objects: Dictionary) -> Image:
	var src := _load(HGSS_BUILDINGS)
	_key_out(src, KEYS_HGSS)
	var parts := {}
	for id: String in CITY_BUILDINGS:
		var piece := _main_block(src.get_region(CITY_BUILDINGS[id][0]))
		var art := _double(piece)
		var cells := Vector2i(ceili(art.get_width() / float(T)), ceili(art.get_height() / float(T)))
		var box := _empty(cells.x * T, cells.y * T)
		box.blit_rect(art, Rect2i(Vector2i.ZERO, art.get_size()),
			Vector2i((box.get_width() - art.get_width()) / 2, box.get_height() - art.get_height()))
		parts[id] = box
	var max_cols := 48
	var cursor := Vector2i.ZERO
	var row_h := 0
	var width := 0
	var placed := {}
	for id: String in parts:
		var size: Vector2i = (parts[id] as Image).get_size() / T
		if cursor.x + size.x > max_cols:
			cursor = Vector2i(0, cursor.y + row_h)
			row_h = 0
		placed[id] = cursor
		cursor.x += size.x
		row_h = maxi(row_h, size.y)
		width = maxi(width, cursor.x)
	var out := _empty(width * T, (cursor.y + row_h) * T)
	for id: String in parts:
		var part: Image = parts[id]
		var at: Vector2i = placed[id]
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), at * T)
		var size := part.get_size() / T
		var footprint := _solid_cells(part)
		var door: Vector2i = CITY_BUILDINGS[id][1]
		if door.x < 0:
			door = _bottom_center(footprint, size.x)
		objects[id] = {"source": ExteriorTiles.SRC_EDIFICIOS, "coords": [at.x, at.y], "size": [size.x, size.y],
			"footprint": footprint, "door": [door.x, door.y]}
	return out


## Adornos urbanos: como los edificios, cada uno en su caja de casillas apoyado abajo.
func _urban_props(objects: Dictionary) -> Image:
	var src := _load(HGSS_URBAN)
	_key_out(src, KEYS_HGSS)
	var parts := {}
	var width := 0
	var height := 0
	for id: String in URBAN_PROPS:
		var art := _double(_main_block(src.get_region(URBAN_PROPS[id])))
		var cells := Vector2i(ceili(art.get_width() / float(T)), ceili(art.get_height() / float(T)))
		var box := _empty(cells.x * T, cells.y * T)
		box.blit_rect(art, Rect2i(Vector2i.ZERO, art.get_size()),
			Vector2i((box.get_width() - art.get_width()) / 2, box.get_height() - art.get_height()))
		parts[id] = box
		width += cells.x
		height = maxi(height, cells.y)
	var out := _empty(width * T, height * T)
	var x := 0
	for id: String in parts:
		var part: Image = parts[id]
		out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i(x * T, 0))
		var size := part.get_size() / T
		# Choca solo la fila de abajo (la base): se puede pasar por detrás de la farola.
		var footprint := []
		for cell: Array in _solid_cells(part):
			if int(cell[1]) == 0:
				footprint.append(cell)
		if footprint.is_empty():
			footprint = [[size.x / 2, 0]]
		objects[id] = {"source": ExteriorTiles.SRC_ADORNOS, "coords": [x, 0], "size": [size.x, size.y],
			"footprint": footprint}
		x += size.x
	return out


## Edificios y monumentos dibujados a mano (assets/_fuentes/mundo/*.px2, exportados por
## exportar_mundo.gd a hecho_a_mano/): cada PNG es una fuente propia del TileSet. Su número de
## fuente (desde SRC_HECHO_A_MANO) y su puerta están en hecho_a_mano/piezas.json; el número no
## cambia nunca, porque los mapas ya pintados lo guardan. Un PNG que no esté apuntado es un error.
func _hand_made(objects: Dictionary) -> void:
	var dir := OUT + "hecho_a_mano/"
	var pieces := JsonFile.read_dict(dir + "piezas.json")
	var files := Array(DirAccess.get_files_at(dir)).filter(func(f: String) -> bool: return f.get_extension() == "png")
	files.sort()
	var used := {}
	for file: String in files:
		var id := file.get_basename()
		if not pieces.has(id):
			push_error("hecho_a_mano/%s no está en piezas.json (dale un número de fuente libre)." % file)
			continue
		var source := int(pieces[id]["fuente"])
		if source < ExteriorTiles.SRC_HECHO_A_MANO or used.has(source):
			push_error("piezas.json: la fuente %d de '%s' está repetida o es menor que %d." % [source, id,
				ExteriorTiles.SRC_HECHO_A_MANO])
			continue
		used[source] = true
		var img := Image.load_from_file(ProjectSettings.globalize_path(dir + file))
		img.convert(Image.FORMAT_RGBA8)
		var size := Vector2i(ceili(img.get_width() / float(T)), ceili(img.get_height() / float(T)))
		var footprint := _solid_cells(img)
		var door := _bottom_center(footprint, size.x)
		if pieces[id].has("puerta"):
			door = Vector2i(int(pieces[id]["puerta"][0]), int(pieces[id]["puerta"][1]))
		objects[id] = {"source": source, "file": "hecho_a_mano/" + file,
			"coords": [0, 0], "size": [size.x, size.y], "footprint": footprint, "door": [door.x, door.y]}


## Lo que se toca con el centro de la pieza (o con su grupo más grande): se borran los trozos
## sueltos de las piezas vecinas que entran en el rectángulo de la hoja. Deja la imagen recortada
## a ese bloque.
static func _main_block(img: Image, crop: bool = true) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var label := PackedInt32Array()
	label.resize(w * h)
	var sizes := [0]
	var bounds := [Rect2i()]
	for y: int in h:
		for x: int in w:
			if img.get_pixel(x, y).a <= 0.02 or label[y * w + x] != 0:
				continue
			var id := sizes.size()
			var count := 0
			var r := Rect2i(x, y, 1, 1)
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			label[y * w + x] = id
			while not stack.is_empty():
				var p: Vector2i = stack.pop_back()
				count += 1
				r = r.merge(Rect2i(p, Vector2i.ONE))
				for dy: int in range(-2, 3):
					for dx: int in range(-2, 3):
						var q := p + Vector2i(dx, dy)
						if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h or label[q.y * w + q.x] != 0:
							continue
						if img.get_pixel(q.x, q.y).a > 0.02:
							label[q.y * w + q.x] = id
							stack.append(q)
			sizes.append(count)
			bounds.append(r)
	var best := 0
	for i: int in range(1, sizes.size()):
		if best == 0 or sizes[i] > sizes[best]:
			best = i
	if best == 0:
		return img
	var out := _empty(w, h)
	for y: int in h:
		for x: int in w:
			if label[y * w + x] == best:
				out.set_pixel(x, y, img.get_pixel(x, y))
	return out.get_region(bounds[best]) if crop else out


## Puerta por defecto: la casilla sólida de la fila de abajo más cercana al centro.
static func _bottom_center(footprint: Array, width: int) -> Vector2i:
	var bottom := -999
	for cell: Array in footprint:
		bottom = maxi(bottom, int(cell[1]))
	var best := Vector2i(width / 2, bottom)
	var best_d := 999
	for cell: Array in footprint:
		if int(cell[1]) == bottom and absi(int(cell[0]) * 2 + 1 - width) < best_d:
			best_d = absi(int(cell[0]) * 2 + 1 - width)
			best = Vector2i(int(cell[0]), bottom)
	return best


## Valla de madera: 3 piezas de 1×2 casillas que se colocan como objetos (se
## ordenan con los personajes, así las puntas tapan a quien está detrás).
func _fences(objects: Dictionary) -> Image:
	var src := _load(HGSS_URBAN)
	_key_out(src, KEYS_HGSS)
	var out := _double(src.get_region(FENCE_HGSS))
	for i: int in 3:
		objects[["valla_izquierda", "valla", "valla_derecha"][i]] = {"source": ExteriorTiles.SRC_VALLAS,
			"coords": [i, 0], "size": [1, 2], "footprint": [[0, 0]]}
	return out


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

## Aplica GREEN_RETOUCH a los verdes de la imagen (ver la constante).
static func _retouched(img: Image) -> Image:
	var r := GREEN_RETOUCH
	var from: float = r["hue_from"]
	var to: float = r["hue_to"]
	var fade: float = r["fade"]
	for y: int in img.get_height():
		for x: int in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.05 or c.s < 0.12 or c.h < from or c.h > to:
				continue
			var weight := clampf(minf(c.h - from, to - c.h) / fade, 0.0, 1.0)
			var h := lerpf(c.h, r["hue_target"], float(r["pull"]) * weight)
			var s := clampf(c.s * lerpf(1.0, r["saturation"], weight), 0.0, 1.0)
			var v := clampf(c.v + float(r["value"]) * weight * c.v, 0.0, 1.0)
			img.set_pixel(x, y, Color.from_hsv(h, s, v, c.a))
	return img


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
