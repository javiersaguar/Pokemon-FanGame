extends Control
## Sustituto provisional de la BattleScene mientras no exista
## res://src/battle/scene/battle_scene.tscn. Permite elegir el resultado a mano.

signal _chosen(outcome: StringName)

const OPTIONS := [
	["Ganar", &"win"],
	["Perder", &"lose"],
	["Huir", &"run"],
	["Capturar", &"caught"],
]

var _info: Label
var _first_button: Button


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = Theme.new()
	theme.default_font_size = 8

	var background := ColorRect.new()
	background.color = Color(0.12, 0.12, 0.2)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(box)

	var title := Label.new()
	title.text = "Combate provisional"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_info = Label.new()
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_info)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	for option: Array in OPTIONS:
		var button := Button.new()
		button.text = option[0]
		button.pressed.connect(_chosen.emit.bind(option[1]))
		buttons.add_child(button)
		if _first_button == null:
			_first_button = button


## Mismo contrato que la BattleScene: corrutina que devuelve un OUTCOME_*.
func run(setup: Variant) -> StringName:
	_info.text = "Falta la BattleScene (Agente 3).\nSetup: %s" % str(setup)
	_first_button.grab_focus()
	var outcome: StringName = await _chosen
	return outcome
