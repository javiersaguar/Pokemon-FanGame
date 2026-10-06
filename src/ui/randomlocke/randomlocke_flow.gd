class_name RandomlockeFlow
extends RefCounted
func run(slot: int) -> void:
	var mode := await ChoiceScreen.pick("Modo de partida",["Normal","RandomLocke"],["Aventura con los datos originales del juego.","Una ROM por semilla, con reglas y ajustes configurables. Todas las especies pueden aparecer según ajustes y prohibidos."])
	if mode < 0: return
	if mode == 0:
		await SceneManager.start_new_game(&"",&"",{"slot":slot,"intro":true})
		return
	while not GameState.in_game:
		var choice := await ChoiceScreen.pick("RandomLocke",["Clásico","Solo aleatorio","Caos","Personalizar","Usar código"],["Equilibrio y reglas Locke del preset.","Aleatorización sin las reglas Locke.","Más cambios con el preset Caos.","Configurar todos los ajustes disponibles.","Pegar un código compartido de esta versión."])
		if choice < 0: return
		var settings: RandomizerSettings
		var seed_value := SeedCode.random_seed()
		if choice == 4:
			var code := await NameKeyboard.ask(SceneManager.ui_layer,"Código de semilla","",true,4096)
			if code.is_empty(): continue
			var decoded := SeedCode.decode(code)
			if not decoded.ok:
				await Dialogue.say(decoded.error)
				continue
			settings = decoded.settings
			seed_value = decoded.seed
		else:
			settings = RandomizerSettings.from_preset(RandomizerSettings.PRESETS[choice] if choice < 3 else "clasico")
			if choice == 3:
				settings = await RandomlockeSettingsScreen.edit(settings)
				if settings == null: continue
		var rom := await RandomlockeGeneratingScreen.generate(settings.to_dict(),seed_value)
		if rom == null or not rom.is_valid():
			await Dialogue.say("No se pudo generar la ROM. %s" % (str(rom.errors) if rom else "Datos no disponibles."))
			continue
		if not await RandomlockeSummaryScreen.confirm(rom): continue
		var error := await SceneManager.start_randomlocke(rom,slot,true)
		if error != OK: await Dialogue.say("No se pudo iniciar: %s." % error_string(error))
