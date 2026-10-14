extends SceneTree
## Registra los dos PNG de Messi aportados por Javier sin alterar sus píxeles.
const SOURCE := "/mnt/c/Users/Javier/Downloads/IBERIA V2.10/Pokemon Iberia V2.10/Graphics/Characters/"
const DESTINATION := "res://assets/sprites/characters/iberia/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DESTINATION))
	for pair: Array in [["trainer119.png","messi_combate.png"],["messiow.png","messi_mapa.png"]]:
		assert(DirAccess.copy_absolute(SOURCE + pair[0], ProjectSettings.globalize_path(DESTINATION + pair[1])) == OK)
	var battle := Image.load_from_file(SOURCE + "trainer119.png")
	var map := Image.load_from_file(SOURCE + "messiow.png")
	var portrait := _bounds(battle, Rect2i(Vector2i.ZERO,battle.get_size()))
	var frames := []
	for row: int in 4:
		var rect := _bounds(map,Rect2i(0,row * 64,64,64))
		for column: int in 4:
			frames.append([rect.position.x,rect.position.y,rect.size.x,rect.size.y])
	var data := JsonFile.read_dict(CharacterArt.CONFIG)
	data.characters["messi"] = {"name":"Messi","atlas":DESTINATION+"messi_mapa.png",
		"battle_atlas":DESTINATION+"messi_combate.png",
		"battle_rect":[portrait.position.x,portrait.position.y,portrait.size.x,portrait.size.y],
		"walk_frames":frames,"frame_mode":"static","source":"Pokémon Iberia V2.10"}
	var file := FileAccess.open(CharacterArt.CONFIG,FileAccess.WRITE)
	file.store_string(JSON.stringify(data,"  ") + "\n")
	file.close()
	print("Messi: dos PNG intactos, cuatro direcciones quietas; recurso provisional.")
	quit()

func _bounds(image: Image, area: Rect2i) -> Rect2i:
	var left := area.end.x
	var right := area.position.x
	var top := area.end.y
	var bottom := area.position.y
	for y: int in range(area.position.y,area.end.y):
		for x: int in range(area.position.x,area.end.x):
			if image.get_pixel(x,y).a8 > 128:
				left = mini(left,x)
				right = maxi(right,x+1)
				top = mini(top,y)
				bottom = maxi(bottom,y+1)
	return Rect2i(left,top,right-left,bottom-top)

