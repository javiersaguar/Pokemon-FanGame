extends BattleEffect
## Calcinación: quema la baya (o la gema) que lleva el objetivo.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	var item := target.pokemon.held_item
	if target.is_fainted() or item == &"" or not DataDB.has_item(item):
		return
	var data := DataDB.item(item)
	if data.pocket == &"berries" or data.category == &"jewels":
		engine.consume_held_item(target, false)
		engine.message(tr("¡%s de %s se ha quemado!") % [data.name, engine.inner_name_of(target)])
