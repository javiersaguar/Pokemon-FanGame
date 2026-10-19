extends RefCounted
## Ruta 24 · La Mancha (48×64). De Getafe a Puertollano por la llanura: un paso obligado por hierba
## nada más salir de Getafe (de la loma de Consuegra al linde del este), el cerro de los molinos al
## noroeste con su escalera, olivares y encinas en lugar de bosque cerrado, campos vallados con sus
## surcos, tapias de piedra seca y flores de campo. Se conservan los molinos, las casas, sus puertas,
## los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba a la salida de Getafe: de la loma de los molinos (columna 20) al borde
	# del este, sobre el camino.
	v.grass_band(Rect2i(21, 6, 27, 2))
	# Campos vallados: los surcos del oeste y del sureste quedan dentro de su tapia.
	v.fence(2, 19, 31)
	v.fence(2, 19, 43)
	v.fence(32, 44, 42)
	v.fence(32, 44, 56)
	# Flores de campo y alguna encina suelta junto al camino.
	v.flowers(Rect2i(29, 26, 3, 2), 0.3)
	v.flowers(Rect2i(19, 44, 3, 1), 0.3)
	v.flowers(Rect2i(8, 52, 4, 1), 0.3)
	v.item("HiperpocionMolinos", &"hyperpotion", Vector2i(10, 15), true)
	v.item("UltraBallOlivar", &"ultraball", Vector2i(44, 21))
	v.item("MaxiRepelenteCampo", &"maxrepel", Vector2i(15, 48), true)
	await v.refresh()
	# Olivares y encinas en hileras (no bosque cerrado: es la llanura manchega).
	v.fill({"estilo": "hileras", "margen": [1, 1], "arboles": [&"arbol_redondo"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(0, 0, 21, 22)]})
