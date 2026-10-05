class_name RandomlockeJob
extends Node
## El hilo solo recibe datos copiados y devuelve una ROM; nunca toca autoloads.
signal finished(rom: RomPatch)
var _thread: Thread

func start(settings: Dictionary, seed_value: int) -> Error:
	if _thread != null:
		return ERR_BUSY
	RandomizerSettings.prepare()
	var input := RandomizerInput.from_datadb()
	var copied_settings := settings.duplicate(true)
	_thread = Thread.new()
	var err := _thread.start(func() -> RomPatch: return Randomizer.generate(input, copied_settings, seed_value))
	if err != OK:
		_thread = null
	return err

func _process(_delta: float) -> void:
	if _thread != null and not _thread.is_alive():
		var result: RomPatch = _thread.wait_to_finish()
		_thread = null
		finished.emit(result)

func _exit_tree() -> void:
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	_thread = null
