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


func test_varias_ranuras_y_la_ultima_usada() -> void:
	var other := SLOT - 1
	SaveManager.delete_save(other)
	GameState.player_name = "Ana"
	assert_eq(SaveManager.save_game(other), OK)
	GameState.player_name = "Beto"
	assert_eq(SaveManager.save_game(SLOT), OK)
	assert_eq(SaveManager.last_used_slot(), SLOT)
	assert_eq(GameState.slot, SLOT, "guardar fija la ranura en curso")
	assert_eq(SaveManager.load_game(other), OK)
	assert_eq(GameState.player_name, "Ana")
	assert_eq(SaveManager.last_used_slot(), other, "cargar también cuenta como usada")
	assert_eq(SaveManager.save_game(), OK, "sin ranura guarda en la de la partida")
	assert_eq(SaveManager.slot_summary(other).get("player_name"), "Ana")
	assert_eq(SaveManager.slot_summary(SLOT).get("player_name"), "Beto")
	SaveManager.delete_save(other)
	assert_eq(SaveManager.last_used_slot(), 0, "la última usada ya no existe")


func test_resumen_de_la_ranura() -> void:
	GameState.player_name = "Javi"
	GameState.add_badge(&"badge_1")
	GameState.party.add(Pokemon.create(&"pikachu", 5))
	SaveManager.save_game(SLOT)
	var summary := SaveManager.slot_summary(SLOT)
	assert_eq(summary["slot"], SLOT)
	assert_eq(summary["mode"], "normal")
	assert_eq(summary["badges"], 1.0)
	assert_eq(summary["party"][0]["species"], "pikachu")
	assert_true(summary.has("dex_seen") and summary.has("saved_at") and summary.has("thumbnail"))
	assert_eq(SaveManager.list_slots().size(), SaveManager.slot_count())


func test_copiar_ranura() -> void:
	var other := SLOT - 1
	SaveManager.delete_save(other)
	GameState.player_name = "Copia"
	SaveManager.save_game(SLOT)
	assert_eq(SaveManager.copy_slot(SLOT, other), OK)
	assert_eq(SaveManager.slot_summary(other).get("player_name"), "Copia")
	assert_eq(SaveManager.copy_slot(SLOT, SLOT), ERR_INVALID_PARAMETER)
	SaveManager.delete_save(other)


func test_randomlocke_guarda_su_rom() -> void:
	GameState.new_game({"slot": SLOT, "mode": GameState.MODE_RANDOMLOCKE,
		"randomlocke": {"seed_code": "PANCHITO-TEST-0000-00"},
		"rom_patch": {"generator_version": 1, "starters": {"starter_1": "litwick"}}})
	assert_true(GameState.is_randomlocke())
	assert_eq(GameState.randomlocke.get("deaths"), 0)
	assert_eq(SaveManager.save_game(), OK)
	assert_true(FileAccess.file_exists(SaveManager.rom_patch_path(SLOT)))
	GameState.reset()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_eq(GameState.mode, GameState.MODE_RANDOMLOCKE)
	assert_eq(GameState.rom_patch["starters"]["starter_1"], "litwick")
	assert_eq(SaveManager.slot_summary(SLOT).get("seed_code"), "PANCHITO-TEST-0000-00")
	GameState.reset()
	SaveManager.apply_rom_patch()
