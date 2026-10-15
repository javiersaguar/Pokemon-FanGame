extends GutTest
## Acceso al mundo entero desde los pueblos iniciales (Pozuelo y Orcasitas, decisiones del 2026-10-13, §7):
## se llega a todos los mapas, desde todos se puede volver, no hay uniones de ida sin motivo, cada ciudad,
## barrio y ruta de data/region.json existe y se alcanza, los cortes por medallas (obras de la A-6, C-5
## averiado) cortan lo que deben y cada gimnasio se alcanza con las medallas de antes. Es la comprobación de
## tools/mundo/grafo_mundo.py (docs/mundo/conexiones.md), hecha con las escenas de verdad. Al final, la
## parte física: en cada exterior se pisan sus bordes y pasarelas, y al cruzar un borde se llega a una casilla
## libre del otro mapa desde la que se puede volver.

const REGION := "res://data/region.json"
const PLACEMENTS := "res://data/personajes_en_el_mapa.json"
## Uniones de un solo sentido a propósito, además de los viajes (transporte/*) y los saltos de los eventos.
const ONE_WAY_OK: Array = [["madrid/atico_ayuso", "madrid/chamberi"]]
## Mapas que solo se cruzan con Surf (data/region.json: maritima_1, de Palma a Ibiza).
const SURF_MAPS: Array[String] = ["maritima_1/exterior", "palma/exterior", "ibiza/exterior"]
const MASK := 1 | 2 | 8
const WATER := 8
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const EDGE_DIR := {"north": Vector2i.UP, "south": Vector2i.DOWN, "west": Vector2i.LEFT, "east": Vector2i.RIGHT}
const OPPOSITE := {"north": "south", "south": "north", "west": "east", "east": "west"}

static var _world: Dictionary = {}


## {mapa: {edges, warps, events, outdoor}} leído de las escenas (SceneState, sin instanciarlas).
func _load_world() -> Dictionary:
	if not _world.is_empty():
		return _world
	var teleport := RegEx.create_from_string("Cutscene\\.teleport\\(&?\"([^\"]+)\"")
	for id: StringName in MapRoot.list_all():
		var sid := String(id)
		if sid.begins_with("test/") or sid.begins_with("muestras/"):
			continue
		var state := (load(MapRoot.path_from_id(id)) as PackedScene).get_state()
		var info := {"edges": [], "warps": [], "events": [], "outdoor": true}
		var guards := {}
		for i: int in state.get_node_count():
			var parent := String(state.get_node_path(i, true)).trim_prefix("./")
			var props := {}
			for j: int in state.get_node_property_count(i):
				props[state.get_node_property_name(i, j)] = state.get_node_property_value(i, j)
			if i == 0 and props.get(&"data") is MapData:
				var data: MapData = props[&"data"]
				info.outdoor = data.outdoor
				for c: MapConnection in data.connections:
					info.edges.append({"edge": c.edge, "target": String(c.target_map), "span": c.span})
			var at := Grid.to_tile(props.get(&"position", Vector2.ZERO))
			if parent == "Warps" and props.has(&"target_map"):
				info.warps.append({"name": String(state.get_node_name(i)), "target": String(props[&"target_map"]), "tile": at})
			if String(props.get(&"hidden_if_flag", "")).begins_with("visited_map:"):
				guards[at] = true
			if props.get(&"event") is Script:
				for found: RegExMatch in teleport.search_all((props[&"event"] as Script).source_code):
					info.events.append(found.get_string(1))
		# Pasarela que tapa un revisor hasta haber estado en el destino (AVE: viaje rápido a lo ya visitado).
		for w: Dictionary in info.warps:
			w["visit_gated"] = guards.has(w.tile) or guards.has(w.tile + Vector2i.DOWN)
		_world[sid] = info
	return _world


func _key(a: String, b: String) -> String:
	return a + ">" + b


## {mapa: {destino: tipo}}. Sin las uniones de `closed` ("a>b") y, con first_visit, sin las que piden haber
## estado ya en el destino.
func _links(first_visit := false, closed: Dictionary = {}) -> Dictionary:
	var world := _load_world()
	var out := {}
	for a: String in world:
		var links := {}
		for e: Dictionary in world[a].edges:
			links[e.target] = "borde"
		for w: Dictionary in world[a].warps:
			if not (first_visit and w.visit_gated):
				links[w.target] = "pasarela"
		for t: String in world[a].events:
			links[t] = "evento"
		for b: String in links.keys():
			if closed.has(_key(a, b)) or not world.has(b):
				links.erase(b)
		out[a] = links
	return out


func _reach(links: Dictionary, starts: Array) -> Dictionary:
	var seen := {}
	var queue: Array = []
	for s: String in starts:
		seen[s] = true
		queue.append(s)
	var cursor := 0
	while cursor < queue.size():
		var a: String = queue[cursor]
		cursor += 1
		for b: String in links.get(a, {}):
			if not seen.has(b):
				seen[b] = true
				queue.append(b)
	return seen


func _region() -> Dictionary:
	return JsonFile.read_dict(REGION)


func _starts() -> Array:
	var region := _region()
	var out: Array = []
	for id: String in region.get("start", []):
		out.append(str(region.locations[id].map))
	return out


## Cortes por medallas: personajes fijos con "hasta" de data/personajes_en_el_mapa.json. Tapan la pasarela
## en la que están o, si están en la primera columna o fila del mapa, el borde de ese lado.
func _gates() -> Array:
	var world := _load_world()
	var groups := {}
	for entry: Dictionary in JsonFile.read_dict(PLACEMENTS).get("colocados", []):
		var until: Variant = entry.get("hasta")
		if not until is Dictionary or not until.has("medallas") or not bool(entry.get("fija", false)):
			continue
		var map := str(entry.mapa)
		var cell: Array = entry.get("casilla", entry.get("cerca", [0, 0]))
		var at := Vector2i(int(cell[0]), int(cell[1]))
		var medals := int(until.medallas)
		var gid := "%s/%d" % [map, medals]
		if not groups.has(gid):
			groups[gid] = {"map": map, "medals": medals, "links": {}, "place": str(entry.get("lugar", ""))}
		for w: Dictionary in world.get(map, {}).get("warps", []):
			if w.tile == at:
				groups[gid].links[_key(map, w.target)] = true
		for e: Dictionary in world.get(map, {}).get("edges", []):
			var along := at.y if e.edge in ["west", "east"] else at.x
			var inside: bool = e.span == Vector2i.ZERO or (along >= e.span.x and along < e.span.y)
			# Junto al borde: en la primera o la segunda columna (fila); los obreros de la A-6 están en la segunda
			# para que al cruzar desde la Ruta 4 no se aparezca encima de uno.
			if inside and ((e.edge == "west" and at.x <= 1) or (e.edge == "north" and at.y <= 1)):
				groups[gid].links[_key(map, e.target)] = true
	return groups.values()


## Uniones de la Ruta marítima 1 (solo con Surf).
func _surf_links() -> Dictionary:
	var out := {}
	var links := _links()
	for a: String in links:
		for b: String in links[a]:
			if a.begins_with("maritima_1/") or b.begins_with("maritima_1/"):
				out[_key(a, b)] = true
	return out


## Uniones cerradas con `medals` medallas: los cortes que piden más y, sin `surf`, el mar de Ibiza.
func _closed(medals: int, surf: bool) -> Dictionary:
	var closed := {} if surf else _surf_links()
	for gate: Dictionary in _gates():
		if medals < int(gate.medals):
			closed.merge(gate.links)
	return closed


func test_desde_pozuelo_y_orcasitas_se_llega_a_todos_los_mapas() -> void:
	var world := _load_world()
	assert_gt(world.size(), 800, "Se leen todos los mapas")
	var starts := _starts()
	assert_eq(starts, ["pozuelo/exterior", "orcasitas/exterior"], "Pueblos iniciales de las decisiones del 2026-10-13, §7")
	var links := _links()
	for start: String in starts:
		var seen := _reach(links, [start])
		var missing: Array = []
		for id: String in world:
			if not seen.has(id):
				missing.append(id)
		assert_eq(missing, [], "Desde %s se llega a todos los mapas" % start)


func test_desde_cualquier_mapa_se_vuelve_a_un_pueblo_inicial() -> void:
	var links := _links()
	var back := {}
	for a: String in links:
		for b: String in links[a]:
			if not back.has(b):
				back[b] = {}
			back[b][a] = true
	var seen := _reach(back, _starts())
	var trapped: Array = []
	for id: String in links:
		if not seen.has(id):
			trapped.append(id)
	assert_eq(trapped, [], "Ningún mapa deja atrapado")


func test_las_uniones_de_un_solo_sentido_son_las_previstas() -> void:
	var links := _links()
	var one_way: Array = []
	for a: String in links:
		for b: String in links[a]:
			if links[a][b] == "evento" or a.begins_with("transporte/") or b.begins_with("transporte/"):
				continue
			if not links.get(b, {}).has(a):
				one_way.append([a, b])
	one_way.sort()
	assert_eq(one_way, ONE_WAY_OK, "Solo de ida: la bajada de la terraza del ático de Ayuso")


func test_cada_ciudad_barrio_y_ruta_del_mapa_regional_existe_y_se_alcanza() -> void:
	var region := _region()
	var seen := _reach(_links(), _starts())
	var pending: Array = []
	var listed := {}
	for section: String in ["locations", "districts", "routes"]:
		for id: String in region.get(section, {}):
			var place: Dictionary = region[section][id]
			var ids: Array = place.get("maps", []).duplicate()
			if place.has("map"):
				if str(place.map) == "":
					pending.append(id)
				else:
					ids.append(place.map)
			for mid: Variant in ids:
				listed[str(mid)] = true
				# Lo que otro agente tiene reservado y aún no ha entregado lleva "pendiente".
				if place.has("pendiente") and not SceneManager.map_exists(StringName(str(mid))):
					continue
				assert_true(SceneManager.map_exists(StringName(str(mid))), "%s/%s: existe %s" % [section, id, mid])
				assert_true(seen.has(str(mid)), "%s/%s: se llega a %s" % [section, id, mid])
	assert_eq(pending, ["calle_victoria"], "Solo falta el mapa de la Calle de la Victoria")
	# Todos los exteriores con bordes salen en el mapa regional.
	var world := _load_world()
	for id: String in world:
		if world[id].outdoor and not world[id].edges.is_empty():
			assert_true(listed.has(id), "%s sale en data/region.json" % id)


func test_los_cortes_por_medallas_cortan_lo_que_deben() -> void:
	var gates := _gates()
	var found := {}
	for gate: Dictionary in gates:
		for link: String in gate.links:
			found[link] = int(gate.medals)
	assert_eq(found.get("madrid/moncloa>ruta_4/exterior"), 7, "Obras de la A-6 hasta la 7.ª medalla")
	assert_eq(found.get("madrid/retiro>leganes/exterior"), 1, "C-5 averiado hasta la 1.ª medalla")
	assert_eq(found.get("madrid/retiro>mostoles/exterior"), 1, "C-5 averiado hasta la 1.ª medalla")
	var starts := _starts()
	# Sin medallas: Madrid entero (con el gimnasio 1, el Quirón y el ático), el este y Palma; nada del sur ni de la A-6.
	var none := _reach(_links(true, _closed(0, false)), starts)
	for id: String in ["madrid/gimnasio_lider", "madrid/atico_ayuso", "madrid/quiron", "madrid/laboratorio",
			"barcelona/eixample", "rocafonda/exterior", "palma/exterior"]:
		assert_true(none.has(id), "Sin medallas se llega a %s" % id)
	for id: String in ["getafe/exterior", "leganes/exterior", "ruta_24/exterior", "malaga/exterior", "ruta_4/exterior",
			"pueblo_inicial/exterior", "ibiza/exterior", "valencia/ciutat_vella"]:
		assert_false(none.has(id), "Sin medallas no se llega a %s" % id)
	# Con la 1.ª medalla se abre el C-5 (Getafe, La Mancha y Málaga), pero no la A-6.
	var one := _reach(_links(true, _closed(1, false)), starts)
	for id: String in ["getafe/exterior", "leganes/exterior", "mostoles/exterior", "puertollano/exterior", "malaga/exterior"]:
		assert_true(one.has(id), "Con 1 medalla se llega a %s" % id)
	assert_false(one.has("ruta_4/exterior"), "La A-6 sigue cortada")
	# Con Surf y 6 medallas se vuelve a San Miguel por la Ruta 23, pero las obras siguen cortando Moncloa–Ruta 4.
	var six := _links(true, _closed(6, true))
	assert_true(_reach(six, starts).has("pueblo_inicial/exterior"), "San Miguel, por Valladolid y la Ruta 23")
	assert_false(six["madrid/moncloa"].has("ruta_4/exterior"), "Moncloa no sale a la Ruta 4 con 6 medallas")


func test_cada_gimnasio_se_alcanza_con_las_medallas_de_antes() -> void:
	# Surf se da como disponible: la medalla que lo da sigue pendiente de Javier (ver docs/mundo/conexiones.md).
	var region := _region()
	var starts := _starts()
	for id: String in region.locations:
		var gym: Variant = region.locations[id].get("gym")
		if not gym is Dictionary:
			continue
		var order := int(gym.order)
		var seen := _reach(_links(true, _closed(order - 1, true)), starts)
		assert_true(seen.has(str(region.locations[id].map)), "Gimnasio %d (%s) con %d medallas" % [order, id, order - 1])


## Casillas libres de un mapa ya en el árbol: {casilla: true} andando y con Surf.
func _free_tiles(map: MapRoot) -> Dictionary:
	var space := map.get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = false
	var walk := {}
	var surf := {}
	var ground := map.get_ground()
	for cell: Vector2i in ground.get_used_cells():
		query.position = map.to_global(Grid.to_world(cell))
		query.collision_mask = MASK
		if space.intersect_point(query, 1).is_empty():
			walk[cell] = true
			surf[cell] = true
			continue
		query.collision_mask = MASK & ~WATER
		if space.intersect_point(query, 1).is_empty():
			surf[cell] = true
	return {"walk": walk, "surf": surf, "bounds": ground.get_used_rect()}


func _flood(free: Dictionary, starts: Array) -> Dictionary:
	var seen := {}
	var queue: Array = []
	for s: Vector2i in starts:
		seen[s] = true
		queue.append(s)
	var cursor := 0
	while cursor < queue.size():
		var t: Vector2i = queue[cursor]
		cursor += 1
		for d: Vector2i in DIRS:
			var n := t + d
			if free.has(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func _on_edge(t: Vector2i, edge: String, bounds: Rect2i, span: Vector2i) -> bool:
	var along := t.y if edge in ["east", "west"] else t.x
	if span != Vector2i.ZERO and (along < span.x or along >= span.y):
		return false
	match edge:
		"north": return t.y == bounds.position.y
		"south": return t.y == bounds.end.y - 1
		"west": return t.x == bounds.position.x
		"east": return t.x == bounds.end.x - 1
	return false


func test_en_cada_exterior_se_pisan_bordes_y_pasarelas_y_se_cruza_a_casilla_libre() -> void:
	GameState.reset()
	for i: int in 8:
		GameState.badges.append(StringName("medalla_prueba_%d" % i))
	var world := _load_world()
	var tiles := {}
	var connections := {}
	for id: String in world:
		if not world[id].outdoor or (world[id].edges.is_empty() and world[id].warps.is_empty()):
			continue
		var prepared := MapLoader.prepare(StringName(id))
		assert_eq(prepared.error, OK, id)
		if prepared.error != OK:
			continue
		var map: MapRoot = prepared.map
		add_child(map)
		await wait_physics_frames(2)
		var free := _free_tiles(map)
		var starts: Array = []
		for spawn: Node2D in map.get_node("Spawns").get_children():
			starts.append(Grid.to_tile(spawn.position))
		free["reach"] = _flood(free.surf if id in SURF_MAPS else free.walk, starts)
		tiles[id] = free
		connections[id] = map.data.connections.duplicate()
		for warp: Warp in map.get_warps():
			assert_true(free.reach.has(Grid.to_tile(warp.position)), "%s: se pisa la pasarela %s" % [id, warp.name])
		map.free()
		await wait_physics_frames(1)
	GameState.reset()
	for id: String in connections:
		var bounds: Rect2i = tiles[id].bounds
		for c: MapConnection in connections[id]:
			var exits: Array = []
			for t: Vector2i in tiles[id].reach:
				if _on_edge(t, c.edge, bounds, c.span):
					exits.append(t)
			assert_false(exits.is_empty(), "%s: se llega al borde %s → %s" % [id, c.edge, c.target_map])
			var other: Variant = tiles.get(String(c.target_map))
			if other == null:
				continue
			var blocked: Array = []
			var one_way: Array = []
			exits.sort()
			for t: Vector2i in exits:
				var arrival := c.arrival(t + EDGE_DIR[c.edge], other.bounds)
				# Libre y unida al resto del otro mapa (no un hueco aislado entre árboles).
				var free_there: bool = other.reach.has(arrival)
				var back := false
				for r: MapConnection in connections[String(c.target_map)]:
					if r.edge == OPPOSITE[c.edge] and String(r.target_map) == id and r.matches(arrival - EDGE_DIR[c.edge], other.bounds):
						back = true
				if not free_there:
					blocked.append("%s→%s" % [t, arrival])
				elif not back:
					one_way.append("%s→%s" % [t, arrival])
			assert_eq(blocked, [], "%s → %s: al cruzar se llega a una casilla libre" % [id, c.target_map])
			assert_eq(one_way, [], "%s → %s: desde la llegada se vuelve por el mismo borde" % [id, c.target_map])


## Casillas libres (con los personajes colocados según las medallas), alcance desde las apariciones y bordes.
func _walkable(id: String, badges: int) -> Dictionary:
	GameState.reset()
	for i: int in badges:
		GameState.badges.append(StringName("medalla_prueba_%d" % i))
	var map: MapRoot = MapLoader.prepare(StringName(id)).map
	add_child(map)
	await wait_physics_frames(2)
	var free := _free_tiles(map)
	var starts: Array = []
	for spawn: Node2D in map.get_node("Spawns").get_children():
		starts.append(Grid.to_tile(spawn.position))
	free["default"] = Grid.to_tile((map.get_node("Spawns/default") as Node2D).position)
	free["reach"] = _flood(free.walk, starts)
	free["conns"] = map.data.connections.duplicate()
	map.free()
	await wait_physics_frames(1)
	return free


## Obras de la A-6 (data/personajes_en_el_mapa.json, "hasta" 7 medallas): cortan Moncloa ⇄ Ruta 4 en los dos
## sentidos y, al cruzar desde la Ruta 4, se llega a una casilla libre (no encima de un obrero).
func test_obras_de_la_a6_cortan_el_paso_sin_dejarte_encima_de_un_obrero() -> void:
	for badges: int in [0, 6, 7]:
		var moncloa := await _walkable("madrid/moncloa", badges)
		var ruta := await _walkable("ruta_4/exterior", badges)
		var arrivals := 0
		for c: MapConnection in ruta.conns:
			if String(c.target_map) != "madrid/moncloa":
				continue
			for t: Vector2i in ruta.reach:
				if not _on_edge(t, c.edge, ruta.bounds, c.span):
					continue
				var arrival := c.arrival(t + EDGE_DIR[c.edge], moncloa.bounds)
				arrivals += 1
				assert_true(moncloa.walk.has(arrival), "Con %d medallas, de la Ruta 4 se llega a %s, casilla libre" % [badges, arrival])
				var inside := _flood(moncloa.walk, [arrival])
				assert_eq(inside.has(moncloa.default), badges >= 7, "Con %d medallas, desde %s %s se pasa a Moncloa" % [badges, arrival, "sí" if badges >= 7 else "no"])
		assert_gt(arrivals, 0, "La Ruta 4 llega al borde de Moncloa")
		var exits := 0
		for c: MapConnection in moncloa.conns:
			if String(c.target_map) != "ruta_4/exterior":
				continue
			for t: Vector2i in _flood(moncloa.walk, [moncloa.default]):
				if _on_edge(t, c.edge, moncloa.bounds, c.span):
					exits += 1
		assert_eq(exits > 0, badges >= 7, "Con %d medallas, de Moncloa %s se sale a la Ruta 4" % [badges, "sí" if badges >= 7 else "no"])
	GameState.reset()
