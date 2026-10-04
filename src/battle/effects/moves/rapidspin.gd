extends BattleEffect
## Giro Rápido: tras golpear, se libera de Drenadoras y de lo que le atrapaba, quita las trampas de su
## bando y sube un nivel de Velocidad (8.ª generación en adelante; la subida está en los datos).

const HAZARDS: Array[StringName] = [&"spikes", &"toxicspikes", &"stealthrock", &"stickyweb"]


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted():
		return
	engine.remove_volatile(user, &"leechseed")
	engine.remove_volatile(user, &"partiallytrapped")
	for id: StringName in HAZARDS:
		engine.remove_side_condition(user.side, id)
