extends RefCounted
## Ruta 16 · Rías Baixas (36×52). De norte a sur: llegada desde la Ruta 17 entre pinares, playa
## con rocas, un paso obligado por hierba alta de orilla a orilla (de la ría al monte), Sanxenxo
## con sus dos casas, jardín y viñedo de albariño, las bateas, un estanque y la bajada a Vigo.
## El monte de Sanxenxo es una meseta con escalera, hierba alta, una ornitóloga y un objeto.
## Se conservan las dos casas, los carteles, Roi, Iria, el bateeiro y las conexiones.

var tree: SceneTree
var hierba_obligada := true

const PLAN := """
TTTTTTTTTTTTTTTT.:::................
TTTTTTTTTTTTTTTT.:::................
TTTTTTTTTTTTTTTTC:::.TT.............
TTTTTTTTTTTTTTTT.:::.TT.............
sssssssssssssss..:::.TT.............
srssssssssrssss..:::.TT.............
sssssssrsssssss..:::.TT.............
sssssssssssssss..:::................
~~~~~~~~~~~~~~f..:::TT..............
~~~~~~~~~~~~~~.f.:::TT..............
~~~~~~~~~~~~~~...:::TT..............
~~~~~~~~~~~~~~f..:::TT..............
~~~~~~~~~~~~~~...:::................
~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,,,,,,
~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,,,,,,
~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,,,,,,
~~~~~~~~~~~~~~...:::................
~~~~~~~~~~~~~~...:::................
~~~~~~~~::C:::::::::TTTTTTHHHH......
~~~~~~~~::::::::::::TTTTTTHHHH......
~~~~~~~~~~~~~~...:::TTTTTTHHHH......
~~~~~~~~~~~~~~...:::TTTTTTHHHH......
~~~~~~~~~~~~~~,,,:::....C.HHHH......
~~~~~~~~~~~~~~,,,:::......HDHH......
~~~~~~~~~~~~~~,,,::::::::::::.......
~~~~~~~~~~~~~~,,,::::::::::::.......
~~~~~~~~~~~~~~,,,:::......P.........
~~~~~~~~~~~~~~,,,:::..........TTTTTT
~~~~~~~~~~~~~~,,,:@:..........TTTTTT
~~~~~~~~~~~~~~,,,:::..........TTTTTT
~~~~~~~~~~~~~~...:::..E.......TTTTTT
~~~~~~~~~~~~~~...:::..........TTTTTT
~~~~~~::::::N:::::::..........HHHHH.
~~~~~~::::::::::::::..........HHHHH.
~~~~~~~~~~~~~~,,,:::..........HHHHH.
~~~~~~~~~~~~~~,,,:::..........HHHHH.
~~~~~~~~~~~~~~,,,:::..........HHHHH.
~~~~~~~~~~~~~~,,,:::...........DHHH.
~~~~~~~~~~~~~~,,,::::::::::::::::...
~~~~~~~~~~~~~~,,,::::::::::::::::...
~~~~~~~~~~~~~~,E,:::....~~~~.TTTTTTT
~~~~~~~~~~~~~~,,,:::....~~~~.TTTTTTT
~~~~~~~~~~~~~~,,,:::....~~~~.,,,,,,,
~~~~~~~~~~~~~~...:::.........,,,,,,,
sssssssssssssss..:::::::::::,,,,,,,,
sssssssssssssss..:::::::::::,,,,,,,,
sssssssssssssss.........::::,,,,,,,,
........................::::,,,,,,,,
TTTTTTTTTTTTTTTT........C:::,,,,,,,,
TTTTTTTTTTTTTTTT........::::,,,,,,,,
TTTTTTTTTTTTTTTT........::::........
TTTTTTTTTTTTTTTT........::::........"""


func vestir(v: Vestidor) -> void:
	var R := Vestidor.rects
	await v.plan(PLAN)
	# El monte de Sanxenxo: meseta con escalera en la columna 26, hierba alta y pinos arriba.
	v.plateau(Rect2i(23, -1, 13, 14), [26])
	v.tall_grass(R.call([Rect2i(24, 2, 5, 6), Rect2i(29, 6, 2, 3)]))
	v.add_forest(Rect2i(30, 0, 6, 4))
	v.add_forest(Rect2i(32, 4, 4, 6))
	v.ledge(23, 35, 16)
	# Jardín de la casa 1 y viñedo de albariño entre las casas.
	v.flowers(Rect2i(30, 18, 5, 4), 0.4)
	v.object(&"manzano", Vector2i(31, 23))
	v.fence(29, 35, 26)
	for y: int in [28, 30, 32, 34]:
		for x: int in range(23, 30):
			v.object(&"cepa_rioja", Vector2i(x, y))
	v.fence(22, 29, 36)
	v.flowers(Rect2i(32, 39, 3, 1), 0.5)
	# La ría: barcas, piedras y una barca varada en la playa del sur.
	v.object(&"barca_albufera", Vector2i(3, 24), true)
	v.object(&"barca_albufera", Vector2i(8, 40), true)
	v.object(&"barca_albufera", Vector2i(2, 14), true)
	v.object(&"barca_albufera", Vector2i(9, 46), true)
	for at: Vector2i in [Vector2i(7, 10), Vector2i(11, 27), Vector2i(1, 36), Vector2i(10, 14), Vector2i(4, 30)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4, true)
	v.object(&"farola_verde", Vector2i(21, 47))
	# Entrenadores, vecina y objetos.
	v.trainer("Xoan", &"ruta16_percebeiro", Vector2i(14, 5), Vestidor.RIGHT, 3)
	v.trainer("Antia", &"ruta16_ornitologa", Vector2i(30, 5), Vestidor.LEFT, 4)
	v.npc("Mariscadora", "npc_old_woman", Vector2i(5, 46), Vestidor.UP, PackedStringArray([
		"Con la marea baja salimos a por almeja. Con la alta, a por un café.",
		"Las bateas dan mejillón para media España. La otra media, en lata."]))
	v.item("Superpocion", &"superpotion", Vector2i(3, 6))
	v.item("RevivirMonte", &"revive", Vector2i(31, 10), true)
	v.item("NidoBallBatea", &"netball", Vector2i(6, 33), true)
	await v.refresh()
	# Lo que queda de hierba lejos del camino, a bosque.
	v.fill({"estilo": "bosque", "margen": [1, 1], "adornos": 0.08, "sueltos": 0.6})
