extends BattleEffect
## Canto Arcaico: Meloetta cambia de forma al usarlo.


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, hit: bool) -> void:
	if not hit or user.is_fainted():
		return
	if user.pokemon.species_id == &"meloetta":
		engine.change_forme(user, &"meloettapirouette")
	elif user.pokemon.species_id == &"meloettapirouette":
		engine.change_forme(user, &"meloetta")
