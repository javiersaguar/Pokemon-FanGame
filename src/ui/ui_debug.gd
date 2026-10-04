class_name UiDebug
extends RefCounted
## Comandos de Debug del Agente 3 (contratos.md §9.4). Los registra Dialogue al arrancar.


static func register() -> void:
	Debug.register_command("dialogue", _cmd_dialogue,
		"dialogue <texto>: muestra el texto en el cuadro de diálogo (\\n = salto de línea)")
	Debug.register_command("giveitem", _cmd_giveitem, "giveitem <id> [n]: mete objetos en la mochila")
	Debug.register_command("bag", _cmd_bag, "bag: lo que hay en la mochila")


static func _cmd_dialogue(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: dialogue <texto>"
	Dialogue.say(" ".join(args).replace("\\n", "\n"))
	return ""


static func _cmd_giveitem(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: giveitem <id> [n]"
	if not (GameState.bag is Bag):
		return "No hay mochila (¿estás en una partida?)."
	var id := StringName(args[0])
	if not DataDB.has_item(id):
		return "No existe el objeto '%s'." % id
	var added := (GameState.bag as Bag).add(id, int(args[1]) if args.size() > 1 else 1)
	return "+%d %s (tienes %d)." % [added, DataDB.item(id).name, (GameState.bag as Bag).count(id)]


static func _cmd_bag(_args: PackedStringArray) -> String:
	if not (GameState.bag is Bag) or (GameState.bag as Bag).is_empty():
		return "La mochila está vacía."
	var bag := GameState.bag as Bag
	var lines := PackedStringArray()
	for id: StringName in bag.all_items():
		lines.append("%s ×%d" % [DataDB.item(id).name, bag.count(id)])
	return "\n".join(lines)
