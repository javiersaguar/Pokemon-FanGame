extends RefCounted
## Ruta 10 · Costa Blanca (60×64). De la Albufera a Alicante por la costa: la huerta al norte, el pueblo
## de la meseta con su escalera, el paseo de Benidorm entre torres, la playa y el mar al este, y un
## paso obligado por hierba de lado a lado al salir del paseo hacia Alicante. Palmeras en lugar de
## bosque cerrado. Se conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y
## las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba al salir del paseo: del pinar del oeste a la arena.
	v.grass_band(Rect2i(4, 53, 40, 2))
	v.flowers(Rect2i(30, 28, 4, 1), 0.4)
	v.flowers(Rect2i(5, 63, 4, 1), 0.4)
	v.item("HiperpocionHuerta10", &"hyperpotion", Vector2i(7, 10), true)
	v.item("UltraBallPlaya", &"ultraball", Vector2i(40, 20))
	v.item("RevivirMeseta", &"revive", Vector2i(6, 17), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"palmera", &"pino"], "hueco": 2,
		"adornos": 0.05, "excluir": [Rect2i(4, 29, 34, 23)]})
