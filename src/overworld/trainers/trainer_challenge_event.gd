extends StoryEvent
## Desafío de un TrainerNPC (Fase 10.4). `source` = el entrenador; params: spotted
## (bool: te ha visto, así que "!" y se acerca; si no, le has hablado).
## Una pareja desafía en un combate doble, con ambos equipos y registros de derrota.


func run() -> void:
	var trainer := source as TrainerNPC
	var group := trainer.group()
	if group.is_empty():
		return
	var map_bgm := AudioManager.current_bgm
	var intro_bgm := StringName(str(trainer.data.get("intro_bgm", "")))
	if intro_bgm != &"":
		AudioManager.play_bgm(intro_bgm, 0.0)
	if bool(param("spotted", false)):
		for t: TrainerNPC in group:
			t.face_towards(player)
		for i: int in group.size():
			if i < group.size() - 1:
				group[i].show_emote("!")
			else:
				await Cutscene.emote(group[i], "!")
		await Cutscene.approach(trainer, player)
	for t: TrainerNPC in group:
		t.face_towards(player)
	player.face_towards(trainer)
	for t: TrainerNPC in group:
		var intro := str(t.data.get("intro_text", ""))
		if intro != "":
			await Dialogue.say(intro, t.display_name)
	if group.size() > 1:
		if await battle_group(group) != SceneManager.OUTCOME_WIN: return
	elif await battle(group[0]) != SceneManager.OUTCOME_WIN: return
	if map_bgm != &"":
		AudioManager.play_bgm(map_bgm)


## El combate contra `t`. Activa trainer_defeated:<id> si ganas (Cutscene.battle_trainer).
func battle(t: TrainerNPC) -> StringName:
	return await Cutscene.battle_trainer(t.trainer_id, t.battle_options)

static func group_setup(group: Array[TrainerNPC]) -> BattleSetup:
	if group.is_empty(): return null
	var setup := BattleSetup.trainer(group[0].trainer_id,group[0].battle_options)
	setup.format = BattleSetup.Format.DOUBLE
	for index: int in range(1,group.size()):
		var partner := BattleSetup.trainer(group[index].trainer_id,group[index].battle_options)
		setup.trainers.append_array(partner.trainers)
		setup.foe_party.append_array(partner.foe_party)
		setup.ai_level = maxi(setup.ai_level,partner.ai_level)
	return setup
func battle_group(group: Array[TrainerNPC]) -> StringName:
	var ids: Array[StringName] = []
	for t: TrainerNPC in group: ids.append(t.trainer_id)
	var setup := group_setup(group)
	var outcome: StringName = await SceneManager.start_battle(setup,{"tutorial":setup.tutorial})
	if outcome == SceneManager.OUTCOME_WIN:
		for id: StringName in ids: GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % id))
	return outcome
