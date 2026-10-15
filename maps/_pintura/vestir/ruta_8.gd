extends RefCounted
## Ruta 8 · Montserrat (72×40). La montaña con pinar y roquedo a los lados del macizo, la explanada
## del monasterio con cipreses, flores y bancos, el bordillo que baja de la carretera a los campos,
## viñas del Bages junto a Santpedor, frutales en Sant Esteve y bosque al sur. Se conservan el
## monasterio, las agujas, las casas, los carteles, Laia, Oriol y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	var R := Vestidor.rects
	# Explanada del monasterio: cipreses, flores y bancos.
	for at: Vector2i in [Vector2i(26, 11), Vector2i(48, 11)]:
		v.object(&"pino", at)
	v.flowers(Rect2i(24, 7, 2, 4), 0.5)
	v.flowers(Rect2i(50, 7, 1, 4), 0.5)
	v.object(&"banco", Vector2i(27, 6))
	v.object(&"banco", Vector2i(42, 6))
	v.trainer("Escaladora", &"ruta8_escaladora", Vector2i(31, 5), Vestidor.DOWN, 2)
	v.item("SuperpocionMonasterio", &"superpotion", Vector2i(50, 6), true)
	# Las laderas del macizo: pinar, roquedo y una meseta con hierba alta al oeste.
	v.plateau(Rect2i(14, 0, 8, 10), [17])
	v.tall_grass(R.call([Rect2i(15, 1, 6, 4)]))
	v.item("CuerdaHuidaLadera", &"escaperope", Vector2i(20, 6))
	for at: Vector2i in [Vector2i(1, 2), Vector2i(4, 4), Vector2i(57, 3), Vector2i(66, 1), Vector2i(70, 4), Vector2i(53, 12)]:
		v.deco(at, ExteriorTiles.ROCK)
	# Bordillo: de la carretera se baja de un salto a los campos.
	v.ledge(16, 38, 19)
	v.ledge(56, 69, 19)
	# Viñas del Bages junto a Santpedor y frutales en Sant Esteve.
	for y: int in [21, 23, 25, 27]:
		for x: int in range(36, 40):
			v.object(&"cepa_rioja", Vector2i(x, y))
	v.fence(35, 40, 28)
	for at: Vector2i in [Vector2i(44, 30), Vector2i(48, 30)]:
		v.object(&"manzano", at)
	v.flowers(Rect2i(26, 33, 2, 3), 0.4)
	v.flowers(Rect2i(46, 33, 3, 2), 0.4)
	v.roughen_tall_grass(Rect2i(0, 18, 72, 12), 0.4)
	v.npc("Vendimiadora", "npc_woman", Vector2i(35, 23), Vestidor.RIGHT, PackedStringArray([
		"Aquí se hace vino desde los romanos. Y el monje de arriba se lo bebe desde hace un poco menos.",
		"Pep Guardiola es de Santpedor. Todo el pueblo sabe hacer la presión alta."]))
	v.item("SuperBallVinas", &"greatball", Vector2i(39, 26), true)
	# Paso obligado: el collado al este de Montserrat (columnas 52-55), con pinar al norte.
	v.add_forest(Rect2i(52, 0, 4, 14), false)
	v.grass_band(Rect2i(52, 14, 4, 26))
	await v.refresh()
	# Pinar en las laderas y bosque al sur.
	v.fill({"estilo": "bosque", "margen": [1, 1], "sueltos": 0.45, "adornos": 0.07,
		"excluir": [Rect2i(23, 0, 28, 13)]})
