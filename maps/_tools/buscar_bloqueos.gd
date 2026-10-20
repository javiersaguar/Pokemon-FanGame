extends SceneTree
## Propone sitios para obstáculos de campo y atajos en un exterior ya pintado (no cambia nada):
## - bolsas: casillas de paso de una sola casilla de ancho que, tapadas, dejan aparte una zona pequeña
##   sin puertas, pasarelas, bordes ni personajes (solo objetos): ahí va una roca o un arbolillo.
## - atajos: muros finos (bosque, seto, valla o piedras, de 1 a 3 casillas) entre dos zonas a las que se
##   llega, de dos casillas de ancho y que ahorran mucho camino: ahí va un tronco que se aparta desde un lado.
## Uso: godot --headless --path . -s res://maps/_tools/buscar_bloqueos.gd -- <mapa>...

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func _initialize() -> void:
	await process_frame
	for mid: String in OS.get_cmdline_user_args():
		await _find(mid)
	quit()


func _find(mid: String) -> void:
	var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var v := Vestidor.new()
	v.setup(map, mid)
	v.scan(root.get_world_2d().direct_space_state)
	var starts: Array[Vector2i] = []
	for c: Resource in map.get(&"data").connections:
		for at: Vector2i in v.edge_cells(c):
			if v.free.has(at):
				starts.append(at)
	var base := _bfs(v, starts, {})
	var items := {}
	var others := {}
	for node: Node in v.entities.get_children():
		if node == v.objects or not node is Node2D:
			continue
		var at := Grid.to_tile((node as Node2D).position)
		if node.get(&"item_id") != null:
			items[at] = node.name
		else:
			for d: Vector2i in DIRS:
				others[at + d] = node.name
	for warp: Node in map.get_node("Warps").get_children():
		others[Grid.to_tile((warp as Node2D).position)] = warp.name
	print("== %s: %d casillas desde los bordes" % [mid, base.size()])
	var pockets: Array = []
	for at: Vector2i in base:
		if v.protected.has(at) or v.is_encounter(at):
			continue
		var n := 0
		for d: Vector2i in DIRS:
			n += 1 if base.has(at + d) else 0
		if n != 2:
			continue
		var seen := _bfs(v, starts, {at: true})
		if seen.size() < base.size() - 81 or seen.size() > base.size() - 4:
			continue
		var cut: Array[Vector2i] = []
		var bad := ""
		var loot: Array = []
		for t: Vector2i in base:
			if seen.has(t) or t == at:
				continue
			cut.append(t)
			if others.has(t):
				bad = others[t]
			if items.has(t):
				loot.append(items[t])
			for d: Vector2i in DIRS:
				if items.has(t + d) and not loot.has(items[t + d]):
					loot.append(items[t + d])
		if bad == "" and not _edge(v, cut):
			pockets.append([cut.size(), at, loot, _box(cut)])
	pockets.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	for p: Array in pockets.slice(0, 5):
		print("  bolsa: tapar %s deja %d casillas %s; objetos %s" % [p[1], p[0], p[3], p[2]])
	var shortcuts: Array = []
	for at: Vector2i in base:
		for dir: Vector2i in [Vector2i.DOWN, Vector2i.RIGHT]:
			var side := Vector2i(dir.y, dir.x)
			if not base.has(at + side):
				continue
			for k: int in range(1, 6):
				var ok := true
				for s: int in 2:
					for i: int in range(1, k + 1):
						ok = ok and _removable(v, at + side * s + dir * i)
					ok = ok and base.has(at + side * s + dir * (k + 1))
				if not ok:
					continue
				var steps := _steps(v, at, at + dir * (k + 1))
				if steps >= 14:
					shortcuts.append([steps, at, dir, k])
				break
	shortcuts.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	var shown := 0
	var used := {}
	for s: Array in shortcuts:
		var key := Vector2i(s[1].x / 6, s[1].y / 6)
		if used.has(key):
			continue
		used[key] = true
		print("  atajo: desde %s hacia %s, muro de %d, ahorra %d pasos" % [s[1], "abajo" if s[2] == Vector2i.DOWN else "la derecha", s[3], s[0]])
		shown += 1
		if shown >= 5:
			break
	map.queue_free()
	await process_frame


func _removable(v: Vestidor, at: Vector2i) -> bool:
	if v.free.has(at) or v.protected.has(at) or v.covered.has(at) or not v.bounds.has_point(at):
		return false
	var id := v.object_at(at)
	if id != &"":
		return v.catalog[id].door.x < 0 and v.catalog[id].source in [ExteriorTiles.SRC_ARBOLES, ExteriorTiles.SRC_VALLAS, ExteriorTiles.SRC_ADORNOS]
	return v.forest.has(at) or (v.decor.get_cell_source_id(at) != -1 and v.terrain(at) not in ["cliff", "water"])


func _edge(v: Vestidor, cells: Array[Vector2i]) -> bool:
	for t: Vector2i in cells:
		if t.x == v.bounds.position.x or t.y == v.bounds.position.y or t.x == v.bounds.end.x - 1 or t.y == v.bounds.end.y - 1:
			return true
	return false


func _box(cells: Array[Vector2i]) -> Rect2i:
	var r := Rect2i(cells[0], Vector2i.ONE)
	for t: Vector2i in cells:
		r = r.expand(t).expand(t + Vector2i.ONE)
	return r


func _bfs(v: Vestidor, starts: Array[Vector2i], blocked: Dictionary) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2i] = []
	for t: Vector2i in starts:
		if not blocked.has(t):
			seen[t] = true
			queue.append(t)
	var cursor := 0
	while cursor < queue.size():
		var t := queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := t + d
			if v.free.has(n) and not seen.has(n) and not blocked.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func _steps(v: Vestidor, a: Vector2i, b: Vector2i) -> int:
	var dist := {a: 0}
	var queue: Array[Vector2i] = [a]
	var cursor := 0
	while cursor < queue.size():
		var t := queue[cursor]
		cursor += 1
		if t == b:
			return dist[t]
		for d: Vector2i in DIRS:
			var n := t + d
			if v.free.has(n) and not dist.has(n):
				dist[n] = dist[t] + 1
				queue.append(n)
	return 9999
