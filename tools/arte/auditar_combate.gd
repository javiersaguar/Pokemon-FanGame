extends SceneTree
## Estado reproducible del catálogo; no equivale a certificación de efectos completos.
func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var dir := String(args[0]) if args.size() else "res://docs/arte/cobertura_combate"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var report: Dictionary = load("res://tools/arte/auditar_combate_runtime.gd").new().report()
	var file := FileAccess.open(dir+"/estado.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report," "))
	file.close()
	var abilities := FileAccess.open(dir+"/habilidades.csv",FileAccess.WRITE)
	abilities.store_csv_line(PackedStringArray(["id","numero","nombre","nombre_ingles","efecto_registrado","requiere_script","descripcion_presente","especies"]))
	for row: Dictionary in report.abilities:
		abilities.store_csv_line(PackedStringArray([row.id,str(row.num),row.name,row.name_en,str(row.effect_registered),str(row.needs_script),str(row.description_present)," ".join(row.species)]))
	abilities.close()
	var moves := FileAccess.open(dir+"/movimientos.csv",FileAccess.WRITE)
	moves.store_csv_line(PackedStringArray(["id","nombre","tipo","requiere_script","efecto_registrado","animacion_propia"]))
	for row: Dictionary in report.moves:
		moves.store_csv_line(PackedStringArray([row.id,row.name,row.type,str(row.needs_script),str(row.effect_registered),str(row.specific_animation)]))
	moves.close()
	print(JSON.stringify(report.summary))
	quit()
