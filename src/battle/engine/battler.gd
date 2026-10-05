class_name Battler
extends RefCounted
## Un Pokémon en el campo: envuelve a un Pokemon y guarda lo que dura mientras está fuera
## (niveles de características, estados volátiles, contador de Tóxico...).

const BOOST_STATS: Array[StringName] = [&"atk", &"def", &"spa", &"spd", &"spe", &"accuracy", &"evasion"]

var pokemon: Pokemon
var side: int
var slot: int
var party_index: int
var boosts: Dictionary[StringName, int] = {}
## Estados volátiles: {"confusion": {"turns": n}, "flinch": {}}.
var volatiles: Dictionary[StringName, Dictionary] = {}
## Contador de Tóxico (se reinicia al cambiar).
var toxic_stage: int = 0
## Niveles de crítico extra (Directo, Foco Energía).
var crit_stage: int = 0
var turns_active: int = 0
var last_move: StringName = &""
var moved_this_turn: bool = false
## Ha recibido daño este turno (Buena Baza).
var damaged_this_turn: bool = false
## Usos seguidos de Protección y similares (cada uno es menos probable).
var protect_count: int = 0
## Habilidad en el combate (Danza Amiga o Abatidoras la cambian sin tocar al Pokémon).
var ability: StringName = &""
## Movimiento fijado por un objeto Elección. Vacío = no está fijado.
var choice_move: StringName = &""
## Descendrático: perdió el objeto durante el combate.
var unburdened: bool = false


func _init(p: Pokemon, battle_side: int, battle_slot: int, index: int) -> void:
	pokemon = p
	side = battle_side
	slot = battle_slot
	party_index = index
	for stat: StringName in BOOST_STATS:
		boosts[stat] = 0
	ability = p.ability_id()


func is_fainted() -> bool:
	return pokemon.is_fainted()


## ¿Tiene ese tipo ahora? (tiene en cuenta los volátiles que quitan tipos).
func has_type(type: StringName) -> bool:
	return type in types()


## Tipos en el combate: los del Pokémon menos los que quite algún volátil (Respiro quita Volador).
## Puede quedar vacío (sin tipo: todo le afecta de forma neutra).
func types() -> Array[StringName]:
	var out := pokemon.types()
	for id: StringName in volatiles:
		var effect := Effects.condition(id)
		if effect != null:
			for t: StringName in effect.removed_types(volatiles[id]):
				out.erase(t)
	return out


func has_volatile(id: StringName) -> bool:
	return volatiles.has(id)


## Estadística con su nivel aplicado (no sirve para los PS).
func boosted_stat(stat: StringName, stage_override: Variant = null) -> int:
	var stage: int = boosts.get(stat, 0) if stage_override == null else int(stage_override)
	return StatCalc.apply_stage(pokemon.stat(stat), stage)


## Velocidad para el orden de turno: nivel de Velocidad y parálisis (mitad).
@warning_ignore("integer_division")
func effective_speed() -> int:
	var spe := boosted_stat(&"spe")
	if pokemon.status == &"par":
		spe = spe * 50 / 100
	return spe


## Movimientos que se pueden elegir (con PP).
func usable_moves() -> Array[int]:
	var out: Array[int] = []
	var vest := pokemon.held_item == &"assaultvest"
	for i: int in pokemon.moves.size():
		var slot := pokemon.moves[i]
		if slot.pp <= 0:
			continue
		if choice_move != &"" and slot.id != choice_move:
			continue
		if vest and slot.data().is_status():
			continue
		out.append(i)
	return out
