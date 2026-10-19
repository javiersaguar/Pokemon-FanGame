extends RefCounted
## Ruta 11 · Palmeral de Elche (76×34). De Alicante a Murcia por la carretera de Elche: el palmeral al
## norte, los huertos vallados al este con su balsa de riego, el casco de Elche al sur y un paso
## obligado por hierba donde la carretera cruza el huerto (cerrado al norte por la tapia del huerto y
## al sur por la balsa). Palmeras en lugar de bosque. Se conservan las casas, sus puertas, los
## carteles, Carmen, Sergio, Pencho, la aparadora, el palmerero, la huertana y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# El camino del huerto cruza la carretera: la hierba crece de lado a lado.
	v.grass_band(Rect2i(62, 15, 4, 7))
	# Tapias del huerto al norte y al sur de la balsa: no se rodea el paso de hierba.
	v.fence_v(64, 0, 14)
	v.fence_v(64, 22, 22)
	v.fence_v(64, 31, 33)
	# Huertos vallados del norte, con su palmera de linde.
	v.fence(0, 7, 2)
	v.fence(59, 72, 2)
	v.flowers(Rect2i(72, 31, 3, 2), 0.4)
	v.item("HiperpocionPalmeral", &"hyperpotion", Vector2i(41, 11), true)
	v.item("UltraBallHuerto", &"ultraball", Vector2i(70, 6))
	v.item("RevivirBalsa", &"revive", Vector2i(73, 27), true)
	await v.refresh()
	# Palmeras sueltas en lo que queda de hierba, lejos de la carretera.
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"palmera"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(8, 20, 50, 12)]})
