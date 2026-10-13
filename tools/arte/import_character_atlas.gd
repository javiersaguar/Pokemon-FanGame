extends SceneTree
## Copia el PNG sin alterar píxeles y registra regiones de sus cinco filas transparentes.
const OUT := "res://assets/sprites/characters/famosos_atlas/"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("Uso: -- id nombre archivo.png")
		quit(1)
		return
	var image := Image.load_from_file(args[2])
	if image == null:
		quit(1)
		return
	var rows := bands(image, Rect2i(Vector2i.ZERO,image.get_size()), false)
	if rows.size() != 5:
		push_error("El atlas debe contener una fila de combate y cuatro filas de mapa: %s" % str(rows))
		quit(1)
		return
	var front := bounds(image, Rect2i(0,rows[0].x,image.get_width(),rows[0].y-rows[0].x))
	var frames: Array[Rect2i] = []
	for i: int in range(1,5):
		var row := Rect2i(0,rows[i].x,image.get_width(),rows[i].y-rows[i].x)
		var columns := bands(image,row,true)
		if columns.size() != 4:
			push_error("La fila %d debe tener cuatro poses: %s" % [i,str(columns)])
			quit(1)
			return
		for column: Vector2i in columns:
			var rect := bounds(image,Rect2i(column.x,row.position.y,column.y-column.x,row.size.y))
			frames.append(rect)
	var walk: Array = []
	for rect: Rect2i in frames:
		walk.append([rect.position.x,rect.position.y,rect.size.x,rect.size.y])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var path := OUT+args[0]+".png"
	var destination := ProjectSettings.globalize_path(path)
	var error := OK if args[2].simplify_path() == destination.simplify_path() else DirAccess.copy_absolute(args[2],destination)
	if error != OK:
		quit(1)
		return
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/character_art.json"))
	config.characters[args[0]] = {"name":args[1],"atlas":path,"battle_rect":[front.position.x,front.position.y,front.size.x,front.size.y],"walk_frames":walk}
	var file := FileAccess.open("res://data/character_art.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(config,"  ")+"\n")
	print("Atlas registrado: ",args[0]," / ",image.get_size()," / 16 poses")
	quit()

func bands(image: Image, rect: Rect2i, horizontal: bool) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	var start := -1
	var first := rect.position.x if horizontal else rect.position.y
	var last := rect.end.x if horizontal else rect.end.y
	for i: int in range(first,last):
		var occupied := false
		for j: int in range(rect.position.y if horizontal else rect.position.x,rect.end.y if horizontal else rect.end.x):
			if image.get_pixel(i if horizontal else j,j if horizontal else i).a8 > 128:
				occupied = true
				break
		if occupied and start < 0: start = i
		if not occupied and start >= 0:
			found.append(Vector2i(start,i))
			start = -1
	if start >= 0: found.append(Vector2i(start,last))
	return found

func bounds(image: Image, rect: Rect2i) -> Rect2i:
	var left := rect.end.x
	var top := rect.end.y
	var right := rect.position.x
	var bottom := rect.position.y
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if image.get_pixel(x,y).a8 > 128:
				left = mini(left,x)
				top = mini(top,y)
				right = maxi(right,x+1)
				bottom = maxi(bottom,y+1)
	return Rect2i(left,top,right-left,bottom-top)
