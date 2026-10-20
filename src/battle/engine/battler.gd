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
## Turno en que salió al campo (0 = al empezar el combate). Impulso, Vigilante.
var entered_turn: int = 0
var last_move: StringName = &""
var moved_this_turn: bool = false
## Ha recibido daño este turno (Buena Baza).
var damaged_this_turn: bool = false
## Usos seguidos de Protección y similares (cada uno es menos probable).
var protect_count: int = 0
## Turno del último uso con éxito. Si pasa un turno entero sin usarla (aunque sea por retroceder),
## la cuenta vuelve a empezar, como el volátil "stall" de Showdown (dura 2 turnos).
var protect_turn: int = -10
## Habilidad en el combate (Danza Amiga o Abatidoras la cambian sin tocar al Pokémon).
var ability: StringName = &""
## Movimiento fijado por un objeto Elección. Vacío = no está fijado.
var choice_move: StringName = &""
## Descendrático: perdió el objeto durante el combate.
var unburdened: bool = false
## Especie de antes de megaevolucionar. Vacío si no está mega.
var mega_from: StringName = &""
## Turnos de Dinamax que le quedan. 0 = no está dinamaxizado.
var dynamax_turns: int = 0
## Tipo del Teratipo mientras dura el combate. Vacío si no ha teracristalizado.
var tera_active: StringName = &""
## Tipos puestos por un movimiento (Anegar, Polvo Mágico, Conversión, Clonatipo). Vacío = los suyos.
var type_override: Array[StringName] = []
## El motor lo pone al sacarlo: (battler, move) -> true si ese movimiento está impedido (Mofa, Anulación...).
var move_filter: Callable
## Último golpe de un movimiento que ha recibido: {"amount", "physical", "side", "slot", "turn"}
## (Contraataque, Manto Espejo, Desquite, Alud...).
var hurt_by: Dictionary = {}
## Kilos de más o de menos (Aligerar).
var weight_delta: float = 0.0
## Último objeto que ha gastado y si se ha comido una baya en este combate (Reciclaje, Eructo).
var consumed_item: StringName = &""
var ate_berry: bool = false
## Estadísticas cambiadas por un movimiento (Isoguardia, Isofuerza, Truco Fuerza, Cambiavelocidad).
var stat_override: Dictionary[StringName, int] = {}
## Si su último movimiento falló (Pataleta).
var last_move_failed: bool = false
## Movimientos usados desde que salió (Última Baza).
var used_moves: Dictionary[StringName, bool] = {}


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
	if tera_active != &"":
		var tera_types: Array[StringName] = []
		tera_types.append(tera_active)
		return tera_types
	if not type_override.is_empty():
		return type_override.duplicate()
	# Copia: pokemon.types() es la lista de la especie. Sin copiar, Respiro le quitaba el tipo
	# Volador a la especie entera para el resto de la partida.
	var out := pokemon.types().duplicate()
	for id: StringName in volatiles:
		var effect := Effects.condition(id)
		if effect != null:
			for t: StringName in effect.removed_types(volatiles[id]):
				out.erase(t)
	return out


func has_volatile(id: StringName) -> bool:
	return volatiles.has(id)


## Peso en kilos en el combate (Patada Baja, Cuerpo Pesado...). Nunca baja de 0,1.
func weight() -> float:
	var w := maxf(0.1, pokemon.species().weight + weight_delta)
	# Metal Pesado y Metal Liviano.
	if ability == &"heavymetal":
		w *= 2.0
	elif ability == &"lightmetal":
		w = maxf(0.1, w / 2.0)
	return w


## Estadística con su nivel aplicado (no sirve para los PS).
func boosted_stat(stat: StringName, stage_override: Variant = null) -> int:
	var stage: int = boosts.get(stat, 0) if stage_override == null else int(stage_override)
	return StatCalc.apply_stage(stat_override.get(stat, pokemon.stat(stat)), stage)


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
		if move_filter.is_valid() and move_filter.call(self, slot.data()):
			continue
		out.append(i)
	return out
