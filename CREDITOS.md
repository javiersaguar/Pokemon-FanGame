# Créditos

Pokémon Spain es un fangame sin ánimo de lucro. Pokémon y todos sus personajes, nombres y gráficos son propiedad de Nintendo, Game Freak y The Pokémon Company. Este proyecto no está afiliado a ellos.

> Apunta aquí **cada recurso ajeno en cuanto lo uses**: qué es, autor, licencia o permiso, enlace y dónde está en el repo. Cada agente edita solo su sección.

## Equipo

- Javier Saguar y su grupo.

## Inspiración

- *Pokémon Iberia*, de **Eric Lostie**: referencia de tono y de estructura (región basada en España, humor negro). No se usa ningún recurso, texto ni gráfico suyo.

## Motor y herramientas

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Godot Engine 4.7.2 | Juan Linietsky, Ariel Manzur y colaboradores | MIT | https://godotengine.org | — |
| GUT 9.7.1 (Godot Unit Test) | Butch Wesley (bitwes) | MIT | https://github.com/bitwes/Gut | `addons/gut/` (incluye sus propias fuentes, con su licencia) |

## Gráficos del mundo: tileset y personajes del mapa (Agente 4; los montó el Agente 1)

Copiados de los packs de `docs/arte/recursos_terceros.md` solo en lo que se usa, sin dibujar nada encima: `assets/tilesets/exterior/build_exterior.gd` y `assets/sprites/characters/import_characters.gd` dicen qué parte sale de qué archivo. Los packs 02 y 05 ya vienen a ×2 y se copian tal cual; los packs 01, 03 y 04 vienen a ×1 y se duplica cada píxel (decisión de Javier). Los colores clave de las hojas (rosa, magenta y amarillo de relleno) se pasan a transparente y las piezas de los autotiles de RMXP se recomponen en las 47 casillas de cada terreno.

| Recurso | Autor | Licencia o permiso | Enlace | En el repo |
|---------|-------|--------------------|--------|------------|
| **HGSS for RMXP** v1.2: valla de madera, edificios de ciudad (`BuildingsRMXP.png`: centros Pokémon, tiendas, oficinas, pisos, teatro, faro...) y adornos urbanos (`UrbanRMXP.png`: farolas, fuentes, bancos, jardineras...) para las ciudades; las casas de HGSS ya no se usan en el pueblo | **SirMalo** | Recurso para fangames de Eevee Expo, con crédito | https://eeveeexpo.com/resources/462/ | `assets/tilesets/exterior/casas.png`, `edificios.png`, `adornos.png` |
| **Public Gen 4 Tileset**: hierba, bosque de pinos (también nevados), nieve, caminos, calle de baldosas, casas de DPPt, estanque, meseta y escaleras, bordillo, adoquines, carteles, rocas y troncos; autotiles de hierba alta, camino, flores y brillos del agua | **Magiscarf, WesleyFG, SailorVicious (Heavy-Metal-Lover), Shawn Frost, NSora-96, PeekyChew, Kyle-Dove, Claisprojects.com, Minorthreat0987, The-Red-Ex, UltimoSpriter, TyranitarDark, DarkDragonn, rafa-cac, Phyromatical, Alucus, Newtiteuf, ChaoticCherryCake y moca** (su `CREDITS.txt`) | Recurso público para fangames de Eevee Expo, con crédito | https://eeveeexpo.com/resources/208/ | `assets/tilesets/exterior/gen4.png`, `autotiles.png`, `animados.png` |
| **Big Tree Pack**: cerezos, manzano, pino, árboles redondos y arbustos (en el mapa y en el fondo de combate del bosque) | **AnonAlpaca** | Libre uso con crédito; el autor permite editarlos | https://eeveeexpo.com/resources/602/ | `assets/tilesets/exterior/arboles.png` |
| **Big Flora Pack**: tulipanes, setos y nenúfares | **AnonAlpaca** (plantas) y **Magiscarf** (lo que no es planta) | Libre uso con crédito; el autor permite editarlos | https://eeveeexpo.com/resources/607/ | `assets/tilesets/exterior/flora.png` |
| **ULTIMATE Gen 4 Overworlds Pack**: protagonista provisional (Ethan y Lyra: andar, correr, bici, surf y pesca), rival, profesor, enfermera, dependiente y vecinos; Poké Ball del suelo; "!", hierba al pisarla, polvo al saltar y brillo shiny | **PurpleZaffre** | Recurso para fangames de Eevee Expo, con crédito obligatorio | https://eeveeexpo.com/resources/609/ | `assets/sprites/characters/` y `assets/sprites/characters/effects/` |
| **Character Customization Resources (Gen 4)**: piezas (bases, ropa, pelo, sombreros, bolsas) con las que se montan los entrenadores Spain | **Poltergeist** (Coffee Cup) | "You can freely edit, use and share the files"; crédito agradecido | https://eeveeexpo.com/resources/317/ | `assets/sprites/trainers/`, `assets/sprites/characters/<clase>.png` |
| Sombra de los personajes y de los Pokémon que te siguen | Equipo de Pokémon Spain (dibujada a mano en `assets/_fuentes/mundo/sombra.px2`) | Propio | — | `assets/sprites/characters/effects/sombra.png` |
| Monumentos dibujados a mano: iglesia de San Miguel Arcángel y ermita de la Virgen del Río (San Miguel de Bernuy), Acueducto de Segovia, cruz y basílica del Valle de Cuelgamuros, Monasterio de El Escorial, Arco de la Victoria, Templo de Debod, Faro de Moncloa, Real Casa de Correos, el Oso y el Madroño, Casa de la Panadería y soportales de la Plaza Mayor, Mercado de San Miguel, Edificio Metrópolis y Edificio Carrión | Equipo de Pokémon Spain (`assets/_fuentes/mundo/*.px2`) | Propio | — | `assets/tilesets/exterior/hecho_a_mano/` |

Los verdes de la naturaleza de los packs 02, 03 y 04 llevan un **retoque de paleta** reproducible (`GREEN_RETOUCH` en `build_exterior.gd`) para que la hierba tenga el tono y la viveza de la de Añil.

## Pokémon: sprites, iconos, Pokémon que te siguen y gritos (Agente 2)

Copiados sin modificar ni reescalar por `tools/sprites/import_pokemon_assets.mjs --all`: todas las especies y formas del pack (decisión de Javier). Qué archivo viene de qué pack: `data/generated/pokemon_assets.json`.

| Recurso | Autor | Licencia o permiso | Enlace | En el repo |
|---------|-------|--------------------|--------|------------|
| **Generation 9 Resource Pack v3.3.8** (set oficial del proyecto, DIRECTRICES §7.1): sprites de combate de frente y espalda, iconos y Pokémon que te siguen, normales y shiny, y gritos | Recopilado por **Caruban**; autores de cada parte abajo (de su `Credits.txt`) | Recurso para fangames publicado en Eevee Expo, con crédito obligatorio; Pokémon es propiedad de Nintendo / Game Freak / The Pokémon Company | https://eeveeexpo.com/resources/1101/ | `assets/sprites/pokemon/{front,front_shiny,back,back_shiny,icons,icons_shiny,followers,followers_shiny}/`, `assets/audio/cries/` |
| Generation 8 Pack v20.1 (reserva: solo si falta algo en el anterior; hoy no se usa ningún archivo suyo) | Golisopod User, UberDunsparce y los autores de su `Gen8 Pack Credits.txt` | Igual que el anterior | https://eeveeexpo.com/resources/952/ | — |

Créditos del Generation 9 Pack (`Credits.txt`), de las partes que usamos:

- **Sprites de combate:** generaciones 1–5, **veekun**; generaciones 6, 7 y 8 y Leyendas: Arceus, **todos los colaboradores del Smogon X/Y, Sun/Moon y Sword/Shield Sprite Project** (Blaquaza, KingOfThe-X-Roads, KattenK, Travis, G.E.Z., SpheX, Hematite, SelenaArmorclaw); generación 9, KingOfThe-X-Roads, Mak, Caruban, jinxed, leParagon, Sopita_Yorita, Azria, Mashirosakura, JordanosArt, Abnayami, OldSoulja, Katten, Divaruta 666, Clara, Skyflyer, AshnixsLaw y ace_stryfe; estilo clásico de la generación 9, KingOfThe-X-Roads, Mak, Caruban, jinxed, leParagon, Sopita_Yorita, Azria, Mashirosakura, JordanosArt, Scept, NanaelJustice, SoyChim, KRLW890, AnonAlpaca, PokeJminer, Red7246, Carmanekko, Eduar, Lykeron, GriloKapu10, Mesayas, Erkey830, QDylm, PorousMist, OldSoulja, AlexandreV2.0, Z-nogyroP, lennybitao, Ruben1986, GRAFAIAIMX, Blaquaza, KattenK, Travis, G.E.Z., SpheX y Hematite; Leyendas: Z-A, Caruban, ace_stryfe, KingOfThe-X-Roads, camiloveso y Mak.
- **Iconos:** generaciones 1–6, Alaguesia y harveydentmd; generación 7, Marin, MapleBranchWing y los colaboradores del DS Styled Gen 7+ Repository; generación 8, Larry Turbo, Leparagon y magnusbanette; iconos shiny, StarrWolf y el equipo de Pokémon Shattered Light; Leyendas: Arceus, LuigiTKO (shiny recoloreados por StarrWolf); generación 9, ezerart y JordanosArt; estilo clásico, LuigiTKO, Pikafan2000, Cesare_CBass, Vent, MultiDiegoDani, leParagon, JWNutz, Katten, AlexandreV2.0, Carmanekko y GRAFAIAIMX; con agradecimiento a "Pokémon Icons Act 2.9 - Teracristalizando" y a Axel Loquendo, CarmaNekko, Divaruta 666, Okyo, JLauz735 y ClaraDragon ("Iconos 9na Gen gba completos", WhackAHack); Leyendas: Z-A, ezerart, camiloveso y Caruban.
- **Pokémon que te siguen:** generaciones 1–5, MissingLukey, help-14, Kymoyonian, cSc-A7X, 2and2makes5, Pokegirl4ever, Fernandojl, Silver-Skies, TyranitarDark, Getsuei-H, Kid1513, Milomilotic11, Kyt666, kdiamo11, Chocosrawlooid, Syledude, Gallanty, Gizamimi-Pichu, Zyon17, LarryTurbo y spritesstealer; generación 6, princess-pheonix, LunarDusk, Wolfang62, TintjeMadelintje101 y piphybuilder88; generación 7, Larry Turbo y princess-pheonix; generación 8, SageDeoxys, Wolfang62, LarryTurbo y tammyclaydon; Leyendas: Arceus, Boonzeet, DarkusShadow, princess-phoenix, Ezeart y WolfPP; generación 9, Azria, DarkusShadow, EduarPokeN, Carmanekko, StarWolff y Caruban; Leyendas: Z-A, DarkusShadow.
- **Gritos:** generaciones 1–6, Rhyden; generación 7, Marin y Rhyden; generación 8, Zeak6464; Leyendas: Arceus, Morningdew; generación 9, editados de los vídeos de Lightblade, HeroLinik y Joya in UK; megaevoluciones de Leyendas: Z-A, DarkWolf13 (de un vídeo de HeroLinik).
- **Objetos:** gráficos de Game Freak; objetos de generaciones 9, Leyendas: Arceus y Z-A recopilados por Caruban, lichenprincess, jinxed, AztecCroc y 3DJackArt; MT de DJChaos. Iconos copiados del pack a 48×48, sin reescalar.
- **Recopilación:** Generation 9 Pack, Caruban; sprites redimensionados de las generaciones 8 y 9, http404error; Generation 8 Pack, Golisopod User y UberDunsparce. Lista completa de créditos de los sprites: la hoja de cálculo enlazada en el `Credits.txt` del pack.

## Interfaz y combate (Agente 3)

Copiados del pack sin modificar ni reescalar, solo los archivos que se usan.

| Recurso | Autor | Licencia o permiso | Enlace | En el repo |
|---------|-------|--------------------|--------|------------|
| Fondos de combate de *ORAS/XY themed battle backgrounds for EBDX* (Field, Forest, Cave, City, Water, IndoorA, Snow, Sand) | **PhoenixOfLight92** (extracción de los fondos de la 6.ª generación) y **LackDeJurane** (fondos combinados) | Uso con crédito | https://eeveeexpo.com/resources/729/ | `assets/sprites/ui/battle/backgrounds/` |
| *Loaky's Modern Type Icons* (versión en español) | **Loaky** | El autor no exige crédito; se le acredita igualmente | https://eeveeexpo.com/resources/1528/ | `assets/sprites/ui/icons/types_spanish.png` |
| Iconos de objetos del MVP y sombras de los Pokémon del Generation 9 Pack | Los de la sección "Pokémon" | Igual que el Generation 9 Pack | https://eeveeexpo.com/resources/1101/ | `assets/sprites/items/`, `assets/sprites/ui/battle/shadows/` |
| Botones, paneles, iconos de estado y de sexo, destellos, cursores y ficha del Pokémon | Equipo de Pokémon Spain (pixel art propio, `assets/_fuentes/ui/`) | Propio | — | `assets/sprites/ui/` |

## Datos

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| Pokémon Showdown 0.11.11 (datos de `dist/data`: especies, movimientos, habilidades, objetos, tipos y learnsets) | Guangcong Luo (Zarel) y colaboradores | MIT | https://github.com/smogon/pokemon-showdown | Procesados en `data/generated/` por `tools/import_data` |
| PokeAPI (CSV de `data/v2/csv`, commit `a003ae375b69`): nombres y descripciones en español, Pokédex, experiencia, captura, EVs y precios | Paul Hallett y colaboradores de PokeAPI | BSD-3-Clause | https://github.com/PokeAPI/pokeapi | Procesados en `data/generated/` por `tools/import_data` |
| OpenStreetMap: calles, monumentos y locales reales de cada ciudad, para los planos de referencia del mundo | © colaboradores de OpenStreetMap | ODbL 1.0 | https://www.openstreetmap.org/copyright | `docs/mundo/planos/*.svg` (los genera `tools/mundo/osm_plano.py`; la caché no se sube) |
| WikiDex: verificación de estadísticas base y EVs (`tools/wikidex`); dos EVs corregidos con `"fuente": "WikiDex"` en `data/species_overrides.json` | Colaboradores de WikiDex | Se usan datos, no textos | https://www.wikidex.net | `data/generated/wikidex_check.json` |

Los nombres, textos y datos de los Pokémon son propiedad de Nintendo, Game Freak y The Pokémon Company; las fuentes anteriores solo los recopilan.

Las transiciones de entrada del combate usan **Elite Battle: DX**, de **Luka S.J.**, conforme a sus [créditos completos](https://luka-sj.com/essentials/resources/EBDX). Copias nativas de Forest/Default/Gold/Common/Elite en `assets/sprites/ui/battle/transitions/`, sin escalar ni rotar; el fondo 640×480 de Default se encuadra en 512×384. Originales, dimensiones y hashes en `data/battle_motion_assets.json`; reproducción con `tools/arte/import_battle_media.py`.

## Audio

| Recurso | Autor | Licencia o permiso | Enlace | En el repo |
|---|---|---|---|---|
| Elite Battle: DX: selección, experiencia, huida, shiny, lanzamiento, swoosh de salto, jingles de captura/evolución/nivel y músicas de victoria/evolución/PS bajos | **Luka S.J.**; sonidos originales de **Game Freak**, extracción por **BadSamaritan** | Recurso publicado para fangames con crédito obligatorio. No es CC0; Pokémon pertenece a Nintendo / Game Freak / The Pokémon Company | [Publicación y créditos de EBDX](https://luka-sj.com/essentials/resources/EBDX) | `assets/audio/{se,me,bgm}/`; originales/hash en `data/audio_assets.json` |
| Sonidos de golpe normal/super/débil, subida/bajada de estadísticas y error, del EBDX move & common animation pack | **NikDie**, **Luka S.J.**, Pokémon Essentials y Game Freak (muestras originales) | Pack para fangames; crédito a los autores del recurso | [Publicación del pack de NikDie](https://eeveeexpo.com/resources/1230/) | `assets/audio/se/{hit_normal,hit_super,hit_weak,stat_up,stat_down,menu_error}.*` |

Créditos completos de EBDX, conforme a su publicación: **Game Freak**, **Pokecheck.org**, **PinkCatDragon**, **Tebited15**, **WolfPP**, **Issei Hyoudou**, **Nasasu**, **luckygirl88**, **Spriters-Resource (redblueyellow)**, **Damien**, **BadSamaritan**, **Luka S.J.**, **Pokémon Essentials**, **Maruno**, **Marin** y **Golisopod User**.

Copias sin modificar ni convertir. `tools/arte/import_audio.py <carpeta-de-recursos>` las reproduce y verifica los hashes. Las BGM se reproducen en bucle; SE/ME/gritos no. El salto usa `SE_Zoom2` de EBDX como swoosh (el pack no incluye un archivo de salto dedicado). Los candidatos para música general están en ESTADO, pregunta 29; aún no se usan.

## Fuentes

| Recurso | Autor | Licencia | Enlace | En el repo |
|---------|-------|----------|--------|------------|
| *Gen 5 Font – Truth and Ideals* (Normal, Shadow y Small Truths) | **bonzairob** ("Credit if used: bonzairob @ 3dPE") | Uso con crédito | https://eeveeexpo.com/resources/861/ | `assets/fonts/truth_and_ideals/` (la del juego) |
| Pixel Operator (versión 2018.10.04-1) | Jayvee Enaguas (HarvettFox96) | CC0 1.0 | https://www.dafont.com/pixel-operator.font | `assets/fonts/` (licencia en `PixelOperator-LICENSE.txt`; ya no se usa) |

Presentación de Megaevolución: símbolo `Graphics/EBDX/Pictures/UI/symMega.png` y energía `Graphics/EBDX/Animations/Moves/ebMega006.png` originales del pack Elite Battle: DX, conservados íntegros en el manifiesto de recursos de combate.

Eclosión: `Graphics/Pokemon/Eggs/000.png` y `000_cracks.png` del Generation 9 Pack, y `Graphics/EBDX/Pictures/Hatching/hatchbg.png` de Elite Battle: DX; originales íntegros a tamaño nativo en el manifiesto de recursos. Se mantienen los autores y condiciones de los packs indicados arriba.
