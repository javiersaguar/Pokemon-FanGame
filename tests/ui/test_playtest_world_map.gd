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
func test_ciudad_con_un_clic_inicia_sesion_y_salas_estan_en_el_mapa() -> void:
 GameState.player_name = "Original"
 var map := await _open()
 assert_not_null(map)
 if map == null: return
 assert_eq(map.zone_buttons.size(),map.entries.size(),"Incluye todos los mapas, también salas de prueba")
 for key: String in map.buttons:
  var point: Button = map.buttons[key]
  for other: String in map.buttons:
   if other == key: continue
   assert_false(point.get_rect().intersects(map.buttons[other].get_rect()),key+" / "+other+": puntos separados")
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
