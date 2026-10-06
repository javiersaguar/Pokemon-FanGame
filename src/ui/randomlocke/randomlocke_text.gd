class_name RandomlockeText
extends RefCounted
const LABELS := {
	"starters": "Iniciales", "wild": "Salvajes", "trainers": "Entrenadores", "keep_type_themes": "Conservar tipos de entrenadores",
	"story_pokemon": "Pokémon de historia", "allow_legendaries": "Permitir legendarios", "learnsets": "Movimientos por nivel",
	"guarantee_stab": "Garantizar STAB", "scaled_power": "Potencia según nivel", "abilities": "Habilidades", "types": "Tipos",
	"base_stats": "Estadísticas", "evolutions": "Evoluciones", "items": "Objetos del mundo", "shops": "Tiendas",
	"similar_strength": "Fuerza similar", "strength_tolerance": "Tolerancia de fuerza (%)", "level_appropriate": "Especies según nivel",
	"no_early_legendaries": "Sin legendarios al inicio", "only_implemented_moves": "Solo movimientos implementados", "locke_rules": "Reglas Locke",
	"gifts": "Regalos", "statics": "Estáticos", "trades": "Intercambios", "trainer_duplicates": "Duplicados en entrenadores",
	"leader_ace": "As de líderes", "rival_starter": "Inicial del rival", "tm_compat": "Compatibilidad MT", "tm_content": "Contenido MT",
	"tutor_compat": "Compatibilidad tutores", "tutor_content": "Contenido tutores", "tm_percent": "Compatibilidad MT (%)",
	"tutor_percent": "Compatibilidad tutores (%)", "shiny_denominator": "Probabilidad shiny (1 entre)", "first_encounter": "Primera captura por zona",
	"permadeath": "Muerte permanente", "nickname_required": "Mote obligatorio", "duplicates_clause": "Cláusula duplicados",
	"shiny_clause": "Cláusula shiny", "gifts_count": "Regalos consumen zona", "statics_count": "Estáticos consumen zona",
	"level_cap": "Tope de nivel", "fixed_battle": "Combate fijo", "battle_items": "Objetos en combate",
	"battle_item_limit": "Límite de objetos por combate", "game_over": "Fin si no quedan Pokémon"
}
const VALUES := {"off": "Sin cambiar", "random": "Aleatorios", "triangle": "Triángulo de tipos", "three_stage": "Tres etapas",
	"per_zone": "Por zona", "global": "Globales", "chaos": "Caos", "type_preference": "Preferencia de tipo",
	"allowed": "Permitidos", "limited": "Limitados", "forbidden": "Prohibidos"}

static func value_text(value: Variant) -> String:
	if value is bool: return "Sí" if value else "No"
	return str(VALUES.get(str(value),str(value)))
static func field_name(key: String) -> String:
	return str(LABELS.get(key,key))
