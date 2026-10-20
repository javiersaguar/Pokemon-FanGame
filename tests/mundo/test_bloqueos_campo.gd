extends GutTest
## Obstáculos de campo (Corte, Golpe Roca, Fuerza) y atajos (troncos que se apartan desde un lado):
## ninguno corta una salida del mapa, cada uno cierra algo (zona, objeto o atajo), se puede examinar,
## y data/bloqueos_campo.json está al día (lo lee tools/mundo/grafo_mundo.py).

const TOOL := preload("res://tools/mundo/bloqueos_campo.gd")


func _load(mid: String) -> Node2D:
	var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
	add_child(map)
	await wait_physics_frames(2)
	return map


func test_el_archivo_esta_al_dia_y_ninguna_salida_queda_cerrada() -> void:
	var mids := TOOL.mapas_con_bloqueos()
	assert_gt(mids.size(), 0, "hay mapas con obstáculos o atajos")
	var result := {}
	for mid: String in mids:
		var map := await _load(mid)
		result[mid] = TOOL.analizar(map)
		map.free()
		assert_eq(result[mid].tras_bloqueo, [], "%s: ninguna salida queda detrás de un bloqueo" % mid)
		for b: Dictionary in result[mid].bloqueos:
			assert_true(b.se_examina, "%s: se llega a %s" % [mid, b.nombre])
	assert_eq(FileAccess.get_file_as_string(TOOL.OUT), TOOL.texto(result),
		"data/bloqueos_campo.json al día (godot --headless --path . -s res://tools/mundo/bloqueos_campo.gd)")


func test_cada_obstaculo_cierra_algo() -> void:
	for mid: String in TOOL.mapas_con_bloqueos():
		var map := await _load(mid)
		var closed := TOOL.recorrer(map, [])
		for node: Node2D in TOOL.bloqueos(map):
			if TOOL.SCENES[node.scene_file_path] == "atajo":
				continue
			var opened := TOOL.recorrer(map, [node])
			var loot := false
			for other: Node in map.get_node("Entities").get_children():
				if other is Node2D and not other is TileMapLayer and other != node:
					var at := Grid.to_tile((other as Node2D).position)
					loot = loot or (TOOL._near(opened, at) and not TOOL._near(closed, at))
			assert_true(opened.size() > closed.size() + 1 or loot, "%s: %s deja detrás una zona o un objeto" % [mid, node.name])
		map.free()


## Pasos más cortos entre dos casillas con los bloqueos dados abiertos.
func _steps(map: Node2D, a: Vector2i, b: Vector2i, open: Array[Node2D]) -> int:
	var seen := TOOL.recorrer(map, open)
	if not seen.has(a) or not seen.has(b):
		return -1
	var dist := {a: 0}
	var queue: Array[Vector2i] = [a]
	var cursor := 0
	while cursor < queue.size():
		var t := queue[cursor]
		cursor += 1
		if t == b:
			return dist[t]
		for d: Vector2i in TOOL.DIRS:
			var n := t + d
			if seen.has(n) and not dist.has(n):
				dist[n] = dist[t] + 1
				queue.append(n)
	return -1


func test_atajos_en_los_dos_estados() -> void:
	var count := 0
	for mid: String in TOOL.mapas_con_bloqueos():
		var map := await _load(mid)
		for node: Node2D in TOOL.bloqueos(map):
			if TOOL.SCENES[node.scene_file_path] != "atajo":
				continue
			count += 1
			var at := Grid.to_tile(node.position)
			var side: Vector2i = node.get(&"open_side")
			assert_ne(node.get(&"hidden_if_flag"), &"", "%s: %s tiene su flag" % [mid, node.name])
			var near := at + side
			var far := at - side
			var closed := _steps(map, near, far, [])
			var opened := _steps(map, near, far, [node])
			assert_gt(closed, 0, "%s: cerrado, se llega a los dos lados de %s dando la vuelta" % [mid, node.name])
			assert_eq(opened, 2, "%s: abierto, %s se cruza" % [mid, node.name])
			assert_gte(closed, 12, "%s: %s ahorra camino (%d pasos cerrado)" % [mid, node.name, closed])
			assert_true(node.call(&"can_open_from", near), "%s: %s se abre desde su lado" % [mid, node.name])
			assert_false(node.call(&"can_open_from", far), "%s: %s no se abre desde el otro" % [mid, node.name])
		map.free()
	assert_gt(count, 0, "hay atajos")
