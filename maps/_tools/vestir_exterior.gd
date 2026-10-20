extends SceneTree
## Viste exteriores ya pintados con su receta (maps/_pintura/vestir/<mapa>.gd) sin repintarlos:
## las puertas, las pasarelas, las apariciones y las conexiones se quedan como estaban.
## Antes de guardar comprueba que se sigue llegando a todo lo que se llegaba (puertas, pasarelas,
## personajes, carteles, bordes y personajes colocados por datos) y a todo lo nuevo; si no, no guarda.
## Uso: godot --headless --path . -s res://maps/_tools/vestir_exterior.gd -- <mapa>... [--prueba]
##   <mapa>: id sin res://maps/ ni .tscn (ruta_16/exterior). La receta se llama como el mapa con
##   «/» cambiada por «_» y sin «_exterior» (ruta_16.gd, madrid_centro.gd).
##   --prueba: no guarda; solo dice lo que haría.
##   --receta=<res://...gd>: usa esa receta en todos los mapas (por ejemplo, _entrenadores.gd).

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const RECIPES := "res://maps/_pintura/vestir/"

var _failed := 0
var _recipe_override := ""


func _initialize() -> void:
	await process_frame
	var args := Array(OS.get_cmdline_user_args())
	var dry := "--prueba" in args
	for arg: String in args:
		if arg.begins_with("--receta="):
			_recipe_override = arg.get_slice("=", 1)
	for mid: String in args:
		if mid.begins_with("--"):
			continue
		await _dress(mid, dry)
	quit(1 if _failed > 0 else 0)


static func recipe_path(mid: String) -> String:
	return RECIPES + mid.trim_suffix("/exterior").replace("/", "_") + ".gd"


func _dress(mid: String, dry: bool) -> void:
	var path := "res://maps/%s.tscn" % mid
	var recipe_file := _recipe_override if _recipe_override != "" else recipe_path(mid)
	if not FileAccess.file_exists(recipe_file):
		push_error("vestir: no hay receta %s" % recipe_file)
		_failed += 1
		return
	var map: Node2D = (load(path) as PackedScene).instantiate()
	# Los entrenadores rellenan su nombre y su hoja con los datos al entrar en el árbol: se guardan como
	# estaban en el mapa, para no fijar en él lo que dicen hoy los datos.
	var trainer_fields := {}
	for node: Node in map.get_node("Entities").get_children():
		if node.get(&"trainer_id") != null:
			trainer_fields[node.name] = [node.get(&"display_name"), node.get(&"sprite_sheet")]
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	var v := Vestidor.new()
	v.setup(map, mid)
	var recipe: Object = (load(recipe_file) as GDScript).new()
	recipe.set(&"tree", self)
	v.surf = recipe.get(&"con_surf") == true
	v.scan(space)
	var before := _status(v)
	await recipe.call(&"vestir", v)
	v.build()
	await physics_frame
	await physics_frame
	v.scan(space)
	var after := _status(v)
	var problems := 0
	# Detrás de un obstáculo de campo solo puede quedar lo opcional (objetos y personajes): se mira
	# también con los obstáculos quitados.
	for at: Vector2i in v.obstacle_cells:
		v.free[at] = true
	var opened := _status(v)
	for at: Vector2i in v.obstacle_cells:
		v.free.erase(at)
	for key: String in before:
		if before[key] and not after.get(key, false):
			if key.begins_with("personaje o cartel") and opened.get(key, false):
				print("  · tras un obstáculo (opcional): ", key)
				continue
			problems += 1
			print("  ✗ ya no se llega: ", key)
	for key: String in after:
		if not before.has(key) and not after[key]:
			if key.begins_with("personaje o cartel") and opened.get(key, false):
				print("  · tras un obstáculo (opcional): ", key)
				continue
			problems += 1
			print("  ✗ no se llega a lo nuevo: ", key)
	for line: String in v.log_lines:
		print("  · ", line)
	# Paso por hierba entre las conexiones: la receta lo pide con `var hierba_obligada := true`.
	var costs := v.grass_costs()
	var must: bool = recipe.get(&"hierba_obligada") == true
	for key: String in costs:
		print("  hierba mínima %s: %d" % [key, costs[key]])
		if must and int(costs[key]) == 0:
			problems += 1
			print("  ✗ se puede cruzar sin pisar hierba: ", key)
	if must and not v.shortcut_cells.is_empty():
		for at: Vector2i in v.shortcut_cells:
			v.free[at] = true
		var open_costs := v.grass_costs()
		for key: String in open_costs:
			print("  hierba mínima con los atajos abiertos %s: %d" % [key, open_costs[key]])
			if int(open_costs[key]) == 0:
				problems += 1
				print("  ✗ con los atajos abiertos se cruza sin pisar hierba: ", key)
		for at: Vector2i in v.shortcut_cells:
			v.free.erase(at)
	if must:
		var connections: Array = map.get(&"data").connections
		for i: int in connections.size():
			for j: int in range(i + 1, connections.size()):
				var route := v.grass_bypass(connections[i], connections[j])
				if not route.is_empty():
					var sample: Array = []
					for k: int in range(0, route.size(), maxi(1, route.size() / 24)):
						sample.append(route[k])
					print("  rodeo sin hierba: ", sample)
	var reach := _reach(v)
	print("%s: %d casillas alcanzables (antes %d), %d entidades nuevas, %d problemas." % [mid,
		reach.size(), before.get("_casillas", 0), v.pending_entities.size(), problems])
	root.remove_child(map)
	if problems > 0 or dry:
		if problems > 0:
			_failed += 1
		for node: Node2D in v.pending_entities + v.pending_sea:
			node.free()
		map.free()
		return
	v.commit_entities()
	for node_name: StringName in trainer_fields:
		var node := map.get_node("Entities").get_node_or_null(NodePath(node_name))
		if node != null:
			node.set(&"display_name", trainer_fields[node_name][0])
			node.set(&"sprite_sheet", trainer_fields[node_name][1])
	var packed := PackedScene.new()
	var error := packed.pack(map)
	if error == OK:
		error = ResourceSaver.save(packed, path)
	print("  guardado: ", error_string(error))
	map.free()
	await process_frame


## Qué se alcanza: puertas, pasarelas, personajes, carteles, bordes y personajes por datos.
func _status(v: Vestidor) -> Dictionary:
	var seen := _reach(v)
	var out := {"_casillas": seen.size()}
	for cell: Vector2i in v.objects.get_used_cells():
		var id := v.object_at(cell)
		if id == &"" or v.catalog[id].door.x < 0:
			continue
		var door: Vector2i = cell + v.catalog[id].door
		out["puerta de %s en %s" % [id, door]] = seen.has(door)
	for warp: Node in v.map.get_node("Warps").get_children():
		var at := Grid.to_tile((warp as Node2D).position)
		out["pasarela %s en %s" % [warp.name, at]] = seen.has(at)
	var nodes: Array = v.entities.get_children()
	nodes.append_array(v.pending_entities)
	for node: Node in nodes:
		if node == v.objects or not node is Node2D:
			continue
		var at := Grid.to_tile((node as Node2D).position)
		var ok := false
		if node.scene_file_path.ends_with("sign.tscn") and node.get("only_from_below") != false:
			ok = seen.has(at + Vector2i.DOWN)
		else:
			for d: Vector2i in DIRS:
				ok = ok or seen.has(at + d)
		out["personaje o cartel %s" % node.name] = ok
	for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
		if entry.get("mapa", "") != v.mid or not entry.has("casilla"):
			continue
		var at := Vector2i(int(entry.casilla[0]), int(entry.casilla[1]))
		var ok := false
		for d: Vector2i in DIRS:
			ok = ok or seen.has(at + d)
		out["colocado %s en %s" % [entry.get("id", "?"), at]] = ok
	for connection: Resource in v.map.get(&"data").connections:
		var any := false
		for at: Vector2i in v.edge_cells(connection):
			any = any or seen.has(at)
		out["borde %s → %s" % [connection.edge, connection.target_map]] = any
	return out


func _reach(v: Vestidor) -> Dictionary:
	var start := Grid.to_tile((v.map.get_node("Spawns/default") as Node2D).position)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	var cursor := 0
	while cursor < queue.size():
		var at := queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := at + d
			if v.free.has(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen
