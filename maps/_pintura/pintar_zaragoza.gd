extends SceneTree
## Pinta Zaragoza (maps/zaragoza/exterior.tscn) con el plano real docs/mundo/planos/zaragoza.svg (norte
## arriba; docs/mundo/ciudades/zaragoza.md): el Ebro cruza por el norte, con el Puente de Piedra y sus
## leones y el de Santiago; en la orilla sur, el Paseo de Echegaray y la Plaza del Pilar, larga y
## paralela al río, con la Basílica del Pilar, el Ayuntamiento, La Seo, la fuente de la Hispanidad y
## Goya; al sur, las callejuelas de tapas de El Tubo; el teatro romano de Caesaraugusta al sureste.
## En la orilla norte, el Arrabal y la ribera con hierba alta. Se une sin fundido con la Ruta 6
## (oeste).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_zaragoza.gd -- --force

const OUT := "res://maps/zaragoza/exterior.tscn"
const SIZE := Vector2i(72, 58)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_zaragoza: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	data.id = &"zaragoza/exterior"
	data.display_name = "Zaragoza"
	data.zone_id = &"zaragoza"
	data.encounter_table = &"zaragoza"
	data.region_map_position = Vector2i(21, 7)
	var p: RefCounted = painter.new("Zaragoza", SIZE, data, 1118)
	p.fill_grass(0.2)
	p.connect_edge("west", &"ruta_6/exterior", 4, Vector2i(14, 18))

	# La ciudad de la orilla sur, toda de baldosas; la orilla norte, ribera con hierba alta.
	p.paving(Rect2i(0, 14, 72, 44))
	p.build_paving()
	p.terrain(rects([Rect2i(2, 0, 14, 5), Rect2i(30, 0, 14, 5), Rect2i(58, 0, 14, 5)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	# El Ebro, con el hueco de los dos puentes (debajo hay suelo pisable).
	p.water(Rect2i(0, 6, 21, 8))
	p.water(Rect2i(23, 6, 26, 8))
	p.water(Rect2i(51, 6, 21, 8))
	p.build_water(0.3)
	p.terrain(rects([Rect2i(21, 5, 2, 9), Rect2i(49, 5, 2, 9), Rect2i(16, 1, 14, 2), Rect2i(44, 1, 14, 2)]),
		ExteriorTiles.TERRAIN_PATH)

	# Los puentes: el de Santiago y el de Piedra con sus cuatro leones.
	p.object_under(&"puente_piedra", Vector2i(20, 13))
	p.object_under(&"puente_piedra", Vector2i(48, 13))
	for cell: Vector2i in [Vector2i(46, 16), Vector2i(52, 16), Vector2i(46, 5), Vector2i(52, 5)]:
		p.object(&"leon_congreso", cell)

	# Plaza del Pilar.
	p.object(&"centro_pokemon", Vector2i(2, 28))
	p.object(&"basilica_pilar", Vector2i(16, 29))
	p.object(&"oficinas_azules", Vector2i(36, 29))       # Ayuntamiento
	p.object(&"la_seo", Vector2i(43, 31))
	p.object(&"fuente_plaza", Vector2i(8, 33))            # fuente de la Hispanidad
	p.object(&"busto", Vector2i(39, 34))                  # Goya
	for cell: Vector2i in [Vector2i(14, 33), Vector2i(34, 33), Vector2i(55, 33), Vector2i(66, 33)]:
		p.object(&"farola_verde", cell)
	p.object(&"tienda_verde", Vector2i(56, 30))           # Mercadona
	p.object(&"tienda_azul", Vector2i(62, 30))            # Basic-Fit

	# El Tubo: callejuelas de tapas (pasillos de una casilla entre las casas).
	for b: Array in [
		[&"casa_dos_aguas", Vector2i(16, 44)], [&"tienda_morada", Vector2i(21, 44)], [&"casa_granero", Vector2i(27, 44)],
		[&"casa_madera", Vector2i(32, 44)], [&"casa_dos_aguas", Vector2i(37, 44)],
		[&"casa_roja_chimenea", Vector2i(16, 54)], [&"casa_madera", Vector2i(22, 54)], [&"casa_granero", Vector2i(27, 54)],
		[&"casa_dos_aguas", Vector2i(32, 54)], [&"casa_roja_chimenea", Vector2i(37, 54)],
		[&"bloque_pisos", Vector2i(2, 46)], [&"oficinas_azules", Vector2i(2, 56)], [&"bloque_pisos", Vector2i(60, 46)],
		[&"bloque_verde_2", Vector2i(62, 56)],
	]:
		p.object(b[0], b[1])
	# Teatro romano de Caesaraugusta: las gradas en ruinas.
	for cell: Vector2i in [Vector2i(46, 45), Vector2i(47, 43), Vector2i(49, 42), Vector2i(51, 42), Vector2i(53, 43),
			Vector2i(54, 45), Vector2i(48, 47), Vector2i(52, 47)]:
		p.deco(cell, ExteriorTiles.ROCK if (cell.x + cell.y) % 2 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(0, 0, SIZE.x, 6), 0.06, [ExteriorTiles.TUFT, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(14, 30), ExteriorTiles.SIGN)
	p.sign_text("CartelPilar", Vector2i(14, 30), PackedStringArray(["BASÍLICA DEL PILAR.",
		"Dos bombas cayeron dentro en 1936 y no estallaron. Las tienes colgadas en una pared.",
		"Cinco millones de visitas al año. Y el cierzo, todas las tardes."]))
	p.deco(Vector2i(42, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelSeo", Vector2i(42, 32), PackedStringArray(["CATEDRAL DEL SALVADOR · LA SEO.",
		"Románica, gótica, mudéjar y barroca. No se decidían."]))
	p.deco(Vector2i(45, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelPuente", Vector2i(45, 15), PackedStringArray(["PUENTE DE PIEDRA (siglo XV).",
		"Sus cuatro leones vigilan el Ebro desde 1991. Antes vigilaba el cierzo, que no se cansa."]))
	p.deco(Vector2i(15, 45), ExteriorTiles.SIGN)
	p.sign_text("CartelTubo", Vector2i(15, 45), PackedStringArray(["EL TUBO.",
		"Callejuelas de tapas. Entras a por una y sales a las tantas."]))
	p.deco(Vector2i(50, 45), ExteriorTiles.SIGN)
	p.sign_text("CartelTeatro", Vector2i(50, 45), PackedStringArray(["TEATRO ROMANO DE CAESARAUGUSTA.",
		"Siglo I. Seis mil espectadores. Hoy, cuatro turistas y un Pokémon fantasma."]))
	p.deco(Vector2i(70, 15), ExteriorTiles.SIGN)
	p.sign_text("CartelEste", Vector2i(70, 15), PackedStringArray(["→ Ruta 7 · Los Monegros.",
		"Desierto. Lleva agua. Y gafas de sol. Y crema."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 15))
	p.spawn("from_ruta_6", Vector2i(0, 15))
	p.trainer("Jorge", &"zaragoza_baturro", Vector2i(28, 34), DOWN, 3)
	p.trainer("Chema", &"zaragoza_tubo", Vector2i(26, 46), LEFT, 3)
	p.npc("Devota", "npc_old_woman", Vector2i(26, 31), UP, PackedStringArray([
		"En las Fiestas del Pilar la ofrenda de flores cubre a la Virgen entera. Este año llevo claveles.",
		"Y si me toca la lotería, un ramo de rosas. Que la Virgen se lo merece."]))
	p.npc("Remero", "npc_fisherman", Vector2i(30, 15), UP, PackedStringArray([
		"Con Surf podrás remontar el Ebro. Cuidado con los siluros: hay más que zaragozanos."]))
	return p
