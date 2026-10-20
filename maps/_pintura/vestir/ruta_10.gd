extends RefCounted
## Ruta 10 · Costa Blanca (60×64). De la Albufera a Alicante por la costa: la huerta al norte, el pueblo
## de la meseta con su escalera, el paseo de Benidorm entre torres, la playa y el mar al este, y un
## paso obligado por hierba de lado a lado al salir del paseo hacia Alicante. Palmeras en lugar de
## bosque cerrado. Se conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y
## las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada.
func vestir_inicial(v: Vestidor) -> void:
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

## Segunda pasada (2026-10-20): el paseo empedrado recto pasa a ser un camino de tierra que va de un
## lado a otro entre palmeras y pinos, al norte del pueblo y al sur del paso de hierba. El paseo del
## pueblo (filas 29-51) se queda.
func vestir(v: Vestidor) -> void:
	await Ruta.romper_avenida(v, Rect2i(25, 2, 4, 27), 9)
	await Ruta.romper_avenida(v, Rect2i(25, 55, 4, 9), 5)
	v.flowers(Rect2i(27, 16, 2, 1), 0.3)
	v.item("PolvoEstelarPaseo", &"stardust", Vector2i(28, 6), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "zona": Rect2i(24, 2, 6, 27), "margen": [1, 1], "arboles": [&"palmera", &"pino"], "hueco": 2, "adornos": 0.08})
