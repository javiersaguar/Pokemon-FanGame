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
	# Cada versión shiny es un archivo propio del pack (colores oficiales), distinto del normal.
	for id: StringName in [&"pidgey", &"charmander", &"swirlix"]:
		for view: String in ["front", "back", "icons", "followers"]:
			var normal_path := "res://assets/sprites/pokemon/%s/%s.png" % [view, id]
			var shiny_path := "res://assets/sprites/pokemon/%s_shiny/%s.png" % [view, id]
			assert_true(FileAccess.file_exists(normal_path), normal_path)
			assert_true(FileAccess.file_exists(shiny_path), shiny_path)
			var normal := (load(normal_path) as Texture2D).get_image()
			var shiny := (load(shiny_path) as Texture2D).get_image()
			assert_eq(shiny.get_size(), normal.get_size(), "%s: mismo tamaño" % shiny_path)
			assert_ne(normal.get_data(), shiny.get_data(), "%s shiny distinto del normal" % shiny_path)


func test_sprites_a_la_escala_del_pack() -> void:
	# Se usan tal cual (DIRECTRICES §7.1): frente 192, espalda 288, iconos 2 cuadros de 64, seguidores 4×4 de 64.
	var sizes := {"front": Vector2i(192, 192), "back": Vector2i(288, 288), "icons": Vector2i(128, 64), "followers": Vector2i(256, 256)}
	for view: String in sizes:
		var img := (load("res://assets/sprites/pokemon/%s/charmander.png" % view) as Texture2D).get_image()
		assert_eq(img.get_size(), sizes[view], view)
