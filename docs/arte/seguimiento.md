# Seguimiento de arte

Estado de **cada asset visible** del juego (Fase A.7 de la guía). Dueño del archivo: Agente 3; cada agente añade y actualiza las filas de sus assets.

- **Estados:** `placeholder → encargo → silueta → color → animado → integrado → revisado → ✅ final`.
- Un asset solo pasa a **✅ final** con la aprobación de Javier (columna "Aprobado por Javier").
- Los **placeholders** están permitidos durante el desarrollo **solo si están en esta tabla**. Desde la demo `v0.3` no puede quedar ninguno a la vista.
- Licencias de los assets de terceros: `docs/arte/licencias.md`. Créditos: `CREDITOS.md`.

## Placeholders a la vista

Relleno técnico temporal que hay que sustituir. **Ninguno es arte del juego.**

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Tileset provisional (`assets/tilesets/placeholder/`) | Tileset | A1 | placeholder | Generado por script | — | Se sustituye por los packs de terceros (lista en `docs/ESTADO.md`) |
| Sprites de Pokémon en combate (`PlaceholderArt.pokemon`) | Pokémon en combate | A3 | placeholder | Generado por código | — | "Gota" del color del tipo. Se quita en cuanto estén los sprites reales del Agente 2 (`assets/sprites/pokemon/`) |
| Entrenadores en combate (`PlaceholderArt.trainer`) | Entrenador en combate | A3 | placeholder | Generado por código | — | Silueta. Se sustituye por los sprites de las clases (`docs/entrenadores.md`) |
| Poké Ball de la captura (`PlaceholderArt.ball`) | UI de combate | A3 | placeholder | Generado por código | — | |
| Fondos y bases de combate (`BattleBackground`) | Fondo de combate | A3 | placeholder | Dibujado por código | — | Degradado y elipses. Se sustituyen por fondos de 256×192 + bases (lista de recursos) |
| Efectos de movimientos (`BattleFx`) | Animación de combate | A3 | placeholder | Dibujado por código | — | Estallido, proyectil y destellos genéricos por tipo |
| Marcos de la UI (`src/ui/theme/main_theme.tres`) | UI | A3 | placeholder | `StyleBoxFlat` | — | Se sustituyen por paneles 9-slice según la biblia |
| Barras de PS y experiencia (`HpBar`) | UI de combate | A3 | placeholder | Dibujadas por código | — | |
| Iconos de sexo y de estado (`BattleDataBox`) | UI | A3 | placeholder | Dibujados por código | — | Se sustituyen por iconos de la biblia |
| Cursor y flecha de continuar (`CursorArrow`) | UI | A3 | placeholder | Dibujados por código | — | |

## Assets

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Pixel Operator (`assets/fonts/`) | Fuente | A3 | integrado | Jayvee Enaguas, CC0 1.0 | ⏳ | Candidata. Faltan º, ª, ♂ y ♀. Hay que revisarla a 512×384 |
