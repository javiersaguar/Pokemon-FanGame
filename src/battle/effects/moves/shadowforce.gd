extends TwoTurnMoveEffect
## Golpe Umbrío: desaparece un turno (nadie le alcanza) y golpea el siguiente rompiendo protecciones.


func _init() -> void:
	charge_text = "¡%s ha desaparecido!"
	invulnerable = &"phantom"


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	BreakProtect.apply(engine, target)
	return true
