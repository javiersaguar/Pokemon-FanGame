extends StoryEvent
## Elegir el inicial en una de las Poké Balls del laboratorio (Fase 8.3).
## Regla R.2: la especie no se escribe aquí; sale de DataDB.starter(slot), que en
## RandomLocke devuelve la aleatorizada.
## params: slot (StringName, "starter_1".."starter_3") e index (int 1–3, el que
## se guarda en la var `starter` y decide el equipo del rival).
## Al elegir: el Pokémon va al equipo, flag `starter_chosen` y var `starter`.
## Nivel: el de DataDB.starter() o, si no lo trae, data/world.json →
## new_game.starter_level.


func run() -> void:
	var slot := StringName(param("slot", "starter_1"))
	var starter := resolve(slot)
	if starter.is_empty():
		push_warning("choose_starter_event: DataDB no da el inicial '%s' (data/starters.json)." % slot)
		return
	var species: StringName = starter["species"]
	var vars := {"pokemon": DataDB.species(species).name}
	if not await Dialogue.ask_yes_no("¿Eliges a {pokemon}?", null, vars):
		return
	var pokemon := Pokemon.create(species, int(starter["level"]))
	await Cutscene.give_pokemon(pokemon)
	GameState.set_var(&"starter", int(param("index", 1)))
	GameState.set_flag(&"starter_chosen")


## {species, level} del inicial `slot` según DataDB ({} si no lo sabe). Acepta que
## DataDB.starter() devuelva el id de la especie o un diccionario {species, level}.
static func resolve(slot: StringName) -> Dictionary:
	if not DataDB.has_method(&"starter"):
		return {}
	var data: Variant = DataDB.call(&"starter", slot)
	var species := &""
	var level := int(GameState.world_config.get("new_game", {}).get("starter_level", 5))
	if data is Dictionary:
		species = StringName(data.get("species", ""))
		level = int(data.get("level", level))
	elif data is String or data is StringName:
		species = StringName(data)
	if species == &"" or not DataDB.has_species(species):
		return {}
	return {"species": species, "level": level}
