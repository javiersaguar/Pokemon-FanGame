class_name BattleEffect
extends RefCounted
## Efecto de combate con script (Fase 9.1): un movimiento especial, un estado volátil, una condición
## de bando o del campo (clima, campo)... Cada script hereda de aquí y SOLO implementa los hooks que
## necesita; el motor (BattleEngine) los llama en su momento. Todo es lógica pura: sin nodos ni await,
## y la aleatoriedad sale siempre de `engine.rng`.
##
## Dónde va cada uno (Effects los encuentra por su id):
##   src/battle/effects/moves/<id>.gd        movimientos
##   src/battle/effects/conditions/<id>.gd   volátiles, condiciones de bando, climas y campos
##
## El estado de una condición activa es un Dictionary (`state`) con al menos {"id", "turns"}; vive en
## Battler.volatiles, BattleSide.conditions o BattleEngine.field.

## Para on_hit(): seguir aplicando los efectos que vienen en los datos del movimiento.
const CONTINUE := 0
## Para on_hit(): el script lo ha resuelto todo (no se aplican los efectos de los datos).
const HANDLED := 1

## Lo rellena Effects al cargar el script.
var id: StringName = &""


# --- Movimientos ---

## Antes de nada (tras "¡X usó Y!"): false = el movimiento falla (el script muestra el mensaje).
func on_try_move(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> bool:
	return true


## Movimientos de dos turnos: true si este turno solo carga (el script muestra el mensaje).
func charge_turn(_engine: BattleEngine, _user: Battler, _move: MoveData) -> bool:
	return false


## Precisión (0 = no falla nunca; -1 = la de los datos).
func accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	return -1


## Potencia base para este golpe.
func base_power(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power


## Daño fijo (Superdiente, Esfuerzo...). -1 = fórmula normal.
func fixed_damage(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	return -1


## Movimientos de estado: efecto propio. Devuelve CONTINUE o HANDLED.
func on_hit(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	return CONTINUE


## Después de que un movimiento de daño haya golpeado (`damage` = daño total hecho).
func on_after_hit(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	pass


## Después de usar el movimiento, haya acertado o no (bloqueos de Golpe, Alboroto...).
func on_after_move(_engine: BattleEngine, _user: Battler, _move: MoveData, _hit: bool) -> void:
	pass


## Persecución: se usa antes de que el objetivo se retire.
func runs_before_switch() -> bool:
	return false


## Protección y similares: usarlos seguidos es cada vez menos probable.
func is_stalling_move() -> bool:
	return false


# --- Condiciones (volátiles, de bando y del campo) ---

## Turnos que dura (0 = hasta que se quite). Se descuenta al final de cada turno.
func duration(_engine: BattleEngine) -> int:
	return 0


## Orden al final del turno (menor = antes), como en los juegos.
func residual_order() -> int:
	return 50


## Al ponerse. false = no se pone (el script muestra el mensaje).
func on_start(_engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	return true


## Al quitarse (por tiempo o porque se elimina).
func on_end(_engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	pass


## Final del turno. `holder` es el Battler, el BattleSide o null (campo).
func on_residual(_engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	pass


## Prioridad en on_before_move (mayor = antes), como en Showdown.
func before_move_priority() -> int:
	return 0


## Antes de moverse el que la tiene. false = no se mueve este turno.
func on_before_move(_engine: BattleEngine, _battler: Battler, _state: Dictionary, _move: MoveData) -> bool:
	return true


## Contra el que la tiene: false = el movimiento no le afecta (Protección, estar en el aire...).
func on_try_hit(_engine: BattleEngine, _target: Battler, _state: Dictionary, _user: Battler, _move: MoveData) -> bool:
	return true


## Multiplicador del clima para el daño (va antes del crítico, como en Showdown).
func weather_modifier(_engine: BattleEngine, _move: MoveData) -> float:
	return 1.0


## Potencia base modificada por el campo (Campo de Niebla debilita lo Dragón contra los que tocan el suelo).
func modify_base_power(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power


## Multiplicador de una estadística en el cálculo de daño (Tormenta Arena: Def. Esp. de los Roca).
func stat_modifier(_engine: BattleEngine, _battler: Battler, _stat: StringName) -> float:
	return 1.0


## Multiplicador del Ataque o Ataque Especial del usuario que depende del movimiento (Mar Llamas,
## Espesura...: en Showdown son onModifyAtk/onModifySpA, no un cambio de potencia).
func move_stat_modifier(_engine: BattleEngine, _user: Battler, _move: MoveData) -> float:
	return 1.0


## Multiplicadores finales del daño (Reflejo...), contra `target`.
func damage_modifier(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _crit: bool) -> float:
	return 1.0


## Velocidad del Battler (Viento Afín).
func modify_speed(_engine: BattleEngine, _battler: Battler, speed: int) -> int:
	return speed


## ¿Puede recibir este estado principal? false = no (el script avisa si `announce`).
func on_set_status(_engine: BattleEngine, _target: Battler, _status: StringName, _source: Battler, _announce: bool) -> bool:
	return true


## ¿Puede quedar confuso?
func on_try_confuse(_engine: BattleEngine, _target: Battler, _source: Battler, _announce: bool) -> bool:
	return true


## Al entrar al campo un Pokémon de ese bando (Red Viscosa).
func on_switch_in(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> void:
	pass


## ¿Impide cambiar o huir al que la tiene?
func traps(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> bool:
	return false


## Acción obligada este turno (movimientos bloqueados, de dos turnos, recarga). null = ninguna.
func forced_action(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> BattleAction:
	return null


## Quita tipos al que la tiene (Respiro quita Volador durante el turno).
func removed_types(_state: Dictionary) -> Array[StringName]:
	return []


# --- Habilidades y objetos equipados (Fase 9.5) ---

## Impide que baje esa característica (Ojocompuesto no; Vista Lince y Sacapecho).
func prevents_drop(_stat: StringName) -> bool:
	return false


## Polvo Escudo: no recibe efectos secundarios.
func blocks_secondary() -> bool:
	return false


## Velo Aroma: impide ciertos volátiles (Atracción).
func allows_volatile(_id: StringName) -> bool:
	return true


## Ajusta la precisión del que ataca (Ojocompuesto, Entusiasmo).
func modify_accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, accuracy: int) -> int:
	return accuracy


## Ajusta la precisión con la que le golpean (Tumbos).
func modify_incoming_accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, accuracy: int) -> int:
	return accuracy


## Huida: escapa seguro de un salvaje.
func guarantees_escape() -> bool:
	return false


## Tras recibir daño de un movimiento (Cobardía, Casco Dentado).
func on_damaged(_engine: BattleEngine, _battler: Battler, _user: Battler, _move: MoveData) -> void:
	pass


## Cuando debilita a un rival (Autoestima).
func on_foe_fainted(_engine: BattleEngine, _user: Battler) -> void:
	pass


func resists(_move: MoveData, _effectiveness: float) -> bool:
	return false


func cures_status(_status: StringName) -> bool:
	return false


func cures_confusion() -> bool:
	return false


## Baya curativa: ¿se come ya, con los PS que le quedan?
func eats_at(_battler: Battler) -> bool:
	return false


func heal_amount(_battler: Battler) -> int:
	return 0


func pinch_confuses(_battler: Battler) -> bool:
	return false
