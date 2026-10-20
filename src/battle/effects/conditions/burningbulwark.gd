extends ProtectVariantConditionEffect
## Llama Protectora: quema al que le toca.


func punish(engine: BattleEngine, user: Battler) -> void:
	engine.set_status(user, &"brn", null, true)
