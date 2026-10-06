class_name Daycare
extends RefCounted
## Guardería (Fase 14.3): compatibilidad, huevo y herencia. Sin escena.
## Quien camina llama a walk(); quien pinta el huevo llama a take_egg().

const CYCLE := 256
const MASUDA_ROLLS := 6

var slots: Array[Pokemon] = []
var steps: int = 0
var egg_ready: bool = false
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


func deposit(pokemon: Pokemon) -> bool:
	if pokemon == null or slots.size() >= 2:
		return false
	slots.append(pokemon)
	return true


func withdraw(index: int) -> Pokemon:
	if index < 0 or index >= slots.size():
		return null
	var pokemon: Pokemon = slots[index]
	slots.remove_at(index)
	if slots.size() < 2:
		egg_ready = false
		steps = 0
	return pokemon


static func compatible(a: Pokemon, b: Pokemon) -> bool:
	if a == null or b == null:
		return false
	var ditto_a := _is_ditto(a)
	var ditto_b := _is_ditto(b)
	if ditto_a and ditto_b:
		return false
	if ditto_a or ditto_b:
		var other := b if ditto_a else a
		return not _undiscovered(other)
	if a.gender == b.gender or a.gender == Pokemon.GENDERLESS or b.gender == Pokemon.GENDERLESS:
		return false
	if _undiscovered(a) or _undiscovered(b):
		return false
	for group: StringName in a.species().egg_groups:
		if group != &"ditto" and group in b.species().egg_groups:
			return true
	return false


## 70, 50 o 20, como en los juegos. 0 si no pueden criar.
static func egg_percent(a: Pokemon, b: Pokemon) -> int:
	if not compatible(a, b):
		return 0
	var same_species := _root(a) == _root(b)
	var same_trainer := a.original_trainer == b.original_trainer
	if same_species and not same_trainer:
		return 70
	if same_species or not same_trainer:
		return 50
	return 20


## La cría es la especie base de la madre (o del que no es Ditto).
static func egg_species(a: Pokemon, b: Pokemon) -> StringName:
	if not compatible(a, b):
		return &""
	var mother := _mother(a, b)
	var current := _root(mother)
	while DataDB.has_species(current) and DataDB.species(current).prevo != &"":
		current = DataDB.species(current).prevo
	return current


## Pasos. Con Cuerpo Llama en el equipo cada paso cuenta por dos.
func walk(step_count: int, flame_body: bool = false) -> void:
	if slots.size() < 2 or not compatible(slots[0], slots[1]) or egg_ready or step_count <= 0:
		return
	steps += step_count * (2 if flame_body else 1)
	while steps >= CYCLE and not egg_ready:
		steps -= CYCLE
		if rng.randi_range(1, 100) <= egg_percent(slots[0], slots[1]):
			egg_ready = true


## Tiradas de shiny. Masuda (idiomas distintos) lo dice quien llama: el Pokémon no guarda idioma.
static func shiny_rolls(masuda: bool) -> int:
	return MASUDA_ROLLS if masuda else 1


func take_egg(masuda: bool = false) -> Pokemon:
	if not egg_ready or slots.size() < 2:
		return null
	var a := slots[0]
	var b := slots[1]
	var species := egg_species(a, b)
	var baby := Pokemon.create(species, 1, rng, shiny_rolls(masuda))
	if baby == null:
		return null
	_inherit(baby, a, b, rng)
	egg_ready = false
	return baby


## Un contagiado puede pasar el Pokérus al de al lado (1/3 por vecino y llamada).
static func spread_pokerus(party: Array, roller: RandomNumberGenerator) -> void:
	for i: int in party.size():
		var pokemon: Pokemon = party[i]
		if pokemon == null or pokemon.pokerus <= 0:
			continue
		for neighbor: int in [i - 1, i + 1]:
			if neighbor < 0 or neighbor >= party.size():
				continue
			var other: Pokemon = party[neighbor]
			if other != null and other.pokerus == 0 and roller.randi_range(0, 2) == 0:
				other.pokerus = pokemon.pokerus


static func _inherit(baby: Pokemon, a: Pokemon, b: Pokemon, roller: RandomNumberGenerator) -> void:
	var mother := _mother(a, b)
	var father := b if mother == a else a
	var knot := a.held_item == &"destinyknot" or b.held_item == &"destinyknot"
	var stats := SpeciesData.STATS.duplicate()
	for i: int in stats.size():
		var swap := roller.randi_range(i, stats.size() - 1)
		var tmp: StringName = stats[i]
		stats[i] = stats[swap]
		stats[swap] = tmp
	var inherited := 5 if knot else 3
	for i: int in mini(inherited, stats.size()):
		var parent := a if roller.randi_range(0, 1) == 0 else b
		baby.ivs[stats[i]] = parent.ivs[stats[i]]
	if a.held_item == &"everstone" and b.held_item == &"everstone":
		baby.nature = a.nature if roller.randi_range(0, 1) == 0 else b.nature
	elif a.held_item == &"everstone":
		baby.nature = a.nature
	elif b.held_item == &"everstone":
		baby.nature = b.nature
	var hidden := mother.ability_slot == "H"
	var roll := roller.randi_range(0, 9)
	if hidden and roll < 6 and baby.species().has_hidden_ability():
		baby.ability_slot = "H"
	elif not hidden and roll < 8 and baby.species().ability(mother.ability_slot) != &"":
		baby.ability_slot = mother.ability_slot
	else:
		baby.ability_slot = "0"
	if _root(a) == _root(b):
		baby.ball = a.ball if roller.randi_range(0, 1) == 0 else b.ball
	else:
		baby.ball = mother.ball
	var egg_moves: Array = DataDB.learnset(baby.species_id).get("egg", [])
	for move_id: StringName in father.move_ids():
		if String(move_id) in egg_moves and not baby.has_move(move_id):
			baby.try_learn(move_id)


static func _mother(a: Pokemon, b: Pokemon) -> Pokemon:
	if _is_ditto(a):
		return b
	if _is_ditto(b):
		return a
	return a if a.gender == Pokemon.FEMALE else b


static func _is_ditto(pokemon: Pokemon) -> bool:
	return _root(pokemon) == &"ditto"


static func _undiscovered(pokemon: Pokemon) -> bool:
	return &"undiscovered" in pokemon.species().egg_groups


static func _root(pokemon: Pokemon) -> StringName:
	var species := pokemon.species()
	return species.root_species() if species != null and species.is_form() else pokemon.species_id
