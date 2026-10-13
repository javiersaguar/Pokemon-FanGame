extends SceneTree
## Pinta el hospital Quirón de Madrid (maps/madrid/quiron.tscn) y la terraza del ático de Ayuso en
## Chamberí (maps/madrid/atico_ayuso.tscn) (docs/DECISIONES_JAVIER_2026-10-13.md §3): un pasillo de
## hospital con tres enfermeros que combaten y Ayuso al fondo, que te lleva a su terraza para el combate
## del gimnasio 1 (src/events/quiron_ayuso_event.gd). El Quirón es el edificio de la Fundación Jiménez
## Díaz de Moncloa (puerta en (58, 29)); de la terraza se baja a Chamberí.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_quiron.gd

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"


func _initialize() -> void:
	await process_frame
	_quiron()
	_terrace()
	quit()


func _quiron() -> void:
	var size := Vector2i(14, 20)
	var d := MapData.new()
	d.id = &"madrid/quiron"
	d.display_name = "Hospital Quirón · Madrid"
	d.zone_id = &"madrid"
	d.outdoor = false
	d.can_run = false
	d.can_bike = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Quiron", size, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, size)):
		p.ground.set_cell(at, 0, Vector2i(1, 25))
	for x: int in size.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, 23))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, 24))
		if x != size.x / 2:
			p.decor.set_cell(Vector2i(x, size.y - 1), 1, Vector2i(1, 24))
	for y: int in range(2, size.y - 1):
		for x: int in [0, size.x - 1]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, 24), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	# Camas a los lados del pasillo, el mostrador de la entrada y el despacho del fondo.
	for y: int in [4, 8, 12]:
		_piece(p, Vector2i(1, y), 2, Rect2i(0, 40, 2, 2))
		_piece(p, Vector2i(11, y), 2, Rect2i(0, 40, 2, 2))
	_piece(p, Vector2i(1, 15), 2, Rect2i(0, 33, 6, 3))
	_piece(p, Vector2i(4, 2), 3, Rect2i(0, 31, 2, 3))
	_piece(p, Vector2i(8, 2), 3, Rect2i(0, 31, 2, 3))
	var door := Vector2i(size.x / 2, size.y - 1)
	p.spawn("default", door + Vector2i.UP)
	p.warp("Salida", door, &"madrid/moncloa", &"from_sala_58_29")
	p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
	p.trainer("Enfermero1", &"quiron_enfermera_1", Vector2i(5, 15), 2, 3)
	p.trainer("Enfermero2", &"quiron_enfermero_2", Vector2i(9, 10), 1, 3)
	p.trainer("Enfermero3", &"quiron_enfermera_3", Vector2i(5, 6), 2, 3)
	p.npc("Ayuso", "ayuso", Vector2i(7, 3), 0, PackedStringArray(),
		{"event": load("res://src/events/quiron_ayuso_event.gd"), "display_name": "Ayuso"})
	p.npc("Recepcionista", "npc_woman", Vector2i(10, 16), 1, PackedStringArray([
		"Bienvenido al hospital Quirón. ¿Tiene seguro privado? ¿No? Pues pase igual, que hoy la presidenta está de visita.",
		"Los enfermeros no le dejarán pasar al fondo sin combatir. Aquí todo se gana con esfuerzo. Y con tarjeta."]))
	_label(p, "HOSPITAL QUIRÓN", size.x)
	print("madrid/quiron: %s" % error_string(p.save("res://maps/madrid/quiron.tscn")))


func _terrace() -> void:
	var d := MapData.new()
	d.id = &"madrid/atico_ayuso"
	d.display_name = "Ático de Ayuso · Chamberí"
	d.zone_id = &"madrid"
	d.can_fly_from = false
	var p := Pintor.new("AticoAyuso", Vector2i(18, 14), d, 2019)
	p.fill_grass(0.0)
	p.paving(Rect2i(0, 0, 18, 14))
	p.build_paving()
	for x: int in [1, 13]:
		p.object(&"jardinera", Vector2i(x, 2))
		p.object(&"jardinera", Vector2i(x, 12))
	p.object(&"sombrilla", Vector2i(2, 8))
	p.object(&"sombrilla", Vector2i(11, 8))
	for x: int in [1, 16]:
		p.object(&"farola_roja", Vector2i(x, 6))
	p.deco(Vector2i(8, 1), ExteriorTiles.SIGN)
	p.sign_text("Vistas", Vector2i(8, 1), PackedStringArray(["Desde aquí se ve todo Madrid: el Palacio Real, las cuatro torres y una grúa en cada esquina.",
		"Y la Moncloa. Sobre todo la Moncloa."]))
	p.spawn("default", Vector2i(8, 12))
	p.warp("Bajar", Vector2i(8, 13), &"madrid/chamberi", &"default")
	print("madrid/atico_ayuso: %s" % error_string(p.save("res://maps/madrid/atico_ayuso.tscn")))


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


func _piece(p: Pintor, at: Vector2i, source: int, rect: Rect2i) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), source, rect.position + Vector2i(x, y))
