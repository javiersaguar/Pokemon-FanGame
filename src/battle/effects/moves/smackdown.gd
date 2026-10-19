extends BattleEffect
## Antiaéreo: derriba al objetivo; mientras siga en el campo toca el suelo (le afecta lo de tipo
## Tierra) y deja de volar o levitar.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted():
		return
	var flying := not engine.is_grounded(target) or str(target.volatiles.get(&"twoturnmove", {}).get("invulnerable", "")) == "air"
	engine.remove_volatile(target, &"magnetrise")
	if str(target.volatiles.get(&"twoturnmove", {}).get("invulnerable", "")) == "air":
		engine.remove_volatile(target, &"twoturnmove")
	if engine.add_volatile(target, &"smackdown") and flying:
		engine.message(tr("¡%s ha caído al suelo!") % engine.name_of(target))
