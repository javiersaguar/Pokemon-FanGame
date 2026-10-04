class_name LockeRules
extends RefCounted
## Estado puro: no mueve Pokémon, no guarda archivos, no emite señales. El mundo aplica resultados.

var _rules: Dictionary = {}
var _families: Dictionary = {}
var _epitaphs: Array = []
var _zones: Dictionary = {}
var _encounters: Dictionary = {}
var _owned: Dictionary = {}
var _deaths: Dictionary = {}
var _cemetery: Array = []
var _captures: int = 0
var _sequence: int = 0
var _state: String = "running"

func _init(settings: Dictionary = {}, families: Dictionary = {}, epitaphs: Array = []) -> void:
	_rules = RandomizerSettings.normalize(settings)
	_families = families.duplicate(true)
	_epitaphs = epitaphs.duplicate(true)

func rules() -> Dictionary:
	return _rules.duplicate(true)

func _enabled(key: String) -> bool:
	return bool(_rules.get("locke_rules", true)) and bool(_rules.get(key, false))

func _family(species: String) -> String:
	return str(_families.get(species, species))

func register_owned(species: String) -> void:
	_owned[_family(species)] = true

func _counts(source: String, shiny: bool) -> bool:
	if shiny and _enabled("shiny_clause"):
		return false
	if source in ["gift", "trade"] and not _enabled("gifts_count"):
		return false
	if source == "static" and not _enabled("statics_count"):
		return false
	return _enabled("first_encounter")

func can_catch(zone_id: String, species: String, shiny: bool = false, source: String = "wild", encounter_id: String = "") -> bool:
	if _state != "running" or species.is_empty() or (_enabled("first_encounter") and zone_id.is_empty()):
		return false
	if not encounter_id.is_empty():
		var encounter: Dictionary = _encounters.get(encounter_id, {})
		return not encounter.is_empty() and encounter.zone_id == zone_id and encounter.species == species and encounter.shiny == shiny and encounter.source == source and encounter.allowed and encounter.outcome == "pending"
	if shiny and _enabled("shiny_clause"):
		return true
	if _enabled("duplicates_clause") and _owned.has(_family(species)):
		return false
	return not _counts(source, shiny) or not _zones.has(zone_id)

func register_encounter(zone_id: String, species: String, shiny: bool = false, source: String = "wild", encounter_id: String = "") -> Dictionary:
	if encounter_id.is_empty():
		_sequence += 1
		encounter_id = "encounter_%d" % _sequence
	if _encounters.has(encounter_id):
		var saved: Dictionary = _encounters[encounter_id]
		return saved.duplicate(true) if saved.zone_id == zone_id and saved.species == species and saved.shiny == shiny and saved.source == source else {}
	var allowed := can_catch(zone_id, species, shiny, source)
	var counted := allowed and _counts(source, shiny)
	var reason := "eligible" if allowed else ("duplicate" if _enabled("duplicates_clause") and _owned.has(_family(species)) else "zone_used")
	if _state != "running":
		reason = "finished"
	var record: Dictionary = {"encounter_id": encounter_id, "zone_id": zone_id, "species": species, "shiny": shiny, "source": source, "allowed": allowed, "counted": counted, "reason": reason, "outcome": "pending", "nickname_required": _enabled("nickname_required")}
	_encounters[encounter_id] = record
	if counted:
		_zones[zone_id] = {"status": "pending", "encounter_id": encounter_id, "species": species}
	return record.duplicate(true)

func resolve_encounter(encounter_id: String, outcome: String, pokemon: Dictionary = {}) -> bool:
	if not _encounters.has(encounter_id) or outcome not in ["caught", "run", "fainted", "lost"]:
		return false
	var encounter: Dictionary = _encounters[encounter_id]
	if encounter.outcome != "pending":
		return encounter.outcome == outcome
	if outcome == "caught":
		if _state != "running" or not encounter.allowed or str(pokemon.get("species", "")) != encounter.species:
			return false
		if _enabled("nickname_required") and str(pokemon.get("nickname", "")).strip_edges().is_empty():
			return false
		register_owned(encounter.species)
		_captures += 1
	encounter.outcome = outcome
	if encounter.counted:
		_zones[encounter.zone_id].status = "caught" if outcome == "caught" else "lost"
	return true

func register_death(pokemon: Dictionary, context: Dictionary) -> Dictionary:
	if not _enabled("permadeath"):
		return {}
	var uid := str(pokemon.get("uid", ""))
	if uid.is_empty():
		return {}
	if _deaths.has(uid):
		return _deaths[uid].duplicate(true)
	var grave := pokemon.duplicate(true)
	grave["uid"] = uid
	grave["dead"] = true
	grave["zone_id"] = str(context.get("zone_id", ""))
	grave["opponent"] = str(context.get("opponent", context.get("trainer", context.get("foe_name", ""))))
	grave["reason"] = str(context.get("reason", "fainted"))
	grave["context"] = context.duplicate(true)
	grave["epitaph"] = epitaph_for(grave)
	_deaths[uid] = grave
	_cemetery.append(grave)
	register_owned(str(grave.get("species", "")))
	return grave.duplicate(true)

func epitaph_for(pokemon: Dictionary) -> String:
	if _epitaphs.is_empty():
		return ""
	var key := str(pokemon.get("uid", "")) + ":" + str(pokemon.get("species", ""))
	var index := key.sha256_text().substr(0, 8).hex_to_int() % _epitaphs.size()
	return str(_epitaphs[index]).replace("{nickname}", str(pokemon.get("nickname", pokemon.get("species", "")))).replace("{species}", str(pokemon.get("species", "")))

func level_cap(next_leader_ace_level: int) -> int:
	return maxi(0, next_leader_ace_level) if _enabled("level_cap") else 0

func can_gain_exp(level: int, next_leader_ace_level: int) -> bool:
	var cap := level_cap(next_leader_ace_level)
	return cap == 0 or level < cap

func battle_mode() -> String:
	return "fixed" if _enabled("fixed_battle") else "normal"

func can_use_item(used_this_battle: int) -> bool:
	if not _rules.get("locke_rules", true):
		return true
	match str(_rules.get("battle_items", "allowed")):
		"forbidden":
			return false
		"limited":
			return maxi(0, used_this_battle) < int(_rules.get("battle_item_limit", 0))
	return true

func is_game_over(party: Array, pc: Array) -> bool:
	if _state == "finished":
		return true
	if not _enabled("game_over") or not _enabled("permadeath") or _owned.is_empty():
		return false
	for pokemon: Dictionary in party + pc:
		var uid := str(pokemon.get("uid", ""))
		if not pokemon.get("dead", false) and not pokemon.get("egg", false) and not _deaths.has(uid) and int(pokemon.get("hp", pokemon.get("current_hp", 1))) > 0:
			return false
	_state = "finished"
	return true

func zone_status(zone_id: String) -> String:
	return str(_zones.get(zone_id, {}).get("status", "available"))

func snapshot() -> Dictionary:
	return {"state_version": 1, "rules": _rules.duplicate(true), "families": _families.duplicate(true), "epitaphs": _epitaphs.duplicate(true), "zones": _zones.duplicate(true), "encounters": _encounters.duplicate(true), "owned": _owned.duplicate(true), "deaths": _deaths.duplicate(true), "cemetery": _cemetery.duplicate(true), "captures": _captures, "death_count": _deaths.size(), "sequence": _sequence, "state": _state}

static func from_dict(data: Dictionary) -> LockeRules:
	var result := LockeRules.new(data.get("rules", {}), data.get("families", {}), data.get("epitaphs", []))
	result._zones = data.get("zones", {}).duplicate(true)
	result._encounters = data.get("encounters", {}).duplicate(true)
	result._owned = data.get("owned", {}).duplicate(true)
	result._deaths = data.get("deaths", {}).duplicate(true)
	result._cemetery = data.get("cemetery", []).duplicate(true)
	result._captures = int(data.get("captures", 0))
	result._sequence = int(data.get("sequence", 0))
	result._state = str(data.get("state", "running"))
	return result
