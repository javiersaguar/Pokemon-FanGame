extends Node
## Guardar y cargar la partida en user://saves/slot_<n>.json.
## Contrato: docs/contratos.md (sección SaveManager).
##
## Formato: {save_version, game_version, saved_at, summary, state}, donde
## state = GameState.to_dict(). Escritura segura: se escribe a .tmp, la partida
## anterior pasa a .bak y el .tmp se renombra. Si el archivo principal está
## dañado, se carga el .bak.

const SAVE_DIR := "user://saves"
const SLOT_COUNT := 3


func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_save(slot: int = 1) -> bool:
	var path := slot_path(slot)
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")


func save_game(slot: int = 1) -> Error:
	var data := {
		"save_version": GameState.SAVE_VERSION,
		"game_version": str(ProjectSettings.get_setting("application/config/version", "")),
		"saved_at": Time.get_datetime_string_from_system(),
		"summary": _make_summary(),
		"state": GameState.to_dict(),
	}
	var err := _write_safely(slot_path(slot), JSON.stringify(data, "\t"))
	if err == OK:
		EventBus.game_saved.emit(slot)
	else:
		push_error("SaveManager: no se pudo guardar la ranura %d (%s)." % [slot, error_string(err)])
	return err


## Restaura GameState desde la ranura. No cambia de mapa: para entrar en la
## partida usa SceneManager.continue_game(slot).
func load_game(slot: int = 1) -> Error:
	var data := _read_slot(slot)
	if data.is_empty():
		return ERR_FILE_NOT_FOUND
	data = _migrate(data)
	if data.is_empty():
		return ERR_FILE_UNRECOGNIZED
	GameState.from_dict(data["state"])
	return OK


## Resumen para la pantalla de título o de carga: player_name, play_time,
## badges, money, map_id, map_name y saved_at. Vacío si la ranura no existe.
func slot_summary(slot: int) -> Dictionary:
	var data := _read_slot(slot)
	if data.is_empty():
		return {}
	var summary: Dictionary = data.get("summary", {}).duplicate()
	summary["saved_at"] = data.get("saved_at", "")
	return summary


func delete_save(slot: int) -> void:
	var path := slot_path(slot)
	for file: String in [path, path + ".bak", path + ".tmp"]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)


# --- Internos ---

func _make_summary() -> Dictionary:
	var map_name := String(GameState.map_id)
	if SceneManager.current_map:
		map_name = SceneManager.current_map.get_display_name()
	return {
		"player_name": GameState.player_name,
		"play_time": GameState.play_time,
		"badges": GameState.badges.size(),
		"money": GameState.money,
		"map_id": String(GameState.map_id),
		"map_name": map_name,
	}


func _read_slot(slot: int) -> Dictionary:
	var path := slot_path(slot)
	for file: String in [path, path + ".bak"]:
		var data := _read_save_file(file)
		if not data.is_empty():
			if file != path:
				push_warning("SaveManager: la ranura %d estaba dañada; se usa la copia .bak." % slot)
			return data
	return {}


func _read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		push_warning("SaveManager: '%s' no es un JSON válido." % path)
		return {}
	var data: Variant = json.data
	if data is Dictionary and data.has("state") and data["state"] is Dictionary:
		return data
	push_warning("SaveManager: '%s' no tiene el formato de partida." % path)
	return {}


func _write_safely(path: String, text: String) -> Error:
	var err := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if err != OK:
		return err
	var tmp := path + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	err = file.get_error()
	file.close()
	if err != OK:
		return err
	if _read_save_file(tmp).is_empty():
		return ERR_FILE_CORRUPT
	var backup := path + ".bak"
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup):
			DirAccess.remove_absolute(backup)
		err = DirAccess.rename_absolute(path, backup)
		if err != OK:
			return err
	return DirAccess.rename_absolute(tmp, path)


## Pasa una partida antigua al formato actual. Al subir GameState.SAVE_VERSION,
## añade aquí el paso de la versión anterior a la nueva.
func _migrate(data: Dictionary) -> Dictionary:
	var version := int(data.get("save_version", 0))
	if version > GameState.SAVE_VERSION:
		push_error("SaveManager: la partida es de una versión más nueva (%d)." % version)
		return {}
	while version < GameState.SAVE_VERSION:
		match version:
			_:
				push_error("SaveManager: no hay migración desde save_version %d." % version)
				return {}
	return data
