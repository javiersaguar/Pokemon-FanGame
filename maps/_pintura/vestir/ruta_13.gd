extends RefCounted
## Ruta 13 · Olivares del Guadalquivir (76×46). De Sevilla hacia el este entre olivos en hilera: el
## cortijo y su era al oeste, el camino real que cruza el olivar, el Guadalquivir con su puente y la
## vega del sur. Un paso de hierba alta entre dos hileras de olivos cierra el olivar de norte a sur, del
## bosque al río. Se conservan los olivos, el cortijo, sus puertas, los carteles, los entrenadores, los
## vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba entre dos hileras de olivos, del bosque del norte a la orilla del río.
	v.grass_band(Rect2i(34, 2, 2, 28))
	# Juncos en la orilla norte del Guadalquivir y flores en la vega.
	v.tall_grass(Vestidor.rects.call([Rect2i(22, 29, 6, 1), Rect2i(44, 29, 8, 1)]))
	v.flowers(Rect2i(3, 38, 4, 2), 0.4)
	v.flowers(Rect2i(20, 39, 5, 1), 0.4)
	v.item("HiperpocionOlivar", &"hyperpotion", Vector2i(40, 9), true)
	v.item("UltraBallVega", &"ultraball", Vector2i(26, 40))
	v.item("RevivirCortijo", &"revive", Vector2i(70, 3), true)
	await v.refresh()
