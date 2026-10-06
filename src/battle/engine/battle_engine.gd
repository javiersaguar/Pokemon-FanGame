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
## Volátiles que pasa Relevo al que entra.
const BATON_PASS_VOLATILES: Array[StringName] = [&"confusion", &"focusenergy", &"leechseed"]
const MAX_TOXIC_STAGE := 15
const CONFUSION_SELF_HIT_PERCENT := 33
## Orden del daño de veneno y quemadura al final del turno (como en Showdown).
const STATUS_RESIDUAL_ORDER := 9

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
## Condiciones del campo (Fase 9.3): "weather" (clima), "terrain" (campo) y otras por id (Eco Voz...).
## Cada una es un estado {"id", "turns", ...}; su comportamiento está en src/battle/effects/conditions/.
var field: Dictionary = {}
## Pokémon que está cambiando ahora mismo (Persecución le golpea antes, con el doble de potencia).
var switching: Battler = null
## Acción que ha elegido cada Battler este turno (Golpe Bajo, Persecución...).
var _turn_actions: Dictionary = {}
## uids del jugador que ya han emitido pokemon_died en este combate.
var _dead_uids: Dictionary = {}
## Índice del rival que entrará tras un aviso de modo Cambio.
var _shift_foe_index := -1
## Acciones ya elegidas en un doble, por slot del jugador, antes de resolver el turno.
var _double_chosen: Dictionary = {}
## Este bando ya ha megaevolucionado en el combate (una vez por bando).
var _mega_used: Array[bool] = [false, false]


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
	var slots := 2 if setup.format == BattleSetup.Format.DOUBLE else 1
	for _i: int in slots:
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
			if is_double():
				_double_chosen[req.slot] = action
				_request_double_slot()
			else:
				_begin_turn(action)
		BattleRequest.Kind.SWITCH:
			_resolve_switch_request(req, action)
		BattleRequest.Kind.LEARN_MOVE:
			_resolve_learn(req, action)
	return _run()


func is_over() -> bool:
	return _over


func active(side_index: int, slot: int = 0) -> Battler:
	var act := _sides[side_index].active
	if slot < 0 or slot >= act.size():
		return null
	return act[slot]


func is_double() -> bool:
	return setup.format == BattleSetup.Format.DOUBLE


func slot_count() -> int:
	return 2 if is_double() else 1


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
	if not it.is_ball() and not _locke_item_allowed():
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
			return p.is_fainted() and not setup.locke_rules
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
	if move == null or move.is_status() or target == null or _is_immune(target, move) or not _supported(move):
		return 0
	var effect := Effects.move(move.id)
	if effect != null:
		var fixed := effect.fixed_damage(self, user, target, move)
		if fixed >= 0:
			return mini(fixed, target.pokemon.current_hp)
	if move.ohko != &"":
		return 0
	if move.level_damage:
		return mini(user.pokemon.level, target.pokemon.current_hp)
	if move.fixed_damage > 0:
		return mini(move.fixed_damage, target.pokemon.current_hp)
	var opts := _damage_opts(user, target, move, effect, false)
	if int(opts["power"]) <= 0:
		return 0
	var hits := (move.multihit_min + move.multihit_max) / 2.0
	var damage := int(DamageCalc.calculate(user, target, move, false, 7, opts) * hits)
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
	if is_double():
		_intro_doubles()
		_queue.append(_step_next_request)
		return
	if setup.is_wild():
		_put_in(FOE, foe_index, true)
		_msg(tr("¡Un %s salvaje apareció!") % party(FOE)[foe_index].display_name(), "wild_appear")
	else:
		_msg(tr("¡%s te desafía!") % _trainer_name(), "challenge")
		_send_out(FOE, foe_index)
	_send_out(PLAYER, player_index)
	_queue.append(_step_next_request)


func _intro_doubles() -> void:
	var foes := _leading_indexes(FOE)
	var players := _leading_indexes(PLAYER)
	if foes.is_empty() or players.is_empty():
		push_error("BattleEngine: un bando no tiene ningún Pokémon que pueda luchar.")
		_finish(BattleResult.LOSE if players.is_empty() else BattleResult.WIN)
		return
	if setup.is_wild():
		for i: int in foes.size():
			_put_in(FOE, foes[i], true, i)
			_msg(tr("¡Un %s salvaje apareció!") % party(FOE)[foes[i]].display_name(), "wild_appear")
	else:
		_msg(tr("¡%s te desafía!") % _trainer_name(), "challenge")
		for i: int in foes.size():
			_send_out(FOE, foes[i], i)
	for i: int in players.size():
		_send_out(PLAYER, players[i], i)


func _leading_indexes(side_index: int) -> Array[int]:
	var out: Array[int] = []
	for i: int in party(side_index).size():
		if party(side_index)[i].is_fainted():
			continue
		out.append(i)
		if out.size() == slot_count():
			break
	return out


func _step_next_request() -> void:
	if is_double():
		_request_double_slot()
		return
	var b := active(PLAYER)
	var forced := _forced_action(b)
	if forced != null:
		_begin_turn(forced)
		return
	var trapped := _is_trapped(b)
	var r := BattleRequest.new()
	r.kind = BattleRequest.Kind.ACTION
	r.side = PLAYER
	r.slot = b.slot
	r.party_index = b.party_index
	r.can_run = setup.is_wild() and setup.can_run and not trapped
	r.can_switch = _sides[PLAYER].first_able_index() >= 0 and not trapped
	r.can_use_items = setup.allow_items and (setup.is_wild() or _locke_item_allowed())
	r.usable_moves = b.usable_moves()
	r.can_mega = can_mega(b)
	request = r


## Pide la acción del siguiente Pokémon del jugador en un doble. Si ya están todas, resuelve el turno.
func _request_double_slot() -> void:
	for slot: int in slot_count():
		if _double_chosen.has(slot):
			continue
		var b := active(PLAYER, slot)
		if b == null or b.is_fainted():
			continue
		var forced := _forced_action(b)
		if forced != null or (setup.ally_ai and slot == 1):
			_double_chosen[slot] = forced if forced != null else BattleAI.choose_action(self, PLAYER, slot, setup.ai_level)
			continue
		var trapped := _is_trapped(b)
		var r := BattleRequest.new()
		r.kind = BattleRequest.Kind.ACTION
		r.side = PLAYER
		r.slot = slot
		r.party_index = b.party_index
		r.can_run = setup.is_wild() and setup.can_run and not trapped and slot == 0
		r.can_switch = _sides[PLAYER].first_able_index() >= 0 and not trapped
		r.can_use_items = slot == 0 and setup.allow_items and (setup.is_wild() or _locke_item_allowed())
		r.usable_moves = b.usable_moves()
		r.can_mega = can_mega(b)
		request = r
		return
	_begin_turn(null)


# --- Turno ---

func _begin_turn(player_action: Variant = null) -> void:
	turn += 1
	_emit(BattleEvent.TURN, -1, -1, {"turn": turn})
	_turn_actions.clear()
	var entries: Array[Dictionary] = []
	for side_index: int in [PLAYER, FOE]:
		for slot: int in slot_count():
			var b := active(side_index, slot)
			if b == null or b.is_fainted():
				continue
			var action := _forced_action(b)
			if action == null and side_index == PLAYER and _double_chosen.has(slot):
				action = _sanitize(b, _double_chosen[slot])
			if action == null and side_index == PLAYER and slot == 0 and player_action != null:
				action = _sanitize(b, player_action)
			if action == null:
				action = BattleAI.choose_action(self, side_index, slot, setup.ai_level)
			b.moved_this_turn = false
			b.damaged_this_turn = false
			if action.kind == BattleAction.Kind.FIGHT and action.mega and not action.forced:
				_try_mega(b)
			_turn_actions[b] = action
			entries.append({
				"battler": b,
				"action": action,
				"order": BattleAction.ORDER[action.kind],
				"priority": _action_priority(b, action),
				"speed": _speed(b),
				"tie": rng.randf(),
			})
	_double_chosen.clear()
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
	if action.forced:
		return action
	var usable := b.usable_moves()
	var fallback := BattleAction.fight(usable[0] if not usable.is_empty() else -1)
	match action.kind:
		BattleAction.Kind.FIGHT:
			if usable.is_empty():
				return BattleAction.fight(-1)
			if action.move_index not in usable:
				push_error("BattleEngine: el movimiento %d no se puede usar." % action.move_index)
				return fallback
			if action.mega and not can_mega(b):
				action.mega = false
		BattleAction.Kind.SWITCH:
			if not _sides[PLAYER].can_switch_to(action.party_index) or _is_trapped(b):
				push_error("BattleEngine: no se puede cambiar al Pokémon %d." % action.party_index)
				return fallback
		BattleAction.Kind.ITEM:
			if not can_use_item(action.item_id, action.party_index):
				push_error("BattleEngine: el objeto '%s' no se puede usar ahora." % action.item_id)
				return fallback
		BattleAction.Kind.RUN:
			if not (setup.is_wild() and setup.can_run) or _is_trapped(b):
				push_error("BattleEngine: no se puede huir de este combate.")
				return fallback
		_:
			return fallback
	return action


func _step_action(entry: Dictionary) -> void:
	var b: Battler = entry["battler"]
	if _over or b.is_fainted() or active(b.side, b.slot) != b or b.moved_this_turn:
		return
	var action: BattleAction = entry["action"]
	match action.kind:
		BattleAction.Kind.RUN:
			_do_run(b)
		BattleAction.Kind.SWITCH:
			_pursuit_before_switch(b)
			if not _over and not b.is_fainted():
				_do_switch(b, action.party_index)
		BattleAction.Kind.ITEM:
			_do_item(b, action)
		BattleAction.Kind.FIGHT:
			_do_move(b, action)
	b.moved_this_turn = true
	_process_faints()


## Final del turno: clima, Deseo, estados, Drenadoras, trampas, condiciones de bando y campos,
## cada uno en su orden (residual_order) y, a igualdad, el Pokémon más rápido primero.
func _step_end_of_turn() -> void:
	if _over:
		return
	var order := _actives_by_speed()
	var entries: Array[Array] = []
	var keys: Array = field.keys()
	keys.sort()
	for key: Variant in keys:
		var effect := Effects.condition(StringName(str(field[key].get("id", key))))
		if effect != null:
			entries.append([effect.residual_order(), -1, _residual_condition.bind(effect, null, field[key], StringName(str(key)))])
	for side_index: int in [PLAYER, FOE]:
		var conditions := _sides[side_index].conditions
		var ids: Array = conditions.keys()
		DataUtil.sort_names(ids)
		for id: StringName in ids:
			var effect := Effects.condition(id)
			if effect != null:
				entries.append([effect.residual_order(), side_index, _residual_condition.bind(effect, _sides[side_index], conditions[id], id)])
	for rank: int in order.size():
		var b := order[rank]
		entries.append([STATUS_RESIDUAL_ORDER, rank, _residual_status.bind(b)])
		var ids: Array = b.volatiles.keys()
		DataUtil.sort_names(ids)
		for id: StringName in ids:
			var effect := Effects.condition(id)
			if effect != null:
				entries.append([effect.residual_order(), rank, _residual_condition.bind(effect, b, b.volatiles[id], id)])
		for passive: BattleEffect in _passives(b):
			entries.append([passive.residual_order(), rank, _passive_residual.bind(passive, b)])
	for i: int in entries.size():
		entries[i].append(i)
	entries.sort_custom(func(a: Array, c: Array) -> bool:
		if a[0] != c[0]:
			return a[0] < c[0]
		if a[1] != c[1]:
			return a[1] < c[1]
		return a[3] < c[3])
	for e: Array in entries:
		if _over:
			return
		(e[2] as Callable).call()
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b != null:
			b.volatiles.erase(&"flinch")
			b.turns_active += 1
	_process_faints()


## Una condición al final del turno: descuenta su duración (y se acaba si llega a 0) o hace su efecto.
func _passive_residual(effect: BattleEffect, battler: Battler) -> void:
	if battler.is_fainted() or active(battler.side, battler.slot) != battler:
		return
	effect.on_residual(self, battler, {})


func _residual_condition(effect: BattleEffect, holder: Variant, state: Dictionary, key: StringName) -> void:
	if holder is Battler and ((holder as Battler).is_fainted() or active((holder as Battler).side, (holder as Battler).slot) != holder):
		return
	if _condition_state(holder, key) != state:
		return
	var turns := int(state.get("turns", 0))
	if turns > 0:
		state["turns"] = turns - 1
		if turns - 1 == 0:
			_remove_condition(holder, key)
			return
	effect.on_residual(self, holder, state)


@warning_ignore("integer_division")
func _residual_status(b: Battler) -> void:
	if b.is_fainted() or active(b.side, b.slot) != b:
		return
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
		if b.side == PLAYER and setup.locke_rules and not setup.tutorial:
			_record_death(b)
		if b.side == FOE:
			steps.append(_step_award_exp.bind(b.pokemon))
	_pending_faints.clear()
	steps.append(_step_check_end)
	_push_front(steps)


func _record_death(b: Battler) -> void:
	var uid := b.pokemon.uid
	if uid.is_empty() or _dead_uids.has(uid):
		return
	_dead_uids[uid] = true
	var foe := active(FOE)
	var death := {
		"party_index": b.party_index, "uid": b.pokemon.uid, "species": String(b.pokemon.species_id),
		"name": b.pokemon.display_name(), "level": b.pokemon.level,
		"foe_species": String(foe.pokemon.species_id) if foe else "", "foe_name": foe.pokemon.display_name() if foe else "",
		"trainer": _trainer_name(), "turn": turn,
	}
	result.deaths.append(death)
	_emit(BattleEvent.POKEMON_DIED, b.side, b.slot, death)
	_msg(tr("%s ha caído para siempre...") % b.pokemon.display_name(), "death")


func _step_check_end() -> void:
	if _sides[PLAYER].all_fainted():
		_finish(BattleResult.LOSE)
	elif _sides[FOE].all_fainted():
		_finish(BattleResult.WIN)


func _step_player_replacement() -> void:
	if _over:
		return
	for slot: int in slot_count():
		var b := active(PLAYER, slot)
		if b == null or not b.is_fainted() or _sides[PLAYER].first_able_index() < 0:
			continue
		var r := BattleRequest.new()
		r.kind = BattleRequest.Kind.SWITCH
		r.side = PLAYER
		r.slot = b.slot
		r.party_index = b.party_index
		r.can_run = setup.is_wild() and setup.can_run
		r.can_switch = true
		r.can_use_items = false
		request = r
		if is_double():
			_queue.push_front(_step_player_replacement)
		return


func _resolve_switch_request(req: BattleRequest, action: BattleAction) -> void:
	if req.reason == &"shift":
		var current := active(PLAYER)
		if current != null and action.kind == BattleAction.Kind.SWITCH \
				and action.party_index != current.party_index \
				and _sides[PLAYER].can_switch_to(action.party_index):
			_do_switch(current, action.party_index)
		var index := _shift_foe_index
		_shift_foe_index = -1
		if index < 0:
			index = BattleAI.choose_replacement(self, FOE)
		_send_out(FOE, index)
		return
	if req.reason == &"" and action.kind == BattleAction.Kind.RUN and setup.is_wild() and setup.can_run:
		_emit(BattleEvent.FLEE, PLAYER, 0, {"success": true})
		_msg(tr("¡Escapaste sin problemas!"))
		_finish(BattleResult.RUN)
		return
	var index := action.party_index
	if action.kind != BattleAction.Kind.SWITCH or not _sides[PLAYER].can_switch_to(index):
		push_error("BattleEngine: cambio no válido (%s)." % action)
		index = _sides[PLAYER].first_able_index()
	if req.reason != &"":
		_do_switch(active(PLAYER), index, req.reason)
	else:
		_send_out(PLAYER, index, req.slot)


func _step_foe_replacement() -> void:
	if _over or _sides[FOE].first_able_index() < 0:
		return
	for slot: int in slot_count():
		var b := active(FOE, slot)
		if b == null or not b.is_fainted():
			continue
		var index := BattleAI.choose_replacement(self, FOE)
		if index < 0:
			return
		if not is_double() and _shift_prompt():
			_shift_foe_index = index
			var next := party(FOE)[index]
			_msg(tr("¡%s va a sacar a %s!") % [_trainer_name(), next.display_name()])
			var r := BattleRequest.new()
			r.kind = BattleRequest.Kind.SWITCH
			r.reason = &"shift"
			r.side = PLAYER
			r.slot = active(PLAYER).slot
			r.party_index = active(PLAYER).party_index
			r.can_run = false
			r.can_switch = true
			r.can_use_items = false
			request = r
			return
		_send_out(FOE, index, slot)
	return


func _shift_prompt() -> bool:
	if not _style_is_shift():
		return false
	var current := active(PLAYER)
	if current == null or current.is_fainted():
		return false
	for i: int in party(PLAYER).size():
		if i != current.party_index and _sides[PLAYER].can_switch_to(i):
			return true
	return false


func _style_is_shift() -> bool:
	if setup.tutorial or setup.battle_style != &"shift":
		return false
	if setup.locke != null and setup.locke.battle_mode() == "fixed":
		return false
	return true


## -1 = sin tope. 0 = ya está en el tope y no gana experiencia.
func _exp_room(p: Pokemon) -> int:
	if setup.tutorial or setup.locke == null:
		return -1
	var cap := setup.locke.level_cap(setup.next_ace_level)
	if cap <= 0:
		return -1
	if p.level >= cap or p.level >= DataDB.MAX_LEVEL:
		return 0
	return maxi(0, DataDB.exp_for_level(p.exp_group(), cap) - p.exp)


func _locke_item_allowed() -> bool:
	if setup.tutorial or setup.locke == null:
		return true
	var used := 0
	for id: StringName in result.items_used:
		if DataDB.has_item(id) and not DataDB.item(id).is_ball():
			used += 1
	return setup.locke.can_use_item(used)


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
	_revert_all_formes()
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

func _send_out(side_index: int, index: int, slot: int = 0) -> void:
	var p := party(side_index)[index]
	if side_index == PLAYER:
		_msg(tr("¡Adelante, %s!") % p.display_name(), "send_out")
	else:
		_msg(tr("¡%s sacó a %s!") % [_trainer_name(), p.display_name()], "send_out")
	_put_in(side_index, index, false, slot)


func _put_in(side_index: int, index: int, wild_appearance: bool, slot: int = 0) -> void:
	var p := party(side_index)[index]
	var b := Battler.new(p, side_index, slot, index)
	_sides[side_index].active[slot] = b
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
	_emit(BattleEvent.SWITCH_IN, side_index, slot, data)
	var conditions := _sides[side_index].conditions
	for id: StringName in conditions.keys():
		var effect := Effects.condition(id)
		if effect != null and not b.is_fainted():
			effect.on_switch_in(self, b, conditions[id])
	if not b.is_fainted():
		for passive: BattleEffect in _passives(b):
			passive.on_switch_in(self, b, {})


func _mark_participant(foe: Pokemon, mine: Pokemon) -> void:
	if not _participants.has(foe.uid):
		_participants[foe.uid] = {}
	_participants[foe.uid][mine.uid] = true


## Cambio voluntario. Con `reason` = &"batonpass" (Relevo) el que entra hereda los niveles de
## características y algunos volátiles.
func _do_switch(b: Battler, index: int, reason: StringName = &"") -> void:
	if b.side == PLAYER:
		_msg(tr("¡%s, vuelve!") % b.pokemon.display_name(), "recall")
	else:
		_msg(tr("¡%s ha retirado a %s!") % [_trainer_name(), b.pokemon.display_name()], "recall")
	_emit(BattleEvent.SWITCH_OUT, b.side, b.slot, {"party_index": b.party_index})
	_revert_forme(b)
	var passed := {}
	if reason == &"batonpass":
		passed = {"boosts": b.boosts.duplicate(), "crit": b.crit_stage, "volatiles": {}}
		for id: StringName in BATON_PASS_VOLATILES:
			if b.volatiles.has(id):
				passed["volatiles"][id] = b.volatiles[id].duplicate(true)
	_send_out(b.side, index)
	if not passed.is_empty():
		var nb := active(b.side)
		nb.boosts.assign(passed["boosts"])
		nb.crit_stage = int(passed["crit"])
		for id: StringName in passed["volatiles"]:
			nb.volatiles[id] = passed["volatiles"][id]


## Persecución: si el rival va a usarla, golpea antes de que `b` se retire y con el doble de potencia.
func _pursuit_before_switch(b: Battler) -> void:
	var foe := _foe_of(b)
	if foe == null or foe.is_fainted() or foe.moved_this_turn:
		return
	var action: BattleAction = _turn_actions.get(foe)
	if action == null or action.kind != BattleAction.Kind.FIGHT:
		return
	var effect := Effects.move(_move_for(foe, action.move_index).id)
	if effect == null or not effect.runs_before_switch():
		return
	switching = b
	_do_move(foe, action)
	switching = null
	foe.moved_this_turn = true


# --- Huir ---

@warning_ignore("integer_division")
func _do_run(b: Battler) -> void:
	var foe := active(FOE)
	_flee_attempts += 1
	var mine := _speed(b)
	var theirs := maxi(1, _speed(foe))
	var escape_ability := Effects.ability(b.ability)
	var escaped := (escape_ability != null and escape_ability.guarantees_escape()) or mine >= theirs
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
	if user.choice_move == &"" and user.pokemon.held_item in [&"choiceband", &"choicespecs", &"choicescarf"] and move.id != STRUGGLE:
		user.choice_move = move.id
	if not _before_move(user, move):
		return
	if slot != null:
		if not action.forced:
			slot.pp = maxi(0, slot.pp - 1)
	else:
		_msg(tr("¡A %s no le quedan movimientos!") % BattleText.name_of(user, setup.is_wild()))
	user.last_move = move.id
	var hit := _use_move(user, move)
	_after_move(user, move, hit)
	if move.selfdestruct == &"always" and not user.is_fainted():
		_damage(user, user.pokemon.current_hp, &"selfdestruct")


func _after_move(user: Battler, move: MoveData, hit: bool) -> void:
	var effect := Effects.move(move.id)
	if effect != null:
		effect.on_after_move(self, user, move, hit)
	if effect == null or not effect.is_stalling_move():
		user.protect_count = 0


## Sueño, congelación, retroceso, confusión y parálisis (en el orden de Showdown). false = no se mueve.
func _before_move(user: Battler, move: MoveData) -> bool:
	var p := user.pokemon
	var name := BattleText.cap_name(user, setup.is_wild())
	var hooks := _volatile_hooks(user)
	for h: Array in hooks:
		if (h[0] as BattleEffect).before_move_priority() >= 10 and not (h[0] as BattleEffect).on_before_move(self, user, h[1], move):
			return false
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
	for h: Array in hooks:
		var priority := (h[0] as BattleEffect).before_move_priority()
		if priority < 10 and priority > 1 and user.volatiles.has(StringName(str(h[1].get("id", "")))) \
				and not (h[0] as BattleEffect).on_before_move(self, user, h[1], move):
			return false
	if p.status == &"par" and rng.randi_range(0, 3) == 0:
		_emit(BattleEvent.CANT_MOVE, user.side, user.slot, {"reason": "par"})
		_msg(tr("¡%s está paralizado! ¡No se puede mover!") % name)
		return false
	return true


## Usa el movimiento (tras "¡X usó Y!"). Devuelve true si ha llegado a resolverse contra su objetivo.
func _use_move(user: Battler, move: MoveData) -> bool:
	var wild := setup.is_wild()
	var effect := Effects.move(move.id)
	_msg(tr("¡%s usó %s!") % [BattleText.cap_name(user, wild), move.name])
	var target := _move_target(user, move)
	_emit(BattleEvent.MOVE, user.side, user.slot, {
		"move": String(move.id), "move_name": move.name, "type": String(move.type),
		"category": String(MoveData.CATEGORY_IDS.find_key(move.category)),
		"target_side": target.side if target else -1, "target_slot": target.slot if target else -1,
	})
	if effect != null and effect.charge_turn(self, user, move):
		return false
	if not _supported(move):
		_msg(tr("¡Pero falló!"))
		return false
	if target == null or target.is_fainted():
		_msg(tr("¡Pero no había ningún objetivo!"))
		return false
	if effect != null and not effect.on_try_move(self, user, target, move):
		return false
	if target != user and move.target not in MoveData.FIELD_TARGETS:
		for c: Array in _conditions_of(target):
			if not (c[0] as BattleEffect).on_try_hit(self, target, c[2], user, move):
				return false
		if _is_immune(target, move) or (move.ohko != &"" and target.pokemon.level > user.pokemon.level):
			_msg(tr("No afecta %s...") % BattleText.to_name(target, wild))
			return false
		if not _accuracy_hits(user, target, move, effect):
			_emit(BattleEvent.MISS, target.side, target.slot, {})
			_msg(tr("¡El ataque %s ha fallado!") % BattleText.of_name(user, wild))
			return false
	if move.is_status():
		_apply_status_move(user, target, move, effect)
	else:
		var targets := _hit_targets(user, move)
		var spread := targets.size() > 1
		if targets.is_empty():
			_apply_damaging_move(user, target, move, effect)
		else:
			for hit: Battler in targets:
				_apply_damaging_move(user, hit, move, effect, spread)
	return true


## Objetivo: el usuario para los de su bando; en dobles, el slot elegido o el aliado.
## Si el rival elegido ya no está, el golpe pasa al otro.
func _move_target(user: Battler, move: MoveData) -> Battler:
	if is_double() and move.target == &"adjacent_ally":
		return active(user.side, 1 - user.slot)
	if move.targets_user() or move.target == &"all" or move.target == &"ally_side":
		return user
	if not is_double():
		return _foe_of(user)
	var chosen := 0
	var action: BattleAction = _turn_actions.get(user)
	if action != null:
		chosen = clampi(action.target_slot, 0, 1)
	var foe := active(1 - user.side, chosen)
	if foe == null or foe.is_fainted():
		foe = active(1 - user.side, 1 - chosen)
	return foe


func _hit_targets(user: Battler, move: MoveData) -> Array[Battler]:
	var out: Array[Battler] = []
	if is_double() and move.target in [&"all_adjacent_foes", &"all_adjacent", &"all"]:
		for slot: int in slot_count():
			var foe := active(1 - user.side, slot)
			if foe != null and not foe.is_fainted():
				out.append(foe)
		if move.target == &"all_adjacent":
			var ally := active(user.side, 1 - user.slot)
			if ally != null and not ally.is_fainted():
				out.append(ally)
		return out
	var one := _move_target(user, move)
	if one != null:
		out.append(one)
	return out


## ¿Lo puede resolver el motor? Los que tienen script (src/battle/effects/moves/) siempre. Los que
## lo necesitan y aún no lo tienen hacen solo la parte que está en los datos (daño, cambios de
## características, estado, curación) y fallan si no tienen ninguna.
func _supported(move: MoveData) -> bool:
	if Effects.has_move(move.id):
		return true
	if move.target in MoveData.FIELD_TARGETS:
		return false
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


func _accuracy_hits(user: Battler, target: Battler, move: MoveData, effect: BattleEffect = null) -> bool:
	if move.ohko != &"":
		var ohko_accuracy := 20 if move.ohko == &"ice" and not user.has_type(&"ice") else 30
		ohko_accuracy += user.pokemon.level - target.pokemon.level
		return rng.randi_range(0, 99) < ohko_accuracy
	var accuracy := move.accuracy
	if effect != null:
		var override := effect.accuracy(self, user, target, move)
		if override >= 0:
			accuracy = override
	if accuracy <= 0:
		return true
	var user_ability := Effects.ability(user.ability)
	if user_ability != null:
		accuracy = user_ability.modify_accuracy(self, user, target, move, accuracy)
	var target_ability := Effects.ability(target.ability)
	if target_ability != null:
		accuracy = target_ability.modify_incoming_accuracy(self, user, target, move, accuracy)
	var stage: int = user.boosts[&"accuracy"]
	if user.ability == &"keeneye":
		stage = maxi(0, stage)
	elif not move.ignore_evasion:
		stage = clampi(stage - target.boosts[&"evasion"], -6, 6)
	return rng.randi_range(0, 99) < StatCalc.apply_accuracy_stage(accuracy, stage)


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


func _apply_damaging_move(user: Battler, target: Battler, move: MoveData, effect: BattleEffect = null, spread: bool = false) -> void:
	var wild := setup.is_wild()
	var scripted_damage := effect.fixed_damage(self, user, target, move) if effect != null else -1
	var fixed := scripted_damage >= 0 or move.ohko != &"" or move.level_damage or move.fixed_damage > 0
	var effectiveness := 1.0 if fixed else DamageCalc.effectiveness(move, target)
	var hits := _roll_hits(move)
	var total := 0
	var landed := 0
	for i: int in hits:
		if target.is_fainted() or user.is_fainted():
			break
		var crit := false
		var amount: int
		if scripted_damage >= 0:
			amount = scripted_damage
		elif move.ohko != &"":
			amount = target.pokemon.max_hp()
		elif move.level_damage:
			amount = user.pokemon.level
		elif move.fixed_damage > 0:
			amount = move.fixed_damage
		else:
			crit = _roll_crit(user, move)
			var opts := _damage_opts(user, target, move, effect, crit)
			opts["spread"] = spread
			amount = DamageCalc.calculate(user, target, move, crit, rng.randi_range(0, DamageCalc.ROLLS - 1), opts)
		total += _damage(target, amount, &"move", effectiveness, crit, move)
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
	if effect != null and landed > 0:
		effect.on_after_hit(self, user, target, move, total)
	if total > 0 and not target.is_fainted():
		for passive: BattleEffect in _passives(target):
			passive.on_damaged(self, target, user, move)
	if user.pokemon.held_item == &"lifeorb" and total > 0 and not user.is_fainted():
		_damage(user, maxi(1, user.pokemon.max_hp() / 10), &"item")
		_msg(tr("¡%s se ha hecho daño con la Vidasfera!") % BattleText.cap_name(user, wild))
	if target.is_fainted():
		var pride := Effects.ability(user.ability)
		if pride != null:
			pride.on_foe_fainted(self, user)


## Potencia y modificadores del daño según el movimiento, el clima, el campo y las condiciones del objetivo.
func _damage_opts(user: Battler, target: Battler, move: MoveData, effect: BattleEffect, crit: bool) -> Dictionary:
	var power := move.power
	if effect != null:
		power = effect.base_power(self, user, target, move, power)
	var weather_mod := 1.0
	var atk_mod := 1.0
	var def_mod := 1.0
	var atk_stat := &"atk" if move.is_physical() else &"spa"
	var def_stat := &"def" if move.is_physical() else &"spd"
	for c: Array in _field_conditions():
		var e: BattleEffect = c[0]
		weather_mod *= e.weather_modifier(self, move)
		power = e.modify_base_power(self, user, target, move, power)
		atk_mod *= e.stat_modifier(self, user, atk_stat)
		def_mod *= e.stat_modifier(self, target, def_stat)
	for passive: BattleEffect in _passives(user):
		power = passive.modify_base_power(self, user, target, move, power)
		atk_mod *= passive.stat_modifier(self, user, atk_stat)
	for passive: BattleEffect in _passives(target):
		def_mod *= passive.stat_modifier(self, target, def_stat)
	var final_mods: Array = []
	for c: Array in _conditions_of(target):
		var m := (c[0] as BattleEffect).damage_modifier(self, user, target, move, crit)
		if m != 1.0:
			final_mods.append(m)
	for passive: BattleEffect in _passives(user):
		var outgoing := passive.damage_modifier(self, user, target, move, crit)
		if outgoing != 1.0:
			final_mods.append(outgoing)
	var ignore_burn := user.ability == &"guts" and user.pokemon.status != &""
	return {"power": power, "weather": weather_mod, "final": final_mods, "atk_mod": atk_mod, "def_mod": def_mod, "ignore_burn": ignore_burn}


@warning_ignore("integer_division")
func _apply_status_move(user: Battler, target: Battler, move: MoveData, effect: BattleEffect = null) -> void:
	var wild := setup.is_wild()
	if effect != null and effect.on_hit(self, user, target, move) == BattleEffect.HANDLED:
		return
	var did := false
	if not move.heal.is_empty():
		if target.pokemon.current_hp >= target.pokemon.max_hp():
			_msg(tr("¡Los PS %s están al máximo!") % BattleText.of_name(target, wild))
			return
		_heal(target, roundi(target.pokemon.max_hp() * float(move.heal[0]) / move.heal[1]), &"move")
		_msg(tr("¡%s ha recuperado PS!") % BattleText.cap_name(target, wild))
		did = true
	if move.status != &"":
		if not _try_set_status(target, move.status, true, user):
			return
		did = true
	if move.volatile_status == &"confusion":
		if not _try_confuse(target, true, user):
			return
		did = true
	if not move.boosts.is_empty():
		did = _apply_boosts(target, move.boosts, false) or did
	if not move.self_boosts.is_empty():
		did = _apply_boosts(user, move.self_boosts, false) or did
	if not did:
		_msg(tr("¡Pero falló!"))


func _apply_secondary(user: Battler, target: Battler, sec: Dictionary) -> void:
	var dust := Effects.ability(target.ability)
	if dust != null and dust.blocks_secondary():
		return
	if not target.is_fainted():
		if sec.has("status"):
			_try_set_status(target, StringName(sec["status"]), false, user)
		match str(sec.get("volatile_status", "")):
			"flinch":
				target.volatiles[&"flinch"] = {}
			"confusion":
				_try_confuse(target, false, user)
		if sec.has("boosts"):
			_apply_boosts(target, DataUtil.int_dict(sec["boosts"]), true)
	if sec.has("self_boosts") and not user.is_fainted():
		_apply_boosts(user, DataUtil.int_dict(sec["self_boosts"]), true)


# --- Daño, curación, estados y características ---

func _damage(b: Battler, amount: int, source: StringName, effectiveness: float = 1.0, critical: bool = false, move: MoveData = null) -> int:
	var held := Effects.item(b.pokemon.held_item)
	if held != null and b.pokemon.held_item == &"focussash" and b.pokemon.current_hp == b.pokemon.max_hp() \
			and b.pokemon.current_hp > 1 and amount >= b.pokemon.current_hp:
		amount = b.pokemon.current_hp - 1
		consume_held_item(b)
		_msg(tr("¡%s ha aguantado gracias a la Banda Focus!") % BattleText.cap_name(b, setup.is_wild()))
		held = null
	elif held != null and move != null and source == &"move" and held.resists(move, effectiveness):
		amount = maxi(1, DamageCalc.modify(amount, 0.5))
		_msg(tr("¡La baya de %s ha reducido el daño!") % b.pokemon.display_name())
		consume_held_item(b)
		held = null
	var dealt := b.pokemon.take_damage(amount)
	if dealt > 0:
		b.damaged_this_turn = true
	_emit(BattleEvent.DAMAGE, b.side, b.slot, {
		"amount": dealt, "hp": b.pokemon.current_hp, "max_hp": b.pokemon.max_hp(),
		"effectiveness": effectiveness, "critical": critical, "source": String(source),
	})
	if b.is_fainted() and b not in _pending_faints:
		_pending_faints.append(b)
	elif not b.is_fainted():
		_eat_healing_berry(b)
	return dealt


func _eat_healing_berry(b: Battler) -> void:
	var held := Effects.item(b.pokemon.held_item)
	if held == null or b.pokemon.current_hp * 2 > b.pokemon.max_hp():
		return
	var amount := held.heal_amount(b)
	if amount <= 0:
		return
	var confuse := held.pinch_confuses(b)
	consume_held_item(b)
	if _heal(b, amount, &"item") > 0:
		_msg(tr("¡%s ha comido su baya y ha recuperado PS!") % BattleText.cap_name(b, setup.is_wild()))
	if confuse:
		_try_confuse(b, true, null)


func _heal(b: Battler, amount: int, source: StringName) -> int:
	var healed := b.pokemon.heal(amount)
	if healed > 0:
		_emit(BattleEvent.HEAL, b.side, b.slot, {
			"amount": healed, "hp": b.pokemon.current_hp, "max_hp": b.pokemon.max_hp(), "source": String(source),
		})
	return healed


## Intenta causar un estado principal. Con `announce`, explica por qué falla (movimientos de estado).
func _try_set_status(target: Battler, status: StringName, announce: bool, source: Battler = null) -> bool:
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
	if not can_set_status(target, status, source, announce):
		return false
	target.pokemon.set_status(status, rng.randi_range(2, 4) if status == &"slp" else 0)
	if status == &"tox":
		target.toxic_stage = 0
	_emit(BattleEvent.STATUS, target.side, target.slot, {"status": String(status)})
	_msg(tr(BattleText.STATUS_SET[status]) % name)
	var berry := Effects.item(target.pokemon.held_item)
	if berry != null and berry.cures_status(status):
		_cure_status(target)
		consume_held_item(target)
		_msg(tr("¡La baya de %s ha curado su problema!") % target.pokemon.display_name())
	return true


func _cure_status(b: Battler) -> void:
	var old := b.pokemon.status
	if old == &"":
		return
	b.pokemon.cure_status()
	_emit(BattleEvent.STATUS, b.side, b.slot, {"status": ""})
	_msg(tr(BattleText.STATUS_CURED[old]) % BattleText.cap_name(b, setup.is_wild()))


func _try_confuse(target: Battler, announce: bool, source: Battler = null) -> bool:
	var name := BattleText.cap_name(target, setup.is_wild())
	if target.is_fainted():
		return false
	if target.has_volatile(&"confusion"):
		if announce:
			_msg(tr("¡%s ya está confuso!") % name)
		return false
	for c: Array in _status_guards(target):
		if not (c[0] as BattleEffect).on_try_confuse(self, target, source, announce):
			return false
	var persim := Effects.item(target.pokemon.held_item)
	if persim != null and persim.cures_confusion():
		consume_held_item(target)
		_msg(tr("¡La baya de %s evita la confusión!") % target.pokemon.display_name())
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
	var guard := Effects.ability(target.ability)
	for stat: StringName in boosts:
		if not target.boosts.has(stat):
			continue
		if boosts[stat] < 0 and guard != null and guard.prevents_drop(stat):
			if not secondary:
				_msg(tr("¡%s se protege con su habilidad!") % BattleText.cap_name(target, wild))
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


# --- Condiciones (volátiles, de bando y del campo) ---

## [efecto, dueño, estado] de lo que afecta a `b`: campo, condiciones de su bando y sus volátiles.
func _conditions_of(b: Battler) -> Array[Array]:
	var out := _field_conditions()
	if b == null:
		return out
	var conditions := _sides[b.side].conditions
	for id: StringName in conditions:
		var effect := Effects.condition(id)
		if effect != null:
			out.append([effect, _sides[b.side], conditions[id]])
	for id: StringName in b.volatiles:
		var effect := Effects.condition(id)
		if effect != null:
			out.append([effect, b, b.volatiles[id]])
	for passive: BattleEffect in _passives(b):
		out.append([passive, b, {}])
	return out


func _field_conditions() -> Array[Array]:
	var out: Array[Array] = []
	for key: Variant in field:
		var effect := Effects.condition(StringName(str(field[key].get("id", key))))
		if effect != null:
			out.append([effect, null, field[key]])
	return out


## [efecto, estado] de los volátiles de `b` con on_before_move, de mayor a menor prioridad.
func _volatile_hooks(b: Battler) -> Array[Array]:
	var out: Array[Array] = []
	for id: StringName in b.volatiles:
		var effect := Effects.condition(id)
		if effect != null:
			out.append([effect, b.volatiles[id]])
	out.sort_custom(func(a: Array, c: Array) -> bool:
		return (a[0] as BattleEffect).before_move_priority() > (c[0] as BattleEffect).before_move_priority())
	return out


## Lo que puede impedir un estado o la confusión a `target`: el campo, su bando y los volátiles de
## todos los que están en el campo (Alboroto impide dormir a cualquiera).
func _status_guards(target: Battler) -> Array[Array]:
	var out := _field_conditions()
	var conditions := _sides[target.side].conditions
	for id: StringName in conditions:
		var effect := Effects.condition(id)
		if effect != null:
			out.append([effect, _sides[target.side], conditions[id]])
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b == null or b.is_fainted():
			continue
		for id: StringName in b.volatiles:
			var effect := Effects.condition(id)
			if effect != null:
				out.append([effect, b, b.volatiles[id]])
	for passive: BattleEffect in _passives(target):
		out.append([passive, target, {}])
	return out


func _condition_state(holder: Variant, key: StringName) -> Dictionary:
	if holder == null:
		return field.get(String(key), {})
	if holder is BattleSide:
		return (holder as BattleSide).conditions.get(key, {})
	return (holder as Battler).volatiles.get(key, {})


func _remove_condition(holder: Variant, key: StringName) -> void:
	var state := _condition_state(holder, key)
	if state.is_empty():
		return
	var effect := Effects.condition(StringName(str(state.get("id", key))))
	if holder == null:
		field.erase(String(key))
	elif holder is BattleSide:
		(holder as BattleSide).conditions.erase(key)
	else:
		(holder as Battler).volatiles.erase(key)
	if effect != null:
		effect.on_end(self, holder, state)
	_condition_event(holder, key, false)


func _condition_event(holder: Variant, key: StringName, is_active: bool) -> void:
	if holder == null:
		var state: Dictionary = field.get(String(key), {})
		var current := String(state.get("id", "")) if is_active else ""
		if key == &"weather":
			_emit(BattleEvent.WEATHER, -1, -1, {"weather": current})
		elif key == &"terrain":
			_emit(BattleEvent.TERRAIN, -1, -1, {"terrain": current})
	elif holder is BattleSide:
		_emit(BattleEvent.SIDE_CONDITION, (holder as BattleSide).index, -1, {"condition": String(key), "active": is_active})
	else:
		var b: Battler = holder
		_emit(BattleEvent.VOLATILE, b.side, b.slot, {"volatile": String(key), "active": is_active})


## ¿Puede megaevolucionar este turno? El jugador necesita la pulsera. El rival, si no es salvaje, solo la piedra.
func can_mega(b: Battler) -> bool:
	if b == null or b.is_fainted() or b.mega_from != &"" or _mega_used[b.side]:
		return false
	if b.pokemon.species().is_mega:
		return false
	if b.side == PLAYER and not setup.mega_bracelet:
		return false
	if b.side == FOE and setup.is_wild():
		return false
	return _mega_species_for(b) != &""


func _mega_species_for(b: Battler) -> StringName:
	var held := b.pokemon.held_item
	if held != &"" and DataDB.has_item(held):
		var mapped := DataDB.item(held).mega_species(b.pokemon.species_id)
		if mapped != &"" and DataDB.has_species(mapped):
			var form := DataDB.species(mapped)
			if form.is_mega and form.base_species == b.pokemon.species_id:
				return mapped
	for form_id: StringName in b.pokemon.species().forms:
		if not DataDB.has_species(form_id):
			continue
		var form := DataDB.species(form_id)
		if not form.is_mega or form.required_item != &"":
			continue
		var need := StringName(str(form.raw.get("required_move", "")))
		if need != &"" and b.pokemon.has_move(need):
			return form.id
	return &""


func _try_mega(b: Battler) -> void:
	if not can_mega(b):
		return
	var next := _mega_species_for(b)
	if next == &"":
		return
	var from := b.pokemon.species_id
	b.mega_from = from
	_mega_used[b.side] = true
	_set_species_keep_ratio(b, next)
	var form_name := b.pokemon.species().form_name
	var shown := form_name if form_name != "" else b.pokemon.species().name
	_msg(tr("¡%s ha megaevolucionado a %s!") % [b.pokemon.display_name(), shown], "mega")
	_emit(BattleEvent.MEGA, b.side, b.slot, {
		"from": String(from),
		"species": String(next),
		"form_name": form_name,
		"ability": String(b.ability),
		"hp": b.pokemon.current_hp,
		"max_hp": b.pokemon.max_hp(),
	})


func _set_species_keep_ratio(b: Battler, species_id: StringName) -> void:
	var p := b.pokemon
	var old_max := p.max_hp()
	var hp := p.current_hp
	p.species_id = species_id
	var new_max := p.max_hp()
	if hp > 0 and old_max > 0 and new_max != old_max:
		p.current_hp = clampi(int(round(float(hp) * float(new_max) / float(old_max))), 1, new_max)
	elif hp > new_max:
		p.current_hp = new_max
	b.ability = p.ability_id()


func _revert_forme(b: Battler) -> void:
	if b == null or b.mega_from == &"":
		return
	_set_species_keep_ratio(b, b.mega_from)
	b.mega_from = &""


func _revert_all_formes() -> void:
	for side_index: int in [PLAYER, FOE]:
		for slot: int in slot_count():
			_revert_forme(active(side_index, slot))


func _speed(b: Battler) -> int:
	var spe := b.effective_speed()
	for c: Array in _conditions_of(b):
		spe = (c[0] as BattleEffect).modify_speed(self, b, spe)
	for passive: BattleEffect in _passives(b):
		spe = passive.modify_speed(self, b, spe)
	return spe


func _passives(b: Battler) -> Array[BattleEffect]:
	var out: Array[BattleEffect] = []
	if b == null:
		return out
	var ability := Effects.ability(b.ability)
	if ability != null:
		out.append(ability)
	var held := Effects.item(b.pokemon.held_item)
	if held != null:
		out.append(held)
	return out


func side_condition(side_index: int, id: StringName) -> Dictionary:
	return _sides[side_index].conditions.get(id, {})


func consume_held_item(b: Battler) -> void:
	if b == null or b.pokemon.held_item == &"":
		return
	b.pokemon.held_item = &""
	b.choice_move = &""
	if b.ability == &"unburden":
		b.unburdened = true


func _actives_by_speed() -> Array[Battler]:
	var order: Array[Battler] = []
	for side_index: int in [PLAYER, FOE]:
		var b := active(side_index)
		if b != null and not b.is_fainted():
			order.append(b)
	order.sort_custom(func(a: Battler, c: Battler) -> bool: return _speed(a) > _speed(c))
	return order


## Acción que el Pokémon tiene que hacer sí o sí este turno (bloqueado, cargando, recargando).
func _forced_action(b: Battler) -> BattleAction:
	if b == null or b.is_fainted():
		return null
	var ids: Array = b.volatiles.keys()
	DataUtil.sort_names(ids)
	for id: StringName in ids:
		var effect := Effects.condition(id)
		if effect != null:
			var action := effect.forced_action(self, b, b.volatiles[id])
			if action != null:
				action.forced = true
				return action
	return null


## ¿No puede cambiar ni huir? (Los de tipo Fantasma siempre pueden.)
func _is_trapped(b: Battler) -> bool:
	if b == null or b.has_type(&"ghost"):
		return false
	for id: StringName in b.volatiles:
		var effect := Effects.condition(id)
		if effect != null and effect.traps(self, b, b.volatiles[id]):
			return true
	return false


# --- API para los efectos (src/battle/effects/) ---

func message(text: String, tag: String = "") -> void:
	_msg(text, tag)


func deal_damage(b: Battler, amount: int, source: StringName = &"move") -> int:
	return _damage(b, amount, source)


func heal(b: Battler, amount: int, source: StringName = &"move") -> int:
	return _heal(b, amount, source)


## Cambios de características ({stat: niveles}). `secondary` = no avisar si no pueden cambiar más.
func boost(target: Battler, boosts: Dictionary, secondary: bool = false) -> bool:
	return _apply_boosts(target, DataUtil.int_dict(boosts), secondary)


func set_status(target: Battler, status: StringName, source: Battler = null, announce: bool = true) -> bool:
	return _try_set_status(target, status, announce, source)


## ¿Lo impide algo del campo, del bando o un volátil (Campo de Niebla, Velo Sagrado, Alboroto...)?
## No mira si ya tiene un estado ni las inmunidades de tipo.
func can_set_status(target: Battler, status: StringName, source: Battler = null, announce: bool = true) -> bool:
	for c: Array in _status_guards(target):
		if not (c[0] as BattleEffect).on_set_status(self, target, status, source, announce):
			return false
	return true


## Pone un estado sin comprobaciones ni mensaje (Descanso).
func force_status(target: Battler, status: StringName, turns: int = 0) -> void:
	target.pokemon.set_status(status, turns)
	_emit(BattleEvent.STATUS, target.side, target.slot, {"status": String(status)})


func cure_status(b: Battler) -> void:
	_cure_status(b)


func confuse(target: Battler, source: Battler = null, announce: bool = true) -> bool:
	return _try_confuse(target, announce, source)


## Añade un volátil con script (conditions/<id>.gd). false si ya lo tiene o su on_start lo impide.
func add_volatile(b: Battler, id: StringName, source: Battler = null, data: Dictionary = {}) -> bool:
	if b == null or b.is_fainted() or b.volatiles.has(id):
		return false
	var veil := Effects.ability(b.ability)
	if veil != null and not veil.allows_volatile(id):
		message(tr("¡%s se protege con su habilidad!") % name_of(b))
		return false
	var state := _new_state(id, data)
	var effect := Effects.condition(id)
	if effect != null and not effect.on_start(self, b, state, source):
		return false
	b.volatiles[id] = state
	_condition_event(b, id, true)
	return true


func remove_volatile(b: Battler, id: StringName) -> void:
	if b != null and b.volatiles.has(id):
		_remove_condition(b, id)


## Condición de bando (Reflejo, Velo Sagrado, Viento Afín, Red Viscosa, Deseo...).
func add_side_condition(side_index: int, id: StringName, source: Battler = null, data: Dictionary = {}) -> bool:
	var conditions := _sides[side_index].conditions
	if conditions.has(id):
		return false
	var state := _new_state(id, data)
	var effect := Effects.condition(id)
	if effect != null and not effect.on_start(self, _sides[side_index], state, source):
		return false
	conditions[id] = state
	_condition_event(_sides[side_index], id, true)
	return true


func remove_side_condition(side_index: int, id: StringName) -> void:
	if _sides[side_index].conditions.has(id):
		_remove_condition(_sides[side_index], id)


func has_side_condition(side_index: int, id: StringName) -> bool:
	return _sides[side_index].conditions.has(id)


## Clima (raindance, sunnyday, sandstorm, snow). false si ya hace ese tiempo.
func set_weather(id: StringName, source: Battler = null) -> bool:
	return _set_field(&"weather", id, source)


func clear_weather() -> void:
	_remove_condition(null, &"weather")


func weather() -> StringName:
	return StringName(str(field.get("weather", {}).get("id", "")))


## Campo (electricterrain, grassyterrain, mistyterrain, psychicterrain).
func set_terrain(id: StringName, source: Battler = null) -> bool:
	return _set_field(&"terrain", id, source)


func clear_terrain() -> void:
	_remove_condition(null, &"terrain")


func terrain() -> StringName:
	return StringName(str(field.get("terrain", {}).get("id", "")))


## Otras condiciones del campo, por id (Eco Voz...).
func field_state(id: StringName) -> Dictionary:
	return field.get(String(id), {})


func set_field_state(id: StringName, state: Dictionary) -> void:
	state["id"] = String(id)
	field[String(id)] = state


func _set_field(key: StringName, id: StringName, source: Battler) -> bool:
	if StringName(str(field.get(String(key), {}).get("id", ""))) == id:
		return false
	var state := _new_state(id, {})
	var effect := Effects.condition(id)
	if effect != null and not effect.on_start(self, null, state, source):
		return false
	if field.has(String(key)):
		_remove_condition(null, key)
	field[String(key)] = state
	_condition_event(null, key, true)
	return true


func _new_state(id: StringName, data: Dictionary) -> Dictionary:
	var effect := Effects.condition(id)
	var state := {"id": String(id), "turns": effect.duration(self) if effect != null else 0}
	state.merge(data, true)
	return state


## ¿Toca el suelo? (No los de tipo Volador ni los que levitan.)
func is_grounded(b: Battler) -> bool:
	return not b.has_type(&"flying") and b.ability != &"levitate" and b.pokemon.held_item != &"airballoon"


func speed_of(b: Battler) -> int:
	return _speed(b)


func foe_of(b: Battler) -> Battler:
	return _foe_of(b)


## Nombre para empezar una frase ("El Pidgey salvaje", "Pikachu").
func name_of(b: Battler) -> String:
	return BattleText.cap_name(b, setup.is_wild())


## Nombre dentro de una frase ("el Pidgey salvaje", "Pikachu").
func inner_name_of(b: Battler) -> String:
	return BattleText.name_of(b, setup.is_wild())


## "al Pidgey salvaje" / "a Pikachu".
func to_name(b: Battler) -> String:
	return BattleText.to_name(b, setup.is_wild())


## "del Pidgey salvaje" / "de Pikachu".
func of_name(b: Battler) -> String:
	return BattleText.of_name(b, setup.is_wild())


## "tu equipo" / "el equipo rival".
func team_name(side_index: int) -> String:
	return tr("tu equipo") if side_index == PLAYER else tr("el equipo rival")


## "de tu equipo" / "del equipo rival".
func team_of_name(side_index: int) -> String:
	return tr("de tu equipo") if side_index == PLAYER else tr("del equipo rival")


## "a tu equipo" / "al equipo rival".
func team_to_name(side_index: int) -> String:
	return tr("a tu equipo") if side_index == PLAYER else tr("al equipo rival")


func turn_action(b: Battler) -> BattleAction:
	return _turn_actions.get(b)


func is_wild_battle() -> bool:
	return setup.is_wild()


func move_index_of(b: Battler, move_id: StringName) -> int:
	for i: int in b.pokemon.moves.size():
		if b.pokemon.moves[i].id == move_id:
			return i
	return -1


## Cambio a mitad de turno (Ida y Vuelta, Relevo): el jugador elige (petición SWITCH con `reason`);
## el rival, su IA. false si no le queda nadie a quien cambiar.
func request_switch(b: Battler, reason: StringName) -> bool:
	if _sides[b.side].first_able_index() < 0:
		return false
	var steps: Array[Callable] = [_step_mid_turn_switch.bind(b, reason)]
	_push_front(steps)
	return true


func _step_mid_turn_switch(b: Battler, reason: StringName) -> void:
	if _over or b.is_fainted() or active(b.side) != b or _sides[b.side].first_able_index() < 0:
		return
	if b.side == FOE:
		_do_switch(b, BattleAI.choose_replacement(self, b.side), reason)
		return
	var r := BattleRequest.new()
	r.kind = BattleRequest.Kind.SWITCH
	r.side = PLAYER
	r.slot = b.slot
	r.party_index = b.party_index
	r.can_run = false
	r.can_switch = true
	r.can_use_items = false
	r.reason = reason
	request = r


## Remolino y Rugido: en un combate salvaje lo acaban; contra un entrenador sacan a otro al azar.
func force_switch(target: Battler) -> bool:
	if setup.is_wild():
		_msg(tr("¡%s ha salido despedido!") % name_of(target))
		_finish(BattleResult.RUN)
		return true
	var options: Array[int] = []
	for i: int in party(target.side).size():
		if _sides[target.side].can_switch_to(i):
			options.append(i)
	if options.is_empty():
		return false
	var index: int = options[rng.randi_range(0, options.size() - 1)]
	_emit(BattleEvent.SWITCH_OUT, target.side, target.slot, {"party_index": target.party_index})
	_revert_forme(target)
	_put_in(target.side, index, false)
	_msg(tr("¡%s ha sido arrastrado al combate!") % name_of(active(target.side)))
	return true


## Usa otro movimiento como si lo hubiera elegido (Espejo).
func use_move(user: Battler, move: MoveData) -> void:
	var hit := _use_move(user, move)
	_after_move(user, move, hit)


func end_battle(outcome: StringName) -> void:
	_finish(outcome)


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
		var room := _exp_room(p)
		if room == 0:
			continue
		if room > 0:
			amount = mini(amount, room)
		if amount <= 0:
			continue
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
		var room := _exp_room(p)
		if room == 0:
			break
		var start := p.exp_at_level_start()
		var next := p.exp_at_next_level()
		var level := p.level
		var chunk := mini(remaining, next - p.exp)
		if room > 0:
			chunk = mini(chunk, room)
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
