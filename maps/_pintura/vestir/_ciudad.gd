extends RefCounted
## Mobiliario común de las recetas de ciudades (maps/_pintura/vestir/<ciudad>.gd): farolas y bancos en
## la hierba que bordea las calles, con una separación mínima, flores en los arriates y árboles en la
## hierba que se queda vacía lejos de calles y puertas. No es una receta: se carga con preload.
## El vestidor no tapa nada protegido (puertas, bordes, personajes y su vista) y vestir_exterior.gd no
## guarda si se deja de llegar a algo.

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


## Suelo de calle: empedrado, camino o cualquier suelo transitable que no sea hierba, arena o nieve
## (las plazas usan baldosas de varios packs).
static func _street(v: Vestidor, at: Vector2i) -> bool:
	return v.paving.has(at) or (v.free.has(at) and not v.water.has(at)
		and v.terrain(at) not in ["grass", "tall_grass", "sand", "snow"])


static func _far(at: Vector2i, placed: Array[Vector2i], gap: int) -> bool:
	for p: Vector2i in placed:
		if absi(p.x - at.x) < gap and absi(p.y - at.y) < gap:
			return false
	return true


static func _excluded(at: Vector2i, rects: Array) -> bool:
	for r: Rect2i in rects:
		if r.has_point(at):
			return true
	return false


## Farolas y bancos en la hierba libre pegada a una calle. Opciones: "farola" (id del catálogo),
## "paso_farolas", "paso_bancos" (separación mínima en casillas) y "excluir" (rectángulos).
static func amueblar(v: Vestidor, opts: Dictionary = {}) -> Dictionary:
	var lamp: StringName = opts.get("farola", &"farola_roja")
	var lamp_gap: int = opts.get("paso_farolas", 7)
	var bench_gap: int = opts.get("paso_bancos", 12)
	var excl: Array = opts.get("excluir", [])
	var lamps: Array[Vector2i] = []
	var benches: Array[Vector2i] = []
	for y: int in range(v.bounds.position.y + 1, v.bounds.end.y - 1):
		for x: int in range(v.bounds.position.x + 1, v.bounds.end.x - 1):
			var at := Vector2i(x, y)
			if not v.open(at) or _excluded(at, excl):
				continue
			var streets := 0
			for d: Vector2i in DIRS:
				if _street(v, at + d):
					streets += 1
			# Solo en el borde de la calle (una calle al lado), no en mitad de un paso estrecho.
			if streets != 1:
				continue
			if _far(at, lamps, lamp_gap):
				if v.object(lamp, at):
					lamps.append(at)
			elif _far(at, benches, bench_gap) and _far(at, lamps, 3):
				if v.object(&"banco", at):
					benches.append(at)
	v.note("  mobiliario: %d farolas y %d bancos" % [lamps.size(), benches.size()])
	return {"farolas": lamps.size(), "bancos": benches.size()}


static func _clear_around(v: Vestidor, at: Vector2i, r: int) -> bool:
	for dy: int in range(-r, r + 1):
		for dx: int in range(-r, r + 1):
			var c := at + Vector2i(dx, dy)
			if not v.bounds.has_point(c) or not v.free.has(c) or v.protected.has(c) or v.covered.has(c) \
					or not _street(v, c):
				return false
	return true


## Plazas y explanadas empedradas: árboles en alcorque y farolas en cuadrícula, solo donde todo
## alrededor es empedrado libre (así no se estrecha ningún paso). Opciones: "paso_plaza" (casillas
## entre árboles), "arbol_plaza", "farola" y "excluir".
static func arbolar_plazas(v: Vestidor, opts: Dictionary = {}) -> Dictionary:
	var step: int = opts.get("paso_plaza", 5)
	var tree_id: StringName = opts.get("arbol_plaza", &"arbol_redondo")
	var lamp: StringName = opts.get("farola", &"farola_roja")
	var excl: Array = opts.get("excluir", [])
	var trees := 0
	var lamps := 0
	for y: int in range(v.bounds.position.y + 2, v.bounds.end.y - 2):
		for x: int in range(v.bounds.position.x + 2, v.bounds.end.x - 2):
			var at := Vector2i(x, y)
			if posmod(x, step) != 0 or posmod(y, step) != 0 or _excluded(at, excl) or not _clear_around(v, at, opts.get("holgura", 1)):
				continue
			if posmod(x / step + y / step, 2) == 0:
				if v.object(tree_id, at):
					trees += 1
			elif v.object(lamp, at):
				lamps += 1
	v.note("  plazas: %d árboles y %d farolas" % [trees, lamps])
	return {"arboles": trees, "farolas": lamps}


## Lo de siempre de una manzana: mobiliario, luego árboles y adornos en la hierba vacía lejos de
## calles y puertas. Opciones de amueblar() más "arboles" (ids), "hueco", "adornos", "margen" y
## "excluir_relleno".
static func manzanas(v: Vestidor, opts: Dictionary = {}) -> void:
	amueblar(v, opts)
	arbolar_plazas(v, opts)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": opts.get("margen", [2, 2]),
		"arboles": opts.get("arboles", [&"arbol_redondo", &"arbol_verde"]), "hueco": opts.get("hueco", 2),
		"adornos": opts.get("adornos", 0.08), "excluir": opts.get("excluir_relleno", [])})


## Explanadas empedradas → manzanas con calles. Deja de calle la red que une todo lo importante
## (puertas, apariciones, pasarelas, bordes, personajes y carteles) ensanchada a `ancho` casillas a
## cada lado, la acera que rodea los edificios y lo protegido. El resto del empedrado libre, si forma
## una mancha de al menos `min_jardin` casillas, pasa a ser jardín: hierba con seto arriba y abajo,
## árboles en cuadrícula y flores. Ninguna puerta ni conexión se mueve; vestir_exterior.gd no guarda
## si se deja de llegar a algo. Opciones: "ancho", "min_jardin", "arboles", "paso_arboles",
## "seto" (bool), "excluir" (rectángulos que no se tocan).
static func calles(v: Vestidor, opts: Dictionary = {}) -> Dictionary:
	var width: int = opts.get("ancho", 1)
	var min_garden: int = opts.get("min_jardin", 10)
	var excl: Array = opts.get("excluir", [])
	var start := Grid.to_tile((v.map.get_node("Spawns/default") as Node2D).position)
	var street := {}
	for at: Vector2i in v.free:
		if _street(v, at) and not _excluded(at, excl):
			street[at] = true
	# Solo pasa a jardín el empedrado de verdad (ni puentes ni la orilla del agua).
	var convertible := {}
	for at: Vector2i in street:
		if not v.paving.has(at) or v.covered.has(at):
			continue
		var wet := false
		for dy: int in range(-1, 2):
			for dx: int in range(-1, 2):
				wet = wet or v.water.has(at + Vector2i(dx, dy))
		if not wet:
			convertible[at] = true
	# Red de paso: el camino más corto de la aparición a cada cosa importante, por la calle.
	var graph := AStarGrid2D.new()
	graph.region = v.bounds
	graph.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	graph.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	graph.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	graph.update()
	for at: Vector2i in Pintor.cells(v.bounds):
		graph.set_point_solid(at, not v.free.has(at))
		if v.free.has(at):
			graph.set_point_weight_scale(at, 1.0 if street.has(at) else 3.0)
	# Cada cosa importante, o la casilla libre de delante si ella no se pisa (puertas, carteles).
	var targets: Array = []
	for a: Vector2i in v.anchors:
		for c: Vector2i in [a, a + Vector2i.DOWN, a + Vector2i.LEFT, a + Vector2i.RIGHT, a + Vector2i.UP]:
			if v.free.has(c):
				targets.append(c)
				break
	targets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.distance_squared_to(start) < b.distance_squared_to(start))
	var net := {start: true}
	for target: Vector2i in targets:
		if net.has(target):
			continue
		var origins: Array = net.keys()
		origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.distance_squared_to(target) < b.distance_squared_to(target))
		var best: Array[Vector2i] = []
		for origin: Vector2i in origins.slice(0, 6):
			for route: Array[Vector2i] in [_l_route(v, origin, target, true), _l_route(v, origin, target, false)]:
				if not route.is_empty() and (best.is_empty() or route.size() < best.size()):
					best = route
		if best.is_empty():
			for origin: Vector2i in origins.slice(0, 6):
				var route := graph.get_id_path(origin, target)
				if not route.is_empty() and (best.is_empty() or route.size() < best.size()):
					best = route
		for at: Vector2i in best:
			net[at] = true
	var keep := {}
	for at: Vector2i in net:
		for dy: int in range(-width, width + 1):
			for dx: int in range(-width, width + 1):
				keep[at + Vector2i(dx, dy)] = true
	for at: Vector2i in street:
		if v.protected.has(at):
			keep[at] = true
			continue
		# Delante de escaleras y caminos de tierra (subidas a cerros, entradas a parques).
		for d: Vector2i in DIRS:
			if v.terrain(at + d) in ["stairs", "path"] or v.terrain(at + d * 2) == "stairs":
				keep[at] = true
		# Acera: lo que toca un edificio, un muro o un monumento (cualquier cosa que no se pisa).
		for dy: int in range(-1, 2):
			for dx: int in range(-1, 2):
				var n := at + Vector2i(dx, dy)
				if v.bounds.has_point(n) and not v.free.has(n) and not v.water.has(n) and v.object_at(n) == &"" \
						and v.forest.get(n) == null:
					keep[at] = true
	# Manchas de empedrado que sobran.
	var seen := {}
	var gardens: Array = []
	for at: Vector2i in street:
		if seen.has(at) or keep.has(at) or not convertible.has(at):
			continue
		var blob: Array[Vector2i] = []
		var queue: Array[Vector2i] = [at]
		seen[at] = true
		while not queue.is_empty():
			var c: Vector2i = queue.pop_back()
			blob.append(c)
			for d: Vector2i in DIRS:
				var n := c + d
				if convertible.has(n) and not keep.has(n) and not seen.has(n):
					seen[n] = true
					queue.append(n)
		for rect: Rect2i in _rectangles(blob, int(opts.get("lado_min", 3)), min_garden):
			gardens.append(Pintor.cells(rect))
	var cells := 0
	for blob: Array in gardens:
		var list: Array[Vector2i] = []
		list.assign(blob)
		v.clear_cells(list)
		for at: Vector2i in list:
			for d: Vector2i in DIRS:
				v._paving_dirty[at + d] = true
		cells += list.size()
	v.build()
	await v.refresh()
	var trees := 0
	var hedges := 0
	var tree_ids: Array = opts.get("arboles", [&"arbol_redondo", &"arbol_verde"])
	var step: int = opts.get("paso_arboles", 3)
	for blob: Array in gardens:
		var inside := {}
		for at: Vector2i in blob:
			inside[at] = true
		var rect := Rect2i(blob[0], Vector2i.ONE)
		for at: Vector2i in blob:
			rect = rect.expand(at).expand(at + Vector2i.ONE)
		# El seto ocupa su fila y dibuja su copa en la de encima: va siempre dentro del jardín, para no
		# tapar la acera de arriba.
		var inner := Rect2i(rect.position + Vector2i(1, 0), Vector2i(maxi(rect.size.x - 2, 0), rect.size.y))
		if bool(opts.get("seto", true)) and rect.size.x >= 3 and rect.size.y >= 3:
			v.hedge(rect.position.x, rect.end.x - 1, rect.end.y - 1)
			hedges += 1
			inner = Rect2i(inner.position, Vector2i(inner.size.x, rect.size.y - 2))
			if rect.size.y >= 5:
				v.hedge(rect.position.x, rect.end.x - 1, rect.position.y + 1)
				hedges += 1
				inner = Rect2i(inner.position + Vector2i(0, 2), Vector2i(inner.size.x, rect.size.y - 4))
		for at: Vector2i in Pintor.cells(inner):
			if posmod(at.x - inner.position.x, step) == 0 and posmod(at.y - inner.position.y, step) == 0 and v.open(at):
				if v.object(tree_ids[v.rng.randi() % tree_ids.size()], at):
					trees += 1
		var flowers: Array[Vector2i] = []
		for at: Vector2i in blob:
			if v.open(at) and v.rng.randf() < 0.18:
				flowers.append(at)
		for at: Vector2i in flowers:
			v.flowers(Rect2i(at, Vector2i.ONE), 0.35)
	await v.refresh()
	v.note("  calles: %d jardines (%d casillas de empedrado a hierba), %d árboles, %d setos" % [gardens.size(), cells, trees, hedges])
	return {"jardines": gardens.size(), "casillas": cells, "arboles": trees}


static func _inner(inside: Dictionary, at: Vector2i) -> bool:
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if not inside.has(at + Vector2i(dx, dy)):
				return false
	return true


## Seto en la primera y la última fila de cada jardín, solo en los tramos de 3 o más casillas cuyo
## borde da a la calle (así el seto separa el jardín de la acera sin cerrar nada).
static func _garden_hedges(v: Vestidor, inside: Dictionary) -> int:
	var rows := {}
	for at: Vector2i in inside:
		if not inside.has(at + Vector2i.DOWN) or not inside.has(at + Vector2i.UP):
			rows[at.y] = true
	var made := 0
	for y: int in rows:
		var xs: Array = []
		for at: Vector2i in inside:
			if at.y == y and (not inside.has(at + Vector2i.DOWN) or not inside.has(at + Vector2i.UP)) and v.open(at) \
					and inside.has(at + Vector2i.UP) == not inside.has(at + Vector2i.DOWN):
				xs.append(at.x)
		xs.sort()
		var run: Array = []
		for x: int in xs + [100000]:
			if not run.is_empty() and x != run.back() + 1:
				if run.size() >= 3:
					v.hedge(run[0], run.back(), y)
					made += 1
				run = []
			run.append(x)
	return made


## Camino en L de `a` a `b` (primero en horizontal o en vertical) si todo está libre; si no, vacío.
static func _l_route(v: Vestidor, a: Vector2i, b: Vector2i, horizontal_first: bool) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var corner := Vector2i(b.x, a.y) if horizontal_first else Vector2i(a.x, b.y)
	for seg: Array in [[a, corner], [corner, b]]:
		var from: Vector2i = seg[0]
		var to: Vector2i = seg[1]
		var d := (to - from).sign()
		var c := from
		while true:
			if not v.free.has(c):
				return []
			if out.is_empty() or out.back() != c:
				out.append(c)
			if c == to:
				break
			c += d
	return out


## Rectángulos grandes dentro de una mancha (el mayor primero, hasta que no quede ninguno de al menos
## `side` de lado y `area` casillas): así los jardines son manzanas rectas y no recortes.
static func _rectangles(blob: Array, side: int, area: int) -> Array[Rect2i]:
	var cells := {}
	for at: Vector2i in blob:
		cells[at] = true
	var out: Array[Rect2i] = []
	while true:
		var best := Rect2i()
		for at: Vector2i in cells:
			if cells.has(at + Vector2i.LEFT) or cells.has(at + Vector2i.UP) and cells.has(at + Vector2i(-1, -1)):
				pass
			# Crece hacia la derecha y hacia abajo desde cada casilla (las manchas son pequeñas).
			var w := 0
			while cells.has(at + Vector2i(w, 0)):
				w += 1
			var h := 0
			var row_w := w
			while row_w >= side:
				var rw := 0
				while rw < row_w and cells.has(at + Vector2i(rw, h)):
					rw += 1
				if rw < side:
					break
				row_w = rw
				h += 1
				if h >= side and row_w * h > best.get_area():
					best = Rect2i(at, Vector2i(row_w, h))
		if best.get_area() < area or best.size.x < side or best.size.y < side:
			break
		out.append(best)
		for at: Vector2i in Pintor.cells(best):
			cells.erase(at)
	return out


## Segunda pasada sobre una ciudad que ya tiene su mobiliario (manzanas() del 2026-10-19): solo
## convierte la explanada en calles y jardines y rellena con arbolado la hierba nueva. No repite
## farolas ni bancos.
static func explanada(v: Vestidor, opts: Dictionary = {}) -> void:
	var o := {"ancho": 0, "min_jardin": 6, "lado_min": 2}
	o.merge(opts, true)
	await calles(v, o)
	if bool(o.get("sin_relleno", false)):
		return
	v.fill({"estilo": "arboleda", "margen": [2, 2], "arboles": o.get("arboles", [&"arbol_redondo", &"arbol_verde"]),
		"hueco": 2, "adornos": 0.08})
