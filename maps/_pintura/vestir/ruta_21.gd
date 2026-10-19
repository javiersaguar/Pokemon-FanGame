extends RefCounted
## Ruta 21 · Viñedos de La Rioja (48×64). De Pamplona a Burgos entre viñas: bosque cerrado en los
## bordes, el Ebro con juncos y su puente, las bodegas del norte con sus cepas, un cerro al este con
## escalera, hierba alta y un mirador, terrazas de viña al oeste, el camino que serpentea hasta las
## bodegas del sur, un paso obligado por hierba al salir del pueblo y viñedos vallados hasta Burgos.
## Se conservan las bodegas, sus puertas y calados, los carteles, el vendimiador, el sumiller, la
## bodeguera y las conexiones.

var tree: SceneTree
var hierba_obligada := true

const PLAN := """
TTTTTTTTTTTT..........::::..........TTTTTTTTTTTT
TTTTTTTTTTTT..........::@:..........TTTTTTTTTTTT
TTTTTTTTTTTT..........::::..........TTTTTTTTTTTT
TTTTTTTTTTTT..........::::..........TTTTTTTTTTTT
TTTTTTTT..............::::..............TTTTTTTT
TTTTTTTT..............::::..............TTTTTTTT
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
TT..............,,,,,.::::.,,,,,..............TT
TT....................::::....................TT
TT........HHH.........::::.......HHH..........TT
TT.......HHHHH........::::......HHHHH.........TT
TT.......HHHHH........::::......HHHHH.........TT
TT.......HHHHH........::::......HHHHH.........TT
TT.......HDHH.........::::......HDHH..........TT
TT....................::::....................TT
TT......::::::N:::::::::::::::::::::::........TT
TT......::::::::::::::::::::::::::::::........TT
TT......::::::::::E::::::::::C::::::::........TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT...............:::::::::....................TT
TT...............:::::::::....................TT
TT...............::::.........................TT
TT...............::::.........................TT
TT...............::::.........................TT
TT...............::::.........................TT
TT...............::::.........................TT
TT........HHH....::::............HH...........TT
TT.......HHHHH...::::...........HHHH..........TT
TT.......HHHHH...::::...........HHHH..........TT
TT.......HHHHH...::::...........HHHH..........TT
TT.......HDHH....::::...........HDHH..........TT
TTYY..........C..::::.....................YY..TT
TT......::::::::::::::::::::::::::::::........TT
TT......:::::::::::::::::::::::E::::::........TT
TT......::::::::::::::::::::::::::::::........TT
TTTTTTTTTTTTTT....................TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT........::::........TTTTTTTTTTTTTT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT....................::::....................TT
TT,,,,,,,,,,,,,,......::::......,,,,,,,,,,,,,,TT
TT,,,,,,,,,,,,,,......::::......,,,,,,,,,,,,,,TT
TT,,,,,,,,,,,,,,......::::......,,,,,,,,,,,,,,TT
TT,,,,,,,,,,,,,,......::::......,,,,,,,,,,,,,,TT
TT,,,,,,,,,,,,,,......::::.C....,,,,,,,,,,,,,,TT
TT....................::::....................TT"""


func vestir(v: Vestidor) -> void:
	var R := Vestidor.rects
	await v.plan(PLAN, Vector2i.ZERO, [&"arbol_verde", &"arbol_redondo"])
	# Cerro de San Vicente al este: meseta con escalera, hierba alta y un mirador sobre el Ebro.
	v.plateau(Rect2i(30, 23, 14, 8), [36])
	v.tall_grass(R.call([Rect2i(31, 23, 5, 3), Rect2i(39, 23, 3, 4)]))
	v.object(&"banco", Vector2i(34, 27))
	v.item("SuperBallCerro", &"greatball", Vector2i(41, 28))
	# Viñas de las bodegas del norte, a los lados de cada bodega.
	for y: int in [12, 14]:
		for x: int in range(3, 8):
			v.object(&"cepa_rioja", Vector2i(x, y))
		for x: int in range(15, 20):
			v.object(&"cepa_rioja", Vector2i(x, y))
		for x: int in range(28, 31):
			v.object(&"cepa_rioja", Vector2i(x, y))
		for x: int in range(39, 45):
			v.object(&"cepa_rioja", Vector2i(x, y))
	# Terrazas de viña al oeste, con bordillos que se saltan hacia el sur.
	for y: int in [22, 24, 30, 32]:
		for x: int in range(3, 15):
			if x % 4 != 2:
				v.object(&"cepa_rioja", Vector2i(x, y))
	v.ledge(2, 15, 26)
	v.item("HiperpocionTerraza", &"hyperpotion", Vector2i(13, 28), true)
	v.fence(26, 27, 33)
	# Viñedos vallados del sur hasta la bajada a Burgos.
	for y: int in [50, 52, 54, 56]:
		for x: int in range(3, 20):
			if x % 5 != 0:
				v.object(&"cepa_rioja", Vector2i(x, y))
		for x: int in range(28, 45):
			if x % 5 != 0:
				v.object(&"cepa_rioja", Vector2i(x, y))
	v.fence(2, 20, 49)
	v.fence(27, 45, 49)
	v.item("RevivirVina", &"revive", Vector2i(30, 53), true)
	v.flowers(Rect2i(26, 0, 3, 2), 0.4)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"arbol_redondo", &"pino"],
		"hueco": 1, "adornos": 0.06})
