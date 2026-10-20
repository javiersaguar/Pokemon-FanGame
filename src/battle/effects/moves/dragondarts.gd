extends BattleEffect
## Dracoflechas: dos golpes. En individuales, los dos al mismo objetivo; en dobles, uno a cada rival,
## o los dos al que se pueda alcanzar si el otro se protege, es inmune o está en el aire o bajo tierra.


func smart_target() -> bool:
	return true
