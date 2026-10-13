extends SceneTree
## Pinta Pozuelo de Alarcón (maps/pozuelo/exterior.tscn), pueblo inicial de cayetano y cayetana
## (docs/DECISIONES_JAVIER_2026-10-13.md §2 y §7): una urbanización de chalets con jardín, setos y
## piscina, la casa del jugador, la del rival y la avenida que sale al este hacia la Casa de Campo.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_pozuelo.gd -- --force

const OUT := "res://maps/pozuelo/exterior.tscn"
const SIZE := Vector2i(44, 36)


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_pozuelo: '%s' ya existe; usa -- --force (se pierden las puertas enlazadas)." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"pozuelo/exterior"
	data.display_name = "Pozuelo de Alarcón"
	data.zone_id = &"pozuelo"
	data.region_map_position = Vector2i(13, 11)
	var p: RefCounted = painter.new("Pozuelo", SIZE, data, 1979)
	p.fill_grass(0.15)
	p.connect_edge("east", &"casa_de_campo/exterior", 0, Vector2i(16, 20))
	# La avenida de la urbanización y las aceras hasta cada chalet.
	p.paving(Rect2i(0, 16, 44, 4))
	p.paving(Rect2i(30, 6, 4, 10))
	p.build_paving()
	for r: Rect2i in [Rect2i(0, 0, 44, 4), Rect2i(0, 4, 2, 12), Rect2i(0, 20, 2, 16), Rect2i(0, 34, 44, 2),
			Rect2i(42, 4, 2, 12), Rect2i(42, 20, 2, 14)]:
		p.forest(r)
	p.build_forest()
	# Chalets: el del jugador (azul) y el del rival (rojo), y los de los vecinos.
	for b: Array in [[&"casa_tejado_azul", Vector2i(4, 13)], [&"casa_roja", Vector2i(12, 13)], [&"casa_azul", Vector2i(20, 13)],
			[&"casa_naranja", Vector2i(36, 13)], [&"casa_rosa", Vector2i(4, 30)], [&"casa_madera", Vector2i(12, 30)],
			[&"casa_tejado_rojo", Vector2i(20, 30)], [&"casa_roja_chimenea", Vector2i(30, 30)]]:
		p.object(b[0], b[1])
	_door(p, &"casa_tejado_azul", Vector2i(4, 13), &"pozuelo/casa_jugador", "CasaJugador", "from_casa_jugador")
	_door(p, &"casa_roja", Vector2i(12, 13), &"pozuelo/casa_rival", "CasaRival", "from_casa_rival")
	# Setos, piscinas y jardines.
	p.hedge(2, 9, 5)
	p.hedge(10, 17, 5)
	p.pond(Rect2i(27, 8, 3, 3), [])
	p.pond(Rect2i(36, 23, 4, 3), [])
	p.flowers(Rect2i(6, 22, 4, 1), 0.5)
	p.flowers(Rect2i(27, 22, 3, 1), 0.5)
	for cell: Vector2i in [Vector2i(10, 8), Vector2i(19, 6), Vector2i(28, 27), Vector2i(39, 6)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(3, 22), Vector2i(40, 30)]:
		p.object(&"farola_verde", cell)

	p.deco(Vector2i(40, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelPueblo", Vector2i(40, 15), PackedStringArray(["POZUELO DE ALARCÓN.",
		"El municipio con más renta de España. Aquí hasta los Rattata llevan náuticos.", "→ Casa de Campo y Madrid."]))
	p.deco(Vector2i(8, 14), ExteriorTiles.SIGN)
	p.sign_text("CartelCasa", Vector2i(8, 14), PackedStringArray(["TU CASA.", "Chalet con piscina, jardín y una hipoteca que pagan tus padres."]))
	p.deco(Vector2i(16, 14), ExteriorTiles.SIGN)
	p.sign_text("CartelRival", Vector2i(16, 14), PackedStringArray(["CASA DE TU RIVAL.", "Su padre es notario. Su abuelo, también. Él va a ser influencer."]))
	p.spawn("default", Vector2i(5, 15))
	p.spawn("from_casa_de_campo", Vector2i(43, 17))
	p.npc("Jardinero", "npc_old_man", Vector2i(24, 21), 0, PackedStringArray([
		"Llevo treinta años cortando el césped de esta urbanización. Nunca me han dejado bañarme en la piscina.",
		"Dicen que en Madrid el profesor Unicoos regala Pokémon. Aquí regalan másteres."]))
	p.npc("Vecina", "npc_woman", Vector2i(30, 21), 1, PackedStringArray([
		"¿Vas a Madrid andando? ¿Sin chófer? Qué valiente.",
		"Por la Casa de Campo se llega a Moncloa. Ve por el camino, que el monte está lleno de Pokémon sin vacunar."]))
	return p

## Puerta de `id` (colocado en `anchor`) enlazada con su interior, y la aparición de vuelta debajo.
func _door(p: RefCounted, id: StringName, anchor: Vector2i, interior: StringName, warp_name: String, spawn: String) -> void:
	var door: Vector2i = anchor + Vector2i(ExteriorTiles.objects()[id]["door"])
	p.warp(warp_name, door, interior, &"default")
	p.root.get_node("Warps/" + warp_name).arrival_facing = Warp.Facing.UP
	p.spawn(spawn, door + Vector2i.DOWN)
