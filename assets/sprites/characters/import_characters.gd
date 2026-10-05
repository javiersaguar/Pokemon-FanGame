extends SceneTree
## Copia del pack 05_ultimate_gen4_overworlds (PurpleZaffre) los personajes del mapa
## y los efectos que usa el juego. Se copian tal cual: ya vienen a ×2 (cuadros de
## 64 px, 4 columnas = pasos × 4 filas = abajo, izquierda, derecha, arriba).
## No se modifica nada del pack. Créditos en CREDITOS.md.
## Uso: godot --headless --path . -s res://assets/sprites/characters/import_characters.gd \
##        [-- --recursos=/mnt/c/Users/Javier/Pokemon-Panchito-recursos]

const DEFAULT_RESOURCES := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
const PACK := "05_ultimate_gen4_overworlds/Ultimate Gen 4 Overworlds Pack/"
const OUT := "res://assets/sprites/characters/"

## destino (sin .png) → archivo del pack
const CHARACTERS := {
	"player_male": "All Official Overworlds/NPC_203_Ethan.png",
	"player_male_run": "All Official Overworlds/NPC_203_Ethan_run.png",
	"player_female": "All Official Overworlds/NPC_206_Lyra.png",
	"player_female_run": "All Official Overworlds/NPC_206_Lyra_run.png",
	"player_male_bike": "All Official Overworlds/NPC_203_Ethan_bike.png",
	"player_female_bike": "All Official Overworlds/NPC_206_Lyra_bike.png",
	"player_male_surf": "All Official Overworlds/NPC_203_Ethan_surf.png",
	"player_female_surf": "All Official Overworlds/NPC_206_Lyra_surf.png",
	"player_male_fishing": "All Official Overworlds/NPC_203_Ethan_fishing.png",
	"player_female_fishing": "All Official Overworlds/NPC_206_Lyra_fishing.png",
	"professor": "All Official Overworlds/NPC_137_Prof_Elm.png",
	"mom": "All Official Overworlds/NPC_126_Mom.png",
	"nurse": "All Official Overworlds/NPC_115_Nurse_1.png",
	"clerk": "All Official Overworlds/NPC_113_Mart_M.png",
	"trainer": "All Official Overworlds/NPC_001_Ace_Trainer_M.png",
	"npc_youngster": "All Official Overworlds/NPC_023_Youngster.png",
	"npc_lass": "All Official Overworlds/NPC_025_Lass.png",
	"npc_fisherman": "All Official Overworlds/NPC_068_Fisherman.png",
	"npc_kimono_girl": "All Official Overworlds/NPC_071_Kimono_Girl.png",
	"npc_old_man": "All Official Overworlds/NPC_100.png",
	"npc_old_woman": "All Official Overworlds/NPC_101.png",
	"npc_man": "All Official Overworlds/NPC_119.png",
	"npc_woman": "All Official Overworlds/NPC_108.png",
	"npc_boy": "All Official Overworlds/NPC_106.png",
	"npc_girl": "All Official Overworlds/NPC_107.png",
	"objects": "All Official Overworlds/Object_Various.png",
	"effects/exclamation": "Animations & Others/Exclamation.png",
	"effects/grass_rustle": "Animations & Others/GrassDP1.png",
	"effects/shiny_sparkles": "Animations & Others/Sparkles1.png",
	"effects/jump_dust": "Animations & Others/AfterJumpDust.png",
	"effects/water_splash": "Animations & Others/Splash.png",
}


func _initialize() -> void:
	var resources := DEFAULT_RESOURCES
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--recursos="):
			resources = arg.get_slice("=", 1)
	var base := resources.path_join(PACK)
	var copied := 0
	for id: String in CHARACTERS:
		var src := base.path_join(CHARACTERS[id])
		var dst := ProjectSettings.globalize_path(OUT + id + ".png")
		DirAccess.make_dir_recursive_absolute(dst.get_base_dir())
		var err := DirAccess.copy_absolute(src, dst)
		if err != OK:
			push_error("import_characters: no se pudo copiar '%s' (%s)." % [src, error_string(err)])
		else:
			copied += 1
	print("import_characters: %d de %d archivos copiados en %s" % [copied, CHARACTERS.size(), OUT])
	quit()
