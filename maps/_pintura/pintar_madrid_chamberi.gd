extends SceneTree
## Pinta Madrid · Chamberí (maps/madrid/chamberi.tscn), el barrio de fincas señoriales al este de
## Argüelles (docs/mundo/ciudades/madrid.md): la calle de Carranza y Alberto Aguilera, la Glorieta de
## Bilbao con su café, la calle de Fuencarral, la Plaza de Olavide con su quiosco y sus terrazas, la
## Plaza de Chamberí con la boca de metro de Andén 0 (la estación fantasma) y la finca con el ÁTICO DE
## AYUSO, donde se juega el combate final del gimnasio 1 (decisión de Javier). Se une sin fundido con
## Moncloa por el oeste.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_chamberi.gd -- --force

const OUT := "res://maps/madrid/chamberi.tscn"
const SIZE := Vector2i(48, 44)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_chamberi: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"madrid/chamberi"
	data.display_name = "Madrid · Chamberí"
	data.zone_id = &"madrid"
	data.encounter_table = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridChamberi", SIZE, data, 1857)
	p.fill_grass(0.1)
	p.connect_edge("west", &"madrid/moncloa", 10, Vector2i(4, 30))
	p.paving(Rect2i(0, 0, SIZE.x, SIZE.y))
	p.build_paving()

	for b: Array in [
		[&"bloque_pisos", Vector2i(1, 7)],
		[&"oficinas_azules", Vector2i(8, 7)],
		[&"bloque_verde_2", Vector2i(15, 6)],
		[&"bloque_pisos", Vector2i(37, 7)],
		[&"edificio_cupula", Vector2i(28, 7)],      # el café de la Glorieta de Bilbao
		[&"bloque_pisos", Vector2i(1, 18)],
		[&"tienda_verde", Vector2i(8, 17)],         # Mercadona de Chamberí
		[&"oficinas_azules", Vector2i(37, 20)],
		[&"tienda_morada", Vector2i(1, 28)],        # estanco de Olavide
		[&"puesto_mercado", Vector2i(14, 29)],      # quiosco de la Plaza de Olavide
		[&"atico_jardin", Vector2i(28, 32)],        # la finca con el ÁTICO DE AYUSO
		[&"bloque_pisos", Vector2i(37, 33)],
		[&"tienda_azul", Vector2i(43, 33)],
		[&"bloque_verde_2", Vector2i(1, 41)],
		[&"bloque_pisos", Vector2i(36, 42)],
		[&"boca_metro", Vector2i(23, 40)],          # Andén 0
		[&"bloque_verde_2", Vector2i(14, 19)],
		[&"bloque_pisos", Vector2i(27, 22)],
		[&"oficinas_azules", Vector2i(1, 35)],
		[&"oficinas_azules", Vector2i(42, 12)],
	]:
		p.object(b[0], b[1])

	# Plaza de Olavide: árboles alrededor y terrazas; arbolado de Chamberí.
	for cell: Vector2i in [Vector2i(10, 23), Vector2i(20, 23), Vector2i(10, 33), Vector2i(20, 33),
			Vector2i(44, 25), Vector2i(30, 43), Vector2i(10, 43)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"sombrilla", Vector2i(12, 34))
	p.object(&"sombrilla", Vector2i(15, 23))
	for cell: Vector2i in [Vector2i(25, 12), Vector2i(34, 12), Vector2i(26, 36)]:
		p.object(&"farola_verde", cell)

	# --- Carteles ---
	p.deco(Vector2i(27, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelFinca", Vector2i(27, 33), PackedStringArray(["FINCA SEÑORIAL. Ático con terraza.",
		"Portero: «La señora presidenta no recibe visitas... salvo a quien le gane en Sol»."]))
	p.deco(Vector2i(22, 39), ExteriorTiles.SIGN)
	p.sign_text("CartelAnden0", Vector2i(22, 39), PackedStringArray(["ANDÉN 0 · Estación de Chamberí.",
		"Cerrada al tráfico desde 1966. Dicen que de noche todavía pasan trenes... sin nadie dentro."]))
	p.deco(Vector2i(22, 22), ExteriorTiles.SIGN)
	p.sign_text("CartelOlavide", Vector2i(22, 22), PackedStringArray(["PLAZA DE OLAVIDE.",
		"Terrazas, cañas y aceitunas. Aquí la libertad se mide en cervezas."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 9))
	p.spawn("from_moncloa", Vector2i(0, 9))
	p.trainer("Camarero", &"madrid_camarero", Vector2i(13, 33), UP, 3)
	p.npc("Portero", "npc_old_man", Vector2i(32, 33), DOWN, PackedStringArray([
		"Arriba está el ático. La señora sube cuando gana alguien en la Real Casa de Correos.",
		"Si le ganas también aquí, te llevas la medalla. Y una caña."]))
	p.npc("Vecina", "npc_old_woman", Vector2i(24, 42), UP, PackedStringArray([
		"Yo bajo a Andén 0 a coger el metro de 1919. Llega igual de puntual que el de ahora."]))
	return p
