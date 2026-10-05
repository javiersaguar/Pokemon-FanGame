class_name LockeBattleDriver
extends BattleDriver
## Envuelve el adaptador existente: no cambia el motor ni la escena de combate.

var inner: EngineDriver
var encounter: Dictionary = {}
var context: Dictionary
var _finished := false

func _init(setup: BattleSetup, battle_context: Dictionary = {}) -> void:
	context = battle_context.duplicate(true)
	setup.locke_rules = bool(GameState.locke.rules.rules().get("locke_rules", true)) and bool(GameState.locke.rules.rules().get("permadeath", true))
	if setup.is_wild() and not setup.foe_party.is_empty():
		encounter = GameState.locke.begin(setup.foe_party[0], str(context.get("zone_id", "")), str(context.get("source", "wild")))
	inner = EngineDriver.new(setup)

func info() -> Dictionary:
	return inner.info()
func start() -> Array:
	return _observe(inner.start())
func request() -> Dictionary:
	return inner.request()
func submit(action: Dictionary) -> Array:
	if StringName(action.get("type", "")) == &"item" and not can_use_item(StringName(action.get("item", "")), int(action.get("party_index", -1))):
		return []
	return _observe(inner.submit(action))
func is_over() -> bool:
	return inner.is_over()
func outcome() -> StringName:
	return inner.outcome()
func player_active() -> Dictionary:
	return inner.player_active()
func player_party() -> Array[Dictionary]:
	return inner.player_party()
func battle_items() -> Array[Dictionary]:
	return inner.battle_items()
func item_needs_target(item_id: StringName) -> bool:
	return inner.item_needs_target(item_id)
func can_use_item(item_id: StringName, party_index: int = -1) -> bool:
	if DataDB.has_item(item_id) and DataDB.item(item_id).is_ball() and not encounter.is_empty() and not GameState.locke.can_catch(encounter):
		return false
	return inner.can_use_item(item_id, party_index)

func _observe(events: Array) -> Array:
	for event: BattleEvent in events:
		if event.type == &"pokemon_died":
			var index := int(event.data.get("party_index", -1))
			var pokemon := GameState.party.get_at(index) as Pokemon
			if pokemon != null:
				var details := context.duplicate(true)
				details.merge(event.data, true)
				details["opponent"] = str(event.data.get("trainer", "")) if str(event.data.get("trainer", "")) != "" else str(event.data.get("foe_name", ""))
				GameState.locke.death(pokemon, details)
	return events

func finish() -> void:
	if _finished:
		return
	_finished = true
	var caught: Pokemon = inner.engine.result.caught_pokemon
	# Captura y mote se confirman en el mundo antes de añadir al equipo/PC.
	inner.engine.result.caught_pokemon = null
	inner.finish()
	GameState.locke.remove_dead()
	if not encounter.is_empty():
		if caught != null:
			caught.original_trainer = GameState.player_name
			caught.trainer_id = GameState.trainer_id
			caught.met_location = GameState.map_id
			caught.met_level = caught.level
			caught.met_date = Time.get_date_string_from_system()
			GameState.locke.receive(caught, encounter)
		else:
			var resolved := {&"run": "run", &"lose": "lost", &"win": "fainted"}
			GameState.locke.resolve(encounter, resolved.get(outcome(), "lost"))
	GameState.locke.check_game_over()
