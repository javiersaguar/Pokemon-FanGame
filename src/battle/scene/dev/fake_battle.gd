class_name FakeBattle
extends BattleDriver
## Combate de mentira para desarrollar y probar la BattleScene mientras no existe
## el BattleEngine del Agente 2. Daño y captura simplificados, sin reglas reales,
## pero con eventos y peticiones con el mismo formato que el motor (§8.5).
## `setup` (Dictionary u objeto) puede traer `trainer_id`, o `species` y `level`,
## y `can_lose`. Si no, salvaje de prueba (fake_battle.json). No toca la partida.

const DATA_PATH := "res://src/battle/scene/dev/fake_battle.json"

var _data: Dictionary
var _info: Dictionary
var _party: Array[Dictionary] = []
var _active := 0
var _foes: Array[Dictionary] = []
var _foe_index := 0
var _outcome: StringName = &""
var _must_switch := false
var _rng := RandomNumberGenerator.new()


func _init(setup: Variant = null, seed_value: int = -1) -> void:
	_data = JsonFile.read_dict(DATA_PATH)
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()
	for spec: Dictionary in _data.get("player_party", []):
		_party.append(_make(spec))
	var trainer_id := StringName(_setup_get(setup, "trainer_id", ""))
	_info = {
		"kind": &"wild", "trainers": [], "background": StringName(_setup_get(setup, "background", "grass")),
		"bgm": &"battle_wild", "can_run": true, "can_lose": bool(_setup_get(setup, "can_lose", false)),
	}
	if trainer_id != &"" and TrainerData.exists(trainer_id):
		var trainer := TrainerData.get_trainer(trainer_id)
		_info["kind"] = &"trainer"
		_info["trainers"] = [trainer]
		_info["bgm"] = StringName(trainer.get("battle_bgm", "battle_trainer"))
		_info["can_run"] = false
		for spec: Dictionary in trainer.get("party", []):
			_foes.append(_make(spec))
	else:
		var wild: Dictionary = _data.get("wild", {}).duplicate()
		if _setup_get(setup, "species", "") != "":
			wild = {"species": _setup_get(setup, "species", ""), "level": int(_setup_get(setup, "level", 5))}
		_foes.append(_make(wild))


func info() -> Dictionary:
	return _info


func start() -> Array:
	return [_switch_in(FOE, _foe_index), _switch_in(PLAYER, _active)]


func request() -> Dictionary:
	if _must_switch:
		return {"kind": REQUEST_SWITCH, "party_index": _active, "can_run": _info["can_run"]}
	return {"kind": REQUEST_ACTION, "party_index": _active, "can_run": _info["can_run"]}


func submit(action: Dictionary) -> Array:
	var events: Array = []
	var me := _party[_active]
	var foe := _foes[_foe_index]
	match StringName(action.get("type", "")):
		&"run":
			if _info["can_run"]:
				events.append(_ev(&"flee", PLAYER, {"success": true}))
				events.append(_msg("¡Escapaste sin problemas!"))
				return _end(events, &"run")
			events.append(_msg("¡No puedes huir de un combate contra un entrenador!"))
		&"switch":
			var forced := _must_switch
			_must_switch = false
			if not forced:
				events.append(_ev(&"switch_out", PLAYER, {"party_index": _active}))
			_active = int(action.get("party_index", 0))
			events.append(_switch_in(PLAYER, _active))
			if forced:
				return events
		&"item":
			var item := StringName(action.get("item", ""))
			events.append(_msg("%s usó %s." % [_player_name(), _item_name(item)]))
			if item == &"pokeball":
				return _throw_ball(events, foe)
			me["hp"] = mini(me["hp"] + 20, me["max_hp"])
			events.append(_ev(&"heal", PLAYER, {"amount": 20, "hp": me["hp"], "max_hp": me["max_hp"]}))
			events.append(_msg("%s recuperó PS." % me["name"]))
		&"fight":
			events.append_array(_use_move(PLAYER, me, FOE, foe, int(action.get("move_slot", 0))))
			if _outcome != &"" or foe["hp"] <= 0:
				return events
	events.append_array(_foe_turn())
	return events


func is_over() -> bool:
	return _outcome != &""


func outcome() -> StringName:
	return _outcome


func player_active() -> Dictionary:
	return _party[_active]


func player_party() -> Array[Dictionary]:
	for i: int in _party.size():
		_party[i]["active"] = i == _active
	return _party


func battle_items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry: Dictionary in _data.get("items", []):
		out.append({"id": entry["id"], "name": _item_name(StringName(entry["id"])), "count": entry["count"]})
	return out


# --- Internos ---

func _foe_turn() -> Array:
	var foe := _foes[_foe_index]
	var me := _party[_active]
	if foe["hp"] <= 0 or me["hp"] <= 0:
		return []
	return _use_move(FOE, foe, PLAYER, me, _rng.randi_range(0, foe["moves"].size() - 1))


func _use_move(side: int, user: Dictionary, target_side: int, target: Dictionary, slot: int) -> Array:
	var move: Dictionary = user["moves"][clampi(slot, 0, user["moves"].size() - 1)]
	move["pp"] = maxi(move["pp"] - 1, 0)
	var prefix: String = "El %s enemigo" % user["name"] if side == FOE else user["name"]
	var events: Array = [_msg("¡%s usó %s!" % [prefix, move["name"]])]
	events.append(_ev(&"move", side, {
		"move": move["id"], "move_name": move["name"], "type": move["type"], "category": move["category"],
		"target_side": target_side, "target_slot": 0,
	}))
	if move["category"] == "status":
		events.append(_ev(&"boost", target_side, {"stat": &"atk", "amount": -1, "stage": -1}))
		events.append(_msg("¡Bajó el Ataque de %s!" % target["name"]))
		return events
	var critical := _rng.randf() < 0.08
	var effectiveness := 1.0
	for type: Variant in target["types"]:
		if move["type"] == &"fire" and StringName(type) == &"grass":
			effectiveness = 2.0
	var damage := maxi(1, int(move.get("power", 40) * user["level"] / 40.0 * effectiveness
		* (1.5 if critical else 1.0)) + _rng.randi_range(0, 2))
	damage = mini(damage, target["hp"])
	target["hp"] -= damage
	events.append(_ev(&"damage", target_side, {"amount": damage, "hp": target["hp"],
		"max_hp": target["max_hp"], "effectiveness": effectiveness, "critical": critical, "source": &"move"}))
	if critical:
		events.append(_msg("¡Un golpe crítico!"))
	if effectiveness > 1.0:
		events.append(_msg("¡Es muy eficaz!"))
	if target["hp"] <= 0:
		events.append_array(_faint(target_side, target))
	return events


func _faint(side: int, pokemon: Dictionary) -> Array:
	pokemon["able"] = false
	var events: Array = [_ev(&"faint", side, {"party_index": _foe_index if side == FOE else _active})]
	if side == PLAYER:
		events.append(_msg("¡%s se debilitó!" % pokemon["name"]))
		if _party.any(func(p: Dictionary) -> bool: return p["able"]):
			_must_switch = true
			return events
		events.append(_msg("¡No te quedan Pokémon que puedan luchar!"))
		var trainers: Array = _info["trainers"]
		if not trainers.is_empty() and str(trainers[0].get("win_text", "")) != "":
			events.append(_ev(&"trainer_speech", FOE, {"trainer_index": 0, "text": trainers[0]["win_text"]}))
		return _end(events, &"lose")
	events.append(_msg("¡El %s enemigo se debilitó!" % pokemon["name"]))
	var me := _party[_active]
	var gained: int = pokemon["level"] * 9
	events.append(_msg("¡%s ganó %d puntos de experiencia!" % [me["name"], gained]))
	me["exp"] += gained
	while me["exp"] >= me["exp_next_level"]:
		events.append(_exp_event())
		me["level"] += 1
		me["max_hp"] += 3
		me["hp"] += 3
		me["exp_level_start"] = me["exp_next_level"]
		me["exp_next_level"] += 100
		events.append(_ev(&"level_up", PLAYER, {"party_index": _active, "level": me["level"],
			"hp": me["hp"], "max_hp": me["max_hp"]}))
		events.append(_msg("¡%s subió al nivel %d!" % [me["name"], me["level"]]))
	events.append(_exp_event())
	_foe_index += 1
	if _foe_index < _foes.size():
		events.append(_switch_in(FOE, _foe_index))
		return events
	var trainers: Array = _info["trainers"]
	if not trainers.is_empty():
		events.append(_msg("¡Has derrotado a %s!" % trainers[0]["display_name"]))
		events.append(_ev(&"trainer_speech", FOE, {"trainer_index": 0, "text": trainers[0].get("lose_text", "")}))
	return _end(events, &"win")


func _throw_ball(events: Array, foe: Dictionary) -> Array:
	if _info["kind"] == &"trainer":
		events.append(_msg("¡El entrenador ha desviado la Poké Ball!"))
		events.append(_msg("¡No seas maleducado!"))
		events.append_array(_foe_turn())
		return events
	var chance: float = 1.0 - float(foe["hp"]) / foe["max_hp"] * 0.7
	var caught := _rng.randf() < chance
	var shakes := 3 if caught else _rng.randi_range(0, 2)
	events.append(_ev(&"catch", FOE, {"ball": &"pokeball", "shakes": shakes, "caught": caught, "critical": false}))
	if caught:
		events.append(_msg("¡Ya está! ¡Has atrapado a %s!" % foe["name"]))
		return _end(events, &"caught")
	events.append(_msg("¡Oh, no! ¡El Pokémon se ha escapado!"))
	events.append_array(_foe_turn())
	return events


func _end(events: Array, result: StringName) -> Array:
	_outcome = result
	events.append(_ev(&"end", -1, {"outcome": result}))
	return events


func _switch_in(side: int, index: int) -> Dictionary:
	var pokemon: Dictionary = _party[index] if side == PLAYER else _foes[index]
	var data := pokemon.duplicate()
	data["party_index"] = index
	data["wild"] = side == FOE and _info["kind"] == &"wild"
	return _ev(&"switch_in", side, data)


func _exp_event() -> Dictionary:
	var me := _party[_active]
	return _ev(&"exp", PLAYER, {"party_index": _active, "exp": me["exp"], "level": me["level"],
		"exp_level_start": me["exp_level_start"], "exp_next_level": me["exp_next_level"]})


func _ev(type: StringName, side: int, data: Dictionary) -> Dictionary:
	return {"type": type, "side": side, "slot": 0, "data": data}


func _msg(text: String) -> Dictionary:
	return _ev(&"message", -1, {"text": text})


func _make(spec: Dictionary) -> Dictionary:
	var species := StringName(spec.get("species", "rattata"))
	var level := int(spec.get("level", 5))
	var moves: Array[Dictionary] = []
	for move_id: Variant in spec.get("moves", ["tackle"]):
		moves.append(_move_info(StringName(move_id)))
	var max_hp := 12 + level * 3
	var types: Array = spec.get("types", ["normal"])
	if DataDB.has_species(species):
		types = Array(DataDB.species(species).types)
	return {
		"species": species, "name": _species_name(species), "level": level, "types": types,
		"gender": &"male" if _rng.randf() < 0.5 else &"female", "hp": max_hp, "max_hp": max_hp,
		"status": &"", "shiny": false, "able": true, "moves": moves,
		"exp": 30, "exp_level_start": 0, "exp_next_level": 100,
	}


func _move_info(move_id: StringName) -> Dictionary:
	var known: Dictionary = _data.get("moves", {}).get(String(move_id), {})
	var pp := int(known.get("pp", 20))
	return {
		"id": move_id, "name": known.get("name", String(move_id).capitalize()),
		"type": StringName(known.get("type", "normal")), "category": known.get("category", "physical"),
		"power": int(known.get("power", 40)), "pp": pp, "max_pp": pp,
	}


func _species_name(species: StringName) -> String:
	return DataDB.species(species).name if DataDB.has_species(species) else String(species).capitalize()


func _item_name(item: StringName) -> String:
	return str(_data.get("item_names", {}).get(String(item), String(item).capitalize()))


func _player_name() -> String:
	return GameState.player_name if GameState.player_name != "" else "Tú"


static func _setup_get(setup: Variant, key: String, default: Variant) -> Variant:
	if setup is Dictionary:
		return setup.get(key, default)
	if setup is Object and key in setup:
		return setup.get(key)
	return default
