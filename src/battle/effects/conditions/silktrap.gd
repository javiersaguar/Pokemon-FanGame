extends ProtectVariantConditionEffect
## Telatrampa: solo para los que hacen daño; baja un nivel la Velocidad del que le toca.


func _init() -> void:
	blocks_status = false


func punish(engine: BattleEngine, user: Battler) -> void:
	engine.boost(user, {&"spe": -1}, true)
