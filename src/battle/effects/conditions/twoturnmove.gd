extends BattleEffect
## Cargando un movimiento de dos turnos. Si está en el aire (Bote, Vuelo), solo le alcanzan los
## movimientos que pueden golpear a quien vuela.

const HITS_AIRBORNE: Array[StringName] = [&"gust", &"twister", &"thunder", &"hurricane", &"skyuppercut", &"smackdown", &"thousandarrows"]


func on_try_hit(engine: BattleEngine, target: Battler, state: Dictionary, user: Battler, move: MoveData) -> bool:
	if str(state.get("invulnerable", "")) != "air" or move.id in HITS_AIRBORNE:
		return true
	engine.message(tr("¡El ataque %s ha fallado!") % engine.of_name(user))
	return false


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, StringName(str(state.get("move", ""))))
	return BattleAction.fight(index) if index >= 0 else null
