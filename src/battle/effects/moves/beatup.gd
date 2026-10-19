extends BattleEffect
## Paliza: un golpe por cada Pokémon del equipo que puede luchar y no tiene problemas de estado; cada
## uno con 5 + Ataque base / 10 de potencia.


func _members(engine: BattleEngine, user: Battler) -> Array[Pokemon]:
	var out: Array[Pokemon] = []
	for p: Pokemon in engine.party(user.side):
		if not p.is_fainted() and (p.status == &"" or p == user.pokemon):
			out.append(p)
	return out


func hit_count(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	user.set_meta(&"beatup_hit", 0)
	return _members(engine, user).size()


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	var members := _members(engine, user)
	var i: int = user.get_meta(&"beatup_hit", 0)
	user.set_meta(&"beatup_hit", i + 1)
	if members.is_empty():
		return 10
	@warning_ignore("integer_division")
	return 5 + members[mini(i, members.size() - 1)].species().base_stat(&"atk") / 10
