extends GutTest


func test_un_equipo_mas_fuerte_gana_la_mayoria() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var strong := Pokemon.create(&"charizard", 50, rng)
	strong.apply_spec({"moves": ["flamethrower"], "ivs": 31})
	var weak := Pokemon.create(&"magikarp", 5, rng)
	weak.apply_spec({"moves": ["splash"]})
	var result := BalanceSim.simulate([strong], [weak], 5, 20, 1, 0)
	assert_eq(result.wins + result.losses + result.other, 5)
	assert_gte(result.wins, 4)
	assert_eq(result.win_percent, int(round(100.0 * float(result.wins) / 5.0)))


func test_un_entrenador_que_no_existe_no_se_inventa() -> void:
	var result := BalanceSim.simulate_trainer([], &"lider_que_no_existe", 3, 1)
	assert_eq(result.error, "no existe")
	assert_eq(result.games, 0)
