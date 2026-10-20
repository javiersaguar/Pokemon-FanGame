extends BattleEffect
## Grito Dragón: +1 nivel de crítico (+2 si es de tipo Dragón) mientras siga en el campo.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	var b := holder as Battler
	b.crit_stage += 2 if b.has_type(&"dragon") else 1
	engine.message(tr("¡%s se ha venido arriba!") % engine.name_of(b))
	return true
