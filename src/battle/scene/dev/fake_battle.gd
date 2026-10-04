class_name FakeBattle
extends BattleDriver
## Combate de mentira para desarrollar y probar la BattleScene mientras no existe
## el BattleEngine del Agente 2. Daño y captura simplificados, sin reglas reales.
## `setup` (Dictionary u objeto) puede traer `trainer_id`, o `species` y `level`,
## y `can_lose`. Si no, salvaje de prueba (fake_battle.json).

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
		"kind": &"wild", "trainer": {}, "background": StringName(_setup_get(setup, "background", "grass")),
		"bgm": &"battle_wild", "can_run": true, "can_lose": bool(_setup_get(setup, "can_lose", false)),
	}
	if trainer_id != &"" and TrainerData.exists(trainer_id):
		var trainer := TrainerData.get_trainer(trainer_id)
		_info["kind"] = &"trainer"
		_info["trainer"] = trainer
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
	var events: Array = [_send_out(FOE, _foes[0])]
	events.append(_send_out(PLAYER, _party[_active]))
	return events


func submit(action: Dictionary) -> Array:
	var events: Array = []
	var me := _party[_active]
	var foe := _foes[_foe_index]
	match StringName(action.get("type", "")):
		&"run":
			if _info["can_run"]:
				events.append(_msg("¡Escapaste sin problemas!"))
				_outcome = &"run"
				return events
			events.append(_msg("¡No puedes huir de un combate contra un entrenador!"))
		&"switch":
			events.append_array(_switch_to(int(action.get("party_index", 0))))
		&"item":
			var item := StringName(action.get("item", ""))
			if item == &"pokeball":
				return _throw_ball(events, foe)
			me["hp"] = mini(me["hp"] + 20, me["max_hp"])
			events.append(_msg("Usaste %s. %s recuperó PS." % [_item_name(item), me["name"]]))
			events.append({"type": &"heal", "side": PLAYER, "hp": me["hp"]})
		&"fight":
			var slot := int(action.get("move_slot", 0))
			events.append_array(_use_move(PLAYER, me, FOE, foe, slot))
			if _outcome != &"" or foe["hp"] <= 0:
				return events
	events.append_array(_foe_turn())
	return events


func needs_switch() -> bool:
	return _must_switch


func submit_switch(party_index: int) -> Array:
	_must_switch = false
	_active = party_index
	return [_send_out(PLAYER, _party[_active])]


func is_over() -> bool:
	return _outcome != &""


func outcome() -> StringName:
	return _outcome


func player_active() -> Dictionary:
	return _party[_active]


func player_party() -> Array[Dictionary]:
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


func _use_move(side: StringName, user: Dictionary, target_side: StringName, target: Dictionary,
		slot: int) -> Array:
	var move: Dictionary = user["moves"][clampi(slot, 0, user["moves"].size() - 1)]
	move["pp"] = maxi(move["pp"] - 1, 0)
	var prefix: String = "El %s enemigo" % user["name"] if side == FOE else user["name"]
	var events: Array = [_msg("¡%s usó %s!" % [prefix, move["name"]])]
	events.append({"type": &"move", "side": side, "target": target_side, "move": move})
	if move["category"] == "status":
		events.append({"type": &"stat_change", "side": target_side, "stat": &"atk", "stages": -1})
		events.append(_msg("¡Bajó el Ataque de %s!" % target["name"]))
		return events
	var critical := _rng.randf() < 0.08
	var effectiveness := 2.0 if move["type"] == "fire" and "grass" in target["types"] else 1.0
	var damage := maxi(1, int(move.get("power", 40) * user["level"] / 40.0 * effectiveness
		* (1.5 if critical else 1.0)) + _rng.randi_range(0, 2))
	target["hp"] = maxi(target["hp"] - damage, 0)
	events.append({"type": &"damage", "side": target_side, "hp": target["hp"],
		"effectiveness": effectiveness, "critical": critical})
	if critical:
		events.append(_msg("¡Un golpe crítico!"))
	if effectiveness > 1.0:
		events.append(_msg("¡Es muy eficaz!"))
	if target["hp"] <= 0:
		events.append_array(_faint(target_side, target))
	return events


func _faint(side: StringName, pokemon: Dictionary) -> Array:
	pokemon["able"] = false
	var events: Array = [{"type": &"faint", "side": side}]
	if side == FOE:
		events.append(_msg("¡El %s enemigo se debilitó!" % pokemon["name"]))
		var me := _party[_active]
		events.append(_msg("¡%s ganó %d puntos de experiencia!" % [me["name"], pokemon["level"] * 9]))
		me["exp"] = float(me["exp"]) + 0.6
		if me["exp"] >= 1.0:
			events.append({"type": &"exp", "side": PLAYER, "exp": 1.0})
			me["exp"] = float(me["exp"]) - 1.0
			me["level"] += 1
			me["max_hp"] += 3
			me["hp"] += 3
			events.append({"type": &"level_up", "side": PLAYER, "level": me["level"],
				"hp": me["hp"], "max_hp": me["max_hp"]})
			events.append(_msg("¡%s subió al nivel %d!" % [me["name"], me["level"]]))
		events.append({"type": &"exp", "side": PLAYER, "exp": me["exp"]})
		_foe_index += 1
		if _foe_index >= _foes.size():
			_outcome = &"win"
		else:
			events.append(_send_out(FOE, _foes[_foe_index]))
	else:
		events.append(_msg("¡%s se debilitó!" % pokemon["name"]))
		if _party.any(func(p: Dictionary) -> bool: return p["able"]):
			_must_switch = true
		else:
			events.append(_msg("¡No te quedan Pokémon que puedan luchar!"))
			_outcome = &"lose"
	return events


func _throw_ball(events: Array, foe: Dictionary) -> Array:
	if _info["kind"] == &"trainer":
		events.append(_msg("¡El entrenador ha bloqueado la Poké Ball!"))
		events.append_array(_foe_turn())
		return events
	var chance: float = 1.0 - float(foe["hp"]) / foe["max_hp"] * 0.7
	var caught := _rng.randf() < chance
	var shakes := 3 if caught else _rng.randi_range(0, 2)
	events.append(_msg("¡Has lanzado una Poké Ball!"))
	events.append({"type": &"ball", "ball": &"pokeball", "shakes": shakes, "caught": caught})
	if caught:
		events.append(_msg("¡Ya está! ¡Has atrapado a %s!" % foe["name"]))
		_outcome = &"caught"
		return events
	events.append(_msg("¡Oh, no! ¡El Pokémon se ha escapado!"))
	events.append_array(_foe_turn())
	return events


func _switch_to(index: int) -> Array:
	var events: Array = [_msg("¡%s, vuelve!" % _party[_active]["name"]), {"type": &"withdraw", "side": PLAYER}]
	_active = index
	events.append(_send_out(PLAYER, _party[_active]))
	return events


func _send_out(side: StringName, pokemon: Dictionary) -> Dictionary:
	return {"type": &"send_out", "side": side, "pokemon": pokemon, "wild": _info["kind"] == &"wild"}


func _msg(text: String) -> Dictionary:
	return {"type": &"message", "text": text}


func _make(spec: Dictionary) -> Dictionary:
	var species := StringName(spec.get("species", "rattata"))
	var level := int(spec.get("level", 5))
	var moves: Array[Dictionary] = []
	var move_ids: Array = spec.get("moves", ["tackle"])
	for move_id: Variant in move_ids:
		moves.append(_move_info(StringName(move_id)))
	var max_hp := 12 + level * 3
	var data := _species_data(species)
	var types: Array = spec.get("types", Array(data.get("types")) if data else ["normal"])
	return {
		"species": species, "name": _species_name(species), "level": level,
		"gender": &"male" if _rng.randf() < 0.5 else &"female", "hp": max_hp, "max_hp": max_hp,
		"status": &"", "shiny": false, "types": types, "exp": 0.3,
		"able": true, "moves": moves,
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
	var data := _species_data(species)
	return str(data.get("name")) if data else String(species).capitalize()


## Datos reales de la especie si el DataDB del Agente 2 ya está (el stub no tiene has_species).
func _species_data(species: StringName) -> Object:
	if DataDB.has_method(&"has_species") and DataDB.call(&"has_species", species):
		return DataDB.species(species) as Object
	return null


func _item_name(item: StringName) -> String:
	return str(_data.get("item_names", {}).get(String(item), String(item).capitalize()))


static func _setup_get(setup: Variant, key: String, default: Variant) -> Variant:
	if setup is Dictionary:
		return setup.get(key, default)
	if setup is Object and key in setup:
		return setup.get(key)
	return default
