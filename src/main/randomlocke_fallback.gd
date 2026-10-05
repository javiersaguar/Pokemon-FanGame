extends RefCounted
## Sustituto de orquestación, con Dialogue/Theme actuales; las pantallas son de A3.
const LABELS := {
	"starters": "Iniciales", "wild": "Salvajes", "trainers": "Entrenadores", "keep_type_themes": "Conservar tipos de entrenadores",
	"story_pokemon": "Pokémon de historia", "allow_legendaries": "Permitir legendarios", "learnsets": "Movimientos por nivel",
	"guarantee_stab": "Garantizar STAB", "scaled_power": "Potencia según nivel", "abilities": "Habilidades", "types": "Tipos",
	"base_stats": "Estadísticas", "evolutions": "Evoluciones", "items": "Objetos del mundo", "shops": "Tiendas",
	"similar_strength": "Fuerza similar", "strength_tolerance": "Tolerancia de fuerza (%)", "level_appropriate": "Especies según nivel",
	"no_early_legendaries": "Sin legendarios al inicio", "only_implemented_moves": "Solo movimientos implementados", "locke_rules": "Reglas Locke",
	"gifts": "Regalos", "statics": "Estáticos", "trades": "Intercambios", "trainer_duplicates": "Duplicados en entrenadores",
	"leader_ace": "As de líderes", "rival_starter": "Inicial del rival", "tm_compat": "Compatibilidad MT", "tm_content": "Contenido MT",
	"tutor_compat": "Compatibilidad tutores", "tutor_content": "Contenido tutores", "tm_percent": "Compatibilidad MT (%)",
	"tutor_percent": "Compatibilidad tutores (%)", "shiny_denominator": "Probabilidad shiny (1 entre)", "first_encounter": "Primera captura por zona",
	"permadeath": "Muerte permanente", "nickname_required": "Mote obligatorio", "duplicates_clause": "Cláusula duplicados",
	"shiny_clause": "Cláusula shiny", "gifts_count": "Regalos consumen zona", "statics_count": "Estáticos consumen zona",
	"level_cap": "Tope de nivel", "fixed_battle": "Combate fijo", "battle_items": "Objetos en combate",
	"battle_item_limit": "Límite de objetos por combate", "game_over": "Fin si no quedan Pokémon"
}
const VALUES := {"off": "Sin cambiar", "random": "Aleatorios", "triangle": "Triángulo de tipos", "three_stage": "Tres etapas",
	"per_zone": "Por zona", "global": "Globales", "chaos": "Caos", "type_preference": "Preferencia de tipo",
	"allowed": "Permitidos", "limited": "Limitados", "forbidden": "Prohibidos"}

func run(slot: int) -> void:
	var mode := await Dialogue.ask("Modo de partida", ["Normal", "RandomLocke", "Volver"])
	if mode == 2:
		return
	if mode == 0:
		await SceneManager.start_new_game(&"", &"", {"slot": slot, "intro": true})
		return
	while not GameState.in_game:
		var choice := await Dialogue.ask("Ajustes RandomLocke", ["Clásico", "Solo aleatorio", "Caos", "Personalizar", "Usar código", "Volver"])
		if choice == 5:
			return
		var settings: RandomizerSettings
		var seed_value := SeedCode.random_seed()
		if choice == 4:
			var code: String = await SceneManager.request_text("Pega el código de semilla", "", "PANCHITO-…", true)
			if code.is_empty():
				continue
			var decoded := SeedCode.decode(code)
			if not decoded.ok:
				await Dialogue.say(decoded.error)
				continue
			settings = decoded.settings
			seed_value = decoded.seed
		else:
			settings = RandomizerSettings.from_preset(RandomizerSettings.PRESETS[mini(choice, 2)] if choice < 3 else "clasico")
			if choice == 3 and not await customize(settings):
				continue
		var job := RandomlockeJob.new()
		SceneManager.add_child(job)
		var err := job.start(settings.to_dict(), seed_value)
		if err != OK:
			job.queue_free()
			await Dialogue.say("No se pudo iniciar la generación: %s." % error_string(err))
			continue
		SceneManager.show_flow_status("Generando RandomLocke…")
		var rom: RomPatch = await job.finished
		SceneManager.hide_flow_status()
		job.queue_free()
		if rom == null or not rom.errors.is_empty():
			await Dialogue.say("No se pudo generar la ROM. %s" % (str(rom.errors) if rom else "Datos no disponibles."))
			continue
		await Dialogue.say("Preset: %s\nReglas Locke: %s / Mote: %s" % [settings.preset, value_text(settings.locke_rules), value_text(settings.nickname_required)])
		var summary := "Semilla: %s" % rom.seed_code()
		var confirmation := await Dialogue.ask(summary, ["Empezar", "Ver ajustes", "Volver"])
		if confirmation == 1:
			await review(settings)
			if not await Dialogue.ask_yes_no("¿Empezar con esta ROM?"):
				continue
		elif confirmation != 0:
			continue
		err = await SceneManager.start_randomlocke(rom, slot, true)
		if err != OK:
			await Dialogue.say("No se pudo iniciar: %s." % error_string(err))

func value_text(value: Variant) -> String:
	if value is bool:
		return "Sí" if value else "No"
	return str(VALUES.get(str(value), str(value)))

func review(settings: RandomizerSettings) -> void:
	var fields := RandomizerSettings.FIELDS + RandomizerSettings.EXTRA_FIELDS
	for start: int in range(0, fields.size(), 5):
		var lines := PackedStringArray()
		for field: Array in fields.slice(start, start + 5):
			lines.append("%s: %s" % [LABELS[field[0]], value_text(settings.get(field[0]))])
		await Dialogue.say("\n".join(lines))

func customize(settings: RandomizerSettings) -> bool:
	settings.preset = RandomizerSettings.CUSTOM
	var fields := RandomizerSettings.FIELDS + RandomizerSettings.EXTRA_FIELDS
	var page := 0
	while true:
		var start := page * 4
		var visible := fields.slice(start, start + 4)
		var labels := PackedStringArray()
		for field: Array in visible:
			labels.append("%s: %s" % [LABELS[field[0]], value_text(settings.get(field[0]))])
		labels.append_array(["Otra página", "Generar", "Volver"])
		var selected := await Dialogue.ask("Personalizar (%d/%d)" % [page + 1, ceili(fields.size() / 4.0)], labels)
		if selected == visible.size() + 2:
			return false
		if selected == visible.size() + 1:
			var errors := RandomizerSettings.errors(settings.to_dict())
			if errors.is_empty():
				return true
			await Dialogue.say("\n".join(errors))
		elif selected == visible.size():
			page = (page + 1) % ceili(fields.size() / 4.0)
		else:
			var field: Array = visible[selected]
			var key: String = field[0]
			if field[1] == "bool":
				settings.set(key, not settings.get(key))
			elif field[1] == "int":
				var text: String = await SceneManager.request_text(LABELS[key], str(settings.get(key)), "Número", true)
				if text.is_valid_int():
					var draft := settings.to_dict()
					draft[key] = text.to_int()
					var errors := RandomizerSettings.errors(draft)
					if errors.is_empty():
						settings.set(key, text.to_int())
					else:
						await Dialogue.say("\n".join(errors))
			else:
				var values: Array = RandomizerSettings._enum_values(field[1])
				var options := PackedStringArray()
				for value: Variant in values:
					options.append(value_text(value))
				options.append("Volver")
				var index := await Dialogue.ask(LABELS[key], options)
				if index < values.size():
					settings.set(key, int(values[index]) if key == "shiny_denominator" else values[index])
	return false
