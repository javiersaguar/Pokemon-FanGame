extends RefCounted
## Ruta 7 · Los Monegros (72×34). Desierto de yeso con cerros (mesetas con escalera y hierba alta
## arriba), la laguna de Sariñena con juncos, piedras, tocones y matojos secos; el festival con su
## público, luces y la barra; y un pastor en el cerro grande. Se conservan el escenario, las mesas
## del sur, los carteles, Kike, Vane y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	var R := Vestidor.rects
	# Laguna de Sariñena al nordeste, con juncos y nenúfares.
	v.pond(Rect2i(66, 0, 6, 8), [Vector2i(68, 3), Vector2i(69, 5), Vector2i(67, 6)])
	v.tall_grass(R.call([Rect2i(64, 0, 2, 3), Rect2i(66, 8, 6, 2)]))
	v.item("CuracionLaguna", &"fullheal", Vector2i(70, 9), true)
	# Cerro de yeso del noroeste con escalera.
	v.plateau(Rect2i(0, 0, 7, 10), [2])
	v.tall_grass(R.call([Rect2i(3, 1, 3, 4)]))
	v.item("SuperpocionCerro", &"superpotion", Vector2i(1, 2), true)
	# El cerro grande: un pastor vigila desde arriba.
	v.tall_grass(R.call([Rect2i(21, 1, 4, 3), Rect2i(30, 4, 3, 3)]))
	v.trainer("Pastor", &"ruta7_pastor", Vector2i(29, 2), Vestidor.LEFT, 3)
	# Madera seca y piedras entre el cerro y el festival.
	v.deco(Vector2i(35, 9), ExteriorTiles.STUMP, ExteriorTiles.SRC_GEN4, true)
	v.deco(Vector2i(14, 10), ExteriorTiles.STUMP_CUT, ExteriorTiles.SRC_GEN4, true)
	for at: Vector2i in [Vector2i(16, 11), Vector2i(52, 4)]:
		v.deco(at, ExteriorTiles.LOG_LEFT[0], ExteriorTiles.SRC_GEN4, true)
		v.deco(at + Vector2i.RIGHT, ExteriorTiles.LOG_LEFT[1], ExteriorTiles.SRC_GEN4, true)
	# El festival: luces, barra y público delante del escenario.
	v.object(&"farola_rosa", Vector2i(38, 11), true)
	v.object(&"farola_rosa", Vector2i(51, 11), true)
	v.object(&"sombrilla", Vector2i(53, 13), true)
	v.npc("RaverPublico1", "raver", Vector2i(41, 13), Vestidor.UP, PackedStringArray([
		"¡Llevo tres días sin dormir! El DJ dice que el amanecer es parte del set."]))
	v.npc("RaverPublico2", "raver_f", Vector2i(47, 13), Vestidor.UP, PackedStringArray([
		"Aquí no hay sombra, ni agua, ni cobertura. Pero hay bajo."]))
	v.npc("Camarera", "npc_lass", Vector2i(55, 11), Vestidor.DOWN, PackedStringArray([
		"El agua, a cinco euros. El hielo, a seis. El desierto lo pone gratis la organización."]))
	# Cerro del sudoeste con escalera, hierba alta y un objeto.
	v.plateau(Rect2i(2, 24, 12, 9), [8])
	v.tall_grass(R.call([Rect2i(3, 25, 5, 3), Rect2i(9, 26, 3, 3)]))
	v.item("SuperBallCerro", &"greatball", Vector2i(12, 29))
	# Un cerrito de yeso en medio del sur y otro junto al festival.
	v.plateau(Rect2i(24, 18, 5, 5))
	v.roughen_tall_grass(Rect2i(14, 18, 30, 15), 0.4, "sand")
	v.roughen_tall_grass(Rect2i(54, 2, 12, 9), 0.4, "sand")
	v.roughen_tall_grass(Rect2i(6, 2, 10, 6), 0.4, "sand")
	# Paso obligado: entre dos mesas de yeso (norte y sur) se cruza el matorral (columnas 56-59).
	v.plateau(Rect2i(56, -1, 6, 10))
	v.plateau(Rect2i(56, 24, 6, 10))
	v.grass_band(Rect2i(56, 9, 4, 15))
	await v.refresh()
	# Piedras y matojos secos por todo el desierto, menos el festival y la carretera.
	v.fill({"estilo": "roquedal", "suelo": ["sand"], "densidad": 0.12, "margen": [1, 1], "adornos": 0.0,
		"excluir": [Rect2i(36, 6, 22, 8)]})
