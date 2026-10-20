extends BattleEffect
## Cargando un movimiento de dos turnos. Si está en el aire (Bote, Vuelo), bajo tierra (Excavar), bajo
## el agua (Buceo) o desaparecido (Golpe Umbrío, Golpe Fantasma), solo le alcanzan algunos movimientos,
## y algunos de esos le hacen el doble.

## Lugar → movimientos que le alcanzan.
const HITS := {
	"air": [&"gust", &"twister", &"thunder", &"hurricane", &"skyuppercut", &"smackdown", &"thousandarrows"],
	"underground": [&"earthquake", &"magnitude", &"fissure"],
	"underwater": [&"surf", &"whirlpool"],
	"shadow": [],
}
## Lugar → movimientos que le hacen el doble.
const DOUBLE := {
	"air": [&"gust", &"twister"],
	"underground": [&"earthquake", &"magnitude"],
	"underwater": [&"surf", &"whirlpool"],
	"phantom": [],
}


func on_try_hit(engine: BattleEngine, target: Battler, state: Dictionary, user: Battler, move: MoveData) -> bool:
	var place := str(state.get("invulnerable", ""))
	if place == "" or not HITS.has(place) or move.id in HITS[place]:
		return true
	# Fijar Blanco y Telépata (y Indefenso) alcanzan también al que vuela o se esconde.
	var aim: Dictionary = user.volatiles.get(&"lockon", {}) if user != null else {}
	if (not aim.is_empty() and str(aim.get("uid", "")) == target.pokemon.uid) \
			or (user != null and user.ability == &"noguard") or target.ability == &"noguard":
		return true
	engine.message(tr("¡El ataque %s ha fallado!") % engine.of_name(user))
	return false


func damage_modifier(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, _crit: bool) -> float:
	var state: Dictionary = target.volatiles.get(&"twoturnmove", {})
	var place := str(state.get("invulnerable", ""))
	if DOUBLE.has(place) and move.id in DOUBLE[place]:
		return 2.0
	return 1.0


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, StringName(str(state.get("move", ""))))
	return BattleAction.fight(index) if index >= 0 else null
