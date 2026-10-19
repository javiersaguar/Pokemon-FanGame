extends ScreenConditionEffect
## Velo Aurora: la mitad de daño físico y especial contra su bando durante 5 turnos.


func _init() -> void:
	screen_name = "Velo Aurora"


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Velo Aurora ha aumentado la resistencia %s a los ataques físicos y especiales!") % engine.team_of_name((holder as BattleSide).index))
	return true


func damage_modifier(_engine: BattleEngine, user: Battler, target: Battler, move: MoveData, crit: bool) -> float:
	if crit or user.side == target.side or move.is_status() or user.ability == &"infiltrator":
		return 1.0
	return 0.5
