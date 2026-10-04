@tool
extends NPC
## NPC de la sala de pruebas que lanza combates de prueba (se pueden perder).
## Cuando el Agente 2 entregue BattleSetup, estos diccionarios se cambian por
## BattleSetup.wild() / BattleSetup.trainer().

const OPTIONS := ["Salvaje", "Entrenador", "No"]


func _on_interact(_player: Player) -> void:
	var choice: int = await Dialogue.ask("¿Quieres un combate de prueba?", PackedStringArray(OPTIONS),
		display_name)
	match choice:
		0:
			await _battle(WildEncounters.make_setup({"species": &"pidgey", "level": 3}))
		1:
			await _battle({"kind": "trainer", "trainer_id": "test_trainer", "can_lose": true})
		_:
			await Dialogue.say("Vale, cuando quieras.", display_name)


func _battle(setup: Variant) -> void:
	if setup is Dictionary:
		setup["can_lose"] = true
	var outcome: StringName = await SceneManager.start_battle(setup)
	await Dialogue.say("Resultado: %s." % outcome, display_name)
