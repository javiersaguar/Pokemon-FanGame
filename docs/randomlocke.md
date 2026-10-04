# Motor RandomLocke — v0.2

El motor continúa el código traspasado por el Agente 2. Generador v2: datos base inmutables + parche, semilla sin signo de 32 bits, ajustes fijados al crear la partida. **Puede salir cualquier especie**, sin límite a la Pokédex regional ni a los sprites del MVP. Las exclusiones son las listas y los ajustes; formas temporales de combate (Mega/Gmax/objeto requerido), registros no obtenibles y entradas sin learnset válido quedan fuera por viabilidad técnica. La UI y la integración del mundo son de A3/A1.

## Preparación y generación

```gdscript
# Hilo principal: leer configuración/datos una sola vez.
RandomizerSettings.prepare()
var settings := RandomizerSettings.from_preset("clasico")
var input := RandomizerInput.from_datadb()
# También: RandomizerInput.from_dict(snapshot_json) para fixtures/DataDB.randomizer_input().
# Hilo principal o WorkerThreadPool: todo lo siguiente es lógica pura.
var patch := Randomizer.generate(input, settings.to_dict(), 20261004)
if patch.is_valid():
    var errors := RomValidator.validate(input, patch)
    var serialized := patch.to_json()
# Aplicar/guardar solo desde el principal y solo sin errores.
```

`input` copia las tablas JSON, construye registros tipados y calcula SHA-256. No modificarlo durante generación. `config` contiene una copia de policy, prohibidos y presets versionados. La generación no lee archivos/autoloads, no tiene nodos ni await. Recorrido de IDs por texto (no ordenar StringName por puntero); subsemillas SHA-256 por módulo y por especie en aprendizaje/compatibilidad. Activar objetos no altera encuentros, iniciales, equipos ni movimientos. Cambiar tipos/evoluciones sí influye en consumidores dependientes (STAB, etapa, rival), por diseño.

El validador comprueba iniciales distintos, daño en la curva y STAB, capturabilidad de zonas, referencias, ciclos, protección de registros/slots/especies y objetos clave, progreso por objetos/movimientos, niveles, tolerancia BST, potencia, preferencia de tipo, temas de líderes, as y mapeo global 1:1. Se reintenta con subsemilla, hasta policy.validation_attempts. `patch.errors` no vacío significa fallo **sin permiso para iniciar partida**; conserva el mismo código visible. Las restricciones elegidas no se relajan silenciosamente.

Los learnsets conservan cantidad de registros y niveles, salvo curvas base sin nivel 1: se normaliza el primer registro al nivel 1 para poder garantizar daño/STAB (incluye curvas que solo contienen movimientos de evolución de nivel 0). Los últimos cuatro movimientos no quedan sin ataque de daño. Preferencia de tipo garantiza al menos el 50 %. Excepción de balance **PENDIENTE JAVIER**: Siniestro puede usar potencia 60 al garantizar STAB, porque no hay ningún STAB de daño implementado ≤50 en la base actual; los demás tipos mantienen la curva heredada.

## Ajustes completos

Los rangos/defaults están en `data/randomizer/settings_schema.json`. Las propuestas de balance heredadas y defaults nuevos no se consideran decisiones definitivas de Javier. `story_pokemon` activa su grupo; `gifts/statics/trades` permiten controlar cada miembro. `locke_rules` es el interruptor maestro de reglas.

| Ajuste | Opciones | Default | Descripción |
|---|---|---|---|
| `starters` | off, random, triangle, three_stage | triangle | Iniciales: sin cambios, aleatorios, triángulo de tipos o dos evoluciones |
| `wild` | off, per_zone, global, chaos | per_zone | Salvajes: sin cambios, por zona, global 1:1 o caos |
| `trainers` | sí/no | sí | Aleatorizar equipos de entrenadores conservando niveles |
| `keep_type_themes` | sí/no | sí | Conservar tipo de líderes y temas definidos |
| `story_pokemon` | sí/no | sí | Activar grupo de regalos, estáticos e intercambios |
| `allow_legendaries` | sí/no | no | Permitir legendarios y singulares |
| `learnsets` | off, random, type_preference | type_preference | Movimientos por nivel: sin cambios, aleatorios o preferencia de tipo |
| `guarantee_stab` | sí/no | sí | Garantizar STAB de daño al nivel 1 |
| `scaled_power` | sí/no | sí | Escalar potencia máxima según nivel |
| `abilities` | sí/no | no | Habilidades aleatorias respetando prohibidos |
| `types` | sí/no | no | Tipos aleatorios coherentes en la línea evolutiva |
| `base_stats` | sí/no | no | Barajar estadísticas conservando su suma |
| `evolutions` | sí/no | no | Evoluciones con suma de estadísticas similar y sin ciclos |
| `items` | sí/no | sí | Objetos de suelo, ocultos, regalos y equipados |
| `shops` | sí/no | no | Tiendas aleatorias con Poké Balls y Pociones garantizadas |
| `similar_strength` | sí/no | sí | Exigir fuerza similar al sustituir especies |
| `strength_tolerance` | 0–100 | 15 | Tolerancia de suma de estadísticas, en porcentaje |
| `level_appropriate` | sí/no | sí | Exigir etapa evolutiva adecuada al nivel |
| `no_early_legendaries` | sí/no | sí | Excluir legendarios y singulares en zonas iniciales |
| `only_implemented_moves` | sí/no | sí | Usar solo movimientos implementados |
| `locke_rules` | sí/no | sí | Activar reglas Locke; Solo aleatorio las desactiva |
| `gifts` | sí/no | sí | Aleatorizar regalos dentro del grupo de historia |
| `statics` | sí/no | sí | Aleatorizar encuentros estáticos dentro del grupo de historia |
| `trades` | sí/no | sí | Aleatorizar intercambios dentro del grupo de historia |
| `trainer_duplicates` | sí/no | no | Permitir especies repetidas en equipos |
| `leader_ace` | sí/no | sí | Hacer que el as del líder sea el más fuerte |
| `rival_starter` | sí/no | sí | Conservar elección alternativa del rival y evolucionarla |
| `tm_compat` | sí/no | no | Aleatorizar compatibilidad de MT |
| `tm_content` | sí/no | no | Aleatorizar contenido de MT |
| `tutor_compat` | sí/no | no | Aleatorizar compatibilidad de tutores |
| `tutor_content` | sí/no | no | Aleatorizar movimientos de tutores |
| `tm_percent` | 0–100 | 50 | Compatibilidad de MT por especie, en porcentaje |
| `tutor_percent` | 0–100 | 50 | Compatibilidad de tutores por especie, en porcentaje |
| `shiny_denominator` | 4096, 1024, 512, 100 | 4096 | Probabilidad shiny de 1 entre este denominador |
| `first_encounter` | sí/no | sí | Solo el primer encuentro elegible de cada zona |
| `permadeath` | sí/no | sí | Debilitado = muerto, pasa al Cementerio |
| `nickname_required` | sí/no | sí | Exigir mote al registrar una captura |
| `duplicates_clause` | sí/no | sí | Repetir encuentro si ya se posee su línea evolutiva |
| `shiny_clause` | sí/no | sí | Capturar shiny sin consumir ni restaurar zona |
| `gifts_count` | sí/no | sí | Regalos e intercambios consumen captura de zona |
| `statics_count` | sí/no | sí | Estáticos consumen captura de zona |
| `level_cap` | sí/no | no | Congelar experiencia al nivel del próximo as |
| `fixed_battle` | sí/no | no | Forzar modo de combate fijo |
| `battle_items` | allowed, limited, forbidden | allowed | Objetos en combate: permitidos, limitados o prohibidos |
| `battle_item_limit` | 0–20 | 3 | Máximo de objetos por combate si están limitados |
| `game_over` | sí/no | sí | Terminar si no queda ningún Pokémon vivo en equipo o PC |

## Presets y prohibidos

`data/randomizer/presets.json` contiene cuatro entradas. **RandomLocke clásico** conserva el balance de A2 (triángulo, salvajes por zona, tolerancia 15 %, etapas y reglas Locke). **Solo aleatorio** usa ese motor y desactiva el interruptor Locke. **Caos Panchito** permite legendarios, todos los módulos, tipos/estadísticas/evoluciones/MT/tutores, sin restricciones de etapa o BST de encuentros. **Personalizado** parte del clásico y permite editar cualquier campo. Alias `caos_panchito` → `caos` por compatibilidad. Probabilidad shiny 1/4096 por defecto, configurable a 1/1024, 1/512 o 1/100; la aplica A2, nunca cambia colores de sprites.

`prohibidos.json`: banned_species, banned_moves, banned_abilities. `policy.json`: curva de potencia, excepción STAB, márgenes de evolución, nivel temprano, tiendas, intentos y referencia de presets. Configuración original `data/randomizer.json` se conserva para consumidores anteriores; el motor nuevo usa snapshot de `data/randomizer/`. **Cambiar resultados obliga a subir generator_version y regenerar dorados de esa versión**.

## Parche, semillas y spoilers

Se mantiene la representación de A2: `species` agrupa tipos/base_stats/evolutions/held_items; abilities y learnsets por especie; starters/gifts/statics son especie por ID; items, objeto por colocación. Encuentros/tiendas conservan registros completos; trainers/trades contienen campos reemplazados. MT/tutores incluyen tablas de contenido y compatibilidad. `input_hash` identifica la base completa, incluyendo configuración, no solo el tamaño de tablas. `to_dict/from_dict` copian profundamente; `to_json/canonical_json` es estable también tras JSON (números integrales normalizados por roundtrip).

`PANCHITO-XXXX-XXXX-XX`: 5 bits versión + 3 preset + 32 semilla + 10 checksum, alfabeto Crockford (sin I/L/O/U; admite I/L→1 y O→0 al introducir). Para Personalizado lleva un sufijo base32 con todos los campos (`RandomizerSettings.payload_chars()` caracteres); no pueden caber todos en los diez del formato corto. El checksum cubre el sufijo. Un código de otra versión recibe aviso claro y nunca se interpreta como configuración actual. **Cargar partida antigua usa su parche guardado, no regenera**. Dos personas necesitan también la misma base/versionado de listas, comprobable por input_hash.

`SeedCode.encode(seed, settings, version)` acepta Settings o diccionario. Preparar catálogo en principal antes de encode/decode; generación recibe referencias de preset desde input.config. `decode` devuelve ok/seed/settings/version/error, con settings_dict adicional. `Randomizer.generate(seed, Settings)` permanece como adaptador principal a DataDB; no usar esa forma desde hilo. `RomPatch.apply()` y `spoiler_text()` también son adaptadores principales; `SpoilerLog.render(input,patch)` es puro. Exportación a `user://randomlocke/<código>_spoilers.txt` corresponde a la UI y solo bajo petición, nunca automática.

## Reglas del mundo y Cementerio

```gdscript
var rules := LockeRules.new(patch.data.settings, input.families(patch), epitaph_templates)
rules.register_owned(selected_starter_species)
var encounter := rules.register_encounter(zone_id, species_id, shiny, "wild", battle_uid)
var allowed := rules.can_catch(zone_id, species_id, shiny, "wild", encounter.encounter_id)
# Resolver antes de añadir al equipo/PC; mote obligatorio puede mantener captura pendiente.
rules.resolve_encounter(encounter.encounter_id, "caught", pokemon_dict)
# También: run/fainted/lost. Un lanzamiento fallido no resuelve el encuentro.
var grave := rules.register_death(pokemon_dict, death_context)
var finished := rules.is_game_over(party_dicts, living_pc_dicts)
var saved := rules.snapshot()
var restored := LockeRules.from_dict(saved)
```

La primera aparición elegible consume zona **antes** de capturar. Se mantiene permiso solo con su encounter_id; huir/debilitar/perder no ofrece otra captura. Varias plantas comparten zone_id. Un duplicado por familia no consume zona; poseídos muertos siguen contando como duplicados. Familias se calculan sobre el grafo parcheado completo (ramificaciones y formas regionales), y se guardan. Shiny exento no consume/restaura zonas y puede saltar duplicados. Regalos/estáticos/intercambios se consultan con source; configuración decide si consumen zona. Las reglas no tienen setters; se copian al construir y snapshots/getters devuelven copias.

Muerte idempotente por uid, lápida con mote/especie/nivel/zona/rival/contexto y epitafio determinista de `epitafios.json`. El motor puro **no retira** el Pokémon del equipo: A1/A2 deben sacarlo a Cementerio, impedir curación/revivir/usarlo y evitar EXP. PC suministrado a game over es plano, sin Cementerio ni huevos. No se termina una partida nueva antes del inicial; si permadeath está desactivada, un equipo debilitado puede curarse. Ranura finished no puede continuar ni capturar, pero se puede consultar.

`level_cap/can_gain_exp`, `battle_mode` y `can_use_item` exponen restricciones para A2. Congelar EXP significa limitar el premio para no superar cap (no basta bloquear después de saltárselo). El límite de objetos es por combate, contabiliza usos exitosos. El tratamiento de las Balls en ese límite queda pendiente de decisión de contenido; la UI/motor deben conservar la posibilidad de capturar. `snapshot` expone zonas available/pending/caught/lost, capturas, muertes, Cementerio, estado y reglas para pantallas A3.

## Integración y compatibilidad

- **A1**: GameState.mode/randomlocke/rom_patch y ranuras ya existen. Aplicar parche antes de mapa, limpiar al título/modo normal, guardar snapshot y no continuar finished. Llamadas antes/después de combate y muerte, registrar iniciales, usar zone_id y resolver rival según elección. Equipo rival se obtiene por trainer_id.
- **A2**: apply_patch atómico valida input_hash/referencias sin cambiar la capa activa si falla; clear_patch restaura base. Todas las consultas usan patch; species_map ya está materializado en encounters y no se vuelve a aplicar. MT/tutores y held_items requieren las consultas nuevas de §10. pokemon_died/result.deaths ya existen; conectar reglas individuales, tope, fijo y objetos. DataDB.randomizer_input exportará snapshot normalizado; adaptador temporal incluido aquí evita bloquearlo.
- **A3**: schema/presets para ajustes, resumen/código, generación en hilo, spoilers solo bajo petición, motes, zonas, Cementerio y game over. Leer plantillas/configuración antes del hilo. El motor no dibuja ni escribe ficheros.

Las peticiones de integración están en ESTADO. §8.6 permanece sin editar por propiedad A2; §10 documenta continuidad y cambios necesarios. El dorado original v1 se conserva sin modificar. Nueva comparación dorada de fixture v2 es estricta y nunca se omite por cambios en datos; el dorado de integración real lleva huella y puede requerir actualización explícita si cambia contenido de otros agentes.

## Pruebas

```bash
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd
PANCHITO_LONG_TESTS=1 godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/randomizer -gselect=fixture -gexit
# Solo al cambiar intencionadamente versión/fixture:
godot --headless --path . -s tests/randomizer/update_fixture_golden.gd
PANCHITO_UPDATE_GOLDEN=1 godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/randomizer -gselect=test_randomizer.gd -gexit
```

Fixture: 40 especies, ramificaciones de nivel, legendario, mascota protegida, varias tablas compartiendo zona, líder, rival en tres momentos, regalo/estático/trueque, objeto clave, tienda, MT y tutor. Suite normal: 200 semillas **por preset**; lenta: 1000 por preset, además de tests de cada regla, roundtrip, corrupción, orden de IDs, aislamiento, equilibrio y progreso. Integración real: 20 semillas clásicas con muestras de caos, aplicación/reversión en DataDB y tiempo <3 s; rendimiento se omite con aviso si no existe data/generated.
