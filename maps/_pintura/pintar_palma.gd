extends SceneTree
## Pinta Palma de Mallorca (maps/palma/exterior.tscn) con el plano real docs/mundo/planos/palma.svg
## (norte arriba; docs/mundo/ciudades/palma.md): al oeste, el monte de Bellver con su castillo circular
## entre pinos; el puerto con el muelle del ferry de Barcelona; el Passeig des Born bajando hacia el
## mar; La Seu sobre el paseo marítimo con la torre de la Almudaina al lado; el casco antiguo con el
## Centro Pokémon, el Mercadona, el estanco y el Basic-Fit. Al sur, la bahía: por ahí se llega
## haciendo Surf a Ibiza (decisión de Javier).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_palma.gd -- --force

const OUT := "res://maps/palma/exterior.tscn"
const SIZE := Vector2i(72, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_palma: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"palma/exterior"
	data.display_name = "Palma de Mallorca"
	data.zone_id = &"palma"
	data.encounter_table = &"palma"
	data.region_map_position = Vector2i(29, 13)
	var p: RefCounted = painter.new("Palma", SIZE, data, 1229)
	p.fill_grass(0.2)

	# La ciudad y el puerto (baldosas) y la bahía.
	p.paving(Rect2i(18, 0, 54, 46))
	p.paving(Rect2i(0, 40, 18, 6))
	p.build_paving()
	p.water(Rect2i(0, 46, 72, 10))
	p.build_water(0.3)

	# El monte de Bellver: meseta con pinar, hierba alta y el castillo arriba.
	p.plateau(Rect2i(-2, -2, 18, 24), [8, 9])
	p.terrain(rects([Rect2i(1, 2, 5, 5), Rect2i(10, 16, 4, 3)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(rects([Rect2i(8, 15, 2, 5), Rect2i(8, 22, 2, 18)]), ExteriorTiles.TERRAIN_PATH)
	for r: Rect2i in [Rect2i(0, 8, 2, 12), Rect2i(12, 0, 2, 12)]:
		p.forest(r)
	p.build_forest()
	p.object(&"castillo_bellver", Vector2i(4, 14))
	p.terrain(rects([Rect2i(2, 24, 5, 6), Rect2i(11, 28, 5, 8)]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Monumentos y edificios.
	p.object(&"catedral_palma", Vector2i(36, 41))      # La Seu
	p.object(&"torre_octogonal", Vector2i(31, 41))     # la torre del Ángel de la Almudaina (provisional)
	p.object(&"ferry", Vector2i(2, 54))
	for b: Array in [
		[&"centro_pokemon", Vector2i(52, 13)], [&"tienda_verde", Vector2i(59, 13)], [&"bloque_pisos", Vector2i(65, 13)],
		[&"tienda_morada", Vector2i(20, 13)], [&"casa_roja_chimenea", Vector2i(32, 13)], [&"casa_dos_aguas", Vector2i(38, 13)],
		[&"casa_madera", Vector2i(43, 13)], [&"bloque_verde_2", Vector2i(18, 27)], [&"soportales", Vector2i(32, 27)],
		[&"soportales", Vector2i(36, 27)], [&"tienda_azul", Vector2i(42, 26)], [&"bloque_pisos", Vector2i(52, 30)],
		[&"oficinas_azules", Vector2i(59, 30)], [&"casa_granero", Vector2i(66, 30)], [&"bloque_pisos", Vector2i(57, 43)],
		[&"bloque_verde_2", Vector2i(63, 43)],
	]:
		p.object(b[0], b[1])
	# Passeig des Born: plátanos a los dos lados.
	for y: int in [4, 10, 16, 22, 28, 34]:
		p.object(&"arbol_redondo", Vector2i(26, y))
		p.object(&"arbol_redondo", Vector2i(30, y))
	for cell: Vector2i in [Vector2i(52, 39), Vector2i(20, 39), Vector2i(66, 38)]:
		p.object(&"farola_verde", cell)
	p.object(&"sombrilla", Vector2i(12, 44))
	p.sprinkle(Rect2i(0, 0, 18, 40), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])

	# --- Pasarela del ferry a Barcelona ---
	p.warp("FerryBarcelona", Vector2i(10, 45), &"barcelona/ciutat_vella", &"from_ferry", &"")

	# --- Carteles ---
	p.deco(Vector2i(35, 42), ExteriorTiles.SIGN)
	p.sign_text("CartelSeu", Vector2i(35, 42), PackedStringArray(["LA SEU · CATEDRAL DE MALLORCA.",
		"El rosetón tiene más de 1200 vidrios. Gaudí reformó el interior; menos mal que esta sí la acabaron."]))
	p.deco(Vector2i(10, 22), ExteriorTiles.SIGN)
	p.sign_text("CartelBellver", Vector2i(10, 22), PackedStringArray(["CASTELL DE BELLVER.",
		"El único castillo gótico redondo de España. Vistas de toda la bahía... y de todos los cruceros."]))
	p.deco(Vector2i(13, 45), ExteriorTiles.SIGN)
	p.sign_text("CartelFerry", Vector2i(13, 45), PackedStringArray(["FERRY · Palma → Barcelona.",
		"La pasarela está a tu izquierda."]))
	p.deco(Vector2i(50, 45), ExteriorTiles.SIGN)
	p.sign_text("CartelIbiza", Vector2i(50, 45), PackedStringArray(["↓ Ibiza, por mar.",
		"Con Surf se llega remando. Con sueldo de aquí, no se llega a fin de mes."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(10, 43))
	p.spawn("from_ferry", Vector2i(10, 44))
	p.trainer("Tolo", &"palma_regatista", Vector2i(17, 42), LEFT, 3)
	p.trainer("Klaus", &"palma_aleman", Vector2i(51, 33), LEFT, 3)
	p.npc("Vecina", "npc_old_woman", Vector2i(28, 19), RIGHT, PackedStringArray([
		"Aquí antes vivía gente. Ahora viven maletas con ruedas.",
		"La ensaimada, en Ca'n Joan de s'Aigo. Y no se lo digas a los alemanes, que la compran."]))
	return p
