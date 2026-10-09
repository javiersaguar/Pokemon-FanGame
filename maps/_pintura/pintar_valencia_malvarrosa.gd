extends SceneTree
## Pinta Valencia · Malvarrosa (maps/valencia/malvarrosa.tscn) con el plano real
## docs/mundo/planos/valencia.svg (norte arriba; docs/mundo/ciudades/valencia.md): el Mediterráneo al
## este, la playa de la Malvarrosa con sus palmeras y el paseo marítimo, la discoteca AKUARELA PLAYA
## (GIMNASIO 3, Labrador) entre el paseo y la arena, el Cabanyal con sus casas, el Centro Pokémon, el
## Mercadona, el estanco y el Basic-Fit; al sur, el puerto con el ferry de Ibiza.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_valencia_malvarrosa.gd -- --force

const OUT := "res://maps/valencia/malvarrosa.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_valencia_malvarrosa: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"valencia/malvarrosa"
	data.display_name = "Valencia · Malvarrosa"
	data.zone_id = &"valencia"
	data.encounter_table = &"valencia"
	data.region_map_position = Vector2i(22, 14)
	var p: RefCounted = painter.new("ValenciaMalvarrosa", SIZE, data, 1238)
	p.connect_edge("west", &"valencia/turia", 4, Vector2i(22, 30))
	p.fill_grass(0.1)

	p.paving(Rect2i(0, 0, 40, 48))
	p.build_paving()
	p.soil(Rect2i(40, 0, 12, 48))               # la playa
	p.water(Rect2i(52, 0, 12, 56))              # el Mediterráneo
	p.water(Rect2i(0, 48, 52, 8))               # el puerto
	p.build_water(0.1)

	# Akuarela, entre el paseo y la arena.
	p.object(&"akuarela", Vector2i(38, 20))
	# Palmeras del paseo marítimo.
	for y: int in [6, 12, 28, 34, 40]:
		p.object(&"palmera", Vector2i(36, y))
	# El Cabanyal y el resto del barrio.
	for b: Array in [
		[&"casa_dos_aguas", Vector2i(2, 9)], [&"casa_madera", Vector2i(7, 9)], [&"casa_roja_chimenea", Vector2i(12, 9)],
		[&"centro_pokemon", Vector2i(19, 10)], [&"tienda_verde", Vector2i(27, 9)],
		[&"casa_granero", Vector2i(2, 22)], [&"casa_dos_aguas", Vector2i(7, 22)], [&"tienda_morada", Vector2i(12, 22)],
		[&"tienda_azul", Vector2i(18, 22)], [&"bloque_pisos", Vector2i(25, 22)],
		[&"bloque_verde_2", Vector2i(2, 35)], [&"oficinas_azules", Vector2i(12, 35)], [&"bloque_pisos", Vector2i(20, 35)],
		[&"oficinas_azules", Vector2i(28, 35)],
	]:
		p.object(b[0], b[1])
	p.object(&"ferry", Vector2i(8, 55))
	for cell: Vector2i in [Vector2i(44, 6), Vector2i(46, 30), Vector2i(43, 40)]:
		p.object(&"sombrilla", cell)
	p.object(&"torre_socorrista", Vector2i(48, 12))

	# --- Pasarela del ferry a Ibiza ---
	p.warp("FerryIbiza", Vector2i(16, 47), &"ibiza/exterior", &"from_ferry", &"")

	# --- Carteles ---
	p.deco(Vector2i(37, 21), ExteriorTiles.SIGN)
	p.sign_text("CartelAkuarela", Vector2i(37, 21), PackedStringArray(["AKUARELA PLAYA · GIMNASIO POKÉMON DE VALENCIA.",
		"Líder: Labrador. Tipo Lucha. Código de vestimenta: bíceps."]))
	p.deco(Vector2i(14, 46), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(14, 46), PackedStringArray(["FERRY · Valencia → Ibiza.",
		"La pasarela está a tu derecha."]))
	p.deco(Vector2i(33, 3), ExteriorTiles.SIGN)
	p.sign_text("CartelMalvarrosa", Vector2i(33, 3), PackedStringArray(["PLATJA DE LA MALVA-ROSA.",
		"Aquí veraneaba Blasco Ibáñez. Ahora veranean los de Gandía Shore."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(16, 45))
	p.spawn("from_ferry", Vector2i(16, 46))
	p.trainer("Jonathan", &"vlc_tronista", Vector2i(44, 24), UP, 3)
	p.trainer("Ruben", &"vlc_despedida", Vector2i(32, 16), DOWN, 3)
	p.npc("Portero", "npc_man", Vector2i(42, 21), DOWN, PackedStringArray([
		"Hoy en Akuarela no entra cualquiera. Labrador quiere entrenadores con fuerza.",
		"Con zapatillas de deporte no se entra. Bueno, a este gimnasio sí."]))
	p.npc("Abuela", "npc_old_woman", Vector2i(10, 15), DOWN, PackedStringArray([
		"Esta casa del Cabanyal tiene la fachada de azulejos de mi abuelo. Los turistas le hacen fotos; yo, la colada."]))
	return p
