extends BattleEffect
## Movimiento bloqueado (Golpe, Danza Pétalo, Enfado), como el "lockedmove" de Showdown.
## Al empezar sortea cuántos turnos dura el arrebato (`true_turns`, 2 o 3). El volátil dura 2 turnos y
## cada golpe que acierta lo renueva mientras quede arrebato. Si un turno no golpea (falla, Protección,
## parálisis...), se acaba: con confusión si era el último turno del arrebato y sin ella si no.
## Dormido, se acaba al final del turno sin confusión.


func duration(_engine: BattleEngine) -> int:
	return 2


func on_start(engine: BattleEngine, _holder: Variant, state: Dictionary, _source: Battler) -> bool:
	state["true_turns"] = engine.rand_int(&"lockedmove_turns", 2, 3)
	return true


func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	if b.pokemon.status == &"slp":
		state["no_fatigue"] = true
		engine.remove_volatile(b, &"lockedmove")
		return
	state["true_turns"] = int(state["true_turns"]) - 1


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	if state.get("no_fatigue", false) or int(state["true_turns"]) > 1 or b.is_fainted():
		return
	if not b.has_volatile(&"confusion"):
		engine.message(tr("¡%s está agotado!") % engine.name_of(b))
		engine.confuse(b, b, false)


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, StringName(str(state.get("move", ""))))
	return BattleAction.fight(index) if index >= 0 else null
