class_name EngineDriver
extends BattleDriver
## Adaptador entre la BattleScene y el BattleEngine del Agente 2 (contratos.md §8.5).
## Los BattleEvent pasan tal cual; aquí solo se traducen peticiones y acciones,
## se preparan los datos de los menús y se gasta el objeto de la mochila.

var engine: BattleEngine
var setup: BattleSetup


func _init(battle_setup: BattleSetup) -> void:
	setup = battle_setup
	engine = BattleEngine.new(setup)


func info() -> Dictionary:
	return {
		"kind": &"wild" if setup.is_wild() else &"trainer",
		"trainers": setup.trainers,
		"background": setup.background if setup.background != &"" else setup.environment,
		"bgm": setup.bgm,
		"can_run": setup.can_run,
		"can_lose": setup.can_lose,
		"format": &"double" if setup.format == BattleSetup.Format.DOUBLE else &"single",
		"ally_ai": setup.ally_ai,
		"mega": setup.mega_bracelet,
		"z": setup.z_ring,
		"dynamax": setup.dynamax,
	}


func start() -> Array:
	return engine.start()


func request() -> Dictionary:
	var r := engine.request
	if r == null:
		return {"kind": REQUEST_ACTION}
	var out := {"party_index": r.party_index, "slot": r.slot, "can_run": r.can_run, "can_switch": r.can_switch,
		"can_use_items": r.can_use_items, "usable_moves": r.usable_moves, "can_mega": r.can_mega,
		"z_moves": r.z_moves, "can_dynamax": r.can_dynamax}
	match r.kind:
		BattleRequest.Kind.SWITCH:
			out["kind"] = REQUEST_SWITCH
			out["reason"] = r.reason
		BattleRequest.Kind.LEARN_MOVE:
			out["kind"] = REQUEST_LEARN_MOVE
			out["move_id"] = r.move_id
			out["move_name"] = DataDB.move(r.move_id).name if DataDB.has_move(r.move_id) else String(r.move_id)
			out["moves"] = _moves_of(engine.party(PLAYER)[r.party_index])
		_:
			out["kind"] = REQUEST_ACTION
	return out


func submit(action: Dictionary) -> Array:
	var item := StringName(action.get("item", ""))
	var engine_action: BattleAction
	match StringName(action.get("type", "")):
		&"fight":
			var struggle := engine.request != null and engine.request.usable_moves.is_empty()
			engine_action = BattleAction.fight(-1 if struggle else int(action.get("move_slot", 0)), int(action.get("target_slot", 0)))
			engine_action.mega = bool(action.get("mega", false))
			engine_action.z = bool(action.get("z", false))
			engine_action.dynamax = bool(action.get("dynamax", false))
		&"switch":
			engine_action = BattleAction.switch_to(int(action.get("party_index", 0)))
		&"item":
			if GameState.bag is Bag:
				(GameState.bag as Bag).remove(item)
			engine_action = BattleAction.use_item(item, int(action.get("party_index", -1)))
		&"learn_move":
			engine_action = BattleAction.learn_move(int(action.get("forget_index", -1)))
		_:
			engine_action = BattleAction.run()
	return engine.submit(engine_action)


func is_over() -> bool:
	return engine.is_over()


func outcome() -> StringName:
	return engine.result.outcome


func finish() -> void:
	engine.result.apply_to_game_state(GameState.map_id)


func player_active() -> Dictionary:
	var b := engine.active(PLAYER)
	if b == null:
		return {}
	var p := b.pokemon
	return {"name": p.display_name(), "level": p.level, "hp": p.current_hp, "max_hp": p.max_hp(),
		"moves": _moves_of(p)}


func player_party() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var b := engine.active(PLAYER)
	var members := engine.party(PLAYER)
	for i: int in members.size():
		var p := members[i]
		out.append({"name": p.display_name(), "level": p.level, "hp": p.current_hp, "max_hp": p.max_hp(),
			"able": not p.is_fainted(), "active": b != null and b.party_index == i})
	return out


func battle_items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not (GameState.bag is Bag) or not setup.allow_items:
		return out
	var bag := GameState.bag as Bag
	for id: StringName in bag.battle_items():
		out.append({"id": id, "name": DataDB.item(id).name, "count": bag.count(id)})
	return out


func item_needs_target(item_id: StringName) -> bool:
	return DataDB.has_item(item_id) and DataDB.item(item_id).battle_use == ItemData.USE_ON_POKEMON


func can_use_item(item_id: StringName, party_index: int = -1) -> bool:
	return engine.can_use_item(item_id, party_index)


static func _moves_of(p: Pokemon) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for slot: MoveSlot in p.moves:
		var move := DataDB.move(slot.id)
		out.append({"id": slot.id, "name": move.name, "type": move.type,
			"category": MoveData.Category.keys()[move.category].to_lower(), "pp": slot.pp, "max_pp": slot.max_pp()})
	return out
