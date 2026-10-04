class_name BattleDataBox
extends Panel
## Caja de datos de un Pokémon en combate: nombre, sexo, nivel, estado, barra de
## PS y, en la del jugador, los PS en número y la barra de experiencia.
## `pokemon` es el resumen que mandan los eventos (ver BattleScene).

const FOE_SIZE := Vector2(124, 30)
const PLAYER_SIZE := Vector2(132, 40)
const BAR_WIDTH := 64
const GENDER_ICONS: Dictionary[StringName, PackedStringArray] = {
	&"male": ["..###", "...##", "..#.#", ".##..", "#..#.", "#..#.", ".##.."],
	&"female": [".###.", "#...#", "#...#", ".###.", "..#..", ".###.", "..#.."],
}
const GENDER_COLORS: Dictionary[StringName, Color] = {
	&"male": Color("4878e8"), &"female": Color("e85868"),
}

@export var is_player := false

var hp := 0
var max_hp := 1

var _name: Label
var _level: Label
var _status_back: ColorRect
var _status: Label
var _hp_bar: HpBar
var _hp_text: Label
var _exp_bar: HpBar
var _gender: StringName = &""


func _ready() -> void:
	size = PLAYER_SIZE if is_player else FOE_SIZE
	mouse_filter = MOUSE_FILTER_IGNORE
	_name = _label(Vector2(6, 1), &"")
	_level = _label(Vector2(size.x - 34, 6), &"SmallLabel")
	_level.size.x = 28
	_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status_back = ColorRect.new()
	_status_back.position = Vector2(7, 20)
	_status_back.size = Vector2(20, 8)
	_status_back.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_status_back)
	_status = Label.new()
	_status.theme_type_variation = &"SmallLightLabel"
	_status.size = _status_back.size
	_status.position.y = -1
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_back.add_child(_status)
	_label(Vector2(size.x - BAR_WIDTH - 20, 19), &"SmallLabel").text = tr("PS")
	_hp_bar = HpBar.new()
	_hp_bar.position = Vector2(size.x - BAR_WIDTH - 6, 21)
	_hp_bar.size = Vector2(BAR_WIDTH, 4)
	add_child(_hp_bar)
	if is_player:
		_hp_text = _label(Vector2(size.x - 6 - 60, 25), &"SmallLabel")
		_hp_text.size.x = 60
		_hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_hp_bar.value_changed.connect(_on_hp_bar_changed)
		_exp_bar = HpBar.new()
		_exp_bar.exp_mode = true
		_exp_bar.position = Vector2(6, size.y - 5)
		_exp_bar.size = Vector2(size.x - 12, 2)
		add_child(_exp_bar)


func show_pokemon(pokemon: Dictionary) -> void:
	_name.text = str(pokemon.get("name", "?"))
	_gender = StringName(pokemon.get("gender", ""))
	set_level(int(pokemon.get("level", 1)))
	set_status(StringName(pokemon.get("status", "")))
	max_hp = maxi(int(pokemon.get("max_hp", 1)), 1)
	set_hp(int(pokemon.get("hp", max_hp)))
	if _exp_bar:
		_exp_bar.ratio = float(pokemon.get("exp", 0.0))
	queue_redraw()


func set_level(level: int) -> void:
	_level.text = tr("Nv%d") % level


func set_status(status: StringName) -> void:
	_status.text = UiColors.STATUS_LABELS.get(status, "")
	_status_back.color = UiColors.STATUS_COLORS.get(status, Color.GRAY)
	_status_back.visible = _status.text != ""


func set_hp(value: int) -> void:
	hp = clampi(value, 0, max_hp)
	_hp_bar.ratio = float(hp) / max_hp
	_update_hp_text(hp)


## Baja o sube la barra de PS hasta `value` (se puede esperar).
func animate_hp(value: int, new_max_hp: int = -1, duration: float = 0.6) -> void:
	if new_max_hp > 0:
		max_hp = new_max_hp
	hp = clampi(value, 0, max_hp)
	await _hp_bar.animate_to(float(hp) / max_hp, duration)
	_update_hp_text(hp)


func animate_exp(ratio: float, duration: float = 0.6) -> void:
	if _exp_bar:
		await _exp_bar.animate_to(ratio, duration)


func set_exp(ratio: float) -> void:
	if _exp_bar:
		_exp_bar.ratio = ratio


func _draw() -> void:
	var pattern: PackedStringArray = GENDER_ICONS.get(_gender, PackedStringArray())
	if pattern.is_empty():
		return
	var origin := _name.position + Vector2(_name.get_minimum_size().x + 2, 5)
	var color: Color = GENDER_COLORS[_gender]
	for y: int in pattern.size():
		for x: int in pattern[y].length():
			if pattern[y][x] == "#":
				draw_rect(Rect2(origin + Vector2(x, y), Vector2.ONE), color)


func _on_hp_bar_changed(ratio: float) -> void:
	_update_hp_text(roundi(ratio * max_hp))


func _update_hp_text(value: int) -> void:
	if _hp_text:
		_hp_text.text = "%d/%d" % [value, max_hp]


func _label(at: Vector2, type: StringName) -> Label:
	var label := Label.new()
	label.position = at
	if type != &"":
		label.theme_type_variation = type
	add_child(label)
	return label
