class_name CharacterChoice
extends MenuScreen
## Elección anterior a crear la partida; cancelar no sustituye el guardado.
signal chosen(id: StringName)
var gender: StringName = &"male"
var identities: Array[StringName] = []
var preview: Sprite2D
var description: Label
var _done := false

static func pick() -> StringName:
	var selected := await ChoiceScreen.pick(TranslationServer.translate("Tu personaje"), [TranslationServer.translate("Chico"), TranslationServer.translate("Chica")])
	if selected < 0: return &""
	var screen := CharacterChoice.new()
	screen.gender = &"female" if selected == 1 else &"male"
	SceneManager.push_menu(screen)
	var id: StringName = await screen.chosen
	SceneManager.pop_menu(screen)
	return id

func _ready() -> void:
	heading.text = tr("Elige tu personaje")
	identities = PlayerIdentity.ids(gender)
	panel(Rect2(128, 34, 116, 132))
	preview = Sprite2D.new()
	preview.position = Vector2(186, 86)
	canvas.add_child(preview)
	description = label("", Rect2(136, 144, 104, 18), Color("382a38"), 8)
	var labels := PackedStringArray()
	for id: StringName in identities: labels.append(PlayerIdentity.info(id).name)
	menu = make_menu(labels, Rect2(12, 62, 108, 66))
	menu.selection_changed.connect(_preview)
	_preview(0)
	run.call_deferred()

func _preview(index: int) -> void:
	var id := identities[index]
	var data := PlayerIdentity.info(id)
	preview.texture = PlayerIdentity.texture(id, &"front")
	if preview.texture:
		preview.scale = Vector2.ONE * minf(96.0 / preview.texture.get_width(), 100.0 / preview.texture.get_height())
	description.text = tr("Pozuelo de Alarcón") if data.start_map.begins_with("pozuelo/") else tr("Orcasitas")

func run() -> void:
	var index := await menu.choose()
	if _done: return
	_done = true
	chosen.emit(identities[index] if index >= 0 else &"")
