# Licencias del arte de terceros

Un registro por recurso **que se usa en el juego** (Fase A.3). Antes de integrar un asset de terceros, su fila tiene que estar aquí y en `CREDITOS.md`. Packs descargados por Javier (de dónde sale cada uno): `docs/arte/recursos_terceros.md`.

Todos son recursos de fans para fangames sin ánimo de lucro; los sprites de Pokémon son propiedad de Nintendo, Game Freak y The Pokémon Company. Solo se usan en un juego **no comercial** y con crédito.

| Recurso | Autores | Licencia / condiciones (de su página) | Enlace | En el repo | Comprobado |
|---------|---------|----------------------------------------|--------|------------|------------|
| **Generation 9 Resource Pack v3.3.8** (set oficial de Pokémon) | Recopilado por Caruban; sprites de veekun y de los Smogon Sprite Projects, iconos, seguidores y gritos de los autores de su `Credits.txt` | Uso libre con crédito a todos los autores de `Credits.txt` (lista en `CREDITOS.md`) | https://eeveeexpo.com/resources/1101/ | `assets/sprites/pokemon/` (Agente 2), `assets/sprites/items/pokeball.png`, `assets/sprites/ui/battle/shadows/` | 2026-10-04 |
| *ORAS/XY themed battle backgrounds for EBDX* | PhoenixOfLight92 (extracción de los fondos de 6.ª gen) y LackDeJurane (fondos combinados) | "PhoenixOfLight92 for ripping the Gen 6 battlebacks, LackDeJurane for the combined battlebacks" | https://eeveeexpo.com/resources/729/ | `assets/sprites/ui/battle/backgrounds/` | 2026-10-04 |
| *Loaky's Modern Type Icons* | Loaky | "Credit isn't required!" (se acredita igualmente) | https://eeveeexpo.com/resources/1528/ | `assets/sprites/ui/icons/types_spanish.png` | 2026-10-04 |
| *Gen 5 Font – Truth and Ideals* | bonzairob | "Credit if used: bonzairob @ 3dPE" | https://eeveeexpo.com/resources/861/ | `assets/fonts/truth_and_ideals/` | 2026-10-04 |
| Pixel Operator 2018.10.04-1 | Jayvee Enaguas (HarvettFox96) | CC0 1.0 (texto completo en `assets/fonts/PixelOperator-LICENSE.txt`) | https://www.dafont.com/pixel-operator.font | `assets/fonts/` (ya no se usa) | 2026-10-04 |
| **Public Gen 4 Tileset** (suelo, naturaleza, casas de DPPt, autotiles) | moca (recopilación); Magiscarf, WesleyFG, SailorVicious, Shawn Frost, NSora-96, PeekyChew, Kyle-Dove, Claisprojects.com, Minorthreat0987, The-Red-Ex, UltimoSpriter, TyranitarDark, DarkDragonn, rafa-cac, Phyromatical, Alucus, Newtiteuf, ChaoticCherryCake y moca (`CREDITS.txt`) | Recurso público para fangames, con crédito a todos los de `CREDITS.txt` | https://eeveeexpo.com/resources/208/ | `assets/tilesets/exterior/` (Agente 4) | 2026-10-05 |
| **HGSS for RMXP** v1.2 (valla de madera; casas sin usar) | SirMalo | Crédito: SirMalo | https://eeveeexpo.com/resources/462/ | `assets/tilesets/exterior/vallas.png`, `casas.png` (Agente 4) | 2026-10-05 |
| **Big Tree Pack** y **Big Flora Pack** | AnonAlpaca (y Magiscarf en lo que no es planta) | Libres con crédito; el autor permite editarlos | https://eeveeexpo.com/resources/602/ y https://eeveeexpo.com/resources/607/ | `assets/tilesets/exterior/arboles.png`, `flora.png` (Agente 4) | 2026-10-05 |
| **ULTIMATE Gen 4 Overworlds Pack** | PurpleZaffre | "Credit PurpleZaffre if you use anything from this pack" (el pack pide además no redistribuirlo suelto; Javier decidió copiar al repo solo lo que se usa) | https://eeveeexpo.com/resources/609/ | `assets/sprites/characters/` (Agente 4) | 2026-10-05 |
| **Character Customization Resources (Gen 4)** | Poltergeist (Coffee Cup) | "You can freely edit, use and share the files. Credits would be appreciated but not necessary. If used: Credit to Coffee Cup/ Poltergeist" | https://eeveeexpo.com/resources/317/ | `assets/sprites/trainers/`, `assets/sprites/characters/<clase>.png` (Agente 4, montados con `build_trainers.gd`) | 2026-10-05 |

## Cómo añadir un recurso

1. Lee la licencia del pack (su `README`, `Credits.txt` o la página del recurso) y copia las condiciones tal cual: crédito, uso no comercial, si se puede editar o redistribuir.
2. Añade la fila aquí y los autores en `CREDITOS.md` (sección de su tipo).
3. Copia al repo **solo los archivos que se usen**, sin reescalar (`DIRECTRICES.md` §7.1).
4. Apunta el asset en `docs/arte/seguimiento.md` con su fuente.
