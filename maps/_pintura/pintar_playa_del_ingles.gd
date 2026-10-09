extends SceneTree
## Pinta Playa del Inglés (maps/playa_del_ingles/exterior.tscn) con el plano real
## docs/mundo/planos/playa_del_ingles.svg (norte arriba; docs/mundo/ciudades/las_palmas.md): al noroeste, el
## Aeropuerto de Gran Canaria con el mostrador de los vuelos a Vigo; la zona de hoteles y apartamentos, el
## centro comercial Yumbo y los locales; al este, la playa con el escenario del concierto de Quevedo
## (GIMNASIO 5); al sur, las Dunas de Maspalomas con la Charca y el palmeral, y el Faro de Maspalomas. Se
## une sin fundido con la Ruta 15 (norte). El vuelo a Vigo lo une el Agente 5 (casilla libre junto al
## mostrador).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_playa_del_ingles.gd -- --force

const OUT := "res://maps/playa_del_ingles/exterior.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_playa_del_ingles: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"playa_del_ingles/exterior"
	data.display_name = "Playa del Inglés"
	data.zone_id = &"playa_del_ingles"
	data.encounter_table = &"playa_del_ingles"
	data.region_map_position = Vector2i(3, 24)
	var p: RefCounted = painter.new("PlayaDelIngles", SIZE, data, 1960)
	p.fill_grass(0.15)
	p.connect_edge("north", &"ruta_15/exterior", 0, Vector2i(8, 20))

	# El pueblo turístico, pavimentado; la playa y las dunas; el mar al este y al sur.
	p.paving(Rect2i(0, 0, 44, 24))
	p.build_paving()
	for r: Rect2i in [Rect2i(44, 0, 12, 52), Rect2i(2, 26, 42, 26), Rect2i(14, 52, 22, 4)]:
		p.soil(r)
	p.water(Rect2i(56, 0, 8, 56))
	p.water(Rect2i(36, 52, 20, 4))
	p.water(Rect2i(28, 38, 8, 5))                       # la Charca de Maspalomas
	p.build_water(0.25)
	p.terrain(rects([Rect2i(8, 30, 10, 6), Rect2i(20, 44, 6, 6), Rect2i(38, 28, 4, 8)]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# El aeropuerto: la terminal, el mostrador de facturación y su cartel.
	p.object(&"terminal_aeropuerto", Vector2i(1, 6))
	p.object(&"mostrador_vuelos", Vector2i(12, 6))
	# Hoteles, el Yumbo y los locales.
	for b: Array in [[&"centro_pokemon", Vector2i(20, 7)], [&"tienda_verde", Vector2i(27, 6)], [&"tienda_morada", Vector2i(33, 6)],
			[&"tienda_naranja", Vector2i(38, 7)], [&"grandes_almacenes", Vector2i(2, 20)], [&"edificio_cristal", Vector2i(12, 20)],
			[&"bloque_pisos", Vector2i(22, 21)], [&"bloque_verde", Vector2i(30, 21)], [&"oficinas_azules", Vector2i(37, 21)]]:
		p.object(b[0], b[1])
	# La playa: el escenario del concierto (gimnasio 5), sombrillas y la torre del socorrista.
	p.object(&"escenario_festival", Vector2i(45, 22))
	for cell: Vector2i in [Vector2i(45, 6), Vector2i(48, 32), Vector2i(45, 44)]:
		p.object(&"sombrilla", cell)
	p.object(&"torre_socorrista", Vector2i(52, 12))
	# Las dunas: el palmeral de la Charca y el Faro de Maspalomas.
	for cell: Vector2i in [Vector2i(25, 40), Vector2i(36, 37), Vector2i(26, 37), Vector2i(36, 46)]:
		p.object(&"palmera", cell)
	p.object(&"faro", Vector2i(4, 55))
	for cell: Vector2i in [Vector2i(6, 28), Vector2i(17, 40), Vector2i(30, 30), Vector2i(41, 47), Vector2i(14, 48)]:
		p.deco(cell, ExteriorTiles.TUFT_TALL)

	# --- Carteles ---
	p.deco(Vector2i(15, 6), ExteriorTiles.SIGN)
	p.sign_text("CartelVuelos", Vector2i(15, 6), PackedStringArray(["AEROPUERTO DE GRAN CANARIA · VUELOS A VIGO.",
		"Embarque por la pasarela. Prohibido llevar líquidos de más de 100 ml. Sí, también el mojo."]))
	p.deco(Vector2i(11, 1), ExteriorTiles.SIGN)
	p.sign_text("CartelFalcon", Vector2i(11, 1), PackedStringArray(["En la pista hay un avión oficial aparcado.",
		"Dicen que es de alguien muy importante que venía a una boda. O a un mitin. O a la playa."]))
	p.deco(Vector2i(44, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelQuevedo", Vector2i(44, 23), PackedStringArray(["CONCIERTO EN LA PLAYA · GIMNASIO POKÉMON DE LAS PALMAS.",
		"Líder: Quevedo. Tipo Agua. Quédate... que empieza el combate."]))
	p.deco(Vector2i(13, 47), ExteriorTiles.SIGN)
	p.sign_text("CartelFaro", Vector2i(13, 47), PackedStringArray(["FARO DE MASPALOMAS (1890).",
		"Sesenta metros de faro para que los barcos no choquen con la playa. Los turistas chocan igual."]))
	p.deco(Vector2i(27, 36), ExteriorTiles.SIGN)
	p.sign_text("CartelDunas", Vector2i(27, 36), PackedStringArray(["RESERVA NATURAL DE LAS DUNAS DE MASPALOMAS.",
		"La arena llegó del fondo del mar. Ahora se la lleva el turismo, metida en las chanclas."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(13, 1))
	p.spawn("from_ruta_15", Vector2i(13, 0))
	p.trainer("Laura", &"pi_fan", Vector2i(49, 24), LEFT, 3)
	p.trainer("Sven", &"pi_turista", Vector2i(47, 38), DOWN, 3)
	p.trainer("Acoidan", &"pi_surfista", Vector2i(53, 46), UP, 3)
	p.npc("Socorrista", "npc_man", Vector2i(51, 13), DOWN, PackedStringArray([
		"Bandera verde: báñate. Bandera amarilla: con cuidado. Bandera roja: hoy canta Quevedo, no hay sitio."]))
	p.npc("Azafata", "npc_woman", Vector2i(15, 8), UP, PackedStringArray([
		"Los vuelos a Vigo salen por aquí. El embarque aún no está abierto: la pasarela, de momento, no lleva a ningún sitio."]))
	return p
