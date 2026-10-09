extends SceneTree
## Pinta Madrid · Centro (maps/madrid/centro.tscn): de la Plaza de España a la calle de Alcalá por la
## Gran Vía, Callao, la Puerta del Sol y la Plaza Mayor (docs/mundo/ciudades/madrid.md y el plano
## real docs/mundo/planos/madrid_centro.svg, norte arriba). Toda la ciudad es de baldosas; las
## calles son los pasillos que dejan las manzanas:
## - Gran Vía: baja en escalones de la Plaza de España (oeste) a Callao y a Alcalá (este), con el
##   Edificio Carrión (cartel de Schweppes), los cines, la Telefónica, el Teatro Príncipe Gran Vía
##   (La Revuelta) y el Edificio Metrópolis en la esquina de Alcalá.
## - Puerta del Sol: la Real Casa de Correos (GIMNASIO 1, Ayuso) con el reloj de las campanadas, el
##   Kilómetro 0, la fuente, Carlos III y el Oso y el Madroño. El Corte Inglés de Preciados al lado.
## - Plaza Mayor: la Casa de la Panadería, los soportales y el Arco de Cuchilleros; el Mercado de
##   San Miguel al oeste. La calle de la Victoria sale de Sol hacia el sur.
## Se une sin fundido con Moncloa por el oeste (Plaza de España).
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_madrid_centro.gd -- --force

const OUT := "res://maps/madrid/centro.tscn"
const SIZE := Vector2i(72, 56)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_madrid_centro: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"madrid/centro"
	data.display_name = "Madrid · Sol y Gran Vía"
	data.zone_id = &"madrid"
	data.encounter_table = &"madrid"
	data.region_map_position = Vector2i(14, 11)
	var p: RefCounted = painter.new("MadridCentro", SIZE, data, 1766)
	p.fill_grass(0.1)
	p.connect_edge("west", &"madrid/moncloa", 38)
	p.paving(Rect2i(0, 0, SIZE.x, SIZE.y))
	p.build_paving()

	var buildings := [
		# Gran Vía, lado norte (de oeste a este).
		[&"bloque_verde_2", Vector2i(2, 5)],
		[&"tienda_azul", Vector2i(11, 5)],            # Basic-Fit de la Gran Vía
		[&"edificio_carrion", Vector2i(22, 13)],      # Callao: cartel de Schweppes
		[&"teatro", Vector2i(30, 13)],                # Cines Callao
		[&"bloque_verde_2", Vector2i(38, 7)],
		[&"oficinas_verdes", Vector2i(37, 17)],       # Telefónica
		[&"teatro", Vector2i(45, 17)],                # Teatro Príncipe Gran Vía (La Revuelta)
		[&"bloque_pisos", Vector2i(51, 17)],
		[&"edificio_metropolis", Vector2i(60, 21)],
		[&"oficinas_azules", Vector2i(66, 21)],       # Círculo de Bellas Artes
		# Gran Vía, lado sur, y Preciados.
		[&"bloque_pisos", Vector2i(2, 19)],
		[&"oficinas_azules", Vector2i(9, 19)],
		[&"bloque_verde_2", Vector2i(2, 27)],
		[&"tienda_morada", Vector2i(11, 27)],
		[&"grandes_almacenes", Vector2i(19, 27)],     # El Corte Inglés de Preciados
		# Puerta del Sol.
		[&"casa_correos", Vector2i(34, 31)],          # GIMNASIO 1
		[&"centro_pokemon", Vector2i(40, 48)],
		# Plaza Mayor: soportales alrededor, la Casa de la Panadería al norte y el Arco de Cuchilleros.
		[&"soportales", Vector2i(10, 42)],
		[&"casa_panaderia", Vector2i(14, 42)],
		[&"soportales", Vector2i(26, 42)],
		[&"soportales", Vector2i(10, 49)],
		[&"soportales", Vector2i(26, 49)],
		[&"soportales", Vector2i(10, 55)],
		[&"soportales_arco", Vector2i(14, 55)],
		[&"soportales", Vector2i(18, 55)],
		[&"soportales", Vector2i(22, 55)],
		[&"soportales", Vector2i(26, 55)],
		[&"mercado_san_miguel", Vector2i(1, 48)],
		# Entre Gran Vía y Alcalá, y el Barrio de las Letras.
		[&"bloque_verde_2", Vector2i(51, 31)],
		[&"tienda_morada", Vector2i(60, 31)],
		[&"teatro", Vector2i(66, 31)],
		[&"bloque_pisos", Vector2i(51, 42)],
		[&"oficinas_azules", Vector2i(58, 41)],
		[&"bloque_verde", Vector2i(65, 42)],
		[&"teatro", Vector2i(52, 52)],                # Teatro Español, en la Plaza de Santa Ana
		[&"tienda_flores", Vector2i(59, 52)],
		# Más manzanas para cerrar las calles.
		[&"puesto_mercado", Vector2i(16, 5)],
		[&"tienda_azul", Vector2i(30, 6)],
		[&"tienda_morada", Vector2i(46, 10)],
		[&"oficinas_azules", Vector2i(51, 8)],
		[&"bloque_pisos", Vector2i(66, 13)],
		[&"bloque_verde_2", Vector2i(46, 26)],
		[&"bloque_pisos", Vector2i(33, 50)],
		[&"oficinas_azules", Vector2i(1, 39)],
	]
	for b: Array in buildings:
		p.object(b[0], b[1])

	# Puerta del Sol: la fuente, Carlos III (provisional: busto), el Oso y el Madroño.
	p.object(&"fuente_plaza", Vector2i(37, 38))
	p.object(&"busto", Vector2i(42, 38))
	p.object(&"oso_madrono", Vector2i(46, 40))
	# Plaza Mayor: Felipe III a caballo (provisional: busto), farolas.
	p.object(&"busto", Vector2i(19, 47))
	for cell: Vector2i in [Vector2i(15, 45), Vector2i(24, 45), Vector2i(31, 35), Vector2i(46, 35), Vector2i(17, 10),
			Vector2i(58, 10)]:
		p.object(&"farola_verde", cell)
	for cell: Vector2i in [Vector2i(66, 48), Vector2i(69, 52), Vector2i(65, 55), Vector2i(1, 55), Vector2i(6, 55),
			Vector2i(31, 52)]:
		p.object(&"arbol_redondo", cell)
	p.object(&"banco", Vector2i(66, 44))

	# --- Carteles ---
	p.deco(Vector2i(38, 32), ExteriorTiles.SIGN)
	p.sign_text("CartelKm0", Vector2i(38, 32), PackedStringArray(["KILÓMETRO 0.",
		"De aquí salen todas las carreteras radiales de España. Y todas las colas."]))
	p.deco(Vector2i(33, 31), ExteriorTiles.SIGN)
	p.sign_text("CartelGimnasio", Vector2i(33, 31), PackedStringArray(["GIMNASIO POKÉMON DE MADRID.",
		"Líder: Isabel Díaz Ayuso. Tipo Fuego. «Libertad... de combatir»."]))
	p.deco(Vector2i(9, 10), ExteriorTiles.SIGN)
	p.sign_text("CartelManolita", Vector2i(9, 10), PackedStringArray(["DOÑA MANOLITA. Administración de lotería.",
		"La cola empieza aquí. Y termina en Navidad."]))
	p.deco(Vector2i(25, 43), ExteriorTiles.SIGN)
	p.sign_text("CartelEstanco", Vector2i(25, 43), PackedStringArray(["ESTANCO DE LA PLAZA MAYOR.",
		"Lotería del Gordo de Navidad. Sellos, tabaco y Poké Balls."]))
	p.deco(Vector2i(47, 36), ExteriorTiles.SIGN)
	p.sign_text("CartelVictoria", Vector2i(47, 36), PackedStringArray(["CALLE DE LA VICTORIA →",
		"Solo para entrenadores con las ocho medallas. Lleva al Palacio Real."]))
	p.deco(Vector2i(29, 23), ExteriorTiles.SIGN)
	p.sign_text("CartelCallao", Vector2i(29, 23), PackedStringArray(["PLAZA DE CALLAO.",
		"El cartel de Schweppes lleva encendido desde 1972. La factura de la luz, también."]))

	# --- Apariciones, entrenadores y vecinos ---
	p.spawn("default", Vector2i(1, 7))
	p.spawn("from_moncloa", Vector2i(0, 7))
	p.trainer("Paco", &"madrid_cunado", Vector2i(22, 46), LEFT, 3)
	p.trainer("Cayetana", &"madrid_influencer", Vector2i(34, 19), DOWN, 2)
	p.trainer("Ramon", &"madrid_tertuliano", Vector2i(44, 34), DOWN, 3)
	p.trainer("Hans", &"madrid_turista", Vector2i(16, 48), RIGHT, 3)
	for i: int in 4:
		p.npc("Cola%d" % i, ["npc_old_woman", "npc_man", "npc_old_man", "npc_lass"][i], Vector2i(10 + i, 10), LEFT,
			PackedStringArray([["Llevo aquí desde las seis. Este año toca, lo noto.",
				"Vengo por mi suegra. Y por si toca, que no se entere.",
				"Antes la cola llegaba a Callao. Ahora llega a Callao y vuelve.",
				"¿Tú también vienes a por el décimo? Pues a la cola, majo."][i]]))
	p.npc("Guia", "npc_man", Vector2i(35, 33), DOWN, PackedStringArray([
		"Esta es la Real Casa de Correos. Desde aquí se dan las campanadas de Nochevieja.",
		"Dentro está el gimnasio de Ayuso. Prepárate: hay terrazas y cañas en cada sala."]))
	p.npc("Madrileno", "npc_old_man", Vector2i(45, 41), LEFT, PackedStringArray([
		"El oso no come madroños: come las uvas de Nochevieja. Doce, una por campanada."]))
	return p
