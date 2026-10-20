extends RefCounted
## Ruta 5 · Corredor del Henares (72×32). El bulevar de la A-2 con farolas, el polígono vallado al
## oeste, la plaza de Cervantes con bancos y flores en Alcalá, un cerro con hierba alta al noroeste,
## pinares al norte y el paseo del Henares con sotos, juncos y un pescador. Se conservan los
## edificios, sus puertas, los carteles, Wilmer, Nuria, Álex y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


func vestir_inicial(v: Vestidor) -> void:
	var R := Vestidor.rects
	# Cerro del noroeste: meseta con hierba alta; escalera en la columna 6.
	v.plateau(Rect2i(0, 0, 13, 7), [6])
	v.tall_grass(R.call([Rect2i(1, 1, 6, 3), Rect2i(2, 4, 3, 1)]))
	v.add_forest(Rect2i(8, 0, 4, 4))
	v.item("SuperpocionCerro", &"superpotion", Vector2i(10, 4), true)
	# Bulevar de la A-2: farolas a los dos lados de la carretera.
	for x: int in [4, 16, 22, 48, 66]:
		v.object(&"farola_roja", Vector2i(x, 13))
	for x: int in [8, 20, 33, 56, 62, 70]:
		v.object(&"farola_roja", Vector2i(x, 18))
	# Polígono: valla, palés (troncos) y un camión de reparto aparcado (los adornos del muelle).
	v.fence(2, 12, 19)
	for at: Vector2i in [Vector2i(13, 8), Vector2i(13, 10)]:
		v.deco(at, ExteriorTiles.LOG_LEFT[0])
		v.deco(at + Vector2i.RIGHT, ExteriorTiles.LOG_LEFT[1])
	v.trainer("Mozo", &"ruta5_mozo", Vector2i(8, 26), Vestidor.UP, 3)
	# Plaza de Cervantes: bancos, flores y jardineras.
	v.object(&"banco", Vector2i(40, 26))
	v.flowers(Rect2i(41, 19, 3, 2), 0.4)
	v.flowers(Rect2i(37, 24, 2, 1), 0.4)
	v.trainer("Tuno", &"ruta5_tuno", Vector2i(42, 22), Vestidor.LEFT, 3)
	v.object(&"cerezo", Vector2i(24, 19))
	v.object(&"arbol_redondo", Vector2i(22, 13))
	# Guadalajara: jardines delante de las casas.
	v.flowers(Rect2i(62, 12, 2, 1), 0.5)
	v.flowers(Rect2i(50, 9, 1, 3), 0.5)
	v.tall_flower(Vector2i(68, 12), Vector2i(0, 10))
	v.tall_flower(Vector2i(69, 12), Vector2i(1, 10))
	# Paseo del Henares: camino de ribera, juncos y sotos.
	v.path(R.call([Rect2i(0, 27, 72, 2)]))
	v.tall_grass(R.call([Rect2i(23, 28, 3, 1), Rect2i(44, 28, 3, 1), Rect2i(60, 28, 4, 1)]))
	v.npc("PescadorHenares", "npc_fisherman", Vector2i(36, 28), Vestidor.DOWN, PackedStringArray([
		"En el Henares pican barbos. Y algún carrito del súper, que también cuenta.",
		"Cervantes se bañaba aquí de chaval. O eso pone en el cartel que no existe."]))
	v.item("SuperBallRibera", &"greatball", Vector2i(54, 28))
	v.item("EterJuncos", &"ether", Vector2i(45, 28), true)
	# Las manchas de hierba alta, con el borde irregular; chopos y arbustos entre ellas.
	v.roughen_tall_grass(Rect2i(0, 18, 72, 9), 0.45)
	v.roughen_tall_grass(Rect2i(13, 1, 10, 6), 0.45)
	for at: Vector2i in [Vector2i(23, 26), Vector2i(53, 24), Vector2i(61, 21), Vector2i(1, 26), Vector2i(10, 18)]:
		v.object(&"arbol_verde", at)
	for at: Vector2i in [Vector2i(27, 24), Vector2i(62, 25), Vector2i(4, 25)]:
		v.object(&"arbustos", at)
	# Obras de la A-2: la carretera se corta y se cruza el campo por la hierba (columnas 52-55),
	# cerrado al norte por el pinar y el Infantado y al sur por el río.
	v.add_forest(Rect2i(52, 0, 4, 6), false)
	v.path(R.call([Rect2i(50, 14, 2, 4), Rect2i(56, 14, 2, 4)]))
	v.grass_band(Rect2i(52, 13, 4, 16))
	v.sign("CartelObras", Vector2i(51, 18), PackedStringArray(["OBRAS EN LA A-2.",
		"Desvío por el campo. Disculpen las molestias (desde 2009)."]))
	await v.refresh()
	# Pinares al norte y sotos de chopos junto al río.
	v.fill({"estilo": "bosque", "zona": Rect2i(0, 0, 72, 7), "margen": [1, 1], "sueltos": 0.6})
	v.fill({"estilo": "arboleda", "zona": Rect2i(0, 18, 72, 9), "margen": [1, 1],
		"arboles": [&"arbol_verde", &"pino", &"arbol_redondo"], "hueco": 1, "adornos": 0.07,
		"excluir": [Rect2i(36, 18, 11, 9)]})


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.bolsa(v, "RocaGolpeCerro", "rock_smash", Vector2i(6, 6))
	await v.refresh()
