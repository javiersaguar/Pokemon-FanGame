# Registro de flags y variables

Todas las claves de `GameState.flags` y `GameState.vars` van aquí **antes** de usarse. Dueño del archivo: Agente 1. Los demás agentes añaden sus filas (solo las suyas).

## Patrones reservados

| Patrón | Se activa en | Efecto | Dueño |
|--------|--------------|--------|-------|
| `trainer_defeated:<trainer_id>` | Al ganar a ese entrenador | Ya no te ve; dice su `after_text` | Agente 3 |
| `item_taken:<map_id>:<nodo>` | Al recoger un objeto del suelo | El objeto no vuelve a aparecer | Agente 1 |

## Flags

| Clave | Se activa en | Efecto |
|-------|--------------|--------|

## Variables

| Clave | Valores | Notas |
|-------|---------|-------|
| `story_progress` | 0, 10, 20... | Avance de la historia (valores espaciados para poder insertar pasos) |
| `repel_steps` | 0+ | Pasos de Repelente que quedan (la pone el objeto; la descuenta `WildEncounters`) |
