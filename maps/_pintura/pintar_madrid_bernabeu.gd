extends SceneTree
## Pinta Madrid · Bernabéu (maps/madrid/bernabeu.tscn): el Paseo de la Castellana con el estadio Santiago
## Bernabéu reformado (dibujado a mano), su explanada, la tienda del club y las torres de oficinas. Aquí
## están Vinicius y Mbappé (decisión de Javier, 2026-10-14) y Enrique Iglesias con su concierto. Une sin
## fundido con Chamberí por el sur (columnas 20–25 de los dos mapas).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_bernabeu.gd -- --force

const OUT := "res://maps/madrid/bernabeu.tscn"
const SIZE := Vector2i(40, 32)


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_bernabeu: '%s' ya existe; usa -- --force (se pierden las puertas enlazadas)." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"madrid/bernabeu"
	data.display_name = "Madrid · Bernabéu"
	data.zone_id = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridBernabeu", SIZE, data, 1902)
	p.fill_grass(0.0)
	p.connect_edge("south", &"madrid/chamberi", 0, Vector2i(20, 26))
	p.paving(Rect2i(0, 0, 40, 32))
	p.build_paving()
	# El estadio en el centro; torres de oficinas de la Castellana a los lados.
	p.object(&"bernabeu", Vector2i(14, 14))
	for b: Array in [[&"oficinas_azules", Vector2i(2, 9)], [&"edificio_cristal", Vector2i(30, 11)], [&"bloque_pisos", Vector2i(2, 26)],
			[&"tienda_azul", Vector2i(31, 26)], [&"oficinas_verdes", Vector2i(9, 9)]]:
		p.object(b[0], b[1])
	# El bulevar de la Castellana: árboles y farolas.
	for y: int in [19, 25, 31]:
		p.object(&"arbol_redondo", Vector2i(12, y))
		p.object(&"arbol_redondo", Vector2i(27, y))
	for cell: Vector2i in [Vector2i(17, 17), Vector2i(23, 17)]:
		p.object(&"farola_verde", cell)
	p.deco(Vector2i(20, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelEstadio", Vector2i(20, 15), PackedStringArray(["ESTADIO SANTIAGO BERNABÉU.",
		"Reformado con lamas de acero, cubierta retráctil y un videomarcador de 360 grados.",
		"Costó más de mil millones. Los vecinos de la Castellana, a cambio, tienen conciertos hasta las tantas."]))
	p.deco(Vector2i(33, 27), ExteriorTiles.SIGN)
	p.sign_text("CartelTienda", Vector2i(33, 27), PackedStringArray(["TIENDA OFICIAL DEL REAL MADRID.", "Camiseta de la temporada: 150 euros. Con el nombre de Mbappé, el doble."]))
	p.deco(Vector2i(19, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelCastellana", Vector2i(19, 30), PackedStringArray(["PASEO DE LA CASTELLANA.", "↓ Chamberí y el centro."]))
	p.spawn("default", Vector2i(22, 30))
	p.spawn("from_chamberi", Vector2i(22, 31))
	p.npc("Socio", "npc_old_man", Vector2i(6, 18), 2, PackedStringArray([
		"Soy socio desde 1965. He visto ganar catorce Copas de Europa y ahora no me dejan aparcar por los conciertos."]))
	return p
