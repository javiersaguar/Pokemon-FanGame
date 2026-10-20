extends BattleEffect
## Condena Silvana: añade el tipo Planta al objetivo.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.has_type(&"grass"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var types := target.types().duplicate()
	types.append(&"grass")
	target.type_override = types
	engine.message(tr("¡%s ahora también es de tipo Planta!") % engine.name_of(target))
	return HANDLED
