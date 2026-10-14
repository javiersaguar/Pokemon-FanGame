extends Node
## Captura la animación de uno o varios movimientos a mitad de su secuencia, sobre un fondo de combate
## real, a 512×384. Necesita ventana (no --headless).
##   godot --path . res://tools/arte/capturar_movimientos.tscn -- <carpeta de salida> <movimiento>...
## (Es una escena para que estén los autoloads: DataDB, UiPreferences...)
## Escribe <carpeta>/<movimiento>.png. Los ataques salen del jugador (abajo) hacia el rival (arriba).

const BACKGROUND := "res://assets/sprites/ui/battle/backgrounds/field.png"


func _ready() -> void:
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("capturar_movimientos: faltan la carpeta de salida y los movimientos")
		get_tree().quit(1)
		return
	var out := args[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var stage := Node2D.new()
	add_child(stage)
	var back := Sprite2D.new()
	back.centered = false
	back.texture = load(BACKGROUND if ResourceLoader.exists(BACKGROUND) else "res://assets/sprites/ui/battle/backgrounds/city.png")
	back.name = "Background"
	stage.add_child(back)
	var foe := BattlePokemonSprite.new()
	foe.position = Vector2(384, 204)
	stage.add_child(foe)
	foe.set_pokemon({"species": &"gengar"})
	foe.show()
	var player := BattlePokemonSprite.new()
	player.back = true
	player.position = Vector2(128, 384)
	stage.add_child(player)
	player.set_pokemon({"species": &"charizard"})
	player.show()
	var fx := Node2D.new()
	fx.name = "Fx"
	stage.add_child(fx)
	for id: String in args.slice(1):
		var spec := BattleMoveAnimation.sequence(StringName(id))
		if spec.is_empty():
			print("%s: sin secuencia" % id)
			continue
		var move := DataDB.move(StringName(id))
		var running := [true]
		var play := func() -> void:
			await BattleMoveAnimation.play(fx, player, foe, {"move": StringName(id), "type": move.type}, false)
			running[0] = false
		play.call()
		# El momento central: la primera fase a media duración, después del movimiento del atacante.
		var phases: Array = spec.get("phases", [spec])
		var pre := 0.15 if spec.has("backdrop") or spec.has("backdrop_asset") else 0.0
		match str(spec.get("user_motion", "")):
			"lunge", "flash": pre += 0.25
			"quick": pre += 0.12
			"sway", "hop": pre += float(spec.duration) * 0.65
		var wait := pre + float(phases[0].get("duration", spec.duration)) * 0.5
		await get_tree().create_timer(wait).timeout
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [out, id]))
		print("%s: %s" % [id, move.name])
		while running[0]:
			await get_tree().process_frame
		await get_tree().create_timer(0.1).timeout
	get_tree().quit()
