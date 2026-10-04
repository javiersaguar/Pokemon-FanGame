class_name TrainerData
extends RefCounted
## Lectura de data/trainer_classes.json y data/trainers/*.json (contratos.md §9.6).
## get_trainer() devuelve el entrenador ya combinado con su clase.

const CLASSES_PATH := "res://data/trainer_classes.json"
const TRAINERS_DIR := "res://data/trainers/"

static var _classes: Dictionary = {}
static var _trainers: Dictionary = {}
static var _loaded := false


static func reload() -> void:
	_classes = JsonFile.read_dict(CLASSES_PATH)
	_trainers = {}
	for file: String in DirAccess.get_files_at(TRAINERS_DIR):
		if not file.ends_with(".json"):
			continue
		var trainers := JsonFile.read_dict(TRAINERS_DIR + file)
		for id: String in trainers:
			if id.begins_with("_"):
				continue
			if _trainers.has(id):
				push_error("TrainerData: el entrenador '%s' está repetido (%s)." % [id, file])
			_trainers[id] = trainers[id]
	_loaded = true


static func exists(trainer_id: StringName) -> bool:
	_ensure_loaded()
	return _trainers.has(String(trainer_id))


static func get_trainer_class(class_id: StringName) -> Dictionary:
	_ensure_loaded()
	if not _classes.has(String(class_id)):
		push_error("TrainerData: no existe la clase de entrenador '%s'." % class_id)
		return {}
	return _classes[String(class_id)]


## El entrenador con los campos de su clase resueltos:
## display_name ("Vendedor de Chupachups Manolo"), class_name, gender,
## battle_sprite, overworld_sprite, intro_bgm, battle_bgm, ai_level y base_money.
static func get_trainer(trainer_id: StringName) -> Dictionary:
	_ensure_loaded()
	if not _trainers.has(String(trainer_id)):
		push_error("TrainerData: no existe el entrenador '%s'." % trainer_id)
		return {}
	var trainer: Dictionary = (_trainers[String(trainer_id)] as Dictionary).duplicate(true)
	var cls := get_trainer_class(StringName(trainer.get("class", "")))
	var gender := str(trainer.get("gender", cls.get("gender", "male")))
	var female := gender == "female"
	var name := Dialogue.format_text(str(trainer.get("name", "")))
	var class_label := str(cls.get("name", ""))
	trainer["id"] = String(trainer_id)
	trainer["name"] = name
	trainer["gender"] = gender
	trainer["class_name"] = class_label
	trainer["display_name"] = ("%s %s" % [class_label, name]).strip_edges()
	trainer["battle_sprite"] = cls.get("battle_sprite_female" if female else "battle_sprite",
		cls.get("battle_sprite", ""))
	trainer["overworld_sprite"] = cls.get("overworld_sprite_female" if female else "overworld_sprite",
		cls.get("overworld_sprite", ""))
	for key: String in ["intro_bgm", "battle_bgm", "ai_level", "base_money"]:
		if not trainer.has(key) and cls.has(key):
			trainer[key] = cls[key]
	return trainer


static func _ensure_loaded() -> void:
	if not _loaded:
		reload()
