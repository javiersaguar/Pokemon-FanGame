extends RefCounted
## Ruta marítima 1 · De Mallorca a Ibiza (48×64). Mar abierto con tres islotes: Dragonera al norte,
## el islote del faro en medio y Es Vedrà al sur. Se les ponen palmeras y piedras, y un objeto oculto en
## Dragonera (los otros dos islotes solo se pisan con Surf y el comprobador de alcance va a pie). No lleva paso de hierba (es agua). Se conservan el faro, los carteles, el entrenador y las
## conexiones.

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	for at: Vector2i in [Vector2i(5, 8), Vector2i(11, 12), Vector2i(34, 28), Vector2i(29, 33), Vector2i(12, 45)]:
		v.deco(at, ExteriorTiles.ROCK_BROWN, ExteriorTiles.SRC_GEN4)
	v.object(&"palmera", Vector2i(7, 9))
	v.object(&"palmera", Vector2i(32, 29))
	v.item("UltraBallDragonera", &"ultraball", Vector2i(9, 11), true)
	await v.refresh()
