extends GutTest
## Servicios completos sobre el mundo y la interfaz reales; archivos aislados por XDG.
var main: Node
var session: PlaytestSession
var old_speed: int
func before_each() -> void:
 GameState.reset()
 SaveManager.test_session_active = false
 old_speed = Dialogue._box.text_speed
 Dialogue._box.text_speed = 0
 main = load("res://src/main/main.tscn").instantiate()
 main.set_script(null)
 add_child(main)
 SceneManager.register_main(main)
 session = PlaytestSession.new()
func after_each() -> void:
 Debug.close()
 SaveManager.test_session_active = false
 Dialogue._box.text_speed = old_speed
 SceneManager._leave_game()
 main.queue_free()
 await wait_physics_frames(2)
 SceneManager.world = null
 SceneManager.ui_layer = null
 SceneManager.battle_layer = null
 SceneManager.transition_layer = null
 SceneManager._fade = null
 GameState.reset()
 session = null
 MapLoader.clear()
func _press(action: StringName = &"accept") -> void:
 for down: bool in [true,false]:
  var event := InputEventAction.new()
  event.action = action
  event.pressed = down
  Input.parse_input_event(event)
func test_puertas_llevan_al_local_y_se_sale_sin_bucle() -> void:
 await session.begin(&"malaga/exterior")
 for local: String in ["hospital","mercadona","estanco"]:
  var map := SceneManager.current_map
  var entry: Warp = map.get_node("Warps/"+local.capitalize())
  var door := Grid.to_tile(entry.position)
  SceneManager.player.place_at(door+Vector2i.DOWN,Vector2i.UP)
  await wait_physics_frames(2)
  assert_true(SceneManager.player.is_tile_free(door),local+": puerta caminable")
  SceneManager.player.place_at(door,Vector2i.UP)
  await SceneManager.player._after_step()
  assert_eq(GameState.map_id,StringName("malaga/"+local))
  assert_false(SceneManager.current_map.data.outdoor)
  assert_false(SceneManager.current_map.data.can_bike)
  SceneManager.player.place_at(Vector2i(8,11),Vector2i.DOWN)
  await SceneManager.player._after_step()
  assert_eq(GameState.map_id,&"malaga/exterior")
  assert_eq(SceneManager.player.tile_position(),door+Vector2i.DOWN)
  assert_null(SceneManager.current_map.warp_at(SceneManager.player.tile_position()),"no reentra al salir")
 await session.finish()
func test_enfermera_cura_desde_mostrador_y_derrota_vuelve_al_hospital() -> void:
 await session.begin(&"malaga/hospital")
 var p := GameState.party.get_at(0) as Pokemon
 p.current_hp = 1
 p.status = &"par"
 p.moves[0].pp = 0
 SceneManager.player.place_at(Vector2i(8,5),Vector2i.UP)
 SceneManager.player._interact()
 var until := Time.get_ticks_msec()+8000
 while GameState.input_locked and Time.get_ticks_msec()<until:
  await wait_process_frames(2)
  if Dialogue.is_open: _press()
 assert_false(GameState.input_locked,"termina el servicio y devuelve el control")
 assert_eq(p.current_hp,p.max_hp())
 assert_eq(p.status,&"")
 assert_gt(p.moves[0].pp,0)
 assert_eq(GameState.healing_map,&"malaga/hospital")
 assert_eq(GameState.healing_spawn,&"recovery")
 await SceneManager.change_map(&"malaga/exterior",&"default")
 p.current_hp = 0
 await SceneManager._whiteout()
 assert_eq(GameState.map_id,&"malaga/hospital")
 assert_eq(SceneManager.player.tile_position(),Vector2i(8,5))
 assert_eq(p.current_hp,p.max_hp())
 await session.finish()
func test_terminal_abre_el_pc_y_devuelve_control() -> void:
 await session.begin(&"malaga/hospital")
 SceneManager.player.place_at(Vector2i(12,10),Vector2i.UP)
 SceneManager.player._interact()
 await wait_until(func() -> bool: return SceneManager.top_menu() is PCScreen,2.0)
 assert_true(SceneManager.top_menu() is PCScreen)
 await wait_process_frames(3)
 _press(&"cancel")
 await wait_process_frames(3)
 assert_false(SceneManager.is_menu_open())
 assert_false(GameState.input_locked)
 await session.finish()
func test_stock_y_compra_usan_precios_de_datadb() -> void:
 await session.begin(&"malaga/mercadona")
 assert_has(ShopTransactions.stock(&"mercadona_malaga"),&"pokeball")
 assert_does_not_have(ShopTransactions.stock(&"mercadona_malaga"),&"ultraball")
 var price := DataDB.item(&"potion").price
 var money: int = GameState.money
 var count: int = GameState.bag.count(&"potion")
 assert_eq(ShopTransactions.buy(&"mercadona_malaga",&"potion",2),OK)
 assert_eq(GameState.money,money-price*2)
 assert_eq(GameState.bag.count(&"potion"),count+2)
 assert_has(ShopTransactions.stock(&"estanco_malaga"),&"xattack")
 assert_eq(ShopTransactions.price(&"estanco_malaga",&"xattack"),DataDB.item(&"xattack").price)
 assert_eq(ShopTransactions.buy(&"estanco_malaga",&"pokeball",1),ERR_INVALID_PARAMETER)
 SceneManager.player.place_at(Vector2i(8,5),Vector2i.UP)
 SceneManager.player._interact()
 var until := Time.get_ticks_msec()+4000
 while not SceneManager.top_menu() is ShopScreen and Time.get_ticks_msec()<until:
  await wait_process_frames(2)
  if Dialogue.is_open: _press()
 assert_true(SceneManager.top_menu() is ShopScreen,"dependiente abre la tienda real a través del mostrador")
 await wait_process_frames(3)
 _press(&"cancel")
 until = Time.get_ticks_msec()+4000
 while GameState.input_locked and Time.get_ticks_msec()<until:
  await wait_process_frames(2)
  if Dialogue.is_open: _press()
 assert_false(GameState.input_locked)
 await session.finish()

func test_todas_las_ciudades_conservan_barrio_puerta_y_salida() -> void:
 var cities := JsonFile.read_dict("res://maps/_pintura/locales.json")
 await session.begin(&"malaga/exterior")
 for city: String in cities:
  for kind: String in ["hospital","centro","mercadona","estanco"]:
   if not cities[city].has(kind): continue
   var row: Array = cities[city][kind]
   var outside := StringName(row[0])
   var error := await SceneManager.change_map(outside,&"default")
   assert_eq(error,OK,outside)
   if error != OK: continue
   var warp: Warp = SceneManager.current_map.get_node("Warps/"+kind.capitalize())
   var at := Grid.to_tile(warp.position)
   await wait_physics_frames(2)
   assert_true(SceneManager.player.is_tile_free(at),city+" / "+kind+": puerta caminable")
   SceneManager.player.place_at(at,Vector2i.UP)
   await SceneManager.player._after_step()
   assert_eq(GameState.map_id,StringName(city+"/"+kind))
   assert_false(SceneManager.current_map.data.outdoor)
   SceneManager.player.place_at(Vector2i(8,11),Vector2i.DOWN)
   await SceneManager.player._after_step()
   assert_eq(GameState.map_id,outside,city+" / "+kind+": vuelve al mismo barrio")
   assert_eq(SceneManager.player.tile_position(),at+Vector2i.DOWN)
   assert_null(SceneManager.current_map.warp_at(SceneManager.player.tile_position()))
 await session.finish()

func test_centros_del_tramo_curan_fijan_recuperacion_y_abren_pc() -> void:
 await session.begin(&"getafe/centro")
 for city: String in ["getafe","leganes","mostoles","puertollano"]:
  await SceneManager.change_map(StringName(city+"/centro"),&"default")
  var p := GameState.party.get_at(0) as Pokemon
  p.current_hp = 1
  p.status = &"brn"
  p.moves[0].pp = 0
  SceneManager.player.place_at(Vector2i(8,5),Vector2i.UP)
  SceneManager.player._interact()
  var until := Time.get_ticks_msec()+8000
  while GameState.input_locked and Time.get_ticks_msec()<until:
   await wait_process_frames(2)
   if Dialogue.is_open: _press()
  assert_false(GameState.input_locked,city+": enfermería devuelve el control")
  assert_eq(p.current_hp,p.max_hp())
  assert_eq(p.status,&"")
  assert_gt(p.moves[0].pp,0)
  assert_eq(GameState.healing_map,StringName(city+"/centro"))
  assert_eq(GameState.healing_spawn,&"recovery")
  await SceneManager.change_map(StringName(city+"/exterior"),&"default")
  p.current_hp = 0
  await SceneManager._whiteout()
  assert_eq(GameState.map_id,StringName(city+"/centro"))
  assert_eq(SceneManager.player.tile_position(),Vector2i(8,5))
  assert_eq(p.current_hp,p.max_hp())
  SceneManager.player.place_at(Vector2i(12,10),Vector2i.UP)
  SceneManager.player._interact()
  await wait_until(func() -> bool: return SceneManager.top_menu() is PCScreen,2.0)
  assert_true(SceneManager.top_menu() is PCScreen,city+": terminal PC")
  await wait_process_frames(3)
  _press(&"cancel")
  await wait_process_frames(3)
  assert_false(SceneManager.is_menu_open())
  assert_false(GameState.input_locked)
  assert_has(ShopTransactions.stock(StringName("mercadona_"+city)),&"potion")
  assert_has(ShopTransactions.stock(StringName("estanco_"+city)),&"xattack")
  var price := DataDB.item(&"potion").price
  var money: int = GameState.money
  var quantity: int = GameState.bag.count(&"potion")
  assert_eq(ShopTransactions.buy(StringName("mercadona_"+city),&"potion",1),OK)
  assert_eq(GameState.money,money-price)
  assert_eq(GameState.bag.count(&"potion"),quantity+1)
 await session.finish()

func test_servicios_adicionales_curan_y_tiendas_de_barrios_usan_su_catalogo() -> void:
 await session.begin(&"huelva/centro")
 for id: String in ["huelva/centro","madrid/sol/hospital"]:
  assert_eq(await SceneManager.change_map(StringName(id)),OK)
  var p: Pokemon = GameState.party.get_at(0)
  p.current_hp = 1
  p.status = &"psn"
  p.moves[0].pp = 0
  SceneManager.player.place_at(Vector2i(8,5),Vector2i.UP)
  SceneManager.player._interact()
  var until := Time.get_ticks_msec()+8000
  while GameState.input_locked and Time.get_ticks_msec()<until:
   await wait_process_frames(2)
   if Dialogue.is_open: _press()
  assert_false(GameState.input_locked)
  assert_eq(p.current_hp,p.max_hp())
  assert_eq(p.status,&"")
  assert_gt(p.moves[0].pp,0)
  assert_eq(GameState.healing_map,StringName(id))
  SceneManager.player.place_at(Vector2i(12,10),Vector2i.UP)
  SceneManager.player._interact()
  await wait_until(func() -> bool: return SceneManager.top_menu() is PCScreen,2.0)
  assert_true(SceneManager.top_menu() is PCScreen)
  await wait_process_frames(3)
  _press(&"cancel")
  await wait_process_frames(3)
  assert_false(GameState.input_locked)
 var locations := JsonFile.read_dict("res://maps/_pintura/locales.json")
 for key: String in locations:
  if not locations[key].has("heading_y"): continue
  for kind: String in ["mercadona","estanco"]:
   if not locations[key].has(kind): continue
   var shop := StringName(kind+"_"+key.replace("/","_"))
   var item := &"potion" if kind == "mercadona" else &"xattack"
   var before: int = GameState.money
   var count: int = GameState.bag.count(item)
   assert_has(ShopTransactions.stock(shop),item)
   assert_eq(ShopTransactions.buy(shop,item,1),OK)
   assert_eq(GameState.money,before-DataDB.item(item).price)
   assert_eq(GameState.bag.count(item),count+1)
 await session.finish()

func _finish_interaction() -> void:
 var until := Time.get_ticks_msec()+6000
 while GameState.input_locked and Time.get_ticks_msec()<until:
  await wait_process_frames(2)
  if Dialogue.is_open: _press()

func test_recompensa_de_npc_resuelve_randomlocke_cancela_y_no_se_duplica() -> void:
 assert_eq(await session.begin(&"getafe/mercadona"),OK)
 var placement := "getafe/mercadona/Cliente"
 assert_eq(DataDB.apply_patch({"items":{placement:"superpotion"}}),[])
 var count: int = GameState.bag.count(&"superpotion")
 SceneManager.player.place_at(Vector2i(5,8),Vector2i.UP)
 SceneManager.player._interact()
 await wait_process_frames(3)
 _press(&"cancel")
 await wait_process_frames(3)
 assert_false(GameState.flag(&"npc_reward:getafe_mercadona_cortesia"))
 assert_eq(GameState.bag.count(&"superpotion"),count)
 for times: int in 2:
  SceneManager.player._interact()
  await _finish_interaction()
  assert_false(GameState.input_locked)
  assert_eq(GameState.bag.count(&"superpotion"),count+1)
 assert_true(GameState.flag(&"npc_reward:getafe_mercadona_cortesia"))
 assert_has(GameState.to_dict().flags,"npc_reward:getafe_mercadona_cortesia")
 await session.finish()

func test_mochila_llena_no_consume_regalo_y_expositor_muestra_catalogo_real() -> void:
 assert_eq(await session.begin(&"getafe/mercadona"),OK)
 GameState.bag.add(&"potion",Bag.MAX_COUNT)
 SceneManager.player.place_at(Vector2i(5,8),Vector2i.UP)
 SceneManager.player._interact()
 await _finish_interaction()
 assert_false(GameState.flag(&"npc_reward:getafe_mercadona_cortesia"))
 GameState.bag.remove(&"potion",1)
 SceneManager.player._interact()
 await _finish_interaction()
 assert_true(GameState.flag(&"npc_reward:getafe_mercadona_cortesia"))
 assert_eq(GameState.bag.count(&"potion"),Bag.MAX_COUNT)
 SceneManager.player.place_at(Vector2i(3,6),Vector2i.UP)
 SceneManager.player._interact()
 await wait_process_frames(4)
 var screen := SceneManager.top_menu() as ChoiceScreen
 assert_not_null(screen)
 if screen != null:
  assert_eq(screen.choices.size(),ShopTransactions.stock(&"mercadona_getafe").size())
  assert_true(screen.choices[0].contains(str(ShopTransactions.price(&"mercadona_getafe",ShopTransactions.stock(&"mercadona_getafe")[0]))))
  assert_true(screen.notes[0].contains("Compra en la caja"))
  _press(&"cancel")
  await wait_process_frames(3)
 assert_false(GameState.input_locked)
 await session.finish()

func test_puesto_del_mercado_abre_compra_de_objetos_existentes() -> void:
 assert_eq(await session.begin(&"getafe/exterior"),OK)
 SceneManager.player.place_at(Vector2i(25,30),Vector2i.UP)
 SceneManager.player._interact()
 var until := Time.get_ticks_msec()+4000
 while not SceneManager.top_menu() is ShopScreen and Time.get_ticks_msec()<until:
  await wait_process_frames(2)
  if Dialogue.is_open: _press()
 assert_true(SceneManager.top_menu() is ShopScreen)
 await wait_process_frames(3)
 _press(&"cancel")
 await _finish_interaction()
 assert_false(GameState.input_locked)
 await session.finish()

func test_casa_visitable_conserva_zona_salida_y_pc_real() -> void:
 assert_eq(await session.begin(&"getafe/exterior"),OK)
 SceneManager.player.place_at(Vector2i(47,23),Vector2i.UP)
 await SceneManager.player._after_step()
 assert_eq(GameState.map_id,&"getafe/casa_vecina")
 assert_eq(SceneManager.current_map.get_zone_id(),&"getafe")
 SceneManager.player.place_at(Vector2i(8,5),Vector2i.UP)
 SceneManager.player._interact()
 await wait_until(func() -> bool: return SceneManager.top_menu() is PCScreen,2.0)
 assert_true(SceneManager.top_menu() is PCScreen)
 await wait_process_frames(3)
 _press(&"cancel")
 await wait_process_frames(3)
 SceneManager.player.place_at(Vector2i(8,11),Vector2i.DOWN)
 await SceneManager.player._after_step()
 assert_eq(GameState.map_id,&"getafe/exterior")
 assert_eq(SceneManager.player.tile_position(),Vector2i(47,24))
 assert_null(SceneManager.current_map.warp_at(Vector2i(47,24)))
 await session.finish()
