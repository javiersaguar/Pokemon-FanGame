class_name BattleDataBox
extends Panel
## Caja de datos de un Pokémon en combate (coordenadas del UiCanvas, 256×192):
## nombre, sexo, ★ si es shiny, nivel, estado, barra de PS y, en la del jugador,
## los PS en número y la barra de experiencia. `pokemon` = resumen de BattleScene._summary().

const FOE_SIZE := Vector2(120, 38)
const PLAYER_SIZE := Vector2(120, 38)
const BAR_SIZE := Vector2(62, 6)
const ICONS := "res://assets/sprites/ui/icons/"
const GENDER_ICONS: Dictionary[StringName, Texture2D] = {
	&"male": preload("res://assets/sprites/ui/icons/gender_male.png"),
	&"female": preload("res://assets/sprites/ui/icons/gender_female.png"),
}
const SHINY_STAR := preload("res://assets/sprites/ui/icons/shiny_star.png")
const HP_FRAME := preload("res://assets/sprites/ui/battle/hp_frame.png")

@export var is_player := false

var hp := 0
var max_hp := 1
var pokemon_name := ""
var mechanic: StringName = &""
var tera_type: StringName = &""
var _mechanic_tag: Label

var _name: Label
var _gender: TextureRect
var _star: TextureRect
var _level: Label
var _status: NinePatchRect
var _status_text: Label
var _hp_bar: HpBar
var _hp_text: Label
var _exp_bar: HpBar


func _ready() -> void:
	size = PLAYER_SIZE if is_player else FOE_SIZE
	mouse_filter = MOUSE_FILTER_IGNORE
	_name = _label(Vector2(7, 2), &"")
	_name.size.x = 60
	_name.clip_text = true
	_gender = _icon(Vector2.ZERO)
	_star = _icon(Vector2.ZERO)
	_star.texture = SHINY_STAR
	_level = _label(Vector2(size.x - 35, 6), &"SmallLabel")
	_level.size.x = 28
	_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bar_origin := Vector2(size.x - BAR_SIZE.x - 6, 19)
	var tag := _label(bar_origin + Vector2(-17, -2), &"TagLabel")
	tag.text = tr("PS")
	var frame := NinePatchRect.new()
	frame.texture = HP_FRAME
	frame.patch_margin_left = 2
	frame.patch_margin_top = 2
	frame.patch_margin_right = 2
	frame.patch_margin_bottom = 2
	frame.position = bar_origin
	frame.size = BAR_SIZE
	add_child(frame)
	_hp_bar = HpBar.new()
	_hp_bar.position = bar_origin + Vector2(1, 1)
	_hp_bar.size = BAR_SIZE - Vector2(2, 2)
	add_child(_hp_bar)
	_status = NinePatchRect.new()
	for side: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		_status.set_patch_margin(side, 2)
	_status.position = Vector2(7, 18)
	_status.size = Vector2(22, 9)
	add_child(_status)
	_mechanic_tag = _label(Vector2(7,27), &"SmallLabel")
	_status_text = Label.new()
	_status_text.theme_type_variation = &"SmallLightLabel"
	_status_text.set_anchors_preset(PRESET_FULL_RECT)
	_status_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status.add_child(_status_text)
	if is_player:
		_hp_text = _label(Vector2(bar_origin.x, 25), &"SmallLabel")
		_hp_text.size.x = BAR_SIZE.x
		_hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_hp_bar.value_changed.connect(_on_hp_bar_changed)
		_exp_bar = HpBar.new()
		_exp_bar.exp_mode = true
		_exp_bar.position = Vector2(30, size.y - 6)
		_exp_bar.size = Vector2(size.x - 38, 2)
		add_child(_exp_bar)


func show_pokemon(pokemon: Dictionary) -> void:
	pokemon_name = str(pokemon.get("name", "?"))
	_name.text = pokemon_name
	var after_name := minf(69,_name.position.x + _name.get_theme_font(&"font").get_string_size(pokemon_name,HORIZONTAL_ALIGNMENT_LEFT,-1,_name.get_theme_font_size(&"font_size")).x + 2)
	var gender := StringName(pokemon.get("gender", ""))
	_gender.texture = GENDER_ICONS.get(gender)
	_gender.visible = _gender.texture != null
	_gender.position = Vector2(after_name, 6).round()
	_star.visible = bool(pokemon.get("shiny", false))
	_star.position = Vector2(after_name + (8 if _gender.visible else 0), 6).round()
	set_level(int(pokemon.get("level", 1)))
	set_status(StringName(pokemon.get("status", "")))
	max_hp = maxi(int(pokemon.get("max_hp", 1)), 1)
	set_hp(int(pokemon.get("hp", max_hp)))
	set_exp(float(pokemon.get("exp_ratio", 0.0)))


func set_level(level: int) -> void:
	_level.text = tr("Nv%d") % level


func set_status(status: StringName) -> void:
	var path := ICONS + "status/%s.png" % status
	_status.visible = status != &"" and ResourceLoader.exists(path)
	if _status.visible:
		_status.texture = load(path)
		_status_text.text = UiColors.STATUS_LABELS.get(status, "")
		_status_text.theme_type_variation = &"SmallLabel" if status in [&"par", &"frz"] else &"SmallLightLabel"


func set_hp(value: int) -> void:
	hp = clampi(value, 0, max_hp)
	_hp_bar.set_instant(float(hp) / max_hp)
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
		_exp_bar.set_instant(ratio)


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


func _icon(at: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.position = at
	icon.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(icon)
	return icon

func set_mechanic(kind: StringName,type: StringName = &"") -> void:
	mechanic = kind
	tera_type = type
	_mechanic_tag.text = {&"mega":"M",&"z":"Z",&"dynamax":"MAX",&"tera":"T"}.get(kind,"")
