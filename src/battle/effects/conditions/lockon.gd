extends BattleEffect
## Fijar Blanco: hasta el final del turno siguiente, sus movimientos contra ese objetivo no fallan.


func duration(_engine: BattleEngine) -> int:
	return 2


func ensures_hit(_engine: BattleEngine, _user: Battler, state: Dictionary, target: Battler, _move: MoveData) -> bool:
	return target != null and str(state.get("uid", "")) == target.pokemon.uid
