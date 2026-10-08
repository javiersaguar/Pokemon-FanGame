class_name OptionsScreen
extends ChoiceScreen
const SPEEDS := [20,40,80,0]
const BUS_NAMES := {&"BGM":"Música",&"SE":"Efectos",&"ME":"Melodías",&"Cries":"Gritos",&"Ambient":"Ambiente"}
func _ready() -> void:
	UiPreferences.initialize()
	build_choices()
	super._ready()
func run_label() -> String:
	return "Correr siempre: %s" % ("Sí" if UiPreferences.always_run() else "No")
func build_choices() -> void:
	caption = "Opciones"
	choices = [run_label(),"Texto: %s" % {20:"Lento",40:"Normal",80:"Rápido",0:"Instantáneo"}.get(Dialogue.text_speed,"Normal"),"Combate: %s" % ("Cambio" if UiPreferences.battle_style() == &"shift" else "Fijo"),"Marco: %s" % UiPreferences.FRAME_NAMES[int(UiPreferences.values.frame)],"Pantalla completa: %s" % ("Sí" if UiPreferences.values.fullscreen else "No")]
	notes = ["R / Y: alternar correr. Mayús / B: correr, o andar si está activado. Se guarda con la partida; desde el título elige el valor de las nuevas partidas.","Velocidad de los diálogos. A cambia entre lenta, normal, rápida e instantánea.","Cambio ofrece sustituir al Pokémon entre rivales de un entrenador. Fijo mantiene el actual. Las reglas Locke pueden forzar Fijo.","Marco de los menús y diálogos claros, con gráficos originales ya publicados.","Alternar entre ventana y pantalla completa."]
	for bus: StringName in AudioManager.BUSES:
		choices.append("%s: %d %%" % [BUS_NAMES[bus],roundi(AudioManager.get_volume(bus)*100)])
		notes.append("Volumen de %s, incluido silencio." % BUS_NAMES[bus].to_lower())
	choices.append("Animación: %s" % ("Reducida" if UiPreferences.reduce_motion() else "Normal"))
	notes.append("Reduce desplazamientos, destellos y parpadeos. Conserva los mensajes y las acciones del combate.")
	choices.append("Controles")
	notes.append("Consultar teclas y botones de movimiento, menús, correr y nombres.")
	choices.append("Fotos reales: %s" % ("Sí" if UiPreferences.real_photos() else "No"))
	notes.append("En combate, enseña la foto real de los personajes famosos si está en la carpeta fotos_reales.")
	choices.append("Volver")
	notes.append("Volver al menú anterior.")
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2:
			_refresh()
			continue
		var absolute := page*ROWS+index if index >= 0 else -1
		if absolute < 0 or absolute == choices.size()-1:
			_done = true
			closed.emit()
			return
		match absolute:
			0:
				var value := not UiPreferences.always_run()
				if not GameState.in_game: UiPreferences.set_value("always_run",value)
				GameState.set_always_run(value)
			1:
				var current := SPEEDS.find(Dialogue.text_speed)
				UiPreferences.set_value("text_speed",SPEEDS[(current+1)%SPEEDS.size()])
			2: UiPreferences.set_value("battle_style","fixed" if UiPreferences.battle_style() == &"shift" else "shift")
			3: UiPreferences.set_value("frame",(int(UiPreferences.values.frame)+1)%3)
			4: UiPreferences.set_value("fullscreen",not UiPreferences.values.fullscreen)
			10: UiPreferences.set_value("reduce_animations",not UiPreferences.reduce_motion())
			11: await ControlsScreen.open()
			12: UiPreferences.set_value("real_photos",not UiPreferences.real_photos())
			_:
				var bus := AudioManager.BUSES[absolute-5]
				var labels := PackedStringArray()
				for value: int in range(0,101,10): labels.append("%d %%" % value)
				var choice := await ChoiceScreen.pick("Volumen / %s" % BUS_NAMES[bus],labels)
				if choice >= 0: UiPreferences.set_value(String(bus),float(choice)/10)
		build_choices()
		_refresh()
		menu.select(index)
