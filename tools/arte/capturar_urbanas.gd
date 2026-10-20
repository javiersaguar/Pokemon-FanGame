extends Node
## Montaje de revisión. Solo compone recursos; no escribe escenas ni pinta mapas reales.
const OUT := "res://docs/arte/comparativas/edificios_reales/"
var catalog: Dictionary

func _ready() -> void:
	catalog = ExteriorTiles.objects()
	await _scene(false, "urbanas_antes.png")
	await _scene(true, "urbanas_despues.png")
	var contract := JsonFile.read_dict(OUT + "urbanas_contrato.json")
	var vp := _viewport(Vector2i(640, 480))
	var i := 0
	for id: String in contract.pieces:
		var pos := Vector2(16 + (i % 8) * 80, 16 + (i / 8) * 112)
		_sprite(vp, StringName(id), pos)
		var label := Label.new()
		label.text = str(contract.pieces[id].source)
		label.position = pos + Vector2(0, 80)
		label.add_theme_font_size_override("font_size", 11)
		vp.add_child(label)
		i += 1
	await _save(vp, "urbanas_catalogo.png")
	get_tree().quit()

func _viewport(size: Vector2i) -> SubViewport:
	var vp := SubViewport.new()
	vp.size = size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(vp)
	return vp

func _sprite(parent: Node, id: StringName, pos: Vector2) -> void:
	var p: Dictionary = catalog[id]
	var source := (load(ExteriorTiles.TILESET) as TileSet).get_source(int(p.source)) as TileSetAtlasSource
	var sprite := Sprite2D.new()
	sprite.texture = source.texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(p.coords * 32, p.size * 32)
	sprite.centered = false
	sprite.position = pos
	parent.add_child(sprite)

func _place(parent: Node, id: StringName, tile: Vector2i) -> void:
	var p: Dictionary = catalog[id]
	_sprite(parent, id, Vector2((tile - Vector2i(0,p.size.y-1)) * 32))

func _scene(after: bool, file: String) -> void:
	var vp := _viewport(Vector2i(640,448))
	var ground := TileMapLayer.new()
	ground.tile_set = load(ExteriorTiles.TILESET)
	vp.add_child(ground)
	for y: int in 14:
		for x: int in 20:
			var paving := x > 1 and x < 18 and y > 2 and y < 13
			ground.set_cell(Vector2i(x,y),ExteriorTiles.SRC_GEN4,
				ExteriorTiles.PAVING_STONE + Vector2i(1,1) if paving else ExteriorTiles.GRASS[0])
	_place(vp,&"casa_roja_chimenea",Vector2i(2,5))
	_place(vp,&"farola_verde",Vector2i(8,5))
	_place(vp,&"banco",Vector2i(11,12))
	if after:
		_place(vp,&"alcorque_arbol",Vector2i(9,6))
		_place(vp,&"alcorque_urbano",Vector2i(14,6))
		_place(vp,&"jardinera_urbana",Vector2i(12,9))
		_place(vp,&"jardinera_urbana_vertical",Vector2i(17,10))
		_place(vp,&"bordillo_esquina_no",Vector2i(8,7))
		_place(vp,&"bordillo_esquina_ne",Vector2i(15,7))
		_place(vp,&"bordillo_esquina_so",Vector2i(8,11))
		_place(vp,&"bordillo_esquina_se",Vector2i(15,11))
		for x: int in range(9,15):
			_place(vp,&"bordillo_n",Vector2i(x,7))
			_place(vp,&"bordillo_s",Vector2i(x,11))
		for y: int in range(8,11):
			_place(vp,&"bordillo_o",Vector2i(8,y))
			_place(vp,&"bordillo_e",Vector2i(15,y))
		_place(vp,&"tapia_esquina_no",Vector2i(2,8))
		_place(vp,&"tapia_esquina_ne",Vector2i(6,8))
		for x: int in range(3,6):
			_place(vp,&"tapia_horizontal",Vector2i(x,8))
		for y: int in range(9,12,2):
			_place(vp,&"tapia_vertical",Vector2i(2,y))
			_place(vp,&"tapia_vertical",Vector2i(6,y))
		_place(vp,&"tapia_fin_s",Vector2i(2,12))
		_place(vp,&"tapia_fin_s",Vector2i(6,12))
	else:
		_place(vp,&"arbol_redondo",Vector2i(9,6))
		_place(vp,&"jardinera",Vector2i(12,9))
	await _save(vp,file)

func _save(vp: SubViewport, file: String) -> void:
	for i: int in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := vp.get_texture().get_image().save_png(OUT+file)
	assert(result==OK)
	print(file, ": ", error_string(result))
	vp.queue_free()
	await get_tree().process_frame
