extends GutTest
## Muestra fija de la comparación con Showdown (tools/showdown_diff): combates que coinciden con
## Showdown turno a turno, con sus fotos guardadas en showdown_muestra.json (no hace falta Node).
## Si falla, algo del combate ha dejado de ser fiel al oficial. Si el cambio es intencionado
## (datos nuevos, corrección), rehaz la muestra: node tools/showdown_diff/make_fixture.mjs

const FIXTURE := "res://tests/combate/showdown_muestra.json"


func _same_boosts(a: Dictionary, b: Dictionary) -> bool:
	for k: String in a.keys() + b.keys():
		if int(a.get(k, 0)) != int(b.get(k, 0)):
			return false
	return true


## "" si las dos fotos coinciden; si no, la primera diferencia.
func _diff(sd: Dictionary, ours: Dictionary) -> String:
	if str(sd.get("weather", "")) != str(ours.get("weather", "")):
		return "clima %s / %s" % [sd.get("weather", ""), ours.get("weather", "")]
	for s: int in 2:
		var a_side: Array = sd["sides"][s]
		var b_side: Array = ours["sides"][s]
		for i: int in a_side.size():
			var a: Dictionary = a_side[i]
			var b: Dictionary = b_side[i]
			var who := "P%d #%d" % [s + 1, i + 1]
			if int(a["hp"]) != int(b["hp"]):
				return "%s PS %d / %d" % [who, a["hp"], b["hp"]]
			if str(a["status"]) != str(b["status"]):
				return "%s estado %s / %s" % [who, a["status"], b["status"]]
			if bool(a["active"]) != bool(b["active"]):
				return "%s en el campo %s / %s" % [who, a["active"], b["active"]]
			if bool(a["active"]):
				if not _same_boosts(a.get("boosts", {}), b.get("boosts", {})):
					return "%s cambios %s / %s" % [who, a.get("boosts", {}), b.get("boosts", {})]
				if a.has("speed") and int(a["speed"]) != int(b["speed"]):
					return "%s velocidad %d / %d" % [who, a["speed"], b["speed"]]
	return ""


func test_la_muestra_coincide_con_showdown() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	assert_true(data is Array and not (data as Array).is_empty(), "la muestra existe")
	if not data is Array:
		return
	var runner: Script = load("res://tools/showdown_diff/ours_runner.gd")
	var failures: PackedStringArray = []
	for entry: Dictionary in data:
		var spec: Dictionary = entry["spec"]
		var sd: Dictionary = entry["showdown"]
		var ours: Dictionary = runner.call("run_one", spec)
		var sd_snaps: Array = sd["snapshots"]
		var our_snaps: Array = ours["snapshots"]
		var problem := ""
		if ours["error"] != null:
			problem = str(ours["error"])
		elif our_snaps.size() != sd_snaps.size():
			problem = "turnos: Showdown %d / nuestro %d" % [sd_snaps.size(), our_snaps.size()]
		else:
			for k: int in sd_snaps.size():
				var d := _diff(sd_snaps[k], our_snaps[k])
				if d != "":
					problem = "turno %d: %s" % [int(sd_snaps[k]["turn"]), d]
					break
			if problem == "":
				var d := _diff(sd["final"], ours["final"])
				if d != "":
					problem = "final: " + d
		if problem != "":
			failures.append("%s → %s" % [spec["id"], problem])
	assert_eq(failures.size(), 0, "\n".join(failures))
