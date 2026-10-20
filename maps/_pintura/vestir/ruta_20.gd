extends RefCounted
## Ruta 20 · Valles de Navarra (48×56). De Bilbao a Pamplona por los valles: el hayedo cerrado a los
## lados, el caserío del norte, la carretera que baja entre prados con hierba alta, el bosque del sur y
## un paso obligado por hierba en la garganta del bosque antes de Pamplona. Se conservan el caserío,
## sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en la garganta del bosque antes de Pamplona.
	v.grass_band(Rect2i(28, 49, 8, 2))
	v.fence(0, 9, 31)
	v.flowers(Rect2i(2, 12, 4, 2), 0.4)
	v.flowers(Rect2i(40, 31, 4, 1), 0.4)
	v.item("HiperpocionHayedo", &"hyperpotion", Vector2i(22, 1), true)
	v.item("UltraBallPrado20", &"ultraball", Vector2i(46, 44))
	v.item("RevivirValle", &"revive", Vector2i(1, 46), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.06})
