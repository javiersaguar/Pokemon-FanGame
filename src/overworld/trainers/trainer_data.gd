class_name TrainerData
extends RefCounted
## Entrenadores de data/trainers/*.json combinados con su clase de
## data/trainer_classes.json (contratos.md §9.6). Los datos en bruto los carga DataDB.


static func exists(trainer_id: StringName) -> bool:
	return DataDB.has_trainer(trainer_id)


static func get_trainer_class(class_id: StringName) -> Dictionary:
	return DataDB.trainer_class(class_id)


## El entrenador con los campos de su clase resueltos:
## display_name ("Vendedor de Chupachups Manolo"), class_name, gender,
## battle_sprite, overworld_sprite, real_photo (ruta de la foto real o ""), intro_bgm, battle_bgm,
## ai_level y base_money.
static func get_trainer(trainer_id: StringName) -> Dictionary:
	var raw := DataDB.trainer(trainer_id)
	if raw.is_empty():
		return {}
	var trainer: Dictionary = raw.duplicate(true)
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
	# Foto real del personaje, si Javier la ha puesto (RealPhoto): por id del entrenador o de su clase.
	trainer["real_photo"] = RealPhoto.find_path([trainer_id, trainer.get("class", "")])
	for key: String in ["intro_bgm", "battle_bgm", "ai_level", "base_money"]:
		if not trainer.has(key) and cls.has(key):
			trainer[key] = cls[key]
	return trainer
