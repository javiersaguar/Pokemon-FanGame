extends RefCounted
## Ruta 26 · El Torcal de Antequera (48×64). Un laberinto de bloques de caliza (mesetas sin escalera,
## con piedras apiladas encima) que encauza el camino en una secuencia de pasillos: llegada desde
## Despeñaperros, desvío al dolmen y a la casa del guarda, pasillo del oeste con paso obligado por
## hierba, vuelta por el este con un claro de hierba alta y el guarda del paraje en el mirador, y bajada a
## Málaga con un prado al sudoeste y encinas. Se conservan el dolmen, la casa del guarda, los carteles, la guía, la
## escaladora y las conexiones.

var tree: SceneTree
var hierba_obligada := true

const PLAN := """
rrrrrrrrrrrrrrrrrrrrssss::::sssssssrTTTTTTTTTTTT
rrrrrrrrrrrrrrrrrrrrssss:@::sssssssrTTTTTTTTTTTT
rr                  ssss::::sssssssrTTTTTTTTTTTT
rr                  ssss::::sssssssrTTTTTTTTTTTT
rr                  ssss::::sssss       sssssssr
rr                  ssss::::sssss       sssssssr
rr                  ssss::::sssss       sssssssr
rr                  ssss::::sssss       sssssssr
rr                  ssss::::sssss       sssssssr
rr                  ssss::::sssss       sssssssr
rr                  ssss::::::::::::.sssssssssss
rr                  ssss::::.........sssssssssss
sssssssrr.::::::::::::::::::rrrrrrrrrsssssssssss
sssssssrr.:::C::::::::::::.................rssss
sssssssrr............E.........,,,,,,,,,,,.rssss
sssssssssssssssssssssrr:::rr...,,,,,,,,,,,.rssss
sssssssssssssssssssssrr:::ssss.,,,,,,,,,,,.sssss
sssssssssssssssssssssrr:::ssss.,,,,,,,,,,,.sssss
ssssssssssss.:.........:::ssss.............sssss
ssssssssssss.:::::::::::::ssssssss....ssssssssss
ssssssssssss.:.........:::ssssssss....ssssssssss
ssssssssssss.:.rrrrrrsssssssssssss....ssssssssss
ssssssssssss.:.rrrrrrsssssssssssss....ssssssssss
ssssssssssss.:.......sssssssssssss....ssssssssss
ssssssssssss.:..,,,,.sssssssssssss....ssssssssss
ssssssssssss.:..,,,,.sssssssssssss..........ssss
ssssssssssss,,,......sssssssssssss..........ssss
ssssssssssss,,,sssssssssssssssssss..........ssss
ssssssssssss,,,sssssssssssssssssssrr........ssss
ssssssssssss,,,sssssssssssssssssssssssssssssssss
ssssssssssss.:.sssssssssssssssssssssssssssssssss
ssssssssssss.:.sssssssssssssssrrrrssssssssssssss
ssssssssssss.:..................:.ssssssssssssss
ssssssssssss.::::::::::::::::::::.ssssssssssssss
ssssssssssss.:..................:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssssssssssssss.:.ssssssssssssss
sssssssssssssssssssrrrrrrrrrrrr.:.ssssssssssssss
sssssssssssssssssssrrrrrrrrrrrr.:.ssssssssssssss
ssssssssssssssssssssssss.::..E..:.ssssssssssssss
ssssssssssssssssssssssss.::::::::.ssssssssssssss
ssssssssssssssssssssssss.::.....:.ssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
ssssssssssssssssssssssss.::.ssssssssssssssssssss
TTTT.....................::.ssssssssssssTTTTTTTT
TTTT.....................::.ssssssssssssTTTTTTTT
TTTT.....................::.ssssssssssssTTTTTTTT
TTTT..............ssssss.::.ssssssssssssTTTTTTTT
TTTT,,,,,,,,,,,,,.ssssss.::.TTTTTTTTTTTTTTTTTTTT
TTTT,,,,,,,,,,,,,.ssssss.::.TTTTTTTTTTTTTTTTTTTT
TTTT,,,,,,,,,,,,,.ssssss.::.TTTTTTTTTTTTTTTTTTTT
TTTT,,,,,,,,,,,,,.ssssss.::.TTTTTTTTTTTTTTTTTTTT
TTTT,,,,,,,,,,,,,.ssssss.::.TTTTTTTTTTTTTTTTTTTT
TTTT..............ssssss:::.TTTTTTTTTTTTTTTTTTTT
TTTTrrrrrrrrrrrrrrssssss::::TrTTTTTTTTTTTTTTTTTT
TTTTrrrrrrrrrrrrrrssssss::::TTTTTTTTTTTTTTTTTTTT"""

const BLOQUES: Array[Rect2i] = [
	Rect2i(20, 0, 3, 6),
	Rect2i(29, 0, 6, 4),
	Rect2i(28, 4, 5, 6),
	Rect2i(40, 4, 7, 6),
	Rect2i(20, 6, 4, 6),
	Rect2i(37, 10, 7, 3),
	Rect2i(44, 10, 4, 6),
	Rect2i(0, 12, 7, 6),
	Rect2i(6, 16, 6, 2),
	Rect2i(15, 16, 6, 2),
	Rect2i(26, 16, 4, 6),
	Rect2i(43, 16, 5, 6),
	Rect2i(0, 18, 7, 6),
	Rect2i(7, 18, 5, 6),
	Rect2i(30, 19, 4, 6),
	Rect2i(38, 19, 5, 6),
	Rect2i(21, 21, 5, 6),
	Rect2i(26, 22, 4, 6),
	Rect2i(43, 22, 5, 3),
	Rect2i(0, 24, 7, 6),
	Rect2i(7, 24, 5, 6),
	Rect2i(30, 25, 4, 6),
	Rect2i(44, 25, 4, 6),
	Rect2i(15, 27, 7, 5),
	Rect2i(22, 27, 4, 5),
	Rect2i(26, 28, 4, 4),
	Rect2i(34, 29, 7, 6),
	Rect2i(41, 29, 3, 6),
	Rect2i(0, 30, 7, 6),
	Rect2i(7, 30, 5, 6),
	Rect2i(44, 31, 4, 6),
	Rect2i(12, 35, 7, 6),
	Rect2i(19, 35, 7, 6),
	Rect2i(26, 35, 5, 5),
	Rect2i(34, 35, 7, 6),
	Rect2i(41, 35, 3, 6),
	Rect2i(0, 36, 7, 6),
	Rect2i(7, 36, 5, 6),
	Rect2i(44, 37, 4, 6),
	Rect2i(12, 41, 7, 6),
	Rect2i(34, 41, 7, 6),
	Rect2i(41, 41, 3, 6),
	Rect2i(0, 42, 7, 6),
	Rect2i(7, 42, 5, 6),
	Rect2i(19, 43, 5, 6),
	Rect2i(44, 43, 4, 6),
	Rect2i(28, 46, 6, 6),
	Rect2i(12, 47, 7, 5),
	Rect2i(34, 47, 7, 5),
	Rect2i(41, 47, 3, 5),
	Rect2i(0, 48, 7, 4),
	Rect2i(7, 48, 5, 4),
	Rect2i(19, 49, 5, 3),
	Rect2i(44, 49, 4, 3),
	Rect2i(28, 52, 7, 4),
	Rect2i(35, 52, 5, 4),
	Rect2i(18, 55, 5, 6),
	Rect2i(18, 61, 5, 3),
]


func vestir(v: Vestidor) -> void:
	v.remove_objects([&"roca_torcal"], v.bounds)
	v.move("Torcal", Vector2i(23, 15))
	v.move("Sur", Vector2i(24, 61))
	await v.plan(PLAN, Vector2i.ZERO, [&"arbol_redondo", &"arbol_verde"])
	var n := 0
	for r: Rect2i in BLOQUES:
		if not v.plateau(r):
			continue
		n += 1
		# Piedras apiladas encima de uno de cada tres bloques con sitio.
		if n % 3 == 0 and r.size.x >= 4 and r.size.y >= 5:
			v.object(&"roca_torcal", Vector2i(r.position.x + 1, r.end.y - 3))
	# Entrenador, objetos y detalles.
	v.trainer("Guarda", &"ruta26_guarda", Vector2i(42, 26), Vestidor.LEFT, 4)
	v.item("UltraBallMirador", &"ultraball", Vector2i(43, 28))
	v.item("HiperpocionRincon", &"hyperpotion", Vector2i(19, 25), true)
	v.item("MaxiRepelentePrado", &"maxrepel", Vector2i(5, 60), true)
	await v.refresh()
	v.fill({"estilo": "roquedal", "densidad": 0.0, "margen": [1, 1], "adornos": 0.07})
