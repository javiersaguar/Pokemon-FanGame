extends SceneTree
func _init() -> void:
	call_deferred("_update")
func _update() -> void:
	var input := RandomizerInput.from_dict(JsonFile.read_dict("res://tests/randomizer/fixtures/mini_game.json"))
	var rom := Randomizer.generate(input, RandomizerSettings.from_preset("clasico"), 20261004)
	if not rom.is_valid():
		printerr(rom.errors)
		quit(1)
		return
	var file := FileAccess.open("res://tests/randomizer/fixtures/golden_v2.json", FileAccess.WRITE)
	file.store_string(rom.to_json() + "\n")
	file.close()
	quit(0)
