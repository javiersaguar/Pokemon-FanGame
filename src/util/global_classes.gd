class_name GlobalClasses
extends RefCounted
## Busca clases globales (class_name) por nombre en tiempo de ejecución. Sirve para
## usar clases de otros agentes que quizá aún no existen sin romper la compilación.


## Script de la clase `global_name`, o null si no existe.
static func find(global_name: StringName) -> Script:
	for info: Dictionary in ProjectSettings.get_global_class_list():
		if info["class"] == global_name:
			return load(info["path"])
	return null


static func exists(global_name: StringName) -> bool:
	return find(global_name) != null


## true si `script` (o una clase de la que hereda) declara la función `method`.
static func has_function(script: Script, method: StringName) -> bool:
	for info: Dictionary in script.get_script_method_list():
		if info["name"] == method:
			return true
	return false
