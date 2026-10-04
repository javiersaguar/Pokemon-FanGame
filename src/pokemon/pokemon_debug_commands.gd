class_name PokemonDebugCommands
extends RefCounted
## Comandos del menú Debug (F9) del Agente 2. Los registra DataDB al arrancar (solo en debug).


func register() -> void:
	Debug.register_command("givepkmn", givepkmn, "givepkmn <especie> [nivel] [shiny] · al equipo o al PC")
	Debug.register_command("forceshiny", forceshiny, "forceshiny [on|off] · todos los Pokémon nuevos salen shiny")
	Debug.register_command("heal", heal, "Cura al equipo (PS, estado y PP).", "Curar equipo")
	Debug.register_command("party", party, "Lista el equipo.")
	Debug.register_command("setlevel", setlevel, "setlevel <posición 1-6> <nivel>")
	Debug.register_command("wildbattle", wildbattle, "wildbattle <especie> [nivel] · combate salvaje")
	Debug.register_command("trainerbattle", trainerbattle, "trainerbattle <id> · combate contra un entrenador")
	Debug.register_command("dex", dex, "dex [all] · vistos y capturados (all = marca toda la regional)")


func givepkmn(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: givepkmn <especie> [nivel] [shiny]"
	var id := StringName(args[0].to_lower())
	if not DataDB.has_species(id):
		return "No existe la especie '%s'." % id
	var p := Pokemon.create(id, int(args[1]) if args.size() > 1 else 5)
	if args.size() > 2 and args[2] == "shiny":
		p.shiny = true
	p.original_trainer = GameState.player_name
	p.trainer_id = GameState.trainer_id
	p.met_location = GameState.map_id
	p.met_date = Time.get_date_string_from_system()
	if GameState.pokedex is Pokedex:
		(GameState.pokedex as Pokedex).register(p)
	var party_module := GameState.party as Party
	if party_module != null and party_module.add(p):
		return "%s (Nv. %d) al equipo." % [p.display_name(), p.level]
	var pc := GameState.pc as PCStorage
	if pc != null:
		var where := pc.deposit(p)
		if where != PCStorage.NO_SLOT:
			return "%s (Nv. %d) al PC: caja %d, hueco %d." % [p.display_name(), p.level, where.x + 1, where.y + 1]
	return "No hay sitio para %s." % p.display_name()


func forceshiny(args: PackedStringArray) -> String:
	Pokemon.debug_force_shiny = args.is_empty() or args[0].to_lower() in ["on", "1", "si", "sí", "true"]
	return "Shiny forzado: %s." % ("sí" if Pokemon.debug_force_shiny else "no")


func heal(_args: PackedStringArray) -> String:
	var party_module := GameState.party as Party
	if party_module == null:
		return "No hay equipo."
	party_module.heal_all()
	return "Equipo curado."


func party(_args: PackedStringArray) -> String:
	var party_module := GameState.party as Party
	if party_module == null or party_module.is_empty():
		return "El equipo está vacío."
	var lines: PackedStringArray = []
	for i: int in party_module.size():
		var p := party_module.members[i]
		lines.append("%d. %s Nv.%d PS %d/%d %s [%s]" % [i + 1, p.display_name(), p.level, p.current_hp,
			p.max_hp(), p.status, ", ".join(PackedStringArray(p.move_ids().map(func(m: StringName) -> String: return String(m))))])
	return "\n".join(lines)


func setlevel(args: PackedStringArray) -> String:
	var party_module := GameState.party as Party
	if args.size() < 2 or party_module == null:
		return "Uso: setlevel <posición 1-6> <nivel>"
	var p := party_module.get_at(int(args[0]) - 1)
	if p == null:
		return "No hay Pokémon en esa posición."
	for up: Dictionary in p.set_level(int(args[1])):
		for move_id: StringName in up["new_moves"]:
			p.try_learn(move_id)
	return "%s ahora es de nivel %d." % [p.display_name(), p.level]


func wildbattle(args: PackedStringArray) -> String:
	if args.is_empty() or not DataDB.has_species(StringName(args[0].to_lower())):
		return "Uso: wildbattle <especie> [nivel]"
	var setup := BattleSetup.wild(StringName(args[0].to_lower()), int(args[1]) if args.size() > 1 else 5, {"can_lose": true})
	if setup.player_party.is_empty():
		return "Primero da un Pokémon al jugador (givepkmn)."
	Debug.close()
	SceneManager.start_battle(setup)
	return "Combate salvaje."


func trainerbattle(args: PackedStringArray) -> String:
	if args.is_empty() or not DataDB.has_trainer(StringName(args[0])):
		return "Uso: trainerbattle <id> (ids: %s)" % ", ".join(PackedStringArray(DataDB.trainer_ids().map(func(t: StringName) -> String: return String(t))))
	var setup := BattleSetup.trainer(StringName(args[0]), {"can_lose": true})
	if setup.player_party.is_empty():
		return "Primero da un Pokémon al jugador (givepkmn)."
	Debug.close()
	SceneManager.start_battle(setup)
	return "Combate contra %s." % setup.trainers[0].get("display_name", args[0])


func dex(args: PackedStringArray) -> String:
	var d := GameState.pokedex as Pokedex
	if d == null:
		return "No hay Pokédex."
	if not args.is_empty() and args[0] == "all":
		for id: StringName in DataDB.regional_dex():
			d.mark_caught(id)
	return "Vistos: %d · Capturados: %d" % [d.seen_count(), d.caught_count()]
