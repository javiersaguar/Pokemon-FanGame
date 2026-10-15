extends RefCounted
## Ruta 6 · Medinaceli y Calatayud (72×34). Medinaceli en su cerro con calle empedrada, flores, banco
## y una fuente junto al arco; el páramo con pinares de Soria, piedras y una muela con escalera; campos
## arados al sur, chopos y camino junto al Jalón, y Calatayud con su huerto. Se conservan las casas,
## el arco, la torre, los carteles, Cirilo, Anselmo y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	var R := Vestidor.rects
	# Medinaceli, arriba: calle empedrada desde la escalera, flores, fuente, banco y árboles.
	v.paving_stone(R.call([Rect2i(19, 11, 4, 3), Rect2i(10, 11, 16, 2)]))
	v.flowers(Rect2i(14, 6, 2, 2), 0.4)
	v.flowers(Rect2i(20, 7, 2, 2), 0.4)
	v.object(&"fuente_cano", Vector2i(16, 4))
	v.object(&"arbol_redondo", Vector2i(10, 4))
	v.object(&"arbol_redondo", Vector2i(26, 4))
	v.object(&"banco", Vector2i(20, 4))
	v.add_forest(Rect2i(9, 0, 4, 2))
	v.add_forest(Rect2i(24, 0, 4, 2))
	# El páramo al oeste del cerro: pinar y piedras.
	v.add_forest(Rect2i(0, 6, 8, 8))
	for at: Vector2i in [Vector2i(5, 2), Vector2i(1, 15), Vector2i(6, 16)]:
		v.deco(at, ExteriorTiles.ROCK)
	# La muela del norte, con escalera, hierba alta arriba y una ornitóloga mirando buitres.
	v.plateau(Rect2i(52, 0, 12, 9), [60])
	v.tall_grass(R.call([Rect2i(53, 1, 5, 4)]))
	v.trainer("Paloma", &"ruta6_ornitologa", Vector2i(61, 3), Vestidor.LEFT, 4)
	v.item("SuperpocionMuela", &"superpotion", Vector2i(62, 1), true)
	v.roughen_tall_grass(Rect2i(40, 0, 32, 11), 0.4)
	# Calatayud: huerto con frutal y flores.
	v.object(&"manzano", Vector2i(54, 10))
	v.flowers(Rect2i(57, 9, 2, 2), 0.5)
	# Campos arados al sur de la carretera.
	v.soil(Rect2i(38, 23, 7, 4))
	v.soil(Rect2i(60, 23, 8, 3))
	v.roughen_tall_grass(Rect2i(0, 22, 40, 9), 0.4)
	v.item("SuperBallCampo", &"greatball", Vector2i(64, 24))
	v.item("RepelentePastos", &"repel", Vector2i(8, 26), true)
	# El Jalón: chopos y camino de ribera.
	v.path(R.call([Rect2i(36, 28, 36, 2)]))
	for x: int in [47, 51, 62, 66, 70]:
		v.object(&"arbol_verde", Vector2i(x, 27))
	v.npc("Hortelano", "npc_old_man", Vector2i(48, 29), Vestidor.DOWN, PackedStringArray([
		"El Jalón riega toda la vega. La Dolores no, la Dolores solo cantaba.",
		"En Calatayud hay más torres mudéjares que vecinos jóvenes."]))
	# Paso obligado por hierba: el descampado de las afueras de Calatayud, de la muela al Jalón.
	v.grass_band(Rect2i(54, 9, 4, 21))
	await v.refresh()
	# Pinar en lo que queda de páramo (Medinaceli, arriba, se queda despejado).
	v.fill({"estilo": "bosque", "margen": [1, 1], "sueltos": 0.5, "adornos": 0.07,
		"excluir": [Rect2i(9, 0, 20, 14)]})
