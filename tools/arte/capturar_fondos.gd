extends SceneTree
## Capturas reales de la pantalla de combate con cada fondo (dos Pokémon y las cajas de datos), y
## las del fondo de hierba en los cuatro momentos del día, en docs/arte/comparativas/fondos_combate/.
## También compone, al lado de anil_combate.png, la comparativa de unas cuantas (Añil a la izquierda).
##   godot --path . -s res://tools/arte/capturar_fondos.gd [-- --solo=<escena>]

const OUT := "res://docs/arte/comparativas/fondos_combate/"
const ANIL := "res://docs/arte/referencias/anil_combate.png"
const PERIODS: Array[StringName] = [&"morning", &"day", &"evening", &"night"]
## Escenas con comparativa al lado de Añil (una de cada tipo: exterior, ciudad, gimnasio y Liga).
const COMPARE := ["hierba", "ciudad", "gimnasio_madrid", "liga"]
## Escena → [Pokémon del jugador, rival].
const CAST := {
	"hierba": ["charizard", "eevee"], "bosque": ["venusaur", "pikachu"], "olivar": ["lucario", "eevee"],
	"palmeral": ["garchomp", "sandaconda"], "montana": ["lucario", "onix"], "nieve": ["blastoise", "abomasnow"],
	"playa": ["blastoise", "gyarados"], "desierto": ["garchomp", "sandaconda"], "agua": ["lapras", "gyarados"],
	"ciudad": ["pikachu", "snorlax"], "cueva": ["lucario", "onix"], "cueva_oscura": ["gengar", "umbreon"],
	"casa": ["eevee", "pikachu"], "edificio": ["pikachu", "snorlax"], "monumento": ["togekiss", "gengar"],
	"gimnasio_madrid": ["blastoise", "charizard"], "gimnasio_barcelona": ["charizard", "lucario"],
	"gimnasio_valencia": ["venusaur", "blastoise"], "gimnasio_sevilla": ["gengar", "togekiss"],
	"gimnasio_playa_del_ingles": ["venusaur", "lapras"], "gimnasio_bilbao": ["lucario", "onix"],
	"gimnasio_valladolid": ["charizard", "abomasnow"], "gimnasio_malaga": ["lucario", "umbreon"],
	"liga": ["dragonite", "garchomp"], "liga_campeon": ["charizard", "dragonite"],
}

var _only := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--solo="):
			_only = arg.trim_prefix("--solo=")
	root.size = Vector2i(512, 384)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var anil := Image.load_from_file(ProjectSettings.globalize_path(ANIL))
	anil.convert(Image.FORMAT_RGBA8)
	for id: StringName in BattleBackgrounds.scene_ids():
		if _only != "" and String(id) != _only:
			continue
		var shot := await _capture(id, &"day")
		shot.save_png(OUT + String(id) + ".png")
		if String(id) in COMPARE:
			_side_by_side(anil, shot).save_png(OUT + String(id) + "_vs_anil.png")
		print("Captura: %s%s.png" % [OUT, id])
	if _only == "" or _only == "hierba":
		for p: StringName in PERIODS:
			var shot := await _capture(&"hierba", p)
			shot.save_png(OUT + "hierba_" + String(p) + ".png")
		var city := await _capture(&"ciudad", &"night")
		city.save_png(OUT + "ciudad_night.png")
	quit()


func _capture(id: StringName, period: StringName) -> Image:
	var cast: Array = CAST.get(String(id), ["charizard", "eevee"])
	var screen: Control = load("res://src/battle/scene/battle_scene.tscn").instantiate()
	root.add_child(screen)
	screen._background.set_environment(id, period)
	screen._apply_bases()
	screen.get_node("Canvas/Curtain").hide()
	screen._player_sprite.set_pokemon({"species": StringName(cast[0])})
	screen._foe_sprite.set_pokemon({"species": StringName(cast[1])})
	screen._player_box.show_pokemon({"name": String(cast[0]).capitalize(), "level": 50, "hp": 150, "max_hp": 150})
	screen._foe_box.show_pokemon({"name": String(cast[1]).capitalize(), "level": 50, "hp": 100, "max_hp": 100})
	screen._player_box.show()
	screen._foe_box.show()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	screen.queue_free()
	await process_frame
	return image


func _side_by_side(anil: Image, ours: Image) -> Image:
	var out := Image.create_empty(anil.get_width() + 16 + ours.get_width(), maxi(anil.get_height(), ours.get_height()), false, Image.FORMAT_RGBA8)
	out.fill(Color(1, 1, 1))
	out.blit_rect(anil, Rect2i(Vector2i.ZERO, anil.get_size()), Vector2i.ZERO)
	out.blit_rect(ours, Rect2i(Vector2i.ZERO, ours.get_size()), Vector2i(anil.get_width() + 16, 0))
	return out
