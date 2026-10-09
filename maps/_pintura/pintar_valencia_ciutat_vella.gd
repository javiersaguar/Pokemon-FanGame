extends SceneTree
## Pinta Valencia · Ciutat Vella (maps/valencia/ciutat_vella.tscn) con el plano real
## docs/mundo/planos/valencia.svg (norte arriba; docs/mundo/ciudades/valencia.md): arriba, las Torres de
## Serranos, la puerta que da al Turia; en medio, la Plaza de la Reina con el Micalet y la Puerta de los
## Hierros de la catedral; al oeste, la Lonja de la Seda frente al Mercado Central; al sur, la Plaza del
## Ayuntamiento con sus fuentes. Por el norte se sale al Jardín del Turia.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_valencia_ciutat_vella.gd -- --force

const OUT := "res://maps/valencia/ciutat_vella.tscn"
const SIZE := Vector2i(64, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_valencia_ciutat_vella: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"valencia/ciutat_vella"
	data.display_name = "Valencia · Ciutat Vella"
	data.zone_id = &"valencia"
	data.encounter_table = &"valencia"
	data.region_map_position = Vector2i(22, 14)
	var p: RefCounted = painter.new("ValenciaCiutatVella", SIZE, data, 1238)
	p.fill_grass(0.1)
	p.connect_edge("north", &"valencia/turia", -8, Vector2i(28, 38))
	p.paving(Rect2i(0, 0, SIZE.x, SIZE.y))
	p.build_paving()

	# Monumentos.
	p.object(&"torres_serranos", Vector2i(28, 10))
	p.object(&"micalet_catedral", Vector2i(26, 27))
	p.object(&"lonja_seda", Vector2i(5, 24))
	p.object(&"mercado_central", Vector2i(4, 38))
	# Resto del casco antiguo y la Plaza del Ayuntamiento.
	for b: Array in [
		[&"bloque_pisos", Vector2i(2, 10)], [&"casa_dos_aguas", Vector2i(9, 10)], [&"casa_madera", Vector2i(14, 10)],
		[&"soportales", Vector2i(20, 10)], [&"soportales", Vector2i(40, 10)], [&"bloque_verde_2", Vector2i(46, 8)],
		[&"bloque_pisos", Vector2i(56, 10)],
		[&"centro_pokemon", Vector2i(48, 24)], [&"tienda_morada", Vector2i(56, 24)],
		[&"puesto_mercado", Vector2i(20, 38)],      # horchatería
		[&"tienda_verde", Vector2i(48, 38)], [&"bloque_pisos", Vector2i(56, 38)],
		[&"oficinas_verdes", Vector2i(24, 53)],     # el Ayuntamiento
		[&"bloque_pisos", Vector2i(2, 53)], [&"oficinas_azules", Vector2i(10, 53)], [&"bloque_verde_2", Vector2i(44, 51)],
		[&"bloque_pisos", Vector2i(55, 53)],
	]:
		p.object(b[0], b[1])
	p.object(&"fuente_plaza", Vector2i(33, 51))
	for cell: Vector2i in [Vector2i(21, 31), Vector2i(40, 34), Vector2i(36, 47), Vector2i(40, 47)]:
		p.object(&"palmera", cell)
	for cell: Vector2i in [Vector2i(24, 26), Vector2i(44, 26)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(25, 28), ExteriorTiles.SIGN)
	p.sign_text("CartelMicalet", Vector2i(25, 28), PackedStringArray(["EL MICALET Y LA CATEDRAL.",
		"207 escalones hasta la campana. Dentro dicen que está el Santo Grial. El de verdad, insisten."]))
	p.deco(Vector2i(16, 25), ExteriorTiles.SIGN)
	p.sign_text("CartelLonja", Vector2i(16, 25), PackedStringArray(["LLOTJA DE LA SEDA (1498).",
		"Aquí se cerraban los tratos de la seda. Ahora, los de los Pokémon intercambiados."]))
	p.deco(Vector2i(26, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelHorchata", Vector2i(26, 39), PackedStringArray(["HORCHATERÍA.",
		"Horchata y fartons. La horchata cura todo menos la sed de horchata."]))
	p.deco(Vector2i(37, 11), ExteriorTiles.SIGN)
	p.sign_text("CartelSerranos", Vector2i(37, 11), PackedStringArray(["TORRES DE SERRANOS (1398).",
		"↑ Jardín del Turia y Ciudad de las Artes y las Ciencias."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(32, 12))
	p.spawn("from_turia", Vector2i(32, 0))
	p.npc("Fallero", "npc_man", Vector2i(34, 44), DOWN, PackedStringArray([
		"En marzo esta plaza se llena de ninots gigantes. Y luego los quemamos. Un año de trabajo en una noche.",
		"La mascletà no se oye: se siente en el estómago."]))
	p.npc("Vendedora", "npc_old_woman", Vector2i(10, 40), DOWN, PackedStringArray([
		"¡Naranjas de Valencia! Las de verdad, no las de los supermercados de fuera."]))
	return p
