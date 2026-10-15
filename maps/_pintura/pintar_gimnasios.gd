extends SceneTree
## Pinta los gimnasios por dentro (docs/DECISIONES_JAVIER_2026-10-14.md y docs/mundo/gimnasios.md): por cada
## gimnasio, tres salas en fila y la del líder, según maps/_pintura/gimnasios_salas.json.
##
## El puzle: en cada sala hay que ganar a todos sus entrenadores para pasar. El paso de un tramo al siguiente
## lo tapa un vigilante que solo se aparta al ganar al entrenador de ese tramo (MapEntity.hidden_if_flag con
## su flag de derrota; otro igual, con visible_if_flag, aparece a un lado), así que no se llega al líder sin
## ganar a todos. Lo comprueba tests/mundo/test_gimnasios_salas.gd.
##
## Cada sala con "plano" se pinta a mano desde dos rejillas del mismo tamaño (docs/arte/gimnasios.md):
## - "plano": estructura y suelo. '#' = pared (se elige sola la pieza: cara de la pared si tiene suelo debajo,
##   borde si no), '.' = suelo del gimnasio, 'S' = puerta de arriba a la sala siguiente (va en la cara de la
##   pared), 'E' = felpudo de la salida; el resto de letras, suelos o alfombras de la leyenda.
## - "muebles": muebles y adornos de la leyenda. '.' o ' ' = nada.
## - "personas": '1'–'9' entrenadores de la sala (por orden), 'g' 'h' 'i' 'j' vigilantes (y 'G' 'H' 'I' 'J',
##   dónde se quedan al apartarse), 'n'–'r' personajes que hablan, 'x' 'y' 'z' carteles y '@' el líder. Así un
##   personaje puede estar detrás de un mostrador (en la casilla de arriba del mueble, que se pisa).
## Las piezas de la leyenda salen del tileset de los gimnasios (assets/tilesets/interior/gimnasios/): recortes
## de Akizakura16 y piezas dibujadas a mano (.px2). Una pieza que ocupa varias casillas se escribe con su
## letra en todas ellas. Las salas sin "plano" se pintan con el zigzag antiguo.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_gimnasios.gd [-- ciudad ...]

const GYM_TILES := "res://assets/tilesets/interior/gimnasios/gimnasios.tres"
const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const SPEC := "res://maps/_pintura/gimnasios_salas.json"
const LEADER_EVENT := "res://src/events/gym_leader_event.gd"
const AYUSO_EVENT := "res://src/events/gym1_ayuso_event.gd"
const BGM_DIR := "res://assets/audio/bgm/"
const SIZE := Vector2i(16, 12)
const FLOORS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(2, 5), Vector2i(1, 9), Vector2i(2, 13), Vector2i(1, 17), Vector2i(2, 21),
	Vector2i(1, 25), Vector2i(2, 29), Vector2i(1, 33), Vector2i(2, 37), Vector2i(1, 41), Vector2i(2, 45),
	Vector2i(1, 49), Vector2i(2, 53), Vector2i(1, 57), Vector2i(2, 61),
]
const WALLS: Array[int] = [4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74]
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3
const FACING := {"abajo": DOWN, "izquierda": LEFT, "derecha": RIGHT, "arriba": UP}
const TRAINER_MARKS := "123456789"
const GUARD_MARKS := "ghij"
const ASIDE_MARKS := "GHIJ"
const NPC_MARKS := "nopqr"
const SIGN_MARKS := "xyz"
const LEADER_MARK := "@"
## Flag de entrenador derrotado (TrainerNPC.DEFEATED_FLAG; en un script suelto no hay autoloads).
const DEFEATED_FLAG := "trainer_defeated:%s"
## Dónde entra cada gimnasio desde la calle: mapa y aparición a la que se vuelve al salir.
const ENTRADAS := {
	"madrid": ["madrid/centro", "from_sala_39_31"], "barcelona": ["barcelona/les_corts", "from_sala_26_40"],
	"valencia": ["valencia/malvarrosa", "from_sala_43_20"], "sevilla": ["sevilla/rio", "from_sala_9_31"],
	"playa_del_ingles": ["playa_del_ingles/exterior", "from_gimnasio"], "bilbao": ["bilbao/exterior", "from_san_mames"],
	"valladolid": ["valladolid/exterior", "from_sala_35_18"], "malaga": ["malaga/exterior", "from_gimnasio"],
}

const PROPIOS := "res://assets/tilesets/interior/gimnasios/propios.json"
const PROPIOS_DIR := "res://assets/tilesets/interior/gimnasios/propios/"

var _errors := 0
var _propios := {}


func _initialize() -> void:
	await process_frame
	_propios = JsonFile.read_dict(PROPIOS)
	var spec := JsonFile.read_dict(SPEC)
	var only := Array(OS.get_cmdline_user_args())
	for city: String in spec:
		if city.begins_with("_") or (not only.is_empty() and city not in only):
			continue
		var gym: Dictionary = spec[city]
		var rooms: Array = gym["salas"]
		for i: int in rooms.size():
			if rooms[i].has("plano"):
				_room_v2(city, gym, rooms[i], i, rooms.size())
			else:
				_room(city, gym, i, rooms.size())
		if gym.has("sala_lider"):
			_room_v2(city, gym, gym["sala_lider"], rooms.size(), rooms.size())
		else:
			_leader_room(city, gym, rooms.size())
	quit(1 if _errors > 0 else 0)


func _id(city: String, index: int, total: int) -> String:
	return "%s/gimnasio_lider" % city if index >= total else "%s/gimnasio_%d" % [city, index + 1]


func _fail(map_id: String, message: String) -> void:
	_errors += 1
	push_error("%s: %s" % [map_id, message])


# --- Salas pintadas desde su plano ---

func _room_v2(city: String, gym: Dictionary, room: Dictionary, index: int, total: int) -> void:
	var map_id := _id(city, index, total)
	var plano: Array = room["plano"]
	var muebles: Array = room["muebles"]
	var personas: Array = room.get("personas", muebles)
	var size := Vector2i(str(plano[0]).length(), plano.size())
	for grid: Array in [plano, muebles, personas]:
		if grid.size() != size.y:
			return _fail(map_id, "el plano y los muebles no tienen las mismas filas")
		for row: String in grid:
			if row.length() != size.x:
				return _fail(map_id, "la fila «%s» no mide %d" % [row, size.x])
	var style: Dictionary = (gym["estilo"] as Dictionary).merged(room.get("estilo", {}), true)
	var merged: Dictionary = (gym.get("leyenda", {}) as Dictionary).merged(room.get("leyenda", {}), true)
	var legend := {}
	for key: String in merged:
		legend[key] = _resolve(map_id, merged[key])
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = str(room["titulo"]).capitalize()
	d.zone_id = StringName(city)
	d.outdoor = false
	d.fixed_camera = size.x <= 16 and size.y <= 12
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = StringName(str(style.get("fondo_combate", "indoor")))
	var music := str(room.get("musica", style.get("musica", "")))
	if music != "" and _music_exists(music):
		d.bgm = StringName(music)
	var p := Pintor.new("Gimnasio", size, d)
	var tiles: TileSet = load(GYM_TILES)
	for layer: TileMapLayer in [p.ground, p.decor, p.above]:
		layer.tile_set = tiles
	p.above.collision_enabled = false
	_structure(p, map_id, plano, style, legend)
	_pieces(p, map_id, plano, legend, true)
	_pieces(p, map_id, muebles, legend, false)
	_people(p, map_id, city, gym, room, personas, index >= total)
	_doors_v2(p, map_id, city, plano, style, index, total)
	_title(p, room, style, size)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


## Las piezas dibujadas a mano ("propia": nombre de propios.json) se convierten en una pieza normal de su
## fuente: entera, o como "fila" / "nueve" / "baldosa" si se pide (con sus casillas dentro del PNG).
func _resolve(map_id: String, spec: Variant) -> Variant:
	if not (spec is Dictionary) or not (spec as Dictionary).has("propia"):
		return spec
	var out: Dictionary = (spec as Dictionary).duplicate()
	var name := str(out["propia"])
	if not _propios.has(name):
		_fail(map_id, "la pieza propia «%s» no está en propios.json" % name)
		return {"baldosa": [0, 0, 0]}
	var src := int(_propios[name]["fuente"])
	var image := Image.load_from_file(ProjectSettings.globalize_path(PROPIOS_DIR + name + ".png"))
	var size := Vector2i(1, 1) if image == null else image.get_size() / 32
	var at: Array = out.get("casilla", [0, 0])
	if out.get("fila", null) is bool or out.get("fila", null) is float:
		out["fila"] = [src, int(at[0]), int(at[1])]
	elif out.get("nueve", null) is bool:
		out["nueve"] = [src, int(at[0]), int(at[1])]
	elif out.has("baldosa"):
		out["baldosa"] = [src, int(at[0]), int(at[1])]
	elif out.has("columna"):
		out["columna"] = [src, int(at[0]), int(at[1])]
	else:
		var part: Array = out.get("parte", [0, 0, size.x, size.y])
		out["pieza"] = [src, int(part[0]), int(part[1]), int(part[2]), int(part[3])]
	return out


static func _music_exists(id: String) -> bool:
	for extension: String in ["ogg", "wav", "mp3"]:
		if ResourceLoader.exists("%s%s.%s" % [BGM_DIR, id, extension]):
			return true
	return false


static func _char(grid: Array, at: Vector2i) -> String:
	if at.y < 0 or at.y >= grid.size() or at.x < 0 or at.x >= str(grid[at.y]).length():
		return ""
	return str(grid[at.y])[at.x]


static func _is_wall(grid: Array, at: Vector2i) -> bool:
	var c := _char(grid, at)
	return c == "#" or c == "S" or c == ""


## Suelo y paredes. La cara de la pared (dos filas) va donde hay suelo debajo; el resto de casillas de pared
## son el borde negro con su reborde, que se elige mirando qué vecinas son suelo o cara.
func _structure(p: Pintor, map_id: String, plano: Array, style: Dictionary, legend: Dictionary) -> void:
	var floor_tile: Array = style["suelo"]
	var wall: Array = style["pared"]
	var wall_src := int(wall[0])
	var b := int(wall[1]) * 5
	var face_cols: Array = style.get("cara", [1, 2, 3])
	var faces := {}
	for y: int in plano.size():
		for x: int in str(plano[y]).length():
			var at := Vector2i(x, y)
			if not _is_wall(plano, at):
				var c := _char(plano, at)
				var spec: Variant = legend.get(c, null) if c != "." and c != "E" else null
				if spec is Dictionary and (spec as Dictionary).has("suelo"):
					var t: Array = spec["suelo"]
					p.ground.set_cell(at, int(t[0]), Vector2i(int(t[1]), int(t[2])))
				else:
					p.ground.set_cell(at, int(floor_tile[0]), Vector2i(int(floor_tile[1]), int(floor_tile[2])))
				continue
			var col := int(face_cols[x % face_cols.size()])
			if not _is_wall(plano, at + Vector2i.DOWN):
				faces[at] = true
				p.ground.set_cell(at, wall_src, Vector2i(col, b + 4))
			elif not _is_wall(plano, at + Vector2i(0, 2)) and _char(plano, at + Vector2i(0, 2)) != "":
				faces[at] = true
				p.ground.set_cell(at, wall_src, Vector2i(col, b + 3))
	for y: int in plano.size():
		for x: int in str(plano[y]).length():
			var at := Vector2i(x, y)
			if not _is_wall(plano, at) or faces.has(at):
				continue
			var open := func(d: Vector2i) -> bool:
				var n := at + d
				return _char(plano, n) != "" and (not _is_wall(plano, n) or faces.has(n))
			var r: bool = open.call(Vector2i.RIGHT)
			var l: bool = open.call(Vector2i.LEFT)
			var u: bool = open.call(Vector2i.UP)
			var dn: bool = open.call(Vector2i.DOWN)
			var piece := Vector2i(1, 1)
			if dn and r: piece = Vector2i(2, 2)
			elif dn and l: piece = Vector2i(0, 2)
			elif u and r: piece = Vector2i(3, 1)
			elif u and l: piece = Vector2i(5, 1)
			elif r: piece = Vector2i(2, 1)
			elif l: piece = Vector2i(0, 1)
			elif dn: piece = Vector2i(1, 2)
			elif u: piece = Vector2i(4, 1)
			elif open.call(Vector2i(1, 1)): piece = Vector2i(2, 2)
			elif open.call(Vector2i(-1, 1)): piece = Vector2i(0, 2)
			elif open.call(Vector2i(1, -1)): piece = Vector2i(3, 1)
			elif open.call(Vector2i(-1, -1)): piece = Vector2i(5, 1)
			p.ground.set_cell(at, wall_src, piece + Vector2i(0, b))
	if style.has("sombra"):
		# Sombra del suelo bajo la pared de arriba (la casilla de sombra del mismo suelo).
		var shade: Array = style["sombra"]
		for at: Vector2i in faces:
			var below := at + Vector2i.DOWN
			if not _is_wall(plano, below) and _char(plano, below) == ".":
				p.ground.set_cell(below, int(shade[0]), Vector2i(int(shade[1]), int(shade[2])))


## Piezas de la leyenda en una rejilla (las del plano son suelos o alfombras; las de los muebles, muebles).
func _pieces(p: Pintor, map_id: String, grid: Array, legend: Dictionary, is_plan: bool) -> void:
	var done := {}
	for y: int in grid.size():
		for x: int in str(grid[y]).length():
			var at := Vector2i(x, y)
			var c := _char(grid, at)
			if done.has(at) or c in [".", " ", "#", "S", "E"] or _is_mark(c, is_plan):
				continue
			if not legend.has(c):
				_fail(map_id, "«%s» en %s no está en la leyenda" % [c, at])
				done[at] = true
				continue
			var spec: Dictionary = legend[c]
			if spec.has("suelo") and is_plan:
				done[at] = true
				continue
			var block := _block(grid, at, c, done)
			_stamp(p, map_id, spec, block)


static func _is_mark(c: String, is_plan: bool) -> bool:
	if is_plan:
		return false
	return c in TRAINER_MARKS or c in GUARD_MARKS or c in ASIDE_MARKS or c in NPC_MARKS or c in SIGN_MARKS or c == LEADER_MARK


## Rectángulo de la letra `c` que empieza en `at` (hacia la derecha y hacia abajo).
static func _block(grid: Array, at: Vector2i, c: String, done: Dictionary) -> Rect2i:
	var w := 0
	while _char(grid, at + Vector2i(w, 0)) == c and not done.has(at + Vector2i(w, 0)):
		w += 1
	var h := 0
	while true:
		var full := true
		for dx: int in w:
			if _char(grid, at + Vector2i(dx, h)) != c or done.has(at + Vector2i(dx, h)):
				full = false
				break
		if not full:
			break
		h += 1
	var rect := Rect2i(at, Vector2i(w, h))
	for cell: Vector2i in Pintor.cells(rect):
		done[cell] = true
	return rect


func _layer(p: Pintor, spec: Dictionary) -> TileMapLayer:
	match str(spec.get("capa", "decor")):
		"suelo":
			return p.ground
		"arriba":
			return p.above
	return p.decor


## Pone una pieza en un bloque. Tipos: "pieza" [fuente, x, y, ancho, alto] (se repite para llenar el bloque;
## "arriba": n = sus n primeras filas van por encima de los personajes), "nueve" [fuente, x, y] (recuadro de
## 3×3 estirado), "fila" [fuente, x, y] (izquierda, centro y derecha), "columna" [fuente, x, y] (arriba,
## centro y abajo), "baldosa" [fuente, x, y] (la misma en todas) y "objeto" (pieza grande del tileset de
## exteriores: casillas de abajo a la izquierda del bloque).
func _stamp(p: Pintor, map_id: String, spec: Dictionary, block: Rect2i) -> void:
	var layer := _layer(p, spec)
	var flip := TileSetAtlasSource.TRANSFORM_FLIP_H if bool(spec.get("espejo", false)) else 0
	if spec.has("pieza"):
		var t: Array = spec["pieza"]
		var src := int(t[0])
		var size := Vector2i(int(t[3]), int(t[4]))
		var high := int(spec.get("arriba", 0))
		if block.size.x % size.x != 0 or block.size.y % size.y != 0:
			_fail(map_id, "la pieza de %s en %s no cabe en %s" % [size, block.position, block.size])
		for oy: int in range(0, block.size.y, size.y):
			for ox: int in range(0, block.size.x, size.x):
				for dy: int in size.y:
					for dx: int in size.x:
						var sx := (size.x - 1 - dx) if flip else dx
						var cell := block.position + Vector2i(ox + dx, oy + dy)
						var target := p.above if dy < high else layer
						target.set_cell(cell, src, Vector2i(int(t[1]) + sx, int(t[2]) + dy), flip)
	elif spec.has("nueve"):
		var t: Array = spec["nueve"]
		var high := int(spec.get("arriba", 0))
		for cell: Vector2i in Pintor.cells(block):
			var cx := 0 if cell.x == block.position.x else (2 if cell.x == block.end.x - 1 else 1)
			var cy := 0 if cell.y == block.position.y else (2 if cell.y == block.end.y - 1 else 1)
			var target := p.above if cell.y - block.position.y < high else layer
			target.set_cell(cell, int(t[0]), Vector2i(int(t[1]) + cx, int(t[2]) + cy))
	elif spec.has("fila"):
		# Las "arriba" primeras filas (la tapa de un mostrador, por ejemplo) van por encima de los personajes
		# y se pisan: así alguien puede estar detrás.
		var t: Array = spec["fila"]
		var high := int(spec.get("arriba", 0))
		for cell: Vector2i in Pintor.cells(block):
			var cx := 0 if cell.x == block.position.x else (2 if cell.x == block.end.x - 1 else 1)
			var dy := cell.y - block.position.y
			var target := p.above if dy < high else layer
			if block.size.x == 1 and spec.has("sola"):
				var s: Array = spec["sola"]
				target.set_cell(cell, int(s[0]), Vector2i(int(s[1]), int(s[2]) + dy))
				continue
			target.set_cell(cell, int(t[0]), Vector2i(int(t[1]) + cx, int(t[2]) + dy))
	elif spec.has("columna"):
		var t: Array = spec["columna"]
		for cell: Vector2i in Pintor.cells(block):
			var cy := 0 if cell.y == block.position.y else (2 if cell.y == block.end.y - 1 else 1)
			layer.set_cell(cell, int(t[0]), Vector2i(int(t[1]) + cell.x - block.position.x, int(t[2]) + cy))
	elif spec.has("baldosa"):
		var t: Array = spec["baldosa"]
		for cell: Vector2i in Pintor.cells(block):
			layer.set_cell(cell, int(t[0]), Vector2i(int(t[1]), int(t[2])), flip)
	elif spec.has("objeto"):
		p.object(StringName(str(spec["objeto"])), Vector2i(block.position.x, block.end.y - 1))
	else:
		_fail(map_id, "pieza sin tipo en %s" % block.position)


## Entrenadores, vigilantes, personajes, carteles y líder, en las marcas de la rejilla de muebles.
func _people(p: Pintor, map_id: String, city: String, gym: Dictionary, room: Dictionary, grid: Array,
		is_leader: bool) -> void:
	var trainers: Array = room.get("entrenadores", [])
	var guards: Array = room.get("vigilantes", [])
	var npcs: Array = room.get("npcs", [])
	var signs: Array = room.get("carteles", [])
	var placed := {}
	for y: int in grid.size():
		for x: int in str(grid[y]).length():
			var at := Vector2i(x, y)
			var c := _char(grid, at)
			if c in TRAINER_MARKS:
				var i := TRAINER_MARKS.find(c)
				if i >= trainers.size():
					_fail(map_id, "el entrenador %s no está en la lista" % c)
					continue
				var t: Dictionary = trainers[i]
				var node_name := "Entrenador%d" % (i + 1)
				p.trainer(node_name, StringName(str(t["id"])), at, int(FACING[str(t.get("mira", "abajo"))]), int(t.get("vista", 2)))
				_props(p.root.get_node("Entities/" + node_name), t)
				placed[c] = true
			elif c in GUARD_MARKS or c in ASIDE_MARKS:
				var aside := c in ASIDE_MARKS
				var i := (ASIDE_MARKS if aside else GUARD_MARKS).find(c)
				if i >= guards.size():
					_fail(map_id, "el vigilante %s no está en la lista" % c)
					continue
				var g: Dictionary = guards[i]
				var after := str(g.get("tras", trainers[i]["id"] if i < trainers.size() else ""))
				var flag := StringName(DEFEATED_FLAG % after)
				var lines: Array = g.get("despues" if aside else "frases", [])
				var props := {"display_name": str(g.get("nombre", "")), ("visible_if_flag" if aside else "hidden_if_flag"): flag}
				if str(g.get("arte", "")) != "":
					props["art_id"] = StringName(str(g["arte"]))
				var facing := int(FACING[str(g.get("mira_aparte" if aside else "mira", "abajo"))])
				p.npc("Vigilante%d%s" % [i + 1, "Aparte" if aside else ""], str(g.get("sprite", gym.get("guardia", "npc_man"))),
					at, facing, PackedStringArray(lines), props)
				placed[c] = true
			elif c in NPC_MARKS:
				var i := NPC_MARKS.find(c)
				if i >= npcs.size():
					_fail(map_id, "el personaje %s no está en la lista" % c)
					continue
				var n: Dictionary = npcs[i]
				var props := {"display_name": str(n.get("nombre", ""))}
				if str(n.get("arte", "")) != "":
					props["art_id"] = StringName(str(n["arte"]))
				if bool(n.get("pasea", false)):
					props["wander"] = true
					props["wander_radius"] = int(n.get("radio", 1))
				p.npc(str(n.get("nodo", "Personaje%d" % (i + 1))), str(n.get("sprite", "npc_man")), at,
					int(FACING[str(n.get("mira", "abajo"))]), PackedStringArray(n.get("frases", [])), props)
				_props(p.root.get_node("Entities/" + str(n.get("nodo", "Personaje%d" % (i + 1)))), n)
				placed[c] = true
			elif c in SIGN_MARKS:
				var i := SIGN_MARKS.find(c)
				if i >= signs.size():
					_fail(map_id, "el cartel %s no está en la lista" % c)
					continue
				var s: Dictionary = signs[i]
				p.sign_text("Cartel%d" % (i + 1), at, PackedStringArray(s.get("frases", [])))
				var node := p.root.get_node("Entities/Cartel%d" % (i + 1))
				node.set(&"show_sprite", bool(s.get("poste", false)))
				node.set(&"only_from_below", bool(s.get("solo_desde_abajo", true)))
				placed[c] = true
			elif c == LEADER_MARK:
				if city == "madrid":
					p.npc("Ayuso", "ayuso", at, DOWN, PackedStringArray(), {"event": load(AYUSO_EVENT), "display_name": "Ayuso"})
				else:
					p.trainer("Lider", StringName(str(gym["lider"])), at, int(FACING[str(room.get("mira_lider", "abajo"))]), 0)
					p.root.get_node("Entities/Lider").set(&"challenge_event", load(LEADER_EVENT))
				placed[c] = true
	for i: int in trainers.size():
		if not placed.has(TRAINER_MARKS[i]):
			_fail(map_id, "el entrenador %d (%s) no tiene casilla" % [i + 1, trainers[i]["id"]])
	for i: int in guards.size():
		if not placed.has(GUARD_MARKS[i]):
			_fail(map_id, "el vigilante %d no tiene casilla" % (i + 1))
	if is_leader and not placed.has(LEADER_MARK):
		_fail(map_id, "falta el líder (@)")


## Flags que piden los datos ("aparece_con" / "se_va_con").
static func _props(node: Node, entry: Dictionary) -> void:
	if entry.has("aparece_con"):
		node.set(&"visible_if_flag", StringName(str(entry["aparece_con"])))
	if entry.has("se_va_con"):
		node.set(&"hidden_if_flag", StringName(str(entry["se_va_con"])))


## La salida (felpudo 'E') y la puerta a la sala siguiente ('S', en la cara de la pared de arriba).
func _doors_v2(p: Pintor, map_id: String, city: String, plano: Array, style: Dictionary, index: int, total: int) -> void:
	var exit := Vector2i(-1, -1)
	var next := Vector2i(-1, -1)
	for y: int in plano.size():
		for x: int in str(plano[y]).length():
			match _char(plano, Vector2i(x, y)):
				"E":
					exit = Vector2i(x, y)
				"S":
					next = Vector2i(x, y)
	if exit.x < 0:
		return _fail(map_id, "falta la salida (E)")
	# El felpudo (una o varias casillas) acaba en la casilla de la salida, centrado en ella.
	var mat: Array = style.get("felpudo", [])
	if not mat.is_empty():
		var mat_size := Vector2i(int(mat[3]), int(mat[4])) if mat.size() >= 5 else Vector2i.ONE
		var mat_origin := exit - Vector2i(mat_size.x / 2, mat_size.y - 1)
		for dy: int in mat_size.y:
			for dx: int in mat_size.x:
				p.decor.set_cell(mat_origin + Vector2i(dx, dy), int(mat[0]), Vector2i(int(mat[1]) + dx, int(mat[2]) + dy))
	p.spawn("default", exit + Vector2i.UP)
	if index == 0:
		var entry: Array = ENTRADAS[city]
		p.warp("Salida", exit, StringName(str(entry[0])), StringName(str(entry[1])))
	else:
		p.warp("Salida", exit, StringName(_id(city, index - 1, total)), &"from_arriba")
	p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	if index >= total:
		if next.x >= 0:
			_fail(map_id, "la sala del líder no lleva puerta de arriba")
		return
	if next.x < 0:
		return _fail(map_id, "falta la puerta de arriba (S)")
	var floor_tile: Array = style["suelo"]
	p.ground.set_cell(next, int(floor_tile[0]), Vector2i(int(floor_tile[1]), int(floor_tile[2])))
	var door: Array = style.get("puerta", [])
	if not door.is_empty():
		var size := Vector2i(int(door[3]), int(door[4]))
		var origin := next - Vector2i(size.x / 2, size.y - 1)
		for dy: int in size.y:
			for dx: int in size.x:
				p.decor.set_cell(origin + Vector2i(dx, dy), int(door[0]), Vector2i(int(door[1]) + dx, int(door[2]) + dy))
	p.spawn("from_arriba", next + Vector2i.DOWN)
	p.warp("Siguiente", next, StringName(_id(city, index + 1, total)), &"default")
	p.root.get_node("Warps/Siguiente").arrival_facing = Warp.Facing.UP


## Rótulo de la sala sobre la pared: el texto de la sala centrado en la placa que empieza en "rotulo_casilla"
## (su casilla de la izquierda) y mide "rotulo_ancho" casillas.
func _title(p: Pintor, room: Dictionary, style: Dictionary, size: Vector2i) -> void:
	var text := str(room.get("rotulo", str(room["titulo"]).get_slice(" · ", 1)))
	var width := int(room.get("rotulo_ancho", style.get("rotulo_ancho", 6)))
	var cell: Array = room.get("rotulo_casilla", style.get("rotulo_casilla", [(size.x - width) / 2, 1]))
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(int(cell[0]) * 32, int(cell[1]) * 32 + int(style.get("rotulo_y", 7)))
	label.size = Vector2(width * 32, 20)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(str(style.get("rotulo_color", "f8f8f0"))))
	label.add_theme_color_override("font_shadow_color", Color(str(style.get("rotulo_sombra", "303048"))))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	p.root.add_child(label)


# --- Salas antiguas (zigzag automático, hasta que cada gimnasio tenga su plano) ---

func _shell(city: String, gym: Dictionary, map_id: String, title: String) -> Pintor:
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = title.capitalize()
	d.zone_id = StringName(city)
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Gimnasio", SIZE, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	var floor_tile: Vector2i = FLOORS[int(gym["suelo"]) % FLOORS.size()]
	var wall: int = WALLS[int(gym["pared"]) % WALLS.size()]
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, SIZE)):
		p.ground.set_cell(at, 0, floor_tile)
	for x: int in SIZE.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall))
		if x != 8:
			p.decor.set_cell(Vector2i(x, 11), 1, Vector2i(1, wall))
	for y: int in range(2, 11):
		for x: int in [0, 15]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(8, 4)
	label.size = Vector2(SIZE.x * 32 - 16, 24)
	label.text = title.replace(" · ", ": ")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("fff4d8"))
	label.add_theme_color_override("font_shadow_color", Color("303048"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	p.root.add_child(label)
	p.spawn("default", Vector2i(8, 10))
	return p


## Tabiques y tramos. Devuelve, por tramo, [casilla del entrenador, hacia dónde mira, casilla del paso].
func _zigzag(p: Pintor, gym: Dictionary, mirrored: bool, sections: int) -> Array:
	var wall: int = WALLS[int(gym["pared"]) % WALLS.size()]
	var gap_a := 2 if mirrored else 13
	var gap_b := 13 if mirrored else 2
	if sections >= 1:
		for x: int in range(1, 15):
			if x != gap_a:
				p.decor.set_cell(Vector2i(x, 7), 1, Vector2i(1, wall))
	if sections >= 2:
		for x: int in range(1, 15):
			if x != gap_b:
				p.decor.set_cell(Vector2i(x, 4), 1, Vector2i(1, wall))
	# Mobiliario del tramo de entrada, en el lado contrario al entrenador, y plantas en las esquinas.
	var prop := Rect2i(3, 52, 3, 2) if int(gym["suelo"]) % 2 == 0 else Rect2i(3, 59, 3, 2)
	_piece(p, Vector2i(3 if mirrored else 10, 9), prop)
	_piece(p, Vector2i(1, 9), Rect2i(0, 36, 1, 2))
	_piece(p, Vector2i(14, 9), Rect2i(2, 36, 1, 2))
	var out: Array = [
		[Vector2i(11 if mirrored else 4, 9), LEFT if mirrored else RIGHT, Vector2i(gap_a, 7)],
		[Vector2i(4 if mirrored else 11, 5), RIGHT if mirrored else LEFT, Vector2i(gap_b, 4)],
		[Vector2i(11 if mirrored else 5, 3), LEFT if mirrored else RIGHT, Vector2i(8, 2)],
	]
	return out


func _gate(p: Pintor, gym: Dictionary, index: int, cell: Vector2i, trainer: Dictionary) -> void:
	p.npc("Vigilante%d" % index, str(gym["guardia"]), cell, DOWN, PackedStringArray([
		"Por aquí no se pasa todavía.", "Primero tienes que ganar a %s. Aquí se entra por orden, como en todas partes menos en la lista de espera." % trainer["nombre"]]),
		{"hidden_if_flag": StringName("trainer_defeated:%s" % str(trainer["id"]))})


func _room(city: String, gym: Dictionary, index: int, total: int) -> void:
	var room: Dictionary = gym["salas"][index]
	var map_id := _id(city, index, total)
	var p := _shell(city, gym, map_id, str(room["titulo"]))
	var trainers: Array = room["entrenadores"]
	var sections := _zigzag(p, gym, index % 2 == 1, mini(trainers.size(), 2))
	for i: int in trainers.size():
		var t: Dictionary = trainers[i]
		p.trainer("Entrenador%d" % (i + 1), StringName(str(t["id"])), sections[i][0], sections[i][1], 2)
		_gate(p, gym, i + 1, sections[i][2], t)
	_doors(p, city, index, total)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


func _leader_room(city: String, gym: Dictionary, total: int) -> void:
	var map_id := _id(city, total, total)
	var p := _shell(city, gym, map_id, str(gym["lider_titulo"]))
	var before: Array = gym.get("lider_previos", [])
	var sections := _zigzag(p, gym, total % 2 == 1, mini(before.size(), 2))
	for i: int in before.size():
		var t: Dictionary = before[i]
		p.trainer("Entrenador%d" % (i + 1), StringName(str(t["id"])), sections[i][0], sections[i][1], 2)
		_gate(p, gym, i + 1, sections[i][2], t)
	var leader := Vector2i(8, 2)
	p.trainer("Lider", StringName(str(gym["lider"])), leader, DOWN, 0)
	p.root.get_node("Entities/Lider").set(&"challenge_event", load(LEADER_EVENT))
	_doors(p, city, total, total)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


## Salida por abajo (a la calle o a la sala anterior) y, si no es la del líder, puerta arriba a la siguiente.
func _doors(p: Pintor, city: String, index: int, total: int) -> void:
	if index == 0:
		var entry: Array = ENTRADAS[city]
		if str(entry[0]) != "":
			p.warp("Salida", Vector2i(8, 11), StringName(str(entry[0])), StringName(str(entry[1])))
			p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	else:
		p.warp("Salida", Vector2i(8, 11), StringName(_id(city, index - 1, total)), &"from_arriba")
		p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	if index < total:
		p.decor.erase_cell(Vector2i(8, 1))
		p.spawn("from_arriba", Vector2i(8, 2))
		p.warp("Siguiente", Vector2i(8, 1), StringName(_id(city, index + 1, total)), &"default")
		p.root.get_node("Warps/Siguiente").arrival_facing = Warp.Facing.UP


func _piece(p: Pintor, at: Vector2i, rect: Rect2i) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), 2, rect.position + Vector2i(x, y))
