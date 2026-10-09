extends SceneTree
## Pinta Ibiza (maps/ibiza/exterior.tscn) con el plano real docs/mundo/planos/ibiza.svg (norte arriba;
## docs/mundo/ciudades/ibiza.md): se llega por mar haciendo Surf desde Mallorca (decisión de Javier),
## por el norte, al puerto con el ferry a Valencia y La Marina de casas encaladas; al sur, la muralla
## renacentista de Dalt Vila con el Portal de ses Taules y, dentro, las callejuelas que suben a la
## catedral; al este, el club y la playa d'en Bossa.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ibiza.gd -- --force

const OUT := "res://maps/ibiza/exterior.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ibiza: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"ibiza/exterior"
	data.display_name = "Ibiza"
	data.zone_id = &"ibiza"
	data.encounter_table = &"ibiza"
	data.region_map_position = Vector2i(26, 15)
	var p: RefCounted = painter.new("Ibiza", SIZE, data, 1235)
	p.fill_grass(0.2)
	p.connect_edge("north", &"maritima_1/exterior", -8, Vector2i(8, 56))

	# El puerto y la bahía al norte; el mar al sur de Dalt Vila y la playa d'en Bossa.
	p.paving(Rect2i(0, 10, 44, 20))
	p.paving(Rect2i(4, 31, 30, 18))
	p.build_paving()
	p.soil(Rect2i(42, 36, 22, 13))
	p.water(Rect2i(0, 0, 64, 10))
	p.water(Rect2i(0, 49, 64, 7))
	p.build_water(0.08)
	p.terrain(rects([Rect2i(46, 10, 16, 6), Rect2i(54, 18, 8, 10)]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# La Marina: casas encaladas, Centro Pokémon y estanco.
	for b: Array in [
		[&"casa_ibicenca", Vector2i(2, 15)], [&"casa_ibicenca", Vector2i(7, 15)], [&"centro_pokemon", Vector2i(12, 16)],
		[&"casa_ibicenca", Vector2i(20, 15)], [&"tienda_morada", Vector2i(25, 16)], [&"casa_ibicenca", Vector2i(31, 15)],
		[&"casa_ibicenca", Vector2i(36, 15)], [&"casa_ibicenca", Vector2i(2, 25)], [&"casa_ibicenca", Vector2i(7, 25)],
		[&"tienda_verde", Vector2i(12, 25)], [&"casa_ibicenca", Vector2i(18, 25)], [&"casa_ibicenca", Vector2i(36, 25)],
	]:
		p.object(b[0], b[1])
	p.object(&"ferry", Vector2i(24, 8))
	# La muralla de Dalt Vila: cuatro lienzos y el portal en medio.
	for x: int in [2, 10, 26]:
		p.object(&"muralla_dalt_vila", Vector2i(x, 31))
	p.object(&"muralla_dalt_vila", Vector2i(18, 31))
	# Dalt Vila por dentro: callejuelas, casas blancas y la catedral arriba.
	for b: Array in [
		[&"casa_ibicenca", Vector2i(5, 38)], [&"casa_ibicenca", Vector2i(10, 38)], [&"casa_ibicenca", Vector2i(26, 38)],
		[&"casa_ibicenca", Vector2i(5, 46)], [&"catedral_ibiza", Vector2i(16, 47)], [&"casa_ibicenca", Vector2i(26, 46)],
	]:
		p.object(b[0], b[1])
	# El club y la playa.
	p.object(&"club_ibiza", Vector2i(44, 33))
	for cell: Vector2i in [Vector2i(46, 44), Vector2i(53, 40), Vector2i(58, 46)]:
		p.object(&"sombrilla", cell)
	p.object(&"torre_socorrista", Vector2i(60, 40))
	p.object(&"arbol_redondo", Vector2i(40, 20))
	p.object(&"arbol_redondo", Vector2i(42, 27))

	# --- Carteles ---
	p.deco(Vector2i(16, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelDaltVila", Vector2i(16, 32), PackedStringArray(["DALT VILA. Patrimonio de la Humanidad.",
		"Murallas del siglo XVI contra los piratas. Hoy no paran ni a los turistas."]))
	p.deco(Vector2i(43, 34), ExteriorTiles.SIGN)
	p.sign_text("CartelClub", Vector2i(43, 34), PackedStringArray(["CLUB IBIZA. Abierto de 00:00 a «ya veremos».",
		"Entrada: 80 euros. Agua: 15 euros. Dignidad: no incluida."]))
	p.deco(Vector2i(22, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(22, 11), PackedStringArray(["FERRY · Ibiza → Valencia.",
		"La pasarela está un poco más allá. Cinco horas de travesía y el bar cerrado."]))
	p.warp("FerryValencia", Vector2i(26, 10), &"valencia/malvarrosa", &"from_ferry", &"")
	p.spawn("from_ferry", Vector2i(26, 11))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(30, 11))
	p.spawn("from_mar", Vector2i(30, 10))
	p.trainer("Luna", &"ibiza_hippie", Vector2i(30, 21), LEFT, 3)
	p.trainer("Tito", &"ibiza_relaciones", Vector2i(51, 34), LEFT, 3)
	p.npc("Payesa", "npc_old_woman", Vector2i(13, 41), DOWN, PackedStringArray([
		"Yo nací aquí cuando Ibiza era de pescadores y payeses. Ahora mi casa vale como un yate.",
		"Y la vendería, pero entonces, ¿dónde vivo? ¿En el yate?"]))
	return p
