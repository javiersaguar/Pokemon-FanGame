class_name RealPhoto
extends RefCounted
## Fotos reales de los personajes en combate (decisión de Javier, docs/mundo/personajes.md).
## Si existe `fotos_reales/<id>.png` (o .jpg, .jpeg, .webp) en el proyecto o en la carpeta de
## usuario, la escena de combate la enseña en lugar del sprite del entrenador. Las fotos no se
## suben al repositorio: las pone Javier en su copia (assets/fotos_reales/LEEME.md).

const DIRS := ["res://assets/fotos_reales/", "user://fotos_reales/"]
const EXTENSIONS := ["png", "jpg", "jpeg", "webp"]
## Tamaño máximo en pantalla (el sprite de combate mide 160×160; la foto, un poco más).
const MAX_SIZE := Vector2(176, 176)


## Ruta de la primera foto que exista para alguno de los ids (por orden), o "" si no hay.
static func find_path(ids: Array) -> String:
	if not UiPreferences.real_photos():
		return ""
	for id: Variant in ids:
		var name := str(id)
		if name.is_empty():
			continue
		for dir: String in DIRS:
			for ext: String in EXTENSIONS:
				var path := "%s%s.%s" % [dir, name, ext]
				if FileAccess.file_exists(path):
					return path
	return ""


## La foto como textura (se lee el archivo tal cual, sin importarla en Godot), o null.
static func load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)


## Escala para que la foto quepa en MAX_SIZE sin deformarse.
static func fit_scale(texture: Texture2D) -> Vector2:
	if texture == null:
		return Vector2.ONE
	var factor := minf(MAX_SIZE.x / texture.get_width(), MAX_SIZE.y / texture.get_height())
	return Vector2(factor, factor)
