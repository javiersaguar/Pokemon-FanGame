extends GutTest
## Validador de arte (Fase A.8, BIBLIA §11): main tiene que quedar con 0 errores.

const ArtValidator := preload("res://tools/arte/art_validator.gd")


func test_assets_pass_the_art_validator() -> void:
	var validator := ArtValidator.new()
	assert_true(validator.run(), "se leen tools/arte/reglas.json y la paleta")
	assert_gt(validator.checked, 0, "hay PNG que revisar")
	assert_eq(validator.errors.size(), 0, "\n".join(validator.errors.slice(0, 20)))


func test_grid_rule_accepts_square_cells_of_any_size() -> void:
	var validator := ArtValidator.new()
	var grid := {"grid": [4, 4]}
	assert_eq(validator._size_problem(Vector2i(256, 256), grid), "")
	assert_eq(validator._size_problem(Vector2i(512, 512), grid), "")
	assert_ne(validator._size_problem(Vector2i(256, 192), grid), "", "cuadros no cuadrados")
	assert_ne(validator._size_problem(Vector2i(250, 250), grid), "", "no divisible entre 4")
