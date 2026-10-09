extends SceneTree
## Valladolid. Norte arriba; composición y encuentros provisionales.
const OUT := "res://maps/valladolid/exterior.tscn"
const SIZE := Vector2i(72, 64)
func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		quit(1)
		return
	var d := MapData.new()
	d.id = &"valladolid/exterior"
	d.display_name = "Valladolid"
	d.zone_id = &"valladolid"
	d.encounter_table = &"valladolid"
	d.region_map_position = Vector2i(11, 7)
	var p := Pintor.new("Valladolid", SIZE, d, 2122)
	p.fill_grass(0.2)
	# Pisuerga al oeste del casco; Campo Grande al sur, estación aún más al sur.
	p.paving(Rect2i(18, 0, 54, 40))
	p.paving(Rect2i(18, 40, 6, 24))
	p.paving(Rect2i(48, 40, 24, 24))
	p.paving(Rect2i(0, 28, 72, 4))
	p.paving(Rect2i(18, 60, 54, 4))
	p.build_paving()
	p.water(Rect2i(12, 0, 4, 28))
	p.water(Rect2i(12, 32, 4, 18))
	p.water(Rect2i(12, 54, 4, 10))
	p.build_water()
	p.object_under(&"puente_piedra", Vector2i(11, 31))
	p.object_under(&"puente_piedra", Vector2i(11, 53))
	p.object(&"cupula_milenio", Vector2i(2, 36))
	p.terrain(Pintor.cells(Rect2i(2, 43, 8, 12)), ExteriorTiles.TERRAIN_TALL_GRASS)
	# Plaza Mayor roja y porticada, con centro libre para el gimnasio 7.
	for x: int in [26, 30, 34, 38]:
		p.object(&"soportales", Vector2i(x, 26))
	p.object(&"soportales_arco", Vector2i(42, 26))
	p.object(&"ayuntamiento_valladolid", Vector2i(30, 18))
	p.object(&"conde_ansurez", Vector2i(34, 35))
	p.object(&"centro_pokemon", Vector2i(18, 26))
	p.object(&"tienda_verde", Vector2i(55, 26))
	p.object(&"tienda_morada", Vector2i(61, 26))
	p.object(&"tienda_azul", Vector2i(61, 38))
	# San Pablo y Museo de Escultura al norte; catedral al este de Plaza Mayor.
	p.object(&"san_pablo_valladolid", Vector2i(18, 15))
	p.object(&"casa_roja", Vector2i(37, 9))
	p.object(&"catedral_valladolid", Vector2i(53, 16))
	for b: Array in [[&"bloque_pisos",Vector2i(64,14)],[&"casa_madera",Vector2i(53,38)],
		[&"casa_dos_aguas",Vector2i(64,51)],[&"oficinas_azules",Vector2i(50,59)]]:
		p.object(b[0],b[1])
	# Manzanas del casco: dejan calles y el acceso norte libres.
	for b: Array in [[&"casa_roja_chimenea",Vector2i(2,19)],[&"casa_dos_aguas",Vector2i(46,10)],
		[&"casa_madera",Vector2i(49,27)],
		[&"oficinas_azules",Vector2i(18,51)],[&"casa_dos_aguas",Vector2i(55,49)]]:
		p.object(b[0],b[1])
	for at: Vector2i in [Vector2i(18,37),Vector2i(47,37),Vector2i(53,5),Vector2i(69,27),Vector2i(6,60)]:
		p.object(&"arbol_redondo",at)
	for at: Vector2i in [Vector2i(18,3),Vector2i(39,3),Vector2i(66,59),Vector2i(19,56)]:
		p.object(&"arbustos",at)
	p.flowers(Rect2i(52,29,3,2))
	p.flowers(Rect2i(23,16,2,3))
	# Campo Grande: bosque y estanque, con paseos que mantienen acceso desde la estación.
	p.pond(Rect2i(34, 48, 9, 6))
	p.terrain(Pintor.cells(Rect2i(26, 42, 6, 3)), ExteriorTiles.TERRAIN_TALL_GRASS)
	p.terrain(Pintor.cells(Rect2i(25, 53, 6, 5)), ExteriorTiles.TERRAIN_TALL_GRASS)
	for at: Vector2i in [Vector2i(25,48),Vector2i(29,51),Vector2i(43,45),Vector2i(43,59)]:
		p.object(&"arbol_redondo",at)
	p.flowers(Rect2i(32,56,9,2))
	for at: Vector2i in [Vector2i(24,33),Vector2i(45,33),Vector2i(56,33)]:
		p.object(&"farola_verde",at)
	p.object(&"banco",Vector2i(39,45))
	p.spawn("default",Vector2i(48,1))
	p.spawn("from_ruta_22",Vector2i(48,0))
	p.spawn("from_ruta_23",Vector2i(71,31))
	p.connect_edge("north", &"ruta_22/exterior", -24, Vector2i(46,50))
	p.trainer("Aficionado", &"valladolid_aficionado",Vector2i(30,33),2,3)
	p.trainer("Paseante", &"valladolid_paseante",Vector2i(32,59),3,3)
	_sign(p,"Gimnasio7",Vector2i(39,34),["PLAZA MAYOR · GIMNASIO 7", "Juanmi Latasa. El fútbol no llena las vitrinas, pero aquí habrá una medalla."])
	_sign(p,"Museo",Vector2i(28,16),["SAN PABLO Y MUSEO NACIONAL DE ESCULTURA", "Tallas policromadas y siglos de historia. El acabado de la obra pública moderna se quedó en presupuesto."])
	_sign(p,"Catedral",Vector2i(52,17),["CATEDRAL DE VALLADOLID", "Inacabada. Se empezó antes de que se inventara la excusa de la falta de presupuesto."])
	_sign(p,"Mercadona",Vector2i(55,27),["MERCADONA · HACENDADO", "La compra sube más niveles que tu equipo."])
	_sign(p,"Estanco",Vector2i(66,27),["ESTANCO · TABACOS", "Sellos, lotería y noticias del barrio."])
	_sign(p,"BasicFit",Vector2i(66,39),["BASIC-FIT", "La cuota entrena tu cuenta todos los meses."])
	_sign(p,"Academia",Vector2i(23,52),["ACADEMIA DE CABALLERÍA", "En Valladolid el caballo también tiene academia. Tú sigues buscando una plaza fija."])
	_sign(p,"Pasaje",Vector2i(50,39),["PASAJE GUTIÉRREZ", "Galería comercial del siglo XIX. Escaparates de antes de que todo fuera una franquicia."])
	_sign(p,"Teatro",Vector2i(45,27),["TEATRO ZORRILLA", "Plaza Mayor. Aquí la función empieza a su hora; los trenes tienen otro guionista."])
	_sign(p,"CampoGrande",Vector2i(32,41),["CAMPO GRANDE", "Paseos, estanque y aves. Aquí los pavos no son los del pleno."])
	_sign(p,"Estacion",Vector2i(55,60),["ESTACIÓN CAMPO GRANDE · AVE", "Próximo tren a Madrid: cuando quiera. Mira la pantalla. Sigue mirando."])
	_sign(p,"Cupula",Vector2i(7,37),["CÚPULA DEL MILENIO", "De la Expo de Zaragoza al Pisuerga. La burbuja de cristal sí tiene vistas."])
	p.npc("Vecina", "npc_old_woman",Vector2i(37,36),0,PackedStringArray(["Antes quedábamos junto al Conde Ansúrez. Ahora todos llegan mirando el móvil."]))
	print("Valladolid: ", error_string(p.save(OUT)))
	quit()
func _sign(p: Pintor, label: String, at: Vector2i, lines: Array) -> void:
	p.deco(at, ExteriorTiles.SIGN)
	p.sign_text(label, at, PackedStringArray(lines))
