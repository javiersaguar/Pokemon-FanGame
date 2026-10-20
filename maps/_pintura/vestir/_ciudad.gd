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
