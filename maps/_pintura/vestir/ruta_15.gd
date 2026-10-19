extends RefCounted
## Ruta 15 · Costa de Gran Canaria (36×72). De Las Palmas a Playa del Inglés junto al mar: la playa y
## las calas al este, el barranco con su meseta y escalera al oeste, la charca de la costa, palmeras
## y roquedo volcánico en lugar de bosque, y un paso obligado por hierba de la ladera a la arena, a
## media ruta. Se conservan las casas, sus puertas, los carteles, los entrenadores y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba de lado a lado: de la ladera del barranco a la playa.
	v.grass_band(Rect2i(0, 44, 28, 2))
	# Roquedo volcánico en la playa y junto a la charca.
	for at: Vector2i in [Vector2i(24, 4), Vector2i(26, 13), Vector2i(23, 33), Vector2i(27, 52), Vector2i(14, 49)]:
		v.deco(at, ExteriorTiles.ROCK_BROWN, ExteriorTiles.SRC_GEN4)
	v.flowers(Rect2i(15, 36, 2, 1), 0.3)
	v.item("HiperpocionBarranco", &"hyperpotion", Vector2i(2, 30), true)
	v.item("UltraBallCala", &"ultraball", Vector2i(26, 46))
	v.item("RevivirCharca", &"revive", Vector2i(21, 51), true)
	await v.refresh()
	# Palmeras y roquedo volcánico en lo que queda de hierba (no hay bosque de pinos en la costa).
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"palmera"], "hueco": 2, "adornos": 0.04})
	v.fill({"estilo": "roquedal", "densidad": 0.05, "margen": [1, 1], "adornos": 0.0})
