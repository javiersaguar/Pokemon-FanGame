class_name SaveSlotsScreen
extends MenuScreen
## Ocho tarjetas por página; modo, miniatura, resumen y gestión de cada ranura.
signal selected(slot: int)
const PAGE_SIZE := 8
var mode: StringName = &"load" # load / new / save / copy
var start_slot := 1
var _page := 0
var _copy_from := 0
var _operating := false
var _done := false
var _detail: Label
var _slots: Array[int] = []

static func choose(kind: StringName = &"load", start := 1) -> int:
	var screen := SaveSlotsScreen.new()
	screen.mode = kind
	screen.start_slot = start
	SceneManager.push_menu(screen)
	var slot: int = await screen.selected
	SceneManager.pop_menu(screen)
	return slot

func _ready() -> void:
	_page = clampi((start_slot - 1) / PAGE_SIZE, 0, (SaveManager.slot_count() - 1) / PAGE_SIZE)
	_detail = label("", Rect2(12, 157, 232, 14), Color("fff4d8"), 8)
	_detail.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	hint.text = "C / START: gestionar    X / B: volver"
	_refresh()
	menu.select(_slots.find(start_slot) if start_slot in _slots else 0)
	run.call_deferred()

func _refresh() -> void:
	if menu:
		canvas.remove_child(menu)
		menu.queue_free()
	_slots.clear()
	var texts := PackedStringArray()
	for slot: int in range(_page * PAGE_SIZE + 1, mini((_page + 1) * PAGE_SIZE, SaveManager.slot_count()) + 1):
		_slots.append(slot)
		var summary := SaveManager.slot_summary(slot)
		var caption := "Vacía" if not SaveManager.has_save(slot) else "Dañada"
		if not summary.is_empty():
			caption = "Locke" if summary.get("mode", "normal") == "randomlocke" else "Normal"
			if summary.get("status", "") == "finished": caption = "Finalizada"
		texts.append("%d / %s\n%s" % [slot, caption, summary.get("player_name", "--")])
	menu = make_menu(texts, Rect2(12, 34, 236, 120), 2)
	for i: int in _slots.size():
		var summary := SaveManager.slot_summary(_slots[i])
		var button := menu.get_child(i) as BattleButton
		button.compact = true
		button.align_left = true
		button.content_left = 40
		button.custom_minimum_size = Vector2(112, 27)
		button.color = &"azul" if summary.is_empty() else (&"verde" if summary.get("mode", "normal") == "randomlocke" else &"amarillo")
		menu.set_disabled(i, mode == &"load" and _copy_from == 0 and (summary.is_empty() or summary.get("status", "") == "finished"))
		var thumbnail := TextureRect.new()
		thumbnail.position = Vector2(5, 2)
		thumbnail.size = Vector2(32, 24)
		thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumbnail.texture = SaveManager.thumbnail(_slots[i])
		thumbnail.mouse_filter = MOUSE_FILTER_IGNORE
		button.add_child(thumbnail)
	menu.selection_changed.connect(_show_detail)
	heading.text = {&"new": "Elegir ranura", &"save": "Guardar partida", &"load": "Cargar partida", &"copy": "Destino de la copia"}.get(mode, "Partidas")
	if _copy_from > 0: heading.text = "Copiar ranura %d: elige destino" % _copy_from
	if SaveManager.slot_count() > PAGE_SIZE: heading.text += " / %d/%d" % [_page + 1, ceili(float(SaveManager.slot_count()) / PAGE_SIZE)]
	_show_detail(0)

func _show_detail(index: int) -> void:
	if index < 0 or index >= _slots.size(): return
	var summary := SaveManager.slot_summary(_slots[index])
	_detail.text = "Ranura disponible" if summary.is_empty() else "%s / %d med. / %d min / ₽%d" % [
		summary.get("map_name", ""), int(summary.get("badges", 0)), int(float(summary.get("play_time", 0)) / 60), int(summary.get("money", 0))]

func run() -> void:
	while is_inside_tree() and not _done:
		var choice := await menu.choose()
		if choice == -2:
			_refresh()
			continue
		if choice < 0:
			if _copy_from > 0:
				_copy_from = 0
				_refresh()
				continue
			_done = true
			selected.emit(0)
			return
		var slot := _slots[choice]
		if _copy_from > 0:
			await _copy_to(slot)
			_refresh()
			continue
		if mode in [&"new", &"save", &"copy"] and SaveManager.has_save(slot):
			if not await Dialogue.ask_yes_no("¿Sobrescribir la ranura %d? Su partida anterior se perderá al guardar." % slot):
				continue
		_done = true
		selected.emit(slot)
		return

func _unhandled_input(event: InputEvent) -> void:
	if _done or _operating or not menu.is_choosing or Engine.get_process_frames() == menu._active_frame:
		return
	if event.is_action_pressed(&"menu"):
		get_viewport().set_input_as_handled()
		_manage()

func _manage() -> void:
	_operating = true
	menu.is_choosing = false
	var slot := _slots[menu.selected]
	var choices := PackedStringArray(["Copiar", "Borrar"])
	if SaveManager.slot_count() > PAGE_SIZE: choices.append_array(["Página anterior", "Página siguiente"])
	choices.append("Volver")
	var choice := await Dialogue.ask("Gestionar ranura %d" % slot, choices)
	match choice:
		0:
			if SaveManager.has_save(slot):
				_copy_from = slot
			else: await Dialogue.say("Esta ranura está vacía.")
		1:
			if SaveManager.has_save(slot) and await Dialogue.ask_yes_no("¿Borrar la ranura %d?" % slot):
				if await Dialogue.ask_yes_no("Se perderán la partida, miniatura y ROM. ¿Borrar definitivamente?"):
					SaveManager.delete_save(slot)
		2, 3:
			if choices.size() > 3:
				_page = wrapi(_page + (-1 if choice == 2 else 1), 0, ceili(float(SaveManager.slot_count()) / PAGE_SIZE))
	_operating = false
	menu._finish(-2) # El único bucle renueva tarjetas y vuelve a esperar.

func _copy_to(slot: int) -> void:
	if slot == _copy_from:
		await Dialogue.say("Elige otra ranura para la copia.")
		return
	if SaveManager.has_save(slot) and not await Dialogue.ask_yes_no("¿Sobrescribir la ranura %d con la copia?" % slot): return
	var error := SaveManager.copy_slot(_copy_from, slot)
	await Dialogue.say("Partida copiada." if error == OK else "No se pudo copiar: %s." % error_string(error))
	_copy_from = 0
