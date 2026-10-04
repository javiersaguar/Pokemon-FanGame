extends GutTest
## Fórmula de daño comparada con el simulador de Showdown 0.11.11 (getDamage con las 16 tiradas).
## Los rangos esperados se han sacado ejecutando el propio Showdown con los mismos Pokémon
## (IVs 31, naturaleza Fuerte salvo que se indique y habilidades que no afectan al daño).


func _battler(species: StringName, level: int, spec: Dictionary = {}, side: int = 0) -> Battler:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var p := Pokemon.create(species, level, rng)
	var full := {"nature": "hardy", "ivs": 31, "evs": 0}
	full.merge(spec, true)
	p.apply_spec(full)
	return Battler.new(p, side, 0, 0)


func _range(att: Battler, def: Battler, move: StringName, crit: bool = false) -> Array[int]:
	return DamageCalc.damage_range(att, def, DataDB.move(move), crit)


func test_garchomp_terremoto_contra_heatran() -> void:
	var att := _battler(&"garchomp", 50, {"nature": "adamant", "evs": {"atk": 252}})
	var def := _battler(&"heatran", 50, {"nature": "calm", "evs": {"hp": 252}}, 1)
	assert_eq(_range(att, def, &"earthquake"),
		[360, 364, 364, 372, 376, 376, 384, 388, 396, 396, 400, 408, 408, 412, 420, 424] as Array[int])


func test_especial_cuadruple_con_stab() -> void:
	assert_eq(_range(_battler(&"pikachu", 25), _battler(&"gyarados", 25, {}, 1), &"thunderbolt"),
		[64, 72, 72, 72, 72, 72, 72, 72, 76, 76, 76, 76, 76, 76, 76, 84] as Array[int])


func test_nivel_bajo_supereficaz() -> void:
	assert_eq(_range(_battler(&"charmander", 10), _battler(&"bulbasaur", 10, {}, 1), &"ember"),
		[14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 18] as Array[int])


func test_neutro_sin_stab() -> void:
	assert_eq(_range(_battler(&"bulbasaur", 10), _battler(&"charmander", 12, {}, 1), &"tackle"),
		[5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6] as Array[int])
	assert_eq(_range(_battler(&"rattata", 3), _battler(&"pidgey", 2, {}, 1), &"tackle"),
		[6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7] as Array[int])


func test_critico() -> void:
	assert_eq(_range(_battler(&"squirtle", 8), _battler(&"pidgey", 8, {}, 1), &"tackle", true),
		[7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9] as Array[int])


func test_quemadura_reduce_el_fisico() -> void:
	var att := _battler(&"machamp", 50, {"nature": "adamant", "evs": {"atk": 252}})
	att.pokemon.set_status(&"brn")
	var def := _battler(&"snorlax", 50, {"evs": {"hp": 252, "def": 4}}, 1)
	assert_eq(_range(att, def, &"closecombat"),
		[157, 159, 160, 163, 165, 166, 168, 171, 172, 174, 175, 178, 180, 181, 183, 186] as Array[int])


func test_niveles_de_caracteristicas() -> void:
	var att := _battler(&"garchomp", 50, {"nature": "jolly", "evs": {"atk": 252}})
	var def := _battler(&"dragonite", 50, {"evs": {"hp": 252}}, 1)
	att.boosts[&"atk"] = 2
	def.boosts[&"def"] = 1
	assert_eq(_range(att, def, &"dragonclaw"),
		[192, 194, 198, 198, 200, 204, 206, 206, 210, 212, 216, 216, 218, 222, 224, 228] as Array[int])


func test_el_critico_ignora_niveles_desfavorables() -> void:
	var att := _battler(&"garchomp", 50, {"nature": "jolly", "evs": {"atk": 252}})
	var def := _battler(&"dragonite", 50, {"evs": {"hp": 252}}, 1)
	att.boosts[&"atk"] = -1
	def.boosts[&"def"] = 2
	assert_eq(_range(att, def, &"dragonclaw", true),
		[216, 218, 218, 222, 224, 228, 230, 234, 236, 236, 240, 242, 246, 248, 252, 254] as Array[int])


func test_resistencias() -> void:
	assert_eq(_range(_battler(&"bulbasaur", 30), _battler(&"charizard", 30, {}, 1), &"vinewhip"),
		[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3] as Array[int], "×0,25")
	assert_eq(_range(_battler(&"charmander", 15), _battler(&"squirtle", 15, {}, 1), &"ember"),
		[4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6] as Array[int], "×0,5")


func test_redondeo_en_base_4096() -> void:
	assert_eq(DamageCalc.modify(100, 1.5), 150)
	assert_eq(DamageCalc.modify(101, 1.5), 151, "151,5 redondea hacia abajo")
	assert_eq(DamageCalc.modify(103, 0.5), 51, "51,5 redondea hacia abajo")
	assert_eq(DamageCalc.modify(7, 1.5), 10, "10,5 redondea hacia abajo")
	assert_eq(DamageCalc.base_damage(50, 100, 100, 100), 44)
