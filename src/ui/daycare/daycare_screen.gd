class_name DaycareScreen
extends ChoiceScreen
var service: Daycare
var requested_egg := false
static func open(daycare: Daycare) -> bool:
	if daycare == null: return false
	var screen := DaycareScreen.new()
	screen.service = daycare
	SceneManager.push_menu(screen)
	await screen.closed
	var requested := screen.requested_egg
	SceneManager.pop_menu(screen)
	return requested
static func deposit_member(daycare: Daycare,index: int) -> Error:
	var p: Pokemon = GameState.party.get_at(index)
	if daycare == null or p == null: return ERR_INVALID_PARAMETER
	if p in daycare.slots: return ERR_ALREADY_EXISTS
	if GameState.party.size() <= 1 or (not p.is_fainted() and GameState.party.able_count() <= 1): return ERR_UNAVAILABLE
	if not daycare.deposit(p): return ERR_OUT_OF_MEMORY
	GameState.party.remove_at(index)
	return OK
static func withdraw_member(daycare: Daycare,index: int) -> Error:
	if daycare == null or index < 0 or index >= daycare.slots.size(): return ERR_INVALID_PARAMETER
	if GameState.party.is_full(): return ERR_OUT_OF_MEMORY
	GameState.party.add(daycare.withdraw(index))
	return OK
func _refresh() -> void:
	caption = "Guardería"
	choices = ["Dejar un Pokémon"]
	notes = ["Elige un miembro del equipo. Conserva al menos un Pokémon capaz de combatir."]
	images = [null]
	for slot: int in 2:
		var p: Pokemon = service.slots[slot] if service != null and slot < service.slots.size() else null
		choices.append(p.display_name() if p else "Plaza vacía")
		notes.append("%s / Nv%d\nObjeto: %s\nA: datos o recoger." % [p.species().name,p.level,DataDB.item(p.held_item).name if DataDB.has_item(p.held_item) else "Ninguno"] if p else "Puedes dejar aquí un Pokémon de tu equipo.")
		images.append(UiTextures.pokemon_icon(p) if p else null)
	choices.append("¡Hay un huevo!" if service != null and service.egg_ready else "Sin huevo")
	notes.append("A: pedir al encargado que te entregue el huevo." if service != null and service.egg_ready else "Camina mientras tus Pokémon compatibles están en la guardería.")
	images.append(preload("res://assets/sprites/ui/hatching/egg.png"))
	choices.append("Volver"); notes.append("Volver al menú anterior."); images.append(null)
	super._refresh()
	# El huevo se muestra a escala nativa; no cabe en el icono de lista.
	if menu.selected == 3: _icon.hide()
	menu.set_disabled(0,service == null or service.slots.size() >= 2)
	menu.set_disabled(3,service == null or not service.egg_ready or GameState.party.is_full())
func _show_detail(index: int) -> void:
	super._show_detail(index)
	if index == 3: _icon.hide()
func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		match index:
			-1,4: _done = true; closed.emit(); return
			0:
				var member := await PartyScreen.pick_member("Dejar en la guardería")
				if member >= 0 and deposit_member(service,member) != OK: await Dialogue.say("No puedes dejarlo aquí ahora. Conserva un Pokémon capaz de combatir.")
			1,2:
				var slot := index - 1
				if slot < service.slots.size():
					var p := service.slots[slot]
					var action := await ChoiceScreen.pick(p.display_name(),["Datos","Recoger","Volver"])
					if action == 0: await SummaryScreen.open(SceneManager.ui_layer,[p],0)
					elif action == 1 and withdraw_member(service,slot) != OK: await Dialogue.say("El equipo está lleno.")
			3: requested_egg = true; _done = true; closed.emit(); return
		_refresh()
		menu.select(index)
