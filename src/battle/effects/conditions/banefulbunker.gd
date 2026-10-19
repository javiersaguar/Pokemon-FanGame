extends ProtectVariantConditionEffect
## Búnker: envenena al que le toca.


func punish(engine: BattleEngine, user: Battler) -> void:
	engine.set_status(user, &"psn", null, false)
