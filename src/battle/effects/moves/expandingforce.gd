extends BattleEffect
## Vasto Impacto: con Campo Psíquico y el usuario en el suelo, ×1,5 y en dobles alcanza a los dos rivales.


func modify_move(engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if not engine.is_double() or engine.terrain() != &"psychicterrain" or not engine.is_grounded(user):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.target = &"all_adjacent_foes"
	return copy


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 6144, 4096) if engine.terrain() == &"psychicterrain" and engine.is_grounded(user) else power
