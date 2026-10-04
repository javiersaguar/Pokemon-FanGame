class_name Randomizer
extends RefCounted
## Motor de RandomLocke (Fase R.1–R.4): genera la "ROM" (RomPatch) de una partida.
## Lógica pura y determinista, como el BattleEngine: sin nodos, con su propio RNG sembrado y
## recorriendo los datos siempre en orden de id. Misma semilla + mismos ajustes + misma versión
## del generador = exactamente la misma ROM. No toca DataDB (se puede llamar desde otro hilo).
##   var rom := Randomizer.generate(seed, RandomizerSettings.from_preset("clasico"))
##   rom.apply()   # DataDB.apply_patch()

## Súbelo cuando cambie cualquier cosa que altere las ROM generadas (código o data/randomizer.json).
const GENERATOR_VERSION := 1
const CONFIG_PATH := "res://data/randomizer.json"
const STATS: Array[StringName] = [&"hp", &"atk", &"def", &"spa", &"spd", &"spe"]
const ITEM_POCKETS: Array[StringName] = [&"items", &"medicine", &"pokeballs", &"berries", &"battle"]
const LEVEL_METHODS: Array[String] = ["level", "level_hold", "level_move", "level_extra"]

var settings: RandomizerSettings
var seed_value: int = 0
var rng := RandomNumberGenerator.new()
var config: Dictionary = {}
var patch: RomPatch
## Problemas de validación de la última subsemilla (vacío = ROM válida).
var problems: PackedStringArray = []

var _pool: Array[StringName] = []
var _pool_set: Dictionary = {}
var _legendary: Dictionary = {}
var _starter_map: Dictionary = {}
var _prevo: Dictionary = {}
var _min_level_memo: Dictionary = {}
var _moves: Array[StringName] = []
var _move_power: Dictionary = {}
var _move_type: Dictionary = {}
var _damaging: Dictionary = {}
var _move_buckets: Dictionary = {}
var _items: Array[StringName] = []
var _buyable: Array[StringName] = []
var _abilities: Array[StringName] = []
var _type_list: Array[StringName] = []


## Genera la ROM. Si no pasa la validación (R.4), prueba subsemillas derivadas (la semilla que ve el
## jugador no cambia). Devuelve null si DataDB tiene un parche aplicado (hay que quitarlo antes).
static func generate(seed_number: int, with_settings: RandomizerSettings) -> RomPatch:
	var r := Randomizer.new()
	r.seed_value = seed_number & 0xFFFFFFFF
	r.settings = with_settings
	return r.run()


func run() -> RomPatch:
	if DataDB.has_patch():
		push_error("Randomizer: quita antes el parche actual (DataDB.clear_patch()).")
		return null
	config = JsonFile.read_dict(CONFIG_PATH)
	_prepare_pools()
	var attempts := maxi(1, int(config.get("validation_attempts", 25)))
	for attempt: int in attempts:
		rng.seed = seed_value if attempt == 0 else hash("%d:%d" % [seed_value, attempt])
		patch = RomPatch.create(seed_value, settings)
		patch.data["subseed"] = attempt
		_build()
		problems = RomValidator.validate(patch)
		if problems.is_empty():
			return patch
	push_warning("Randomizer: ninguna subsemilla de %d pasa la validación: %s" % [seed_value, "; ".join(problems)])
	return patch


func _build() -> void:
	_starter_map.clear()
	_prevo.clear()
	_min_level_memo.clear()
	if settings.evolutions:
		_randomize_evolutions()
	_index_prevos()
	if settings.types:
		_randomize_types()
	if settings.base_stats:
		_shuffle_base_stats()
	if settings.abilities:
		_randomize_abilities()
	_randomize_starters()
	_randomize_wild()
	if settings.story_pokemon:
		_randomize_story()
	_randomize_trainers()
	if settings.learnsets != "off":
		for id: StringName in RomValidator.species_in_play(patch):
			_randomize_learnset(id)
	if settings.items:
		_randomize_items()
	if settings.shops:
		_randomize_shops()


# --- Preparación (no usa el RNG) ---

func _prepare_pools() -> void:
	var banned := DataUtil.names(config.get("banned_species", []))
	var legendary_tags := DataUtil.names(config.get("legendary_tags", []))
	var ids := DataDB.species_ids(false)
	DataUtil.sort_names(ids)
	for id: StringName in ids:
		var s := DataDB.species(id)
		if s.num <= 0 or s.nonstandard not in [&"", &"past"] or id in banned:
			continue
		var level_moves: Array = DataDB.learnset(id).get("level", [])
		if level_moves.is_empty():
			continue
		if settings.learnsets == "off" and not _has_damaging_level_move(level_moves):
			continue
		_pool.append(id)
		_pool_set[id] = true
		var legendary := s.is_legendary or s.is_mythical
		for tag: StringName in s.tags:
			legendary = legendary or tag in legendary_tags
		_legendary[id] = legendary
	_type_list = DataDB.type_ids()
	DataUtil.sort_names(_type_list)
	var banned_moves := DataUtil.names(config.get("banned_moves", []))
	var move_ids := DataDB.move_ids()
	DataUtil.sort_names(move_ids)
	for id: StringName in move_ids:
		var m := DataDB.move(id)
		if m.num <= 0 or m.nonstandard not in [&"", &"past"] or id in banned_moves or m.raw.has("is_z") or m.raw.has("is_max"):
			continue
		if settings.only_implemented_moves and m.needs_script:
			continue
		if m.target in MoveData.FIELD_TARGETS or m.ohko != &"":
			continue
		_moves.append(id)
		_move_power[id] = m.power if m.is_damaging() else 0
		_move_type[id] = m.type
		_damaging[id] = m.is_damaging() and (m.power > 0 or m.fixed_damage > 0 or m.level_damage)
	var item_ids := DataDB.item_ids()
	DataUtil.sort_names(item_ids)
	for id: StringName in item_ids:
		var it := DataDB.item(id)
		if it.is_panchito or it.nonstandard != &"" or it.price <= 0 or it.pocket not in ITEM_POCKETS:
			continue
		_items.append(id)
		if it.effect != &"" and it.battle_use != ItemData.USE_NONE or it.field_use != ItemData.USE_NONE:
			_buyable.append(id)
	var banned_abilities := DataUtil.names(config.get("banned_abilities", []))
	var ability_ids: Array[StringName] = []
	for id: StringName in _all_ability_ids():
		var a := DataDB.ability(id)
		if a.num > 0 and not a.raw.has("nonstandard") and id not in banned_abilities:
			ability_ids.append(id)
	DataUtil.sort_names(ability_ids)
	_abilities = ability_ids


func _all_ability_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in _pool:
		for slot: String in DataDB.species(id).abilities:
			var a := DataDB.species(id).abilities[slot]
			if DataDB.has_ability(a) and a not in out:
				out.append(a)
	return out


func _has_damaging_level_move(level_moves: Array) -> bool:
	for entry: Array in level_moves:
		var m := DataDB.move(StringName(entry[1])) if DataDB.has_move(StringName(entry[1])) else null
		if m != null and m.is_damaging() and (m.power > 0 or m.fixed_damage > 0 or m.level_damage):
			return true
	return false


# --- Datos efectivos (base + lo ya parcheado) ---

func _evos(id: StringName) -> Array:
	return RomValidator.evolutions(patch, id)


func _types(id: StringName) -> Array[StringName]:
	var patched: Variant = patch.section("species").get(String(id), {}).get("types")
	if patched != null:
		return DataUtil.names(patched)
	return DataDB.species(id).types


func _bst(id: StringName) -> int:
	var total := 0
	for v: int in DataDB.species(id).base_stats.values():
		total += v
	return total


func _index_prevos() -> void:
	var ids := DataDB.species_ids()
	DataUtil.sort_names(ids)
	for id: StringName in ids:
		for evo: Dictionary in _evos(id):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and DataDB.has_species(to) and not _prevo.has(to):
				_prevo[to] = {"from": id, "evo": evo}


## Nivel mínimo con el que puede aparecer (nivel de sus evoluciones; las que no son por nivel suman evolution_gap).
func _min_level(id: StringName) -> int:
	if _min_level_memo.has(id):
		return _min_level_memo[id]
	var level := 1
	if _prevo.has(id):
		var from: StringName = _prevo[id]["from"]
		var evo: Dictionary = _prevo[id]["evo"]
		var base := _min_level(from)
		if str(evo.get("method", "")) in LEVEL_METHODS and evo.has("level"):
			level = maxi(base, int(evo["level"]))
		else:
			level = mini(base + int(config.get("evolution_gap", 15)), DataDB.MAX_LEVEL)
	_min_level_memo[id] = level
	return level


## Nivel a partir del cual ya no debería aparecer sin evolucionar (101 = sin límite).
func _max_level(id: StringName) -> int:
	var best := DataDB.MAX_LEVEL + 1
	var gap := int(config.get("overlevel_gap", 10))
	for evo: Dictionary in _evos(id):
		if evo.has("region") or not DataDB.has_species(StringName(str(evo.get("to", "")))):
			continue
		if str(evo.get("method", "")) in LEVEL_METHODS and evo.has("level"):
			best = mini(best, int(evo["level"]) + gap)
		else:
			best = mini(best, _min_level(id) + int(config.get("evolution_gap", 15)) + gap)
	return best


func _stage(id: StringName) -> int:
	return 0 if not _prevo.has(id) else _stage(_prevo[id]["from"]) + 1


## Línea evolutiva desde `id` siguiendo la primera evolución: [id, evolución, evolución final].
func _chain(id: StringName, use_patch: bool = true) -> Array[StringName]:
	var out: Array[StringName] = [id]
	var current := id
	while out.size() < 4:
		var next := &""
		for evo: Dictionary in (_evos(current) if use_patch else DataDB.species(current).evolutions):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and DataDB.has_species(to) and to not in out:
				next = to
				break
		if next == &"":
			break
		out.append(next)
		current = next
	return out


func _root(id: StringName) -> StringName:
	var current := id
	while _prevo.has(current):
		current = _prevo[current]["from"]
	return current


func _is_legendary(id: StringName) -> bool:
	return _legendary.get(id, false)


func _legendary_ok(id: StringName, level: int) -> bool:
	if not _is_legendary(id):
		return true
	if not settings.allow_legendaries:
		return false
	return not (settings.no_early_legendaries and level < int(config.get("early_legendary_level", 30)))


func _random(list: Array) -> Variant:
	return list[rng.randi_range(0, list.size() - 1)]


## Especie al azar para sustituir a `original` a nivel `level`, respetando las reglas de equilibrio.
## Si no hay ninguna, relaja primero la fuerza, luego el nivel y luego las repetidas.
func _pick(original: StringName, level: int, used: Dictionary, theme: StringName = &"") -> StringName:
	var original_bst := _bst(original) if DataDB.has_species(original) else 400
	var tolerance := original_bst * settings.strength_tolerance / 100.0
	for tier: Array in [[true, true, true], [false, true, true], [false, false, true], [false, false, false]]:
		var candidates: Array[StringName] = []
		for id: StringName in _pool:
			if tier[2] and used.has(id):
				continue
			if not _legendary_ok(id, level):
				continue
			if theme != &"" and theme not in _types(id):
				continue
			if tier[0] and settings.similar_strength and absf(_bst(id) - original_bst) > tolerance:
				continue
			if tier[1] and settings.level_appropriate and level > 0 and not (_min_level(id) <= level and level < _max_level(id)):
				continue
			candidates.append(id)
		if not candidates.is_empty():
			return _random(candidates)
	if theme != &"":
		return _pick(original, level, used)
	return original


# --- Especies: evoluciones, tipos, estadísticas y habilidades ---

func _randomize_evolutions() -> void:
	var targets_used := {}
	var tolerance := maxf(settings.strength_tolerance, 15.0) / 100.0
	for id: StringName in _pool:
		var evos: Array = DataDB.species(id).evolutions
		if evos.is_empty():
			continue
		var out: Array = []
		for evo: Dictionary in evos:
			var copy := evo.duplicate(true)
			var original := StringName(str(evo.get("to", "")))
			if not evo.has("region") and DataDB.has_species(original):
				var own := _bst(id)
				var wanted := _bst(original)
				var candidates: Array[StringName] = []
				for c: StringName in _pool:
					if c != id and not targets_used.has(c) and _bst(c) > own and absf(_bst(c) - wanted) <= wanted * tolerance and _legendary_ok(c, 100):
						candidates.append(c)
				if not candidates.is_empty():
					var chosen: StringName = _random(candidates)
					targets_used[chosen] = true
					copy["to"] = String(chosen)
			out.append(copy)
		_species_patch(id)["evolutions"] = out


func _randomize_types() -> void:
	for id: StringName in _pool:
		if _prevo.has(id):
			continue
		var primary: StringName = _random(_type_list)
		var secondary: StringName = primary
		while secondary == primary:
			secondary = _random(_type_list)
		for member: StringName in _family(id):
			var dual := DataDB.species(member).types.size() > 1
			_species_patch(member)["types"] = [String(primary), String(secondary)] if dual else [String(primary)]


func _shuffle_base_stats() -> void:
	for id: StringName in _pool:
		if _prevo.has(id):
			continue
		var order: Array[StringName] = STATS.duplicate()
		for i: int in range(order.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp := order[i]
			order[i] = order[j]
			order[j] = tmp
		for member: StringName in _family(id):
			var s := DataDB.species(member)
			if s.fixed_max_hp > 0:
				continue
			var stats := {}
			for i: int in STATS.size():
				stats[String(order[i])] = s.base_stat(STATS[i])
			_species_patch(member)["base_stats"] = stats


func _randomize_abilities() -> void:
	for id: StringName in _pool:
		var slots := DataDB.species(id).abilities.keys()
		DataUtil.sort_names(slots)
		var out := {}
		var used := {}
		for slot: String in slots:
			var a: StringName = _random(_abilities)
			for i: int in 5:
				if not used.has(a):
					break
				a = _random(_abilities)
			used[a] = true
			out[slot] = String(a)
		patch.section("abilities")[String(id)] = out


func _family(root: StringName) -> Array[StringName]:
	var out: Array[StringName] = [root]
	var i := 0
	while i < out.size():
		for evo: Dictionary in _evos(out[i]):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and DataDB.has_species(to) and to not in out:
				out.append(to)
		i += 1
	return out


func _species_patch(id: StringName) -> Dictionary:
	var section := patch.section("species")
	if not section.has(String(id)):
		section[String(id)] = {}
	return section[String(id)]


# --- Iniciales ---

func _randomize_starters() -> void:
	if settings.starters == "off":
		return
	var ids := DataDB.starter_ids()
	DataUtil.sort_names(ids)
	var slots: Array[StringName] = []
	var originals: Array[StringName] = []
	for id: StringName in ids:
		var spec := DataDB.starter_spec(id)
		if spec.get("randomize", true) == false or not DataDB.has_species(StringName(str(spec.get("species", "")))):
			continue
		slots.append(id)
		originals.append(StringName(str(spec["species"])))
	if slots.is_empty():
		return
	var chosen := _choose_starters(slots.size())
	for i: int in slots.size():
		patch.section("starters")[String(slots[i])] = String(chosen[i])
		var old_chain := _chain(_root(originals[i]), false)
		var new_chain := _chain(chosen[i])
		for stage: int in old_chain.size():
			_starter_map[old_chain[stage]] = new_chain[mini(stage, new_chain.size() - 1)]


func _choose_starters(count: int) -> Array[StringName]:
	var candidates: Array[StringName] = []
	var three: Array[StringName] = []
	for id: StringName in _pool:
		if _prevo.has(id) or _is_legendary(id) or _chain(id).size() < 2:
			continue
		candidates.append(id)
		if _chain(id).size() >= 3:
			three.append(id)
	if candidates.size() < count:
		candidates = _pool.duplicate()
	var source := three if (settings.starters != "random" and three.size() >= count) else candidates
	if settings.starters == "triangle" and count == 3:
		var triangle := _triangle_starters(source)
		if triangle.size() == 3:
			return triangle
	var out: Array[StringName] = []
	while out.size() < count:
		var id: StringName = _random(source)
		if id not in out:
			out.append(id)
	return out


## Tres especies A, B y C tales que B gana a A, C gana a B y A gana a C (como Planta/Fuego/Agua),
## en el orden de starter_1, starter_2 y starter_3 (el rival lleva el que gana al tuyo).
func _triangle_starters(source: Array[StringName]) -> Array[StringName]:
	var by_type := {}
	for id: StringName in source:
		var t := _types(id)[0]
		if not by_type.has(t):
			by_type[t] = []
		by_type[t].append(id)
	var triads: Array[Array] = []
	for a: StringName in _type_list:
		for b: StringName in _type_list:
			for c: StringName in _type_list:
				if a == b or b == c or a == c or String(a) > String(b) or String(a) > String(c):
					continue
				if not (by_type.has(a) and by_type.has(b) and by_type.has(c)):
					continue
				if _beats(b, a) and _beats(c, b) and _beats(a, c):
					triads.append([a, b, c])
				elif _beats(a, b) and _beats(b, c) and _beats(c, a):
					triads.append([c, b, a])
	if triads.is_empty():
		return []
	var triad: Array = _random(triads)
	var out: Array[StringName] = []
	for t: StringName in triad:
		out.append(_random(by_type[t]))
	return out


func _beats(attacker: StringName, defender: StringName) -> bool:
	return DataDB.type_effectiveness(attacker, [defender]) > 1.0


# --- Salvajes, regalos y entrenadores ---

func _randomize_wild() -> void:
	if settings.wild == "off":
		return
	var global_map := {}
	var global_used := {}
	var ids := DataDB.encounter_ids()
	DataUtil.sort_names(ids)
	for table_id: StringName in ids:
		var table: Dictionary = DataDB.encounter_table(table_id).duplicate(true)
		var local_map := {}
		var local_used := {}
		var keys := table.keys()
		DataUtil.sort_names(keys)
		for key: Variant in keys:
			var lists: Array = []
			if table[key] is Array:
				lists.append(table[key])
			elif table[key] is Dictionary:
				var periods: Array = table[key].keys()
				DataUtil.sort_names(periods)
				for period: Variant in periods:
					if table[key][period] is Array:
						lists.append(table[key][period])
			for list: Array in lists:
				for entry: Variant in list:
					if entry is not Dictionary or not entry.has("species"):
						continue
					var original := StringName(str(entry["species"]))
					var level := int(entry.get("max", entry.get("min", 5)))
					var chosen: StringName
					match settings.wild:
						"global":
							if not global_map.has(original):
								global_map[original] = _pick(original, level, global_used)
								global_used[global_map[original]] = true
							chosen = global_map[original]
						"chaos":
							chosen = _pick(original, level, {})
						_:
							if not local_map.has(original):
								local_map[original] = _pick(original, level, local_used)
								local_used[local_map[original]] = true
							chosen = local_map[original]
					entry["species"] = String(chosen)
		patch.section("encounters")[String(table_id)] = table
	if settings.wild == "global":
		for k: StringName in global_map:
			patch.section("species_map")[String(k)] = String(global_map[k])


func _randomize_story() -> void:
	var used := {}
	for kind: String in ["gifts", "statics"]:
		var ids := DataDB.gift_ids() if kind == "gifts" else DataDB.static_ids()
		DataUtil.sort_names(ids)
		for id: StringName in ids:
			var spec := DataDB.gift(id) if kind == "gifts" else DataDB.static_encounter(id)
			if spec.get("randomize", true) == false or not spec.has("species"):
				continue
			var chosen := _pick(StringName(str(spec["species"])), int(spec.get("level", 5)), used)
			used[chosen] = true
			patch.section(kind)[String(id)] = String(chosen)
	var wild_species := RomValidator.wild_species(patch)
	var trade_ids := DataDB.trade_ids()
	DataUtil.sort_names(trade_ids)
	for id: StringName in trade_ids:
		var t := DataDB.trade(id)
		if t.get("randomize", true) == false:
			continue
		var out := {}
		var receive: Variant = t.get("receive")
		if receive is Dictionary and receive.has("species"):
			var r: Dictionary = receive.duplicate(true)
			r["species"] = String(_pick(StringName(str(r["species"])), int(r.get("level", 10)), used))
			r.erase("moves")
			out["receive"] = r
		if t.has("give") and not wild_species.is_empty():
			out["give"] = String(_random(wild_species))
		if not out.is_empty():
			patch.section("trades")[String(id)] = out


func _randomize_trainers() -> void:
	var ids := DataDB.trainer_ids()
	DataUtil.sort_names(ids)
	for trainer_id: StringName in ids:
		var t := DataDB.trainer(trainer_id)
		if t.get("randomize", true) == false:
			continue
		var party: Array = t.get("party", [])
		var theme := _trainer_theme(t, party)
		var used := {}
		var new_party: Array = []
		var changed := false
		for spec: Dictionary in party:
			var original := StringName(str(spec.get("species", "")))
			var chosen := original
			if _starter_map.has(original):
				chosen = _starter_map[original]
			elif settings.trainers and DataDB.has_species(original):
				chosen = _pick(original, int(spec.get("level", 5)), used, theme)
			used[chosen] = true
			var copy: Dictionary = spec.duplicate(true)
			if chosen != original:
				copy["species"] = String(chosen)
				for key: String in ["moves", "ability", "form"]:
					copy.erase(key)
				changed = true
			new_party.append(copy)
		if changed:
			patch.section("trainers")[String(trainer_id)] = {"party": new_party}


## Tipo que hay que mantener (líderes): "type_theme" del entrenador o de su clase, o el tipo que
## comparten todos sus Pokémon. Vacío si no hay o si el ajuste está desactivado.
func _trainer_theme(t: Dictionary, party: Array) -> StringName:
	if not settings.keep_type_themes:
		return &""
	if t.has("type_theme"):
		return StringName(str(t["type_theme"]))
	var cls := DataDB.trainer_class(StringName(str(t.get("class", "")))) if DataDB.has_trainer_class(StringName(str(t.get("class", "")))) else {}
	if cls.has("type_theme"):
		return StringName(str(cls["type_theme"]))
	if party.size() < 2:
		return &""
	var shared: Array = []
	for i: int in party.size():
		var sid := StringName(str(party[i].get("species", "")))
		if not DataDB.has_species(sid):
			return &""
		var types := DataDB.species(sid).types
		shared = Array(types) if i == 0 else shared.filter(func(x: Variant) -> bool: return StringName(x) in types)
		if shared.is_empty():
			return &""
	return StringName(shared[0])


# --- Movimientos ---

func _power_cap(level: int) -> int:
	if not settings.scaled_power:
		return 9999
	for row: Array in config.get("power_caps", []):
		if level <= int(row[0]):
			return int(row[1])
	return 9999


## Movimientos posibles (memorizados por potencia máxima, tipo y si hacen daño).
func _move_candidates(cap: int, type: StringName, damaging: bool) -> Array[StringName]:
	var key := "%d|%s|%d" % [cap, type, 1 if damaging else 0]
	if _move_buckets.has(key):
		return _move_buckets[key]
	var out: Array[StringName] = []
	for id: StringName in _moves:
		if damaging and not _damaging[id]:
			continue
		if type != &"" and _move_type[id] != type:
			continue
		if int(_move_power[id]) > cap:
			continue
		out.append(id)
	_move_buckets[key] = out
	return out


## Movimiento al azar. Si pide tipos, prueba primero uno de ellos al azar y luego los demás; después
## relaja la potencia mínima y la máxima, y solo al final acepta cualquier tipo.
func _pick_move(types: Array[StringName], cap: int, used: Dictionary, damaging: bool, min_power: int = 0) -> StringName:
	var order: Array[StringName] = []
	if not types.is_empty():
		order.append(_random(types))
		for t: StringName in types:
			if t not in order:
				order.append(t)
	var attempts: Array[Array] = []
	for t: StringName in order:
		attempts.append([t, cap, min_power])
	for t: StringName in order:
		attempts.append([t, cap, 0])
	for t: StringName in order:
		attempts.append([t, 9999, 0])
	attempts.append_array([[&"", cap, min_power], [&"", cap, 0], [&"", 9999, 0]])
	for attempt: Array in attempts:
		var candidates: Array = _move_candidates(int(attempt[1]), attempt[0], damaging)
		if int(attempt[2]) > 0:
			candidates = candidates.filter(func(m: StringName) -> bool: return int(_move_power[m]) >= int(attempt[2]))
		if candidates.is_empty():
			continue
		for i: int in 8:
			var m: StringName = _random(candidates)
			if not used.has(m):
				return m
		var free: Array = candidates.filter(func(m: StringName) -> bool: return not used.has(m))
		if not free.is_empty():
			return _random(free)
	return _random(_move_candidates(9999, &"", damaging))


func _randomize_learnset(id: StringName) -> void:
	var base: Array = DataDB.learnset(id).get("level", [])
	if base.is_empty():
		return
	var types := _types(id)
	var chance := float(config.get("type_preference_chance", 0.5))
	var result: Array = []
	var used := {}
	for entry: Array in base:
		var level := int(entry[0])
		var prefer := settings.learnsets == "type_preference" and rng.randf() < chance
		var move := _pick_move(types if prefer else ([] as Array[StringName]), _power_cap(maxi(level, 1)), used, false)
		used[move] = true
		result.append([level, String(move)])
	# Ataque de daño (con STAB si se pide) entre los que sabe al principio: el último de su primer
	# nivel, para que entre en sus 4 movimientos iniciales aunque aprenda muchos a ese nivel.
	var first := -1
	for i: int in result.size():
		if int(result[i][0]) >= 1:
			if first >= 0 and int(result[i][0]) != int(result[first][0]):
				break
			first = i
	if first >= 0 and (settings.guarantee_stab or not _damaging[StringName(result[first][1])]):
		var cap := _power_cap(maxi(int(result[first][0]), 1))
		var min_power := mini(int(config.get("first_move_min_power", 30)), cap)
		var stab := _pick_move(types if settings.guarantee_stab else ([] as Array[StringName]), cap, used, true, min_power)
		used[stab] = true
		result[first][1] = String(stab)
	# En cada momento de su curva, los 4 últimos aprendidos incluyen un ataque de daño.
	var window: Array[StringName] = []
	for i: int in result.size():
		if int(result[i][0]) < 1:
			continue
		window.append(StringName(result[i][1]))
		if window.size() > 4:
			window.pop_front()
		var has_damage := false
		for m: StringName in window:
			has_damage = has_damage or _damaging[m]
		if not has_damage:
			var fix := _pick_move(types, _power_cap(maxi(int(result[i][0]), 1)), used, true)
			used[fix] = true
			result[i][1] = String(fix)
			window[window.size() - 1] = fix
	patch.section("learnsets")[String(id)] = result


# --- Objetos y tiendas ---

func _randomize_items() -> void:
	var placements := DataDB.item_placements()
	var ids := placements.keys()
	DataUtil.sort_names(ids)
	for pid: Variant in ids:
		var original := StringName(str(placements[pid]))
		if DataDB.has_item(original) and (DataDB.item(original).is_key_item() or DataDB.item(original).pocket == &"machines"):
			continue
		if not _items.is_empty():
			patch.section("items")[str(pid)] = String(_random(_items))


func _randomize_shops() -> void:
	var guaranteed := DataUtil.names(config.get("shop_guaranteed", []))
	var ids := DataDB.shop_ids()
	DataUtil.sort_names(ids)
	for shop_id: StringName in ids:
		var shop: Dictionary = DataDB.shop(shop_id).duplicate(true)
		var used := {}
		var stock: Array = shop.get("stock", [])
		for t: int in stock.size():
			var tier: Dictionary = stock[t]
			var items: Array = []
			for i: int in tier.get("items", []).size():
				var chosen: StringName = _random(_buyable)
				for j: int in 8:
					if not used.has(chosen):
						break
					chosen = _random(_buyable)
				used[chosen] = true
				items.append(String(chosen))
			tier["items"] = items
		if not stock.is_empty():
			var first_items: Array = stock[0]["items"]
			for g: StringName in guaranteed:
				if String(g) not in first_items:
					first_items.push_front(String(g))
		patch.section("shops")[String(shop_id)] = shop
