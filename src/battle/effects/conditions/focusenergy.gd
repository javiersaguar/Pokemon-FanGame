extends BattleEffect
## Foco Energía: +2 niveles de crítico mientras siga en el campo.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	(holder as Battler).crit_stage += 2
	engine.message(tr("¡%s se está preparando para luchar!") % engine.name_of(holder))
	return true
