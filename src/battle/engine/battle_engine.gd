class_name BattleEngine
extends RefCounted
## Motor de combate: lógica pura (sin nodos, sin await, sin nada visual). Contrato: docs/contratos.md §8.5.
## La BattleScene le envía decisiones (submit) y reproduce los BattleEvent que devuelve.
## Toda la aleatoriedad sale de `rng` (setup.seed): misma semilla + mismas decisiones = mismo combate.
##
## Por dentro, el combate es una cola de pasos. Cuando hace falta una decisión del jugador
## (acción, cambio tras un debilitado, olvidar un movimiento), el motor deja una `request` y para.

const PLAYER := 0
const FOE := 1
## Probabilidad de crítico 1/n por nivel (7.ª generación en adelante).
const CRIT_CHANCES: Array[int] = [0, 24, 8, 2, 1]
## Reparto de golpes de los movimientos de 2 a 5 golpes (5.ª generación en adelante).
const MULTIHIT_2_TO_5: Array[int] = [2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5]
const STRUGGLE := &"struggle"
const MAX_TOXIC_STAGE := 15
const CONFUSION_SELF_HIT_PERCENT := 33

var setup: BattleSetup
## Decisión pendiente del jugador (null si no hay ninguna o si el combate ha terminado).
var request: BattleRequest = null
var result := BattleResult.new()
var turn: int = 0
var rng := RandomNumberGenerator.new()

var _sides: Array[BattleSide] = []
var _events: Array[BattleEvent] = []
var _queue: Array[Callable] = []
var _pending_faints: Array[Battler] = []
var _started := false
var _over := false
var _flee_attempts := 0
## uid de cada rival -> {uid de los Pokémon del jugador que se han enfrentado a él: true}.
var _participants: Dictionary = {}
## uid de los Pokémon del jugador que han subido de nivel (para las evoluciones del final).
var _leveled: Dictionary = {}


func _init(battle_setup: BattleSetup) -> void:
	setup = battle_setup
	var seed_value := setup.seed
	if seed_value == 0:
		var r := RandomNumberGenerator.new()
		r.randomize()
		seed_value = int(r.randi()) + 1
	rng.seed = seed_value
	result.seed = seed_value
	_sides.append(BattleSide.new(PLAYER, setup.player_party))
	_sides.append(BattleSide.new(FOE, setup.foe_party))
	_sides[PLAYER].active.append(null)
	_sides[FOE].active.append(null)


# --- API pública ---

## Presentación del combate hasta la primera decisión del jugador.
func start() -> Array[BattleEvent]:
	if not _started:
		_started = true
		_queue.append(_step_intro)
	return _run()


## Respuesta a `request`. Devuelve los eventos hasta la siguiente decisión o el final.
func submit(action: BattleAction) -> Array[BattleEvent]:
	if _over or request == null:
		push_error("BattleEngine.submit: no hay ninguna decisión pendiente.")
		return []
	var req := request
	request = null
	match req.kind:
		BattleRequest.Kind.ACTION:
			_begin_turn(action)
		BattleRequest.Kind.SWITCH:
			_resolve_switch_request(action)
		BattleRequest.Kind.LEARN_MOVE:
			_resolve_learn(req, action)
	return _run()


func is_over() -> bool:
	return _over


func active(side_index: int, slot: int = 0) -> Battler:
	return _sides[side_index].active[slot]


func party(side_index: int) -> Array[Pokemon]:
	return _sides[side_index].party


func side(side_index: int) -> BattleSide:
	return _sides[side_index]


## ¿Tiene efecto usar `item_id` ahora (sobre el Pokémon `party_index` del jugador)?
func can_use_item(item_id: StringName, party_index: int = -1) -> bool:
	if _over or not setup.allow_items or not DataDB.has_item(item_id):
		return false
	var it := DataDB.item(item_id)
	if it.battle_use == ItemData.USE_NONE:
		return false
	if it.is_ball():
		return setup.is_wild() and active(FOE) != null and not active(FOE).is_fainted()
	if it.effect == &"flee":
		return setup.is_wild()
	var b := active(PLAYER)
	var p: Pokemon = b.pokemon if party_index < 0 else (party(PLAYER)[party_index] if party_index < party(PLAYER).size() else null)
	if p == null:
		return false
	var on_field := _battler_of(PLAYER, party_index) if party_index >= 0 else b
	match it.effect:
		&"heal_hp":
			return not p.is_fainted() and p.current_hp < p.max_hp()
		&"heal_and_cure":
			return not p.is_fainted() and (p.current_hp < p.max_hp() or p.status != &"" \
				or (on_field != null and on_field.has_volatile(&"confusion")))
		&"cure_status":
			var statuses: Array = it.param("statuses", [])
			return not p.is_fainted() and (String(p.status) in statuses \
				or (bool(it.param("confusion", false)) and on_field != null and on_field.has_volatile(&"confusion")))
		&"revive":
			return p.is_fainted()
		&"restore_pp":
			for slot: MoveSlot in p.moves:
				if slot.pp < slot.max_pp():
					return true
			return false
		&"boost_stat":
			return on_field != null and on_field.boosts.get(StringName(str(it.param("stat", "atk"))), 0) < 6
		&"crit_boost":
			return on_field != null and on_field.crit_stage == 0
	return false


## Daño que haría `move` sin RNG ni crítico (para la IA). 0 si no hace daño o no afecta.
func estimate_damage(user: Battler, target: Battler, move: MoveData) -> int:
	if move == null or move.is_status() or target == null or _is_immune(target, move):
		return 0
	if move.ohko != &"":
		return 0
	if move.level_damage:
		return mini(user.pokemon.level, target.pokemon.current_hp)
	if move.fixed_damage > 0:
		return mini(move.fixed_damage, target.pokemon.current_hp)
	if move.power <= 0:
		return 0
	var hits := (move.multihit_min + move.multihit_max) / 2.0
	var damage := int(DamageCalc.calculate(user, target, move, false, 7) * hits)
	return mini(damage, target.pokemon.current_hp)


# --- Bucle ---

func _run() -> Array[BattleEvent]:
	while not _queue.is_empty() and request == null and not _over:
		var step: Callable = _queue.pop_front()
		step.call()
	if not _over and request == null:
		push_error("BattleEngine: la cola se ha vaciado sin pedir ninguna decisión.")
	var out := _events
	_events = []
	return out


## Pone `steps` (en ese orden) delante de todo lo que queda en la cola.
func _push_front(steps: Array[Callable]) -> void:
	for i: int in range(steps.size() - 1, -1, -1):
		_queue.push_front(steps[i])


func _emit(type: StringName, event_side: int = -1, slot: int = -1, data: Dictionary = {}) -> void:
	_events.append(BattleEvent.make(type, event_side, slot, data))


## `tag` marca los textos de presentación que la escena puede poner a su manera
## (wild_appear, challenge, send_out, recall, defeat); vacío en los de mecánicas.
func _msg(text: String, tag: String = "") -> void:
	_emit(BattleEvent.MESSAGE, -1, -1, {"text": text, "tag": tag} if tag != "" else {"text": text})


# --- Inicio y peticiones ---

func _step_intro() -> void:
	var foe_index := _sides[FOE].first_able_index()
	var player_index := _sides[PLAYER].first_able_index()
	if foe_index < 0 or player_index < 0:
		push_error("BattleEngine: un bando no tiene ningún Pokémon que pueda luchar.")
		_finish(BattleResult.LOSE if player_index < 0 else BattleResult.WIN)
		return
	if setup.is_wild():
		_put_in(FOE, foe_index, true)
		_msg(tr("¡Un %s salvaje apareció!") % party(FOE)[foe_index].display_name(), "wild_appear")
	else:
		_msg(tr("¡%s te desafía!") % _trainer_name(), "challenge")
		_send_out(FOE, foe_index)
	_send_out(PLAYER, player_index)
	_queue.append(_step_next_request)


func _step_next_request() -> void:
	var b := active(PLAYER)
	var r := BattleRequest.new()
	r.kind = BattleRequest.Kind.ACTION
	r.side = PLAYER
	r.slot = b.slot
	r.party_index = b.party_index
	r.can_run = setup.is_wild() and setup.can_run
	r.can_switch = _sides[PLAYER].first_able_index() >= 0
	r.can_use_items = setup.allow_items
	r.usable_moves = b.usable_moves()
	request = r


# --- Turno ---

func _begin_turn(player_action: BattleAction) -> void:
	turn += 1
	_emit(BattleEvent.TURN, -1, -1, {"turn": turn})
	var entries: Array[Dictionary] = []
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b == null or b.is_fainted():
			continue
		var action := _sanitize(b, player_action) if side_index == PLAYER else BattleAI.choose_action(self, side_index, b.slot, setup.ai_level)
		b.moved_this_turn = false
		entries.append({
			"battler": b,
			"action": action,
			"order": BattleAction.ORDER[action.kind],
			"priority": _action_priority(b, action),
			"speed": b.effective_speed(),
			"tie": rng.randf(),
		})
	entries.sort_custom(_entry_goes_first)
	for e: Dictionary in entries:
		_queue.append(_step_action.bind(e))
	_queue.append(_step_end_of_turn)
	_queue.append(_step_player_replacement)
	_queue.append(_step_foe_replacement)
	_queue.append(_step_next_request)


## Huir y cambiar primero, luego objetos y luego movimientos por prioridad y Velocidad; empate al azar.
func _entry_goes_first(a: Dictionary, b: Dictionary) -> bool:
	if a["order"] != b["order"]:
		return a["order"] < b["order"]
	if a["priority"] != b["priority"]:
		return a["priority"] > b["priority"]
	if a["speed"] != b["speed"]:
		return a["speed"] > b["speed"]
	return a["tie"] < b["tie"]


func _action_priority(b: Battler, action: BattleAction) -> int:
	if action.kind != BattleAction.Kind.FIGHT:
		return 0
	var m := _move_for(b, action.move_index)
	return m.priority if m else 0


## Corrige acciones imposibles del jugador (la interfaz no debería enviarlas).
func _sanitize(b: Battler, action: BattleAction) -> BattleAction:
	var usable := b.usable_moves()
	var fallback := BattleAction.fight(usable[0] if not usable.is_empty() else -1)
	match action.kind:
		BattleAction.Kind.FIGHT:
			if usable.is_empty():
				return BattleAction.fight(-1)
			if action.move_index not in usable:
				push_error("BattleEngine: el movimiento %d no se puede usar." % action.move_index)
				return fallback
		BattleAction.Kind.SWITCH:
			if not _sides[PLAYER].can_switch_to(action.party_index):
				push_error("BattleEngine: no se puede cambiar al Pokémon %d." % action.party_index)
				return fallback
		BattleAction.Kind.ITEM:
			if not can_use_item(action.item_id, action.party_index):
				push_error("BattleEngine: el objeto '%s' no se puede usar ahora." % action.item_id)
				return fallback
		BattleAction.Kind.RUN:
			if not (setup.is_wild() and setup.can_run):
				push_error("BattleEngine: no se puede huir de este combate.")
				return fallback
		_:
			return fallback
	return action


func _step_action(entry: Dictionary) -> void:
	var b: Battler = entry["battler"]
	if _over or b.is_fainted() or active(b.side) != b:
		return
	var action: BattleAction = entry["action"]
	match action.kind:
		BattleAction.Kind.RUN:
			_do_run(b)
		BattleAction.Kind.SWITCH:
			_do_switch(b, action.party_index)
		BattleAction.Kind.ITEM:
			_do_item(b, action)
		BattleAction.Kind.FIGHT:
			_do_move(b, action)
	b.moved_this_turn = true
	_process_faints()


func _step_end_of_turn() -> void:
	if _over:
		return
	var order: Array[Battler] = []
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b != null and not b.is_fainted():
			order.append(b)
	order.sort_custom(func(a: Battler, c: Battler) -> bool: return a.effective_speed() > c.effective_speed())
	for b: Battler in order:
		_residual_status(b)
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b != null:
			b.volatiles.erase(&"flinch")
			b.turns_active += 1
	_process_faints()


@warning_ignore("integer_division")
func _residual_status(b: Battler) -> void:
	var p := b.pokemon
	var name := BattleText.cap_name(b, setup.is_wild())
	match p.status:
		&"psn":
			_msg(tr("¡%s sufre los efectos del veneno!") % name)
			_damage(b, maxi(1, p.max_hp() / 8), &"psn")
		&"tox":
			b.toxic_stage = mini(b.toxic_stage + 1, MAX_TOXIC_STAGE)
			_msg(tr("¡%s sufre los efectos del veneno!") % name)
			_damage(b, maxi(1, p.max_hp() / 16) * b.toxic_stage, &"tox")
		&"brn":
			_msg(tr("¡%s se resiente de la quemadura!") % name)
			_damage(b, maxi(1, p.max_hp() / 16), &"brn")


# --- Debilitados, final y reemplazos ---

func _process_faints() -> void:
	if _pending_faints.is_empty():
		return
	var steps: Array[Callable] = []
	for b: Battler in _pending_faints:
		_emit(BattleEvent.FAINT, b.side, b.slot, {"party_index": b.party_index})
		_msg(tr("¡%s se debilitó!") % BattleText.cap_name(b, setup.is_wild()))
		if b.side == FOE:
			steps.append(_step_award_exp.bind(b.pokemon))
	_pending_faints.clear()
	steps.append(_step_check_end)
	_push_front(steps)


func _step_check_end() -> void:
	if _sides[PLAYER].all_fainted():
		_finish(BattleResult.LOSE)
	elif _sides[FOE].all_fainted():
		_finish(BattleResult.WIN)


func _step_player_replacement() -> void:
	var b := active(PLAYER)
	if _over or not b.is_fainted() or not _sides[PLAYER].has_able():
		return
	var r := BattleRequest.new()
	r.kind = BattleRequest.Kind.SWITCH
	r.side = PLAYER
	r.slot = b.slot
	r.party_index = b.party_index
	r.can_run = setup.is_wild() and setup.can_run
	r.can_switch = true
	r.can_use_items = false
	request = r


func _resolve_switch_request(action: BattleAction) -> void:
	if action.kind == BattleAction.Kind.RUN and setup.is_wild() and setup.can_run:
		_emit(BattleEvent.FLEE, PLAYER, 0, {"success": true})
		_msg(tr("¡Escapaste sin problemas!"))
		_finish(BattleResult.RUN)
		return
	var index := action.party_index
	if action.kind != BattleAction.Kind.SWITCH or not _sides[PLAYER].can_switch_to(index):
		push_error("BattleEngine: cambio no válido (%s)." % action)
		index = _sides[PLAYER].first_able_index()
	_send_out(PLAYER, index)


func _step_foe_replacement() -> void:
	var b := active(FOE)
	if _over or not b.is_fainted() or not _sides[FOE].has_able():
		return
	_send_out(FOE, BattleAI.choose_replacement(self, FOE))


@warning_ignore("integer_division")
func _finish(outcome: StringName) -> void:
	if _over:
		return
	_queue.clear()
	request = null
	if outcome == BattleResult.WIN and not setup.is_wild():
		var money := 0
		for i: int in setup.trainers.size():
			var t := setup.trainers[i]
			_msg(tr("¡Has derrotado a %s!") % str(t.get("display_name", "")))
			if str(t.get("lose_text", "")) != "":
				_emit(BattleEvent.TRAINER_SPEECH, FOE, -1, {"trainer_index": i, "text": str(t["lose_text"])})
			var last: Pokemon = party(FOE).back() if not party(FOE).is_empty() else null
			money += int(t.get("base_money", 0)) * (last.level if last else 0)
		if money > 0:
			result.money_won = money
			_msg(BattleText.money_won(money))
			_emit(BattleEvent.MONEY, -1, -1, {"amount": money})
	elif outcome == BattleResult.LOSE:
		for i: int in setup.trainers.size():
			var t := setup.trainers[i]
			if str(t.get("win_text", "")) != "":
				_emit(BattleEvent.TRAINER_SPEECH, FOE, -1, {"trainer_index": i, "text": str(t["win_text"])})
		if setup.player_name != "":
			_msg(tr("¡A %s no le quedan Pokémon que puedan luchar!") % setup.player_name, "defeat")
		else:
			_msg(tr("¡No te quedan Pokémon que puedan luchar!"), "defeat")
	result.outcome = outcome
	result.turns = turn
	_collect_evolutions()
	_emit(BattleEvent.END, -1, -1, {"outcome": String(outcome)})
	_over = true


func _collect_evolutions() -> void:
	var members := party(PLAYER)
	var species_list: Array[StringName] = []
	var types_list: Array[StringName] = []
	for p: Pokemon in members:
		species_list.append(p.species_id)
		for t: StringName in p.types():
			if t not in types_list:
				types_list.append(t)
	var context := {"time": setup.time_period, "party_species": species_list, "party_types": types_list, "weather": setup.weather}
	for i: int in members.size():
		var p := members[i]
		if not _leveled.has(p.uid) or p.is_fainted():
			continue
		var evo := EvolutionRules.level_up_evolution(p, context)
		if not evo.is_empty():
			result.pending_evolutions.append({"party_index": i, "uid": p.uid, "to": String(evo["to"]), "evolution": evo})


# --- Cambios ---

func _send_out(side_index: int, index: int) -> void:
	var p := party(side_index)[index]
	if side_index == PLAYER:
		_msg(tr("¡Adelante, %s!") % p.display_name(), "send_out")
	else:
		_msg(tr("¡%s sacó a %s!") % [_trainer_name(), p.display_name()], "send_out")
	_put_in(side_index, index, false)


func _put_in(side_index: int, index: int, wild_appearance: bool) -> void:
	var p := party(side_index)[index]
	var b := Battler.new(p, side_index, 0, index)
	_sides[side_index].active[0] = b
	var s := p.species()
	var data := {
		"party_index": index,
		"species": String(p.species_id),
		"form_name": s.form_name,
		"name": p.display_name(),
		"level": p.level,
		"gender": String(p.gender),
		"shiny": p.shiny,
		"hp": p.current_hp,
		"max_hp": p.max_hp(),
		"status": String(p.status),
		"wild": wild_appearance,
	}
	if side_index == PLAYER:
		data["exp"] = p.exp
		data["exp_level_start"] = p.exp_at_level_start()
		data["exp_next_level"] = p.exp_at_next_level()
		var foe := active(FOE)
		if foe != null and not foe.is_fainted():
			_mark_participant(foe.pokemon, p)
	else:
		if p.species_id not in result.seen_species:
			result.seen_species.append(p.species_id)
		var mine := active(PLAYER)
		if mine != null and not mine.is_fainted():
			_mark_participant(p, mine.pokemon)
	_emit(BattleEvent.SWITCH_IN, side_index, 0, data)


func _mark_participant(foe: Pokemon, mine: Pokemon) -> void:
	if not _participants.has(foe.uid):
		_participants[foe.uid] = {}
	_participants[foe.uid][mine.uid] = true


func _do_switch(b: Battler, index: int) -> void:
	if b.side == PLAYER:
		_msg(tr("¡%s, vuelve!") % b.pokemon.display_name(), "recall")
	else:
		_msg(tr("¡%s ha retirado a %s!") % [_trainer_name(), b.pokemon.display_name()], "recall")
	_emit(BattleEvent.SWITCH_OUT, b.side, b.slot, {"party_index": b.party_index})
	_send_out(b.side, index)


# --- Huir ---

@warning_ignore("integer_division")
func _do_run(b: Battler) -> void:
	var foe := active(FOE)
	_flee_attempts += 1
	var mine := b.effective_speed()
	var theirs := maxi(1, foe.effective_speed())
	var escaped := mine >= theirs
	if not escaped:
		var odds := mine * 128 / theirs + 30 * _flee_attempts
		escaped = odds > 255 or rng.randi_range(0, 255) < odds
	_emit(BattleEvent.FLEE, PLAYER, b.slot, {"success": escaped})
	if escaped:
		_msg(tr("¡Escapaste sin problemas!"))
		_finish(BattleResult.RUN)
	else:
		_msg(tr("¡No has podido escapar!"))


# --- Objetos ---

func _do_item(b: Battler, action: BattleAction) -> void:
	var it := DataDB.item(action.item_id)
	result.items_used.append(it.id)
	if it.is_ball():
		_throw_ball(b, it)
		return
	var index := action.party_index if action.party_index >= 0 else b.party_index
	var p := party(PLAYER)[index]
	var on_field := _battler_of(PLAYER, index)
	var who := p.display_name()
	_msg(tr("¡%s ha usado %s!") % [setup.player_name, it.name] if setup.player_name != "" else tr("¡Has usado %s!") % it.name)
	_emit(BattleEvent.ITEM_USED, PLAYER, b.slot, {"item": String(it.id), "item_name": it.name, "party_index": index})
	match it.effect:
		&"heal_hp", &"heal_and_cure":
			var amount := int(it.param("amount", 0))
			if it.effect_params.has("fraction"):
				amount = maxi(1, roundi(p.max_hp() * float(it.param("fraction"))))
			var healed := _heal_pokemon(p, on_field, amount, &"item")
			if healed > 0:
				_msg(tr("¡%s ha recuperado %d PS!") % [who, healed])
			if it.effect == &"heal_and_cure":
				_cure_pokemon(p, on_field, [], true)
		&"cure_status":
			_cure_pokemon(p, on_field, it.param("statuses", []), bool(it.param("confusion", false)))
		&"revive":
			if p.revive(float(it.param("fraction", 0.5))):
				_msg(tr("¡%s se ha reanimado!") % who)
		&"restore_pp":
			var slots: Array[MoveSlot] = []
			if bool(it.param("all_moves", false)):
				slots = p.moves
			elif action.move_index >= 0 and action.move_index < p.moves.size():
				slots.append(p.moves[action.move_index])
			else:
				for slot: MoveSlot in p.moves:
					if slots.is_empty() and slot.pp < slot.max_pp():
						slots.append(slot)
			for slot: MoveSlot in slots:
				slot.restore(-1 if bool(it.param("full", false)) else int(it.param("amount", 10)))
			_msg(tr("¡Se han restaurado los PP de %s!") % who)
		&"boost_stat":
			if on_field != null:
				var boosts: Dictionary[StringName, int] = {StringName(str(it.param("stat", "atk"))): int(it.param("stages", 1))}
				_apply_boosts(on_field, boosts, false)
		&"crit_boost":
			if on_field != null:
				on_field.crit_stage += int(it.param("stages", 2))
				_msg(tr("¡%s se está concentrando!") % who)
		&"flee":
			_emit(BattleEvent.FLEE, PLAYER, b.slot, {"success": true})
			_msg(tr("¡Escapaste sin problemas!"))
			_finish(BattleResult.RUN)
		_:
			_msg(tr("No ha tenido ningún efecto."))


func _heal_pokemon(p: Pokemon, on_field: Battler, amount: int, source: StringName) -> int:
	if on_field != null:
		return _heal(on_field, amount, source)
	return p.heal(amount)


## Cura los estados de `statuses` (vacío = todos) y, si `confusion`, la confusión.
func _cure_pokemon(p: Pokemon, on_field: Battler, statuses: Array, confusion: bool) -> void:
	if p.status != &"" and (statuses.is_empty() or String(p.status) in statuses):
		if on_field != null:
			_cure_status(on_field)
		else:
			var old := p.status
			p.cure_status()
			_msg(BattleText.STATUS_CURED[old] % p.display_name())
	if confusion and on_field != null and on_field.has_volatile(&"confusion"):
		_end_confusion(on_field)


func _throw_ball(b: Battler, ball: ItemData) -> void:
	var foe := active(FOE)
	_msg(tr("¡%s ha lanzado una %s!") % [setup.player_name, ball.name] if setup.player_name != "" else tr("¡Has lanzado una %s!") % ball.name)
	if not setup.is_wild():
		_emit(BattleEvent.CATCH, FOE, foe.slot, {"ball": String(ball.id), "shakes": 0, "caught": false, "critical": false, "blocked": true})
		_msg(tr("¡El Entrenador ha desviado la Ball!"))
		_msg(tr("¡No seas ladrón!"))
		return
	var context := {
		"turn": turn, "environment": setup.environment, "time_period": setup.time_period,
		"caught_species": setup.caught_species, "user": b,
	}
	var multiplier := CatchCalc.ball_multiplier(ball, foe, context)
	var p := foe.pokemon
	var a := CatchCalc.catch_value(p.max_hp(), p.current_hp, p.species().catch_rate, multiplier, p.status)
	var attempt := CatchCalc.attempt(rng, a, setup.dex_caught_count)
	_emit(BattleEvent.CATCH, FOE, foe.slot, {
		"ball": String(ball.id), "shakes": attempt["shakes"], "caught": attempt["caught"], "critical": attempt["critical"],
	})
	if not attempt["caught"]:
		_msg(tr(BattleText.CATCH_FAIL[attempt["shakes"]]))
		return
	p.ball = ball.id
	if bool(ball.param("heals", false)):
		p.heal_full()
	if ball.effect_params.has("set_friendship"):
		p.friendship = int(ball.param("set_friendship"))
	result.caught_pokemon = p
	_msg(tr("¡Ya está! ¡Has atrapado a %s!") % p.display_name())
	var steps: Array[Callable] = [_step_award_exp.bind(p), _finish.bind(BattleResult.CAUGHT)]
	_push_front(steps)


# --- Movimientos ---

func _move_for(b: Battler, index: int) -> MoveData:
	if index < 0 or index >= b.pokemon.moves.size():
		return DataDB.move(STRUGGLE)
	return b.pokemon.moves[index].data()


func _do_move(user: Battler, action: BattleAction) -> void:
	var slot: MoveSlot = null
	var move: MoveData
	if action.move_index >= 0 and action.move_index < user.pokemon.moves.size():
		slot = user.pokemon.moves[action.move_index]
		move = slot.data()
	else:
		move = DataDB.move(STRUGGLE)
	if not _before_move(user, move):
		return
	if slot != null:
		slot.pp = maxi(0, slot.pp - 1)
	else:
		_msg(tr("¡A %s no le quedan movimientos!") % BattleText.name_of(user, setup.is_wild()))
	user.last_move = move.id
	_use_move(user, move)
	if move.selfdestruct == &"always" and not user.is_fainted():
		_damage(user, user.pokemon.current_hp, &"selfdestruct")


## Sueño, congelación, retroceso, confusión y parálisis (en el orden de Showdown). false = no se mueve.
func _before_move(user: Battler, move: MoveData) -> bool:
	var p := user.pokemon
	var name := BattleText.cap_name(user, setup.is_wild())
	if p.status == &"slp":
		p.status_turns -= 1
		if p.status_turns <= 0:
			_cure_status(user)
		else:
			_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "slp"})
			_msg(tr("%s está dormido.") % name)
			if not move.sleep_usable:
				return false
	if p.status == &"frz":
		if move.has_flag(&"defrost") or rng.randi_range(0, 4) == 0:
			_cure_status(user)
		else:
			_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "frz"})
			_msg(tr("¡%s está congelado!") % name)
			return false
	if user.has_volatile(&"flinch"):
		_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "flinch"})
		_msg(tr("¡%s retrocedió!") % name)
		return false
	if user.has_volatile(&"confusion"):
		user.volatiles[&"confusion"]["turns"] = int(user.volatiles[&"confusion"]["turns"]) - 1
		if int(user.volatiles[&"confusion"]["turns"]) <= 0:
			_end_confusion(user)
		else:
			_msg(tr("¡%s está confuso!") % name)
			if rng.randi_range(0, 99) < CONFUSION_SELF_HIT_PERCENT:
				_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "confusion"})
				_msg(tr("¡Está tan confuso que se ha herido a sí mismo!"))
				_damage(user, DamageCalc.confusion_damage(user, rng.randi_range(0, DamageCalc.ROLLS - 1)), &"confusion")
				return false
	if p.status == &"par" and rng.randi_range(0, 3) == 0:
		_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "par"})
		_msg(tr("¡%s está paralizado! ¡No se puede mover!") % name)
		return false
	return true


func _use_move(user: Battler, move: MoveData) -> void:
	var wild := setup.is_wild()
	_msg(tr("¡%s usó %s!") % [BattleText.cap_name(user, wild), move.name])
	var target := user if move.targets_user() else _foe_of(user)
	_emit(BattleEvent.MOVE, user.side, user.slot, {
		"move": String(move.id), "move_name": move.name, "type": String(move.type),
		"category": String(MoveData.CATEGORY_IDS.find_key(move.category)),
		"target_side": target.side if target else -1, "target_slot": target.slot if target else -1,
	})
	if move.target in MoveData.FIELD_TARGETS or not _supported(move):
		_msg(tr("¡Pero falló!"))
		return
	if target == null or target.is_fainted():
		_msg(tr("¡Pero no había ningún objetivo!"))
		return
	if target != user:
		if _is_immune(target, move) or (move.ohko != &"" and target.pokemon.level > user.pokemon.level):
			_msg(tr("No afecta %s...") % BattleText.to_name(target, wild))
			return
		if not _accuracy_hits(user, target, move):
			_emit(BattleEvent.MISS, target.side, target.slot, {})
			_msg(tr("¡El ataque %s ha fallado!") % BattleText.of_name(user, wild))
			return
	if move.is_status():
		_apply_status_move(user, target, move)
	else:
		_apply_damaging_move(user, target, move)


## ¿Lo resuelve el motor con sus datos? Hasta la Fase 9, los que necesitan script hacen solo la
## parte que está en los datos (daño, cambios de características, estado, curación) y fallan si
## no tienen ninguna (Desarrollo sube Ataque y At. Esp. aunque falte el efecto del sol).
func _supported(move: MoveData) -> bool:
	if not move.needs_script:
		return true
	if move.is_status():
		return not move.boosts.is_empty() or not move.self_boosts.is_empty() or move.status != &"" \
			or not move.heal.is_empty() or move.volatile_status == &"confusion"
	return move.power > 0 or move.fixed_damage > 0 or move.level_damage


func _foe_of(b: Battler) -> Battler:
	return active(1 - b.side)


func _battler_of(side_index: int, party_index: int) -> Battler:
	var b := active(side_index)
	return b if b != null and b.party_index == party_index else null


## Inmunidad por tipo (los de estado la ignoran salvo que el movimiento diga lo contrario) o por polvos.
func _is_immune(target: Battler, move: MoveData) -> bool:
	if DamageCalc.is_typeless(move):
		return false
	for t: StringName in target.types():
		if DataDB.type_effectiveness(move.type, [t]) == 0.0 and not move.ignores_immunity_of(t):
			return true
		if move.has_flag(&"powder") and DataDB.type_immune_to(t, &"powder"):
			return true
	if move.ohko != &"" and move.ohko != &"any" and target.has_type(move.ohko):
		return true
	return false


func _accuracy_hits(user: Battler, target: Battler, move: MoveData) -> bool:
	if move.ohko != &"":
		var accuracy := 20 if move.ohko == &"ice" and not user.has_type(&"ice") else 30
		accuracy += user.pokemon.level - target.pokemon.level
		return rng.randi_range(0, 99) < accuracy
	if move.accuracy <= 0:
		return true
	var stage: int = user.boosts[&"accuracy"]
	if not move.ignore_evasion:
		stage = clampi(stage - target.boosts[&"evasion"], -6, 6)
	return rng.randi_range(0, 99) < StatCalc.apply_accuracy_stage(move.accuracy, stage)


func _roll_hits(move: MoveData) -> int:
	if move.multihit_min == 2 and move.multihit_max == 5:
		return MULTIHIT_2_TO_5[rng.randi_range(0, MULTIHIT_2_TO_5.size() - 1)]
	if move.multihit_min != move.multihit_max:
		return rng.randi_range(move.multihit_min, move.multihit_max)
	return move.multihit_min


func _roll_crit(user: Battler, move: MoveData) -> bool:
	if move.will_crit:
		return true
	var ratio := clampi(move.crit_ratio + user.crit_stage, 0, CRIT_CHANCES.size() - 1)
	return ratio > 0 and rng.randi_range(0, CRIT_CHANCES[ratio] - 1) == 0


func _apply_damaging_move(user: Battler, target: Battler, move: MoveData) -> void:
	var wild := setup.is_wild()
	var fixed := move.ohko != &"" or move.level_damage or move.fixed_damage > 0
	var effectiveness := 1.0 if fixed else DamageCalc.effectiveness(move, target)
	var hits := _roll_hits(move)
	var total := 0
	var landed := 0
	for i: int in hits:
		if target.is_fainted() or user.is_fainted():
			break
		var crit := false
		var amount: int
		if move.ohko != &"":
			amount = target.pokemon.max_hp()
		elif move.level_damage:
			amount = user.pokemon.level
		elif move.fixed_damage > 0:
			amount = move.fixed_damage
		else:
			crit = _roll_crit(user, move)
			amount = DamageCalc.calculate(user, target, move, crit, rng.randi_range(0, DamageCalc.ROLLS - 1))
		total += _damage(target, amount, &"move", effectiveness, crit)
		landed += 1
		if crit:
			_msg(tr("¡Un golpe crítico!"))
		if target.pokemon.status == &"frz" and not target.is_fainted() and (move.type == &"fire" or move.thaws_target):
			_cure_status(target)
		for sec: Dictionary in move.secondaries:
			if rng.randi_range(0, 99) < int(sec.get("chance", 100)):
				_apply_secondary(user, target, sec)
	if move.ohko != &"" and target.is_fainted():
		_msg(tr("¡Es un golpe fulminante!"))
	if not fixed:
		if effectiveness > 1.0:
			_msg(tr("¡Es supereficaz!"))
		elif effectiveness < 1.0:
			_msg(tr("No es muy eficaz..."))
	if move.is_multihit():
		_msg(tr("¡Ha golpeado %d veces!") % landed if landed != 1 else tr("¡Ha golpeado 1 vez!"))
	if not move.drain.is_empty() and total > 0 and not user.is_fainted():
		if _heal(user, roundi(total * float(move.drain[0]) / move.drain[1]), &"drain") > 0:
			_msg(tr("¡%s ha perdido energía!") % BattleText.cap_name(target, wild))
	if not move.recoil.is_empty() and total > 0 and not user.is_fainted():
		_damage(user, maxi(1, roundi(total * float(move.recoil[0]) / move.recoil[1])), &"recoil")
		_msg(tr("¡%s se ha hecho daño por el retroceso!") % BattleText.cap_name(user, wild))
	if move.struggle_recoil and not user.is_fainted():
		_damage(user, maxi(1, roundi(user.pokemon.max_hp() / 4.0)), &"struggle")
		_msg(tr("¡%s se ha hecho daño por el retroceso!") % BattleText.cap_name(user, wild))
	if not move.self_boosts.is_empty() and not user.is_fainted() and landed > 0:
		_apply_boosts(user, move.self_boosts, true)
	if move.selfdestruct == &"if_hit" and total > 0 and not user.is_fainted():
		_damage(user, user.pokemon.current_hp, &"selfdestruct")


@warning_ignore("integer_division")
func _apply_status_move(user: Battler, target: Battler, move: MoveData) -> void:
	var wild := setup.is_wild()
	var did := false
	if not move.heal.is_empty():
		if target.pokemon.current_hp >= target.pokemon.max_hp():
			_msg(tr("¡Los PS %s están al máximo!") % BattleText.of_name(target, wild))
			return
		_heal(target, roundi(target.pokemon.max_hp() * float(move.heal[0]) / move.heal[1]), &"move")
		_msg(tr("¡%s ha recuperado PS!") % BattleText.cap_name(target, wild))
		did = true
	if move.status != &"":
		if not _try_set_status(target, move.status, true):
			return
		did = true
	if move.volatile_status == &"confusion":
		if not _try_confuse(target, true):
			return
		did = true
	if not move.boosts.is_empty():
		did = _apply_boosts(target, move.boosts, false) or did
	if not move.self_boosts.is_empty():
		did = _apply_boosts(user, move.self_boosts, false) or did
	if not did:
		_msg(tr("¡Pero falló!"))


func _apply_secondary(user: Battler, target: Battler, sec: Dictionary) -> void:
	if not target.is_fainted():
		if sec.has("status"):
			_try_set_status(target, StringName(sec["status"]), false)
		match str(sec.get("volatile_status", "")):
			"flinch":
				target.volatiles[&"flinch"] = {}
			"confusion":
				_try_confuse(target, false)
		if sec.has("boosts"):
			_apply_boosts(target, DataUtil.int_dict(sec["boosts"]), true)
	if sec.has("self_boosts") and not user.is_fainted():
		_apply_boosts(user, DataUtil.int_dict(sec["self_boosts"]), true)


# --- Daño, curación, estados y características ---

func _damage(b: Battler, amount: int, source: StringName, effectiveness: float = 1.0, critical: bool = false) -> int:
	var dealt := b.pokemon.take_damage(amount)
	_emit(BattleEvent.DAMAGE, b.side, b.slot, {
		"amount": dealt, "hp": b.pokemon.current_hp, "max_hp": b.pokemon.max_hp(),
		"effectiveness": effectiveness, "critical": critical, "source": String(source),
	})
	if b.is_fainted() and b not in _pending_faints:
		_pending_faints.append(b)
	return dealt


func _heal(b: Battler, amount: int, source: StringName) -> int:
	var healed := b.pokemon.heal(amount)
	if healed > 0:
		_emit(BattleEvent.HEAL, b.side, b.slot, {
			"amount": healed, "hp": b.pokemon.current_hp, "max_hp": b.pokemon.max_hp(), "source": String(source),
		})
	return healed


## Intenta causar un estado principal. Con `announce`, explica por qué falla (movimientos de estado).
func _try_set_status(target: Battler, status: StringName, announce: bool) -> bool:
	var wild := setup.is_wild()
	var name := BattleText.cap_name(target, wild)
	if target.is_fainted():
		return false
	if target.pokemon.status != &"":
		if announce:
			_msg(BattleText.STATUS_ALREADY[status] % name if target.pokemon.status == status else tr("¡Pero falló!"))
		return false
	for t: StringName in target.types():
		if DataDB.type_immune_to(t, status):
			if announce:
				_msg(tr("No afecta %s...") % BattleText.to_name(target, wild))
			return false
	target.pokemon.set_status(status, rng.randi_range(2, 4) if status == &"slp" else 0)
	if status == &"tox":
		target.toxic_stage = 0
	_emit(BattleEvent.STATUS, target.side, target.slot, {"status": String(status)})
	_msg(tr(BattleText.STATUS_SET[status]) % name)
	return true


func _cure_status(b: Battler) -> void:
	var old := b.pokemon.status
	if old == &"":
		return
	b.pokemon.cure_status()
	_emit(BattleEvent.STATUS, b.side, b.slot, {"status": ""})
	_msg(tr(BattleText.STATUS_CURED[old]) % BattleText.cap_name(b, setup.is_wild()))


func _try_confuse(target: Battler, announce: bool) -> bool:
	var name := BattleText.cap_name(target, setup.is_wild())
	if target.is_fainted():
		return false
	if target.has_volatile(&"confusion"):
		if announce:
			_msg(tr("¡%s ya está confuso!") % name)
		return false
	target.volatiles[&"confusion"] = {"turns": rng.randi_range(2, 5)}
	_emit(BattleEvent.VOLATILE, target.side, target.slot, {"volatile": "confusion", "active": true})
	_msg(tr("¡%s se ha quedado confuso!") % name)
	return true


func _end_confusion(b: Battler) -> void:
	b.volatiles.erase(&"confusion")
	_emit(BattleEvent.VOLATILE, b.side, b.slot, {"volatile": "confusion", "active": false})
	_msg(tr("¡%s ya no está confuso!") % BattleText.cap_name(b, setup.is_wild()))


## Aplica cambios de características. En los primarios (`secondary` = false) avisa si no pueden
## subir o bajar más. Devuelve true si ha mostrado algo.
func _apply_boosts(target: Battler, boosts: Dictionary[StringName, int], secondary: bool) -> bool:
	var wild := setup.is_wild()
	var shown := false
	for stat: StringName in boosts:
		if not target.boosts.has(stat):
			continue
		var old: int = target.boosts[stat]
		var new_stage := clampi(old + boosts[stat], -6, 6)
		var applied := new_stage - old
		if applied != 0:
			target.boosts[stat] = new_stage
			_emit(BattleEvent.BOOST, target.side, target.slot, {"stat": String(stat), "amount": applied, "stage": new_stage})
			_msg(BattleText.stat_change(target, wild, stat, applied))
			shown = true
		elif not secondary:
			_msg(BattleText.stat_limit(target, wild, stat, boosts[stat] > 0))
			shown = true
	return shown


# --- Experiencia y movimientos nuevos ---

func _step_award_exp(foe: Pokemon) -> void:
	if not setup.exp_enabled:
		return
	var s := foe.species()
	var faced: Dictionary = _participants.get(foe.uid, {})
	var members := party(PLAYER)
	var steps: Array[Callable] = []
	var shared: Array[Callable] = []
	for i: int in members.size():
		var p := members[i]
		if p.is_fainted() or p.level >= DataDB.MAX_LEVEL:
			continue
		var participated := faced.has(p.uid)
		if not participated and not setup.exp_share:
			continue
		var amount := ExpCalc.battle_exp(s.base_exp, foe.level, p.level, participated,
			ExpCalc.bonus_for(p, setup.player_trainer_id))
		for stat: StringName in s.ev_yield:
			p.add_evs(stat, s.ev_yield[stat])
		if participated:
			steps.append(_step_gain_exp.bind(i, amount, true))
		else:
			shared.append(_step_gain_exp.bind(i, amount, false))
	if not shared.is_empty():
		steps.append(_msg.bind(tr("¡El resto de tu equipo también ha ganado puntos de experiencia!")))
		steps.append_array(shared)
	_push_front(steps)


func _step_gain_exp(index: int, amount: int, announce: bool) -> void:
	if announce:
		_msg(tr("¡%s ha ganado %d puntos de experiencia!") % [party(PLAYER)[index].display_name(), amount])
	_give_exp(index, amount)


## Da la experiencia nivel a nivel: un evento `exp` por tramo de barra y `level_up` en cada subida.
## Si al subir quiere aprender movimientos, se resuelven antes de seguir subiendo.
func _give_exp(index: int, amount: int) -> void:
	var p := party(PLAYER)[index]
	var on_field := _battler_of(PLAYER, index)
	var slot := on_field.slot if on_field else -1
	var remaining := amount
	while remaining > 0 and p.level < DataDB.MAX_LEVEL:
		var start := p.exp_at_level_start()
		var next := p.exp_at_next_level()
		var level := p.level
		var chunk := mini(remaining, next - p.exp)
		var ups := p.gain_exp(chunk)
		remaining -= chunk
		_emit(BattleEvent.EXP, PLAYER, slot, {
			"party_index": index, "amount": chunk, "exp": p.exp, "level": level,
			"exp_level_start": start, "exp_next_level": next,
		})
		if ups.is_empty():
			break
		var up := ups[0]
		_leveled[p.uid] = true
		_msg(tr("¡%s ha subido al nivel %d!") % [p.display_name(), p.level])
		_emit(BattleEvent.LEVEL_UP, PLAYER, slot, {
			"party_index": index, "level": p.level, "old_stats": _stats_json(up["old_stats"]),
			"new_stats": _stats_json(up["new_stats"]), "hp": p.current_hp, "max_hp": p.max_hp(),
		})
		var learn: Array[Callable] = []
		for move_id: StringName in up["new_moves"]:
			learn.append(_step_learn.bind(index, move_id))
		if not learn.is_empty():
			if remaining > 0:
				learn.append(_give_exp.bind(index, remaining))
			_push_front(learn)
			return


func _step_learn(index: int, move_id: StringName) -> void:
	var p := party(PLAYER)[index]
	if p.has_move(move_id) or not DataDB.has_move(move_id):
		return
	var move_name := DataDB.move(move_id).name
	if p.try_learn(move_id):
		_msg(tr("¡%s ha aprendido %s!") % [p.display_name(), move_name])
		_emit(BattleEvent.MOVE_LEARNED, PLAYER, -1, {"party_index": index, "move": String(move_id), "move_name": move_name, "forgot": ""})
		return
	_msg(tr("%s quiere aprender %s, pero ya conoce cuatro movimientos.") % [p.display_name(), move_name])
	var r := BattleRequest.new()
	r.kind = BattleRequest.Kind.LEARN_MOVE
	r.side = PLAYER
	r.party_index = index
	r.move_id = move_id
	r.can_run = false
	r.can_switch = false
	r.can_use_items = false
	request = r


func _resolve_learn(req: BattleRequest, action: BattleAction) -> void:
	var p := party(PLAYER)[req.party_index]
	var new_name := DataDB.move(req.move_id).name
	var forget := action.forget_index if action.kind == BattleAction.Kind.LEARN_MOVE else -1
	if forget < 0 or forget >= p.moves.size():
		_msg(tr("%s no ha aprendido %s.") % [p.display_name(), new_name])
		return
	var old := p.moves[forget].id
	p.replace_move(forget, req.move_id)
	_msg(tr("1, 2 y... ¡Puf!"))
	_msg(tr("¡%s ha olvidado %s!") % [p.display_name(), DataDB.move(old).name])
	_msg(tr("¡Y ha aprendido %s!") % new_name)
	_emit(BattleEvent.MOVE_LEARNED, PLAYER, -1, {"party_index": req.party_index, "move": String(req.move_id), "move_name": new_name, "forgot": String(old)})


# --- Utilidades ---

func _trainer_name() -> String:
	if setup.trainers.is_empty():
		return ""
	var names: Array[String] = []
	for t: Dictionary in setup.trainers:
		names.append(str(t.get("display_name", "")))
	return tr(" y ").join(PackedStringArray(names))


func _stats_json(stats: Dictionary) -> Dictionary:
	var out := {}
	for k: StringName in stats:
		out[String(k)] = stats[k]
	return out
