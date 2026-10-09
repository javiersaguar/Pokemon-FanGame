extends SceneTree
## Pinta la Ruta marítima 1 · Canal de Ibiza (maps/maritima_1/exterior.tscn): el mar entre Mallorca e
## Ibiza, que se cruza haciendo Surf (decisión de Javier), con Sa Dragonera (el islote del dragón,
## frente a Mallorca), un islote en medio con un velero fondeado y, ya cerca de Ibiza, Es Vedrà. Se une
## sin fundido con Palma por el norte.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_maritima_1.gd -- --force

const OUT := "res://maps/maritima_1/exterior.tscn"
const SIZE := Vector2i(48, 64)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_maritima_1: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"maritima_1/exterior"
	data.display_name = "Ruta marítima 1 · Canal de Ibiza"
	data.zone_id = &"maritima_1"
	data.encounter_table = &"maritima_1"
	data.region_map_position = Vector2i(28, 14)
	data.can_bike = false
	var p: RefCounted = painter.new("Maritima1", SIZE, data, 1977)
	p.fill_grass(0.0)
	p.connect_edge("north", &"palma/exterior", 12)
	p.connect_edge("south", &"ibiza/exterior", 8)

	# Todo es mar menos los islotes (arena, rocas y matorral).
	var islets: Array[Rect2i] = [Rect2i(4, 8, 12, 6), Rect2i(26, 28, 10, 5), Rect2i(8, 44, 6, 4)]
	for x: int in SIZE.x:
		for y: int in SIZE.y:
			var land := false
			for r: Rect2i in islets:
				land = land or r.has_point(Vector2i(x, y))
			if not land:
				p.water(Rect2i(x, y, 1, 1))
	p.build_water(0.06)
	for r: Rect2i in islets:
		p.soil(r)
	for cell: Vector2i in [Vector2i(6, 9), Vector2i(13, 12), Vector2i(10, 9), Vector2i(34, 29), Vector2i(9, 46)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 else ExteriorTiles.ROCK_BROWN)

	p.object(&"velero", Vector2i(18, 32))
	p.object(&"es_vedra", Vector2i(30, 60))

	# --- Carteles (boyas) ---
	p.deco(Vector2i(14, 10), ExteriorTiles.SIGN)
	p.sign_text("CartelDragonera", Vector2i(14, 10), PackedStringArray(["SA DRAGONERA. Reserva natural.",
		"Tiene forma de dragón dormido. No lo despiertes, que aquí no llega la ambulancia."]))
	p.deco(Vector2i(10, 47), ExteriorTiles.SIGN)
	p.sign_text("CartelVedra", Vector2i(10, 47), PackedStringArray(["↓ ES VEDRÀ e Ibiza.",
		"Dicen que el islote es magnético. Las brújulas se vuelven locas. Los Pokémon, también."]))

	# --- Apariciones y entrenadores ---
	p.spawn("default", Vector2i(10, 11))
	p.spawn("from_palma", Vector2i(24, 0))
	p.trainer("Biel", &"maritima1_nadador", Vector2i(8, 11), RIGHT, 3)
	p.trainer("DjMarta", &"maritima1_dj", Vector2i(28, 30), LEFT, 3)
	return p
