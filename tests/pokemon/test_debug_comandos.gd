extends GutTest
## Comandos de Debug del Agente 2 (givepkmn, heal, party, setlevel).

var _saved: Dictionary


func before_each() -> void:
	_saved = (GameState.party as Party).to_dict()
	(GameState.party as Party).from_dict({})


func after_each() -> void:
	(GameState.party as Party).from_dict(_saved)


func test_givepkmn_heal_y_setlevel() -> void:
	var party := GameState.party as Party
	assert_string_contains(Debug.run_command("givepkmn pikachu 7"), "Pikachu (Nv. 7) al equipo")
	assert_eq(party.size(), 1)
	assert_true((GameState.pokedex as Pokedex).is_caught(&"pikachu"))
	party.members[0].take_damage(5)
	assert_eq(Debug.run_command("heal"), "Equipo curado.")
	assert_eq(party.members[0].current_hp, party.members[0].max_hp())
	assert_string_contains(Debug.run_command("setlevel 1 12"), "nivel 12")
	assert_eq(party.members[0].level, 12)
	assert_string_contains(Debug.run_command("party"), "1. Pikachu Nv.12")
	assert_string_contains(Debug.run_command("givepkmn noexiste"), "No existe")
