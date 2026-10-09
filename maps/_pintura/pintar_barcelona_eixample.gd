extends SceneTree
## Pinta Barcelona · Eixample (maps/barcelona/eixample.tscn) con el plano real
## docs/mundo/planos/barcelona_centro.svg (norte arriba; en el juego la cuadrícula de Cerdà va recta):
## la Diagonal llega de Les Corts por el oeste; el Passeig de Gràcia baja con sus árboles de norte a sur,
## con La Pedrera y la Casa Batlló; al este, la manzana de la SAGRADA FAMÍLIA, con su grúa; abajo, la
## Plaça de Catalunya con sus fuentes, El Corte Inglés y el Centro Pokémon, de donde sale La Rambla hacia
## Ciutat Vella. Todo es de baldosas; las calles son los pasillos entre manzanas.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_barcelona_eixample.gd -- --force

const OUT := "res://maps/barcelona/eixample.tscn"
const SIZE := Vector2i(72, 60)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_barcelona_eixample: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"barcelona/eixample"
	data.display_name = "Barcelona · Eixample"
	data.zone_id = &"barcelona"
	data.encounter_table = &"barcelona"
	data.region_map_position = Vector2i(28, 8)
	var p: RefCounted = painter.new("BarcelonaEixample", SIZE, data, 1859)
	p.fill_grass(0.1)
	p.connect_edge("west", &"barcelona/les_corts", 8, Vector2i(6, 10))
	p.paving(Rect2i(0, 0, SIZE.x, SIZE.y))
	p.build_paving()

	for b: Array in [
		# Manzanas de la primera fila (dan a la calle de la fila 20).
		[&"bloque_pisos", Vector2i(3, 19)], [&"oficinas_azules", Vector2i(15, 19)], [&"tienda_morada", Vector2i(22, 19)],
		[&"la_pedrera", Vector2i(34, 19)], [&"bloque_verde", Vector2i(49, 19)], [&"bloque_pisos", Vector2i(57, 19)],
		[&"oficinas_azules", Vector2i(66, 19)],
		# Segunda fila (dan a la calle de la fila 32).
		[&"tienda_verde", Vector2i(3, 31)], [&"bloque_pisos", Vector2i(15, 31)], [&"casa_batllo", Vector2i(23, 31)],
		[&"bloque_verde_2", Vector2i(34, 31)],
		# Tercera fila (dan a la Gran Via, fila 42).
		[&"bloque_pisos", Vector2i(3, 41)], [&"oficinas_azules", Vector2i(15, 41)], [&"tienda_flores", Vector2i(22, 41)],
		[&"bloque_pisos", Vector2i(35, 41)],
		# La Sagrada Família ocupa su manzana, con su grúa al lado.
		[&"sagrada_familia", Vector2i(50, 41)],
		# Plaça de Catalunya.
		[&"centro_pokemon", Vector2i(6, 51)], [&"grandes_almacenes", Vector2i(58, 51)],
		# Relleno de las manzanas de Cerdà.
		[&"tienda_azul", Vector2i(9, 19)], [&"tienda_verde_2", Vector2i(43, 19)], [&"bloque_pisos", Vector2i(8, 31)],
		[&"oficinas_azules", Vector2i(42, 31)], [&"tienda_morada", Vector2i(9, 41)], [&"bloque_verde_2", Vector2i(41, 41)],
		[&"bloque_verde_2", Vector2i(2, 5)], [&"bloque_verde_2", Vector2i(14, 5)], [&"bloque_verde_2", Vector2i(36, 5)],
		[&"bloque_verde_2", Vector2i(48, 5)], [&"bloque_verde_2", Vector2i(60, 5)],
	]:
		p.object(b[0], b[1])
	p.object(&"grua", Vector2i(65, 41))

	# Passeig de Gràcia con sus árboles; fuentes y árboles de la Plaça de Catalunya.
	for y: int in [14, 26, 38]:
		p.object(&"arbol_redondo", Vector2i(28, y))
		p.object(&"arbol_redondo", Vector2i(32, y))
	p.object(&"fuente_plaza", Vector2i(22, 50))
	p.object(&"fuente_plaza", Vector2i(42, 50))
	for cell: Vector2i in [Vector2i(16, 57), Vector2i(48, 57), Vector2i(20, 46), Vector2i(44, 46)]:
		p.object(&"arbol_redondo", cell)
	for cell: Vector2i in [Vector2i(30, 47), Vector2i(36, 47), Vector2i(46, 43), Vector2i(12, 8)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(49, 42), ExteriorTiles.SIGN)
	p.sign_text("CartelSagrada", Vector2i(49, 42), PackedStringArray(["TEMPLE EXPIATORI DE LA SAGRADA FAMÍLIA.",
		"En obras desde 1882. La torre de Jesús se acabó en 2026. El resto, cuando Dios quiera.",
		"Dicen que la acaban antes que el Camp Nou."]))
	p.deco(Vector2i(33, 20), ExteriorTiles.SIGN)
	p.sign_text("CartelPedrera", Vector2i(33, 20), PackedStringArray(["LA PEDRERA · Casa Milà (Gaudí, 1912).",
		"En la azotea, chimeneas que parecen guerreros. Abajo, colas que parecen ejércitos."]))
	p.deco(Vector2i(22, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelBatllo", Vector2i(22, 32), PackedStringArray(["CASA BATLLÓ (Gaudí, 1906).",
		"El tejado es el lomo del dragón que mató Sant Jordi. Los balcones, sus víctimas."]))
	p.deco(Vector2i(29, 58), ExteriorTiles.SIGN)
	p.sign_text("CartelRambla", Vector2i(29, 58), PackedStringArray(["PLAÇA DE CATALUNYA.",
		"↓ La Rambla, el Barri Gòtic y el puerto. Cuidado con la cartera."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 7))
	p.spawn("from_les_corts", Vector2i(0, 7))
	p.trainer("Mireia", &"bcn_startup", Vector2i(30, 24), DOWN, 3)
	p.trainer("Kevin", &"bcn_guiri", Vector2i(56, 43), LEFT, 3)
	p.npc("Guia", "npc_man", Vector2i(54, 43), DOWN, PackedStringArray([
		"Gaudí murió en 1926 y dejó la Sagrada Família a medias. Desde entonces, cada generación pone su grúa.",
		"Dentro, la luz de las vidrieras parece un bosque. Fuera, la cola parece la de Doña Manolita."]))
	p.npc("Senyora", "npc_old_woman", Vector2i(26, 52), UP, PackedStringArray([
		"Bon dia! Aquí las palomas comen mejor que los turistas: ellas no pagan 7 euros por un café."]))
	return p
