class_name ControlsScreen
extends ChoiceScreen
const ACTIONS := [&"move_up",&"move_down",&"move_left",&"move_right",&"accept",&"cancel",&"menu",&"run_toggle",&"run",&"speed_up"]
const NAMES := ["Arriba","Abajo","Izquierda","Derecha","Aceptar","Volver","Menú / detalle","Alternar correr","Correr / andar","Velocidad de juego"]
static func open() -> void:
	var screen := ControlsScreen.new()
	SceneManager.push_menu(screen)
	await screen.chosen
	SceneManager.pop_menu(screen)
func _ready() -> void:
	caption = "Controles"
	for index: int in ACTIONS.size():
		choices.append(NAMES[index])
		var bindings := PackedStringArray()
		for event: InputEvent in InputMap.action_get_events(ACTIONS[index]):
			if event is InputEventKey:
				var code: Key = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				bindings.append("Teclado: " + {KEY_UP:"Flecha arriba",KEY_DOWN:"Flecha abajo",KEY_LEFT:"Flecha izquierda",KEY_RIGHT:"Flecha derecha",KEY_ENTER:"Intro",KEY_KP_ENTER:"Intro numérico",KEY_SPACE:"Espacio",KEY_SHIFT:"Mayús"}.get(code,OS.get_keycode_string(code)))
			elif event is InputEventJoypadButton:
				bindings.append("Mando: " + {JOY_BUTTON_A:"A",JOY_BUTTON_B:"B",JOY_BUTTON_X:"X",JOY_BUTTON_Y:"Y",JOY_BUTTON_START:"Start",JOY_BUTTON_BACK:"Select",JOY_BUTTON_DPAD_UP:"Cruceta arriba",JOY_BUTTON_DPAD_DOWN:"Cruceta abajo",JOY_BUTTON_DPAD_LEFT:"Cruceta izquierda",JOY_BUTTON_DPAD_RIGHT:"Cruceta derecha"}.get(event.button_index,str(event.button_index)))
			elif event is InputEventJoypadMotion: bindings.append("Mando: palanca")
		notes.append("\n".join(bindings))
	choices.append("Teclado de nombres")
	notes.append("Con mando: cruceta y A sobre las letras; Aa alterna mayúsculas. OK termina. Con teclado: Tab alterna la entrada física; Enter confirma. X/B cancela solo los campos opcionales.")
	super._ready()
