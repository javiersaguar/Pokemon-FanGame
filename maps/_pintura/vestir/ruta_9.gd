extends RefCounted
## Ruta 9 · La Albufera y la huerta (48×76). Del Turia hacia el sur entre la Albufera al oeste, la huerta
## con sus barracas, la avenida que cruza los arrozales, la playa del Saler al este y el pueblo del sur.
## Un paso obligado por hierba cierra de lado a lado la huerta entre la Albufera y la playa (la avenida
## se corta por las obras del carril bici). Se conservan las barracas, las casas, sus puertas, los
## carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba de la orilla de la Albufera a la arena del Saler.
	v.grass_band(Rect2i(14, 36, 29, 2))
	v.sign("CartelObrasCarril", Vector2i(24, 39), PackedStringArray(["OBRAS DEL CARRIL BICI.",
		"Paso provisional por la huerta. Se ruega no pisar las alcachofas."]))
	# Juncos en la orilla de la Albufera y barcas.
	v.tall_grass(Vestidor.rects.call([Rect2i(14, 16, 2, 3), Rect2i(14, 39, 1, 2)]))
	v.object(&"barca_albufera", Vector2i(3, 24), true)
	v.object(&"barca_albufera", Vector2i(9, 34), true)
	v.flowers(Rect2i(30, 39, 3, 1), 0.4)
	v.item("HiperpocionHuerta", &"hyperpotion", Vector2i(36, 18), true)
	v.item("UltraBallSaler", &"ultraball", Vector2i(40, 44))
	v.item("RevivirMarjal", &"revive", Vector2i(3, 47), true)
	await v.refresh()
	# Pinada del Saler y arboleda en lo que queda de hierba lejos de la avenida.
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"pino", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.05, "excluir": [Rect2i(0, 57, 48, 19)]})
