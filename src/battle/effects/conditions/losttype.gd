extends BattleEffect
## Ha perdido un tipo (Electrochoque, Llama Final) mientras siga en el campo.


func removed_types(state: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = []
	out.append(StringName(str(state.get("type", ""))))
	return out
