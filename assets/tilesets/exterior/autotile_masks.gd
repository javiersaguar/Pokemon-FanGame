class_name AutotileMasks
extends RefCounted
## Los 47 casos de un autotile (según qué vecinos son del mismo terreno) y de qué
## piezas de 16 px de una hoja de autotile de RMXP (96×128) se compone cada uno.
## Bits del caso: N=1, NE=2, E=4, SE=8, S=16, SO=32, O=64, NO=128. Una esquina solo
## cuenta si sus dos lados también son del terreno.

const N := 1
const NE := 2
const E := 4
const SE := 8
const S := 16
const SW := 32
const W := 64
const NW := 128


## Los 47 casos distintos, ordenados.
static func all() -> Array[int]:
	var seen := {}
	for raw: int in 256:
		seen[normalize(raw)] = true
	var out: Array[int] = []
	for mask: int in seen:
		out.append(mask)
	out.sort()
	return out


static func normalize(mask: int) -> int:
	if not (mask & N and mask & E):
		mask &= ~NE
	if not (mask & S and mask & E):
		mask &= ~SE
	if not (mask & S and mask & W):
		mask &= ~SW
	if not (mask & N and mask & W):
		mask &= ~NW
	return mask


## Piezas (en unidades de 16 px dentro de la hoja de RMXP) de los cuartos
## [NO, NE, SO, SE] de la casilla.
static func quarters(mask: int) -> Array[Vector2i]:
	return [
		_quarter(mask & N, mask & W, mask & NW, Vector2i(2, 4), Vector2i(4, 0), Vector2i(0, 4), Vector2i(2, 2), Vector2i(0, 2)),
		_quarter(mask & N, mask & E, mask & NE, Vector2i(3, 4), Vector2i(5, 0), Vector2i(5, 4), Vector2i(3, 2), Vector2i(5, 2)),
		_quarter(mask & S, mask & W, mask & SW, Vector2i(2, 5), Vector2i(4, 1), Vector2i(0, 5), Vector2i(2, 7), Vector2i(0, 7)),
		_quarter(mask & S, mask & E, mask & SE, Vector2i(3, 5), Vector2i(5, 1), Vector2i(5, 5), Vector2i(3, 7), Vector2i(5, 7)),
	]


## vertical/horizontal/diagonal: si el vecino de arriba-abajo, el del lado y el de
## la esquina son del terreno. Piezas: centro, esquina interior, borde lateral
## (vertical sí, lado no), borde de arriba/abajo (vertical no, lado sí) y esquina.
static func _quarter(vertical: int, side: int, diagonal: int, center: Vector2i, inner: Vector2i,
		side_edge: Vector2i, top_edge: Vector2i, corner: Vector2i) -> Vector2i:
	if vertical and side:
		return center if diagonal else inner
	if vertical:
		return side_edge
	if side:
		return top_edge
	return corner


## Vecinos de Godot (TileSet.CellNeighbor) que son del terreno en este caso.
static func peering(mask: int) -> Array[int]:
	var out: Array[int] = []
	var pairs := {
		N: TileSet.CELL_NEIGHBOR_TOP_SIDE, NE: TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
		E: TileSet.CELL_NEIGHBOR_RIGHT_SIDE, SE: TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		S: TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, SW: TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		W: TileSet.CELL_NEIGHBOR_LEFT_SIDE, NW: TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	}
	for bit: int in pairs:
		if mask & bit:
			out.append(pairs[bit])
	return out
