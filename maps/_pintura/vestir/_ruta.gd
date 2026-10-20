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


const FACING: Array[Vector2i] = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]
const FAR := 1 << 20


## Recoloca los entrenadores propios de la ruta (los de data/trainers/<ruta>.json que no van en pareja
## ni se colocan por datos) en pasos estrechos, como en Añil: mirando a través del camino (mejor de
## espaldas a una pared), de forma que para no cruzar su vista (5 casillas como mucho) haya que pisar más
## hierba o no se pueda. Se reparten a lo largo de la ruta entre las dos primeras conexiones y no tapan el paso.
## Devuelve cuántos ha movido.
static func entrenadores_en_pasos(v: Vestidor) -> int:
	var conns: Array = v.map.get(&"data").connections
	if conns.size() < 2:
		v.note("entrenadores: la ruta no tiene dos bordes; no se mueven")
		return 0
	var own := JsonFile.read_dict("res://data/trainers/%s.json" % v.mid.get_slice("/", 0))
	var data_ids := {}
	for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
		if entry.get("mapa", "") == v.mid:
			data_ids[String(entry.get("id", ""))] = true
	var movers: Array[Node2D] = []
	var partners := {}
	for node: Node in v.entities.get_children():
		var p: Variant = node.get(&"partner")
		if p is NodePath and p != NodePath():
			partners[String(node.name)] = true
			partners[String(p).get_file()] = true
	for node: Node in v.entities.get_children():
		var tid: Variant = node.get(&"trainer_id")
		if tid == null or not own.has(String(tid)) or partners.has(String(node.name)) \
				or data_ids.has(String(tid)) or data_ids.has(String(node.name)):
			continue
		movers.append(node as Node2D)
	if movers.is_empty():
		return 0
	var walk := v.free.duplicate()
	for node: Node2D in movers:
		walk[Grid.to_tile(node.position)] = true
	var forbid := {}
	for warp: Node in v.map.get_node("Warps").get_children():
		var at := Grid.to_tile((warp as Node2D).position)
		walk.erase(at)
		_ring(forbid, at, 1)
	for cell: Vector2i in v.objects.get_used_cells():
		var id := v.object_at(cell)
		if id != &"" and v.catalog[id].door.x >= 0:
			_ring(forbid, cell + v.catalog[id].door, 2)
	var edges := {}
	for c: Resource in conns:
		for at: Vector2i in v.edge_cells(c):
			_ring(forbid, at, 2)
			_ring(edges, at, 1)
	for node: Node in v.entities.get_children():
		if node == v.objects or not node is Node2D or node in movers:
			continue
		var at := Grid.to_tile((node as Node2D).position)
		_ring(forbid, at, 1)
		var sight: Variant = node.get(&"sight_range")
		if sight != null and node.get(&"trainer_id") != null:
			var f := FACING[clampi(int(node.get(&"initial_facing")), 0, 3)]
			for n: int in range(1, int(sight) + 1):
				forbid[at + f * n] = true
	var a: Array[Vector2i] = v.edge_cells(conns[0]).filter(func(t: Vector2i) -> bool: return walk.has(t))
	var b: Array[Vector2i] = v.edge_cells(conns[1]).filter(func(t: Vector2i) -> bool: return walk.has(t))
	var da := _cost01(v, walk, a, {})
	var db := _cost01(v, walk, b, {})
	var base := _best(da, b)
	var steps := _plain(walk, a)
	if base >= FAR:
		v.note("entrenadores: no se cruza la ruta")
		return 0
	var cands: Array = []
	for t: Vector2i in walk:
		if forbid.has(t) or v.is_encounter(t) or not steps.has(t):
			continue
		for fi: int in 4:
			var f := FACING[fi]
			var line: Array[Vector2i] = []
			while line.size() < 5 and walk.has(t + f * (line.size() + 1)):
				line.append(t + f * (line.size() + 1))
			if line.is_empty():
				continue
			var crosses := 0
			var clean := true
			for c: Vector2i in line:
				clean = clean and not edges.has(c)
				if da.has(c) and db.has(c) and da[c] + db[c] - (1 if v.is_encounter(c) else 0) == base:
					crosses += 1
			if crosses > 0 and clean:
				cands.append([t, fi, line, crosses, not walk.has(t - f)])
	cands.sort_custom(func(x: Array, y: Array) -> bool: return x[3] > y[3])
	var scored: Array = []
	for c: Array in cands.slice(0, 500):
		var block := {c[0]: true}
		for l: Vector2i in c[2]:
			block[l] = true
		var dodge := _best(_cost01(v, walk, a, block), b)
		if dodge <= base:
			continue
		if _best(_cost01(v, walk, a, {c[0]: true}), b) >= FAR:
			continue
		scored.append([mini(dodge - base, 3), steps[c[0]], c])
	if scored.is_empty():
		v.note("entrenadores: no hay pasos estrechos")
		return 0
	var span := 1
	for s: Array in scored:
		span = maxi(span, int(s[1]))
	var chosen: Array = []
	var moved := 0
	for i: int in movers.size():
		# Cada uno se queda en su tramo de la ruta (los niveles y el orden no cambian).
		var target := float(steps.get(Grid.to_tile(movers[i].position), span * (i + 1) / float(movers.size() + 1)))
		var best: Array = []
		var best_score := -INF
		for s: Array in scored:
			var c: Array = s[2]
			var ok := true
			for other: Array in chosen:
				ok = ok and (absi(c[0].x - other[0].x) + absi(c[0].y - other[0].y)) >= 8
				for l: Vector2i in c[2]:
					ok = ok and l != other[0] and not l in other[2]
			if not ok or absf(float(s[1]) - target) > span * 0.3:
				continue
			var score := float(s[0]) * 4.0 + (2.0 if c[4] else 0.0) - absf(float(s[1]) - target) / span * 10.0
			if score > best_score:
				best_score = score
				best = c
		if best.is_empty():
			v.note("entrenadores: %s se queda donde estaba (no hay un paso estrecho libre en su tramo)" % movers[i].name)
			continue
		chosen.append(best)
		var node := movers[i]
		v.note("entrenador %s: %s → %s mirando %s, vista %d" % [node.name, Grid.to_tile(node.position), best[0], FACING[best[1]], best[2].size()])
		v.move(String(node.name), best[0], best[1])
		node.set(&"sight_range", best[2].size())
		moved += 1
	return moved


static func _ring(out: Dictionary, at: Vector2i, radius: int) -> void:
	for y: int in range(-radius, radius + 1):
		for x: int in range(-radius, radius + 1):
			out[at + Vector2i(x, y)] = true


## Coste mínimo en casillas de hierba alta desde `starts` (0-1), sin pasar por `block`.
static func _cost01(v: Vestidor, walk: Dictionary, starts: Array[Vector2i], block: Dictionary) -> Dictionary:
	var cost := {}
	var queue: Array[Vector2i] = []
	for at: Vector2i in starts:
		if not block.has(at):
			cost[at] = 1 if v.is_encounter(at) else 0
			queue.append(at)
	while not queue.is_empty():
		var at: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := at + d
			if not walk.has(n) or block.has(n):
				continue
			var g := 1 if v.is_encounter(n) else 0
			var next := int(cost[at]) + g
			if not cost.has(n) or next < int(cost[n]):
				cost[n] = next
				if g == 1:
					queue.push_back(n)
				else:
					queue.push_front(n)
	return cost


static func _best(cost: Dictionary, goal: Array[Vector2i]) -> int:
	var best := FAR
	for at: Vector2i in goal:
		if cost.has(at):
			best = mini(best, int(cost[at]))
	return best


static func _plain(walk: Dictionary, starts: Array[Vector2i]) -> Dictionary:
	var dist := {}
	var queue: Array[Vector2i] = []
	for at: Vector2i in starts:
		dist[at] = 0
		queue.append(at)
	var cursor := 0
	while cursor < queue.size():
		var at := queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := at + d
			if walk.has(n) and not dist.has(n):
				dist[n] = dist[at] + 1
				queue.append(n)
	return dist
