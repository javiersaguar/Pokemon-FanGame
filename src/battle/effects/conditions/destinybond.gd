extends BattleEffect
## Mismo Destino: dura hasta que vuelve a moverse. Si un golpe le debilita, el atacante también cae.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s quiere que el rival le acompañe!") % engine.name_of(holder))
	return true


func before_move_priority() -> int:
	return 5


func on_before_move(engine: BattleEngine, battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	engine.remove_volatile(battler, &"destinybond")
	if move.id != &"destinybond":
		battler.set_meta(&"destinybond_last", false)
	return true


func on_damage(engine: BattleEngine, battler: Battler, _state: Dictionary, amount: int, _source: StringName, _move: MoveData) -> int:
	var attacker: Battler = engine._move_user
	if amount >= battler.pokemon.current_hp and attacker != null and attacker.side != battler.side and not attacker.is_fainted():
		engine.message(tr("¡%s se ha llevado consigo a %s!") % [engine.name_of(battler), engine.inner_name_of(attacker)])
		engine.deal_damage(attacker, attacker.pokemon.current_hp, &"destinybond")
	return amount
