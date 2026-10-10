# Conexiones del mundo

> Generado con `python3 tools/mundo/grafo_mundo.py` a partir de los mapas pintados (`maps/**/*.tscn`). No se edita a mano: se vuelve a generar al pintar o unir mapas.

Bordes = `MapConnection` (se pasa andando, sin fundido; `span` = solo un tramo del borde). Pasarelas = `Warp` (ferris, avión, Cercanías). Los interiores aún no existen.

## Grupos de mapas unidos entre sí

- Se llega desde San Miguel de Bernuy (33 mapas): `barcelona/ciutat_vella`, `barcelona/eixample`, `barcelona/les_corts`, `getafe/exterior`, `ibiza/exterior`, `leganes/exterior`, `madrid/centro`, `madrid/chamberi`, `madrid/moncloa`, `madrid/palacio_real`, `madrid/retiro`, `maritima_1/exterior`, `mostoles/exterior`, `palma/exterior`, `pueblo_inicial/exterior`, `puertollano/exterior`, `ruta_1/exterior`, `ruta_2/exterior`, `ruta_21/exterior`, `ruta_22/exterior`, `ruta_23/exterior`, `ruta_24/exterior`, `ruta_3/exterior`, `ruta_4/exterior`, `ruta_5/exterior`, `ruta_6/exterior`, `ruta_7/exterior`, `ruta_8/exterior`, `valencia/ciutat_vella`, `valencia/malvarrosa`, `valencia/turia`, `valladolid/exterior`, `zaragoza/exterior`
- **Aislado del pueblo inicial** (13 mapas): `huelva/exterior`, `las_palmas/canteras`, `las_palmas/vegueta_triana`, `playa_del_ingles/exterior`, `ruta_12/exterior`, `ruta_13/exterior`, `ruta_14/exterior`, `ruta_15/exterior`, `ruta_16/exterior`, `sevilla/centro`, `sevilla/maria_luisa`, `sevilla/rio`, `vigo/exterior`

## Uniones pendientes

- `ruta_16/exterior` → `ruta_17/exterior` (borde north): el mapa de destino aún no existe.

## Mapa por mapa

| Mapa | Nombre | Bordes | Pasarelas |
|---|---|---|---|
| `barcelona/ciutat_vella` | Barcelona · Ciutat Vella | north → `barcelona/eixample` | FerryPalma → `palma/exterior` |
| `barcelona/eixample` | Barcelona · Eixample | west → `barcelona/les_corts`, south → `barcelona/ciutat_vella` | — |
| `barcelona/les_corts` | Barcelona · Les Corts | west → `ruta_8/exterior`, east → `barcelona/eixample` | — |
| `getafe/exterior` | Getafe | south → `ruta_24/exterior`, west → `leganes/exterior` | — |
| `huelva/exterior` | Huelva | east → `ruta_14/exterior` | FerryCanarias → `las_palmas/canteras` |
| `ibiza/exterior` | Ibiza | north → `maritima_1/exterior` | FerryValencia → `valencia/malvarrosa` |
| `las_palmas/canteras` | Las Palmas · Las Canteras | south → `las_palmas/vegueta_triana` | FerryHuelva → `huelva/exterior` |
| `las_palmas/vegueta_triana` | Las Palmas · Vegueta y Triana | north → `las_palmas/canteras`, south → `ruta_15/exterior` | — |
| `leganes/exterior` | Leganés | west → `mostoles/exterior`, east → `getafe/exterior` | CercaniasAtocha → `madrid/retiro` |
| `madrid/centro` | Madrid · Sol y Gran Vía | west → `madrid/moncloa`, west → `madrid/palacio_real`, east → `madrid/retiro`, east → `madrid/retiro` | — |
| `madrid/chamberi` | Madrid · Chamberí | west → `madrid/moncloa` | — |
| `madrid/moncloa` | Madrid · Moncloa | west → `ruta_4/exterior`, east → `madrid/centro`, east → `madrid/chamberi` | — |
| `madrid/palacio_real` | Madrid · Palacio Real | east → `madrid/centro` | — |
| `madrid/retiro` | Madrid · Retiro y Prado | west → `madrid/centro`, west → `madrid/centro`, east → `ruta_5/exterior` | CercaniasLeganes → `leganes/exterior`, CercaniasMostoles → `mostoles/exterior` |
| `maritima_1/exterior` | Ruta marítima 1 · Canal de Ibiza | north → `palma/exterior`, south → `ibiza/exterior` | — |
| `mostoles/exterior` | Móstoles | east → `leganes/exterior` | CercaniasAtocha → `madrid/retiro` |
| `palma/exterior` | Palma de Mallorca | south → `maritima_1/exterior` | FerryBarcelona → `barcelona/ciutat_vella` |
| `playa_del_ingles/exterior` | Playa del Inglés | north → `ruta_15/exterior` | AvionVigo → `vigo/exterior` |
| `pueblo_inicial/exterior` | San Miguel de Bernuy | west → `ruta_23/exterior`, south → `ruta_1/exterior` | — |
| `puertollano/exterior` | Puertollano | north → `ruta_24/exterior` | — |
| `ruta_1/exterior` | Ruta 1 · Hoces del Duratón | north → `pueblo_inicial/exterior`, south → `ruta_2/exterior` | — |
| `ruta_12/exterior` | Ruta 12 · Sierra Nevada y Granada | west → `ruta_13/exterior` | — |
| `ruta_13/exterior` | Ruta 13 · Mar de olivos | east → `ruta_12/exterior`, west → `sevilla/centro` | — |
| `ruta_14/exterior` | Ruta 14 · Doñana | east → `sevilla/rio`, west → `huelva/exterior` | — |
| `ruta_15/exterior` | Ruta 15 · Costa de Gran Canaria | north → `las_palmas/vegueta_triana`, south → `playa_del_ingles/exterior` | — |
| `ruta_16/exterior` | Ruta 16 · Rías Baixas | south → `vigo/exterior`, north → `ruta_17/exterior` | — |
| `ruta_2/exterior` | Ruta 2 · Tierra de Pinares y Acueducto | north → `ruta_1/exterior`, south → `ruta_3/exterior` | — |
| `ruta_21/exterior` | Ruta 21 · Viñedos de La Rioja | south → `ruta_22/exterior` | — |
| `ruta_22/exterior` | Ruta 22 · Burgos y Atapuerca | north → `ruta_21/exterior`, south → `valladolid/exterior` | — |
| `ruta_23/exterior` | Ruta 23 · Cuéllar y Tierra de Pinares | west → `valladolid/exterior`, east → `pueblo_inicial/exterior` | — |
| `ruta_24/exterior` | Ruta 24 · La Mancha | south → `puertollano/exterior`, north → `getafe/exterior` | — |
| `ruta_3/exterior` | Ruta 3 · Puerto de Navacerrada | north → `ruta_2/exterior`, south → `ruta_4/exterior` | — |
| `ruta_4/exterior` | Ruta 4 · El Escorial y Galapagar | north → `ruta_3/exterior`, east → `madrid/moncloa` | — |
| `ruta_5/exterior` | Ruta 5 · Corredor del Henares | west → `madrid/retiro`, east → `ruta_6/exterior` | — |
| `ruta_6/exterior` | Ruta 6 · Medinaceli y Calatayud | west → `ruta_5/exterior`, east → `zaragoza/exterior` | — |
| `ruta_7/exterior` | Ruta 7 · Los Monegros | west → `zaragoza/exterior`, east → `ruta_8/exterior` | — |
| `ruta_8/exterior` | Ruta 8 · Montserrat | west → `ruta_7/exterior`, east → `barcelona/les_corts` | — |
| `sevilla/centro` | Sevilla · Centro | east → `ruta_13/exterior`, west → `sevilla/rio`, south → `sevilla/maria_luisa` | — |
| `sevilla/maria_luisa` | Sevilla · Plaza de España | north → `sevilla/centro` | — |
| `sevilla/rio` | Sevilla · Río y Triana | east → `sevilla/centro`, west → `ruta_14/exterior` | — |
| `valencia/ciutat_vella` | Valencia · Ciutat Vella | north → `valencia/turia` | — |
| `valencia/malvarrosa` | Valencia · Malvarrosa | west → `valencia/turia` | FerryIbiza → `ibiza/exterior` |
| `valencia/turia` | Valencia · Jardín del Turia | south → `valencia/ciutat_vella`, east → `valencia/malvarrosa` | — |
| `valladolid/exterior` | Valladolid | east → `ruta_23/exterior`, north → `ruta_22/exterior` | — |
| `vigo/exterior` | Vigo | north → `ruta_16/exterior` | AvionGranCanaria → `playa_del_ingles/exterior` |
| `zaragoza/exterior` | Zaragoza | west → `ruta_6/exterior`, east → `ruta_7/exterior` | — |
