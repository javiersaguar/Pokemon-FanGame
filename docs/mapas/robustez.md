# Carga y recorrido ampliado — 2026-10-05

La carga valida el destino antes de mutar la partida o descargar el mapa de origen. PackedScene se conserva en una cache de 16 entradas; no se conservan instancias ni cambios de NPC de visitas anteriores. Los guardados se inspeccionan con peek_state antes de continuar. Un mapa, spawn o coordenada inválidos devuelve Error y conserva mundo, posición y control.

Entrada directa `-- --map=muestras/ruta` usa default si no se especifica --spawn. La nueva partida del título usa el mapa y spawn de world.mvp_locations/new_game. Se evita el antiguo fallback silencioso para un nombre de spawn equivocado.

## Medición

Godot 4.7.2, WSL, headless, recursos ya importados. `prepare_ms` es carga/instanciación de escena (cache propia vacía al empezar; recursos comunes ya pueden estar cargados por el inicio de partida). `load_ms` incluye preparar, añadir al árbol, colocar jugador, cámara y metadatos. Son dos tramos medidos por separado, no una suma que deba duplicarse. Ambos deben ser <500 ms. Los fundidos de 0,25 s por lado son deliberados y se excluyen del tiempo de carga. No son una garantía de rendimiento para todo hardware o mapas futuros.

| Mapa | Preparar (ms) | Entrar (ms) | Destinos/apariciones válidos |
|---|---:|---:|---|
| muestras/pueblo | 4.834 | 0.922 | Sí |
| muestras/ruta | 3.859 | 0.687 | Sí |
| test/muestra_pueblo | 2.123 | 1.140 | Sí |
| test/muestra_ruta | 2.149 | 0.639 | Sí |
| test/test_outdoor | 3.891 | 0.567 | Sí |
| test/test_room | 0.351 | 1.282 | Sí |

Informe [JSON](smoke_2026-10-05.json). Reproducir desde el worktree:

```sh
XDG_DATA_HOME=/tmp/panchito-a1-smoke godot --headless --path . -- --smoke-maps=all
```

El smoke reducido recorre todos los mapas, todos sus spawns y destinos de Warp, entra al árbol y espera física. Al cerrar este arranque reducido, Godot avisa 89 referencias ObjectDB / 62 recursos (GDScript y recursos constantes de Character; inspección --verbose sin ningún Node filtrado). **Pendiente diagnóstico del cierre reducido**, sin atribuir todavía causa. No aparece en el arranque normal real `--fixed-fps 60 --quit-after 120 -- --map=muestras/ruta`, en la captura gráfica completa ni al cerrar la suite GUT completa. No se ocultan esos avisos ni se confunden con tests correctos.

## Partida ampliada

`tests/mundo/test_extended_game.gd` juega normal y RandomLocke con escenas y motor reales: intro/teclado → habitación/laboratorio → inicial por DataDB → mote obligatorio Locke → rival tutorial con BattleScene/EngineDriver (sin muerte Locke) → Pokédex/recompensa por ID → enfermera → mapa exterior/paso por física → correr siempre → guardar → salir → continuar y restaurar ROM/reglas/flags/identidad/posición. Acelera únicamente texto/animaciones de la escena de combate; no usa Debug ni simula el resultado del combate. Las pruebas específicas cubren las conexiones, campo, transporte, reloj/cañas/estáticos/errantes y errores; no se añaden objetos/flags de historia inventados para activarlos.

`test_map_robustness.gd` recorre además los seis mapas dentro de la suite headless, comprueba cache sin instancias compartidas y conserva partida ante destino, spawn, coordenadas y guardado inválidos.

**Este es el perfil test.** No cierra v0.1: el pueblo rechazado requiere aprobación nueva y los mapas reales del MVP requieren entrega/registro de lógica, revisión manual y repetición del recorrido sobre perfil real antes de tag.
