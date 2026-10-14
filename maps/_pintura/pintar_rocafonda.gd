extends SceneTree
## Rocafonda · Mataró (docs/DECISIONES_JAVIER_2026-10-14.md §3): el barrio de Lamine Yamal, cerca de
## Barcelona. Se entra por el oeste desde el Eixample (filas 20–23). Pocas casas y algo derruidas,
## un campo de tierra con niños jugando al fútbol y, de repente, una mansión enorme con verja: allí
## está Lamine (el palacete del pack hace de mansión, con piscina). Su abuela vive en una de las casas del barrio. Al este, el mar de Mataró.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_rocafonda.gd -- --force

const OUT := "res://maps/rocafonda/exterior.tscn"
const SIZE := Vector2i(56, 40)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_rocafonda: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	print("%s: %s" % [OUT, error_string(_paint().save(OUT))])
	quit()


static func rects(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r: Rect2i in list:
		out.append_array(Pintor.cells(r))
	return out


func _paint() -> Pintor:
	var d := MapData.new()
	d.id = &"rocafonda/exterior"
	d.display_name = "Rocafonda · Mataró"
	d.zone_id = &"rocafonda"
	d.encounter_table = &"rocafonda"
	d.region_map_position = Vector2i(29, 7)
	var p := Pintor.new("Rocafonda", SIZE, d, 8304)
	p.fill_grass(0.3)
	p.connect_edge("west", &"barcelona/eixample", 34, Vector2i(20, 24))

	# El mar de Mataró al este.
	p.water(Rect2i(50, 0, 6, 40))
	p.build_water(0.3)
	p.soil(Rect2i(47, 0, 3, 40))

	p.terrain(rects([
		Rect2i(0, 20, 46, 4),    # la calle que cruza el barrio desde Barcelona
		Rect2i(12, 8, 4, 12),    # hacia las casas del norte
		Rect2i(30, 12, 4, 8),    # subida a la mansión
		Rect2i(20, 24, 4, 6),    # bajada al campo
	]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([
		Rect2i(2, 2, 8, 6),
		Rect2i(40, 26, 6, 12),
		Rect2i(2, 30, 10, 8),
	]), ExteriorTiles.TERRAIN_TALL_GRASS)

	# Las casas del barrio: pocas y algo derruidas (escombros, vallas rotas, tocones).
	p.object(&"casa_gris", Vector2i(4, 18))
	p.object(&"casa_roja_pequena", Vector2i(17, 18))
	p.object(&"casa_pequena", Vector2i(4, 29))
	p.object(&"casa_azul_pequena", Vector2i(24, 18))
	for at: Vector2i in [Vector2i(10, 17), Vector2i(11, 18), Vector2i(3, 24), Vector2i(16, 26), Vector2i(27, 25), Vector2i(10, 27)]:
		p.deco(at, ExteriorTiles.ROCK_BROWN)
	for at: Vector2i in [Vector2i(9, 25), Vector2i(17, 9), Vector2i(21, 6)]:
		p.deco(at, ExteriorTiles.STUMP_CUT)
	p.fence(1, 3, 12)
	p.fence(9, 10, 12)
	p.fence(17, 18, 26)

	# El campo de tierra, con los niños jugando.
	p.soil(Rect2i(16, 30, 18, 8))
	p.object(&"farola_verde", Vector2i(15, 31))
	# Las porterías: dos postes de valla en cada fondo.
	for at: Vector2i in [Vector2i(17, 34), Vector2i(17, 36), Vector2i(32, 34), Vector2i(32, 36)]:
		p.object(&"valla", at)

	# La mansión: verja, jardín cuidado y palmeras, en medio de todo lo demás.
	p.object(&"casa_carbonell", Vector2i(28, 10))
	p.pond(Rect2i(37, 3, 6, 4))
	p.hedge(24, 27, 11)
	p.hedge(36, 40, 11)
	for at: Vector2i in [Vector2i(23, 6), Vector2i(44, 8)]:
		p.object(&"palmera", at)
	p.flowers(Rect2i(25, 7, 3, 3))
	p.flowers(Rect2i(37, 8, 3, 2))
	p.object(&"arbol_redondo", Vector2i(44, 16))
	p.object(&"arbol_redondo", Vector2i(2, 12))

	_sign(p, "CartelRocafonda", Vector2i(2, 24), ["ROCAFONDA · MATARÓ · 08304.",
		"El 304 del código postal es el que hace Lamine con los dedos cuando marca. Aquí lo saben todos los niños."])
	_sign(p, "CartelCampo", Vector2i(24, 29), ["CAMPO DE FÚTBOL DEL BARRIO.",
		"Tierra, porterías sin red y un balón que ya ha roto tres ventanas. De aquí salió el mejor jugador joven del mundo."])
	_sign(p, "CartelMansion", Vector2i(34, 17), ["PROPIEDAD PRIVADA.", "Prohibido el paso. Prohibido tocar el timbre. Prohibido pedir autógrafos. Bueno, uno."])
	_sign(p, "CartelOeste", Vector2i(1, 19), ["← Barcelona · Eixample."])

	p.spawn("default", Vector2i(2, 21))
	p.spawn("from_eixample", Vector2i(0, 21))
	for kid: Array in [
		["Nino1", "npc_boy", Vector2i(19, 33), RIGHT, ["¡Pásala! ¡Pásala! ...Nunca me la pasan."]],
		["Nino2", "npc_youngster", Vector2i(24, 34), LEFT, ["Yo voy a ser como Lamine. Ya tengo el corte de pelo; me falta lo demás."]],
		["Nina", "npc_girl", Vector2i(29, 32), DOWN, ["¡Gol! Bueno, ha dado en el poste. Bueno, en la mochila que hace de poste."]],
		["Portero", "npc_boy", Vector2i(31, 35), LEFT, ["Me han puesto de portero porque llegué el último. Llevo cuatro años llegando el último."]],
	]:
		p.npc(kid[0], kid[1], kid[2], kid[3], PackedStringArray(kid[4]))
	p.npc("AbuelaLamine", "abuela", Vector2i(18, 19), DOWN, PackedStringArray([
		"Mi nieto ya juega en el Barça y en la selección, pero para mí sigue siendo el niño que rompía los cristales con el balón.",
		"Se ha comprado esa casa tan grande, pero viene a comer aquí. Donde está la abuela, está la comida.",
		"¿Has comido? Siéntate, que hay arroz para todo el barrio."]), {"display_name": "Abuela de Lamine"})
	p.npc("Vecino", "npc_old_man", Vector2i(8, 22), UP, PackedStringArray([
		"Rocafonda es un barrio humilde. Cuando ese chaval marcó en la Eurocopa, aquí se oyó más que en el estadio.",
		"La mansión apareció de un día para otro. Antes era un descampado. Ahora es un descampado con verja."]))
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
