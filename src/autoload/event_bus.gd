extends Node
## Señales globales. Quien emite no sabe quién escucha.
## Contrato: docs/contratos.md (sección EventBus). Se pueden añadir señales;
## no se quitan ni se renombran sin acuerdo.

@warning_ignore_start("unused_signal")

# --- Mundo ---
## El jugador ha terminado un paso y está en `tile` (coordenadas de casilla).
signal player_stepped(tile: Vector2i)
## Se va a descargar `from_map` para cargar `to_map` (la pantalla ya está en negro).
signal map_will_change(from_map: StringName, to_map: StringName)
## El mapa `map_id` ya está cargado y el jugador colocado (antes del fundido de entrada).
signal map_loaded(map_id: StringName)
## Se ha gastado el último paso de Repelente (GameState var `repel_steps`).
signal repel_wore_off

# --- Combate ---
## `setup` es el BattleSetup del Agente 2.
signal battle_started(setup: Variant)
## `outcome` es uno de los valores de SceneManager.OUTCOME_*.
signal battle_ended(outcome: StringName)

# --- Estado de la partida ---
signal flag_changed(key: StringName, value: bool)
signal var_changed(key: StringName, value: Variant)
signal money_changed(money: int)
signal badge_obtained(badge_id: StringName)
signal new_game_started
signal game_saved(slot: int)
signal game_loaded(slot: int)

# --- Interfaz ---
signal input_lock_changed(locked: bool)
signal menu_opened(menu: Node)
signal menu_closed(menu: Node)
signal dialogue_started
signal dialogue_finished

# --- Tiempo ---
## `period` es uno de los ids de data/world.json → clock.periods.
signal time_period_changed(period: StringName)

@warning_ignore_restore("unused_signal")
