extends SceneTree
## Pone un cartel (src/overworld/sign/sign.tscn) en Entities de un mapa ya pintado, sin repintarlo. Si ya hay
## un nodo con ese nombre, no hace nada. Las líneas van separadas por «|».
## Uso: godot --headless --path . -s res://maps/_tools/poner_cartel.gd -- <mapa> <nombre> <x> <y> "<línea 1>|<línea 2>"

const SIGN_SCENE := "res://src/overworld/sign/sign.tscn"


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 5:
		push_error("poner_cartel: faltan argumentos (mapa, nombre, x, y, líneas).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	var entities := map.get_node(^"Entities")
	if entities.has_node(NodePath(a[1])):
		print("%s: ya tenía el cartel %s." % [a[0], a[1]])
		map.free()
		quit()
		return
	var node: Node2D = (load(SIGN_SCENE) as PackedScene).instantiate()
	node.name = a[1]
	node.position = Grid.to_world(Vector2i(int(a[2]), int(a[3])))
	node.set(&"lines", PackedStringArray(String(a[4]).split("|")))
	entities.add_child(node)
	node.owner = map
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: cartel %s en (%s, %s) (%s)." % [a[0], a[1], a[2], a[3], error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
