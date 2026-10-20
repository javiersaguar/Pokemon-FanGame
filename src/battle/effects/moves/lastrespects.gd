extends BattleEffect
## Homenaje Póstumo: 50 más 50 por cada compañero debilitado.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	return mini(5050, 50 + 50 * engine.fainted_indices(user.side).size())
