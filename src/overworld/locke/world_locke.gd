class_name WorldLocke
extends RefCounted
## Adaptador del estado puro al mundo. GameState conserva snapshot y Pokémon pendientes.

var rules: LockeRules
var pending: Dictionary = {}
var _legacy_death_count := 0

func _init(saved: Dictionary = {}) -> void:
	_legacy_death_count = int(saved.get("legacy_death_count", 0))
	if saved.has("snapshot"):
		rules = LockeRules.from_dict(saved.snapshot)
		pending = saved.get("pending_captures", {}).duplicate(true)
	else:
		var settings: Dictionary = saved.get("settings", GameState.rom_patch.get("settings", {}))
		var families: Dictionary = saved.get("families", {})
		if families.is_empty():
			families = RandomizerInput.from_datadb().families(RomPatch.from_dict(GameState.rom_patch))
		var templates: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/randomizer/epitafios.json"))
		rules = LockeRules.new(settings, families, templates if templates is Array else [])
		# El guardado anterior tenía resúmenes, sin lápidas ni permisos de captura.
		var legacy := rules.snapshot()
		for zone: String in saved.get("zones", {}):
			var old: Variant = saved.zones[zone]
			var status := str(old.get("status", "lost")) if old is Dictionary else str(old)
			if status != "available":
				legacy.zones[zone] = {"status": "caught" if status == "caught" else "lost"}
		_legacy_death_count = int(saved.get("deaths", 0))
		rules = LockeRules.from_dict(legacy)
	if saved.get("status", "") == "finished":
		var finished := rules.snapshot()
		finished["state"] = "finished"
		rules = LockeRules.from_dict(finished)
	for pokemon: Pokemon in usable_pokemon():
		rules.register_owned(String(pokemon.species_id))
	sync()

func sync() -> void:
	var state := rules.snapshot()
	GameState.randomlocke["snapshot"] = state
	GameState.randomlocke["settings"] = rules.rules()
	GameState.randomlocke["pending_captures"] = pending.duplicate(true)
	GameState.randomlocke["zones"] = state.zones.duplicate(true)
	GameState.randomlocke["legacy_death_count"] = _legacy_death_count
	GameState.randomlocke["deaths"] = state.death_count + _legacy_death_count
	GameState.randomlocke["status"] = "finished" if state.state == "finished" else "in_progress"

func begin(pokemon: Pokemon, zone: String, source: String = "wild") -> Dictionary:
	var encounter := rules.register_encounter(zone, String(pokemon.species_id), pokemon.shiny, source)
	sync()
	EventBus.locke_state_changed.emit()
	return encounter

func can_catch(encounter: Dictionary) -> bool:
	return rules.can_catch(encounter.zone_id, encounter.species, encounter.shiny, encounter.source, encounter.encounter_id)

## El inicial es poseído sin consumir zona. Si se exige mote, se retiene hasta nombrarlo.
func receive(pokemon: Pokemon, encounter: Dictionary = {}, starter: bool = false) -> String:
	if not starter and not can_catch(encounter):
		return ""
	var token := "starter:" + pokemon.uid if starter else str(encounter.encounter_id)
	if bool(rules.rules().get("locke_rules", true)) and bool(rules.rules().get("nickname_required", true)) and pokemon.nickname.strip_edges().is_empty():
		pending[token] = {"pokemon": pokemon.to_dict(), "encounter": encounter.duplicate(true), "starter": starter}
		sync()
		if not GameState.is_input_locked_by(&"locke_nickname"):
			GameState.lock_input(&"locke_nickname")
		EventBus.locke_nickname_requested.emit(token, pokemon.to_dict())
		return "pending"
	return _store(pokemon, encounter, starter)

func complete_capture(token: String, nickname: String) -> String:
	if not pending.has(token) or nickname.strip_edges().is_empty():
		return ""
	var entry: Dictionary = pending[token]
	var pokemon := Pokemon.from_dict(entry.pokemon)
	pokemon.nickname = nickname.strip_edges()
	var where := _store(pokemon, entry.encounter, entry.starter)
	if where != "":
		pending.erase(token)
		if pending.is_empty():
			GameState.unlock_input(&"locke_nickname")
		sync()
	return where

func _store(pokemon: Pokemon, encounter: Dictionary, starter: bool) -> String:
	if GameState.party.is_full() and GameState.pc.is_full():
		return ""
	if not starter and not rules.resolve_encounter(encounter.encounter_id, "caught", record(pokemon)):
		return ""
	if starter:
		GameState.set_flag(&"starter_chosen")
		rules.register_owned(String(pokemon.species_id))
	var where := "party" if GameState.party.add(pokemon) else "pc"
	if where == "pc":
		GameState.pc.deposit(pokemon)
	GameState.pokedex.register(pokemon)
	sync()
	EventBus.locke_state_changed.emit()
	return where

func resolve(encounter: Dictionary, outcome: String) -> void:
	if not encounter.is_empty():
		rules.resolve_encounter(encounter.encounter_id, outcome)
	sync()
	EventBus.locke_state_changed.emit()

## Registrar inmediatamente; retirar al terminar el combate evita mover índices del motor.
func death(pokemon: Pokemon, context: Dictionary) -> Dictionary:
	var grave := rules.register_death(record(pokemon), context)
	sync()
	EventBus.locke_state_changed.emit()
	return grave

func remove_dead() -> void:
	var dead: Dictionary = rules.snapshot().deaths
	for index: int in range(GameState.party.size() - 1, -1, -1):
		if dead.has(GameState.party.get_at(index).uid):
			GameState.party.remove_at(index)
	for uid: String in dead:
		var slot: Vector2i = GameState.pc.find_uid(uid)
		if slot != PCStorage.NO_SLOT:
			GameState.pc.take(slot.x, slot.y)
	sync()

func check_game_over() -> bool:
	var party_records: Array = []
	for pokemon: Pokemon in usable_pokemon():
		party_records.append(record(pokemon))
	# Una captura pendiente de mote sigue viva aunque todavía no se pueda usar.
	for entry: Dictionary in pending.values():
		party_records.append(record(Pokemon.from_dict(entry.pokemon)))
	var finished := rules.is_game_over(party_records, [])
	sync()
	if finished and not GameState.is_input_locked_by(&"locke_finished"):
		GameState.lock_input(&"locke_finished")
		EventBus.locke_game_over.emit(rules.snapshot())
	return finished

static func record(pokemon: Pokemon) -> Dictionary:
	var data := pokemon.to_dict()
	data["species"] = String(pokemon.species_id)
	data["hp"] = pokemon.current_hp
	return data

static func usable_pokemon() -> Array[Pokemon]:
	var result: Array[Pokemon] = []
	if GameState.party is Party:
		result.append_array(GameState.party.members)
	if GameState.pc is PCStorage:
		for box: int in GameState.pc.box_count():
			for slot: int in GameState.pc.box_size():
				var pokemon: Pokemon = GameState.pc.get_pokemon(box, slot)
				if pokemon != null:
					result.append(pokemon)
	return result
