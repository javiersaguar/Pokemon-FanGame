extends BattleEffect
## Anegar: el objetivo pasa a ser solo de tipo Agua.

var new_type := &"water"
var type_name := "Agua"


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.tera_active != &"" or target.types() == [new_type] or target.pokemon.species_id in [&"arceus", &"silvally"]:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	target.type_override.assign([new_type])
	engine.message(tr("¡%s ha pasado a ser de tipo %s!") % [engine.name_of(target), type_name])
	return HANDLED
