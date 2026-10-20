extends BattleEffect
## Nitrochoque y Electroderrape: ×5461/4096 al daño si es supereficaz.


func modify_damage(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, amount: int) -> int:
	return DamageCalc.modify(amount, 5461, 4096) if DamageCalc.effectiveness(move, target) > 1.0 else amount
