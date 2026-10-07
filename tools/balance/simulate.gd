extends SceneTree
## godot --headless --path . -s res://tools/balance/simulate.gd -- --games=20 --seed=1
## Lee data/balance/leaders.json. Si Javier no ha puesto líderes, no inventa ninguno.


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var games := 20
	var seed_value := 1
	for arg: String in args:
		if arg.begins_with("--games="):
			games = int(arg.trim_prefix("--games="))
		elif arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
	var config: Dictionary = JsonFile.read_dict("res://data/balance/leaders.json")
	var leaders: Array = config.get("leaders", [])
	var team_specs: Array = config.get("team", [])
	if leaders.is_empty() or team_specs.is_empty():
		print("PENDIENTE JAVIER: data/balance/leaders.json no tiene líderes o equipo esperado.")
		quit(0)
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var team: Array[Pokemon] = []
	for spec: Dictionary in team_specs:
		var pokemon := Pokemon.from_spec(spec, rng)
		if pokemon != null:
			team.append(pokemon)
	for leader: Variant in leaders:
		var result := BalanceSim.simulate_trainer(team, StringName(str(leader)), games, seed_value)
		print("%s: %d/%d victorias (%d%%)" % [result.trainer, result.wins, result.games, result.win_percent])
	quit(0)
