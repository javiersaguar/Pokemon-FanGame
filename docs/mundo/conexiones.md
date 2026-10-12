# Conexiones del mundo

> Generado con `python3 tools/mundo/grafo_mundo.py` a partir de los mapas pintados (`maps/**/*.tscn`). No se edita a mano: se vuelve a generar al pintar o unir mapas.

Bordes = `MapConnection` (se pasa andando, sin fundido; `span` = solo un tramo del borde). Pasarelas = `Warp` (ferris, avión, Cercanías). Los interiores aún no existen.

## Grupos de mapas unidos entre sí

- Se llega desde San Miguel de Bernuy (83 mapas): `barcelona/barceloneta/hospital`, `barcelona/ciutat_vella`, `barcelona/eixample`, `barcelona/estanco`, `barcelona/hospital`, `barcelona/les_corts`, `barcelona/les_corts/mercadona`, `barcelona/mercadona`, `getafe/casa_vecina`, `getafe/centro`, `getafe/estanco`, `getafe/exterior`, `getafe/mercadona`, `ibiza/centro`, `ibiza/estanco`, `ibiza/exterior`, `ibiza/mercadona`, `leganes/centro`, `leganes/estanco`, `leganes/exterior`, `leganes/mercadona`, `madrid/atocha/mercadona`, `madrid/centro`, `madrid/chamberi`, `madrid/chamberi/estanco`, `madrid/chamberi/mercadona`, `madrid/estanco`, `madrid/hospital`, `madrid/mercadona`, `madrid/moncloa`, `madrid/palacio_real`, `madrid/retiro`, `madrid/sol/hospital`, `malaga/estanco`, `malaga/exterior`, `malaga/hospital`, `malaga/mercadona`, `maritima_1/exterior`, `mostoles/centro`, `mostoles/estanco`, `mostoles/exterior`, `mostoles/mercadona`, `palma/centro`, `palma/estanco`, `palma/exterior`, `palma/mercadona`, `pueblo_inicial/exterior`, `puertollano/centro`, `puertollano/estanco`, `puertollano/exterior`, `puertollano/mercadona`, `ruta_1/exterior`, `ruta_2/exterior`, `ruta_21/exterior`, `ruta_22/exterior`, `ruta_23/cuellar/mercadona`, `ruta_23/exterior`, `ruta_24/exterior`, `ruta_25/exterior`, `ruta_26/exterior`, `ruta_3/exterior`, `ruta_4/exterior`, `ruta_5/exterior`, `ruta_6/exterior`, `ruta_7/exterior`, `ruta_8/exterior`, `valencia/ciutat_vella`, `valencia/estanco`, `valencia/hospital`, `valencia/malvarrosa`, `valencia/malvarrosa/estanco`, `valencia/malvarrosa/hospital`, `valencia/malvarrosa/mercadona`, `valencia/mercadona`, `valencia/turia`, `valladolid/estanco`, `valladolid/exterior`, `valladolid/hospital`, `valladolid/mercadona`, `zaragoza/centro`, `zaragoza/estanco`, `zaragoza/exterior`, `zaragoza/mercadona`
- **Aislado del pueblo inicial** (28 mapas): `huelva/centro`, `huelva/estanco`, `huelva/exterior`, `huelva/mercadona`, `las_palmas/canteras`, `las_palmas/estanco`, `las_palmas/hospital`, `las_palmas/mercadona`, `las_palmas/vegueta_triana`, `playa_del_ingles/estanco`, `playa_del_ingles/exterior`, `playa_del_ingles/hospital`, `playa_del_ingles/mercadona`, `ruta_12/exterior`, `ruta_13/exterior`, `ruta_14/exterior`, `ruta_15/exterior`, `ruta_16/exterior`, `sevilla/centro`, `sevilla/estanco`, `sevilla/hospital`, `sevilla/maria_luisa`, `sevilla/mercadona`, `sevilla/rio`, `vigo/centro`, `vigo/estanco`, `vigo/exterior`, `vigo/mercadona`

## Uniones pendientes

- `ruta_16/exterior` → `ruta_17/exterior` (borde north): el mapa de destino aún no existe.

## Mapa por mapa

| Mapa | Nombre | Bordes | Pasarelas |
|---|---|---|---|
| `barcelona/barceloneta/hospital` | Hospital · Barceloneta | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/ciutat_vella` | Barcelona · Ciutat Vella | north → `barcelona/eixample` | FerryPalma → `palma/exterior`, Hospital → `barcelona/barceloneta/hospital` |
| `barcelona/eixample` | Barcelona · Eixample | west → `barcelona/les_corts`, south → `barcelona/ciutat_vella` | Hospital → `barcelona/hospital`, Mercadona → `barcelona/mercadona`, Estanco → `barcelona/estanco` |
| `barcelona/estanco` | Estanco · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/hospital` | Hospital · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/les_corts` | Barcelona · Les Corts | west → `ruta_8/exterior`, east → `barcelona/eixample` | Mercadona → `barcelona/les_corts/mercadona` |
| `barcelona/les_corts/mercadona` | Mercadona · Les Corts | — | Salida → `barcelona/les_corts` |
| `barcelona/mercadona` | Mercadona · Barcelona | — | Salida → `barcelona/eixample` |
| `getafe/casa_vecina` | Casa de la vecina / Getafe | — | Salida → `getafe/exterior` |
| `getafe/centro` | Centro Pokémon · Getafe | — | Salida → `getafe/exterior` |
| `getafe/estanco` | Estanco · Getafe | — | Salida → `getafe/exterior` |
| `getafe/exterior` | Getafe | south → `ruta_24/exterior`, west → `leganes/exterior` | CasaVecina → `getafe/casa_vecina`, Centro → `getafe/centro`, Mercadona → `getafe/mercadona`, Estanco → `getafe/estanco` |
| `getafe/mercadona` | Mercadona · Getafe | — | Salida → `getafe/exterior` |
| `huelva/centro` | Centro Pokémon · Huelva | — | Salida → `huelva/exterior` |
| `huelva/estanco` | Estanco · Huelva | — | Salida → `huelva/exterior` |
| `huelva/exterior` | Huelva | east → `ruta_14/exterior` | FerryCanarias → `las_palmas/canteras`, Centro → `huelva/centro`, Mercadona → `huelva/mercadona`, Estanco → `huelva/estanco` |
| `huelva/mercadona` | Mercadona · Huelva | — | Salida → `huelva/exterior` |
| `ibiza/centro` | Centro Pokémon · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/estanco` | Estanco · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/exterior` | Ibiza | north → `maritima_1/exterior` | FerryValencia → `valencia/malvarrosa`, Centro → `ibiza/centro`, Mercadona → `ibiza/mercadona`, Estanco → `ibiza/estanco` |
| `ibiza/mercadona` | Mercadona · Ibiza | — | Salida → `ibiza/exterior` |
| `las_palmas/canteras` | Las Palmas · Las Canteras | south → `las_palmas/vegueta_triana` | FerryHuelva → `huelva/exterior`, Mercadona → `las_palmas/mercadona` |
| `las_palmas/estanco` | Estanco · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/hospital` | Hospital · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/mercadona` | Mercadona · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/vegueta_triana` | Las Palmas · Vegueta y Triana | north → `las_palmas/canteras`, south → `ruta_15/exterior` | Hospital → `las_palmas/hospital`, Estanco → `las_palmas/estanco` |
| `leganes/centro` | Centro Pokémon · Leganés | — | Salida → `leganes/exterior` |
| `leganes/estanco` | Estanco · Leganés | — | Salida → `leganes/exterior` |
| `leganes/exterior` | Leganés | west → `mostoles/exterior`, east → `getafe/exterior` | CercaniasAtocha → `madrid/retiro`, Centro → `leganes/centro`, Mercadona → `leganes/mercadona`, Estanco → `leganes/estanco` |
| `leganes/mercadona` | Mercadona · Leganés | — | Salida → `leganes/exterior` |
| `madrid/atocha/mercadona` | Mercadona · Atocha | — | Salida → `madrid/retiro` |
| `madrid/centro` | Madrid · Sol y Gran Vía | west → `madrid/moncloa`, west → `madrid/palacio_real`, east → `madrid/retiro`, east → `madrid/retiro` | Hospital → `madrid/sol/hospital` |
| `madrid/chamberi` | Madrid · Chamberí | west → `madrid/moncloa` | Mercadona → `madrid/chamberi/mercadona`, Estanco → `madrid/chamberi/estanco` |
| `madrid/chamberi/estanco` | Estanco · Chamberí | — | Salida → `madrid/chamberi` |
| `madrid/chamberi/mercadona` | Mercadona · Chamberí | — | Salida → `madrid/chamberi` |
| `madrid/estanco` | Estanco · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/hospital` | Hospital · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/mercadona` | Mercadona · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/moncloa` | Madrid · Moncloa | west → `ruta_4/exterior`, east → `madrid/centro`, east → `madrid/chamberi` | Hospital → `madrid/hospital`, Mercadona → `madrid/mercadona`, Estanco → `madrid/estanco` |
| `madrid/palacio_real` | Madrid · Palacio Real | east → `madrid/centro` | — |
| `madrid/retiro` | Madrid · Retiro y Prado | west → `madrid/centro`, west → `madrid/centro`, east → `ruta_5/exterior` | CercaniasLeganes → `leganes/exterior`, CercaniasMostoles → `mostoles/exterior`, Mercadona → `madrid/atocha/mercadona` |
| `madrid/sol/hospital` | Hospital · Sol | — | Salida → `madrid/centro` |
| `malaga/estanco` | Estanco · Málaga | — | Salida → `malaga/exterior` |
| `malaga/exterior` | Málaga | north → `ruta_26/exterior` | Hospital → `malaga/hospital`, Mercadona → `malaga/mercadona`, Estanco → `malaga/estanco` |
| `malaga/hospital` | Hospital · Málaga | — | Salida → `malaga/exterior` |
| `malaga/mercadona` | Mercadona · Málaga | — | Salida → `malaga/exterior` |
| `maritima_1/exterior` | Ruta marítima 1 · Canal de Ibiza | north → `palma/exterior`, south → `ibiza/exterior` | — |
| `mostoles/centro` | Centro Pokémon · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/estanco` | Estanco · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/exterior` | Móstoles | east → `leganes/exterior` | CercaniasAtocha → `madrid/retiro`, Centro → `mostoles/centro`, Mercadona → `mostoles/mercadona`, Estanco → `mostoles/estanco` |
| `mostoles/mercadona` | Mercadona · Móstoles | — | Salida → `mostoles/exterior` |
| `palma/centro` | Centro Pokémon · Palma | — | Salida → `palma/exterior` |
| `palma/estanco` | Estanco · Palma | — | Salida → `palma/exterior` |
| `palma/exterior` | Palma de Mallorca | south → `maritima_1/exterior` | FerryBarcelona → `barcelona/ciutat_vella`, Centro → `palma/centro`, Mercadona → `palma/mercadona`, Estanco → `palma/estanco` |
| `palma/mercadona` | Mercadona · Palma | — | Salida → `palma/exterior` |
| `playa_del_ingles/estanco` | Estanco · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/exterior` | Playa del Inglés | north → `ruta_15/exterior` | AvionVigo → `vigo/exterior`, Hospital → `playa_del_ingles/hospital`, Mercadona → `playa_del_ingles/mercadona`, Estanco → `playa_del_ingles/estanco` |
| `playa_del_ingles/hospital` | Hospital · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/mercadona` | Mercadona · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `pueblo_inicial/exterior` | San Miguel de Bernuy | west → `ruta_23/exterior`, south → `ruta_1/exterior` | — |
| `puertollano/centro` | Centro Pokémon · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/estanco` | Estanco · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/exterior` | Puertollano | south → `ruta_25/exterior`, north → `ruta_24/exterior` | Centro → `puertollano/centro`, Mercadona → `puertollano/mercadona`, Estanco → `puertollano/estanco` |
| `puertollano/mercadona` | Mercadona · Puertollano | — | Salida → `puertollano/exterior` |
| `ruta_1/exterior` | Ruta 1 · Hoces del Duratón | north → `pueblo_inicial/exterior`, south → `ruta_2/exterior` | — |
| `ruta_12/exterior` | Ruta 12 · Sierra Nevada y Granada | west → `ruta_13/exterior` | — |
| `ruta_13/exterior` | Ruta 13 · Mar de olivos | east → `ruta_12/exterior`, west → `sevilla/centro` | — |
| `ruta_14/exterior` | Ruta 14 · Doñana | east → `sevilla/rio`, west → `huelva/exterior` | — |
| `ruta_15/exterior` | Ruta 15 · Costa de Gran Canaria | north → `las_palmas/vegueta_triana`, south → `playa_del_ingles/exterior` | — |
| `ruta_16/exterior` | Ruta 16 · Rías Baixas | south → `vigo/exterior`, north → `ruta_17/exterior` | — |
| `ruta_2/exterior` | Ruta 2 · Tierra de Pinares y Acueducto | north → `ruta_1/exterior`, south → `ruta_3/exterior` | — |
| `ruta_21/exterior` | Ruta 21 · Viñedos de La Rioja | south → `ruta_22/exterior` | — |
| `ruta_22/exterior` | Ruta 22 · Burgos y Atapuerca | north → `ruta_21/exterior`, south → `valladolid/exterior` | — |
| `ruta_23/cuellar/mercadona` | Mercadona · Cuéllar | — | Salida → `ruta_23/exterior` |
| `ruta_23/exterior` | Ruta 23 · Cuéllar y Tierra de Pinares | west → `valladolid/exterior`, east → `pueblo_inicial/exterior` | Mercadona → `ruta_23/cuellar/mercadona` |
| `ruta_24/exterior` | Ruta 24 · La Mancha | south → `puertollano/exterior`, north → `getafe/exterior` | — |
| `ruta_25/exterior` | Ruta 25 · Despeñaperros | south → `ruta_26/exterior`, north → `puertollano/exterior` | — |
| `ruta_26/exterior` | Ruta 26 · El Torcal de Antequera | south → `malaga/exterior`, north → `ruta_25/exterior` | — |
| `ruta_3/exterior` | Ruta 3 · Puerto de Navacerrada | north → `ruta_2/exterior`, south → `ruta_4/exterior` | — |
| `ruta_4/exterior` | Ruta 4 · El Escorial y Galapagar | north → `ruta_3/exterior`, east → `madrid/moncloa` | — |
| `ruta_5/exterior` | Ruta 5 · Corredor del Henares | west → `madrid/retiro`, east → `ruta_6/exterior` | — |
| `ruta_6/exterior` | Ruta 6 · Medinaceli y Calatayud | west → `ruta_5/exterior`, east → `zaragoza/exterior` | — |
| `ruta_7/exterior` | Ruta 7 · Los Monegros | west → `zaragoza/exterior`, east → `ruta_8/exterior` | — |
| `ruta_8/exterior` | Ruta 8 · Montserrat | west → `ruta_7/exterior`, east → `barcelona/les_corts` | — |
| `sevilla/centro` | Sevilla · Centro | east → `ruta_13/exterior`, west → `sevilla/rio`, south → `sevilla/maria_luisa` | Hospital → `sevilla/hospital`, Mercadona → `sevilla/mercadona`, Estanco → `sevilla/estanco` |
| `sevilla/estanco` | Estanco · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/hospital` | Hospital · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/maria_luisa` | Sevilla · Plaza de España | north → `sevilla/centro` | — |
| `sevilla/mercadona` | Mercadona · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/rio` | Sevilla · Río y Triana | east → `sevilla/centro`, west → `ruta_14/exterior` | — |
| `valencia/ciutat_vella` | Valencia · Ciutat Vella | north → `valencia/turia` | Hospital → `valencia/hospital`, Mercadona → `valencia/mercadona`, Estanco → `valencia/estanco` |
| `valencia/estanco` | Estanco · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/hospital` | Hospital · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/malvarrosa` | Valencia · Malvarrosa | west → `valencia/turia` | FerryIbiza → `ibiza/exterior`, Hospital → `valencia/malvarrosa/hospital`, Mercadona → `valencia/malvarrosa/mercadona`, Estanco → `valencia/malvarrosa/estanco` |
| `valencia/malvarrosa/estanco` | Estanco · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/malvarrosa/hospital` | Hospital · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/malvarrosa/mercadona` | Mercadona · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/mercadona` | Mercadona · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/turia` | Valencia · Jardín del Turia | south → `valencia/ciutat_vella`, east → `valencia/malvarrosa` | — |
| `valladolid/estanco` | Estanco · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/exterior` | Valladolid | east → `ruta_23/exterior`, north → `ruta_22/exterior` | Hospital → `valladolid/hospital`, Mercadona → `valladolid/mercadona`, Estanco → `valladolid/estanco` |
| `valladolid/hospital` | Hospital · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/mercadona` | Mercadona · Valladolid | — | Salida → `valladolid/exterior` |
| `vigo/centro` | Centro Pokémon · Vigo | — | Salida → `vigo/exterior` |
| `vigo/estanco` | Estanco · Vigo | — | Salida → `vigo/exterior` |
| `vigo/exterior` | Vigo | north → `ruta_16/exterior` | AvionGranCanaria → `playa_del_ingles/exterior`, Centro → `vigo/centro`, Mercadona → `vigo/mercadona`, Estanco → `vigo/estanco` |
| `vigo/mercadona` | Mercadona · Vigo | — | Salida → `vigo/exterior` |
| `zaragoza/centro` | Centro Pokémon · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/estanco` | Estanco · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/exterior` | Zaragoza | west → `ruta_6/exterior`, east → `ruta_7/exterior` | Centro → `zaragoza/centro`, Mercadona → `zaragoza/mercadona`, Estanco → `zaragoza/estanco` |
| `zaragoza/mercadona` | Mercadona · Zaragoza | — | Salida → `zaragoza/exterior` |
