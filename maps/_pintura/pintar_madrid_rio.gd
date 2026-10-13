extends SceneTree
## Pinta Madrid Río (maps/madrid_rio/exterior.tscn), la ruta inicial corta de Orcasitas a Atocha
## (docs/DECISIONES_JAVIER_2026-10-13.md §7, niveles 2–6): el parque lineal junto al Manzanares, el
## Puente de Toledo, el Matadero y El Jincho cantando en el puente. Une sin fundido con Orcasitas
## (sur, columnas 18–23) y con Madrid · Retiro (norte, columnas 14–19 ⇄ 6–11 de Atocha).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_rio.gd -- --force

const OUT := "res://maps/madrid_rio/exterior.tscn"
const SIZE := Vector2i(36, 40)


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_rio: '%s' ya existe; usa -- --force." % OUT)
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
	data.id = &"madrid_rio/exterior"
	data.display_name = "Madrid Río"
	data.zone_id = &"madrid_rio"
	data.encounter_table = &"madrid_rio"
	data.region_map_position = Vector2i(14, 12)
	var p: RefCounted = painter.new("MadridRio", SIZE, data, 2011)
	p.fill_grass(0.25)
	p.connect_edge("south", &"orcasitas/exterior", 0, Vector2i(18, 24))
	p.connect_edge("north", &"madrid/retiro", -8, Vector2i(14, 20))
	# El Manzanares con el hueco del Puente de Toledo (debajo hay suelo pisable).
	p.water(Rect2i(0, 16, 17, 8))
	p.water(Rect2i(19, 16, 17, 8))
	p.build_water(0.25)
	p.terrain(rects([Rect2i(17, 16, 2, 8), Rect2i(18, 24, 6, 16), Rect2i(14, 0, 6, 16), Rect2i(17, 12, 2, 4)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(4, 26, 10, 6), Rect2i(26, 4, 8, 7), Rect2i(26, 28, 6, 6)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	for r: Rect2i in [Rect2i(0, 0, 14, 2), Rect2i(20, 0, 16, 2), Rect2i(0, 2, 2, 14), Rect2i(34, 2, 2, 14), Rect2i(0, 24, 2, 16),
			Rect2i(34, 24, 2, 16), Rect2i(2, 38, 16, 2), Rect2i(24, 38, 10, 2)]:
		p.forest(r)
	p.build_forest()
	p.object_under(&"puente_piedra", Vector2i(16, 23))   # el Puente de Toledo
	p.object(&"nave_logistica", Vector2i(3, 12))          # el Matadero
	for cell: Vector2i in [Vector2i(22, 6), Vector2i(10, 4), Vector2i(28, 14), Vector2i(8, 35), Vector2i(29, 36)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(14, 33), Vector2i(24, 26)]:
		p.object(&"banco", cell)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])
	p.deco(Vector2i(24, 37), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(24, 37), PackedStringArray(["MADRID RÍO.",
		"Diez kilómetros de parque encima de la M-30. Costó lo que cuesta un país pequeño. ↑ Atocha."]))
	p.deco(Vector2i(20, 24), ExteriorTiles.SIGN)
	p.sign_text("CartelPuente", Vector2i(20, 24), PackedStringArray(["PUENTE DE TOLEDO (siglo XVIII).",
		"Barroco y de piedra. Debajo del río pasaba la M-30; ahora pasa por debajo del parque. Y el río, por donde puede."]))
	p.deco(Vector2i(9, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelMatadero", Vector2i(9, 13), PackedStringArray(["MATADERO MADRID.", "Antes, matadero. Ahora, centro cultural. Las exposiciones también duelen."]))
	p.spawn("default", Vector2i(20, 38))
	p.spawn("from_orcasitas", Vector2i(20, 39))
	p.spawn("from_retiro", Vector2i(16, 0))
	p.trainer("ElJincho", &"el_jincho", Vector2i(19, 13), 0, 3)
	p.trainer("Dani", &"madridrio_repartidor", Vector2i(24, 32), 1, 3)
	p.npc("Abuelo", "npc_old_man", Vector2i(15, 30), 2, PackedStringArray([
		"Antes por aquí pasaban coches. Ahora pasan corredores. Hacen el mismo ruido, pero sudan más."]))
	return p
