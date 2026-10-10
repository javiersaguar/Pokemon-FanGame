class_name PlaytestSession
extends RefCounted
## Copia temporal de la aventura. El original permanece en memoria hasta salir.
signal changed
var active := false
var working := false
var snapshot: Dictionary = {}
var foes: Array[Pokemon] = []
var _preferences: Dictionary = {}
var _debug_values: Dictionary = {}

func available() -> bool:
	return OS.is_debug_build() and is_instance_valid(SceneManager.world) and is_instance_valid(SceneManager.ui_layer) and not working and not SceneManager.is_busy() and not Dialogue.is_open and not Cutscene.is_running() and not SceneManager.is_menu_open()

func begin(map_id: StringName = &"pueblo_inicial/exterior", spawn: StringName = MapRoot.DEFAULT_SPAWN) -> Error:
	if not OS.is_debug_build(): return ERR_UNAUTHORIZED
	if active or SaveManager.test_session_active or not available(): return ERR_BUSY
	var error := MapLoader.check_spawn(map_id, spawn)
	if error != OK: return error
	# Los diálogos/nombres en curso se terminan antes de abrir la sesión.
	snapshot = {"state":GameState.to_dict().duplicate(true), "slot":GameState.slot,
		"rom_patch":GameState.rom_patch.duplicate(true), "in_game":GameState.in_game}
	_preferences = UiPreferences.values.duplicate(true)
	_debug_values = {"noclip":Debug.noclip,"encounters":Debug.encounters_disabled,
		"hour":Clock.debug_hour_offset,"shiny":Pokemon.debug_force_shiny,"bgm":AudioManager.current_bgm}
	active = true
	working = true
	SaveManager.test_session_active = true
	Debug.close()
	SceneManager.close_all_menus()
	error = await SceneManager.start_new_game(map_id, spawn, {"slot":0,"intro":false})
	if error == OK:
		GameState.player_name = "Javier"
		GameState.money = 999999
		GameState.set_flag(&"story_intro_done")
		for id: StringName in [&"charizard",&"blastoise",&"venusaur",&"pikachu",&"gengar",&"lucario"]:
			GameState.party.add(Pokemon.create(id,50))
		for id: StringName in [&"potion",&"superpotion",&"hyperpotion",&"fullheal",&"revive",&"pokeball",&"ultraball",&"megabracelet",&"zring"]:
			if DataDB.has_item(id): GameState.bag.add(id,30)
		# Habilita el transporte ya implementado exclusivamente en esta copia.
		for cfg: Dictionary in GameState.world_config.get("field",{}).get("actions",{}).values():
			var item := StringName(str(cfg.get("item", "")))
			if DataDB.has_item(item): GameState.bag.add(item)
			var flag := StringName(cfg.get("required_flag", ""))
			if flag != &"": GameState.set_flag(flag)
		for id: StringName in DataDB.species_ids(): GameState.pokedex.mark_seen(id, true)
		foes = [Pokemon.create(&"magikarp",50),Pokemon.create(&"gengar",50)]
		Debug.encounters_disabled = true
		Debug.noclip = false
	working = false
	if error != OK:
		await finish()
	changed.emit()
	return error

func finish() -> Error:
	if not active: return ERR_UNAVAILABLE
	if not available(): return ERR_BUSY
	working = true
	Debug.close()
	SceneManager.close_all_menus()
	# Restaurar preferencias antes del estado: battle_style no pisa el de la partida.
	for key: String in _preferences: UiPreferences.set_value(key,_preferences[key],false)
	Clock.set_debug_hour_offset(int(_debug_values.hour))
	var error := await SceneManager.restore_test_snapshot(snapshot)
	if error == OK:
		Debug.noclip = bool(_debug_values.noclip)
		Debug.encounters_disabled = bool(_debug_values.encounters)
		Clock.set_debug_hour_offset(int(_debug_values.hour))
		Pokemon.debug_force_shiny = bool(_debug_values.shiny)
		AudioManager.play_bgm(StringName(_debug_values.bgm))
		SaveManager.test_session_active = false
		active = false
		snapshot.clear()
		foes.clear()
	working = false
	changed.emit()
	return error

## Valida todo antes de reemplazar; no admite equipos vacíos en el jugador.
func set_member(side: int, index: int, spec: Dictionary) -> Error:
	if not active or not available(): return ERR_UNAUTHORIZED
	if side not in [0,1] or index < 0 or index >= Party.MAX_SIZE: return ERR_INVALID_PARAMETER
	if not DataDB.has_species(StringName(spec.get("species",""))): return ERR_INVALID_DATA
	var moves: Array = spec.get("moves",[])
	if moves.is_empty() or moves.size() > Pokemon.MAX_MOVES: return ERR_INVALID_DATA
	for id: Variant in moves:
		if not DataDB.has_move(StringName(id)): return ERR_INVALID_DATA
	var item := StringName(spec.get("item",""))
	if item != &"" and not DataDB.has_item(item): return ERR_INVALID_DATA
	var p := Pokemon.from_spec(spec)
	var members: Array[Pokemon] = GameState.party.members if side == 0 else foes
	if index > members.size(): return ERR_INVALID_PARAMETER
	if index == members.size(): members.append(p)
	else: members[index] = p
	if side == 0: GameState.pokedex.register(p)
	changed.emit()
	return OK

func remove_member(side: int, index: int) -> Error:
	if not active or not available(): return ERR_UNAUTHORIZED
	var members: Array[Pokemon] = GameState.party.members if side == 0 else foes
	if index < 0 or index >= members.size() or members.size() <= 1: return ERR_INVALID_PARAMETER
	members.remove_at(index)
	changed.emit()
	return OK

func battle_setup(trainer: StringName, custom_foes: bool, options: Dictionary) -> BattleSetup:
	if not active or not available() or not GameState.in_game: return null
	var setup: BattleSetup
	if trainer == &"":
		if foes.is_empty(): return null
		setup = BattleSetup.wild(_fresh_foe(foes[0]),foes[0].level,options)
		if bool(options.get("double", false)) and foes.size() > 1:
			setup.foe_party.append(_fresh_foe(foes[1]))
	else:
		if not DataDB.has_trainer(trainer): return null
		setup = BattleSetup.trainer(trainer,options)
		if custom_foes:
			setup.foe_party.clear()
			for p: Pokemon in foes: setup.foe_party.append(_fresh_foe(p))
	if setup.foe_party.is_empty() or GameState.party.able_count() < (2 if setup.format == BattleSetup.Format.DOUBLE else 1): return null
	setup.can_lose = true
	return setup

static func _fresh_foe(p: Pokemon) -> Pokemon:
	var copy := Pokemon.from_dict(p.to_dict())
	copy.uid = Pokemon.new_uid()
	copy.heal_full()
	return copy

static func maps() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for id: StringName in SceneManager.list_maps():
		var result := MapLoader.prepare(id)
		if result.error != OK: continue
		var map: MapRoot = result.map
		entries.append({"id":String(id), "label":map.get_display_name(),"note":String(id)})
		map.free()
	entries.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return str(a.label)+str(a.id) < str(b.label)+str(b.id))
	return entries

static func spawns(map_id: StringName) -> Array[StringName]:
	var result := MapLoader.prepare(map_id)
	var out: Array[StringName] = []
	if result.error != OK: return out
	var map: MapRoot = result.map
	var parent := map.get_node_or_null(^"Spawns")
	if parent:
		for child: Node in parent.get_children():
			if MapLoader.valid_tile(map,MapLoader.spawn_tile(map,child.name)): out.append(child.name)
	map.free()
	DataUtil.sort_names(out)
	return out
