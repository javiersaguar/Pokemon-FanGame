class_name Pokemon
extends RefCounted
## Un Pokémon concreto (del jugador, de un entrenador o salvaje). Los datos fijos están en SpeciesData.
## Contrato: docs/contratos.md (sección Pokemon).

const MAX_MOVES := 4
const MAX_IV := 31
const MAX_EV := 252
const MAX_TOTAL_EVS := 510
const MAX_FRIENDSHIP := 255
const STATUSES: Array[StringName] = [&"par", &"brn", &"psn", &"tox", &"slp", &"frz"]
const MALE := &"male"
const FEMALE := &"female"
const GENDERLESS := &""

## Identificador único (para seguirle la pista entre equipo, PC y escenas).
var uid: String = ""
## Especie o forma: "pikachu", "raichualola"...
var species_id: StringName
## Vacío = nombre de la especie.
var nickname: String = ""
var level: int = 1
## Experiencia total.
@warning_ignore("shadowed_global_identifier")
var exp: int = 0
var ivs: Dictionary[StringName, int] = {}
var evs: Dictionary[StringName, int] = {}
var nature: StringName = &"hardy"
## "0", "1" o "H" (oculta).
var ability_slot: String = "0"
var gender: StringName = GENDERLESS
var shiny: bool = false
var moves: Array[MoveSlot] = []
var current_hp: int = 0
## "", "par", "brn", "psn", "tox", "slp" o "frz".
var status: StringName = &""
## Contador del sueño (como en Showdown: baja antes de cada intento de moverse; a 0, se despierta).
var status_turns: int = 0
var held_item: StringName = &""
var friendship: int = 50
var ball: StringName = &"pokeball"
var original_trainer: String = ""
var trainer_id: int = 0
var met_level: int = 0
var met_location: StringName = &""
var met_date: String = ""
## 0 = nunca lo ha tenido; > 0 = días que le quedan; -1 = curado (inmune).
var pokerus: int = 0
var tera_type: StringName = &""
var ribbons: Array[StringName] = []

## Debug: todos los Pokémon nuevos salen shiny (para probar los sprites).
static var debug_force_shiny: bool = false
static var _uid_rng: RandomNumberGenerator


# --- Creación ---

## Pokémon nuevo (salvaje o de regalo): IVs al azar, naturaleza, sexo, habilidad, shiny y los
## últimos 4 movimientos aprendibles por nivel. `rng` permite resultados reproducibles.
## `shiny_rolls`: tiradas de shiny (Fase 6.7: 1 normal, más con el Amuleto Iris o Masuda; 0 = nunca).
static func create(id: StringName, at_level: int, rng: RandomNumberGenerator = null, shiny_rolls: int = 1) -> Pokemon:
	var s := DataDB.species(id)
	if s == null:
		return null
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var p := Pokemon.new()
	p.uid = new_uid()
	p.species_id = id
	p.level = clampi(at_level, 1, DataDB.MAX_LEVEL)
	p.exp = DataDB.exp_for_level(s.exp_group, p.level)
	for stat: StringName in SpeciesData.STATS:
		p.ivs[stat] = rng.randi_range(0, MAX_IV)
		p.evs[stat] = 0
	var natures := DataDB.nature_ids()
	DataUtil.sort_names(natures)
	p.nature = natures[rng.randi_range(0, natures.size() - 1)]
	if s.is_genderless():
		p.gender = GENDERLESS
	else:
		p.gender = FEMALE if rng.randf() < s.gender_ratio else MALE
	var slots: Array[String] = ["0"]
	if s.abilities.has("1"):
		slots.append("1")
	p.ability_slot = slots[rng.randi_range(0, slots.size() - 1)]
	if s.has_hidden_ability() and rng.randf() < float(DataDB.rule(&"wild_hidden_ability_chance", 0.0)):
		p.ability_slot = "H"
	p.shiny = roll_shiny(rng, shiny_rolls)
	for move_id: StringName in DataDB.default_moves(id, p.level):
		p.moves.append(MoveSlot.create(move_id))
	p.friendship = s.base_friendship
	p.met_level = p.level
	p.current_hp = p.max_hp()
	return p


## Pokémon a partir de una ficha como las de data/trainers/*.json:
## {species, level, moves?, ability?, ability_slot?, item?, nature?, ivs?, evs?, gender?, shiny?,
##  form?, nickname?, tera_type?, friendship?, ball?}. `ivs` puede ser un número (todas iguales).
static func from_spec(spec: Dictionary, rng: RandomNumberGenerator = null) -> Pokemon:
	var id := StringName(spec.get("species", ""))
	var form := str(spec.get("form", ""))
	if form != "":
		var with_form := StringName(String(id) + form.to_lower().replace("-", "").replace(" ", ""))
		if DataDB.has_species(with_form):
			id = with_form
		else:
			push_error("Pokemon.from_spec: '%s' no tiene la forma '%s'." % [id, form])
	# Los Pokémon de los entrenadores no tiran shiny: solo lo son si su ficha lo dice.
	var p := create(id, int(spec.get("level", 5)), rng, 0)
	if p == null:
		return null
	p.apply_spec(spec)
	return p


## Aplica los campos opcionales de una ficha (ver from_spec) y deja los PS al máximo.
func apply_spec(spec: Dictionary) -> void:
	var s := species()
	if spec.has("moves"):
		moves.clear()
		for move_id: Variant in spec["moves"]:
			if DataDB.has_move(StringName(move_id)) and moves.size() < MAX_MOVES:
				moves.append(MoveSlot.create(StringName(move_id)))
			else:
				push_error("Pokemon: movimiento '%s' no válido para %s." % [move_id, species_id])
	if spec.has("ability_slot"):
		ability_slot = str(spec["ability_slot"])
	if spec.has("ability"):
		var wanted := StringName(spec["ability"])
		var found := ""
		for slot: String in s.abilities:
			if s.abilities[slot] == wanted:
				found = slot
		if found == "":
			push_error("Pokemon: %s no puede tener la habilidad '%s'." % [species_id, wanted])
		else:
			ability_slot = found
	if spec.has("item"):
		held_item = StringName(spec["item"])
	if spec.has("nature"):
		nature = StringName(spec["nature"])
	if spec.has("ivs"):
		_apply_stat_spec(ivs, spec["ivs"], MAX_IV)
	if spec.has("evs"):
		_apply_stat_spec(evs, spec["evs"], MAX_EV)
	if spec.has("gender") and not s.is_genderless():
		gender = StringName(spec["gender"])
	if spec.has("shiny"):
		shiny = bool(spec["shiny"])
	if spec.has("nickname"):
		nickname = str(spec["nickname"])
	if spec.has("tera_type"):
		tera_type = StringName(spec["tera_type"])
	if spec.has("friendship"):
		friendship = clampi(int(spec["friendship"]), 0, MAX_FRIENDSHIP)
	if spec.has("ball"):
		ball = StringName(spec["ball"])
	current_hp = max_hp()


## Tirada de shiny (Fase 6.7): `rolls` comprobaciones independientes de 1/odds,
## con odds = data/world.json → shiny.odds (4096 por defecto).
static func roll_shiny(rng: RandomNumberGenerator, rolls: int = 1) -> bool:
	if debug_force_shiny and rolls > 0:
		return true
	var odds := DataDB.shiny_odds()
	var hit := false
	for i: int in maxi(rolls, 0):
		if odds > 0 and rng.randi_range(1, odds) == 1:
			hit = true
	return hit


## Probabilidad teórica de shiny con `rolls` tiradas: 1 − (1 − 1/odds)^rolls.
static func shiny_chance(rolls: int = 1) -> float:
	var odds := DataDB.shiny_odds()
	return 0.0 if odds <= 0 else 1.0 - pow(1.0 - 1.0 / odds, rolls)


static func new_uid() -> String:
	if _uid_rng == null:
		_uid_rng = RandomNumberGenerator.new()
		_uid_rng.randomize()
	return "%08x%08x" % [_uid_rng.randi(), _uid_rng.randi()]


# --- Datos de especie ---

func species() -> SpeciesData:
	return DataDB.species(species_id)


func display_name() -> String:
	if nickname != "":
		return nickname
	var s := species()
	return s.name if s else String(species_id)


func types() -> Array[StringName]:
	return species().types


func has_type(type: StringName) -> bool:
	return type in species().types


func ability_id() -> StringName:
	var s := species()
	var a := s.ability(ability_slot)
	return a if a != &"" else s.ability("0")


# --- Estadísticas ---

func stat(stat_id: StringName) -> int:
	var s := species()
	if stat_id == &"hp":
		if s.fixed_max_hp > 0:
			return s.fixed_max_hp
		return StatCalc.hp(s.base_stat(&"hp"), ivs.get(&"hp", 0), evs.get(&"hp", 0), level)
	var n := DataDB.nature(nature)
	var percent := n.percent(stat_id) if n else 100
	return StatCalc.stat(s.base_stat(stat_id), ivs.get(stat_id, 0), evs.get(stat_id, 0), level, percent)


func max_hp() -> int:
	return stat(&"hp")


func stats() -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int] = {}
	for stat_id: StringName in SpeciesData.STATS:
		out[stat_id] = stat(stat_id)
	return out


func total_evs() -> int:
	var total := 0
	for v: int in evs.values():
		total += v
	return total


## Suma EVs respetando los límites (252 por estadística, 510 en total). Devuelve los sumados.
func add_evs(stat_id: StringName, amount: int) -> int:
	var room := mini(MAX_EV - evs.get(stat_id, 0), MAX_TOTAL_EVS - total_evs())
	var added := clampi(amount, 0, maxi(room, 0))
	evs[stat_id] = evs.get(stat_id, 0) + added
	return added


# --- PS y estados ---

func is_fainted() -> bool:
	return current_hp <= 0


## Cura hasta `amount` PS. Devuelve los PS curados.
func heal(amount: int) -> int:
	if is_fainted():
		return 0
	var before := current_hp
	current_hp = mini(current_hp + maxi(amount, 0), max_hp())
	return current_hp - before


## Resta PS (mínimo 0). Devuelve el daño real.
func take_damage(amount: int) -> int:
	var dealt := clampi(amount, 0, current_hp)
	current_hp -= dealt
	return dealt


func revive(hp_fraction: float = 0.5) -> bool:
	if not is_fainted():
		return false
	current_hp = maxi(1, int(max_hp() * hp_fraction))
	status = &""
	status_turns = 0
	return true


func set_status(new_status: StringName, turns: int = 0) -> void:
	status = new_status
	status_turns = turns


func cure_status() -> void:
	status = &""
	status_turns = 0


## Curación completa (Centro Pokémon): PS, estado y PP.
func heal_full() -> void:
	current_hp = max_hp()
	cure_status()
	for slot: MoveSlot in moves:
		slot.restore()


# --- Experiencia y niveles ---

func exp_group() -> StringName:
	return species().exp_group


## Experiencia total al empezar el nivel actual.
func exp_at_level_start() -> int:
	return DataDB.exp_for_level(exp_group(), level)


## Experiencia total necesaria para el siguiente nivel (igual a `exp` en el nivel 100).
func exp_at_next_level() -> int:
	if level >= DataDB.MAX_LEVEL:
		return exp
	return DataDB.exp_for_level(exp_group(), level + 1)


func exp_to_next_level() -> int:
	return maxi(0, exp_at_next_level() - exp)


## Suma experiencia y sube los niveles que toquen (puede subir varios de golpe).
## Devuelve una entrada por nivel: {level, old_stats, new_stats, new_moves}. `new_moves` son los
## movimientos de ese nivel que todavía no conoce; aprenderlos lo decide quien llama (try_learn).
func gain_exp(amount: int) -> Array[Dictionary]:
	var ups: Array[Dictionary] = []
	if level >= DataDB.MAX_LEVEL or amount <= 0:
		return ups
	exp = mini(exp + amount, DataDB.exp_for_level(exp_group(), DataDB.MAX_LEVEL))
	while level < DataDB.MAX_LEVEL and exp >= DataDB.exp_for_level(exp_group(), level + 1):
		ups.append(_level_up_once())
	return ups


## Pone el nivel exacto (Debug, Caramelo Raro...). Devuelve las subidas como gain_exp.
func set_level(new_level: int) -> Array[Dictionary]:
	new_level = clampi(new_level, 1, DataDB.MAX_LEVEL)
	if new_level > level:
		return gain_exp(DataDB.exp_for_level(exp_group(), new_level) - exp)
	var old_max := max_hp()
	level = new_level
	exp = exp_at_level_start()
	_keep_damage(old_max)
	return []


func _level_up_once() -> Dictionary:
	var old_stats := stats()
	level += 1
	_keep_damage(old_stats[&"hp"])
	var new_moves: Array[StringName] = []
	for move_id: StringName in DataDB.moves_learned_at(species_id, level):
		if not has_move(move_id) and DataDB.has_move(move_id):
			new_moves.append(move_id)
	return {"level": level, "old_stats": old_stats, "new_stats": stats(), "new_moves": new_moves}


## Tras cambiar el máximo de PS, conserva el daño recibido (los debilitados siguen a 0).
func _keep_damage(old_max_hp: int) -> void:
	if current_hp > 0:
		current_hp = clampi(current_hp + max_hp() - old_max_hp, 1, max_hp())


## ¿Ha pasado el nivel al que evolucionaría su especie? (bonus de experiencia ×1,2).
func is_past_evolution_level() -> bool:
	for evo: Dictionary in species().evolutions:
		if evo.get("method", "") == "level" and evo.has("level") and level >= int(evo["level"]):
			return true
	return false


# --- Movimientos ---

func move_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for slot: MoveSlot in moves:
		out.append(slot.id)
	return out


func has_move(move_id: StringName) -> bool:
	for slot: MoveSlot in moves:
		if slot.id == move_id:
			return true
	return false


## Aprende el movimiento si hay hueco. Devuelve false si ya tiene 4 o si ya lo conoce.
func try_learn(move_id: StringName) -> bool:
	if moves.size() >= MAX_MOVES or has_move(move_id) or not DataDB.has_move(move_id):
		return false
	moves.append(MoveSlot.create(move_id))
	return true


## Sustituye el movimiento de la posición `index` (0-3) por `move_id`.
func replace_move(index: int, move_id: StringName) -> void:
	if index < 0 or index >= moves.size():
		push_error("Pokemon.replace_move: posición %d fuera de rango." % index)
		return
	moves[index] = MoveSlot.create(move_id)


func forget_move(index: int) -> void:
	if moves.size() > 1 and index >= 0 and index < moves.size():
		moves.remove_at(index)


func restore_all_pp() -> void:
	for slot: MoveSlot in moves:
		slot.restore()


# --- Evolución ---

## Cambia de especie conservando el daño recibido. El mote se mantiene.
func evolve_to(new_species: StringName) -> void:
	if not DataDB.has_species(new_species):
		push_error("Pokemon.evolve_to: no existe la especie '%s'." % new_species)
		return
	var old_max := max_hp()
	species_id = new_species
	if species().ability(ability_slot) == &"":
		ability_slot = "0"
	_keep_damage(old_max)


# --- Guardado ---

func to_dict() -> Dictionary:
	return {
		"uid": uid,
		"species": String(species_id),
		"nickname": nickname,
		"level": level,
		"exp": exp,
		"ivs": _stats_to_dict(ivs),
		"evs": _stats_to_dict(evs),
		"nature": String(nature),
		"ability_slot": ability_slot,
		"gender": String(gender),
		"shiny": shiny,
		"moves": moves.map(func(m: MoveSlot) -> Dictionary: return m.to_dict()),
		"hp": current_hp,
		"status": String(status),
		"status_turns": status_turns,
		"held_item": String(held_item),
		"friendship": friendship,
		"ball": String(ball),
		"original_trainer": original_trainer,
		"trainer_id": trainer_id,
		"met_level": met_level,
		"met_location": String(met_location),
		"met_date": met_date,
		"pokerus": pokerus,
		"tera_type": String(tera_type),
		"ribbons": ribbons.map(func(r: StringName) -> String: return String(r)),
	}


static func from_dict(d: Dictionary) -> Pokemon:
	var p := Pokemon.new()
	p.uid = str(d.get("uid", ""))
	if p.uid == "":
		p.uid = new_uid()
	p.species_id = StringName(d.get("species", ""))
	p.nickname = str(d.get("nickname", ""))
	p.level = int(d.get("level", 1))
	p.exp = int(d.get("exp", 0))
	p.ivs = DataUtil.int_dict(d.get("ivs", {}))
	p.evs = DataUtil.int_dict(d.get("evs", {}))
	p.nature = StringName(d.get("nature", "hardy"))
	p.ability_slot = str(d.get("ability_slot", "0"))
	p.gender = StringName(d.get("gender", ""))
	p.shiny = bool(d.get("shiny", false))
	for m: Dictionary in d.get("moves", []):
		p.moves.append(MoveSlot.from_dict(m))
	p.current_hp = int(d.get("hp", 0))
	p.status = StringName(d.get("status", ""))
	p.status_turns = int(d.get("status_turns", 0))
	p.held_item = StringName(d.get("held_item", ""))
	p.friendship = int(d.get("friendship", 50))
	p.ball = StringName(d.get("ball", "pokeball"))
	p.original_trainer = str(d.get("original_trainer", ""))
	p.trainer_id = int(d.get("trainer_id", 0))
	p.met_level = int(d.get("met_level", 0))
	p.met_location = StringName(d.get("met_location", ""))
	p.met_date = str(d.get("met_date", ""))
	p.pokerus = int(d.get("pokerus", 0))
	p.tera_type = StringName(d.get("tera_type", ""))
	p.ribbons = DataUtil.names(d.get("ribbons", []))
	return p


## Copia independiente (mismo uid). Útil para simular combates sin tocar el original.
func clone() -> Pokemon:
	return Pokemon.from_dict(to_dict())


func _stats_to_dict(values: Dictionary[StringName, int]) -> Dictionary:
	var out := {}
	for stat_id: StringName in SpeciesData.STATS:
		out[String(stat_id)] = values.get(stat_id, 0)
	return out


func _apply_stat_spec(target: Dictionary[StringName, int], value: Variant, max_value: int) -> void:
	if value is Dictionary:
		for k: Variant in value:
			target[StringName(str(k))] = clampi(int(value[k]), 0, max_value)
	else:
		for stat_id: StringName in SpeciesData.STATS:
			target[stat_id] = clampi(int(value), 0, max_value)
