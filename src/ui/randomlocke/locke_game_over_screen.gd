class_name LockeGameOverScreen
extends MenuScreen
var snapshot: Dictionary = {}
var summary: Label
var save_error := OK
func _ready() -> void:
	heading.text = "RandomLocke / Final de la partida"
	panel(Rect2(12,34,232,63))
	summary = label("",Rect2(20,42,216,48),Color("382a38"),8)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.text = "No quedan Pokémon disponibles.\nCapturas: %d / Muertes: %d\nLa partida ha terminado." % [int(snapshot.get("captures",0)),int(snapshot.get("death_count",0))]
	menu = make_menu(["Cementerio", "Copiar código", "Menú inicial"],Rect2(24,110,208,60))
	hint.text = "Puedes revisar y compartir esta partida"
	# La ranura terminada no se podrá continuar, también después de reiniciar.
	if GameState.in_game and GameState.is_randomlocke() and GameState.slot > 0:
		save_error = SaveManager.save_game(GameState.slot)
		if save_error != OK: hint.text = "No se pudo guardar / vuelve a intentarlo"
	run.call_deferred()
func run() -> void:
	while is_inside_tree():
		var index := await menu.choose(0,false)
		match index:
			0: await CemeteryScreen.open(snapshot)
			1:
				DisplayServer.clipboard_set(str(GameState.randomlocke.get("seed_code","")))
				await Dialogue.say("Código copiado.")
			2:
				if save_error != OK:
					save_error = SaveManager.save_game(GameState.slot)
					if save_error != OK:
						await Dialogue.say("No se pudo guardar el final: %s." % error_string(save_error))
						continue
				SceneManager.pop_menu(self)
				SceneManager.go_to_title()
				return
