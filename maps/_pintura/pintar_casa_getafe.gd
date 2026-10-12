extends SceneTree
## Primera vivienda visitable del repaso: recursos originales, sin trama nueva.
func _initialize() -> void:
 await process_frame
 var d := MapData.new()
 d.id = &"getafe/casa_vecina"
 d.display_name = "Casa de la vecina / Getafe"
 d.zone_id = &"getafe"
 d.outdoor = false
 d.fixed_camera = true
 d.can_run = false
 d.can_bike = false
 d.can_fly_from = false
 d.followers_allowed = false
 d.battle_background = &"indoor"
 var p := Pintor.new("CasaVecina",Vector2i(16,12),d)
 var tiles: TileSet = load("res://assets/tilesets/interior/interior.tres")
 for layer: TileMapLayer in [p.ground,p.decor,p.objects,p.above]: layer.tile_set = tiles
 for at: Vector2i in Pintor.cells(Rect2i(0,0,16,12)): p.ground.set_cell(at,0,Vector2i(1,25))
 for x: int in 16:
  p.decor.set_cell(Vector2i(x,0),1,Vector2i(1,23))
  p.decor.set_cell(Vector2i(x,1),1,Vector2i(1,24))
  if x != 8: p.decor.set_cell(Vector2i(x,11),1,Vector2i(1,24))
 for y: int in range(2,11):
  for x: int in [0,15]: p.decor.set_cell(Vector2i(x,y),1,Vector2i(1,24),TileSetAtlasSource.TRANSFORM_TRANSPOSE)
 _piece(p,Vector2i(1,2),2,Rect2i(0,33,6,3))
 _piece(p,Vector2i(11,2),2,Rect2i(1,0,2,3))
 _piece(p,Vector2i(2,7),2,Rect2i(0,40,2,2))
 _piece(p,Vector2i(10,8),2,Rect2i(3,59,3,2))
 _piece(p,Vector2i(7,2),3,Rect2i(0,31,2,3))
 p.spawn("default",Vector2i(8,10))
 p.warp("Salida",Vector2i(8,11),&"getafe/exterior",&"from_casa_vecina")
 p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
 p.npc("Vecina","npc_old_woman",Vector2i(7,6),0,["Bienvenido. El ordenador permite ordenar las cajas de Pokémon.","Leganés queda al oeste; para Puertollano, sigue la Ruta 24 hacia el sur."])
 p.sign_text("Libros",Vector2i(12,4),["Guía del entrenador: las habilidades dependen de la especie. En el PC puedes organizar el equipo y las cajas."])
 var pc: Node2D = load("res://src/overworld/sign/sign.tscn").instantiate()
 pc.set_script(load("res://src/overworld/hospital_terminal.gd"))
 pc.name = "PC"
 pc.position = Grid.to_world(Vector2i(8,4))
 p.entities.add_child(pc)
 var title := Label.new()
 title.name = "Rotulo"
 title.position = Vector2(40,18)
 title.size = Vector2(432,24)
 title.text = "CASA / GETAFE"
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_override("font",load("res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"))
 title.add_theme_font_size_override("font_size",16)
 title.add_theme_color_override("font_color",Color("303048"))
 p.root.add_child(title)
 print("Casa de Getafe: ",error_string(p.save("res://maps/getafe/casa_vecina.tscn")))
 quit()
func _piece(p: Pintor,at: Vector2i,source: int,rect: Rect2i) -> void:
 for y: int in rect.size.y:
  for x: int in rect.size.x: p.decor.set_cell(at+Vector2i(x,y),source,rect.position+Vector2i(x,y))
