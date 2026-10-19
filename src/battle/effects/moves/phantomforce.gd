extends TwoTurnMoveEffect
## Golpe Fantasma: desaparece un turno (nada le alcanza) y al siguiente ataca atravesando Protección.


func _init() -> void:
	charge_text = "¡%s ha desaparecido de repente!"
	invulnerable = &"shadow"


func on_prepare_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> void:
	if target.has_volatile(&"protect"):
		engine.remove_volatile(target, &"protect")
		engine.message(tr("¡%s ha roto la protección %s!") % [engine.name_of(user), engine.of_name(target)])
