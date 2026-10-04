class_name BattleDriver
extends RefCounted
## Lo que la BattleScene necesita del combate. Hoy lo implementa FakeBattle;
## cuando exista el BattleEngine del Agente 2, lo implementará un adaptador.
##
## Los eventos tienen el formato de BattleEvent (contratos.md §8.5): `type`,
## `side` (0 = jugador, 1 = rival), `slot` y `data`. Pueden ser BattleEvent o
## Dictionary con esas claves. La escena ignora los tipos que no conoce.

const PLAYER := 0
const FOE := 1

## Lo que tiene que decidir el jugador (como BattleRequest):
## {kind: &"action" | &"switch" | &"learn_move", party_index, move_id, move_name, can_run}
const REQUEST_ACTION := &"action"
const REQUEST_SWITCH := &"switch"
const REQUEST_LEARN_MOVE := &"learn_move"


## {kind: &"wild" | &"trainer", trainers: Array[Dictionary] (como BattleSetup.trainers),
##  background: StringName, bgm: StringName, can_run: bool, can_lose: bool}
func info() -> Dictionary:
	return {}


## Eventos hasta la primera decisión.
func start() -> Array:
	return []


func request() -> Dictionary:
	return {"kind": REQUEST_ACTION}


## Resuelve hasta la siguiente decisión. Acciones:
## {type: &"fight", move_slot} · {type: &"item", item} · {type: &"switch", party_index}
## · {type: &"run"} · {type: &"learn_move", forget_index}
func submit(_action: Dictionary) -> Array:
	return []


func is_over() -> bool:
	return true


## Uno de los SceneManager.OUTCOME_*.
func outcome() -> StringName:
	return &"win"


## Aplica el resultado a la partida (dinero, captura, Pokédex). Lo llama la escena al final.
func finish() -> void:
	pass


## Para los menús: el Pokémon activo del jugador.
## {name, level, hp, max_hp, moves: [{id, name, type, category, pp, max_pp}]}
func player_active() -> Dictionary:
	return {}


## Para el menú de equipo: [{name, level, hp, max_hp, able: bool, active: bool}].
func player_party() -> Array[Dictionary]:
	return []


## Objetos que se pueden usar en combate: [{id, name, count}].
func battle_items() -> Array[Dictionary]:
	return []
