extends BattleEffect
## Demolición: rompe Reflejo, Pantalla de Luz y Velo Aurora del bando del objetivo antes de golpear.


func on_prepare_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> void:
	var broke := false
	for screen: StringName in [&"reflect", &"lightscreen", &"auroraveil"]:
		if engine.has_side_condition(target.side, screen):
			engine.remove_side_condition(target.side, screen)
			broke = true
	if broke:
		engine.message(tr("¡Se ha roto la barrera!"))
