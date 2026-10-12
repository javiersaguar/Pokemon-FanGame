extends RefCounted
## Conecta locales ya colocados. Solo se llama después de reservar los mapas.
static func apply(p: RefCounted,city: String,map_id: String,entries: Dictionary) -> void:
 for kind: String in ["hospital","centro","mercadona","estanco"]:
  if not entries.has(kind): continue
  var row: Array = entries[kind]
  if row[0] != map_id: continue
  var anchor := Vector2i(int(row[1]),int(row[2]))
  var object_id := &"oficinas_azules" if kind == "hospital" else (&"centro_pokemon" if kind == "centro" else (&"tienda_verde" if kind == "mercadona" else &"tienda_morada"))
  if kind == "hospital": p.object(object_id,anchor)
  var door: Vector2i = anchor+ExteriorTiles.objects()[object_id].door
  p.spawn("from_"+kind,door+Vector2i.DOWN)
  p.warp(kind.capitalize(),door,StringName(city+"/"+kind),&"default")
  p.root.get_node("Warps/"+kind.capitalize()).arrival_facing = Warp.Facing.UP
  if kind == "hospital":
   var title := Label.new()
   title.name = "RotuloHospital"
   title.text = "HOSPITAL"
   title.position = Grid.to_world(anchor)+Vector2(16,-80)
   title.add_theme_font_override("font",load("res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"))
   title.add_theme_font_size_override("font_size",16)
   title.add_theme_color_override("font_color",Color("fff4d8"))
   title.add_theme_color_override("font_shadow_color",Color("303048"))
   title.add_theme_constant_override("shadow_offset_x",1)
   title.add_theme_constant_override("shadow_offset_y",1)
   p.root.add_child(title)
 for node: Node in p.entities.get_children():
  if node.get_script() != null and node.get_script().resource_path == "res://src/overworld/sign/sign.gd":
   var lines: PackedStringArray = node.get("lines")
   if entries.has("hospital"):
    for index: int in lines.size():
     lines[index] = lines[index].replace("Centro Pokémon","Hospital").replace("CENTRO POKÉMON","HOSPITAL")
   var service := String(node.name).trim_prefix("Cartel").to_lower()
   if entries.has(service):
    for index: int in lines.size():
     if "Interior pendiente." in lines[index]:
      lines[index] = "Curación y PC. Entra por la puerta." if service == "centro" else "Tienda abierta. Entra por la puerta."
   node.set("lines",lines)

static func apply_all(p: RefCounted,map_id: String) -> void:
 var locations := JsonFile.read_dict("res://maps/_pintura/locales.json")
 for id: String in locations:
  var entries: Dictionary = locations[id]
  for kind: String in ["hospital","centro","mercadona","estanco"]:
   if entries.has(kind) and entries[kind][0] == map_id:
    apply(p,id,map_id,entries)
    break
