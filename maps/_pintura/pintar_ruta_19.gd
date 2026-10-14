extends SceneTree
## Ruta 19 · Costa de Cantabria (docs/mundo/rutas.md). Entra por el oeste desde Santander (filas 12–15)
## y sale por el este a Bilbao (filas 20–23). El Cantábrico al norte, con la playa de los surfistas y
## los acantilados (bordillos que se saltan hacia el sur); al este, Castro Urdiales con la iglesia de
## Santa María, el faro y su puerto. Al sur, prados y hierba alta.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_19.gd -- --force

const OUT := "res://maps/ruta_19/exterior.tscn"
const SIZE := Vector2i(56, 36)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_19: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	print("%s: %s" % [OUT, error_string(_paint().save(OUT))])
	quit()


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


func _paint() -> Pintor:
	var d := MapData.new()
	d.id = &"ruta_19/exterior"
	d.display_name = "Ruta 19 · Costa de Cantabria"
	d.zone_id = &"ruta_19"
	d.encounter_table = &"ruta_19"
	d.region_map_position = Vector2i(15, 2)
	var p := Pintor.new("Ruta19", SIZE, d, 1919)
	p.fill_grass(0.22)
	p.connect_edge("west", &"santander/exterior", 0, Vector2i(12, 16))
	p.connect_edge("east", &"bilbao/exterior", 0, Vector2i(20, 24))

	# El Cantábrico y la playa de los surfistas.
	p.water(Rect2i(0, 0, 56, 8))
	p.build_water(0.35)
	p.soil(Rect2i(0, 8, 16, 3))

	p.terrain(rects([
		Rect2i(0, 12, 22, 4),    # desde Santander
		Rect2i(18, 12, 4, 12),   # baja junto a los acantilados
		Rect2i(18, 20, 38, 4),   # hacia Bilbao
		Rect2i(40, 14, 4, 6),    # subida a Castro Urdiales
		Rect2i(40, 12, 6, 2),    # el muelle de Castro
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(2, 24, 14, 8),
		Rect2i(24, 26, 14, 8),
		Rect2i(44, 26, 10, 6),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Acantilados: bordillos sobre el mar que se saltan hacia el sur.
	p.ledge(23, 38, 10)
	p.ledge(24, 36, 15)
	for at: Vector2i in [Vector2i(26, 13), Vector2i(31, 13), Vector2i(35, 18)]:
		p.object(&"arbol_redondo", at)

	# Castro Urdiales: la iglesia gótica de Santa María, el faro sobre las rocas y el puerto.
	p.object(&"iglesia_altea", Vector2i(44, 11))
	p.object(&"faro", Vector2i(30, 9))
	p.object(&"casa_azul_pequena", Vector2i(51, 18))
	p.object(&"casa_naranja", Vector2i(46, 19))
	p.object(&"barca_albufera", Vector2i(48, 6))
	p.forest(Rect2i(0, 32, 56, 4))
	p.forest(Rect2i(0, 16, 14, 6))
	p.build_forest()

	_sign(p, "CartelOeste", Vector2i(2, 16), ["← Santander."])
	_sign(p, "CartelPlaya", Vector2i(16, 9), ["PLAYA.", "Olas buenas, agua fría, neopreno obligatorio. En agosto también."])
	_sign(p, "CartelCastro", Vector2i(39, 17), ["CASTRO URDIALES.",
		"Santa María, el castillo-faro y el puente medieval. Aquí el bocarte se pesca; en Santoña lo convierten en anchoa."])
	_sign(p, "CartelEste", Vector2i(53, 24), ["→ Bilbao.", "Gimnasio 6, en San Mamés. Lleva el bocadillo; la grada canta noventa minutos."])

	p.spawn("default", Vector2i(20, 18))
	p.spawn("from_santander", Vector2i(0, 13))
	p.spawn("from_bilbao", Vector2i(55, 21))
	p.trainer("Surfista", &"ruta19_surfista", Vector2i(10, 11), DOWN, 3)
	p.trainer("Pescador", &"ruta19_pescador", Vector2i(45, 13), LEFT, 3)
	p.npc("Bocartera", "npc_old_woman", Vector2i(43, 15), DOWN, PackedStringArray([
		"Bocarte fresco, frito o en vinagre. La anchoa es el mismo pez, pero con más tiempo y más precio.",
		"Mi marido pesca, yo vendo y el de la lonja se queda la mitad."]))
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
