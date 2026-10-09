extends SceneTree
## Pinta la Ruta 13 · Mar de olivos (maps/ruta_13/exterior.tscn), de Granada (este) hacia Sevilla (oeste)
## por la campiña de Jaén y Córdoba (docs/mundo/rutas.md): olivares en hileras que no se acaban, el
## cortijo del aceite "a precio de oro", y Córdoba junto al Guadalquivir, con la Mezquita-Catedral de
## fondo y el Puente Romano, que cruza a la orilla de la Calahorra. Se une sin fundido con la Ruta 12
## (este) y con Sevilla · Centro (oeste).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_ruta_13.gd -- --force

const OUT := "res://maps/ruta_13/exterior.tscn"
const SIZE := Vector2i(76, 46)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_ruta_13: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
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


## Hileras de olivos: uno cada 3 casillas en x y en y (abajo a la izquierda de cada olivo).
func grove(p: RefCounted, xs: Array, ys: Array, skip: Array = []) -> void:
	for y: int in ys:
		for x: int in xs:
			if not Vector2i(x, y) in skip:
				p.object(&"olivo", Vector2i(x, y))


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"ruta_13/exterior"
	data.display_name = "Ruta 13 · Mar de olivos"
	data.zone_id = &"ruta_13"
	data.encounter_table = &"ruta_13"
	data.region_map_position = Vector2i(11, 18)
	var p: RefCounted = painter.new("Ruta13", SIZE, data, 1313)
	p.fill_grass(0.3)
	p.connect_edge("east", &"ruta_12/exterior", 0, Vector2i(20, 30))
	p.connect_edge("west", &"sevilla/centro", 0, Vector2i(14, 26))

	# El camino: entra por el este, sube entre los olivares y baja a Córdoba; sale al oeste.
	p.terrain(rects([Rect2i(58, 24, 18, 3), Rect2i(56, 14, 3, 13), Rect2i(28, 14, 31, 3), Rect2i(28, 14, 3, 7),
		Rect2i(0, 18, 31, 3), Rect2i(16, 21, 4, 9)]), ExteriorTiles.TERRAIN_PATH)
	p.terrain(rects([Rect2i(62, 27, 12, 3), Rect2i(2, 4, 10, 6), Rect2i(21, 22, 4, 4)]), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(rects([Rect2i(47, 13, 1, 1)]), ExteriorTiles.TERRAIN_PATH)
	p.soil(Rect2i(44, 4, 4, 3))
	# El Guadalquivir, con el hueco del Puente Romano (debajo hay suelo pisable).
	p.water(Rect2i(0, 30, 17, 8))
	p.water(Rect2i(19, 30, 57, 8))
	p.build_water(0.25)
	p.terrain(rects([Rect2i(17, 30, 2, 9)]), ExteriorTiles.TERRAIN_PATH)

	for r: Rect2i in [Rect2i(0, 0, 76, 2), Rect2i(0, 2, 2, 12), Rect2i(0, 26, 2, 4), Rect2i(74, 2, 2, 18),
			Rect2i(0, 42, 76, 4), Rect2i(30, 38, 46, 4)]:
		p.forest(r)
	p.build_forest()
	p.object_under(&"puente_piedra", Vector2i(16, 37))

	# Los olivares: Jaén (este), la campiña (norte) y el olivar del sur, en hileras.
	grove(p, [60, 63, 66, 69, 72], [5, 8, 11, 14, 17, 20])
	grove(p, [30, 33, 36, 39, 42, 48, 51], [5, 8, 11], [Vector2i(48, 8), Vector2i(48, 11)])
	grove(p, [33, 36, 39, 42, 45, 48, 51], [21, 24, 27])
	grove(p, [3, 6, 9, 12], [13, 16], [Vector2i(12, 16)])

	# Córdoba: la Mezquita-Catedral de fondo, junto al río.
	p.object(&"mezquita", Vector2i(2, 29))
	p.object(&"casa_granero", Vector2i(25, 29))   # una casa de patio cordobés
	p.flowers(Rect2i(11, 25, 4, 2), 0.4)
	p.flowers(Rect2i(26, 21, 2, 2), 0.3)
	# El cortijo del aceite.
	p.object(&"casa_dos_aguas", Vector2i(46, 13))
	p.fence(41, 45, 13)
	for cell: Vector2i in [Vector2i(54, 7), Vector2i(26, 9), Vector2i(10, 22), Vector2i(8, 39)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 == 0 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(0, 0, SIZE.x, SIZE.y), 0.05, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL, ExteriorTiles.WHITE_FLOWERS])

	# --- Carteles ---
	p.deco(Vector2i(73, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelRuta", Vector2i(73, 23), PackedStringArray(["RUTA 13 · MAR DE OLIVOS",
		"← Córdoba y Sevilla   → Granada. Olivos: unos sesenta millones. Sombra: ninguna."]))
	p.deco(Vector2i(45, 17), ExteriorTiles.SIGN)
	p.sign_text("CartelAceite", Vector2i(45, 17), PackedStringArray(["ACEITE DE OLIVA VIRGEN EXTRA · VENTA DIRECTA.",
		"Garrafa de 5 litros: 45 euros. Se aceptan joyas, coches y riñones."]))
	p.deco(Vector2i(13, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelMezquita", Vector2i(13, 29), PackedStringArray(["MEZQUITA-CATEDRAL DE CÓRDOBA.",
		"Mezquita del siglo VIII con una catedral dentro desde el XVI. Ni se pelean: ya pelean los demás por ella."]))
	p.deco(Vector2i(20, 29), ExteriorTiles.SIGN)
	p.sign_text("CartelPuente", Vector2i(20, 29), PackedStringArray(["PUENTE ROMANO.",
		"Dos mil años cruzando el Guadalquivir. Sale en una serie de dragones, así que ahora lo cruzan con capa."]))
	p.deco(Vector2i(14, 40), ExteriorTiles.SIGN)
	p.sign_text("CartelCalahorra", Vector2i(14, 40), PackedStringArray(["TORRE DE LA CALAHORRA, al otro lado del puente.",
		"La tienes justo detrás. O la tendrías, si alguien la hubiera dibujado ya."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(74, 25))
	p.spawn("from_ruta_12", Vector2i(75, 25))
	p.spawn("from_sevilla", Vector2i(0, 19))
	p.trainer("Manuel", &"ruta13_aceitunero", Vector2i(65, 12), RIGHT, 3)
	p.trainer("Rafael", &"ruta13_aceitero", Vector2i(42, 16), DOWN, 3)
	p.trainer("Gunnar", &"ruta13_turista", Vector2i(12, 27), LEFT, 3)
	p.npc("Agricultor", "npc_old_man", Vector2i(53, 23), LEFT, PackedStringArray([
		"Este olivo lo plantó mi bisabuelo. La aceituna la cobro yo. El aceite, el del supermercado.",
		"A mí me pagan a 3 euros el kilo; en la tienda lo venden a 10. La diferencia se la come alguien."]))
	p.npc("Vecina", "npc_woman", Vector2i(23, 26), DOWN, PackedStringArray([
		"En mayo abrimos el patio para la Fiesta de los Patios. Vienen diez mil turistas y riegan las macetas con la vista."]))
	p.npc("Pescador", "npc_fisherman", Vector2i(30, 29), DOWN, PackedStringArray([
		"En el Guadalquivir hay más Basculin que agua. Con la sequía, más Basculin que río."]))
	return p
