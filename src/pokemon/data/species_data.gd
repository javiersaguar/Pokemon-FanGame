class_name SpeciesData
extends RefCounted
## Datos fijos de una especie o forma: data/generated/species.json + data/species_overrides.json.
## Las formas son especies propias ("raichualola", "charizardmegax") con `base_species`.
## Contrato: docs/contratos.md (sección DataDB).

const STATS: Array[StringName] = [&"hp", &"atk", &"def", &"spa", &"spd", &"spe"]

var id: StringName
var num: int
var name: String
var name_en: String
## Especie base si es una forma ("raichu" para "raichualola"); vacío si no lo es.
var base_species: StringName
var forme: StringName
## Nombre de la forma en español ("Forma de Alola"); vacío si no es una forma.
var form_name: String
var types: Array[StringName] = []
var base_stats: Dictionary[StringName, int] = {}
## PS máximos fijos (Shedinja = 1); 0 = se calculan con la fórmula normal.
var fixed_max_hp: int = 0
## Ranura -> habilidad: "0", "1", "H" (oculta) y "S" (especial).
var abilities: Dictionary[String, StringName] = {}
## Probabilidad de ser hembra (0..1); -1 = sin sexo.
var gender_ratio: float = 0.5
var catch_rate: int = 45
var base_exp: int = 0
var exp_group: StringName = &"medium_fast"
var ev_yield: Dictionary[StringName, int] = {}
var egg_groups: Array[StringName] = []
var egg_cycles: int = 0
var hatch_steps: int = 0
var base_friendship: int = 50
var height: float = 0.0
var weight: float = 0.0
var color: StringName
var genus: String
var generation: int = 0
var prevo: StringName
## Cada entrada: {to, method, level?, item?, move?, time?, gender?, ...} (ver contrato).
var evolutions: Array[Dictionary] = []
var forms: Array[StringName] = []
var is_mega: bool = false
var is_gmax: bool = false
var required_item: StringName
var is_legendary: bool = false
var is_mythical: bool = false
var is_baby: bool = false
var tags: Array[StringName] = []
## "", "past", "future", "lgpe", "unobtainable"... (isNonstandard de Showdown).
var nonstandard: StringName
var learnset_id: StringName
var dex_entry: String
## Entrada original completa, para campos sin propiedad propia.
var raw: Dictionary = {}


static func from_dict(species_id: StringName, d: Dictionary) -> SpeciesData:
	var s := SpeciesData.new()
	s.id = species_id
	s.raw = d
	s.num = int(d.get("num", 0))
	s.name = str(d.get("name", species_id))
	s.name_en = str(d.get("name_en", ""))
	s.base_species = StringName(d.get("base_species", ""))
	s.forme = StringName(d.get("forme", ""))
	s.form_name = str(d.get("form_name", ""))
	s.types = DataUtil.names(d.get("types", []))
	s.base_stats = DataUtil.int_dict(d.get("base_stats", {}))
	s.fixed_max_hp = int(d.get("max_hp", 0))
	for slot: String in d.get("abilities", {}):
		s.abilities[slot] = StringName(d["abilities"][slot])
	s.gender_ratio = float(d.get("gender_ratio", 0.5))
	s.catch_rate = int(d.get("catch_rate", 45))
	s.base_exp = int(d.get("base_exp", 0))
	s.exp_group = StringName(d.get("exp_group", "medium_fast"))
	s.ev_yield = DataUtil.int_dict(d.get("ev_yield", {}))
	s.egg_groups = DataUtil.names(d.get("egg_groups", []))
	s.egg_cycles = int(d.get("egg_cycles", 0))
	s.hatch_steps = int(d.get("hatch_steps", 0))
	s.base_friendship = int(d.get("base_friendship", 50))
	s.height = float(d.get("height", 0.0))
	s.weight = float(d.get("weight", 0.0))
	s.color = StringName(d.get("color", ""))
	s.genus = str(d.get("genus", ""))
	s.generation = int(d.get("generation", 0))
	s.prevo = StringName(d.get("prevo", ""))
	for evo: Dictionary in d.get("evolutions", []):
		s.evolutions.append(evo)
	s.forms = DataUtil.names(d.get("forms", []))
	s.is_mega = bool(d.get("is_mega", false))
	s.is_gmax = bool(d.get("is_gmax", false))
	s.required_item = StringName(d.get("required_item", ""))
	s.is_legendary = bool(d.get("is_legendary", false))
	s.is_mythical = bool(d.get("is_mythical", false))
	s.is_baby = bool(d.get("is_baby", false))
	s.tags = DataUtil.names(d.get("tags", []))
	s.nonstandard = StringName(d.get("nonstandard", ""))
	s.learnset_id = StringName(d.get("learnset", ""))
	s.dex_entry = str(d.get("dex_entry", ""))
	return s


func base_stat(stat: StringName) -> int:
	return base_stats.get(stat, 0)


func is_genderless() -> bool:
	return gender_ratio < 0.0


func is_form() -> bool:
	return base_species != &""


## Id de la especie sin forma ("raichu" para "raichualola").
func root_species() -> StringName:
	return base_species if is_form() else id


func has_type(type: StringName) -> bool:
	return type in types


func ability(slot: String) -> StringName:
	return abilities.get(slot, &"")


func has_hidden_ability() -> bool:
	return abilities.has("H")
