extends SceneTree
## Pinta los interiores del inicio nuevo (docs/DECISIONES_JAVIER_2026-10-13.md §7): la casa del jugador y
## la del rival en Pozuelo y en Orcasitas, y el laboratorio del profesor Unicoos en Madrid · Moncloa.
## El laboratorio es el edificio de oficinas de la Ciudad Universitaria de Moncloa (puerta en (40, 16)).
## Con el tileset de interiores y las piezas de la casa de Getafe. La intro (quién te despierta, qué dice
## el profesor y cuándo te da el inicial) es del Agente A: aquí solo van las salas, las salidas, la
## aparición "default" y la marca "profesor" del laboratorio.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_casas_iniciales.gd

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"


func _initialize() -> void:
	await process_frame
	_house(&"pozuelo/casa_jugador", "Tu casa · Pozuelo", &"pozuelo/exterior", &"from_casa_jugador", "TU CASA · POZUELO",
		"npc_woman", "Mamá", ["¡Por fin te levantas! El profesor Unicoos te espera en su laboratorio de Moncloa.",
		"Coge el camino de la Casa de Campo. Y no hables con desconocidos, que aquí todos son de otra urbanización."])
	_house(&"pozuelo/casa_rival", "Casa del rival · Pozuelo", &"pozuelo/exterior", &"from_casa_rival", "CASA DEL RIVAL · POZUELO",
		"npc_old_man", "Abuelo del rival", ["Mi nieto ya se ha ido a Moncloa. Le ha llevado el chófer, claro.",
		"Dice que va a ser Campeón. Yo a su edad quería ser notario, y aquí me ves: notario."])
	_house(&"orcasitas/casa_jugador", "Tu casa · Orcasitas", &"orcasitas/exterior", &"from_casa_jugador", "TU CASA · ORCASITAS",
		"npc_woman", "Mamá", ["¡Despierta, que el profesor Unicoos te espera en Moncloa! Ve por Madrid Río hasta Atocha.",
		"Llévate el táper. Y si te encuentras a El Jincho, pídele una foto para tu prima."])
	_house(&"orcasitas/casa_rival", "Casa del rival · Orcasitas", &"orcasitas/exterior", &"from_casa_rival", "CASA DEL RIVAL · ORCASITAS",
		"npc_old_woman", "Abuela del rival", ["Mi nieto ha salido corriendo con la moto. Sin casco, como su padre.",
		"Dice que en Moncloa regalan Pokémon. Si es gratis, allí estará el primero."])
	_lab()
	quit()


func _room(map_id: StringName, title: String, size: Vector2i) -> Pintor:
	var d := MapData.new()
	d.id = map_id
	d.display_name = title
	d.zone_id = StringName(String(map_id).get_slice("/", 0))
	d.outdoor = false
	d.fixed_camera = true
	d.can_run = false
	d.can_bike = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new(String(map_id).replace("/", "_"), size, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, size)):
		p.ground.set_cell(at, 0, Vector2i(1, 25))
	var door_x := size.x / 2
	for x: int in size.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, 23))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, 24))
		if x != door_x:
			p.decor.set_cell(Vector2i(x, size.y - 1), 1, Vector2i(1, 24))
	for y: int in range(2, size.y - 1):
		for x: int in [0, size.x - 1]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, 24), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	return p


func _exit(p: Pintor, size: Vector2i, exterior: StringName, spawn: StringName) -> void:
	var door := Vector2i(size.x / 2, size.y - 1)
	p.spawn("default", door + Vector2i.UP)
	p.warp("Salida", door, exterior, spawn)
	p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN


func _label(p: Pintor, text: String, width: int) -> void:
	var title := Label.new()
	title.name = "Rotulo"
	title.position = Vector2(40, 18)
	title.size = Vector2(width * 32 - 80, 24)
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", load(FONT))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("303048"))
	p.root.add_child(title)


func _house(map_id: StringName, title: String, exterior: StringName, spawn: StringName, label: String,
		sheet: String, npc_name: String, lines: Array) -> void:
	var size := Vector2i(16, 12)
	var p := _room(map_id, title, size)
	_piece(p, Vector2i(1, 2), 2, Rect2i(0, 33, 6, 3))
	_piece(p, Vector2i(11, 2), 2, Rect2i(1, 0, 2, 3))
	_piece(p, Vector2i(2, 7), 2, Rect2i(0, 40, 2, 2))
	_piece(p, Vector2i(11, 8), 2, Rect2i(3, 59, 3, 2))
	_piece(p, Vector2i(8, 2), 3, Rect2i(0, 31, 2, 3))
	_exit(p, size, exterior, spawn)
	p.npc(npc_name.replace(" ", ""), sheet, Vector2i(6, 6), 0, PackedStringArray(lines))
	p.sign_text("Tele", Vector2i(13, 4), PackedStringArray(["En la tele: «Última hora: el profesor Unicoos regala Pokémon en Moncloa. Solo hay que saber derivar»."]))
	_label(p, label, size.x)
	print("%s: %s" % [map_id, error_string(p.save("res://maps/%s.tscn" % map_id))])


func _lab() -> void:
	var size := Vector2i(20, 14)
	var p := _room(&"madrid/laboratorio", "Laboratorio del profesor Unicoos", size)
	for x: int in [1, 7, 13]:
		_piece(p, Vector2i(x, 2), 2, Rect2i(0, 33, 6, 3))
	for x: int in [1, 13]:
		_piece(p, Vector2i(x, 10), 2, Rect2i(0, 33, 6, 3))
	_piece(p, Vector2i(8, 6), 3, Rect2i(0, 31, 2, 3))
	_piece(p, Vector2i(11, 6), 3, Rect2i(0, 31, 2, 3))
	_exit(p, size, &"madrid/moncloa", &"from_sala_40_16")
	p.spawn("profesor", Vector2i(10, 6))
	p.npc("Ayudante", "npc_lass", Vector2i(5, 8), 2, PackedStringArray([
		"Bienvenido al laboratorio del profesor Unicoos. Aquí se estudian los Pokémon con matemáticas.",
		"El profesor dice que un Pokémon es como una ecuación: si no la resuelves, te muerde."]))
	p.sign_text("Pizarra", Vector2i(14, 5), PackedStringArray(["En la pizarra: «Probabilidad de que tu inicial sea de tipo Planta: 1/3. Probabilidad de que te guste: depende»."]))
	_label(p, "LABORATORIO DEL PROFESOR UNICOOS", size.x)
	print("madrid/laboratorio: %s" % error_string(p.save("res://maps/madrid/laboratorio.tscn")))


func _piece(p: Pintor, at: Vector2i, source: int, rect: Rect2i) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), source, rect.position + Vector2i(x, y))
