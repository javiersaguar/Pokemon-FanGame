extends RefCounted
## Ruta 12 · Sierra Nevada y la Alpujarra (72×40). De los olivares de Sevilla a Murcia al pie de la
## sierra: las cumbres nevadas en su meseta con escaleras al norte, el pueblo blanco de la Alpujarra al
## oeste, la carretera del valle y el pinar cerrando el sur. Un paso obligado por hierba corta el valle
## del muro de la sierra al pinar. Se conservan las casas, sus puertas, los carteles, los entrenadores,
## los vecinos y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba de la falda de la sierra al pinar del sur.
	v.grass_band(Rect2i(44, 22, 2, 14))
	v.flowers(Rect2i(3, 6, 4, 2), 0.4)
	v.flowers(Rect2i(54, 16, 3, 1), 0.4)
	for at: Vector2i in [Vector2i(21, 34), Vector2i(38, 31), Vector2i(57, 35)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4)
	v.item("HiperpocionCumbre", &"hyperpotion", Vector2i(41, 2), true)
	v.item("UltraBallValle", &"ultraball", Vector2i(66, 4))
	v.item("RevivirPinar12", &"revive", Vector2i(12, 34), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"pino", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.06, "excluir": [Rect2i(18, 0, 34, 22)]})


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.bolsa(v, "RocaGolpeSierra", "rock_smash", Vector2i(21, 33), "RevivirSierra", &"revive")
	await v.refresh()
