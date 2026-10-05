extends SceneTree
## Validador de arte (Fase A.8): revisa los PNG de assets/ con las reglas de
## tools/arte/reglas.json. Falla (código 1) si un PNG tiene un tamaño no
## canónico o, si es arte propio, colores fuera de la paleta maestra.
## La lógica está en art_validator.gd (también la usa tests/ui/test_arte.gd).
##   godot --headless --path . -s res://tools/arte/validar.gd

const ArtValidator := preload("res://tools/arte/art_validator.gd")


func _initialize() -> void:
	var validator := ArtValidator.new()
	if not validator.run():
		push_error("validar.gd: faltan %s o %s." % [ArtValidator.RULES_PATH, ArtValidator.PALETTE_PATH])
		quit(1)
		return
	for line: String in validator.errors:
		print("✗ " + line)
	for line: String in validator.warnings:
		print("! " + line)
	print("\nArte: %d PNG revisados, %d errores, %d avisos." % [validator.checked, validator.errors.size(), validator.warnings.size()])
	quit(1 if not validator.errors.is_empty() else 0)
