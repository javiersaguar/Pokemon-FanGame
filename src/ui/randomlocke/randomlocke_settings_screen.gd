class_name RandomlockeSettingsScreen
extends ChoiceScreen
signal completed(settings: RandomizerSettings)
const SHORT_LABELS := {"keep_type_themes":"Tema de tipos","story_pokemon":"Historia","allow_legendaries":"Legendarios","learnsets":"Movs. por nivel","guarantee_stab":"STAB inicial","scaled_power":"Potencia","similar_strength":"Fuerza similar","strength_tolerance":"Tolerancia (%)","level_appropriate":"Según nivel","no_early_legendaries":"Legendarios tardíos","only_implemented_moves":"Movs. implementados","trainer_duplicates":"Duplicados rival","rival_starter":"Inicial rival","leader_ace":"As de líder","tm_compat":"Compat. MT","tutor_compat":"Compat. tutor","tm_percent":"MT (%)","tutor_percent":"Tutor (%)","shiny_denominator":"Shiny 1 entre","first_encounter":"Primera captura","nickname_required":"Exigir mote","duplicates_clause":"Duplicados","shiny_clause":"Cláusula shiny","gifts_count":"Regalos usan zona","statics_count":"Estáticos usan zona","battle_items":"Objetos batalla","battle_item_limit":"Límite objetos","game_over":"Fin por derrota"}
var settings: RandomizerSettings
var readonly := false
var fields: Array = []
var schema: Dictionary = {}
static func edit(initial: RandomizerSettings, view_only := false) -> RandomizerSettings:
	var screen := RandomlockeSettingsScreen.new()
	screen.settings = RandomizerSettings.new()
	screen.settings.apply_dict(initial.to_dict())
	screen.readonly = view_only
	SceneManager.push_menu(screen)
	var result: RandomizerSettings = await screen.completed
	SceneManager.pop_menu(screen)
	return result
func _ready() -> void:
	if settings == null: settings = RandomizerSettings.from_preset("clasico")
	fields = RandomizerSettings.FIELDS + RandomizerSettings.EXTRA_FIELDS
	schema = JSON.parse_string(FileAccess.get_file_as_string("res://data/randomizer/settings_schema.json"))
	build_choices()
	super._ready()
func build_choices() -> void:
	caption = "Reglas / %s" % settings.preset if readonly else "Ajustes RandomLocke"
	choices = ["Volver"] if readonly else ["Generar esta ROM", "Cancelar"]
	notes = ["Revisa los ajustes antes de crear la partida."] if readonly else ["Generar con esta configuración y una semilla nueva. Se revisa el resumen antes de empezar.","Volver sin crear partida."]
	for field: Array in fields:
		var key: String = field[0]
		var short_value := RandomlockeText.value_text(settings.get(key)).replace("Triángulo de tipos","Triángulo").replace("Preferencia de tipo","Prefer. tipo")
		choices.append("%s: %s" % [SHORT_LABELS.get(key,RandomlockeText.field_name(key)),short_value])
		notes.append("%s: %s\n%s" % [RandomlockeText.field_name(key),RandomlockeText.value_text(settings.get(key)),str(schema.get(key,{}).get("description",""))])
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2:
			_refresh()
			continue
		var absolute := page*ROWS+index if index >= 0 else -1
		if absolute == 0 or absolute == -1 or (absolute == 1 and not readonly):
			if absolute == 0 and not readonly:
				var errors := RandomizerSettings.errors(settings.to_dict())
				if not errors.is_empty():
					await Dialogue.say("\n".join(errors))
					continue
			_done = true
			completed.emit(settings if absolute == 0 and not readonly else null)
			return
		if readonly: continue
		var field: Array = fields[absolute-2]
		var key: String = field[0]
		if field[1] == "bool": settings.set(key,not settings.get(key))
		elif field[1] == "int":
			var text := await NameKeyboard.ask(SceneManager.ui_layer,RandomlockeText.field_name(key),str(settings.get(key)),true,3)
			if not text.is_empty():
				if not text.is_valid_int():
					await Dialogue.say("Introduce un número entero.")
				else:
					var draft := settings.to_dict()
					draft[key] = text.to_int()
					var errors := RandomizerSettings.errors(draft)
					if errors.is_empty(): settings.set(key,text.to_int())
					else: await Dialogue.say("\n".join(errors))
		else:
			var values: Array = RandomizerSettings._enum_values(field[1])
			var texts := PackedStringArray()
			for value: Variant in values: texts.append(RandomlockeText.value_text(value))
			var selected := await ChoiceScreen.pick(RandomlockeText.field_name(key),texts)
			if selected >= 0: settings.set(key, int(values[selected]) if key == "shiny_denominator" else values[selected])
		settings.preset = RandomizerSettings.CUSTOM
		build_choices()
		_refresh()
		menu.select(index)
