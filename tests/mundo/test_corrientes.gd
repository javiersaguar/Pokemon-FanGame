extends GutTest
## Corrientes marinas y escollos de la Ruta marítima 1: se simula el Surf como Player._walk (el primer
## paso va hacia donde se pulsa; dentro de una corriente se sigue en su dirección hasta salir o chocar)
## y se comprueba que no hay trampas, que la cala del premio solo se abre por su corriente y que todas
## las corrientes van sobre el agua.

const MAP := "res://maps/maritima_1/exterior.tscn"
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var _map: MapRoot
var _bounds: Rect2i
var _currents: Array = []


func before_all() -> void:
	_map = (load(MAP) as PackedScene).instantiate()
	add_child(_map)
	await wait_physics_frames(3)
	_bounds = _map.get_ground().get_used_rect()
	_currents = _map.find_children("*", "SurfCurrent", true, false)


func after_all() -> void:
	_map.queue_free()


func _free(tile: Vector2i) -> bool:
	if not _bounds.has_point(tile):
		return false
	var q := PhysicsPointQueryParameters2D.new()
	q.position = _map.to_global(Grid.to_world(tile))
	q.collision_mask = 1 | 2
	return _map.get_world_2d().direct_space_state.intersect_point(q, 1).is_empty() \
		and _map.terrain_at(tile) == "water"


## Adónde acaba un paso con Surf hacia `dir` desde `tile`.
func _surf(tile: Vector2i, dir: Vector2i) -> Vector2i:
	if not _free(tile + dir):
		return tile
	var at := tile + dir
	for _i: int in 200:
		var drift := SurfCurrent.direction_at(_map, at)
		if drift == Vector2i.ZERO or not _free(at + drift):
			break
		at += drift
	return at


func _reach(start: Vector2i) -> Dictionary:
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d: Vector2i in DIRS:
			var n := _surf(t, d)
			if not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func test_hay_corrientes_y_escollos_sobre_el_agua() -> void:
	assert_gte(_currents.size(), 3, "la ruta lleva corrientes")
	for node: Node in _currents:
		for cell: Vector2i in Pintor.cells(node.call(&"rect")):
			assert_eq(_map.terrain_at(cell), "water", "%s en %s va sobre el agua" % [node.name, cell])
	assert_gte(_map.get_node("Mar").get_child_count() - _currents.size(), 10, "hay escollos")


func test_la_corriente_de_bajada_lleva_al_velero() -> void:
	assert_eq(_surf(Vector2i(22, 5), Vector2i.DOWN), Vector2i(22, 26))


func test_sin_trampas_y_se_cruza_de_palma_a_ibiza() -> void:
	var start := Grid.to_tile((_map.get_node("Spawns/from_palma") as Node2D).position)
	var seen := _reach(start)
	var exits := {}
	for t: Vector2i in seen:
		if t.y == _bounds.end.y - 1:
			exits[t] = true
	assert_gt(exits.size(), 0, "se llega al borde de Ibiza")
	# Desde cualquier casilla alcanzable se puede volver a salir por el norte o por el sur.
	var ok := {}
	for t: Vector2i in seen:
		if t.y == 0 or t.y == _bounds.end.y - 1:
			ok[t] = true
	var changed := true
	while changed:
		changed = false
		for t: Vector2i in seen:
			if ok.has(t):
				continue
			for d: Vector2i in DIRS:
				if ok.has(_surf(t, d)):
					ok[t] = true
					changed = true
					break
	var trapped: Array = seen.keys().filter(func(t: Vector2i) -> bool: return not ok.has(t))
	assert_eq(trapped, [], "casillas de las que no se sale")


func test_la_cala_solo_se_abre_por_su_corriente() -> void:
	var start := Grid.to_tile((_map.get_node("Spawns/from_palma") as Node2D).position)
	var seen := _reach(start)
	var prize := Grid.to_tile((_map.get_node("Entities/PPMaxCala") as Node2D).position)
	var near := false
	for d: Vector2i in DIRS:
		near = near or seen.has(prize + d)
	assert_true(near, "se llega al PP Máx de la cala")
	assert_lt(_surf(Vector2i(39, 46), Vector2i.RIGHT).x, 40, "por el hueco del oeste la corriente echa fuera")
	assert_eq(_surf(Vector2i(44, 29), Vector2i.DOWN), Vector2i(44, 44), "la corriente del este mete en la cala")
	assert_lt(_surf(Vector2i(42, 46), Vector2i.LEFT).x, 40, "y desde dentro se sale por el hueco")
