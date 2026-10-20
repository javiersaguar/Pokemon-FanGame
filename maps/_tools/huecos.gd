extends SceneTree
## Mide lo que más se aleja de Añil en cada exterior, para saber por dónde empezar la siguiente pasada:
## - hueco: lado del cuadrado más grande de casillas que se pisan y están vacías (hierba, tierra, arena
##   o empedrado lisos, sin hierba alta, camino, flores, adornos ni el dibujo de ningún objeto);
## - vacío: porcentaje de casillas que se pisan y están vacías;
## - recta: el tramo recto más largo de borde de bosque (filas o columnas de pinos con el mismo borde).
## Escribe una línea por mapa, ordenadas de peor a mejor por el hueco.
## Uso: godot --headless --path . -s res://maps/_tools/huecos.gd -- <mapa>...  (o --rutas, --ciudades)

const PLAIN := ["grass", "", "stone", "sand", "dirt", "snow"]


func _initialize() -> void:
	await process_frame
	var mids: Array[String] = []
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--rutas":
			for r: int in range(1, 27):
				mids.append("ruta_%d/exterior" % r)
			mids.append("maritima_1/exterior")
		elif arg == "--ciudades":
			for entry: Variant in JsonFile.read_dict("res://data/region.json").get("locations", {}).values():
				mids.append(String(entry.get("map", "")))
			for entry: Variant in JsonFile.read_dict("res://data/region.json").get("districts", {}).values():
				mids.append(String(entry.get("map", "")))
		elif not arg.begins_with("--"):
			mids.append(arg)
	var rows: Array = []
	for mid: String in mids:
		if mid == "" or not ResourceLoader.exists("res://maps/%s.tscn" % mid) or rows.any(func(r: Array) -> bool: return r[0] == mid):
			continue
		rows.append(await _measure(mid))
	rows.sort_custom(func(a: Array, b: Array) -> bool: return a[1] > b[1])
	for r: Array in rows:
		print("%-34s hueco %2d en %-10s vacío %3d%%  recta %2d" % r)
	quit()


func _measure(mid: String) -> Array:
	var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var v := Vestidor.new()
	v.setup(map, mid)
	v.scan(root.get_world_2d().direct_space_state)
	var empty := {}
	for at: Vector2i in v.free:
		if v.terrain(at) in PLAIN and v.decor.get_cell_source_id(at) == -1 and not v.covered.has(at) \
				and v.objects.get_cell_source_id(at) == -1:
			empty[at] = true
	# Cuadrado vacío más grande (programación dinámica).
	var size := {}
	var best := 0
	var best_at := Vector2i.ZERO
	for y: int in range(v.bounds.position.y, v.bounds.end.y):
		for x: int in range(v.bounds.position.x, v.bounds.end.x):
			var at := Vector2i(x, y)
			if not empty.has(at):
				continue
			var s := 1 + mini(int(size.get(at + Vector2i.LEFT, 0)), mini(int(size.get(at + Vector2i.UP, 0)), int(size.get(at + Vector2i(-1, -1), 0))))
			size[at] = s
			if s > best:
				best = s
				best_at = at - Vector2i(s - 1, s - 1)
	# Borde recto de bosque más largo.
	var straight := 0
	for dir: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
		var normal := Vector2i(dir.y, dir.x)
		for side: int in [-1, 1]:
			for at: Vector2i in v.forest:
				if v.forest.has(at - dir) and v.free.has(at - dir + normal * side) == v.free.has(at + normal * side):
					continue
				if not v.free.has(at + normal * side):
					continue
				var run := 0
				var t := at
				while v.forest.has(t) and v.free.has(t + normal * side):
					run += 1
					t += dir
				straight = maxi(straight, run)
	var ratio := int(100.0 * empty.size() / maxf(1.0, v.free.size()))
	map.queue_free()
	await process_frame
	return [mid, best, str(best_at), ratio, straight]
