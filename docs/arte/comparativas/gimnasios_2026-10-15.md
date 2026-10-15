# Gimnasios por dentro · antes y después (2026-10-15, Agente 3)

Capturas a escala real (vista de pájaro) de cada sala. **Antes:** `main` al empezar la sesión (salas de 16×12 con el zigzag automático y casi sin muebles). **Después:** cada sala pintada a mano desde su plano en `maps/_pintura/gimnasios_salas.json` (ver [`docs/arte/gimnasios.md`](../gimnasios.md)). Se rehacen con:

```sh
godot --path . -s res://maps/_tools/captura_gimnasios.gd -- res://docs/arte/comparativas/gimnasios/despues <ciudad> flags=quiron_superado
```

Las capturas no ejecutan `MapLoader.prepare`, así que no salen los personajes colocados por datos (Ayuso en su ático); los vigilantes salen en su sitio de bloqueo (sin entrenadores ganados). Todo el arte es **PROVISIONAL** hasta que lo apruebe Javier.

## 1 · Madrid — Real Casa de Correos

| Sala | Antes | Después |
|---|---|---|
| Registro General | ![](gimnasios/antes/madrid_gimnasio_1.png) | ![](gimnasios/despues/madrid_gimnasio_1.png) |
| Salón de Plenos (Grupo Popular) | ![](gimnasios/antes/madrid_gimnasio_2.png) | ![](gimnasios/despues/madrid_gimnasio_2.png) |
| Archivo de Títulos | ![](gimnasios/antes/madrid_gimnasio_3.png) | ![](gimnasios/despues/madrid_gimnasio_3.png) |
| Despacho de la Presidenta | ![](gimnasios/antes/madrid_gimnasio_lider.png) | ![](gimnasios/despues/madrid_gimnasio_lider.png) |
| Terraza del ático (Chamberí) | ![](gimnasios/antes/madrid_atico_ayuso.png) | ![](gimnasios/despues/madrid_atico_ayuso.png) |

- **Registro:** mostrador corrido de madera con dos funcionarios (se les habla por encima), sala de espera con taburetes y el dispensador de turnos, mampara de cristal, jefatura con estanterías, las banderas de España y de la Comunidad junto a la puerta y el retrato del Rey.
- **Salón de Plenos:** dos filas de escaños que hacen de tabique (con el hueco en lados alternos), estrado con alfombra, mesa de la presidencia, atril, banderas, retrato y escaños del público.
- **Archivo de Títulos:** pasillos de archivadores, pared de títulos enmarcados, la vitrina del máster (cartel), trituradora y mesas de consulta.
- **Despacho:** retrato de la presidenta, banderas, mesa, alfombra, sofás, vitrinas y el jefe de gabinete. Ayuso te sube a su ático.
- **Ático:** la fachada del ático con su jardín (por su puerta se baja a Chamberí), barandilla de azotea, jardineras, mesas con sombrilla, la fuente, un camarero y un escolta. Ayuso espera en (8, 6), como dicen los datos.
