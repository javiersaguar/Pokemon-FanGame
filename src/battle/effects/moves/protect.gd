extends BattleEffect
## Protección: no le afectan este turno los movimientos que la respetan. Seguida, cada vez es menos
## probable (1/3, 1/9...), y falla si ya no queda nadie por moverse.


func is_stalling_move() -> bool:
	return true


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var foe := engine.foe_of(user)
	var last := foe == null or foe.is_fainted() or foe.moved_this_turn
	var chance := int(pow(3, mini(user.protect_count, 6)))
	if last or engine.rng.randi_range(0, chance - 1) != 0:
		user.protect_count = 0
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.protect_count += 1
	engine.add_volatile(user, &"protect", user)
	return HANDLED
