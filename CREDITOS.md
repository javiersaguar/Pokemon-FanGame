# Créditos

Pokémon Panchito es un fangame sin ánimo de lucro. Pokémon y todos sus personajes, nombres y gráficos son propiedad de Nintendo, Game Freak y The Pokémon Company. Este proyecto no está afiliado a ellos.

> Apunta aquí **cada recurso ajeno en cuanto lo uses**: qué es, autor, licencia o permiso, enlace y dónde está en el repo. Cada agente edita solo su sección.

## Equipo

- Javier Saguar y su grupo.

## Motor y herramientas

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Godot Engine 4.7.2 | Juan Linietsky, Ariel Manzur y colaboradores | MIT | https://godotengine.org | — |
| GUT 9.7.1 (Godot Unit Test) | Butch Wesley (bitwes) | MIT | https://github.com/bitwes/Gut | `addons/gut/` (incluye sus propias fuentes, con su licencia) |

## Gráficos

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Tileset provisional | Equipo de Pokémon Panchito (generado por script) | Propio | — | `assets/tilesets/placeholder/` |
| Personajes y objetos del mapa provisionales | Equipo de Pokémon Panchito (generado por script) | Propio | — | `assets/sprites/characters/placeholder/` |
| Sprites de Pokémon de combate (frente, espalda, normal y shiny), estilo 5.ª generación | Nintendo / Game Freak (5.ª generación) y los artistas del Smogon Sprite Project (generaciones posteriores), vía Pokémon Showdown | Propiedad de Nintendo / Game Freak; uso de fans sin ánimo de lucro | https://play.pokemonshowdown.com/sprites/ | `assets/sprites/pokemon/{front,back,front_shiny,back_shiny}/` (`tools/sprites`) |
| Iconos de Pokémon (40×30) | Nintendo / Game Freak y colaboradores de Pokémon Showdown (hoja `pokemonicons-sheet.png`) | Propiedad de Nintendo / Game Freak; uso de fans sin ánimo de lucro | https://play.pokemonshowdown.com/sprites/pokemonicons-sheet.png | `assets/sprites/pokemon/icons/` (`tools/sprites`) |

## Datos

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Pokémon Showdown 0.11.11 (datos de `dist/data`: especies, movimientos, habilidades, objetos, tipos y learnsets) | Guangcong Luo (Zarel) y colaboradores | MIT | https://github.com/smogon/pokemon-showdown | Procesados en `data/generated/` por `tools/import_data` |
| PokeAPI (CSV de `data/v2/csv`, commit `a003ae375b69`): nombres y descripciones en español, Pokédex, experiencia, captura, EVs y precios | Paul Hallett y colaboradores de PokeAPI | BSD-3-Clause | https://github.com/PokeAPI/pokeapi | Procesados en `data/generated/` por `tools/import_data` |

Los nombres, textos y datos de los Pokémon son propiedad de Nintendo, Game Freak y The Pokémon Company; las fuentes anteriores solo los recopilan.

## Audio

*(Sección del Agente 3.)*

## Fuentes

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Pixel Operator (versión 2018.10.04-1) | Jayvee Enaguas (HarvettFox96) | CC0 1.0 | https://www.dafont.com/pixel-operator.font | `assets/fonts/` (licencia en `PixelOperator-LICENSE.txt`) |
