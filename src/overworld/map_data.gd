class_name MapData
extends Resource
## Datos de un mapa. Cada escena de mapa tiene uno en MapRoot.data.

## Debe coincidir con la ruta de la escena dentro de maps/ sin extensión
## (maps/pueblo_inicial/exterior.tscn → &"pueblo_inicial/exterior").
## Si se deja vacío, se deduce de la ruta.
@export var id: StringName
## Conexiones sin fundido por los bordes; puertas/escaleras siguen usando Warp.
@export var connections: Array[MapConnection] = []
## Nombre del cartel al entrar ("Ruta 1").
@export var display_name: String
## Id de la pista para AudioManager.play_bgm(). Vacío = no cambia la música.
@export var bgm: StringName
## Afecta al tinte día/noche.
@export var outdoor := true
@export var weather: StringName = &"none"
## Id del JSON de data/encounters/ (sin extensión). Vacío = sin encuentros.
@export var encounter_table: StringName
## Zona compartida por plantas/mapas para primera captura; vacío usa tabla o ID del mapa.
@export var zone_id: StringName
## Probabilidad de encuentro por paso en hierba alta. 0 = la de data/world.json
## (encounters.step_chance).
@export_range(0.0, 1.0, 0.01) var encounter_rate := 0.0
@export var battle_background: StringName
@export var region_map_position: Vector2i
@export var can_fly_from := true
@export var can_bike := true
## Permiso de correr. Interiores pequeños (fixed_camera y outdoor=false) no corren.
@export var can_run := true
## Centro Pokémon al que vuelves si pierdes aquí sin haber curado antes en otro.
@export var healing_spot: StringName
## Interiores pequeños: la cámara se queda fija en el centro del mapa.
@export var fixed_camera := false
## El Pokémon que te sigue sale en este mapa (no en interiores estrechos, cuevas...).
@export var followers_allowed := true
