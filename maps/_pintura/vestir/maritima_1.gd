extends RefCounted
## Ruta marítima 1 · De Mallorca a Ibiza (48×64). Mar abierto con tres islotes: Dragonera al norte,
## el islote del faro en medio y Es Vedrà al sur. Se les ponen palmeras y piedras, y un objeto oculto en
## Dragonera (los otros dos islotes solo se pisan con Surf y el comprobador de alcance va a pie). No lleva paso de hierba (es agua). Se conservan el faro, los carteles, el entrenador y las
## conexiones.

var tree: SceneTree
var hierba_obligada := false
## Con Surf: el agua cuenta como libre al comprobar a dónde se llega.
var con_surf := true


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
func vestir_segunda(v: Vestidor) -> void:
	for at: Vector2i in [Vector2i(4, 10), Vector2i(13, 13), Vector2i(36, 27), Vector2i(27, 34), Vector2i(10, 46), Vector2i(14, 44)]:
		v.deco(at, ExteriorTiles.ROCK, ExteriorTiles.SRC_GEN4)
	await v.refresh()


## Tercera pasada (2026-10-20): corrientes (SurfCurrent) y escollos (rocas del mar de 2×2 que chocan).
## - Camino: la «corriente de bajada» lleva de la entrada de Palma (24,0) al velero y al faro, entre
##   dos hileras de escollos; desde el faro se sigue a mar abierto hacia Ibiza, entre Es Vedrà y el
##   islote del sur.
## - Premio fuera del camino: una cala cerrada por escollos en el sureste, con un PP Máx. Solo se entra
##   por la corriente que baja pegada al borde este (desde la altura del faro) y solo se sale por el
##   hueco del oeste, donde otra corriente empuja hacia fuera (por ahí no se puede entrar).
## - La corriente del canal, al sur del faro, empuja hacia el islote del sur.
func vestir(v: Vestidor) -> void:
	v.current(Rect2i(22, 6, 2, 20), Vector2i.DOWN)
	for at: Vector2i in [Vector2i(19, 8), Vector2i(26, 11), Vector2i(19, 15), Vector2i(26, 18), Vector2i(19, 22)]:
		v.reef(at)
	# Cala del sureste: muro norte (con la corriente de entrada), muro oeste (con el hueco de salida) y
	# muro sur; el este es el borde del mapa.
	v.current(Rect2i(44, 30, 2, 14), Vector2i.DOWN)
	for at: Vector2i in [Vector2i(40, 42), Vector2i(42, 42), Vector2i(46, 42), Vector2i(40, 44), Vector2i(40, 47),
			Vector2i(40, 49), Vector2i(42, 49), Vector2i(44, 49), Vector2i(46, 49)]:
		v.reef(at)
	v.current(Rect2i(38, 46, 4, 1), Vector2i.LEFT)
	v.item("PPMaxCala", &"ppmax", Vector2i(46, 47))
	# Canal del faro hacia el islote del sur.
	v.current(Rect2i(15, 38, 16, 2), Vector2i.LEFT)
	for at: Vector2i in [Vector2i(17, 35), Vector2i(24, 41), Vector2i(29, 49), Vector2i(20, 53), Vector2i(4, 30),
			Vector2i(38, 9), Vector2i(42, 22), Vector2i(6, 56)]:
		v.reef(at)
	v.sign("CartelCorrientes", Vector2i(35, 31), PackedStringArray([
		"FARO DE LA RUTA MARÍTIMA 1",
		"¡Ojo, navegantes! Al este baja una corriente pegada a la costa.",
		"Dicen que acaba en una cala entre escollos.",
	]))
	await v.refresh()
