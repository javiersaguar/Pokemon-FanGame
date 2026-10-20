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
