extends BattleEffect
## Corte Furia: cada vez que se usa seguida y acierta dobla la potencia, hasta 160.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	var streak: int = user.get_meta(&"furycutter_streak", 0) if int(user.get_meta(&"furycutter_turn", -10)) == engine.turn - 1 else 0
	return mini(160, power * int(pow(2, streak)))


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, hit: bool) -> void:
	var consecutive := int(user.get_meta(&"furycutter_turn", -10)) == engine.turn - 1
	var streak: int = user.get_meta(&"furycutter_streak", 0) if consecutive else 0
	user.set_meta(&"furycutter_streak", mini(streak + 1, 3) if hit else 0)
	user.set_meta(&"furycutter_turn", engine.turn if hit else -10)
