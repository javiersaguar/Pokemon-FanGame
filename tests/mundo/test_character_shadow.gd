extends GutTest
func after_each() -> void:
	GameState.reset()
func test_personajes_y_seguidor_usan_sombra_del_arte() -> void:
	for path: String in ["player/player", "npc/npc", "follower/follower"]:
		var character: Character = load("res://src/overworld/%s.tscn" % path).instantiate()
		add_child_autofree(character)
		var shadow := character.get_node("GroundShadow") as Sprite2D
		assert_not_null(shadow.texture)
		assert_eq(shadow.texture.resource_path, "res://assets/sprites/characters/effects/sombra.png")
		assert_eq(shadow.position, Vector2.ZERO)
func test_sombra_queda_en_suelo_durante_salto() -> void:
	var character: Character = load("res://src/overworld/npc/npc.tscn").instantiate()
	add_child_autofree(character)
	character.place_at(Vector2i(4, 4))
	var previous := get_tree().get_processed_tweens()
	character.jump(Vector2i.RIGHT)
	var jump_tweens: Array[Tween] = []
	for tween: Tween in get_tree().get_processed_tweens():
		if not previous.has(tween): jump_tweens.append(tween)
	assert_gt(jump_tweens.size(), 0, "el salto crea sus animaciones")
	if jump_tweens.is_empty(): return
	for tween: Tween in jump_tweens:
		tween.pause()
		tween.custom_step(Character.JUMP_TIME * 0.5)
	var shadow := character.get_node("GroundShadow") as Sprite2D
	assert_lt(character.sprite.global_position.y, character.global_position.y)
	assert_eq(shadow.global_position.y, character.global_position.y)
	for tween: Tween in jump_tweens:
		if tween.is_valid(): tween.custom_step(Character.JUMP_TIME)
	await get_tree().process_frame
	assert_false(character.moving)
	assert_eq(character.sprite.position, Vector2.ZERO)
	assert_eq(shadow.position, Vector2.ZERO)
	await get_tree().create_timer(0.4).timeout
