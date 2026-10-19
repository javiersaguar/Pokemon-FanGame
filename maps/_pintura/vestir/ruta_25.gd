extends RefCounted
## Ruta 25 · Despeñaperros (48×64). El paso de Sierra Morena: el embalse con su presa al noroeste,
## la garganta encajada entre dos riscos (el del oeste con escalera abajo y el de los Órganos al este,
## con su escalera al sur), un paso obligado por hierba en lo más estrecho de la garganta, pinares y
## encinas cerrando las laderas, roquedo en lo alto de los riscos y la bajada hacia el Torcal. Se
## conservan la presa, la casa, sus puertas, los carteles, los entrenadores y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en lo más estrecho de la garganta (entre los dos riscos).
	v.grass_band(Rect2i(19, 44, 18, 2))
	# Juncos en la orilla del embalse y piedras sueltas en la garganta.
	v.tall_grass(Vestidor.rects.call([Rect2i(16, 4, 3, 2), Rect2i(16, 9, 3, 2)]))
	for at: Vector2i in [Vector2i(33, 29), Vector2i(19, 36), Vector2i(35, 40), Vector2i(29, 57)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4)
	v.item("HiperpocionPresa", &"hyperpotion", Vector2i(3, 21), true)
	v.item("UltraBallOrganos", &"ultraball", Vector2i(44, 30))
	v.item("RevivirLadera", &"revive", Vector2i(6, 44), true)
	await v.refresh()
	# Pinares y encinas en las laderas; roquedo en lo alto de los riscos de los Órganos.
	v.fill({"estilo": "roquedal", "zona": Rect2i(38, 13, 10, 33), "densidad": 0.06, "margen": [1, 1], "adornos": 0.08})
	v.fill({"estilo": "bosque", "margen": [1, 1], "adornos": 0.06, "sueltos": 0.5,
		"excluir": [Rect2i(38, 13, 10, 33)]})
