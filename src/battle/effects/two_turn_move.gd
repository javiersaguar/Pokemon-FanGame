class_name TwoTurnMoveEffect
extends BattleEffect
## Movimientos de dos turnos (Rayo Solar, Ataque Aéreo, Bote...): el primer turno carga y el segundo
## golpea. Los que suben o se esconden son semiinvulnerables mientras cargan.

## Mensaje del turno de carga ("¡%s está absorbiendo luz!").
var charge_text: String = ""
## "" o "air" (en el aire: solo le alcanzan algunos movimientos).
var invulnerable: StringName = &""
## Con sol no carga (Rayo Solar).
var skip_in_sun: bool = false


func charge_turn(engine: BattleEngine, user: Battler, move: MoveData) -> bool:
	if user.has_volatile(&"twoturnmove"):
		engine.remove_volatile(user, &"twoturnmove")
		return false
	if skip_in_sun and engine.weather() == &"sunnyday":
		return false
	engine.add_volatile(user, &"twoturnmove", null, {"move": String(move.id), "invulnerable": String(invulnerable)})
	engine.message(tr(charge_text) % engine.name_of(user))
	return true
