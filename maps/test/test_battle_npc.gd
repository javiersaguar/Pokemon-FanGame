@tool
extends NPC
## NPC de la sala de pruebas que lanza combates de prueba (se pueden perder).
## Fase R.2: nada escrito a mano; el salvaje sale de la tabla de encuentros y el
## entrenador, de los datos de entrenadores.

@export var wild_table: StringName = &"test_outdoor"
@export var trainer_id: StringName = &"ruta1_manolo"

const OPTIONS := ["Salvaje", "Entrenador", "No"]


func _on_interact(_player: Player) -> void:
	var choice: int = await Dialogue.ask("¿Quieres un combate de prueba?", PackedStringArray(OPTIONS),
		display_name)
	match choice:
		0:
			var wild := WildEncounters.pick(wild_table, &"land", Clock.period())
			if not wild.is_empty():
				await _battle(WildEncounters.make_setup(wild))
		1:
			await _battle(_trainer_setup())
		_:
			await Dialogue.say("Vale, cuando quieras.", display_name)


func _trainer_setup() -> Variant:
	var setup_class := GlobalClasses.find(&"BattleSetup")
	if setup_class and GlobalClasses.has_function(setup_class, &"trainer"):
		return setup_class.call(&"trainer", trainer_id, {"can_lose": true})
	return {"kind": "trainer", "trainer_id": trainer_id, "can_lose": true}


func _battle(setup: Variant) -> void:
	if setup is Dictionary:
		setup["can_lose"] = true
	elif setup is Object and &"can_lose" in setup:
		setup.set(&"can_lose", true)
	var outcome: StringName = await SceneManager.start_battle(setup)
	await Dialogue.say("Resultado: %s." % outcome, display_name)
