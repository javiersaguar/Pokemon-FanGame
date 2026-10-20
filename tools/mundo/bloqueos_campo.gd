extends SceneTree
## Obstáculos de campo (Corte, Golpe Roca, Fuerza) y atajos (tronco o cancela que se abre desde un lado) de cada
## mapa, y qué dejan detrás. Con todos cerrados y desde los bordes con conexión y la aparición «default»
## se recorre el mapa como alcance.gd; luego, con cada bloqueo abierto. Escribe data/bloqueos_campo.json:
##   bloqueos: nombre, tipo (cut, rock_smash, strength, atajo), casilla y condición para abrirlo;
##   tras_bloqueo: salidas (pasarelas y bordes) a las que solo se llega abriendo algo (deberían ser
##     ninguna: tools/mundo/grafo_mundo.py quita esas uniones si la acción no está disponible);
##   opcional: objetos y personajes a los que solo se llega abriendo algo.
## Uso: godot --headless --path . -s res://tools/mundo/bloqueos_campo.gd [-- --comprobar]
##   --comprobar: no escribe; sale con 1 si el archivo no está al día.

const OUT := "res://data/bloqueos_campo.json"
const BLOCKING_MASK := 1 | 2 | 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const SCENES := {
	"res://src/overworld/campo/corte.tscn": "cut",
	"res://src/overworld/campo/golpe_roca.tscn": "rock_smash",
	"res://src/overworld/campo/fuerza.tscn": "strength",
	"res://src/overworld/campo/atajo_tronco.tscn": "atajo",
	"res://src/overworld/campo/atajo_valla.tscn": "atajo",
}


func _initialize() -> void:
	await process_frame
	var check := "--comprobar" in OS.get_cmdline_user_args()
	var result := {}
	for mid: String in mapas_con_bloqueos():
		var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
		root.add_child(map)
		await physics_frame
		await physics_frame
		result[mid] = analizar(map)
		map.queue_free()
		await process_frame
	var text := texto(result)
	if check:
		var same := FileAccess.file_exists(OUT) and FileAccess.get_file_as_string(OUT) == text
		print("bloqueos_campo.json %s" % ("al día" if same else "NO está al día"))
		quit(0 if same else 1)
		return
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	print("%s: %d mapas con bloqueos." % [OUT, result.size()])
	quit()


static func texto(result: Dictionary) -> String:
	return JSON.stringify({
		"_": "Generado por tools/mundo/bloqueos_campo.gd. Obstáculos de campo y atajos por mapa y lo que dejan detrás.",
		"mapas": result,
	}, "\t", true) + "\n"


## Ids de los mapas (sin res://maps/ ni .tscn) que tienen algún obstáculo o atajo.
static func mapas_con_bloqueos() -> Array[String]:
	var out: Array[String] = []
	_scan("res://maps", out)
	out.sort()
	return out


static func _scan(dir: String, out: Array[String]) -> void:
	for sub: String in DirAccess.get_directories_at(dir):
		if not sub.begins_with("_") and sub != "test" and sub != "muestras":
			_scan(dir.path_join(sub), out)
	for file: String in DirAccess.get_files_at(dir):
		if not file.ends_with(".tscn"):
			continue
		var path := dir.path_join(file)
		var text := FileAccess.get_file_as_string(path)
		for scene: String in SCENES:
			if text.contains('path="%s"' % scene):
				out.append(path.trim_prefix("res://maps/").trim_suffix(".tscn"))
				break


static func bloqueos(map: Node2D) -> Array[Node2D]:
	var out: Array[Node2D] = []
	for node: Node in map.get_node("Entities").get_children():
		if node is Node2D and SCENES.has(node.scene_file_path):
			out.append(node)
	return out


static func condicion(node: Node2D) -> String:
	var kind: String = SCENES[node.scene_file_path]
	return "flag:%s" % node.get(&"hidden_if_flag") if kind == "atajo" else kind


## Casillas de entrada: las de los bordes con conexión y la aparición «default».
static func entradas(map: Node2D) -> Array[Vector2i]:
	var bounds := (map.get_node("Ground") as TileMapLayer).get_used_rect()
	var out: Array[Vector2i] = []
	var spawn := map.get_node_or_null("Spawns/default") as Node2D
	if spawn != null:
		out.append(Grid.to_tile(spawn.position))
	for c: Resource in map.get(&"data").connections:
		out.append_array(borde(c, bounds))
	return out


static func borde(c: Resource, bounds: Rect2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var vertical: bool = c.edge in ["east", "west"]
	var count := bounds.size.y if vertical else bounds.size.x
	for i: int in count:
		var along := (bounds.position.y if vertical else bounds.position.x) + i
		if c.span != Vector2i.ZERO and (along < c.span.x or along >= c.span.y):
			continue
		match String(c.edge):
			"north": out.append(Vector2i(along, bounds.position.y))
			"south": out.append(Vector2i(along, bounds.end.y - 1))
			"west": out.append(Vector2i(bounds.position.x, along))
			_: out.append(Vector2i(bounds.end.x - 1, along))
	return out


static func recorrer(map: Node2D, open: Array[Node2D]) -> Dictionary:
	var space := map.get_world_2d().direct_space_state
	var bounds := (map.get_node("Ground") as TileMapLayer).get_used_rect()
	var exclude: Array[RID] = []
	for node: Node2D in open:
		var body := node.get_node_or_null("Body") as CollisionObject2D
		if body != null:
			exclude.append(body.get_rid())
	var free := func(tile: Vector2i) -> bool:
		if not bounds.has_point(tile):
			return false
		var q := PhysicsPointQueryParameters2D.new()
		q.position = map.to_global(Grid.to_world(tile))
		q.collision_mask = BLOCKING_MASK
		q.exclude = exclude
		return space.intersect_point(q, 1).is_empty()
	var seen := {}
	var queue: Array[Vector2i] = []
	for t: Vector2i in entradas(map):
		if not seen.has(t) and free.call(t):
			seen[t] = true
			queue.append(t)
	var cursor := 0
	while cursor < queue.size():
		var t := queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := t + d
			if not seen.has(n) and free.call(n):
				seen[n] = true
				queue.append(n)
	return seen


## Salidas del mapa: nombre → [destino, casillas desde las que se usa].
static func salidas(map: Node2D) -> Dictionary:
	var bounds := (map.get_node("Ground") as TileMapLayer).get_used_rect()
	var out := {}
	var warps := map.get_node_or_null("Warps")
	if warps != null:
		for node: Node in warps.get_children():
			out["pasarela " + node.name] = [String(node.get(&"target_map")), [Grid.to_tile((node as Node2D).position)]]
	for c: Resource in map.get(&"data").connections:
		out["borde %s" % c.edge] = [String(c.target_map), borde(c, bounds)]
	return out


static func _near(seen: Dictionary, at: Vector2i) -> bool:
	for d: Vector2i in DIRS:
		if seen.has(at + d):
			return true
	return false


static func analizar(map: Node2D) -> Dictionary:
	var blocks := bloqueos(map)
	var closed := recorrer(map, [])
	var opened := recorrer(map, blocks)
	var info := {"bloqueos": [], "tras_bloqueo": [], "opcional": []}
	for node: Node2D in blocks:
		var at := Grid.to_tile(node.position)
		info.bloqueos.append({"nombre": String(node.name), "tipo": SCENES[node.scene_file_path],
			"casilla": [at.x, at.y], "condicion": condicion(node), "se_examina": _near(closed, at)})
	var exits := salidas(map)
	var names := exits.keys()
	names.sort()
	for key: String in names:
		var cells: Array = exits[key][1]
		var in_closed := cells.any(func(t: Vector2i) -> bool: return closed.has(t))
		var in_open := cells.any(func(t: Vector2i) -> bool: return opened.has(t))
		if in_closed or not in_open:
			continue
		var needs: Array = []
		for node: Node2D in blocks:
			var single := recorrer(map, [node])
			if cells.any(func(t: Vector2i) -> bool: return single.has(t)):
				needs.append(condicion(node))
		if needs.is_empty():
			needs = blocks.map(func(n: Node2D) -> String: return condicion(n))
		info.tras_bloqueo.append({"salida": key, "destino": exits[key][0], "condicion": needs})
	for node: Node in map.get_node("Entities").get_children():
		if not node is Node2D or node is TileMapLayer or blocks.has(node):
			continue
		var at := Grid.to_tile((node as Node2D).position)
		if not _near(closed, at) and _near(opened, at):
			info.opcional.append(String(node.name))
	info.opcional.sort()
	return info
