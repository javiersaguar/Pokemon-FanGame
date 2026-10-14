extends GutTest
var _original: Dictionary

func before_each() -> void:
	_original = CharacterArt.entries()
	GameState.reset()

func after_each() -> void:
	CharacterArt._characters = _original
	GameState.reset()

func test_atlas_combate_y_mapa_tienen_regiones_reales_sin_deformar() -> void:
	for id: String in CharacterArt.entries():
		var portrait := CharacterArt.battle_texture(StringName(id))
		assert_not_null(portrait,id)
		var frames := CharacterArt.walk_frames(StringName(id))
		assert_eq(frames.size(),16,id)
		for frame: AtlasTexture in frames:
			assert_not_null(frame)
			assert_eq(frame.get_size(),frames[0].get_size())
		var sprite := CharacterArtSprite.new()
		add_child_autofree(sprite)
		sprite.set_art(StringName(id))
		sprite.facing = Vector2i.UP
		assert_eq((sprite.texture as AtlasTexture).region,frames[12].region)
		assert_lte((sprite.texture.get_height()-8)*sprite.scale.y,64.0)
		assert_gt((sprite.texture.get_height()-8)*sprite.scale.y,32.0)

func test_entrenador_resuelve_su_clase_en_mapa_y_combate_sin_cambiar_colocacion() -> void:
	CharacterArt._characters["ayuso"] = _original.rajoy.duplicate(true)
	assert_eq(TrainerData.get_trainer(&"ayuso").art_id,&"ayuso")
	assert_eq(BattleSetup.trainer_info(&"ayuso").art_id,&"ayuso")
	var actor: TrainerNPC = load("res://src/overworld/trainers/trainer_npc.tscn").instantiate()
	actor.trainer_id = &"ayuso"
	actor.sight_range = 0
	add_child_autofree(actor)
	assert_true(actor.sprite is CharacterArtSprite)
	assert_eq((actor.sprite as CharacterArtSprite).poses.size(),16)

func test_gimnasios_resuelven_sus_personajes_propios() -> void:
	for id: StringName in [&"casado",&"messi",&"julian_alvarez",&"peter_lim",&"antony",&"jose_mota",&"buenafuente",&"berto_romero",&"dani_rovira",&"la_pantera",&"lucho_rk",&"cruz_cafune",&"otegi",&"ronaldo_nazario",&"torrente",&"penelope_cruz",&"javier_bardem"]:
		assert_eq(BattleSetup.trainer_info(id).art_id,id)
		var actor: TrainerNPC = load("res://src/overworld/trainers/trainer_npc.tscn").instantiate()
		actor.trainer_id = id
		actor.sight_range = 0
		add_child_autofree(actor)
		assert_true(actor.sprite is CharacterArtSprite,str(id))
		assert_eq((actor.sprite.texture as AtlasTexture).atlas.resource_path,CharacterArt.info(id).atlas)

func test_messi_usa_las_dos_hojas_intactas_y_declara_sus_poses_quietas() -> void:
	var data := CharacterArt.info(&"messi")
	assert_eq(CharacterArt.battle_texture(&"messi").atlas.resource_path,data.battle_atlas)
	assert_ne(data.battle_atlas,data.atlas)
	var poses := CharacterArt.walk_frames(&"messi")
	assert_eq(poses[0].region,poses[1].region)
	assert_ne(poses[0].region,poses[4].region)
	var preview := CharacterArtPreview.new()
	preview.art_id = &"messi"
	add_child_autofree(preview)
	assert_false(preview.walking)
	assert_true(preview.hint.text.contains("4 poses quietas"))

func test_entrada_muestra_capa_completa_y_nadal_no_se_reduce_a_mitad() -> void:
	var transition := BattleEntryTransition.new()
	transition.kind = &"trainer"
	transition.info = {"trainers":[BattleSetup.trainer_info(&"nadal")]}
	add_child_autofree(transition)
	var portrait := transition._portrait
	assert_true(portrait.texture is AtlasTexture)
	assert_eq((portrait.texture as AtlasTexture).region,CharacterArt.battle_texture(&"nadal").region)
	var size := portrait.texture.get_size() * portrait.scale
	assert_lte(size.x,CharacterArt.BATTLE_MAX.x)
	assert_lte(size.y,CharacterArt.BATTLE_MAX.y)
	assert_gt(size.y,100.0,"raqueta y capa no vuelven diminuto al entrenador")

func test_entrada_y_escena_doble_muestran_las_dos_identidades() -> void:
	var trainers := [BattleSetup.trainer_info(&"abalos"),BattleSetup.trainer_info(&"koldo")]
	var transition := BattleEntryTransition.new()
	transition.kind = &"trainer"
	transition.info = {"trainers":trainers}
	add_child_autofree(transition)
	transition.set_progress(0.4)
	var first := transition._portrait
	var partner := first.get_node(^"PartnerTrainer") as Sprite2D
	assert_eq((first.texture as AtlasTexture).region,CharacterArt.battle_texture(&"abalos").region)
	assert_eq((partner.texture as AtlasTexture).region,CharacterArt.battle_texture(&"koldo").region)
	var a := first.get_global_transform() * first.get_rect()
	var b := partner.get_global_transform() * partner.get_rect()
	assert_false(a.intersects(b),"ambos retratos tienen espacio propio")
	assert_lte(b.end.x,512.0)
	assert_true(transition._title.text.contains("Ábalos") and transition._title.text.contains("Koldo"))
	var scene: BattleScene = load("res://src/battle/scene/battle_scene.tscn").instantiate()
	add_child_autofree(scene)
	scene.fast = true
	scene._box.text_speed = 0
	scene._info = {"trainers":trainers}
	await scene._intro([])
	var world_partner := scene._foe_trainer.get_node(^"PartnerTrainer") as Sprite2D
	assert_true(world_partner.is_visible_in_tree())
	assert_eq((world_partner.texture as AtlasTexture).region,CharacterArt.battle_texture(&"koldo").region)
	var first_feet := scene._foe_trainer.get_global_transform() * Vector2(0,0)
	var partner_feet := world_partner.get_global_transform() * Vector2(0,0)
	assert_eq(first_feet.y,partner_feet.y,"los dos apoyan los pies en la misma base")
	scene._foe_trainer.hide()
	assert_false(world_partner.is_visible_in_tree(),"salen juntos al sacar al Pokémon")

func test_entrada_de_atlas_nuevos_tiene_espacio_sin_necesitar_equipos() -> void:
	var transition := BattleEntryTransition.new()
	transition.kind = &"trainer"
	transition.info = {"trainers":[
		{"art_id":"zona_gemelos_carlos","name":"Carlos"},
		{"art_id":"zona_gemelos_dani","name":"Dani"}]}
	add_child_autofree(transition)
	transition.set_progress(0.4)
	var first := transition._portrait
	var partner := first.get_node(^"PartnerTrainer") as Sprite2D
	assert_not_null(first.texture)
	assert_not_null(partner.texture)
	var a := first.get_global_transform() * first.get_rect()
	var b := partner.get_global_transform() * partner.get_rect()
	assert_false(a.intersects(b),"dos retratos anchos conservan su espacio")
	assert_gte(a.position.x,0.0)
	assert_lte(b.end.x,512.0)
	assert_true(transition._title.text.contains("Carlos") and transition._title.text.contains("Dani"))
