# Audio EBDX — A3, 2026-10-06

Antes, estos eventos pedían un ID sin archivo y quedaban mudos. Ahora se reproducen los originales de los packs descargados, sin conversión ni cambios; manifiesto y hashes en `data/audio_assets.json`.

| Evento | Antes | Ahora: muestra original integrada |
|---|---|---|
| Selección de menú | Silencio | [Cursor](../../../assets/audio/se/menu_move.wav), [aceptar](../../../assets/audio/se/menu_accept.wav), [volver](../../../assets/audio/se/menu_cancel.wav) |
| Shiny | Destello sin sonido | [Shiny de EBDX](../../../assets/audio/se/shiny.wav) |
| Salto | ID jump sin archivo | [Swoosh SE_Zoom2](../../../assets/audio/se/jump.wav), aproximación con el recurso disponible |
| Golpes | Silencio | [Normal](../../../assets/audio/se/hit_normal.ogg), [supereficaz](../../../assets/audio/se/hit_super.ogg), [débil](../../../assets/audio/se/hit_weak.ogg) del pack de NikDie |
| Captura | Animación muda | [Lanzamiento](../../../assets/audio/se/ball_throw.wav), [sacudida](../../../assets/audio/se/ball_shake.wav), [captura completada](../../../assets/audio/me/caught.ogg) |
| Exp./nivel | Barras mudas | [Experiencia](../../../assets/audio/se/exp.wav), [nivel](../../../assets/audio/me/level_up.ogg) |
| Evolución | Silencio | [Inicio](../../../assets/audio/me/evolution.ogg), [BGM](../../../assets/audio/bgm/evolution.ogg) |
| Huida | Silencio | [Flee](../../../assets/audio/se/flee.wav) |
| Victoria | ID sin música | [Salvaje](../../../assets/audio/bgm/victory_wild.ogg), [entrenador](../../../assets/audio/bgm/victory_trainer.ogg) |
| PS bajos | ID de pitido sin archivo | [BGM EBDX](../../../assets/audio/bgm/low_hp.ogg): entra al 20 % y vuelve a la anterior al curar/cambiar; victoria tiene prioridad |

La pila de BGM conserva el mapa mientras suena combate→PS bajos→victoria→evolución. ME pausa la música y la reanuda por donde iba. El modo `fast` de las pruebas omite esperas de jingles. Créditos completos en CREDITOS.md. Música general aún pendiente: candidatos y enlaces/licencias en ESTADO, pregunta 29.
