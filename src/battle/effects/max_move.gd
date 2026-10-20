class_name MaxMoveEffect
extends BattleEffect
## Movimientos Dinamax (8.ª generación, como Showdown): después de golpear ponen un tiempo o un campo,
## suben una característica a su bando o la bajan al bando rival.

var weather_id: StringName = &""
var terrain_id: StringName = &""
## Característica que sube un nivel al usuario (y a su aliado).
var ally_stat: StringName = &""
## Característica que baja un nivel al objetivo (y a su compañero).
var foe_stat: StringName = &""


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted():
		return
	if weather_id != &"":
		engine.set_weather(weather_id, user)
	if terrain_id != &"":
		engine.set_terrain(terrain_id, user)
	if ally_stat != &"":
		for b: Battler in [user, engine.ally_of(user)]:
			if b != null and not b.is_fainted():
				engine.boost(b, {ally_stat: 1}, true)
	if foe_stat != &"":
		for b: Battler in [target, engine.ally_of(target)]:
			if b != null and not b.is_fainted():
				engine.boost(b, {foe_stat: -1}, true)
