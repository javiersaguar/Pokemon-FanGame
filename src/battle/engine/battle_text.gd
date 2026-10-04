class_name BattleText
extends RefCounted
## Textos del combate en un solo sitio (pasan por tr()). El motor los usa en los eventos `message`.

const CURRENCY := "₽"

## Con artículo: "el Ataque", "la Defensa"...
const STAT_NAMES: Dictionary[StringName, String] = {
	&"atk": "el Ataque", &"def": "la Defensa", &"spa": "el Ataque Especial", &"spd": "la Defensa Especial",
	&"spe": "la Velocidad", &"accuracy": "la Precisión", &"evasion": "la Evasión",
}
const STATUS_SET: Dictionary[StringName, String] = {
	&"par": "¡%s sufre parálisis! Puede que no consiga moverse.",
	&"brn": "¡%s se ha quemado!",
	&"psn": "¡%s ha sido envenenado!",
	&"tox": "¡%s ha sido gravemente envenenado!",
	&"slp": "¡%s se ha dormido!",
	&"frz": "¡%s se ha congelado!",
}
const STATUS_ALREADY: Dictionary[StringName, String] = {
	&"par": "¡%s ya está paralizado!",
	&"brn": "¡%s ya está quemado!",
	&"psn": "¡%s ya está envenenado!",
	&"tox": "¡%s ya está envenenado!",
	&"slp": "¡%s ya está dormido!",
	&"frz": "¡%s ya está congelado!",
}
const STATUS_CURED: Dictionary[StringName, String] = {
	&"par": "¡%s ya no está paralizado!",
	&"brn": "¡%s ya no está quemado!",
	&"psn": "¡%s ya no está envenenado!",
	&"tox": "¡%s ya no está envenenado!",
	&"slp": "¡%s se ha despertado!",
	&"frz": "¡%s ya no está congelado!",
}
const CATCH_FAIL: Array[String] = [
	"¡Oh, no! ¡El Pokémon se ha escapado!",
	"¡Vaya! ¡Parecía que lo habías atrapado!",
	"¡Qué rabia! ¡Ha faltado muy poco!",
	"¡Mecachis! ¡Casi lo consigues!",
]


## "Pikachu", "el Pidgey salvaje" o "el Pidgey enemigo".
static func name_of(b: Battler, wild: bool) -> String:
	var n := b.pokemon.display_name()
	if b.side == 0:
		return n
	return t("el %s salvaje") % n if wild else t("el %s enemigo") % n


## Igual, con mayúscula inicial (para empezar frase).
static func cap_name(b: Battler, wild: bool) -> String:
	return capitalize(name_of(b, wild))


## "a Pikachu" / "al Pidgey salvaje".
static func to_name(b: Battler, wild: bool) -> String:
	var n := name_of(b, wild)
	return "al " + n.substr(3) if n.begins_with("el ") else "a " + n


## "de Pikachu" / "del Pidgey salvaje".
static func of_name(b: Battler, wild: bool) -> String:
	var n := name_of(b, wild)
	return "del " + n.substr(3) if n.begins_with("el ") else "de " + n


## tr() para funciones estáticas.
static func t(text: String) -> String:
	return String(TranslationServer.translate(text))


static func capitalize(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1) if text != "" else text


static func stat_change(b: Battler, wild: bool, stat: StringName, amount: int) -> String:
	var verb: String
	if amount > 0:
		verb = "subió" if amount == 1 else ("subió mucho" if amount == 2 else "subió muchísimo")
	else:
		verb = "bajó" if amount == -1 else ("bajó mucho" if amount == -2 else "bajó muchísimo")
	return "¡%s %s!" % [_stat_subject(b, wild, stat), t(verb)]


static func stat_limit(b: Battler, wild: bool, stat: StringName, rising: bool) -> String:
	return "¡%s %s!" % [_stat_subject(b, wild, stat), t("no puede subir más") if rising else t("no puede bajar más")]


## "El Ataque de Pikachu", "La Defensa del Pidgey salvaje".
static func _stat_subject(b: Battler, wild: bool, stat: StringName) -> String:
	return capitalize(t(STAT_NAMES.get(stat, String(stat))) + " " + of_name(b, wild))


static func money_won(amount: int) -> String:
	return t("¡Has ganado %d %s!") % [amount, CURRENCY]
