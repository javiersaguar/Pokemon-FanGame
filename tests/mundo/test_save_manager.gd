extends GutTest
## SaveManager: ida y vuelta, escritura segura con copia .bak y versiones (Agente 1).

const SLOT := 99


func before_each() -> void:
	SaveManager.delete_save(SLOT)
	GameState.new_game()


func after_each() -> void:
	SaveManager.delete_save(SLOT)


func after_all() -> void:
	GameState.reset()


func test_guardar_y_cargar() -> void:
	GameState.player_name = "Javi"
	GameState.set_flag(&"got_pokedex")
	GameState.player_tile = Vector2i(3, 5)
	var before := JSON.stringify(GameState.to_dict())
	assert_eq(SaveManager.save_game(SLOT), OK)
	assert_true(SaveManager.has_save(SLOT))
	GameState.reset()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_eq(JSON.stringify(GameState.to_dict()), before)
	assert_eq(SaveManager.slot_summary(SLOT).get("player_name"), "Javi")


func test_la_partida_anterior_queda_en_bak() -> void:
	GameState.player_name = "Primera"
	SaveManager.save_game(SLOT)
	GameState.player_name = "Segunda"
	SaveManager.save_game(SLOT)
	var path := SaveManager.slot_path(SLOT)
	assert_true(FileAccess.file_exists(path + ".bak"))
	assert_false(FileAccess.file_exists(path + ".tmp"), "no quedan temporales")
	# Si el archivo principal se estropea, se carga la copia.
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{esto no es JSON")
	file.close()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_eq(GameState.player_name, "Primera")


func test_ranura_vacia() -> void:
	assert_false(SaveManager.has_save(SLOT))
	assert_eq(SaveManager.load_game(SLOT), ERR_FILE_NOT_FOUND)
	assert_eq(SaveManager.slot_summary(SLOT), {})


func test_partida_de_una_version_mas_nueva() -> void:
	SaveManager.save_game(SLOT)
	var path := SaveManager.slot_path(SLOT)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data["save_version"] = GameState.SAVE_VERSION + 1
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	DirAccess.remove_absolute(path + ".bak")
	assert_eq(SaveManager.load_game(SLOT), ERR_FILE_UNRECOGNIZED)
	assert_push_error("versión más nueva")
