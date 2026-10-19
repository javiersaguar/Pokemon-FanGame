extends BattleEffect
## Meteorobola: con un clima dobla la potencia y toma su tipo (lluvia, Agua; sol, Fuego; arena,
## Roca; nieve, Hielo).

const TYPES := {&"raindance": &"water", &"sunnyday": &"fire", &"sandstorm": &"rock", &"snow": &"ice", &"snowscape": &"ice", &"hail": &"ice"}


func modify_move(engine: BattleEngine, _user: Battler, move: MoveData) -> MoveData:
	if not TYPES.has(engine.weather()):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = TYPES[engine.weather()]
	copy.power = move.power * 2
	return copy
