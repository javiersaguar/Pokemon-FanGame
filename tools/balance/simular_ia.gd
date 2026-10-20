extends Node
## Prueba la IA de los entrenadores con su propio equipo (espejo) contra una IA al azar. Necesita los
## autoloads, por eso es una escena:
##   godot --headless --path . res://tools/balance/simular_ia.tscn -- --games=20 --seed=1 --ia=ayuso,iniesta
## Sin --ia, los líderes, el Alto Mando y Pedro Sánchez (clases con ai_level 4 y entrenadores de gimnasio).

const POR_DEFECTO := "ayuso,laporta,labrador,joaquin,quevedo,aupa_athletic,latasa,banderas,iniesta,nadal,gasol,alonso,pedro_sanchez"


func _ready() -> void:
	var games := 20
	var seed_value := 1
	var ids := POR_DEFECTO
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--games="):
			games = int(arg.trim_prefix("--games="))
		elif arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--ia="):
			ids = arg.trim_prefix("--ia=")
	for trainer_id: String in ids.split(",", false):
		if not DataDB.has_trainer(StringName(trainer_id)):
			print("%s: no existe" % trainer_id)
			continue
		var setup := BattleSetup.trainer(StringName(trainer_id))
		var mirror := BalanceSim.simulate(setup.foe_party, setup.foe_party, games, seed_value, setup.ai_level, 0)
		print("%s (IA %d) contra IA al azar: %d/%d victorias (%d%%)" % [trainer_id, setup.ai_level, mirror.wins, mirror.games, mirror.win_percent])
	get_tree().quit()
