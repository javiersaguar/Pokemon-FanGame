extends RefCounted
## Ruta 23 · Cuéllar y el regreso a San Miguel (64×40). De Valladolid a San Miguel de Bernuy por la
## tierra de pinares: Cuéllar amurallado en su cerro al noroeste, el pinar cerrado al norte y al sur,
## las casas de labor junto a la carretera, los pastos con hierba alta y un paso obligado por hierba
## del pinar del norte al del sur antes de llegar al pueblo. Se conservan la muralla, el castillo, las
## casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba de pinar a pinar, cruzando la carretera antes de San Miguel.
	v.grass_band(Rect2i(55, 14, 2, 15))
	# Pinar de Cuéllar: el bosque baja hasta la carretera al este de la muralla.
	v.add_forest(Rect2i(26, 0, 6, 2))
	v.flowers(Rect2i(10, 28, 4, 1), 0.4)
	v.flowers(Rect2i(26, 27, 3, 1), 0.4)
	v.item("HiperpocionPinar23", &"hyperpotion", Vector2i(60, 15), true)
	v.item("UltraBallPastos", &"ultraball", Vector2i(44, 26))
	v.item("RevivirMuralla", &"revive", Vector2i(1, 3), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"pino"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(3, 2, 23, 16)]})
