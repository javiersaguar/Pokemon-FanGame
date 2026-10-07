extends RefCounted
## Lógica de run_ours.gd: juega los combates de tools/showdown_diff en nuestro BattleEngine con el
## azar fijado por el mismo oráculo que run_showdown.mjs. Se carga cuando ya existen los autoloads.

const MAX_TURNS := 60
const GENERATED := "res://data/generated/"
## Mismo clima con otro identificador en Showdown.
const WEATHER_ALIAS := {"snow": "snowscape"}


# --- Lo que tiene implementado el motor (para que el generador no use lo que falta) ---

static func dump_capabilities(path: String) -> int:
	var moves: Array[String] = []
	var all_moves: Dictionary = _read_json(GENERATED + "moves.json")
	for id: String in all_moves:
		if not bool(all_moves[id].get("needs_script", false)) or Effects.has_move(StringName(id)):
			moves.append(id)
	var abilities: Array[String] = []
	for id: String in _read_json(GENERATED + "abilities.json"):
		if Effects.ability(StringName(id)) != null:
			abilities.append(id)
	var items: Array[String] = []
	for id: String in _read_json(GENERATED + "items.json"):
		if Effects.item(StringName(id)) != null:
			items.append(id)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		printerr("No puedo escribir ", path)
		return 1
	f.store_string(JSON.stringify({"moves": moves, "abilities": abilities, "items": items}))
	print("Capacidades: %d movimientos, %d habilidades, %d objetos." % [moves.size(), abilities.size(), items.size()])
	return 0


static func _read_json(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


# --- Combates ---

static func run_file(specs_path: String, out_path: String) -> int:
	var specs: Variant = JSON.parse_string(FileAccess.get_file_as_string(specs_path))
	if not specs is Array:
		printerr("No puedo leer ", specs_path)
		return 1
	var results: Array = []
	for spec: Dictionary in specs:
		results.append(run_one(spec))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		printerr("No puedo escribir ", out_path)
		return 1
	f.store_string(JSON.stringify(results))
	print("Nuestro motor: %d combates." % results.size())
	return 0


static func run_one(spec: Dictionary) -> Dictionary:
	var res := {"id": spec["id"], "snapshots": [], "final": null, "flags": [], "tags": {}, "log": [], "error": null}
	var setup := BattleSetup.new()
	setup.kind = BattleSetup.Kind.TRAINER
	setup.format = BattleSetup.Format.SINGLE
	setup.player_party = _team(spec["p1"])
	setup.foe_party = _team(spec["p2"])
	setup.player_name = "P1"
	setup.trainers = [{"id": "showdown_diff", "name": "P2", "display_name": "P2", "class_name": "",
		"base_money": 0, "ai_level": 0, "items": []}]
	setup.can_lose = true
	setup.can_run = false
	setup.allow_items = false
	setup.exp_enabled = false
	setup.exp_share = false
	setup.battle_style = &"fixed"
	setup.seed = (int(spec["seed"]) & 0x7FFFFFFF) | 1
	setup.rng_oracle = func(tag: StringName, t: int) -> float:
		if tag == &"speed_tie":
			res["flags"].append({"flag": "speed_tie", "turn": t})
			return 0.0
		res["tags"][String(tag)] = int(res["tags"].get(String(tag), 0)) + 1
		return oracle_u(spec, String(tag), t)
	setup.foe_controller = func(engine: BattleEngine, side_index: int, _slot: int) -> BattleAction:
		return choose(spec, engine, side_index, engine.turn)
	setup.foe_replacement = func(engine: BattleEngine) -> int:
		return engine.side(BattleEngine.FOE).first_able_index()
	setup.turn_observer = func(engine: BattleEngine, t: int) -> void:
		res["snapshots"].append(snapshot(engine, t))
	var engine := BattleEngine.new(setup)
	_log(res, engine.start())
	var guard := 0
	while not engine.is_over() and guard < 2000:
		guard += 1
		if engine.turn >= MAX_TURNS:
			res["flags"].append({"flag": "max_turns", "turn": engine.turn})
			break
		var req := engine.request
		if req == null:
			res["error"] = "El motor no pide ninguna decisión (turno %d)." % engine.turn
			break
		var action: BattleAction
		match req.kind:
			BattleRequest.Kind.ACTION:
				action = choose(spec, engine, BattleEngine.PLAYER, engine.turn + 1)
			BattleRequest.Kind.SWITCH:
				action = BattleAction.switch_to(engine.side(BattleEngine.PLAYER).first_able_index())
			_:
				res["error"] = "Petición inesperada %d (turno %d)." % [req.kind, engine.turn]
				break
		_log(res, engine.submit(action))
	res["final"] = snapshot(engine, engine.turn)
	return res


## Mismo FNV-1a de 32 bits que lib/oracle.mjs.
static func fnv1a(text: String) -> int:
	var h := 0x811c9dc5
	for b: int in text.to_utf8_buffer():
		h = ((h ^ b) * 0x01000193) & 0xFFFFFFFF
	return h


static func oracle_u(spec: Dictionary, tag: String, t: int) -> float:
	var luck: Dictionary = spec.get("luck", {})
	if luck.has(tag):
		return float(luck[tag])
	return float(fnv1a("%d|%s|%d" % [int(spec["seed"]), tag, t])) / 4294967296.0


static func choose(spec: Dictionary, engine: BattleEngine, side_index: int, t: int) -> BattleAction:
	var b := engine.active(side_index)
	var usable := b.usable_moves()
	var n := b.pokemon.moves.size()
	if usable.is_empty() or n == 0:
		return BattleAction.fight(-1)
	var start := fnv1a("%d|choice|%d|%d" % [int(spec["seed"]), side_index, t]) % n
	for k: int in n:
		var i := (start + k) % n
		if i in usable:
			return BattleAction.fight(i)
	return BattleAction.fight(usable[0])


static func snapshot(engine: BattleEngine, t: int) -> Dictionary:
	var sides: Array = []
	for s: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		var team: Array = []
		var act := engine.active(s)
		var party := engine.party(s)
		for i: int in party.size():
			var p: Pokemon = party[i]
			var entry := {"hp": p.current_hp, "status": "fnt" if p.current_hp <= 0 else String(p.status),
				"active": act != null and act.party_index == i and not act.is_fainted()}
			if entry["active"]:
				var boosts := {}
				for k: StringName in act.boosts:
					if int(act.boosts[k]) != 0:
						boosts[String(k)] = int(act.boosts[k])
				entry["boosts"] = boosts
				entry["speed"] = engine.call("_speed", act)
			team.append(entry)
		sides.append(team)
	var weather := String(engine.weather())
	return {"turn": t, "weather": WEATHER_ALIAS.get(weather, weather), "sides": sides}


static func _team(sets: Array) -> Array[Pokemon]:
	var team: Array[Pokemon] = []
	for set: Dictionary in sets:
		var spec := {"species": set["species"], "level": int(set["level"]), "moves": set["moves"],
			"ability": set["ability"], "nature": set["nature"], "ivs": set["ivs"], "evs": set["evs"]}
		if str(set.get("item", "")) != "":
			spec["item"] = set["item"]
		if str(set.get("gender", "")) != "":
			spec["gender"] = "female" if set["gender"] == "F" else "male"
		var p := Pokemon.from_spec(spec)
		# Showdown da siempre los PP al máximo (como con 3 Más PP); si no, se agotan en otro momento.
		for slot: MoveSlot in p.moves:
			slot.pp_ups = 3
			slot.pp = slot.max_pp()
		team.append(p)
	return team


static func _log(res: Dictionary, events: Array[BattleEvent]) -> void:
	for e: BattleEvent in events:
		if e.type == BattleEvent.MESSAGE and str(e.data.get("text", "")) != "":
			res["log"].append(str(e.data["text"]))
		elif e.type == BattleEvent.TURN:
			res["log"].append("|turn|%d" % int(e.data.get("turn", 0)))
