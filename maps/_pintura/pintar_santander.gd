extends SceneTree
## Santander (docs/mundo/ciudades/santander.md). Entra por el oeste desde la Ruta 18 (filas 20–23) y sale
## por el este a la Ruta 19 (filas 12–15). Al norte, el Sardinero con el Gran Casino; en el centro, la
## catedral, el Mercado de la Esperanza y la Plaza Porticada; al sur, el paseo de Pereda, el Centro
## Botín y Puertochico sobre la bahía; al sureste, la península de la Magdalena con el palacio y las
## focas. Centro Pokémon, Mercadona y estanco según maps/_pintura/locales.json.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_santander.gd -- --force

const OUT := "res://maps/santander/exterior.tscn"
const SIZE := Vector2i(64, 48)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_santander: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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
	d.id = &"santander/exterior"
	d.display_name = "Santander"
	d.zone_id = &"santander"
	d.encounter_table = &"santander"
	d.region_map_position = Vector2i(14, 2)
	var p := Pintor.new("Santander", SIZE, d, 3939)
	p.fill_grass(0.2)
	p.connect_edge("west", &"ruta_18/exterior", 0, Vector2i(20, 24))
	p.connect_edge("east", &"ruta_19/exterior", 0, Vector2i(12, 16))

	# Calles: el centro entero empedrado, la avenida hacia el este y el paseo de la bahía.
	p.paving(Rect2i(0, 8, 44, 32))
	p.paving(Rect2i(44, 12, 20, 4))
	p.paving(Rect2i(44, 12, 4, 12))
	p.build_paving()

	# El Cantábrico al norte (el Sardinero) y la bahía al sur.
	p.water(Rect2i(30, 0, 34, 3))
	p.water(Rect2i(0, 40, 64, 8))
	p.build_water(0.25)
	p.soil(Rect2i(30, 3, 34, 2))

	# Primera fila: catedral, servicios, Mercado de la Esperanza y pisos.
	p.object(&"catedral_santa_ana", Vector2i(1, 18))
	p.object(&"centro_pokemon", Vector2i(8, 18))
	p.object(&"tienda_verde", Vector2i(15, 18))
	p.object(&"tienda_morada", Vector2i(21, 18))
	p.object(&"mercado_san_miguel", Vector2i(27, 18))
	p.object(&"bloque_pisos", Vector2i(37, 18))
	# Segunda fila: la Plaza Porticada (soportales), teatro y un gimnasio de cadena.
	p.object(&"tienda_flores", Vector2i(1, 29))
	p.object(&"casa_gris", Vector2i(8, 29))
	for x: int in [14, 18, 22, 26]:
		p.object(&"soportales", Vector2i(x, 29))
	p.object(&"teatro", Vector2i(31, 29))
	p.object(&"tienda_azul", Vector2i(38, 29))
	# Al sur, sobre el agua: el Centro Botín y Puertochico.
	p.object(&"centro_botin", Vector2i(20, 37))
	p.object(&"barca_albufera", Vector2i(4, 46))
	p.object(&"barca_albufera", Vector2i(36, 47))
	p.object(&"farola_verde", Vector2i(12, 35))
	p.object(&"farola_verde", Vector2i(34, 35))
	p.object(&"banco", Vector2i(6, 35))

	# Norte: jardines de Piquío y el Sardinero con el Gran Casino.
	p.forest(Rect2i(0, 0, 18, 6))
	p.object(&"casa_azul", Vector2i(20, 7))
	p.object(&"teatro_real", Vector2i(50, 11))
	p.object(&"torre_socorrista", Vector2i(44, 7))
	p.flowers(Rect2i(36, 6, 6, 2))
	p.object(&"arbol_redondo", Vector2i(28, 7))

	# La Magdalena: césped, el palacio, el estanque de las focas y el faro.
	p.terrain(rects([Rect2i(50, 16, 2, 18)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(44, 26, 5, 12)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.object(&"casa_carbonell", Vector2i(54, 29))
	p.pond(Rect2i(52, 33, 7, 5))
	for at: Vector2i in [Vector2i(60, 37), Vector2i(48, 22), Vector2i(58, 20), Vector2i(62, 25)]:
		p.object(&"arbol_redondo", at)
	p.flowers(Rect2i(53, 30, 6, 2))
	p.build_forest()

	_sign(p, "CartelCatedral", Vector2i(7, 19), ["CATEDRAL DE SANTANDER.",
		"Del siglo XII, con el claustro gótico. Sobrevivió al incendio de 1941, que se llevó medio centro."])
	_sign(p, "CartelMercado", Vector2i(35, 19), ["MERCADO DE LA ESPERANZA.", "Hierro del siglo XIX y pescado de esta mañana. Las anchoas, de Santoña."])
	_sign(p, "CartelPorticada", Vector2i(13, 30), ["PLAZA PORTICADA.",
		"Se levantó después del incendio. Debajo hay un refugio de la guerra y un trozo de muralla medieval."])
	_sign(p, "CartelBotin", Vector2i(31, 36), ["CENTRO BOTÍN · RENZO PIANO.",
		"Arte sobre la bahía, forrado con 270.000 piezas de cerámica. Lo pagó un banco. Lo has pagado tú, con las comisiones."])
	_sign(p, "CartelPuerto", Vector2i(2, 38), ["PUERTOCHICO · FERRY A INGLATERRA.",
		"El ferry a Portsmouth sale de la estación marítima. Tu aventura sigue por tierra."])
	_sign(p, "CartelCasino", Vector2i(58, 10), ["GRAN CASINO DEL SARDINERO.", "Modernista y con vistas al mar. La banca siempre gana; la playa, también."])
	_sign(p, "CartelMagdalena", Vector2i(52, 24), ["PALACIO DE LA MAGDALENA.",
		"Lo pagó la ciudad para regalárselo al rey en 1912. El rey veraneaba gratis; la ciudad sigue pagando el mantenimiento."])
	_sign(p, "CartelFocas", Vector2i(51, 38), ["MINI ZOO DE LA MAGDALENA.", "Focas, pingüinos y Seel. Los Seel no estaban en el proyecto original."])
	_sign(p, "CartelOeste", Vector2i(1, 24), ["← Ruta 18 · Asturias y Picos de Europa."])
	_sign(p, "CartelEste", Vector2i(62, 11), ["→ Ruta 19 · Costa de Cantabria.", "Castro Urdiales y, al final, Bilbao."])

	p.spawn("default", Vector2i(10, 21))
	p.spawn("from_ruta_18", Vector2i(0, 21))
	p.spawn("from_ruta_19", Vector2i(63, 13))
	p.trainer("Turista", &"santander_turista", Vector2i(17, 34), RIGHT, 3)
	p.trainer("Rabas", &"santander_raba", Vector2i(40, 36), LEFT, 3)
	p.npc("Pejino", "npc_fisherman", Vector2i(8, 38), DOWN, PackedStringArray([
		"Aquí a los del barrio pesquero nos llaman pejinos. A los del centro, de otra manera, pero no lo digo.",
		"Las rabas son calamar rebozado en tiras. Si te lo ponen en anillas, estás en Madrid."]))
	p.npc("Banista", "nadador_f", Vector2i(40, 6), DOWN, PackedStringArray([
		"El Sardinero tiene dos playas, la Primera y la Segunda. Los nombres no costaron mucho.",
		"El agua está a dieciocho grados. En agosto. Ven en agosto."]))
	p.npc("Vecino", "npc_old_man", Vector2i(24, 21), DOWN, PackedStringArray([
		"Santander es la ciudad más elegante del norte. Eso lo dicen en Santander.",
		"Cuando sopla el viento sur, todo el mundo se vuelve loco. Hoy no sopla. Creo."]))
	load("res://maps/_pintura/servicios_locales.gd").apply(p, "santander", "santander/exterior", JsonFile.read_dict("res://maps/_pintura/locales.json")["santander"])
	return p


func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
