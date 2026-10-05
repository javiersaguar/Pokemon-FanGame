class_name Randomizer
extends RefCounted
## Motor de RandomLocke (Fase R.1–R.4): genera la "ROM" (RomPatch) de una partida.
## Lógica pura y determinista, como el BattleEngine: sin nodos, con su propio RNG sembrado y
## recorriendo los datos siempre en orden de id. Misma semilla + mismos ajustes + misma versión
## del generador = exactamente la misma ROM. La API de entrada explícita no toca DataDB y puede llamarse desde otro hilo.
##   var rom := Randomizer.generate(seed, RandomizerSettings.from_preset("clasico"))
##   rom.apply()   # input.apply_patch()

## Súbelo cuando cambie cualquier cosa que altere las ROM generadas (código o data/randomizer/).
const GENERATOR_VERSION := 2
const CONFIG_PATH := "res://data/randomizer/policy.json"
const STATS: Array[StringName] = [&"hp", &"atk", &"def", &"spa", &"spd", &"spe"]
const ITEM_POCKETS: Array[StringName] = [&"items", &"medicine", &"pokeballs", &"berries", &"battle"]
const LEVEL_METHODS: Array[String] = ["level", "level_hold", "level_move", "level_extra"]

var input: RandomizerInput
var settings: RandomizerSettings
var _build_errors: PackedStringArray = []
var _attempt: int = 0
var seed_value: int = 0
var rng := RandomNumberGenerator.new()
var config: Dictionary = {}
var patch: RomPatch
## Problemas de validación de la última subsemilla (vacío = ROM válida).
var problems: PackedStringArray = []

var _bst_cache: Dictionary = {}
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
static func generate(input_or_seed: Variant, with_settings: Variant, seed_number: int = 0) -> RomPatch:
	var r := Randomizer.new()
	r.input = input_or_seed if input_or_seed is RandomizerInput else RandomizerInput.from_datadb()
	r.seed_value = (seed_number if input_or_seed is RandomizerInput else int(input_or_seed)) & 0xFFFFFFFF
	r.settings = RandomizerSettings.new()
	var raw_settings: Dictionary = with_settings.to_dict() if with_settings is RandomizerSettings else with_settings
	var settings_errors := RandomizerSettings.errors(raw_settings)
	if not settings_errors.is_empty():
		var failed := RomPatch.create(r.seed_value, r.settings)
		failed.errors.assign(settings_errors)
		return failed
	r.settings.apply_dict(with_settings.to_dict() if with_settings is RandomizerSettings else with_settings)
	if with_settings is RandomizerSettings:
		r.settings.preset_reference = with_settings.preset_reference.duplicate(true)
	return r.run()

func run() -> RomPatch:
	if input == null:
		input = RandomizerInput.from_datadb()
	config = input.data.get("config", {}).duplicate(true)
	if config.get("presets", {}).has(settings.preset):
		settings.preset_reference = RandomizerSettings.normalize(config.presets[settings.preset])
	else:
		settings.preset_reference = {}
	if not settings.matches_preset():
		settings.preset = RandomizerSettings.CUSTOM
	patch = RomPatch.create(seed_value, settings)
	patch.input = input
	problems = PackedStringArray(input.errors())
	problems.append_array(PackedStringArray(RandomizerSettings.errors(settings.to_dict())))
	if config.is_empty():
		problems.append("Falta configuración del generador en la entrada.")
	if not problems.is_empty():
		patch.errors.assign(problems)
		return patch
	_prepare_pools()
	if _pool.size() < input.starter_ids().size() or _moves.is_empty():
		patch.errors.assign(["No hay candidatos suficientes con estos ajustes."])
		problems = PackedStringArray(patch.errors)
		return patch
	var attempts := maxi(1, int(config.get("validation_attempts", 25)))
	for attempt: int in attempts:
		_attempt = attempt
		_build_errors.clear()
		patch = RomPatch.create(seed_value, settings)
		patch.input = input
		patch.data["input_hash"] = input.fingerprint
		patch.data["subseed"] = attempt
		_build()
		problems = PackedStringArray(RomValidator.validate(input, patch))
		problems.append_array(_build_errors)
		patch.errors.assign(problems)
		if problems.is_empty():
			return patch
	return patch

func _seed_module(module: String) -> void:
	rng.seed = ("%d:%d:%d:%s" % [GENERATOR_VERSION, seed_value, _attempt, module]).sha256_text().substr(0, 15).hex_to_int()


func _build() -> void:
	_starter_map.clear()
	_prevo.clear()
	_min_level_memo.clear()
	if settings.evolutions:
		_seed_module("evolutions")
		_randomize_evolutions()
	_index_prevos()
	if settings.types:
		_seed_module("types")
		_randomize_types()
	if settings.base_stats:
		_seed_module("base_stats")
		_shuffle_base_stats()
	if settings.abilities:
		_seed_module("abilities")
		_randomize_abilities()
	_seed_module("starters")
	_randomize_starters()
	_seed_module("wild")
	_randomize_wild()
	if settings.story_pokemon:
		_randomize_story()
	_seed_module("trainers")
	_randomize_trainers()
	if settings.learnsets != "off":
		for id: StringName in _pool:
			if input.mutable_species(id):
				_seed_module("learnsets:" + String(id))
				_randomize_learnset(id)
	_randomize_machines()
	if settings.items:
		_seed_module("items")
		_randomize_items()
		_seed_module("held_items")
		_randomize_held_items()
	if settings.shops:
		_seed_module("shops")
		_randomize_shops()


# --- Preparación (no usa el RNG) ---

func _prepare_pools() -> void:
	var banned := DataUtil.names(config.get("banned_species", []))
	var legendary_tags := DataUtil.names(config.get("legendary_tags", []))
	var ids := input.species_ids()
	DataUtil.sort_names(ids)
	for id: StringName in ids:
		var s := input.species(id)
		if s.num <= 0 or s.nonstandard not in [&"", &"past"] or s.is_mega or s.is_gmax or s.required_item != &"" or s.catch_rate <= 0 or id in banned:
			continue
		var level_moves: Array = input.learnset(id).get("level", [])
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
	_type_list = input.type_ids()
	DataUtil.sort_names(_type_list)
	var banned_moves := DataUtil.names(config.get("banned_moves", []))
	var move_ids := input.move_ids()
	DataUtil.sort_names(move_ids)
	for id: StringName in move_ids:
		var m := input.move(id)
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
	var item_ids := input.item_ids()
	DataUtil.sort_names(item_ids)
	for id: StringName in item_ids:
		var it := input.item(id)
		if it.is_key_item() or it.raw.get("randomize", true) == false or it.is_panchito or it.nonstandard != &"" or it.price <= 0 or it.pocket not in ITEM_POCKETS:
			continue
		_items.append(id)
		if it.effect != &"" and it.battle_use != ItemData.USE_NONE or it.field_use != ItemData.USE_NONE:
			_buyable.append(id)
	var banned_abilities := DataUtil.names(config.get("banned_abilities", []))
	var ability_ids: Array[StringName] = []
	for id: StringName in _all_ability_ids():
		var a := input.ability(id)
		if a.num > 0 and not a.raw.has("nonstandard") and id not in banned_abilities:
			ability_ids.append(id)
	DataUtil.sort_names(ability_ids)
	_abilities = ability_ids


func _all_ability_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in _pool:
		for slot: String in input.species(id).abilities:
			var a := input.species(id).abilities[slot]
			if input.has_ability(a) and a not in out:
				out.append(a)
	return out


func _has_damaging_level_move(level_moves: Array) -> bool:
	for entry: Array in level_moves:
		var m := input.move(StringName(entry[1])) if input.has_move(StringName(entry[1])) else null
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
	return input.species(id).types


func _bst(id: StringName) -> int:
	if _bst_cache.has(id):
		return int(_bst_cache[id])
	var total := 0
	for v: int in input.species(id).base_stats.values():
		total += v
	_bst_cache[id] = total
	return total


func _index_prevos() -> void:
	var ids := input.species_ids()
	DataUtil.sort_names(ids)
	for id: StringName in ids:
		for evo: Dictionary in _evos(id):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and input.has_species(to) and not _prevo.has(to):
				_prevo[to] = {"from": id, "evo": evo}


## Nivel mínimo con el que puede aparecer (nivel de sus evoluciones; las que no son por nivel suman evolution_gap).
func _min_level(id: StringName) -> int:
	if _min_level_memo.has(id):
		return _min_level_memo[id]
	if input.species(id).raw.has("min_level"):
		return int(input.species(id).raw.min_level)
	var level := 1
	if _prevo.has(id):
		var from: StringName = _prevo[id]["from"]
		var evo: Dictionary = _prevo[id]["evo"]
		var base := _min_level(from)
		if str(evo.get("method", "")) in LEVEL_METHODS and evo.has("level"):
			level = maxi(base, int(evo["level"]))
		else:
			level = mini(base + int(config.get("evolution_gap", 15)), input.MAX_LEVEL)
	_min_level_memo[id] = level
	return level


## Nivel a partir del cual ya no debería aparecer sin evolucionar (101 = sin límite).
func _max_level(id: StringName) -> int:
	if input.species(id).raw.has("max_level"):
		return int(input.species(id).raw.max_level) + 1
	var best := input.MAX_LEVEL + 1
	var gap := int(config.get("overlevel_gap", 10))
	for evo: Dictionary in _evos(id):
		if evo.has("region") or not input.has_species(StringName(str(evo.get("to", "")))):
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
		for evo: Dictionary in (_evos(current) if use_patch else input.species(current).evolutions):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and input.has_species(to) and to not in out:
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
## Si no existe candidato, falla la ROM sin relajar los ajustes.
func _candidates(original: StringName, low: int, high: int, used: Dictionary, theme: StringName = &"", early: bool = false) -> Array[StringName]:
	var candidates: Array[StringName] = []
	var original_bst := _bst(original) if input.has_species(original) else 0
	var tolerance := original_bst * settings.strength_tolerance / 100.0
	for id: StringName in _pool:
		if used.has(id) or not _legendary_ok(id, low):
			continue
		if early and settings.no_early_legendaries and _is_legendary(id):
			continue
		if theme != &"" and theme not in _types(id):
			continue
		if settings.similar_strength and absf(_bst(id) - original_bst) > tolerance:
			continue
		if settings.level_appropriate and low > 0 and not (_min_level(id) <= low and high < _max_level(id)):
			continue
		candidates.append(id)
	return candidates

func _pick(original: StringName, level: int, used: Dictionary, theme: StringName = &"", high: int = -1, early: bool = false) -> StringName:
	var candidates := _candidates(original, level, level if high < 0 else high, used, theme, early)
	if not candidates.is_empty():
		return _random(candidates)
	_build_errors.append("No hay reemplazo válido para %s a nivel %d (tipo %s)." % [original, level, theme])
	return original

func _family_mutable(root: StringName) -> bool:
	for member: StringName in _family(root):
		if not input.mutable_species(member):
			return false
	return true


# --- Especies: evoluciones, tipos, estadísticas y habilidades ---

func _randomize_evolutions() -> void:
	var targets_used := {}
	var tolerance := settings.strength_tolerance / 100.0
	var bins: Dictionary = {}
	for id: StringName in _pool:
		if input.mutable_species(id) and _legendary_ok(id, 100):
			bins.get_or_add(_bst(id), []).append(id)
	var totals: Array = bins.keys()
	totals.sort()
	for id: StringName in _pool:
		if not input.mutable_species(id):
			continue
		var evos: Array = input.species(id).evolutions
		if evos.is_empty():
			continue
		var out: Array = []
		for evo: Dictionary in evos:
			var copy := evo.duplicate(true)
			var original := StringName(str(evo.get("to", "")))
			if not evo.has("region") and input.has_species(original):
				var own := _bst(id)
				var wanted := _bst(original)
				var candidates: Array[StringName] = []
				for total: int in totals:
					if total <= own or absf(total - wanted) > wanted * tolerance:
						continue
					for c: StringName in bins[total]:
						if c != id and not targets_used.has(c):
							candidates.append(c)
				DataUtil.sort_names(candidates)
				if not candidates.is_empty():
					var chosen: StringName = _random(candidates)
					targets_used[chosen] = true
					copy["to"] = String(chosen)
			out.append(copy)
		_species_patch(id)["evolutions"] = out


func _randomize_types() -> void:
	for id: StringName in _pool:
		if _prevo.has(id) or not _family_mutable(id):
			continue
		var primary: StringName = _random(_type_list)
		var secondary: StringName = primary
		while secondary == primary and _type_list.size() > 1:
			secondary = _random(_type_list)
		for member: StringName in _family(id):
			var dual := input.species(member).types.size() > 1
			_species_patch(member)["types"] = [String(primary), String(secondary)] if dual else [String(primary)]


func _shuffle_base_stats() -> void:
	for id: StringName in _pool:
		if _prevo.has(id) or not _family_mutable(id):
			continue
		var order: Array[StringName] = STATS.duplicate()
		for i: int in range(order.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp := order[i]
			order[i] = order[j]
			order[j] = tmp
		for member: StringName in _family(id):
			var s := input.species(member)
			if s.fixed_max_hp > 0:
				continue
			var stats := {}
			for i: int in STATS.size():
				stats[String(order[i])] = s.base_stat(STATS[i])
			_species_patch(member)["base_stats"] = stats


func _randomize_abilities() -> void:
	for id: StringName in _pool:
		if not input.mutable_species(id) or _abilities.is_empty():
			continue
		var slots := input.species(id).abilities.keys()
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
			if not evo.has("region") and input.has_species(to) and to not in out:
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
	var ids := input.starter_ids()
	DataUtil.sort_names(ids)
	var slots: Array[StringName] = []
	var originals: Array[StringName] = []
	for id: StringName in ids:
		var spec := input.starter_spec(id)
		if spec.get("randomize", true) == false or not input.mutable_species(StringName(str(spec.get("species", "")))):
			continue
		slots.append(id)
		originals.append(StringName(str(spec["species"])))
	if slots.is_empty():
		return
	var chosen := _choose_starters(slots.size())
	if chosen.size() != slots.size():
		return
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
		if ((settings.starters != "random" or settings.level_appropriate) and _prevo.has(id)) or not _legendary_ok(id, 5) or not input.mutable_species(id) or (settings.starters != "random" and _chain(id).size() < 3):
			continue
		candidates.append(id)
		if _chain(id).size() >= 3:
			three.append(id)
	if candidates.size() < count:
		_build_errors.append("No hay suficientes iniciales con la etapa requerida.")
		return []
	var source := three if (settings.starters != "random" and three.size() >= count) else candidates
	if settings.starters == "triangle" and count == 3:
		var triangle := _triangle_starters(source)
		if triangle.size() == 3:
			return triangle
		_build_errors.append("No existe un triángulo de iniciales con estos ajustes.")
		return []
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
	return input.type_effectiveness(attacker, [defender]) > 1.0


# --- Salvajes, regalos y entrenadores ---

func _randomize_wild() -> void:
	if settings.wild == "off":
		return
	var groups: Dictionary = {}
	for table_id: String in input.ids("encounters"):
		var table: Dictionary = input.data.encounters[table_id]
		if table.get("randomize", true) == false:
			continue
		var group := "global" if settings.wild == "global" else str(table.get("zone_id", table_id))
		var bands: Dictionary = groups.get_or_add(group, {})
		for entry: Dictionary in RomValidator._entries(table):
			var original := StringName(str(entry.species))
			if entry.get("randomize", true) == false or not input.mutable_species(original):
				continue
			var low := int(entry.get("min", entry.get("min_level", 1)))
			var high := int(entry.get("max", entry.get("max_level", low)))
			var band: Dictionary = bands.get_or_add(String(original), {"low": low, "high": high, "early": false})
			band.low = mini(band.low, low)
			band.high = maxi(band.high, high)
			band.early = band.early or table.get("early", false)
	var mappings: Dictionary = {}
	if settings.wild != "chaos":
		var group_ids: Array = groups.keys()
		group_ids.sort()
		for group: String in group_ids:
			_seed_module("wild:" + group)
			var domains: Dictionary = {}
			var originals: Array = groups[group].keys()
			originals.sort()
			for original: String in originals:
				var band: Dictionary = groups[group][original]
				domains[original] = _candidates(StringName(original), band.low, band.high, {}, &"", band.early)
			mappings[group] = _match_domains(domains)
	for table_id: String in input.ids("encounters"):
		var table: Dictionary = input.data.encounters[table_id].duplicate(true)
		if table.get("randomize", true) == false:
			continue
		var group := "global" if settings.wild == "global" else str(table.get("zone_id", table_id))
		_seed_module("wild:" + table_id)
		for entry: Dictionary in RomValidator._entries(table):
			var original := StringName(str(entry.species))
			if entry.get("randomize", true) == false or not input.mutable_species(original):
				continue
			var low := int(entry.get("min", entry.get("min_level", 1)))
			var high := int(entry.get("max", entry.get("max_level", low)))
			var chosen := _pick(original, low, {}, &"", high, bool(table.get("early", false))) if settings.wild == "chaos" else StringName(str(mappings.get(group, {}).get(String(original), original)))
			entry["species"] = String(chosen)
		patch.section("encounters")[table_id] = table
	if settings.wild == "global":
		patch.section("species_map").merge(mappings.get("global", {}))

func _match_domains(domains: Dictionary) -> Dictionary:
	var keys: Array = domains.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return domains[a].size() < domains[b].size() if domains[a].size() != domains[b].size() else a < b)
	for key: String in keys:
		var options: Array = domains[key]
		for i: int in range(options.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var temp: Variant = options[i]
			options[i] = options[j]
			options[j] = temp
	var owners: Dictionary = {}
	for key: String in keys:
		if not _augment(key, domains, owners, {}):
			_build_errors.append("No existe mapeo 1:1 válido para %s." % key)
	var result: Dictionary = {}
	for chosen: Variant in owners:
		result[owners[chosen]] = String(chosen)
	return result

func _augment(original: String, domains: Dictionary, owners: Dictionary, visited: Dictionary) -> bool:
	for option: Variant in domains[original]:
		var chosen := str(option)
		if visited.has(chosen):
			continue
		visited[chosen] = true
		if not owners.has(chosen) or _augment(owners[chosen], domains, owners, visited):
			owners[chosen] = original
			return true
	return false


func _randomize_story() -> void:
	var used := {}
	for kind: String in ["gifts", "statics"]:
		if not settings.get(kind):
			continue
		_seed_module(kind)
		used.clear()
		var ids := input.gift_ids() if kind == "gifts" else input.static_ids()
		DataUtil.sort_names(ids)
		for id: StringName in ids:
			var spec := input.gift(id) if kind == "gifts" else input.static_encounter(id)
			if spec.get("randomize", true) == false or not spec.has("species") or not input.mutable_species(StringName(str(spec.species))):
				continue
			var chosen := _pick(StringName(str(spec["species"])), int(spec.get("level", 5)), used)
			used[chosen] = true
			patch.section(kind)[String(id)] = String(chosen)
	if not settings.trades:
		return
	_seed_module("trades")
	var wild_species := RomValidator.wild_species(patch)
	var trade_ids := input.trade_ids()
	DataUtil.sort_names(trade_ids)
	for id: StringName in trade_ids:
		var t := input.trade(id)
		if t.get("randomize", true) == false:
			continue
		var out := {}
		var receive: Variant = t.get("receive")
		if receive is Dictionary and receive.has("species") and receive.get("randomize", true) != false and input.mutable_species(StringName(str(receive.species))):
			var r: Dictionary = receive.duplicate(true)
			r["species"] = String(_pick(StringName(str(r["species"])), int(r.get("level", 10)), used))
			r.erase("moves")
			out["receive"] = r
		if t.has("give") and not wild_species.is_empty() and input.mutable_species(StringName(str(t.give))):
			out["give"] = String(_random(wild_species))
		if not out.is_empty():
			patch.section("trades")[String(id)] = out


func _randomize_trainers() -> void:
	var ids := input.trainer_ids()
	DataUtil.sort_names(ids)
	for trainer_id: StringName in ids:
		var t := input.trainer(trainer_id)
		if t.get("randomize", true) == false:
			continue
		var party: Array = t.get("party", [])
		var theme := _trainer_theme(t, party)
		var used := {}
		for spec: Dictionary in party:
			if spec.get("randomize", true) == false or not input.mutable_species(StringName(str(spec.get("species", "")))):
				used[StringName(str(spec.species))] = true
		var new_party: Array = []
		var changed := false
		for spec: Dictionary in party:
			var original := StringName(str(spec.get("species", "")))
			var chosen := original
			var protected: bool = spec.get("randomize", true) == false or not input.mutable_species(original)
			if not protected and settings.rival_starter and (t.get("rival", false) or t.get("class", "") == "rival") and _starter_map.has(original):
				chosen = _starter_map[original]
				var line := _chain(chosen)
				for member: StringName in line:
					if _min_level(member) <= int(spec.get("level", 5)):
						chosen = member
			elif not protected and settings.trainers and input.has_species(original):
				chosen = _pick(original, int(spec.get("level", 5)), {} if settings.trainer_duplicates else used, theme)
			used[chosen] = true
			var copy: Dictionary = spec.duplicate(true)
			if chosen != original:
				copy["species"] = String(chosen)
				for key: String in ["moves", "ability", "form"]:
					copy.erase(key)
				changed = true
			new_party.append(copy)
		if settings.trainers and settings.leader_ace and (t.has("ace_index") or theme != &"" and t.get("leader", false)):
			var ace := int(t.get("ace_index", new_party.size() - 1))
			if ace >= 0 and ace < new_party.size():
				var strongest := 0
				for member: Dictionary in new_party:
					strongest = maxi(strongest, _bst(StringName(str(member.species))))
				if _bst(StringName(str(new_party[ace].species))) < strongest:
					var protected: bool = party[ace].get("randomize", true) == false or not input.mutable_species(StringName(str(party[ace].species)))
					var ace_used := used.duplicate()
					ace_used.erase(StringName(str(new_party[ace].species)))
					var options := _candidates(StringName(str(party[ace].species)), int(party[ace].level), int(party[ace].level), {} if settings.trainer_duplicates else ace_used, theme)
					options = options.filter(func(id: StringName) -> bool: return _bst(id) >= strongest)
					if protected or options.is_empty():
						_build_errors.append("El as de %s no puede ser el más fuerte." % trainer_id)
					else:
						new_party[ace].species = String(_random(options))
						for key: String in ["moves", "ability", "form"]:
							new_party[ace].erase(key)
						changed = true
		if changed:
			patch.section("trainers")[String(trainer_id)] = {"party": new_party}


## Tipo que hay que mantener (líderes): "type_theme" del entrenador o de su clase, o el tipo que
## comparten todos sus Pokémon. Vacío si no hay o si el ajuste está desactivado.
func _trainer_theme(t: Dictionary, party: Array) -> StringName:
	if not settings.keep_type_themes:
		return &""
	if t.has("leader_type"):
		return StringName(str(t.leader_type))
	if t.has("type_theme"):
		return StringName(str(t["type_theme"]))
	var cls := input.trainer_class(StringName(str(t.get("class", "")))) if input.has_trainer_class(StringName(str(t.get("class", "")))) else {}
	if cls.has("type_theme"):
		return StringName(str(cls["type_theme"]))
	if party.size() < 2:
		return &""
	var shared: Array = []
	for i: int in party.size():
		var sid := StringName(str(party[i].get("species", "")))
		if not input.has_species(sid):
			return &""
		var types := input.species(sid).types
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
## la potencia máxima permanece fijada por datos; STAB usa excepciones configurables.
func _pick_move(types: Array[StringName], cap: int, used: Dictionary, damaging: bool, min_power: int = 0) -> StringName:
	var candidates: Array[StringName] = []
	if types.is_empty():
		candidates = _move_candidates(cap, &"", damaging)
	else:
		for type: StringName in types:
			candidates.append_array(_move_candidates(cap, type, damaging))
	if candidates.is_empty() and damaging and settings.guarantee_stab:
		for type: StringName in types:
			var override_cap := int(config.get("low_power_stab_cap_overrides", {}).get(String(type), cap))
			candidates.append_array(_move_candidates(maxi(cap, override_cap), type, true))
	if candidates.is_empty() and not types.is_empty():
		if damaging and settings.guarantee_stab:
			_build_errors.append("No hay STAB de daño con potencia válida para %s." % str(types))
		candidates = _move_candidates(cap, &"", damaging)
	if candidates.is_empty():
		_build_errors.append("No hay movimiento con potencia válida y estos ajustes.")
		return _moves[0]
	for attempt: int in 8:
		var id: StringName = _random(candidates)
		if not used.has(id) and int(_move_power[id]) >= min_power:
			return id
	if min_power > 0:
		var strong: Array = candidates.filter(func(id: StringName) -> bool: return int(_move_power[id]) >= min_power)
		if not strong.is_empty():
			candidates = DataUtil.names(strong)
	var free: Array = candidates.filter(func(id: StringName) -> bool: return not used.has(id))
	return _random(free if not free.is_empty() else candidates)


func _randomize_learnset(id: StringName) -> void:
	var base: Array = input.learnset(id).get("level", [])
	if base.is_empty():
		return
	base = base.duplicate(true)
	if not base.is_empty() and int(base[0][0]) > 1:
		base[0][0] = 1
	var types := _types(id)
	var chance := float(config.get("type_preference_chance", 0.5))
	var result: Array = []
	var used := {}
	for index: int in base.size():
		var entry: Array = base[index]
		var level := int(entry[0])
		var prefer := settings.learnsets == "type_preference" and (index < ceili(base.size() * chance) or rng.randf() < chance)
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
	if first < 0 and not result.is_empty():
		first = 0
		result[0][0] = 1 # Movimientos de evolución (nivel 0) sin nivel 1: normalizar para R.4.
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
	for index: int in base.size():
		if str(base[index][1]) in input.data.get("required_moves", []):
			result[index][1] = str(base[index][1])
	patch.section("learnsets")[String(id)] = result


# --- Objetos y tiendas ---

func _randomize_items() -> void:
	var placements := input.item_placements()
	var ids := placements.keys()
	DataUtil.sort_names(ids)
	for pid: Variant in ids:
		var record: Variant = placements[pid]
		var original := StringName(str(record.get("item", ""))) if record is Dictionary else StringName(str(record))
		if record is Dictionary and record.get("randomize", true) == false:
			continue
		if String(original) in input.data.get("required_items", []) or input.has_item(original) and (input.item(original).is_key_item() or input.item(original).raw.get("randomize", true) == false or input.item(original).pocket == &"machines"):
			continue
		if not _items.is_empty():
			patch.section("items")[str(pid)] = String(_random(_items))


func _randomize_shops() -> void:
	var guaranteed := DataUtil.names(config.get("shop_guaranteed", []))
	var ids := input.shop_ids()
	DataUtil.sort_names(ids)
	for shop_id: StringName in ids:
		var shop: Dictionary = input.shop(shop_id).duplicate(true)
		if shop.get("randomize", true) == false:
			continue
		if _buyable.is_empty():
			_build_errors.append("No hay objetos válidos para tiendas.")
			continue
		var used := {}
		var stock: Array = shop.get("stock", [])
		for t: int in stock.size():
			var tier: Dictionary = stock[t]
			var items: Array = []
			for i: int in tier.get("items", []).size():
				var original := StringName(str(tier.items[i]))
				if String(original) in input.data.get("required_items", []) or input.has_item(original) and (input.item(original).is_key_item() or input.item(original).raw.get("randomize", true) == false):
					items.append(String(original))
					continue
				var chosen: StringName = _random(_buyable)
				for j: int in 8:
					if not used.has(chosen):
						break
					chosen = _random(_buyable)
				used[chosen] = true
				items.append(String(chosen))
			tier["items"] = items
		if stock.is_empty():
			stock.append({"items": []})
			shop["stock"] = stock
		if not stock.is_empty():
			var first_items: Array = stock[0]["items"]
			for g: StringName in guaranteed:
				if String(g) not in first_items:
					first_items.push_front(String(g))
		patch.section("shops")[String(shop_id)] = shop

func _randomize_machines() -> void:
	for kind: String in ["tm", "tutor"]:
		var machines: Dictionary = input.data.get(kind + "_moves", {})
		_seed_module(kind + "_content")
		if settings.get(kind + "_content"):
			for machine_id: String in input.ids(kind + "_moves"):
				var record: Dictionary = machines[machine_id]
				if record.get("randomize", true) == false or str(record.get("move", "")) in input.data.get("required_moves", []):
					continue
				var copy := record.duplicate(true)
				copy["move"] = String(_random(_moves))
				patch.section(kind + "_moves")[machine_id] = copy
		if settings.get(kind + "_compat"):
			for id: StringName in _pool:
				if not input.mutable_species(id):
					continue
				_seed_module(kind + "_compat:" + String(id))
				var compatible: Array[String] = []
				for machine_id: String in input.ids(kind + "_moves"):
					var required: bool = str(machines[machine_id].get("move", "")) in input.data.get("required_moves", [])
					var existing: Array = input.data.get(kind + "_compat", {}).get(String(id), [])
					if required and machine_id in existing or rng.randi_range(0, 99) < int(settings.get(kind + "_percent")):
						compatible.append(machine_id)
				patch.section(kind + "_compat")[String(id)] = compatible

func _randomize_held_items() -> void:
	if _items.is_empty():
		return
	for id: StringName in _pool:
		if not input.mutable_species(id):
			continue
		var base: Array = input.species(id).raw.get("held_items", [])
		if base.is_empty():
			continue
		var result: Array = []
		for entry: Variant in base:
			var item_id := str(entry.get("item", "")) if entry is Dictionary else str(entry)
			if input.has_item(StringName(item_id)) and (input.item(StringName(item_id)).is_key_item() or input.item(StringName(item_id)).raw.get("randomize", true) == false) or entry is Dictionary and entry.get("randomize", true) == false:
				result.append(entry)
			elif entry is Dictionary:
				var copy: Dictionary = entry.duplicate(true)
				copy["item"] = String(_random(_items))
				result.append(copy)
			else:
				result.append(String(_random(_items)))
		_species_patch(id)["held_items"] = result
