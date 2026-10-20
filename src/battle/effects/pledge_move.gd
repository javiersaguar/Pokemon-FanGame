class_name PledgeMoveEffect
extends BattleEffect
## Votos (Fuego, Planta, Agua). Si el aliado va a usar otro Voto este turno, el primero espera y el
## segundo sale combinado: 150 de potencia y un efecto de 4 turnos. Fuego + Planta: mar de llamas en el
## bando rival (fuego); Agua + Fuego: arcoíris en el propio (agua, secundarios ×2); Planta + Agua:
## pantano en el rival (planta, Velocidad ×1/4).

const COMBOS := {
	"firepledge+grasspledge": [&"fire", &"firepledgecombo"],
	"firepledge+waterpledge": [&"water", &"waterpledgecombo"],
	"grasspledge+waterpledge": [&"grass", &"grasspledgecombo"],
}


static func _combo(a: StringName, b: StringName) -> Array:
	var ids: Array[String] = [String(a), String(b)]
	ids.sort()
	return COMBOS.get("+".join(ids), [])


func _first(engine: BattleEngine, user: Battler) -> StringName:
	var state: Dictionary = user.volatiles.get(&"pledgecombo", {})
	return StringName(str(state.get("first", ""))) if int(state.get("turn", -1)) == engine.turn else &""


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData) -> bool:
	if _first(engine, user) != &"":
		return true
	var ally := engine.ally_of(user)
	if ally == null or ally.moved_this_turn:
		return true
	var action := engine.turn_action(ally)
	if action == null or action.kind != BattleAction.Kind.FIGHT or action.move_index < 0 or action.move_index >= ally.pokemon.moves.size():
		return true
	var other := ally.pokemon.moves[action.move_index].id
	if other == move.id or _combo(move.id, other).is_empty():
		return true
	ally.volatiles[&"pledgecombo"] = {"first": String(move.id), "turn": engine.turn}
	engine.act_next(ally)
	engine.message(tr("¡%s espera a su compañero!") % engine.name_of(user))
	return false


func modify_move(engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	var first := _first(engine, user)
	var combo := _combo(first, move.id) if first != &"" else []
	if combo.is_empty():
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = combo[0]
	copy.power = 150
	return copy


func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, hit: bool) -> void:
	var first := _first(engine, user)
	user.volatiles.erase(&"pledgecombo")
	var combo := _combo(first, move.id) if first != &"" else []
	if combo.is_empty() or not hit:
		return
	var condition: StringName = combo[1]
	engine.add_side_condition(user.side if condition == &"waterpledgecombo" else 1 - user.side, condition, user)
