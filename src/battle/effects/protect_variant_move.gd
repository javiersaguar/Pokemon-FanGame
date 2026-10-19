class_name ProtectVariantMoveEffect
extends BattleEffect
## Protecciones con su propio volátil (Búnker, Barrera Espinosa, Escudo Real, Telatrampa, Obstrucción):
## seguidas son cada vez menos probables, como Protección, y fallan si ya no queda nadie por moverse.

var volatile_id: StringName = &"protect"


func is_stalling_move() -> bool:
	return true


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var foe := engine.foe_of(user)
	var last := foe == null or foe.is_fainted() or foe.moved_this_turn
	if engine.turn - user.protect_turn > 1:
		user.protect_count = 0
	var chance := int(pow(3, mini(user.protect_count, 6)))
	if last or not engine.rand_chance(&"protect", 1, chance):
		user.protect_count = 0
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.protect_count += 1
	user.protect_turn = engine.turn
	engine.add_volatile(user, volatile_id, user)
	return HANDLED
