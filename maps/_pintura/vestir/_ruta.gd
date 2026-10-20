extends RefCounted
## Ayudantes comunes de las recetas de rutas (maps/_pintura/vestir/ruta_*.gd). No es una receta: se
## carga con preload.

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


## Rompe una avenida empedrada recta de `rect` (vertical): el empedrado pasa a hierba y queda un camino
## de tierra de dos casillas que va de un lado a otro de la antigua avenida cada `step` filas. No pisa
## la hierba alta (los pasos obligados se quedan). Devuelve las casillas del camino.
static func romper_avenida(v: Vestidor, rect: Rect2i, step: int = 8) -> Array[Vector2i]:
	var old: Array[Vector2i] = []
	for at: Vector2i in Pintor.cells(rect):
		if v.paving.has(at):
			old.append(at)
	v.clear_cells(old)
	for at: Vector2i in old:
		for d: Vector2i in DIRS:
			v._paving_dirty[at + d] = true
	var lane := []
	var left := true
	var y := rect.position.y
	var x_left := rect.position.x
	var x_right := rect.end.x - 2
	while y < rect.end.y:
		var x := x_left if left else x_right
		var seg_end := mini(y + step, rect.end.y)
		lane.append(Rect2i(x, y, 2, seg_end - y))
		if seg_end < rect.end.y:
			lane.append(Rect2i(x_left, seg_end - 2, x_right + 2 - x_left, 2))
		left = not left
		y = seg_end
	var cells: Array[Vector2i] = []
	for at: Vector2i in Vestidor.rects(lane):
		if v.terrain(at) != "tall_grass" and at not in cells:
			cells.append(at)
	v.path(cells)
	v.build()
	await v.refresh()
	return cells


## Atajo que se abre más tarde (Vestidor.shortcut): el tronco o la cancela se abre desde el lado que
## queda más cerca, andando, del borde que lleva a `toward` (el que se alcanza dando la vuelta larga).
static func atajo(v: Vestidor, node_name: String, from: Vector2i, dir: Vector2i, wall: int, toward: String) -> void:
	var goal: Array[Vector2i] = []
	for c: Resource in v.map.get(&"data").connections:
		if String(c.target_map) == toward:
			goal = v.edge_cells(c)
	if goal.is_empty():
		v.note("AVISO: %s sin borde hacia %s" % [node_name, toward])
	var near := _steps_to(v, from, goal) <= _steps_to(v, from + dir * (wall + 1), goal)
	v.shortcut(node_name, from, dir, wall, -dir if near else dir, StringName("atajo:%s:%s" % [v.mid, node_name]))


## Obstáculo de campo en la entrada (`entrance`, de una casilla) de una bolsa pequeña sin salidas y, si
## se pide, un objeto en la casilla de la bolsa más alejada de la entrada.
static func bolsa(v: Vestidor, node_name: String, action: String, entrance: Vector2i, item_name: String = "", item_id: StringName = &"") -> void:
	var starts: Array[Vector2i] = []
	for c: Resource in v.map.get(&"data").connections:
		for at: Vector2i in v.edge_cells(c):
			if v.free.has(at):
				starts.append(at)
	var outside := _flood(v, starts, entrance)
	var inner: Array[Vector2i] = []
	for d: Vector2i in DIRS:
		if v.free.has(entrance + d) and not outside.has(entrance + d):
			inner.append(entrance + d)
	var pocket := _flood(v, inner, entrance)
	if pocket.is_empty() or pocket.size() > 80:
		v.note("AVISO: %s en %s no cierra una bolsa (%d casillas)" % [node_name, entrance, pocket.size()])
		return
	v.obstacle(node_name, action, entrance)
	if item_name == "":
		return
	var best := inner[0]
	for at: Vector2i in pocket:
		if not v.protected.has(at) and pocket[at] > pocket[best]:
			best = at
	v.item(item_name, item_id, best)


## Casillas libres a las que se llega desde `starts` sin pasar por `wall`, con su distancia.
static func _flood(v: Vestidor, starts: Array[Vector2i], wall: Vector2i) -> Dictionary:
	var dist := {}
	var queue: Array[Vector2i] = []
	for at: Vector2i in starts:
		if at != wall and not dist.has(at):
			dist[at] = 0
			queue.append(at)
	var cursor := 0
	while cursor < queue.size():
		var at := queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := at + d
			if n != wall and v.free.has(n) and not dist.has(n):
				dist[n] = dist[at] + 1
				queue.append(n)
	return dist


## Prueba los candidatos [from, dir, wall] en orden y pone el primero que, abierto, no deja cruzar la
## ruta sin pisar hierba (los pasos obligados se quedan).
static func atajo_primero(v: Vestidor, node_name: String, candidates: Array, toward: String) -> void:
	for c: Array in candidates:
		var side := Vector2i(c[1].y, c[1].x)
		var cells: Array[Vector2i] = []
		for s: int in 2:
			for i: int in range(1, int(c[2]) + 1):
				var at: Vector2i = c[0] + side * s + c[1] * i
				if not v.free.has(at):
					cells.append(at)
					v.free[at] = true
		var costs := v.grass_costs()
		for at: Vector2i in cells:
			v.free.erase(at)
		if costs.values().all(func(n: int) -> bool: return n > 0):
			atajo(v, node_name, c[0], c[1], c[2], toward)
			return
		v.note("atajo %s en %s: abierto se cruzaría sin hierba, se prueba otro" % [node_name, c[0]])
	v.note("AVISO: %s sin sitio" % node_name)


static func _steps_to(v: Vestidor, start: Vector2i, goal: Array[Vector2i]) -> int:
	var dist := {start: 0}
	var queue: Array[Vector2i] = [start]
	var cursor := 0
	while cursor < queue.size():
		var at := queue[cursor]
		cursor += 1
		if at in goal:
			return dist[at]
		for d: Vector2i in DIRS:
			var n := at + d
			if v.free.has(n) and not dist.has(n):
				dist[n] = dist[at] + 1
				queue.append(n)
	return 1 << 20
