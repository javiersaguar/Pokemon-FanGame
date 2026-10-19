extends ProtectVariantConditionEffect
## Escudo Real: solo para los que hacen daño; baja un nivel el Ataque del que le toca.


func _init() -> void:
	blocks_status = false


func punish(engine: BattleEngine, user: Battler) -> void:
	engine.boost(user, {&"atk": -1}, true)
