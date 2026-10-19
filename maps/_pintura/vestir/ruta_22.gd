extends RefCounted
## Ruta 22 · Burgos y Atapuerca (48×64). De los viñedos a Valladolid: la entrada desde La Rioja entre
## pinares, la meseta de los yacimientos de Atapuerca al este (con sus catas, escalera y un objeto en
## lo alto), Burgos al oeste con su plaza empedrada, farolas y bancos, el Arlanzón con juncos y su
## puente, y el prado del sur con chopos, una charca y un paso obligado por hierba de lado a lado.
## Se conservan las casas, sus puertas, la catedral, los carteles, el arqueólogo, el paleontólogo,
## el investigador y las conexiones.

var tree: SceneTree
var hierba_obligada := true

const PLAN := """
TTTTTTTTTTTTTTTTTT....::::...^................^.
TTTTTTTTTTTTTTTTTT....::@:...^................^.
TTTTTTTTTTTTTT........::::...^................^.
TTTTTTTT..............::::...^................^.
TTTTTTTT..............::::...^................^.
TT..YY......YY........::::...^................^.
TT....................::::...^................^.
TT....................::::...^..s#ss.....s#ss.^.
TT....................::::...^..ssss.....ssss.^.
TT....................::::...^................^.
TT....................::::...^................^.
..HHH...........HHH...::::...^..s#ss.....s#ss.^.
.HHHHH.........HHHHH..::::...^..ssss..::.ssss.^.
.HHHHH.........HHHHH..::::...^........::......^.
.HHHHH.........HHHHH..::::...^........::......^.
.HDHH..........HDHH...::::...^..s#ss..::.s#ss.^.
......................::::...^..ssss..::.ssss.^.
......................::::...^........::E.....^.
.____________________.::::...^........::......^.
.____________________.::::...^...N....::......^.
.____________________.::::...^........::......^.
._______________HHH__.::::...^........::......^.
.______________HHHHH_.::::...^^^^^^^^C++^^^^^^^.
._____H__H_____HHHHH_.::::...^^^^^^^^^++^^^^^^^.
._____HHHH_____HHHHH_.::::............::........
._____HHHH_____HDHH__.::::............::........
._____HHDH___________.::::............::........
.____C_______________.::::............::........
.____:::::::::::::::::::::::::::::::::::........
.____:::::::::::::::::::::::::::::::::::........
.____::::::####:::::::::::::::::::::::::........
.___#_______________#.::::......................
.____________________.::::......................
..........,,,,,,,,,...::::..,,,,,,,,,...........
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~::::~~~~~~~~~~~~~~~~~~~~~~
..............,,,,,,,.::::..,,,,,,,.............
......................::::......................
......................::::......................
TTTTTTTTTTTTTT........::::.........TTTTTTTTTTTTT
TTTTTTTTTTTTTT....E...::::.........TTTTTTTTTTTTT
TTTTTTTTTTTTTT........::::.........TTTTTTTTTTTTT
TTTTTTTTTTTTT.........::::.........TTTTTTTTTTTTT
TTTTTTTTTT............::::........TTTTTTTTTTTTTT
TTTTTTTTTT............::::........TTTTTTTTTTTTTT
TTTTTTTTTT............::::........TTTTTTTTTTTTTT
TTTTTTTTTT............::::........TTTTTTTTTTTTTT
TTTTTTTTTT............::::........TTTTTTTTTTTTTT
TTTTTTTTTTTTTT........::::........TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT,,,,,,,,,,,,,,,,,,,,TTTTTTTTTTTTTT
TTTTTTTTTTTTTT........::::........TTTTTTTTTTTTTT
TTTTTTTT..............::::..,,,,,,,,,,..TTTTTTTT
TTTTTTTT..............::::..,,,,,,,,,,..TTTTTTTT
TTTTTTTT..............::::..,,,,,,,,,,..TTTTTTTT
TTTTTTTT..............::::..,,,,,,,,,,..TTTTTTTT
TTTTTTTT..............::::.C,,,,,,,,,,..TTTTTTTT
TTTTTTTT..............::::..............TTTTTTTT
TTTTTTTT..............::::..............TTTTTTTT"""


func vestir(v: Vestidor) -> void:
	await v.plan(PLAN, Vector2i.ZERO, [&"arbol_verde", &"pino"])
	# Burgos: farolas y bancos en la plaza empedrada.
	for at: Vector2i in [Vector2i(2, 18), Vector2i(10, 18), Vector2i(20, 18), Vector2i(2, 31), Vector2i(12, 31)]:
		v.object(&"farola_roja", at)
	v.object(&"banco", Vector2i(11, 20))
	v.object(&"banco", Vector2i(4, 21))
	v.flowers(Rect2i(17, 27, 3, 1), 0.4)
	# Atapuerca: objeto junto a las catas.
	v.item("UltraBallYacimiento", &"ultraball", Vector2i(31, 4))
	# Prado del sur: charca de la ribera y objeto oculto entre los chopos.
	v.pond(Rect2i(10, 57, 6, 4), [Vector2i(12, 58)])
	v.item("RevivirRibera", &"revive", Vector2i(17, 59), true)
	v.item("HiperpocionPinar", &"hyperpotion", Vector2i(15, 43), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"pino", &"arbol_redondo"],
		"hueco": 1, "adornos": 0.06, "excluir": [Rect2i(29, 0, 18, 24), Rect2i(0, 17, 22, 17)]})
