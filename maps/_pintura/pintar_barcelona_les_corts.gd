extends SceneTree
## Pinta Barcelona · Les Corts (maps/barcelona/les_corts.tscn), la entrada a Barcelona desde la Ruta 8
## por la Diagonal (docs/mundo/ciudades/barcelona.md; plano real docs/mundo/planos/barcelona_camp_nou.svg):
## al norte de la Diagonal, Pedralbes y Les Corts; al sur, la explanada del SPOTIFY CAMP NOU, GIMNASIO 2
## (Laporta), reabierto con aforo parcial y lleno de grúas, con La Masia, la tienda del Barça y el
## Basic-Fit. La Diagonal sigue hacia el este, al Eixample.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_barcelona_les_corts.gd -- --force

const OUT := "res://maps/barcelona/les_corts.tscn"
const SIZE := Vector2i(64, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_barcelona_les_corts: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"barcelona/les_corts"
	data.display_name = "Barcelona · Les Corts"
	data.zone_id = &"barcelona"
	data.encounter_table = &"barcelona"
	data.region_map_position = Vector2i(28, 8)
	var p: RefCounted = painter.new("BarcelonaLesCorts", SIZE, data, 1957)
	p.fill_grass(0.15)
	p.connect_edge("west", &"ruta_8/exterior", 0, Vector2i(14, 18))
	p.connect_edge("east", &"barcelona/eixample", -8, Vector2i(14, 18))  # la Diagonal sigue en el Eixample
	p.paving(Rect2i(0, 14, SIZE.x, 34))
	p.paving(Rect2i(0, 0, SIZE.x, 14))
	p.build_paving()

	for b: Array in [
		# Pedralbes y Les Corts, al norte de la Diagonal.
		[&"bloque_pisos", Vector2i(2, 13)], [&"oficinas_verdes", Vector2i(10, 13)], [&"oficinas_verdes", Vector2i(18, 13)],
		[&"bloque_verde", Vector2i(27, 13)], [&"oficinas_azules", Vector2i(36, 13)], [&"bloque_pisos", Vector2i(44, 13)],
		[&"tienda_verde", Vector2i(52, 13)], [&"bloque_pisos", Vector2i(58, 13)],
		# El Camp Nou y lo que tiene alrededor.
		[&"camp_nou", Vector2i(16, 40)],
		[&"casa_granero", Vector2i(46, 30)],          # La Masia
		[&"tienda_azul", Vector2i(52, 30)],           # Basic-Fit
		[&"tienda_morada", Vector2i(46, 41)],         # la Botiga del Barça
		[&"bloque_verde_2", Vector2i(54, 41)],
		[&"bloque_pisos", Vector2i(2, 46)],
	]:
		p.object(b[0], b[1])
	p.object(&"grua", Vector2i(8, 36))
	p.object(&"grua", Vector2i(38, 35))
	for cell: Vector2i in [Vector2i(2, 22), Vector2i(60, 22), Vector2i(41, 22), Vector2i(36, 46), Vector2i(60, 47)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(14, 20), Vector2i(34, 20), Vector2i(42, 44)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(25, 41), ExteriorTiles.SIGN)
	p.sign_text("CartelCampNou", Vector2i(25, 41), PackedStringArray(["SPOTIFY CAMP NOU · GIMNASIO POKÉMON DE BARCELONA.",
		"Líder: Joan Laporta. Tipo Acero. Aforo: el que haya.",
		"«Estará al cien por cien la temporada que viene»."]))
	p.deco(Vector2i(45, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelMasia", Vector2i(45, 30), PackedStringArray(["LA MASIA.",
		"Aquí se forman los cracks del Barça. Y luego se van vendiendo para pagar palancas."]))
	p.deco(Vector2i(1, 18), ExteriorTiles.SIGN)
	p.sign_text("CartelDiagonal", Vector2i(1, 18), PackedStringArray(["AVINGUDA DIAGONAL.",
		"→ Eixample, Sagrada Família y Plaça de Catalunya."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_ruta_8", Vector2i(0, 15))
	p.trainer("Jordi", &"bcn_soci", Vector2i(30, 44), LEFT, 3)
	p.trainer("Ramon", &"bcn_obrero", Vector2i(12, 42), RIGHT, 3)
	p.npc("Comercial", "influencerlinkedin", Vector2i(27, 42), DOWN, PackedStringArray([
		"¿Quieres entrar al gimnasio? Te vendo el pasillo. Es una palanca: pagas hoy y pasas dentro de veinte años.",
		"Laporta te espera en el césped. Dice que la grada que falta no hace falta para ganarte."]))
	p.npc("Guiri", "turistachanclas", Vector2i(45, 22), LEFT, PackedStringArray([
		"I came to see Messi! ...He is not here? Since when? Oh."]))
	return p
