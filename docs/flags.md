# Registro de flags y variables

Todas las claves de `GameState.flags` y `GameState.vars` van aquí **antes** de usarse. Dueño del archivo: Agente 1. Los demás agentes añaden sus filas (solo las suyas).

## Patrones reservados

| Patrón | Se activa en | Efecto | Dueño |
|--------|--------------|--------|-------|
| `trainer_defeated:<trainer_id>` | Al ganar a ese entrenador | Ya no te ve; dice su `after_text` | Agente 3 |
| `static_done:<static_id>` | KO/captura de estático | Evita repetir hasta evento de reaparición autorizado | Agente 1 |
| `visited_map:<map_id>` | Al cargar mapa | Registro de visitas para vuelo | Agente 1 |
| `item_taken:<map_id>:<nodo>` | Al recoger un objeto del suelo | El objeto no vuelve a aparecer | Agente 1 |

## Flags

| Clave | Se activa en | Efecto |
|-------|--------------|--------|
| `story_intro_done` | Intro del profesor | Identidad elegida, habitación preparada |
| `story_bedroom_done` | Salir de la habitación | Introducción del laboratorio disponible |
| `story_lab_intro_done` | Profesor en laboratorio | Tres Poké Balls disponibles |
| `starter_chosen` | Inicial incorporado (tras mote si procede) | Oculta las otras dos Poké Balls |
| `rival_intro_done` | Ganar o perder tutorial | Rival deja de desafiar; profesor da recompensas |
| `got_pokedex` | Profesor tras rival | Habilita Pokédex |
| `story_rewards_done` | Regalo incorporado | Evita duplicar recompensa |
| `test_trigger_done` | Disparador de prueba | Evita repetirlo |

## Variables

| Clave | Valores | Notas |
|-------|---------|-------|
| `transport` | walk/bike/surf | Modo de movimiento; sprite obligatorio para activar bike/surf |
| `story_progress` | 0, 10, 20... | Avance de la historia (valores espaciados para poder insertar pasos) |
| `starter` | 1, 2, 3 | Índice elegido; rival por ID en world.mvp_story |
| `repel_steps` | 0+ | Pasos de Repelente que quedan (la pone el objeto; la descuenta `WildEncounters`) |
