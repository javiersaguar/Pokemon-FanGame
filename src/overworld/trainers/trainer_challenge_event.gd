extends StoryEvent
## Desafío de un TrainerNPC (Fase 10.4). `source` = el entrenador; params: spotted
## (bool: te ha visto, así que "!" y se acerca; si no, le has hablado).
## Con pareja, los dos te desafían. Hasta que el motor juegue dobles (Fase 9.4), cada
## uno lucha por separado, uno detrás de otro.


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
		# Si pierdes y no se puede perder, SceneManager te lleva al Centro Pokémon y
		# este mapa (con los entrenadores) ya no existe.
		if await battle(t) != SceneManager.OUTCOME_WIN:
			return
	if map_bgm != &"":
		AudioManager.play_bgm(map_bgm)


## El combate contra `t`. Activa trainer_defeated:<id> si ganas (Cutscene.battle_trainer).
func battle(t: TrainerNPC) -> StringName:
	return await Cutscene.battle_trainer(t.trainer_id, t.battle_options)
