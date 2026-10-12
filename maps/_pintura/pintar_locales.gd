extends SceneTree
## Interiores de servicios, con muebles originales del set público de Akizakura16.
const TILESET := "res://assets/tilesets/interior/interior.tres"
const SIZE := Vector2i(16,12)
var city := "malaga"
var city_name := "Málaga"
var exterior := "malaga/exterior"
var locations: Dictionary = {}
func _initialize() -> void:
 await process_frame
 var args := OS.get_cmdline_user_args()
 if "--all" in args:
  var cities := JsonFile.read_dict("res://maps/_pintura/locales.json")
  for id: String in cities:
   if Array(args).filter(func(arg: String) -> bool: return not arg.begins_with("--")).size() > 0 and id not in args: continue
   city = id
   city_name = cities[id].name
   locations = cities[id]
   for kind: String in ["hospital","centro","mercadona","estanco"]:
    if locations.has(kind) and ("--kind=mercadona" not in args or kind == "mercadona"): _paint(kind)
  quit()
  return
 if args.size() >= 3:
  city = args[0]
  city_name = args[1]
  exterior = args[2]
 for kind: String in ["hospital","mercadona","estanco"]:
  _paint(kind)
 quit()
func _paint(kind: String) -> void:
 var medical := kind in ["hospital","centro"]
 var d := MapData.new()
 d.id = StringName(city+"/"+kind)
 d.display_name = ("Hospital" if kind == "hospital" else ("Centro Pokémon" if kind == "centro" else kind.capitalize()))+" · "+city_name
 d.zone_id = StringName(locations.get("zone",city))
 d.outdoor = false
 d.fixed_camera = true
 d.can_bike = false
 d.can_run = false
 d.can_fly_from = false
 d.followers_allowed = false
 d.battle_background = &"indoor"
 var p := Pintor.new(kind.capitalize(),SIZE,d)
 var tiles: TileSet = load(TILESET)
 for layer: TileMapLayer in [p.ground,p.decor,p.objects,p.above]:
  layer.tile_set = tiles
 var floor_tile := Vector2i(1,21) if medical else (Vector2i(1,49) if kind == "mercadona" else Vector2i(1,25))
 for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO,SIZE)):
  p.ground.set_cell(at,0,floor_tile)
 # Moldura de pared y zócalo; límite físico completo, salvo la salida.
 var wall_row := 4 if medical else (9 if kind == "mercadona" else 24)
 for x: int in SIZE.x:
  p.decor.set_cell(Vector2i(x,0),1,Vector2i(1,wall_row-1))
  p.decor.set_cell(Vector2i(x,1),1,Vector2i(1,wall_row))
  if x != 8: p.decor.set_cell(Vector2i(x,11),1,Vector2i(1,wall_row))
 for y: int in range(2,11):
  p.decor.set_cell(Vector2i(0,y),1,Vector2i(1,wall_row),TileSetAtlasSource.TRANSFORM_TRANSPOSE)
  p.decor.set_cell(Vector2i(15,y),1,Vector2i(1,wall_row),TileSetAtlasSource.TRANSFORM_TRANSPOSE)
 p.spawn("default",Vector2i(8,10))
 p.warp("Salida",Vector2i(8,11),StringName(locations[kind][0] if locations.has(kind) else exterior),StringName("from_"+kind))
 p.root.get_node("Warps/Salida").arrival_facing = Warp.Facing.DOWN
 _heading(p,d.display_name)
 if medical:
  _hospital(p,kind)
 else:
  _shop(p,kind)
 if city == "getafe" and kind == "mercadona": _detail_getafe(p)
 var result := p.save("res://maps/"+String(d.id)+".tscn")
 print(d.id,": ",error_string(result))
func _fragment(p: Pintor, at: Vector2i, source: int, rect: Rect2i) -> void:
 for y: int in rect.size.y:
  for x: int in rect.size.x:
   p.decor.set_cell(at+Vector2i(x,y),source,rect.position+Vector2i(x,y))
func _desk(p: Pintor, at: Vector2i) -> void:
 # Frontal de un mostrador gris, tres piezas del atlas sin transformaciones.
 for x: int in 3:
  p.decor.set_cell(at+Vector2i(x,0),3,Vector2i(4+x,6))
func _hospital(p: Pintor,kind: String) -> void:
 var place := ("Hospital de " if kind == "hospital" else "Centro Pokémon de ")+city_name
 _desk(p,Vector2i(7,4))
 p.npc("Enfermera","nurse",Vector2i(8,3),0,[],{"display_name":"Enfermería","event":load("res://src/events/common/heal_party_event.gd"),"event_params":{"place":place,"spawn":"recovery"}})
 p.spawn("recovery",Vector2i(8,5))
 # Camas de observación separadas por un corredor libre.
 for at: Vector2i in [Vector2i(2,3),Vector2i(12,3)]:
  _fragment(p,at,2,Rect2i(0,40,2,2))
 _fragment(p,Vector2i(2,8),2,Rect2i(3,59,3,2))
 # Terminal (sprite del pack) y entidad examinable desde abajo.
 _fragment(p,Vector2i(11,7),3,Rect2i(0,31,2,3))
 var terminal: Node2D = load("res://src/overworld/sign/sign.tscn").instantiate()
 terminal.set_script(load("res://src/overworld/hospital_terminal.gd"))
 terminal.name = "PC"
 terminal.position = Grid.to_world(Vector2i(12,9))
 p.entities.add_child(terminal)
 p.npc("Paciente","npc_woman",Vector2i(5,8),0,["Aquí puedes curar a tus Pokémon y organizar las cajas desde el PC."])
func _shop(p: Pintor,kind: String) -> void:
 var stock := Rect2i(5,3,2,3) if kind == "mercadona" else Rect2i(5,6,2,3)
 # Dos pasillos amplios: se llega a la caja sin atravesar muebles.
 for at: Vector2i in [Vector2i(2,3),Vector2i(12,3),Vector2i(2,7),Vector2i(12,7)]:
  _fragment(p,at,2,stock)
 _desk(p,Vector2i(7,4))
 p.npc("Dependiente","npc_youngster",Vector2i(8,3),0,[],{"display_name":kind.capitalize(),"event":load("res://src/events/common/open_shop_event.gd"),"event_params":{"shop_id":kind+"_"+city.replace("/","_")}})
 p.npc("Cliente","npc_woman",Vector2i(5,7),0,["Poké Balls, curas y repelentes: pregunta en la caja." if kind == "mercadona" else "Aquí venden objetos para preparar el combate."])
func _heading(p: Pintor,title: String) -> void:
 var label := Label.new()
 label.name = "Rotulo"
 label.position = Vector2(40,float(locations.get("heading_y",18 if locations.has("centro") else 8)))
 label.size = Vector2(432,24) if label.position.y == 18 else Vector2(432,32)
 label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 label.text = title.to_upper().replace(" · "," / ")
 label.add_theme_font_override("font",load("res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"))
 label.add_theme_font_size_override("font_size",16)
 label.add_theme_color_override("font_color",Color("303048"))
 label.add_theme_color_override("font_shadow_color",Color("fff4d8"))
 label.add_theme_constant_override("shadow_offset_x",1)
 label.add_theme_constant_override("shadow_offset_y",1)
 p.root.add_child(label)

func _detail_getafe(p: Pintor) -> void:
 _fragment(p,Vector2i(2,3),2,Rect2i(5,27,2,3))
 _fragment(p,Vector2i(12,3),2,Rect2i(1,9,2,3))
 _fragment(p,Vector2i(1,9),2,Rect2i(4,38,1,1))
 var display: Node2D = load("res://src/overworld/sign/sign.tscn").instantiate()
 display.set_script(load("res://src/overworld/service_display.gd"))
 display.name = "Expositor"
 display.position = Grid.to_world(Vector2i(3,5))
 display.set("shop_id",&"mercadona_getafe")
 p.entities.add_child(display)
 p.sign_text("AvisoCaja",Vector2i(11,1),PackedStringArray(["HACENDADO · MERCADONA","Examina las estanterías para consultar objetos y precios. Compra en la caja."]))
 var notice: Node = p.entities.get_node("AvisoCaja")
 notice.set("show_sprite",false)
 var atlas := AtlasTexture.new()
 atlas.atlas = load("res://assets/tilesets/exterior/gen4.png")
 atlas.region = Rect2(Vector2(ExteriorTiles.SIGN*Grid.TILE),Vector2(32,32))
 var poster := Sprite2D.new()
 poster.name = "AvisoVisible"
 poster.position = Grid.to_world(Vector2i(11,1))
 poster.texture = atlas
 poster.z_index = 1
 p.root.add_child(poster)
 var customer: Node = p.entities.get_node("Cliente")
 customer.set("display_name","Reponedora")
 customer.set("lines",PackedStringArray())
 customer.set("event",load("res://src/events/common/npc_reward_event.gd"))
 customer.set("event_params",{"reward_id":"getafe_mercadona_cortesia"})
 p.npc("Compradora","npc_lass",Vector2i(10,8),1,["Puedes leer qué hace cada objeto antes de comprarlo. El precio es el mismo que en la caja."])
