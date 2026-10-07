class_name RandomlockeGeneratingScreen
extends MenuScreen
var elapsed := 0.0
var status: Label
static func generate(settings: Dictionary, seed_value: int) -> RomPatch:
	var screen := RandomlockeGeneratingScreen.new()
	SceneManager.push_menu(screen)
	var job := RandomlockeJob.new()
	screen.add_child(job)
	var error := job.start(settings,seed_value)
	var rom: RomPatch = null
	if error == OK: rom = await job.finished
	SceneManager.pop_menu(screen)
	return rom
func _ready() -> void:
	heading.text = "RandomLocke"
	panel(Rect2(16,55,224,96))
	status = label("Generando la ROM...",Rect2(24,75,208,22),Color("382a38"))
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var explanation := label("",Rect2(28,109,200,34),Color("382a38"),8)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.text = "Preparando Pokémon, encuentros y reglas.\nPuedes revisar el resultado antes de empezar."
	hint.text = "Generación en curso / espera un momento"
func _process(delta: float) -> void:
	if UiPreferences.reduce_motion():
		status.text = "Generando la ROM..."
		return
	elapsed += delta
	status.text = "Generando la ROM"+".".repeat(1+int(elapsed*3)%3)
