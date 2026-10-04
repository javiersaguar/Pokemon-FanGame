class_name JsonFile
extends RefCounted
## Lectura de archivos JSON con errores claros (ruta y línea).


## Devuelve el contenido del JSON o `null` si no existe o no se puede leer.
static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JsonFile: no existe el archivo '%s'." % path)
		return null
	var json := JSON.new()
	var err := json.parse(FileAccess.get_file_as_string(path))
	if err != OK:
		push_error("JsonFile: '%s' no es un JSON válido (línea %d): %s" % [
			path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data


## Como `read()`, pero garantiza un Dictionary (vacío si falla).
static func read_dict(path: String) -> Dictionary:
	var data: Variant = read(path)
	if data is Dictionary:
		return data
	if data != null:
		push_error("JsonFile: '%s' debería contener un objeto JSON." % path)
	return {}
