extends Node
## Partidas guardadas: varias ranuras independientes (Fase 8.7), normal o
## RandomLocke. Contrato: docs/contratos.md (sección SaveManager).
##
## Archivos de la ranura n (en user://saves/):
##   slot_<n>.json      {save_version, game_version, saved_at, summary, state}
##                      con state = GameState.to_dict()
##   slot_<n>.png       miniatura (el mundo a 256×192, sin la interfaz)
##   slot_<n>.rom.json  parche de la ROM del RandomLocke (Fase R.1)
##   index.json         {"last_slot": n} para "Continuar"
## Escritura segura: se escribe a .tmp, la versión anterior pasa a .bak y el
## .tmp se renombra. Si el archivo principal está dañado, se carga el .bak.

const SAVE_DIR := "user://saves"
const INDEX_PATH := "user://saves/index.json"
## Ranuras si data/world.json → saves.slots no dice otra cosa (mínimo 8).
const DEFAULT_SLOT_COUNT := 8
const THUMBNAIL_SIZE := Vector2i(256, 192)


func slot_count() -> int:
	var cfg: Dictionary = GameState.world_config.get("saves", {})
	return maxi(int(cfg.get("slots", DEFAULT_SLOT_COUNT)), 1)


func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func thumbnail_path(slot: int) -> String:
	return "%s/slot_%d.png" % [SAVE_DIR, slot]


func rom_patch_path(slot: int) -> String:
	return "%s/slot_%d.rom.json" % [SAVE_DIR, slot]


func has_save(slot: int) -> bool:
	var path := slot_path(slot)
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")


## Ranura de la partida en curso; si no hay, la 1.
func current_slot() -> int:
	return GameState.slot if GameState.slot > 0 else 1


## Primera ranura vacía (0 si están todas ocupadas).
func first_empty_slot() -> int:
	for slot: int in range(1, slot_count() + 1):
		if not has_save(slot):
			return slot
	return 0


## Última ranura guardada o cargada (0 si no hay ninguna). La usa "Continuar".
func last_used_slot() -> int:
	var slot := int(_read_json(INDEX_PATH).get("last_slot", 0))
	return slot if slot > 0 and has_save(slot) else 0


## Guarda la partida en `slot` (0 = la ranura en curso). Con la miniatura y, en
## RandomLocke, el parche de la ROM.
func save_game(slot: int = 0) -> Error:
	if GameState.locke != null:
		GameState.locke.sync()
	if slot <= 0:
		slot = current_slot()
	var data := {
		"save_version": GameState.SAVE_VERSION,
		"game_version": str(ProjectSettings.get_setting("application/config/version", "")),
		"saved_at": Time.get_datetime_string_from_system(),
		"summary": _make_summary(),
		"state": GameState.to_dict(),
	}
	var err := _write_safely(slot_path(slot), JSON.stringify(data, "\t"))
	if err == OK and GameState.is_randomlocke():
		err = _write_safely(rom_patch_path(slot), JSON.stringify(GameState.rom_patch))
	if err != OK:
		push_error("SaveManager: no se pudo guardar la ranura %d (%s)." % [slot, error_string(err)])
		return err
	_save_thumbnail(slot)
	GameState.slot = slot
	_set_last_slot(slot)
	EventBus.game_saved.emit(slot)
	return OK


## Restaura GameState desde la ranura (y, en RandomLocke, aplica su ROM en
## DataDB). No cambia de mapa: para entrar en la partida usa
## SceneManager.continue_game(slot).
func load_game(slot: int) -> Error:
	var data := _read_save(slot_path(slot))
	if data.is_empty():
		return ERR_FILE_NOT_FOUND
	data = _migrate(data)
	if data.is_empty():
		return ERR_FILE_UNRECOGNIZED
	var state: Dictionary = data["state"]
	var patch: Dictionary = {}
	if state.get("mode", "normal") == "randomlocke":
		patch = _read_json(rom_patch_path(slot))
		if patch.is_empty():
			patch = _read_json(rom_patch_path(slot) + ".bak")
		if patch.is_empty():
			return ERR_FILE_CORRUPT
		var err := apply_patch_data(patch)
		if err != OK:
			return err
	else:
		DataDB.clear_patch()
	# Solo mutar GameState después de validar/aplicar la ROM atómicamente.
	GameState.rom_patch = patch
	GameState.from_dict(state)
	GameState.slot = slot
	_set_last_slot(slot)
	return OK


## Aplica en DataDB el parche de la partida en curso (o lo quita en modo normal).
func apply_rom_patch() -> Error:
	if GameState.is_randomlocke():
		return apply_patch_data(GameState.rom_patch)
	DataDB.clear_patch()
	return OK

func apply_patch_data(patch: Dictionary) -> Error:
	if patch.is_empty() or not patch.get("errors", []) is Array or not patch.get("errors", []).is_empty():
		return ERR_INVALID_DATA
	for key: String in RomPatch.KEYS:
		if patch.has(key) and not patch[key] is Dictionary:
			return ERR_INVALID_DATA
	if patch.has("settings") and not patch.settings is Dictionary:
		return ERR_INVALID_DATA
	var errors: Array[String] = DataDB.apply_patch(patch)
	return OK if errors.is_empty() else ERR_INVALID_DATA


## Resumen para las pantallas de título y de carga (vacío si la ranura no existe):
## slot, mode, player_name, play_time, badges, dex_seen, dex_caught, money,
## map_id, map_name, party [{species, shiny}], saved_at, thumbnail (ruta o "")
## y, en RandomLocke, seed_code, deaths y status.
func slot_summary(slot: int) -> Dictionary:
	var data := _read_save(slot_path(slot))
	if data.is_empty():
		return {}
	var summary: Dictionary = data.get("summary", {}).duplicate()
	summary["slot"] = slot
	summary["saved_at"] = data.get("saved_at", "")
	summary["thumbnail"] = thumbnail_path(slot) if FileAccess.file_exists(thumbnail_path(slot)) else ""
	return summary


## Resúmenes de todas las ranuras, en orden (un {} por cada ranura vacía).
func list_slots() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for slot: int in range(1, slot_count() + 1):
		out.append(slot_summary(slot))
	return out


## Miniatura de la ranura o null si no tiene.
func thumbnail(slot: int) -> Texture2D:
	var path := thumbnail_path(slot)
	if not FileAccess.file_exists(path):
		return null
	var image := Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image else null


## Copia la ranura `from` en `to` (sobrescribe `to`; la confirmación es cosa de la UI).
func copy_slot(from: int, to: int) -> Error:
	if from == to or not has_save(from):
		return ERR_INVALID_PARAMETER
	delete_save(to)
	var err := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	for pair: Array in [[slot_path(from), slot_path(to)], [thumbnail_path(from), thumbnail_path(to)],
			[rom_patch_path(from), rom_patch_path(to)]]:
		if err == OK and FileAccess.file_exists(pair[0]):
			err = DirAccess.copy_absolute(pair[0], pair[1])
	if err == OK and not FileAccess.file_exists(slot_path(from)):
		err = DirAccess.copy_absolute(slot_path(from) + ".bak", slot_path(to))
	return err


## Borra la ranura entera (la confirmación doble es cosa de la UI).
func delete_save(slot: int) -> void:
	var path := slot_path(slot)
	for file: String in [path, path + ".bak", path + ".tmp", thumbnail_path(slot),
			rom_patch_path(slot), rom_patch_path(slot) + ".bak", rom_patch_path(slot) + ".tmp"]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)


# --- Internos ---

func _make_summary() -> Dictionary:
	var map_name := String(GameState.map_id)
	if SceneManager.current_map:
		map_name = SceneManager.current_map.get_display_name()
	var summary := {
		"mode": String(GameState.mode),
		"player_name": GameState.player_name,
		"player_gender": String(GameState.player_gender),
		"play_time": GameState.play_time,
		"badges": GameState.badges.size(),
		"money": GameState.money,
		"map_id": String(GameState.map_id),
		"map_name": map_name,
		"dex_seen": _call_int(GameState.pokedex, &"seen_count"),
		"dex_caught": _call_int(GameState.pokedex, &"caught_count"),
		"party": _party_icons(),
	}
	if GameState.is_randomlocke():
		summary["seed_code"] = GameState.randomlocke.get("seed_code", "")
		summary["deaths"] = int(GameState.randomlocke.get("deaths", 0))
		summary["status"] = GameState.randomlocke.get("status", "in_progress")
	return summary


func _party_icons() -> Array:
	var out := []
	var party: Variant = GameState.party
	if party is Object and &"members" in party:
		for p: Variant in party.members:
			out.append({"species": String(p.species_id), "shiny": bool(p.shiny)})
	return out


static func _call_int(target: Variant, method: StringName) -> int:
	if target is Object and target.has_method(method):
		return int(target.call(method))
	return 0


## Miniatura del mundo: la última imagen sin interfaz que guardó SceneManager al
## abrir el menú o, si no hay, la pantalla actual. Reducida a la mitad (el mundo
## va a ×2, así que se ve en sus píxeles reales).
func _save_thumbnail(slot: int) -> void:
	var image: Image = SceneManager.world_snapshot
	if image == null:
		image = SceneManager.capture_screen()
	if image == null or image.is_empty():
		return
	image = image.duplicate() as Image
	image.resize(THUMBNAIL_SIZE.x, THUMBNAIL_SIZE.y, Image.INTERPOLATE_NEAREST)
	var err := image.save_png(ProjectSettings.globalize_path(thumbnail_path(slot)))
	if err != OK:
		push_warning("SaveManager: no se pudo guardar la miniatura (%s)." % error_string(err))


func _set_last_slot(slot: int) -> void:
	_write_safely(INDEX_PATH, JSON.stringify({"last_slot": slot}))


func _read_save(path: String) -> Dictionary:
	for file: String in [path, path + ".bak"]:
		var data := _read_json(file)
		if data.has("state") and data["state"] is Dictionary:
			if file != path:
				push_warning("SaveManager: '%s' estaba dañado; se usa la copia .bak." % path)
			return data
		if not data.is_empty():
			push_warning("SaveManager: '%s' no tiene el formato de partida." % file)
	return {}


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not (json.data is Dictionary):
		push_warning("SaveManager: '%s' no es un JSON válido." % path)
		return {}
	return json.data


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
	if _read_json(tmp).is_empty() and text != "{}":
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
			1:
				# v2 añade snapshot Locke/pendientes; WorldLocke restaura el legado sin regenerar la ROM.
				version = 2
				data["save_version"] = version
			_:
				push_error("SaveManager: no hay migración desde save_version %d." % version)
				return {}
	return data
