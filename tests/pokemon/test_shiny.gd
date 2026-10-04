extends GutTest
## Shiny (Fase 6.7 y DIRECTRICES §8): probabilidad por tiradas, configurable, y sprites oficiales.

const TRIES := 1000000


func _count(rolls: int, seed_value: int) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var hits := 0
	for i: int in TRIES:
		if Pokemon.roll_shiny(rng, rolls):
			hits += 1
	return hits


## Con 1.000.000 de tiradas sembradas, el número de shinies cae dentro de ±4 desviaciones típicas.
func _assert_rate(rolls: int, seed_value: int) -> void:
	var p := Pokemon.shiny_chance(rolls)
	var expected := TRIES * p
	var sigma := sqrt(TRIES * p * (1.0 - p))
	var hits := _count(rolls, seed_value)
	gut.p("%d tirada(s): %d shinies (esperado %.0f ± %.0f)" % [rolls, hits, expected, sigma])
	assert_between(float(hits), expected - 4.0 * sigma, expected + 4.0 * sigma)


func test_probabilidad_base_1_entre_4096() -> void:
	assert_eq(DataDB.shiny_odds(), 4096)
	assert_almost_eq(Pokemon.shiny_chance(1), 1.0 / 4096.0, 1e-9)
	_assert_rate(DataDB.shiny_rolls(&"base"), 11)


func test_amuleto_iris_y_masuda() -> void:
	assert_eq(DataDB.shiny_rolls(&"shiny_charm"), 3)
	assert_eq(DataDB.shiny_rolls(&"masuda"), 6)
	assert_eq(DataDB.shiny_rolls(&"masuda_shiny_charm"), 8)
	assert_almost_eq(Pokemon.shiny_chance(8), 1.0 - pow(4095.0 / 4096.0, 8), 1e-9)
	_assert_rate(DataDB.shiny_rolls(&"masuda_shiny_charm"), 22)


func test_reproducible_con_semilla() -> void:
	assert_eq(_count(1, 5), _count(1, 5))


func test_los_entrenadores_no_tiran_shiny() -> void:
	Pokemon.debug_force_shiny = true
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var trainer_mon := Pokemon.from_spec({"species": "pidgey", "level": 5}, rng)
	var wild := Pokemon.create(&"pidgey", 5, rng)
	Pokemon.debug_force_shiny = false
	assert_false(trainer_mon.shiny, "solo si su ficha lo dice")
	assert_true(wild.shiny, "el Debug fuerza los salvajes")
	assert_true(Pokemon.from_spec({"species": "pidgey", "level": 5, "shiny": true}, rng).shiny)
	assert_false(Pokemon.create(&"pidgey", 5, rng, 0).shiny, "0 tiradas = nunca")


func test_shiny_tiene_sprites_oficiales() -> void:
	for id: StringName in [&"pidgey", &"charmander", &"swirlix"]:
		for set_name: String in ["front_shiny", "back_shiny"]:
			var path := "res://assets/sprites/pokemon/%s/%s.png" % [set_name, id]
			assert_true(ResourceLoader.exists(path), path)
		var normal := (load("res://assets/sprites/pokemon/front/%s.png" % id) as Texture2D).get_image()
		var shiny := (load("res://assets/sprites/pokemon/front_shiny/%s.png" % id) as Texture2D).get_image()
		assert_ne(normal.get_data(), shiny.get_data(), "%s shiny distinto del normal" % id)
