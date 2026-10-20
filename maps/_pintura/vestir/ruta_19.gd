extends RefCounted
## Ruta 19 · Costa cántabra (56×36). De Santander a Bilbao junto al Cantábrico: la playa y el faro en
## su islote al norte, los prados con bordillos, la carretera de la costa, los caseríos al este y el
## bosque atlántico cerrando el sur. Un paso obligado por hierba corta los prados del acantilado al
## bosque. Se conservan el faro, los caseríos, sus puertas, los carteles, los entrenadores, los
## vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba del borde del acantilado al bosque del sur.
	v.grass_band(Rect2i(36, 8, 2, 24))
	# Setos y flores en los prados; piedras en la playa.
	v.hedge(40, 46, 25)
	v.flowers(Rect2i(17, 9, 4, 2), 0.4)
	v.flowers(Rect2i(48, 19, 4, 1), 0.4)
	for at: Vector2i in [Vector2i(3, 8), Vector2i(11, 9), Vector2i(7, 10)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4)
	v.item("HiperpocionPrado", &"hyperpotion", Vector2i(26, 9), true)
	v.item("UltraBallCaserio", &"ultraball", Vector2i(54, 12))
	v.item("RevivirBosque", &"revive", Vector2i(3, 30), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.06})
