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
	character.jump(Vector2i.RIGHT)
	await get_tree().create_timer(0.15).timeout
	var shadow := character.get_node("GroundShadow") as Sprite2D
	assert_lt(character.sprite.global_position.y, character.global_position.y)
	assert_eq(shadow.global_position.y, character.global_position.y)
	await character.step_finished
	assert_eq(character.sprite.position, Vector2.ZERO)
	assert_eq(shadow.position, Vector2.ZERO)
