extends GutTest
## Interiores personalizados (data/interiores/*.json, pintados con
## maps/_pintura/pintar_interiores_datos.gd):
## - ningún interior repite firma (suelo, pared, muebles y casillas) con otro, salvo los locales
##   de servicio estándar (Centro Pokémon u hospital, Mercadona y estanco), que comparten
##   estructura; los gimnasios y los transportes tienen su propio test;
## - cada puerta que lleva a uno de estos interiores tiene vuelta: la aparición de llegada
##   existe y no cae en un paso (sin bucles de reentrada), desde ella se llega andando a la
##   salida, y la salida vuelve al mapa de origen a una aparición que existe y tampoco cae en un paso;
## - se llega a hablar con cada persona y a leer cada cartel;
## - ninguna frase se repite entre interiores y la escena está al día con sus datos.

const DATOS := "res://data/interiores/"
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const SERVICIOS := ["mercadona", "estanco", "centro", "hospital"]
const NPC_SCRIPT := "res://src/overworld/npc/npc.gd"

var _datos: Dictionary = {}


func before_all() -> void:
	for file: String in DirAccess.get_files_at(DATOS):
		if not file.ends_with(".json") or file.begins_with("_"):
			continue
		var d := JsonFile.read_dict(DATOS + file)
		var ints: Dictionary = d.get("interiores", {})
		for id: String in ints:
			_datos[id] = ints[id]


func test_hay_interiores_personalizados() -> void:
	assert_gt(_datos.size(), 0, "data/interiores tiene salas")


func test_ningun_interior_repite_firma() -> void:
	var firmas := {}
	for id: StringName in MapRoot.list_all():
		var s := String(id)
		if s.begins_with("transporte/") or s.begins_with("test/") or s.begins_with("muestras/") or s == "madrid/quiron":
			continue
		var file := s.get_file()
		if file in SERVICIOS or file.begins_with("gimnasio"):
			continue
		var map := _cargar(s)
		if map == null:
			continue
		if not (map.data != null and not map.data.outdoor):
			map.free()
			continue
		var f := _firma(map)
		map.free()
		firmas.get_or_add(f, []).append(s)
	for f: String in firmas:
		var ids: Array = firmas[f]
		if ids.size() < 2:
			continue
		var nuestros := ids.filter(func(i: String) -> bool: return _datos.has(i))
		assert_eq(nuestros.size(), 0, "Misma firma: %s" % ", ".join(PackedStringArray(ids)))


func test_cada_puerta_tiene_entrada_y_salida_en_los_dos_sentidos() -> void:
	var entradas := {}
	for id: StringName in MapRoot.list_all():
		var s := String(id)
		if s.begins_with("test/") or s.begins_with("muestras/"):
			continue
		var map := _cargar(s)
		if map == null:
			continue
		var interior := map.data != null and not map.data.outdoor
		for warp: Warp in map.get_warps():
			var destino := String(warp.target_map)
			# La salida de una sala de dentro (un dormitorio) es la vuelta, no una entrada.
			if interior and warp.name == &"Salida":
				continue
			if _datos.has(destino):
				entradas.get_or_add(destino, []).append({"origen": s, "paso": Grid.to_tile(warp.position), "aparicion": warp.target_spawn})
		map.free()
	for id: String in _datos:
		assert_true(entradas.has(id), "%s tiene alguna puerta que lleve a él" % id)
		if not entradas.has(id):
			continue
		var sala := _cargar(id)
		assert_not_null(sala, id)
		if sala == null:
			continue
		var salida := sala.get_node_or_null(^"Warps/Salida") as Warp
		assert_not_null(salida, "%s tiene salida" % id)
		if salida == null:
			sala.free()
			continue
		var libres := _libres(sala)
		for entrada: Dictionary in entradas[id]:
			var llegada: Variant = MapLoader.spawn_tile(sala, entrada.aparicion)
			assert_not_null(llegada, "%s: existe la aparición %s" % [id, entrada.aparicion])
			if llegada == null:
				continue
			assert_null(sala.warp_at(llegada), "%s: se llega fuera de un paso (sin bucle)" % id)
			var alcance := _alcance(llegada, libres)
			assert_true(alcance.has(Grid.to_tile(salida.position)), "%s: desde %s se llega a la salida" % [id, entrada.aparicion])
			assert_eq(String(salida.target_map), String(entrada.origen), "%s: la salida vuelve a %s" % [id, entrada.origen])
		var origen := _cargar(String(salida.target_map))
		assert_not_null(origen, "%s: existe el mapa de la salida" % id)
		if origen != null:
			var vuelta: Variant = MapLoader.spawn_tile(origen, salida.target_spawn)
			assert_not_null(vuelta, "%s: existe la aparición de vuelta %s" % [id, salida.target_spawn])
			if vuelta != null:
				assert_null(origen.warp_at(vuelta), "%s: la vuelta no cae en un paso" % id)
				assert_true(MapLoader.valid_tile(origen, vuelta), "%s: la vuelta es una casilla del mapa" % id)
			origen.free()
		sala.free()


func test_se_llega_a_cada_persona_y_cartel() -> void:
	for id: String in _datos:
		var sala := _cargar(id)
		if sala == null:
			continue
		var libres := _libres(sala)
		var inicio: Variant = MapLoader.spawn_tile(sala, &"default")
		assert_not_null(inicio, "%s tiene aparición default" % id)
		if inicio == null:
			sala.free()
			continue
		var alcance := _alcance(inicio, libres)
		var ocupadas := {}
		for node: Node in sala.get_entities().get_children():
			if node is Node2D and not node is TileMapLayer:
				ocupadas[Grid.to_tile((node as Node2D).position)] = true
		for node: Node in sala.get_entities().get_children():
			if node is TileMapLayer or not node is Node2D:
				continue
			var at := Grid.to_tile((node as Node2D).position)
			assert_true(_se_llega(sala, at, alcance, ocupadas), "%s: se llega a %s en %s" % [id, node.name, at])
		sala.free()


func test_las_frases_no_se_repiten_y_la_escena_esta_al_dia() -> void:
	var vistas := {}
	for id: String in _datos:
		var e: Dictionary = _datos[id]
		var sala := _cargar(id)
		assert_not_null(sala, "%s está pintado" % id)
		if sala == null:
			continue
		if e.has("tamano"):
			assert_eq(sala.get_ground().get_used_rect().size, Vector2i(int(e.tamano[0]), int(e.tamano[1])), "%s tiene el tamaño de sus datos" % id)
		for grupo: String in ["personas", "carteles"]:
			for q: Dictionary in e.get(grupo, []):
				var node := sala.get_entities().get_node_or_null(NodePath(str(q.get("nodo", "")))) as Node2D
				assert_not_null(node, "%s: está %s" % [id, q.get("nodo", "")])
				if node != null and q.has("en"):
					assert_eq(Grid.to_tile(node.position), Vector2i(int(q.en[0]), int(q.en[1])), "%s/%s en su casilla" % [id, q.nodo])
				for f: Variant in q.get("frases", []):
					var texto := str(f)
					assert_false(vistas.has(texto), "Frase repetida en %s y %s: %s" % [id, vistas.get(texto, ""), texto])
					vistas[texto] = id
		sala.free()


func test_partida_guardada_en_una_sala_rehecha_se_recoloca() -> void:
	var id := "ibiza/casa_1"
	assert_true(_datos.has(id))
	var sala := _cargar(id)
	var legacy := sala.data.legacy_save_bounds
	var entrada: Vector2i = MapLoader.spawn_tile(sala, &"default")
	var mueble := Vector2i(-1, -1)
	var objetos := sala.get_layer(&"Entities/Objects")
	for c: Vector2i in objetos.get_used_cells():
		if c.y >= 2 and sala.get_ground().get_cell_source_id(c) >= 0:
			mueble = c
			break
	sala.free()
	assert_true(legacy.has_area(), "la sala rehecha recuerda su área de antes")
	var state := GameState.to_dict()
	state.position = {"map": id, "tile": [legacy.end.x - 1, legacy.end.y - 1], "facing": [0, 1]}
	var fuera := MapLoader.saved_position(state)
	assert_eq(fuera.error, OK)
	assert_true(fuera.migrated, "una casilla de la sala antigua que ya no existe se recoloca")
	assert_eq(fuera.tile, entrada)
	if mueble.x >= 0:
		state.position.tile = [mueble.x, mueble.y]
		var encima := MapLoader.saved_position(state)
		assert_eq(encima.error, OK)
		assert_true(encima.migrated, "una casilla que ahora tapa un mueble se recoloca")
		assert_eq(encima.tile, entrada)
	state.position.tile = [entrada.x, entrada.y]
	assert_false(MapLoader.saved_position(state).migrated, "la entrada se queda donde está")
	state.position.tile = [999, 999]
	assert_eq(MapLoader.check_position(state), ERR_INVALID_DATA)


func _cargar(id: String) -> MapRoot:
	var path := MapRoot.path_from_id(StringName(id))
	if not ResourceLoader.exists(path):
		return null
	var node := (load(path) as PackedScene).instantiate()
	if not node is MapRoot:
		node.free()
		return null
	return node as MapRoot


## Suelo, pared y muebles con sus casillas (todas las capas de casillas).
func _firma(map: MapRoot) -> String:
	var partes := PackedStringArray()
	for capa: String in ["Ground", "Decor", "Entities/Objects", "Above"]:
		var layer := map.get_node_or_null(NodePath(capa)) as TileMapLayer
		if layer == null:
			continue
		var celdas := layer.get_used_cells()
		celdas.sort()
		for c: Vector2i in celdas:
			partes.append("%s|%d,%d|%d|%s|%d" % [capa, c.x, c.y, layer.get_cell_source_id(c), layer.get_cell_atlas_coords(c), layer.get_cell_alternative_tile(c)])
	return "\n".join(partes).md5_text()


## Casillas por las que se anda: hay suelo, ninguna capa con colisión tiene allí una casilla
## sólida y no hay nadie de pie.
func _libres(map: MapRoot) -> Dictionary:
	var out := {}
	var ground := map.get_ground()
	var capas: Array[TileMapLayer] = []
	for capa: String in ["Decor", "Entities/Objects", "Above"]:
		var layer := map.get_node_or_null(NodePath(capa)) as TileMapLayer
		if layer != null and layer.collision_enabled:
			capas.append(layer)
	var gente := {}
	for node: Node in map.get_entities().get_children():
		if node is Node2D and not node is TileMapLayer:
			gente[Grid.to_tile((node as Node2D).position)] = true
	for c: Vector2i in ground.get_used_cells():
		if gente.has(c):
			continue
		var solida := false
		for layer: TileMapLayer in capas:
			var td := layer.get_cell_tile_data(c)
			if td != null and td.get_collision_polygons_count(0) > 0:
				solida = true
				break
		if not solida:
			out[c] = true
	return out


func _alcance(inicio: Vector2i, libres: Dictionary) -> Dictionary:
	var vistos := {inicio: true}
	var cola: Array[Vector2i] = [inicio]
	var i := 0
	while i < cola.size():
		var c := cola[i]
		i += 1
		for d: Vector2i in DIRS:
			var n := c + d
			if libres.has(n) and not vistos.has(n):
				vistos[n] = true
				cola.append(n)
	return vistos


## Al lado, o por encima de un mostrador de una o dos casillas de fondo sin nada encima.
func _se_llega(map: MapRoot, at: Vector2i, alcance: Dictionary, ocupadas: Dictionary) -> bool:
	for d: Vector2i in DIRS:
		if alcance.has(at + d):
			return true
		var m1 := at + d
		var m2 := at + d * 2
		if map.terrain_at(m1) != "counter" or ocupadas.has(m1):
			continue
		if alcance.has(m2):
			return true
		if map.terrain_at(m2) == "counter" and not ocupadas.has(m2) and alcance.has(at + d * 3):
			return true
	return false
