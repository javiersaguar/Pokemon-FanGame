extends SceneTree
## Pinta la Ruta 16 · Rías Baixas (maps/ruta_16/exterior.tscn). El sur enlaza con Vigo (columnas 24–29,
## las mismas que el borde norte de Vigo). La ría queda al oeste, con dos bateas. Al este, Sanxenxo:
## un cartel de las regatas (el rey emérito no está en el mapa). El norte, columnas 16–21, queda para
## la Ruta 17. docs/mundo/rutas.md.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_16.gd -- --force

const OUT := "res://maps/ruta_16/exterior.tscn"
const SIZE := Vector2i(36, 52)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_16: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"ruta_16/exterior"
	data.display_name = "Ruta 16 · Rías Baixas"
	data.zone_id = &"ruta_16"
	data.encounter_table = &"ruta_16"
	data.region_map_position = Vector2i(2, 4)
	var p: RefCounted = painter.new("Ruta16", SIZE, data, 1616)
	p.fill_grass(0.18)
	# Mismas columnas que el norte de Vigo. El norte lo cierra este agente al pintar la Ruta 17.
	p.connect_edge("south", &"vigo/exterior", 0, Vector2i(24, 30))
	p.connect_edge("north", &"ruta_17/exterior", 0, Vector2i(16, 22))

	# La ría, al oeste. Las bateas son muelles de camino sobre el agua.
	p.water(Rect2i(0, 8, 14, 36))
	p.build_water(0.3)
	p.terrain(rects([
		Rect2i(16, 0, 6, SIZE.y),     # camino norte-sur, columnas 16–21
		Rect2i(22, 44, 8, 8),         # enlace con Vigo, columnas 24–29
		Rect2i(8, 18, 8, 2),          # batea
		Rect2i(6, 32, 10, 2),         # batea
		Rect2i(22, 22, 8, 3),         # acceso a Sanxenxo
		Rect2i(22, 36, 12, 3),
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(24, 4, 12, 12),
		Rect2i(24, 28, 12, 6),
		Rect2i(24, 42, 12, 8),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	p.object(&"casa_dos_aguas", Vector2i(26, 24))
	p.object(&"casa_madera", Vector2i(30, 38))
	p.object(&"arbol_redondo", Vector2i(23, 12))
	p.object(&"arbol_redondo", Vector2i(32, 48))
	p.object(&"farola_verde", Vector2i(22, 46))

	p.deco(Vector2i(24, 48), ExteriorTiles.SIGN)
	p.sign_text("CartelVigo", Vector2i(24, 48), PackedStringArray(["↓ Vigo.",
		"El árbol sigue encendido. En julio también."]))
	p.deco(Vector2i(16, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelNorte", Vector2i(16, 2), PackedStringArray(["↑ Ruta 17 · Galicia interior.",
		"Hórreos, muralla de Lugo y, si llueve, es que es martes."]))
	p.deco(Vector2i(24, 22), ExteriorTiles.SIGN)
	p.sign_text("CartelSanxenxo", Vector2i(24, 22), PackedStringArray(["SANXENXO · REGATAS.",
		"El pantalón de loneta ya ha zarpado. Aquí solo quedan las bateas y el mejillón."]))
	p.deco(Vector2i(10, 18), ExteriorTiles.SIGN)
	p.sign_text("CartelBatea", Vector2i(10, 18), PackedStringArray(["BATEA.",
		"Mejillón de la ría. El cupo, como el de las Cíes: se acaba antes que las ganas."]))

	p.spawn("default", Vector2i(18, 28))
	p.spawn("from_vigo", Vector2i(26, 50))
	p.spawn("from_ruta_17", Vector2i(18, 1))
	p.trainer("Roi", &"ruta16_regatista", Vector2i(22, 30), LEFT, 3)
	p.trainer("Iria", &"ruta16_nadadora", Vector2i(15, 40), RIGHT, 3)
	p.npc("Bateeiro", "npc_fisherman", Vector2i(12, 32), DOWN, PackedStringArray([
		"Llevo el mejillón a Vigo antes de que lo lleve el de la batea de al lado.",
		"En Sanxenxo hoy hay regata. El barco grande no atraca aquí."]))
	return p
