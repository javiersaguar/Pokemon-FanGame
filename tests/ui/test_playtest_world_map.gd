extends GutTest
var main: Node
var menu: PlaytestMenu
var gut_layer: CanvasLayer
var gut_visible := true
func before_each() -> void:
 gut_layer = gut.add_children_to.get_node("GutLayer") as CanvasLayer
 gut_visible = gut_layer.visible
 gut_layer.hide()
 GameState.reset()
 SaveManager.test_session_active = false
 main = load("res://src/main/main.tscn").instantiate()
 main.set_script(null)
 add_child(main)
 SceneManager.register_main(main)
 SceneManager._fade.hide()
 menu = Debug._preferred_panel as PlaytestMenu
func after_each() -> void:
 gut_layer.visible = gut_visible
 Debug.close()
 if menu.session.active and menu.session.available(): await menu.session.finish()
 SaveManager.test_session_active = false
 SceneManager._leave_game()
 main.queue_free()
 await wait_physics_frames(2)
 SceneManager.world = null
 SceneManager.ui_layer = null
 SceneManager.battle_layer = null
 SceneManager.transition_layer = null
 SceneManager._fade = null
 MapLoader.clear()
func _click(button: Button) -> void:
 var at := button.get_global_rect().get_center()
 var move := InputEventMouseMotion.new()
 move.position = at
 get_tree().root.push_input(move,true)
 await wait_process_frames(2)
 for down: bool in [true,false]:
  var event := InputEventMouseButton.new()
  event.button_index = MOUSE_BUTTON_LEFT
  event.position = at
  event.pressed = down
  get_tree().root.push_input(event,true)
  await wait_process_frames(2)
func _open() -> PlaytestWorldMap:
 Debug.open()
 menu._open_world_map()
 await wait_process_frames(3)
 return SceneManager.top_menu() as PlaytestWorldMap
func _no_overlap(map: PlaytestWorldMap) -> void:
 for key: String in map.buttons:
  var point: Button = map.buttons[key]
  assert_true(Rect2(Vector2.ZERO,PlaytestWorldMap.BOARD).encloses(point.get_rect()),key+": dentro del plano")
  for other: String in map.buttons:
   if other == key: continue
   assert_false(point.get_rect().intersects(map.buttons[other].get_rect()),key+" / "+other+": puntos separados")
func test_ciudad_con_un_clic_inicia_sesion_y_salas_estan_en_el_mapa() -> void:
 GameState.player_name = "Original"
 var map := await _open()
 assert_not_null(map)
 if map == null: return
 assert_eq(map.zone_buttons.size(),map.entries.size(),"Incluye todos los mapas, también salas de prueba")
 _no_overlap(map)
 assert_false(map.buttons.santander.disabled,"Santander ya está pintado (ya no queda ninguna ciudad sin mapa)")
 assert_false(map.buttons.bilbao.disabled,"Bilbao ya tiene las salas de San Mamés")
 assert_false(map.buttons.vigo.disabled,"Vigo ya está pintado")
 assert_false(map.buttons.valladolid.disabled,"Valladolid ya está pintado")
 assert_false(map.buttons.malaga.disabled,"Málaga ya está pintado")
 assert_false(map.buttons.ruta_16.disabled,"La Ruta 16 ya está pintada")
 map._show_zones("madrid")
 assert_has(map.zone_buttons,"madrid/hospital")
 assert_has(map.zone_buttons,"madrid/moncloa")
 await _click(map.buttons.madrid)
 await wait_process_frames(3)
 await wait_until(func() -> bool: return menu.session.active and not menu.session.working,6.0)
 assert_true(menu.session.active)
 assert_true(SaveManager.test_session_active)
 assert_true(str(GameState.map_id).begins_with("madrid/"))
 assert_false(SceneManager.is_menu_open())
 assert_eq(await menu.session.finish(),OK)
 assert_eq(GameState.player_name,"Original")
func test_clic_en_interior_viaja_sin_confirmacion_y_busca_todas_las_zonas() -> void:
 assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
 var map := await _open()
 if map == null: fail_test("Abre el mapa"); return
 map.search.text = "Málaga hospital"
 map.search.text_changed.emit(map.search.text)
 await wait_process_frames(3)
 assert_eq(map.zone_buttons.keys(),["malaga/hospital"])
 assert_true(map.zone_buttons["malaga/hospital"].get_global_rect().size.y >= 30)
 await _click(map.zone_buttons["malaga/hospital"])
 await wait_process_frames(3)
 await wait_until(func() -> bool: return GameState.map_id == &"malaga/hospital" and not SceneManager.is_busy(),4.0)
 assert_eq(GameState.map_id,&"malaga/hospital")
 assert_false(Debug.is_open)
 assert_false(SceneManager.is_menu_open())
 assert_false(GameState.input_locked)
 assert_true(MapLoader.valid_tile(SceneManager.current_map,SceneManager.player.tile_position()))
func test_cancelar_mando_y_no_viajar_durante_dialogo() -> void:
 var map := await _open()
 if map == null: fail_test("Abre el mapa"); return
 for down: bool in [true,false]:
  var event := InputEventJoypadButton.new()
  event.button_index = JOY_BUTTON_B
  event.pressed = down
  Input.parse_input_event(event)
 await wait_process_frames(3)
 assert_false(menu.session.active)
 assert_false(SceneManager.is_menu_open())
 assert_true(Debug.is_open)
 assert_eq(await menu.session.begin(&"getafe/exterior"),OK)
 Dialogue.say("Espera a terminar el diálogo.")
 await wait_process_frames(2)
 menu._open_world_map()
 await wait_process_frames(2)
 assert_false(SceneManager.top_menu() is PlaytestWorldMap)
 for i: int in 2:
  for down: bool in [true,false]:
   var event := InputEventAction.new()
   event.action = &"accept"
   event.pressed = down
   Input.parse_input_event(event)
  await wait_process_frames(2)
 assert_false(Dialogue.is_open)
func _catalogue() -> Array[Dictionary]:
 if not menu._catalogues.has("maps"): menu._catalogues.maps = PlaytestSession.maps()
 return menu._catalogues.maps
func _board() -> PlaytestWorldMap:
 var map := PlaytestWorldMap.new()
 map.entries.assign(_catalogue())
 add_child_autofree(map)
 await wait_process_frames(2)
 return map
func test_cada_lugar_de_la_region_tiene_punto_y_cada_mapa_un_punto_que_lo_lleva() -> void:
 var map := await _board()
 var region := JsonFile.read_dict("res://data/region.json")
 for section: String in ["locations","districts","routes"]:
  for id: String in region[section]:
   var place: Dictionary = region[section][id]
   if not place.has("map") and place.get("maps",[]).is_empty(): continue
   assert_has(map.places,id,"%s tiene punto" % id)
   var exists := false
   for mid: Variant in place.get("maps",[]) + [place.get("map","")]:
    exists = exists or (str(mid) != "" and SceneManager.map_exists(StringName(str(mid))))
   assert_eq(map._enabled(id),exists,"%s: activo solo si su mapa existe" % id)
 assert_false(map._enabled("calle_victoria"),"La Calle de la Victoria sigue pendiente")
 assert_false(map.groups.has("otros"),"Ningún mapa se queda sin punto")
 var covered := {}
 for key: String in map.groups:
  if map.places.has(key):
   for entry: Dictionary in map.groups[key]: covered[entry.id] = true
 for entry: Dictionary in map.entries:
  assert_true(covered.has(entry.id),"%s sale en algún punto del mapa" % entry.id)
 for id: String in ["pozuelo/exterior","orcasitas/exterior","casa_de_campo/exterior","madrid_rio/exterior","rocafonda/exterior",
   "madrid/bernabeu","madrid/quiron","madrid/atico_ayuso","madrid/laboratorio","madrid/gimnasio_lider","bilbao/gimnasio_2",
   "transporte/ferry_barcelona_palma","transporte/avion_gran_canaria_vigo","transporte/ave_madrid_malaga",
   "playa_del_ingles/aeropuerto","vigo/aeropuerto","madrid/sala_retiro_20_58","maritima_1/exterior","test/test_room"]:
  assert_true(covered.has(id),"%s está en el mapa F9" % id)
 assert_has(map.groups.moncloa.map(func(e: Dictionary) -> String: return e.id),"madrid/quiron","El Quirón cuelga de Moncloa")
 assert_has(map.groups.chamberi.map(func(e: Dictionary) -> String: return e.id),"madrid/chamberi/mercadona","Las salas cuelgan de su barrio")
 assert_has(map.groups.centro.map(func(e: Dictionary) -> String: return e.id),"madrid/gimnasio_3","Las salas del gimnasio 1 cuelgan de Sol")
 assert_eq(map._primary("pozuelo"),"pozuelo/exterior")
 assert_eq(map._primary("ferry_baleares"),"transporte/ferry_barcelona_palma")
 _no_overlap(map)
func test_vista_de_madrid_con_pueblos_iniciales_y_barrios_sin_solapes() -> void:
 GameState.player_name = "Original"
 var map := await _open()
 if map == null: fail_test("Abre el mapa"); return
 assert_has(map.buttons,"madrid_zoom")
 assert_false(map.buttons.has("pozuelo"),"Pozuelo va en el recuadro de Madrid")
 await _click(map.view_button)
 await wait_process_frames(2)
 assert_eq(map.view,"madrid")
 for id: String in ["pozuelo","orcasitas","casa_de_campo","madrid_rio","moncloa","chamberi","bernabeu","palacio_real","centro","retiro","getafe","leganes","mostoles"]:
  assert_has(map.buttons,id,"%s en la vista de Madrid" % id)
  if map.buttons.has(id): assert_false(map.buttons[id].disabled,id)
 _no_overlap(map)
 await _click(map.buttons.orcasitas)
 await wait_process_frames(3)
 await wait_until(func() -> bool: return menu.session.active and not menu.session.working,6.0)
 assert_eq(GameState.map_id,&"orcasitas/exterior")
 assert_eq(await menu.session.finish(),OK)
 assert_eq(GameState.player_name,"Original")
func test_busqueda_sin_tildes_y_filtro_por_tipo() -> void:
 var map := await _board()
 for query: Array in [["atico ayuso","madrid/atico_ayuso"],["quiron","madrid/quiron"],["bernabeu","madrid/bernabeu"],
   ["ORCASITAS","orcasitas/exterior"],["pozuelo de alarcon","pozuelo/exterior"],["ferry palma","transporte/ferry_barcelona_palma"],
   ["estacion atocha","madrid/sala_retiro_20_58"],["canal de ibiza","maritima_1/exterior"],["leganes","leganes/exterior"]]:
  map.search.text = query[0]
  map.search.text_changed.emit(map.search.text)
  assert_has(map.zone_buttons,query[1],"«%s» encuentra %s" % query)
 map.search.text = ""
 map.search.text_changed.emit("")
 for index: int in PlaytestWorldMap.CATEGORIES.size():
  map.filter.select(index)
  map.filter.item_selected.emit(index)
  var kind := str(PlaytestWorldMap.CATEGORIES[index][0])
  var expected := map.entries.filter(func(e: Dictionary) -> bool: return kind == "" or e.category == kind).size()
  assert_eq(map.zone_buttons.size(),expected,"Filtro %s" % PlaytestWorldMap.CATEGORIES[index][1])
 map.filter.select(3)
 map.filter.item_selected.emit(3)
 assert_eq(map.zone_buttons.size(),34,"32 salas de gimnasio, el Quirón y el ático")
 for id: String in map.zone_buttons: assert_true(id.contains("gimnasio") or id in ["madrid/quiron","madrid/atico_ayuso"],id)
