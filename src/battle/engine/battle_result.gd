class_name BattleResult
extends RefCounted
## Resultado del combate (engine.result). Contrato: docs/contratos.md §8.5.

const WIN := &"win"
const LOSE := &"lose"
const RUN := &"run"
const CAUGHT := &"caught"

## win, lose, run o caught (los mismos valores que SceneManager.OUTCOME_*). Vacío mientras dura.
var outcome: StringName = &""
var turns: int = 0
@warning_ignore("shadowed_global_identifier")
var seed: int = 0
var money_won: int = 0
var caught_pokemon: Pokemon = null
var seen_species: Array[StringName] = []
var items_used: Array[StringName] = []
## Reglas Locke: {party_index, uid, species, name, level, foe_species, foe_name, trainer, turn} de cada muerto.
var deaths: Array[Dictionary] = []
## {party_index, uid, to}: evoluciones que la escena de evolución tiene que reproducir.
var pending_evolutions: Array[Dictionary] = []


## Suma el dinero, apunta la Pokédex y guarda al capturado (equipo o PC). Lo llama la BattleScene
## al terminar (el motor nunca toca GameState). `location` = id del mapa (dato de captura).
## Devuelve {caught_to: "party" | "pc" | "", box, slot}.
func apply_to_game_state(location: StringName = &"") -> Dictionary:
	var info := {"caught_to": "", "box": -1, "slot": -1}
	if money_won > 0:
		GameState.add_money(money_won)
	var dex := GameState.pokedex as Pokedex
	if dex != null:
		for id: StringName in seen_species:
			dex.mark_seen(id)
	if caught_pokemon == null:
		return info
	var p := caught_pokemon
	p.original_trainer = GameState.player_name
	p.trainer_id = GameState.trainer_id
	p.met_level = p.level
	p.met_location = location if location != &"" else GameState.map_id
	p.met_date = Time.get_date_string_from_system()
	if dex != null:
		dex.register(p)
	var party := GameState.party as Party
	if party != null and party.add(p):
		info["caught_to"] = "party"
		return info
	var pc := GameState.pc as PCStorage
	if pc != null:
		var where := pc.deposit(p)
		if where != PCStorage.NO_SLOT:
			info = {"caught_to": "pc", "box": where.x, "slot": where.y}
	return info
