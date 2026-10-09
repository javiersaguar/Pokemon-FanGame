extends SceneTree
## Pinta Vigo (maps/vigo/exterior.tscn). El norte es la salida a la Ruta 16. La Porta do Sol, en el
## centro, lleva el árbol de Navidad (encendido todo el año: el montaje empieza en julio) y el Sireno.
## Al este, el aeropuerto de Peinador: llegada del avión desde Gran Canaria (spawn from_avion). Al sur,
## la ría y el puerto. Plano: docs/mundo/planos/vigo.svg. docs/mundo/ciudades/vigo.md.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_vigo.gd -- --force

const OUT := "res://maps/vigo/exterior.tscn"
const SIZE := Vector2i(56, 46)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_vigo: '%s' ya existe; usa -- --force para sobrescribirlo." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"vigo/exterior"
	data.display_name = "Vigo"
	data.zone_id = &"vigo"
	data.encounter_table = &"vigo"
	data.region_map_position = Vector2i(2, 5)
	var p: RefCounted = painter.new("Vigo", SIZE, data, 824)
	p.fill_grass(0.16)
	# Borde norte: pasillo hacia la Ruta 16 (la unión entre tramos no es de este agente; la ruta sí).
	p.connect_edge("north", &"ruta_16/exterior", 0, Vector2i(24, 30))
	p.paving(Rect2i(0, 6, SIZE.x, SIZE.y - 6))
	p.build_paving()
	p.terrain(Pintor.cells(Rect2i(24, 0, 6, 6)), ExteriorTiles.TERRAIN_PATH)

	# La ría, al sur, con un muelle pisable en el centro.
	p.water(Rect2i(0, 38, 22, 8))
	p.water(Rect2i(28, 38, 28, 8))
	p.build_water(0.25)
	p.terrain(Pintor.cells(Rect2i(22, 36, 6, 10)), ExteriorTiles.TERRAIN_PATH)

	for b: Array in [
		[&"centro_pokemon", Vector2i(2, 18)],
		[&"tienda_verde", Vector2i(14, 18)],          # Mercadona
		[&"tienda_morada", Vector2i(22, 18)],         # estanco
		[&"tienda_azul", Vector2i(30, 18)],           # Basic-Fit
		[&"bloque_pisos", Vector2i(40, 18)],
		[&"casa_dos_aguas", Vector2i(2, 30)],         # Casco Vello
		[&"casa_madera", Vector2i(10, 30)],
		[&"casa_granero", Vector2i(16, 30)],
		[&"oficinas_azules", Vector2i(40, 32)],       # aeropuerto de Peinador
		[&"bloque_verde", Vector2i(46, 32)],
	]:
		p.object(b[0], b[1])
	p.object(&"arbol_navidad_vigo", Vector2i(26, 28))
	p.object(&"sireno_vigo", Vector2i(32, 28))
	for cell: Vector2i in [Vector2i(4, 22), Vector2i(20, 22), Vector2i(38, 22), Vector2i(50, 22), Vector2i(8, 36)]:
		p.object(&"farola_verde", cell)

	p.deco(Vector2i(24, 28), ExteriorTiles.SIGN)
	p.sign_text("CartelPorta", Vector2i(24, 28), PackedStringArray(["PORTA DO SOL.",
		"El árbol se monta en julio. El encendido es en noviembre. Las luces, todo el año.",
		"Doce millones de LED. Y el Sireno, mirando."]))
	p.deco(Vector2i(48, 33), ExteriorTiles.SIGN)
	p.sign_text("CartelAvion", Vector2i(48, 33), PackedStringArray(["AEROPUERTO DE PEINADOR.",
		"Llegadas: Gran Canaria. Líquidos en bolsa de 100 ml.",
		"El Falcon aparca donde quiere."]))
	p.deco(Vector2i(24, 2), ExteriorTiles.SIGN)
	p.sign_text("CartelNorte", Vector2i(24, 2), PackedStringArray(["↑ Ruta 16 · Rías Baixas.",
		"Sanxenxo queda más allá. Las bateas también."]))
	p.deco(Vector2i(23, 40), ExteriorTiles.SIGN)
	p.sign_text("CartelPuerto", Vector2i(23, 40), PackedStringArray(["PUERTO DE VIGO.",
		"Ostras, cruceros y, con permiso, las Islas Cíes.",
		"El cupo de visitantes se acaba antes que las ostras."]))

	p.spawn("default", Vector2i(26, 24))
	p.spawn("from_avion", Vector2i(50, 34))
	p.spawn("from_ruta_16", Vector2i(26, 1))
	p.trainer("Uxio", &"vigo_regatista", Vector2i(24, 42), UP, 3)
	p.trainer("Sabela", &"vigo_nadadora", Vector2i(12, 36), RIGHT, 3)
	p.npc("Operario", "npc_man", Vector2i(28, 26), DOWN, PackedStringArray([
		"Estamos montando la Navidad. Sí, es julio. En Vigo el calendario lo decide el alcalde."]))
	p.npc("Mostrador", "npc_lass", Vector2i(46, 34), RIGHT, PackedStringArray([
		"Peinador. El vuelo de Gran Canaria llega con las maletas y sin los líquidos.",
		"La pasarela del avión está en esta casilla. No te quedes en el medio."]))
	p.npc("Ostrera", "npc_old_woman", Vector2i(20, 36), LEFT, PackedStringArray([
		"Rúa das Ostras. Una docena, y el cupo de las Cíes se acaba antes que las ostras."]))
	return p
