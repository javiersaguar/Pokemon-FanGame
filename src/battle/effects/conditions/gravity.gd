extends BattleEffect
## Gravedad (5 turnos): todos tocan el suelo; no se pueden usar los movimientos que vuelan o saltan.

const GROUNDED_OUT: Array[StringName] = [&"bounce", &"fly", &"flyingpress", &"highjumpkick", &"jumpkick", &"magnetrise",
	&"skydrop", &"splash", &"telekinesis", &"floatyfall", &"axekick", &"supercellslam"]


func residual_order() -> int:
	return 28


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("La gravedad ha vuelto a la normalidad."))


func grounding(_state: Dictionary) -> int:
	return 1


func disables_move(_battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.id in GROUNDED_OUT


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s por la gravedad!"


## Precisión ×5/3 (6840/4096 de Showdown), después de los niveles de precisión y evasión.
func modify_accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, accuracy: int) -> int:
	return DamageCalc.modify(accuracy, 6840.0, 4096.0)
