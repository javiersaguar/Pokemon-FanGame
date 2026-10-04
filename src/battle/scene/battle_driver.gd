class_name BattleDriver
extends RefCounted
## Lo que la BattleScene necesita del combate. Hoy lo implementa FakeBattle;
## cuando exista el BattleEngine del Agente 2, lo implementará un adaptador.
##
## Eventos: Dictionary (u objeto con propiedades) con `type` y estos campos.
## `side` es &"player" o &"foe"; `pokemon` es un resumen (ver pokemon_summary()).
##   message      {text}
##   send_out     {side, pokemon, wild: bool}
##   withdraw     {side}
##   move         {side, target, move: {id, name, type, category}}
##   damage       {side, hp, effectiveness: float, critical: bool}
##   heal         {side, hp}
##   status       {side, status}
##   stat_change  {side, stat, stages}
##   faint        {side}
##   exp          {side, exp: float 0–1}
##   level_up     {side, level, hp, max_hp}
##   ball         {ball, shakes: int, caught: bool}
##
## Resumen de un Pokémon: {species, name, level, gender, hp, max_hp, status,
## shiny, types, exp (0–1), able: bool, moves: [{id, name, type, category, pp, max_pp}]}

const PLAYER := &"player"
const FOE := &"foe"


## {kind: &"wild" | &"trainer", trainer: Dictionary (TrainerData.get_trainer),
##  background: StringName, bgm: StringName, can_run: bool, can_lose: bool}
func info() -> Dictionary:
	return {}


## Eventos del principio del combate (los send_out).
func start() -> Array:
	return []


## Resuelve un turno con la acción del jugador:
## {type: &"fight", move_slot} · {type: &"item", item} · {type: &"switch", party_index} · {type: &"run"}
func submit(_action: Dictionary) -> Array:
	return []


## true si el jugador tiene que sacar otro Pokémon (el suyo se ha debilitado).
func needs_switch() -> bool:
	return false


func submit_switch(_party_index: int) -> Array:
	return []


func is_over() -> bool:
	return true


## Uno de los SceneManager.OUTCOME_*.
func outcome() -> StringName:
	return &"win"


func player_active() -> Dictionary:
	return {}


func player_party() -> Array[Dictionary]:
	return []


## Objetos que se pueden usar en combate: [{id, name, count}].
func battle_items() -> Array[Dictionary]:
	return []
