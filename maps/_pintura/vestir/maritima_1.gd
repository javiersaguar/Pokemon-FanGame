extends RefCounted
## Ruta marítima 1 · De Mallorca a Ibiza (48×64). Mar abierto con tres islotes: Dragonera al norte,
## el islote del faro en medio y Es Vedrà al sur. Se les ponen palmeras y piedras, y un objeto oculto en
## Dragonera (los otros dos islotes solo se pisan con Surf y el comprobador de alcance va a pie). No lleva paso de hierba (es agua). Se conservan el faro, los carteles, el entrenador y las
## conexiones.

var tree: SceneTree
var hierba_obligada := false


## Primera pasada (2026-10-19), ya aplicada.
func vestir_inicial(v: Vestidor) -> void:
	for at: Vector2i in [Vector2i(5, 8), Vector2i(11, 12), Vector2i(34, 28), Vector2i(29, 33), Vector2i(12, 45)]:
		v.deco(at, ExteriorTiles.ROCK_BROWN, ExteriorTiles.SRC_GEN4)
	v.object(&"palmera", Vector2i(7, 9))
	v.object(&"palmera", Vector2i(32, 29))
	v.item("UltraBallDragonera", &"ultraball", Vector2i(9, 11), true)
	await v.refresh()


## Segunda pasada (2026-10-20): escollos en el canal, junto a los islotes, para que el mar no sea una
## lámina vacía. Las corrientes y las reglas de Surf de los escollos se han pedido al agente de combate
## (docs/mapas/reservas.md, «Peticiones a Combate»).
func vestir(v: Vestidor) -> void:
	for at: Vector2i in [Vector2i(4, 10), Vector2i(13, 13), Vector2i(36, 27), Vector2i(27, 34), Vector2i(10, 46), Vector2i(14, 44)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4)
	await v.refresh()
