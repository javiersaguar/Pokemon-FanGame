extends SceneTree
## Regenera data/item_placements.json recorriendo todos los mapas.
## Uso: godot --headless --path . -s res://maps/_tools/build_item_placements.gd
## Pásalo al añadir, quitar o cambiar objetos del suelo (lo comprueba un test).

const ITEM_PLACEMENTS := "res://src/overworld/item_placements.gd"


## En _initialize y cargando el script a mano: así los autoloads ya existen cuando
## se compilan las clases de los mapas.
func _initialize() -> void:
	await process_frame
	var placements: GDScript = load(ITEM_PLACEMENTS)
	var data: Dictionary = placements.call(&"scan")
	var output: String = placements.get(&"OUTPUT")
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(placements.call(&"to_json", data))
	file.close()
	print("%s: %d objetos" % [output, data.size()])
	quit()
