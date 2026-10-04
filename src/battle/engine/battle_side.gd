class_name BattleSide
extends RefCounted
## Un bando del combate: su equipo y sus Pokémon en el campo (1 en individuales).

var index: int
var party: Array[Pokemon] = []
var active: Array[Battler] = []


func _init(side_index: int, members: Array[Pokemon]) -> void:
	index = side_index
	party = members


## ¿Le queda algún Pokémon que pueda luchar (incluido el que está en el campo)?
func has_able() -> bool:
	return able_count() > 0


func all_fainted() -> bool:
	return not has_able()


## Primer Pokémon del equipo que puede luchar y no está ya en el campo (-1 si ninguno).
func first_able_index() -> int:
	for i: int in party.size():
		if can_switch_to(i):
			return i
	return -1


func can_switch_to(i: int) -> bool:
	if i < 0 or i >= party.size() or party[i].is_fainted():
		return false
	for b: Battler in active:
		if b != null and b.party_index == i and not b.is_fainted():
			return false
	return true


func able_count() -> int:
	var n := 0
	for p: Pokemon in party:
		if not p.is_fainted():
			n += 1
	return n
