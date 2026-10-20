extends GutTest
## Revisión de punta a punta: un combate completo de cada líder y de la Liga con sus equipos reales y la
## IA de su clase (contra su propio equipo, porque el equipo esperado del jugador es PENDIENTE JAVIER).
## Falla si algún movimiento, habilidad u objeto de esos equipos no tiene efecto o si el combate no acaba.

const LIDERES: Array[StringName] = [&"ayuso", &"laporta", &"labrador", &"joaquin", &"quevedo", &"aupa_athletic",
	&"latasa", &"banderas", &"iniesta", &"nadal", &"gasol", &"alonso", &"pedro_sanchez"]


func _sin_efecto(party: Array) -> PackedStringArray:
	var missing: PackedStringArray = []
	for p: Pokemon in party:
		for slot: MoveSlot in p.moves:
			var m := DataDB.move(slot.id)
			if m.needs_script and not Effects.has_move(slot.id) and slot.id != &"struggle":
				missing.append("%s: movimiento %s" % [p.species_id, slot.id])
		var ability := p.ability_id()
		if ability != &"" and Effects.ability(ability) == null:
			missing.append("%s: habilidad %s" % [p.species_id, ability])
		if p.held_item != &"" and DataDB.has_item(p.held_item) and DataDB.item(p.held_item).pocket in [&"items", &"berries"] \
				and Effects.item(p.held_item) == null:
			missing.append("%s: objeto %s" % [p.species_id, p.held_item])
	return missing


func test_todos_los_equipos_de_lideres_y_liga_tienen_efecto() -> void:
	var missing: PackedStringArray = []
	for id: StringName in LIDERES:
		if DataDB.has_trainer(id):
			missing.append_array(_sin_efecto(BattleSetup.trainer(id).foe_party))
	assert_eq(missing.size(), 0, "\n".join(missing))


func test_cada_combate_acaba_con_un_ganador() -> void:
	var played := 0
	for id: StringName in LIDERES:
		if not DataDB.has_trainer(id):
			continue
		var setup := BattleSetup.trainer(id)
		var result := BalanceSim.simulate(setup.foe_party, setup.foe_party, 2, 5, setup.ai_level, setup.ai_level)
		assert_eq(int(result["other"]), 0, "%s: el combate se ha quedado sin acabar" % id)
		played += 1
	assert_eq(played, LIDERES.size(), "están todos los líderes, el Alto Mando y Pedro Sánchez")
