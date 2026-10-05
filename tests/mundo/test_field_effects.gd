extends GutTest
class EffectCharacter extends Character:
	var effects: Array[String] = []
	func _spawn_effect(texture: Texture2D, _tile: Vector2i, _time: float) -> void:
		effects.append(texture.resource_path)
class PuddleMap extends MapRoot:
	func terrain_at(_tile: Vector2i) -> String:
		return "puddle"
func after_each() -> void:
	SceneManager.current_map = null
	GameState.reset()
func actor() -> EffectCharacter:
	var character = load("res://src/overworld/npc/npc.tscn").instantiate()
	character.set_script(EffectCharacter)
	add_child_autofree(character)
	return character
func test_polvo_solo_cada_dos_pasos_corriendo() -> void:
	var character := actor()
	await character.step(Vector2i.RIGHT, 0.02, true, true)
	assert_eq(character.effects.size(), 0)
	await character.step(Vector2i.RIGHT, 0.02, true, true)
	assert_eq(character.effects, [Character.JUMP_DUST.resource_path] as Array[String])
	await character.step(Vector2i.RIGHT, 0.02, true, false)
	assert_eq(character.effects.size(), 1)
	await wait_physics_frames(2)
func test_charco_salpica_con_asset_del_pack() -> void:
	var map := PuddleMap.new()
	add_child_autofree(map)
	SceneManager.current_map = map
	var character := actor()
	await character.step(Vector2i.RIGHT, 0.02, true)
	assert_eq(character.effects, [Character.WATER_SPLASH.resource_path] as Array[String])
	await wait_physics_frames(2)
