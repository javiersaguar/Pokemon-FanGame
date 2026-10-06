class_name RandomlockeSummaryScreen
extends ChoiceScreen
var rom: RomPatch
var settings: RandomizerSettings
static func confirm(patch: RomPatch) -> bool:
	var screen := RandomlockeSummaryScreen.new()
	screen.rom = patch
	SceneManager.push_menu(screen)
	var index: int = await screen.chosen
	SceneManager.pop_menu(screen)
	return index == 0
static func code_lines(code: String) -> String:
	var lines := PackedStringArray()
	for offset: int in range(0,code.length(),14): lines.append(code.substr(offset,14))
	return "\n".join(lines)
func _ready() -> void:
	settings = rom.settings()
	caption = "Resumen de la ROM"
	choices = ["Empezar", "Copiar código", "Ver ajustes", "Exportar spoilers", "Volver"]
	var summary := "Preset: %s\nReglas Locke: %s\nMote: %s\nVersión: %d\nCódigo:\n%s" % [settings.preset,RandomlockeText.value_text(settings.locke_rules),RandomlockeText.value_text(settings.nickname_required),rom.generator_version(),code_lines(rom.seed_code())]
	notes = [summary,"Copiar el código completo para compartir exactamente esta ROM.","Ver todos los ajustes, sin revelar las especies.","Exportación opcional con todas las especies y equipos. Contiene spoilers.","Volver sin aplicar la ROM."]
	super._ready()
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		match index:
			1:
				DisplayServer.clipboard_set(rom.seed_code())
				await Dialogue.say("Código copiado.")
			2: await RandomlockeSettingsScreen.edit(settings,true)
			3:
				if await Dialogue.ask_yes_no("El registro revela todos los Pokémon. ¿Exportarlo?"):
					var file := FileAccess.open("user://randomlocke_spoilers.txt",FileAccess.WRITE)
					if file:
						file.store_string(rom.spoiler_text())
						await Dialogue.say("Registro exportado a %s." % ProjectSettings.globalize_path("user://randomlocke_spoilers.txt"))
					else: await Dialogue.say("No se pudo exportar el registro.")
			_:
				_done = true
				chosen.emit(index)
				return
