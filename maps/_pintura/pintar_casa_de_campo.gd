extends SceneTree
## Pinta la Casa de Campo (maps/casa_de_campo/exterior.tscn), la ruta inicial corta de Pozuelo a Madrid ·
## Moncloa (docs/DECISIONES_JAVIER_2026-10-13.md §7, niveles 2–6): encinar y pinar, el lago con sus barcas,
## los carteles del Zoo, el Parque de Atracciones y el Teleférico, que sube a Rosales (Moncloa).
## Une sin fundido con Pozuelo (oeste, filas 16–19) y con Moncloa (norte, columnas 30–35 ⇄ 4–9 de Moncloa).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_casa_de_campo.gd -- --force

const OUT := "res://maps/casa_de_campo/exterior.tscn"
const SIZE := Vector2i(40, 36)


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_casa_de_campo: '%s' ya existe; usa -- --force." % OUT)
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
	data.id = &"casa_de_campo/exterior"
	data.display_name = "Casa de Campo"
	data.zone_id = &"casa_de_campo"
	data.encounter_table = &"casa_de_campo"
	data.region_map_position = Vector2i(13, 11)
	var p: RefCounted = painter.new("CasaDeCampo", SIZE, data, 1931)
	p.fill_grass(0.3)
	p.connect_edge("west", &"pozuelo/exterior", 0, Vector2i(16, 20))
	p.connect_edge("north", &"madrid/moncloa", -26, Vector2i(30, 36))
	p.terrain(rects([Rect2i(0, 16, 26, 3), Rect2i(24, 2, 3, 17), Rect2i(24, 2, 12, 3), Rect2i(31, 0, 4, 4)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(4, 22, 10, 6), Rect2i(28, 10, 8, 6), Rect2i(16, 26, 8, 5)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.water(Rect2i(6, 4, 12, 8))                       # el lago
	p.build_water(0.25)
	for r: Rect2i in [Rect2i(0, 0, 30, 2), Rect2i(36, 0, 4, 36), Rect2i(0, 2, 2, 14), Rect2i(0, 20, 2, 16), Rect2i(2, 32, 34, 4),
			Rect2i(28, 18, 8, 10)]:
		p.forest(r)
	p.build_forest()
	for cell: Vector2i in [Vector2i(20, 8), Vector2i(4, 14), Vector2i(14, 22), Vector2i(26, 28)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(20, 13), Vector2i(18, 24)]:
		p.object(&"pino", cell)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])
	p.deco(Vector2i(2, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(2, 15), PackedStringArray(["CASA DE CAMPO.",
		"El pulmón de Madrid: cinco veces el Retiro. → Zoo y Parque de Atracciones (cerrados para ti: no tienes medallas).",
		"↑ Teleférico y Moncloa: el laboratorio del profesor Unicoos."]))
	p.deco(Vector2i(19, 12), ExteriorTiles.SIGN)
	p.sign_text("CartelLago", Vector2i(19, 12), PackedStringArray(["LAGO DE LA CASA DE CAMPO.", "Alquiler de barcas: 8 euros. Los Magikarp, gratis."]))
	p.deco(Vector2i(30, 5), ExteriorTiles.SIGN)
	p.sign_text("CartelTeleferico", Vector2i(30, 5), PackedStringArray(["TELEFÉRICO DE MADRID · Rosales ⇄ Casa de Campo.",
		"Fuera de servicio por mantenimiento desde que se inventó. Sigue el camino hacia el norte."]))
	p.spawn("default", Vector2i(1, 17))
	p.spawn("from_pozuelo", Vector2i(0, 17))
	p.spawn("from_moncloa", Vector2i(32, 0))
	p.trainer("Borja", &"casadecampo_padretarjeta", Vector2i(12, 18), 3, 3)
	p.trainer("Lucas", &"casadecampo_patinetero", Vector2i(25, 9), 1, 3)
	p.npc("Corredor", "npc_man", Vector2i(10, 15), 0, PackedStringArray([
		"Vengo corriendo desde Pozuelo. Mentira: me ha traído el chófer hasta aquí y ahora corro para la foto."]))
	return p
