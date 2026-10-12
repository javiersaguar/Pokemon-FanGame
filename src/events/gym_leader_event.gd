extends "res://src/overworld/trainers/trainer_challenge_event.gd"
## Desafío de un líder de gimnasio: el combate normal y, si le ganas, la medalla de su gimnasio
## (data/gimnasios.json). Hablarle después solo repite su after_text (TrainerNPC).

const GYMS := "res://data/gimnasios.json"


func run() -> void:
	var trainer := source as TrainerNPC
	var leader_id := trainer.trainer_id if trainer else &""
	await super()
	if leader_id != &"" and GameState.flag(StringName(TrainerNPC.DEFEATED_FLAG % leader_id)):
		await award(leader_id)


## Entrega la medalla del gimnasio de `leader_id` si aún no la tienes, con su mensaje.
static func award(leader_id: StringName) -> void:
	var gym := grant(leader_id)
	if gym.is_empty():
		return
	AudioManager.play_me(&"level_up")
	await Dialogue.say("¡Has conseguido la %s del gimnasio de %s!" % [gym["nombre_medalla"], gym["ciudad"]])


## Apunta la medalla en la partida. Devuelve el gimnasio, o {} si no es líder o ya la tenías.
static func grant(leader_id: StringName) -> Dictionary:
	var gym := gym_of(leader_id)
	if gym.is_empty() or GameState.has_badge(StringName(str(gym["medalla"]))):
		return {}
	GameState.add_badge(StringName(str(gym["medalla"])))
	return gym


## El gimnasio cuyo líder es `leader_id` ({} si no lo es de ninguno).
static func gym_of(leader_id: StringName) -> Dictionary:
	var gyms: Dictionary = JsonFile.read_dict(GYMS).get("gimnasios", {})
	for city: String in gyms:
		if str(gyms[city].get("lider", "")) == String(leader_id):
			return gyms[city]
	return {}
