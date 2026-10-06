class_name BattleSetup
extends RefCounted
## Todo lo que define un combate antes de empezar. Contrato: docs/contratos.md §8.5.
## Las fábricas wild() y trainer() toman el equipo y los datos del jugador de GameState.

enum Kind { WILD, TRAINER }
enum Format { SINGLE, DOUBLE }

const DEFAULT_WILD_BGM := &"battle_wild"
const DEFAULT_TRAINER_BGM := &"battle_trainer"

var kind: Kind = Kind.WILD
var format: Format = Format.SINGLE
## En dobles, el segundo Pokémon del jugador lo juega la IA (combate con compañero).
var ally_ai: bool = false
## El jugador tiene la Megapulsera o la Piedra Activadora. Sin esto no megaevoluciona.
var mega_bracelet: bool = false
## Objetos Pokemon del jugador: el motor los modifica (PS, PP, estado, experiencia...).
var player_party: Array[Pokemon] = []
var foe_party: Array[Pokemon] = []
var player_name: String = ""
var player_trainer_id: int = 0
## Entrenadores rivales (vacío en combates salvajes). Ver contratos.md §8.5.
var trainers: Array[Dictionary] = []
var can_lose: bool = false
## Reglas Locke de RandomLocke (Fase R.7): un debilitado del jugador muere (evento pokemon_died)
## y no se puede revivir. Se apaga si la muerte permanente está desactivada o el combate es un tutorial.
var locke_rules: bool = false
## Reglas completas (tope, modo fijo, objetos). null = el combate no las aplica.
var locke: LockeRules = null
## Nivel del as del siguiente líder. 0 = todavía no hay tope que aplicar.
var next_ace_level: int = 0
## "fixed" no avisa al sacar el siguiente rival; "shift" sí (se puede rechazar).
## El modo fijo de Locke gana aunque aquí ponga "shift".
var battle_style: StringName = &"fixed"
## El tutorial no aplica ninguna regla Locke, aunque la partida sea RandomLocke.
var tutorial: bool = false
var can_run: bool = true
var allow_items: bool = true
var exp_enabled: bool = true
var exp_share: bool = true
var background: StringName = &""
var bgm: StringName = DEFAULT_WILD_BGM
var weather: StringName = &""
## grass, cave, water, underwater, fishing...
var environment: StringName = &""
## Clock.period(): morning, day, evening o night.
var time_period: StringName = &""
## Nivel de IA del rival (0 = salvaje).
var ai_level: int = 0
## Especies base ya capturadas (Ball Acopio) y cuántas hay (captura crítica).
var caught_species: Dictionary[StringName, bool] = {}
var dex_caught_count: int = 0
## Semilla del RNG; 0 = aleatoria.
@warning_ignore("shadowed_global_identifier")
var seed: int = 0


## Combate salvaje contra un Pokemon ya creado o contra una especie (`what`) al nivel `level`.
static func wild(what: Variant, level: int = 5, options: Dictionary = {}) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = Kind.WILD
	s.can_run = true
	s.bgm = DEFAULT_WILD_BGM
	var p: Pokemon = what if what is Pokemon else Pokemon.create(StringName(str(what)), level)
	if p != null:
		s.foe_party.append(p)
	s.fill_from_game_state()
	s.apply_options(options)
	return s


## Combate contra el entrenador `trainer_id` de data/trainers (con su clase ya combinada).
static func trainer(trainer_id: StringName, options: Dictionary = {}) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = Kind.TRAINER
	s.can_run = false
	s.fill_from_game_state()
	var info := trainer_info(trainer_id, s.player_name)
	if info.is_empty():
		return s
	s.trainers.append(info)
	s.ai_level = int(info["ai_level"])
	s.bgm = StringName(info["battle_bgm"]) if str(info["battle_bgm"]) != "" else DEFAULT_TRAINER_BGM
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(trainer_id))
	for spec: Dictionary in DataDB.trainer(trainer_id).get("party", []):
		var p := Pokemon.from_spec(spec, rng)
		if p != null:
			p.original_trainer = str(info["name"])
			s.foe_party.append(p)
	if bool(options.get("double", DataDB.trainer(trainer_id).get("double", false))):
		s.format = Format.DOUBLE
	s.apply_options(options)
	return s


## Datos de presentación del entrenador (entrenador + clase). {} si no existe.
static func trainer_info(trainer_id: StringName, player_name_value: String = "") -> Dictionary:
	if not DataDB.has_trainer(trainer_id):
		push_error("BattleSetup: no existe el entrenador '%s'." % trainer_id)
		return {}
	var t := DataDB.trainer(trainer_id)
	var class_id := StringName(t.get("class", ""))
	var cls := DataDB.trainer_class(class_id) if DataDB.has_trainer_class(class_id) else {}
	var gender := str(t.get("gender", cls.get("gender", "male")))
	var female := gender == "female"
	var trainer_name := _fill_names(str(t.get("name", "")), player_name_value)
	var class_name_text := str(cls.get("name", ""))
	return {
		"id": String(trainer_id),
		"class": String(class_id),
		"class_name": class_name_text,
		"name": trainer_name,
		"display_name": (class_name_text + " " + trainer_name).strip_edges() if class_name_text != "" else trainer_name,
		"gender": gender,
		"base_money": int(cls.get("base_money", 0)),
		"ai_level": int(t.get("ai_level", cls.get("ai_level", 1))),
		"battle_sprite": str(cls.get("battle_sprite_female", cls.get("battle_sprite", ""))) if female else str(cls.get("battle_sprite", "")),
		"battle_bgm": str(t.get("battle_bgm", cls.get("battle_bgm", ""))),
		"intro_bgm": str(cls.get("intro_bgm", "")),
		"intro_text": _fill_names(str(t.get("intro_text", "")), player_name_value),
		"lose_text": _fill_names(str(t.get("lose_text", "")), player_name_value),
		"win_text": _fill_names(str(t.get("win_text", "")), player_name_value),
		"items": t.get("items", []),
	}


## Equipo, nombre, id de entrenador, Pokédex y hora del jugador desde GameState y Clock.
func fill_from_game_state() -> void:
	if GameState.party is Party:
		player_party = (GameState.party as Party).members
	player_name = GameState.player_name
	player_trainer_id = GameState.trainer_id
	if GameState.pokedex is Pokedex:
		var dex := GameState.pokedex as Pokedex
		for id: StringName in dex.caught_species():
			caught_species[id] = true
		dex_caught_count = dex.caught_count()
	time_period = Clock.period()
	exp_share = bool(DataDB.rule(&"exp_share", true))
	if GameState.bag is Bag:
		var bag := GameState.bag as Bag
		mega_bracelet = bag.has(&"megabracelet") or bag.has(&"keystone")
	if GameState.is_randomlocke() and GameState.locke != null:
		locke = GameState.locke.rules
		var rules_dict := locke.rules()
		locke_rules = bool(rules_dict.get("locke_rules", true)) and bool(rules_dict.get("permadeath", true))
		if locke.battle_mode() == "fixed":
			battle_style = &"fixed"
		next_ace_level = int(GameState.randomlocke.get("next_ace_level", 0))


## options: can_lose, can_run, allow_items, exp_enabled, exp_share, locke_rules, tutorial,
## background, bgm, weather, environment, time_period, battle_style, seed, ai_level, next_ace_level.
func apply_options(options: Dictionary) -> void:
	for key: String in ["can_lose", "can_run", "allow_items", "exp_enabled", "exp_share", "locke_rules", "tutorial"]:
		if options.has(key):
			set(key, bool(options[key]))
	for key: String in ["background", "bgm", "weather", "environment", "time_period", "battle_style"]:
		if options.has(key):
			set(key, StringName(str(options[key])))
	if options.has("seed"):
		seed = int(options["seed"])
	if options.has("ai_level"):
		ai_level = int(options["ai_level"])
	if bool(options.get("double", false)):
		format = Format.DOUBLE
	if options.has("ally_ai"):
		ally_ai = bool(options["ally_ai"])
	if options.has("mega"):
		mega_bracelet = bool(options["mega"])
	if options.has("next_ace_level"):
		next_ace_level = int(options["next_ace_level"])
	if tutorial:
		locke = null
		locke_rules = false


func is_wild() -> bool:
	return kind == Kind.WILD


static func _fill_names(text: String, player_name_value: String) -> String:
	return text.replace("{rival}", GameState.rival_name).replace("{player}", player_name_value)
