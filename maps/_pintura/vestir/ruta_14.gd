extends RefCounted
## Ruta 14 · Doñana y las marismas (72×40). De Sevilla a Huelva por la marisma: la aldea del Rocío al
## norte con sus casas blancas, las lagunas, el camino elevado entre el agua, las dunas de la playa al
## sur y el pinar. Un paso obligado por juncos (hierba alta) corta el camino a la salida de Sevilla, del
## pinar del norte al del sur. Se conservan las casas, sus puertas, los carteles, los entrenadores, los
## vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por juncos a la salida de Sevilla, de pinar a pinar.
	v.grass_band(Rect2i(60, 20, 2, 16))
	# Juncos en las orillas de las lagunas y barcas de la marisma.
	v.tall_grass(Vestidor.rects.call([Rect2i(26, 14, 2, 3), Rect2i(10, 18, 3, 1)]))
	v.object(&"barca_albufera", Vector2i(20, 31), true)
	v.object(&"barca_albufera", Vector2i(36, 22), true)
	v.flowers(Rect2i(5, 5, 4, 2), 0.4)
	v.item("HiperpocionRocio", &"hyperpotion", Vector2i(57, 3), true)
	v.item("UltraBallDunas", &"ultraball", Vector2i(44, 37))
	v.item("RevivirMarisma", &"revive", Vector2i(5, 32), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"pino"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(0, 34, 48, 6)]})
