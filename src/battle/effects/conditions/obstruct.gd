extends ProtectVariantConditionEffect
## Obstrucción: solo para los que hacen daño; baja dos niveles la Defensa del que le toca.


func _init() -> void:
	blocks_status = false


func punish(engine: BattleEngine, user: Battler) -> void:
	engine.boost(user, {&"def": -2}, true)
