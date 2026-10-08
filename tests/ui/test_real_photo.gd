extends GutTest
## Fotos reales de los personajes en combate (RealPhoto, decisión de Javier).

const DIR := "user://fotos_reales/"
const PHOTO := "user://fotos_reales/ayuso.png"

var _before := true


func before_each() -> void:
	UiPreferences.initialize()
	_before = UiPreferences.real_photos()
	UiPreferences.set_value("real_photos", true, false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	var image := Image.create_empty(300, 400, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.3, 0.3))
	image.save_png(ProjectSettings.globalize_path(PHOTO))


func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PHOTO))
	UiPreferences.set_value("real_photos", _before, false)


func test_el_entrenador_lleva_su_foto_si_existe() -> void:
	var trainer := TrainerData.get_trainer(&"ayuso")
	assert_eq(trainer.get("real_photo"), PHOTO)
	assert_eq(TrainerData.get_trainer(&"laporta").get("real_photo"), "", "sin foto, ruta vacía")


func test_la_foto_cabe_sin_deformarse() -> void:
	var texture := RealPhoto.load_texture(PHOTO)
	assert_not_null(texture)
	var scale := RealPhoto.fit_scale(texture)
	assert_almost_eq(scale.x, scale.y, 0.0001)
	assert_lte(texture.get_height() * scale.y, RealPhoto.MAX_SIZE.y + 0.01)
	assert_lte(texture.get_width() * scale.x, RealPhoto.MAX_SIZE.x + 0.01)


func test_desde_opciones_se_pueden_quitar() -> void:
	UiPreferences.set_value("real_photos", false, false)
	assert_eq(RealPhoto.find_path([&"ayuso"]), "")
	assert_eq(TrainerData.get_trainer(&"ayuso").get("real_photo"), "")


func test_sin_ids_no_busca_nada() -> void:
	assert_eq(RealPhoto.find_path([]), "")
	assert_eq(RealPhoto.find_path([""]), "")
	assert_null(RealPhoto.load_texture(""))
