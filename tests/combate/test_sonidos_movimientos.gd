extends GutTest
## Sonidos de las animaciones de movimientos (data/battle_motion_sounds.json, del EBDX move & common
## animation pack): cada animación tiene al menos un sonido y todos los archivos existen y están
## apuntados con su procedencia.


func test_cada_animacion_tiene_sonido() -> void:
	var motion: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_moves.json"))
	var without: PackedStringArray = []
	for id: String in motion:
		if id.begins_with("_"):
			continue
		if BattleMoveAnimation.sounds(StringName(id)).is_empty():
			without.append(id)
	assert_eq(without, PackedStringArray(), "todas las animaciones suenan")


func test_los_sonidos_existen_y_tienen_procedencia() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_sounds.json"))
	var assets: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio_assets.json"))
	var registered := {}
	for f: Dictionary in assets["files"]:
		registered[String(f["target"]).get_basename()] = true
	var seen := {}
	for move: String in data["moves"]:
		for sound: Variant in data["moves"][move]:
			seen[String(sound)] = true
	for sound: String in seen:
		var base := "assets/audio/se/" + sound
		var found := false
		for ext: String in ["ogg", "wav", "mp3"]:
			found = found or ResourceLoader.exists("res://%s.%s" % [base, ext])
		assert_true(found, "existe %s" % sound)
		assert_true(registered.has(base), "%s tiene procedencia en audio_assets.json" % sound)


func test_mordisco_usa_el_sonido_de_ebdx() -> void:
	var list := BattleMoveAnimation.sounds(&"bite")
	assert_false(list.is_empty())
	assert_true(String(list[0]).begins_with("anim/"))
