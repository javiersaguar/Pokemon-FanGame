# Guion de Pokémon Spain: historia, diálogos y lore

> **Borrador para que Javier lo retoque.** Humor negro sobre la España actual, sin líneas rojas (decisión de Javier, 2026-10-08), apoyado en lo que cada personaje es en la vida real y en sus memes más conocidos de redes. Todo es **propuesta**: nada de esto está en el juego hasta que Javier lo apruebe.
>
> **Ya en el juego (2026-10-12):** los cuatro textos de los líderes, la Liga, el Clan PSOE y los famosos que salen aquí están pasados a `data/trainers/liga.json` y `famosos.json`; las líneas **Extra** y las escenas de la historia, todavía no.
>
> **Cómo se pasa al juego.** Cada entrenador tiene cuatro textos en `data/trainers/*.json`: **Antes** = `intro_text` (cuando te ve), **Pierde** = `lose_text` (cuando le ganas), **Gana** = `win_text` (si pierdes tú), **Después** = `after_text` (si le hablas otra vez). Las líneas **Extra** son para NPCs, carteles o escenas. Dónde está cada uno: `data/personajes_en_el_mapa.json` y [`gimnasios.md`](gimnasios.md).

## 1. La historia

### El punto de partida

Eres de **San Miguel de Bernuy** (Segovia), un pueblo de la España vaciada con más vacas que vecinos y una sola cobertura: la del bar. El día que cumples la edad de tener tu primer Pokémon, el pueblo entero (doce personas) sale a despedirte. Tu madre te da un táper. Tu rival te da envidia.

- **Madre:** "Llévate el táper. Y si te dan una beca, cógela, que en Madrid un piso cuesta un riñón y los riñones no se recuperan."
- **Abuelo del bar:** "Cuando yo era joven nos íbamos a Alemania. Ahora os vais a Madrid. Lo mismo, pero con más IVA."
- **Rival (primera vez):** "Yo voy a ser Campeón. Tú, como mucho, influencer."

### El Clan PSOE

El villano de la aventura es el **Clan PSOE**, liderado por el **Líder Supremo, Pedro Sánchez**. Su plan: hacerse con los Pokémon legendarios de España para "garantizar la estabilidad" (es decir, no convocar elecciones nunca). Sus administradores:

- **José Luis Ábalos**: el que firma los contratos. Siempre acompañado de su asistente.
- **Koldo**: el asistente. Lleva las cajas. Nadie sabe qué hay en las cajas. Él dice que "mascarillas".
- **Leire Díez, "la fontanera"**: trabaja en las **cloacas de Madrid**, borrando pruebas y arreglando "fugas".
- **Los reclutas**: con chaleco rojo y un argumentario que repiten de memoria.

El Clan aparece por toda la región: en Moncloa, en Ferraz, en la Albufera, en Pamplona… y en cada ciudad intenta llevarse algo (el agua de Doñana, el aceite de Jaén, las entradas de la Alhambra). El **Falcon** del Líder Supremo aparece aparcado en los aeropuertos: el de Gran Canaria, el de Vigo…

### Arco por arco

1. **Madrid (medalla 1, Ayuso)**: llegas a la capital y descubres que la Liga se juega en el Palacio Real. Ayuso te recibe en su ático: "Aquí se viene a ser libre y a pagar el alquiler". Primer encuentro con reclutas del Clan en Moncloa.
2. **Barcelona (medalla 2, Laporta)**: el Camp Nou está en obras y Laporta ha vendido hasta las palancas. Ibai y Piqué organizan la Kings League en La Masia. El Clan intenta "pactar" con todo el mundo.
3. **Valencia (medalla 3, Labrador)**: Akuarela, la Albufera y la paella. Ábalos aparece por primera vez en la Albufera "de vacaciones".
4. **Sevilla (medalla 4, Joaquín)**: el club de la comedia; Sergio Ramos en la Maestranza. Koldo intenta llevarse el agua de Doñana en cajas.
5. **Las Palmas (medalla 5, Quevedo)**: el concierto en la playa. El Falcon está en el aeropuerto: el Líder Supremo ha venido a "una reunión" (es una boda).
6. **Bilbao (medalla 6, la chica del *Aupa Athletic*)**: San Mamés y los Williams.
7. **Valladolid (medalla 7, Latasa)**: la Plaza Mayor helada. **Javier**, el creador del juego, te espera para combatir cuando vuelves con siete medallas (y revancha después de la Liga).
8. **Málaga (medalla 8, Banderas)**: el rodaje. Julio Iglesias en su yate: "Y lo sabes".
9. **Las cloacas de Madrid**: bajas a por Leire Díez, la fontanera, y descubres el plan del Clan.
10. **La Liga en el Palacio Real**: Iniesta, Nadal, Gasol y Alonso. Al final, el **Líder Supremo** en persona, que llega en el Falcon.
11. **El Salón del Trono**: **Felipe VI** te inscribe en el Hall de la Fama. **Juan Carlos** está en las regatas de Sanxenxo y te escribe una postal desde Abu Dabi.

### El final

- **Felipe VI:** "Enhorabuena. Has hecho en un viaje lo que mi familia lleva siglos sin hacer: ganarse el puesto."
- **Créditos:** "Pokémon Spain. Hecho sin ánimo de lucro. Ningún político ha sido dañado durante el desarrollo de este juego. Bueno, alguno sí, pero ya venía así."

## 2. Los líderes de gimnasio

### 1 · Isabel Díaz Ayuso (Madrid, Fuego)
- **Antes:** "Bienvenido a Madrid, la capital de la libertad. Aquí combates con una caña en la mano o no combates."
- **Pierde:** "Esto es cosa del Gobierno. Me voy a tomar una caña con mi medalla y con la tuya."
- **Gana:** "Libertad… para ganarte."
- **Después:** "Desde mi ático se ve todo Madrid. Y todo lo que ha hecho mal el Gobierno."
- **Extra:** "Comunismo o libertad. Tú elige: o me ganas o te pongo una multa por no tomar cañas." · "A mí me gusta la fruta. Sobre todo la que tiene el Gobierno." · "En Madrid nadie te pregunta de dónde eres. Te preguntan cuánto pagas de alquiler."

### 2 · Joan Laporta (Barcelona, Acero)
- **Antes:** "Benvingut al Camp Nou. Bueno, a lo que hay del Camp Nou. Activo una palanca y te gano."
- **Pierde:** "Al loro, que no estamos tan mal… Toma la medalla, que es lo único que no he vendido."
- **Gana:** "¡Visca el Barça! Y visca les palanques."
- **Después:** "El estadio estará listo en 2026. O en 2027. Lo importante es que la grúa ya es del club."
- **Extra:** "He vendido el 25 % de la tele, el 49 % de la tienda y el 100 % de mi paciencia." · "¿Negreira? No me suena. ¿Es un Pokémon nuevo?"

### 3 · Labrador (Valencia, Lucha)
- **Antes:** "¿Tú vienes a entrenar o a mirar? Aquí, en Akuarela, el que no suda no liga."
- **Pierde:** "Me has ganado, tete. Me voy al gimnasio a llorar. Bueno, a entrenar llorando."
- **Gana:** "¡La tensión, la tensión! Esto es Gandía Shore, nene."
- **Después:** "Mi Machamp tiene cuatro brazos y los cuatro con bíceps. Yo tengo dos y ya me cuesta."
- **Extra:** "Lo que pasa en Akuarela se queda en Akuarela. Y en los vídeos de los guiris."

### 4 · Joaquín Sánchez (Sevilla, Planta)
- **Antes:** "¡Illo! ¿Sabes el chiste del Pokémon que se fue a Triana? Pues empieza cuando te gane."
- **Pierde:** "¡Me has dejado más seco que el Guadalquivir en agosto! Toma la medalla, anda, que me haces gracia."
- **Gana:** "¡Viva er Betis manque pierda! Pero hoy no ha perdido."
- **Después:** "¿Otro chiste? Va: un Bulbasaur entra en un bar…"
- **Extra:** "Me retiré a los 41 y ahora me paso el día en la tele contando chistes. Como un político, pero con gracia." · "Mi mujer dice que soy el novio de España. España no ha dicho nada, pero tampoco me ha dejado."

### 5 · Quevedo (Las Palmas, Agua)
- **Antes:** "Quédate… a ver cómo te gano en mi isla."
- **Pierde:** "Te quedas con la medalla. Yo me quedo con la canción, que da más dinero."
- **Gana:** "Esto suena mejor que la sesión 52."
- **Después:** "Nací en Madrid, pero me crié aquí. Por eso mis Pokémon son de agua: aquí todo acaba en la playa."
- **Extra:** "Las fans llevan dos días en la fila. Yo llevo dos días durmiendo." · "¿Columbia? Es una canción, no un viaje."

### 6 · La chica del *Aupa Athletic* (Bilbao, Lucha/Fuego) — la del vídeo (decidido por Javier)
- **Antes:** "¡Aupa Athletic! En San Mamés se viene a sufrir… y hoy sufres tú."
- **Pierde:** "Agur, medalla. Pero que sepas que en Copa te gano."
- **Gana:** "¡Athletic, eup! Aquí solo ganan los de casa."
- **Después:** "Grabé un vídeo diciendo «¡Aupa Athletic!» y ahora soy líder de gimnasio. Así funciona internet."

### 7 · Juanmi Latasa (Valladolid, Hielo)
- **Antes:** "En Valladolid hace un frío que pela. Y yo, en el área, también."
- **Pierde:** "Me has dejado helado. Toma, una medalla y un lechazo para el camino."
- **Gana:** "Gol del Pucela. Que no se diga que no sabemos ganar."
- **Después:** "Aquí en invierno se patina en la Plaza Mayor. Sin querer."

### 8 · Antonio Banderas (Málaga, Siniestro)
- **Antes:** "¡Silencio, se rueda! Escena final: el Zorro derrota al aspirante. ¡Acción!"
- **Pierde:** "¡Corten! Esa no estaba en el guion. Toma la medalla y no se lo digas al productor… que soy yo."
- **Gana:** "Y el Óscar es para… bueno, para mí no, pero la medalla tampoco es para ti."
- **Después:** "He vuelto a Málaga para hacer teatro, cine y Semana Santa. A la vez."
- **Extra:** "En Hollywood me llamaban Antonio. Aquí me llaman 'el de la Semana Santa'."

## 3. Los entrenadores de los gimnasios

Están en `data/trainers/gimnasios.json` con estos textos (Antes / Pierde / Gana / Después):

- **Madrid:** Borja, padre con la tarjeta ("Mi padre me ha pagado el máster, el piso y este combate") · Paco, camarero ("Terraza llena, tres cañas en la mano y aún me queda una para combatir") · Cayetana, influencer ("Estoy orgullosa de anunciar que voy a ganarte. #Libertad #Emprendimiento").
- **Barcelona:** Jordi, tertuliano culé ("¡El Camp Nou estará acabado para 2026! ¿Qué año es? Bueno, pues 2027") · Pau, carterista ("¿Tu cartera? Ni idea. ¿Tu medalla? Esa la quiero") · Montse, revisora de Rodalies ("Este tren sufre un retraso de cuarenta minutos. Hasta entonces, combatimos").
- **Valencia:** Vicent, crossfitero · Rubén, tronista ("Vengo de Mujeres y Hombres a buscar el amor") · Nerea, raver.
- **Sevilla:** Manolo, el cuñado ("¿Monólogos? Yo hago monólogos en todas las comidas familiares") · Lola, flamenca · Curro, costalero.
- **Las Palmas:** Saray, fan de Quevedo · Yeray, surfista · Airam, nadador.
- **Bilbao:** Aitor, crossfitero · Iñaki, tertuliano ("En San Mamés se viene a sufrir") · Josu, camarero de pintxos.
- **Valladolid:** Álvaro, esquiador · Sergio, opositor eterno ("Este combate es el tema 214") · Elena, montañera.
- **Málaga:** Brian, turista extra de la película · Marta, productora ("Lo arreglamos en postproducción") · Antonio, el del catering ("Te sirvo un espeto… de derrota").

## 4. La Liga (Palacio Real)

- **Andrés Iniesta (Psíquico):** **Antes:** "Iniesta de mi vida… ¿te acuerdas? Yo sí. Cada día." **Pierde:** "No pasa nada. Ya marqué el gol más importante de la historia; este me lo puedo dejar." **Gana:** "Minuto 116. Como en Johannesburgo." **Extra:** "Dani Jarque, siempre con nosotros."
- **Rafa Nadal (Tierra):** **Antes:** "¡Vamos! Catorce Roland Garros. Tú no vas a ser el primero que me gane en tierra." **Pierde:** "Me retiro. Otra vez. Esta vez de verdad." **Gana:** "¡Vamos! Y ahora, a colocar las botellas en su sitio."
- **Pau Gasol (Dragón):** **Antes:** "Dos anillos de la NBA. El tercero te lo quito a ti." **Pierde:** "Buen partido. En Los Ángeles se habría llenado el pabellón." **Gana:** "Altura, técnica y un Dragonite que mide lo que yo."
- **Fernando Alonso (Eléctrico):** **Antes:** "La 33 está al caer. Y tú, también." **Pierde:** "¡Motor de GP2! ¡Motor de GP2!" **Gana:** "Karma." **Después:** "Tengo cuarenta y tantos y sigo corriendo. Tú tienes doce y ya estás cansado." **Extra:** "El Plan funciona. Lo que no funciona es el coche."

### El Líder Supremo: Pedro Sánchez
- **Antes:** "Me tomé cinco días para reflexionar si combatir contigo. He decidido que sí. Por el bien de España."
- **Pierde:** "Esto no es una derrota. Es un cambio de opinión."
- **Gana:** "Manual de resistencia, capítulo uno: no dimitir nunca."
- **Después:** "Si me buscas, estaré en el Falcon. O en Marruecos. O en la fachosfera, que no sé dónde está pero existe."
- **Extra:** "Esto es una campaña del fango." · "Yo no he cambiado de opinión. He evolucionado. Como un Eevee."

## 5. El Clan PSOE

- **Recluta:** "¡Por el Líder Supremo! ¡Y por la siguiente legislatura!" · **Pierde:** "Me van a abrir un expediente…" · **Extra:** "El argumentario dice que no hay argumentario."
- **José Luis Ábalos:** **Antes:** "Yo no sé nada. Pregúntale a Koldo." **Pierde:** "Esto es una persecución. Me voy al Grupo Mixto." **Extra:** "¿Jessica? No conozco a ninguna Jessica. Bueno, conozco a varias."
- **Koldo:** **Antes:** "¿Qué hay en las cajas? Mascarillas. Y chistorras. Y soles. Y lechugas." **Pierde:** "Esto no estaba en el contrato." **Extra:** "Yo solo era el que llevaba las cosas. Y el que las traía. Y el que las contaba."
- **Leire Díez, la fontanera:** **Antes:** "En las cloacas no hay fugas. Yo me encargo." **Pierde:** "Llamad al fontanero. Ah, no, que soy yo." **Extra:** "Aquí abajo se arregla todo. Arriba, nada."

## 6. Los famosos, uno a uno

Cada uno con su sitio (si está colocado), sus cuatro textos y alguna línea extra. Los textos de `data/trainers/famosos.json` son la base; aquí van propuestas para mejorarlos.

### Madrid
- **Ester Expósito** (Gran Vía, en su estreno). **Antes:** "Es mi estreno y tú estás en medio de la alfombra roja." **Pierde:** "Ya me pasaba en Élite: siempre gana el que menos te esperas." **Gana:** "¡Corten! Me quedo con este plano."
- **David Broncano** (Teatro Príncipe, *La Revuelta*). **Antes:** "Dos preguntas: ¿cuánto dinero tienes en el banco? ¿Y cuántos combates has ganado este mes?" **Pierde:** "Esto en El Hormiguero no pasa. Allí tienen hormigas." **Gana:** "Jorge, ¿qué hora es? ¡La hora de ganarte!"
- **Chicote y Pedroche** (Puerta del Sol, campanadas; combate doble). **Chicote, antes:** "¡Esto es una pocilga! ¿Quién ha dejado este combate sin fregar?" **Pedroche, antes:** "Este año el vestido es un Pokémon. No digo cuál." **Pierden:** "¡Que se nos pasan las uvas!" · **Extra (Pedroche):** "Llevo veinte años dando las campanadas. Y el vestido de este año es transparente, como el Gobierno."
- **Santiago Abascal** (Puerta del Congreso, a caballo). **Antes:** "¡Santiago y cierra combate!" **Pierde:** "Me vuelvo a la reconquista. En caballo, que el coche contamina." **Gana:** "España, una, grande y mía."
- **Vito Quiles y Bertrand Ndongo** (Puerta del Congreso; doble). **Vito, antes:** "¿Cuándo vas a dimitir? ¡Responde a la pregunta!" **Bertrand, antes:** "Lo estoy grabando todo." **Pierden:** "Esto es censura. Lo subo a X." · **Extra (Vito):** "Soy periodista. Bueno, tengo un micrófono, que es casi lo mismo."
- **José Luis Martínez-Almeida** (Cibeles). **Antes:** "Soy alcalde de Madrid y del Atleti. Las dos cosas sufren igual." **Pierde:** "Esto lo arreglo con una obra. Otra." **Gana:** "¡Aúpa Atleti! Bueno, aquí no, aquí… ¡Aúpa Madrid!"
- **Enrique Iglesias** (camino del Bernabéu). **Antes:** "Bailando, bailando… ¿te bailo y te gano?" **Pierde:** "Experiencia religiosa, la tuya." **Gana:** "Héroe. Así me llaman."
- **Jorge Javier Vázquez y Belén Esteban** (plató de televisión; doble). **Jorge Javier, antes:** "Soy rojo y maricón, y te voy a ganar." **Belén, antes:** "¡Yo por mis Pokémon MATO!" **Pierden:** "¡Andreíta, cómete el pollo!" · **Extra (Belén):** "Llevo treinta años en la tele hablando de mí. Y aún no he terminado."

### Barcelona y la Ruta 8
- **Laporta**: ver líderes.
- **Ibai y Piqué** (Kings League, La Masia; doble). **Ibai, antes:** "¡Qué pasa, chavales! Esto es la Velada de los Pokémon." **Piqué, antes:** "Esto es la Kings League: aquí las reglas las pongo yo. Y las cambio." **Pierden:** "Esto lo arreglamos con una carta secreta." · **Extra (Piqué):** "Cambié un Ferrari por un Twingo y un Rolex por un Casio. Y una medalla por ti, parece."
- **Lamine Yamal** (Camp Nou, viene de Rocafonda). **Antes:** "Tengo diecisiete años y más títulos que tú. ¡Rocafonda 304!" **Pierde:** "Me voy, que mañana tengo examen de mates." **Gana:** "304, hermano."
- **HustleHard304 y Keyne** (con Lamine; van por separado). **Antes:** "Con Lamine se gana. Contra él, no." · "Somos del barrio. El barrio no pierde."
- **Aitana** (de gira, Palau Sant Jordi). **Antes:** "Mon amour, mon amour… ¿combatimos?" **Pierde:** "Me voy a Los Ángeles a escribir una canción sobre esto." **Gana:** "Otra canción de amor. La tuya, de derrota."
- **Rosalía** (Sant Esteve Sesrovires, su pueblo). **Antes:** "Chicken teriyaki, chicken teriyaki… y combate." **Pierde:** "Saoko, papi, saoko. Me voy en moto." **Gana:** "Motomami, motomami."
- **Pep Guardiola** (Santpedor, su pueblo). **Antes:** "Te voy a hacer un rondo que no vas a tocar la bola." **Pierde:** "Felicidades. Es un orgullo perder contra alguien así." **Gana:** "115 cargos y ni uno por esto." **Extra:** "Me quedo calvo de pensar en ti. Bueno, ya lo era."

### Valencia, Murcia y Alicante
- **Ferran Torres** (el Turia). **Antes:** "¡Tiburón! Nado en el Turia aunque no tenga agua." **Pierde:** "Vuelvo a Foios a por fuerzas." **Gana:** "Gol, y me pongo las aletas."
- **Juan Roig** (junto al Mercado Central). **Antes:** "En Mercadona la cultura es del esfuerzo. Y la tuya, de perder." **Pierde:** "Te hago un descuento: Hacendado." **Gana:** "El jefe soy yo. Lo pone en la puerta."
- **Ilia Topuria** (Alicante, pendiente). **Antes:** "El Matador no pierde. Y tú tampoco vas a ser el primero."
- **Vito Quiles** también en la Ruta 11 (Elche, su ciudad): "¿Otra vez tú? ¡Responde: ¿cuándo dimites?!"

### Andalucía
- **Sergio Ramos** (junto a la Maestranza). **Antes:** "Minuto 93. Siempre aparezco en el 93." **Pierde:** "Me han expulsado. Pero que conste que fue con elegancia." **Gana:** "92:48. Apúntalo." **Extra:** "Además de futbolista soy cantante. Lo segundo no lo sabe nadie."
- **Rubiales y Jenni Hermoso** (la boda del cortijo, Ruta 12; doble). **Rubiales, antes:** "¡No voy a dimitir! ¡No voy a dimitir! ¡No voy a dimitir!" **Jenni, antes:** "Campeona del mundo. A ver qué traes tú." **Pierden:** "Esto es un falso feminismo de los combates." (Rubiales) · "Se acabó." (Jenni) · **Extra (cartel de la boda):** "Aviso de los novios: aquí los besos se piden antes de darlos."
- **Julio Iglesias** (su yate, Muelle Uno). **Antes:** "Soy el padre de todos los Pokémon de España… y lo sabes." **Pierde:** "Me voy a mi yate a cantar 'Me olvidé de vivir'." **Gana:** "Y lo sabes." **Extra:** "Tengo tres mil canciones y tres mil… bueno, y lo sabes."
- **Mario Casas** (el rodaje de Banderas). **Antes:** "Tres metros sobre el cielo y yo, en el suelo de este rodaje." **Pierde:** "Me voy a quitar la camiseta, que me sienta mejor perder sin ella." **Gana:** "¡Hache nunca pierde!"
- **Coto Matamoros** (el paseo marítimo de Málaga). **Antes:** "Yo opino de todo. Y de ti, también." **Pierde:** "Esto en el plató lo arreglo gritando más fuerte." **Gana:** "Lo dije en la tertulia: ibas a perder."

### El norte
- **Juan Carlos I** (regatas de Sanxenxo). **Antes:** "Lo siento mucho, me he equivocado, no volverá a ocurrir. Pero antes, combatimos." **Pierde:** "Me vuelvo a Abu Dabi. Allí no hay Pokémon ni Hacienda." **Gana:** "Campechano, pero no tonto." **Extra:** "En Botsuana cacé elefantes. Aquí cazo regatas."
- **Pereira7** (una cafetería de Vigo). **Antes:** "Un café y un combate, por favor. El café lo pagas tú."
- **ElXokas** (Ruta 17, pendiente). **Antes:** "¡Bo día! Te voy a ganar en gallego, que duele más."
- **Amancio Ortega** (Ruta 17, Arteixo, pendiente). **Antes:** "Mis Pokémon visten de Zara. Y los tuyos, de rebajas." **Pierde:** "Dono la medalla a un hospital."
- **Melendi** (Ruta 18, pendiente). **Antes:** "Caminando por la vida… me he encontrado contigo." **Pierde:** "Tengo un vicio: perder contigo."
- **Nico e Iñaki Williams** (San Mamés, pendiente; doble). **Antes:** "¡Dos hermanos, una banda!" **Pierden:** "Ya nos vengaremos en Copa."

### Castilla y el centro
- **Juanmi Latasa**: ver líderes.
- **Sarah Santaolalla** (tertulia de radio, Valladolid). **Antes:** "En la tertulia digo lo que pienso. Y pienso que vas a perder." **Pierde:** "Lo comentamos después de la publicidad."
- **Óscar Puente** (camino de la estación de Valladolid). **Antes:** "Soy ministro de Transportes. Este combate sale con retraso, como todos." **Pierde:** "Lo tuiteo y lo arreglo. O no." **Gana:** "Puntualidad británica. Bueno, británica no, de Renfe."
- **Folagor, Sekiam y PokeAlex** (la tienda de cartas de Getafe; van por separado). **Folagor:** "¿Sabías que Pokémon Spain no existe? Pues te gano igual." **Sekiam:** "Mi equipo está en el top del ranking. Del mío." **PokeAlex:** "Esto es un evento competitivo. Gana el que más sobres abra."
- **Pablo Iglesias e Irene Montero** (su chalet de Galapagar; doble). **Pablo, antes:** "Cuando vivía en Vallecas era más de izquierdas. Ahora tengo piscina." **Irene, antes:** "Solo sí es sí. ¿Combatimos?" **Pierden:** "Esto es lawfare." · **Extra (Pablo):** "Me corté la coleta y ahora tengo una taberna. La revolución, de cañas."
- **Francisco Franco** (Valle de Cuelgamuros, Ruta 3). **Antes:** "Franco ha muerto. Bueno, más o menos." **Pierde:** "Me voy a Mingorrubio. Otra vez." **Gana:** "Cuarenta años sin perder… y ahora esto." **Extra (cartel):** "Aquí estuvo enterrado hasta 2019. El Pokémon fantasma que ves no tiene nada que ver. O sí."
- **Vegeta777 y Willyrex** (camino de Andorra, salida de Zaragoza; doble). **Antes:** "Nos vamos a Andorra. Allí los combates pagan menos impuestos." **Pierden:** "Nos lo deducimos."
- **Javier, el creador** (Valladolid, con siete medallas): **Antes:** "Hola. Soy el que ha hecho este juego. Si encuentras un error, es una característica." **Pierde:** "Bien jugado. Te subo el nivel de los líderes en el próximo parche." **Gana:** "El creador siempre gana. Lo pone en el contrato."

## 7. Para seguir

- Pasar los textos que Javier apruebe a `data/trainers/*.json`.
- Escribir las escenas del Clan PSOE como eventos (`src/events/`): Moncloa, Ferraz, la Albufera, Doñana, el aeropuerto de Gran Canaria, las cloacas y la Liga.
- Decidir con Javier: si los tríos son combate triple o tres seguidos, qué personajes quiere cambiar de sitio y cómo sale él (pelo, ropa y equipo) para su combate con siete medallas.

## 8. Los gimnasios por dentro (2026-10-14)

Según [`DECISIONES_JAVIER_2026-10-14.md`](../DECISIONES_JAVIER_2026-10-14.md). **Todo lo que no lleva «Frase de Javier» es propuesta, pendiente de que Javier lo corrija a mano**: equipos, frases y el lore resumido de cada personaje. Los textos están en `data/trainers/gimnasios.json`; si se cambian allí, esta sección se rehace con el script de datos.

**Cómo es cada gimnasio:** tres salas en fila y la del líder. Cada sala es un zigzag de tres tramos: en cada tramo hay un entrenador, y el paso al tramo siguiente lo tapa un vigilante que solo se aparta al ganarle. No se puede llegar al líder sin ganar a todos (lo comprueba `tests/mundo/test_gimnasios_salas.gd`).

### 1 · Madrid — Medalla Libertad

Entrenadores de sala: Concejales del PP con chaleco y pulsera.

**Real Casa de Correos · Registro**

- **Concejal Borja Mari** (`gym1_concejal_1`), equipo: growlithe nv. 10, litleo nv. 11.
  - **Antes:** «Soy concejal de Urbanismo. Ese solar es zona verde hasta que yo diga lo contrario. ¡Combate recalificado!» **Pierde:** «Lo recurriré. Tengo un primo en el Constitucional.» **Gana:** «Aprobado por mayoría absoluta: la mía.» **Después:** «En Madrid se viene a trabajar. O a que trabajen otros, que también es libertad.»
- **Concejal Pelayo** (`gym1_concejal_2`), equipo: houndour nv. 11, ponyta nv. 11.
  - **Antes:** «He inaugurado esta rotonda tres veces. La cuarta, contigo dentro. ¡A combatir!» **Pierde:** «Esto es culpa de la herencia recibida.» **Gana:** «Otra inauguración. Traed la cinta.» **Después:** «Bajamos impuestos todos los años. A los mismos, pero todos los años.»
- **Alcalde Almeida** (`almeida_gym`), equipo: numel nv. 12, slugma nv. 12, fletchling nv. 12. *Lore:* Alcalde de Madrid y atlético confeso; se le parodia por las obras, los túneles y las talas de árboles.
  - **Antes:** «¿Tú otra vez? Vengo de inaugurar un túnel y de ver perder al Atleti. Hoy pago mis penas contigo.» **Pierde:** «Otra derrota. Estoy entrenado: soy del Atleti.» **Gana:** «Madrid es la ciudad más segura del mundo. Para mí.» **Después:** «He talado dos mil árboles para que se vea mejor el asfalto. De nada.»

**Real Casa de Correos · Grupo Popular**

- **Concejal Jacobo** (`gym1_concejal_3`), equipo: vulpix nv. 12, torchic nv. 12.
  - **Antes:** «Llevo la pulsera con la bandera, el chaleco acolchado y un acta de concejal. ¿Qué llevas tú?» **Pierde:** «Me he quedado sin argumentario.» **Gana:** «España va bien. Yo, mejor.» **Después:** «La presidenta nos pasa el argumentario a las ocho. A las ocho y cinco ya lo creemos.»
- **Concejal Gonzalo** (`gym1_concejal_4`), equipo: tepig nv. 12, litten nv. 13.
  - **Antes:** «Soy concejal de Urbanismo. Ese solar es zona verde hasta que yo diga lo contrario. ¡Combate recalificado!» **Pierde:** «Lo recurriré. Tengo un primo en el Constitucional.» **Gana:** «Aprobado por mayoría absoluta: la mía.» **Después:** «En Madrid se viene a trabajar. O a que trabajen otros, que también es libertad.»
- **Expresidente Rajoy** (`rajoy_gym`), equipo: cyndaquil nv. 13, charmander nv. 13, magby nv. 13. *Lore:* Presidente del Gobierno de 2011 a 2018, hasta la moción de censura. Registrador de la propiedad, lector del *Marca*, caminante rápido y autor de frases circulares («es el vecino el que elige al alcalde…»).
  - **Antes:** «Mire usted: un combate es un combate y un Pokémon es un Pokémon. Y cuanto peor, mejor para todos; y cuanto peor para todos, mejor.» **Pierde:** «Fin de la cita.» **Gana:** «Es el vecino el que elige al ganador, y es el ganador el que quiere que sean los vecinos el ganador.» **Después:** «Yo me voy a andar rápido y a leer el Marca. Lo demás ya tal.»

**Real Casa de Correos · Archivo de Títulos**

- **Concejal Álvaro** (`gym1_concejal_5`), equipo: fennekin nv. 13, growlithe nv. 13.
  - **Antes:** «He inaugurado esta rotonda tres veces. La cuarta, contigo dentro. ¡A combatir!» **Pierde:** «Esto es culpa de la herencia recibida.» **Gana:** «Otra inauguración. Traed la cinta.» **Después:** «Bajamos impuestos todos los años. A los mismos, pero todos los años.»
- **Concejal Íñigo** (`gym1_concejal_6`), equipo: scorbunny nv. 13, houndour nv. 14.
  - **Antes:** «Llevo la pulsera con la bandera, el chaleco acolchado y un acta de concejal. ¿Qué llevas tú?» **Pierde:** «Me he quedado sin argumentario.» **Gana:** «España va bien. Yo, mejor.» **Después:** «La presidenta nos pasa el argumentario a las ocho. A las ocho y cinco ya lo creemos.»
- **Máster Pablo Casado** (`casado`), equipo: fuecoco nv. 14, litleo nv. 14, ponyta nv. 14. *Lore:* Presidente del PP de 2018 a 2022. Su máster de la Universidad Rey Juan Carlos, convalidado casi entero, fue un escándalo en 2018; el Supremo no vio delito. **Frase de Javier.**
  - **Antes:** «Si pude robar el máster, no me robarás la victoria.» **Pierde:** «Este combate también me lo convalidan, ¿no?» **Gana:** «Aprobado sin ir a clase. Como siempre.» **Después:** «Tengo el título colgado en el despacho. El despacho ya no lo tengo.»

**Real Casa de Correos · Despacho de la Presidenta**

- **Ayuso** espera en su despacho y te sube a la terraza de su ático de Chamberí; allí se combate por la medalla (sus frases, en el §2).

### 2 · Barcelona — Medalla Palanca

Entrenadores de sala: Socios y fans del Barça entre grúas.

**Spotify Camp Nou · Túnel de Vestuarios**

- **Culé Jordi** (`gym2_cule_1`), equipo: magnemite nv. 17, aron nv. 18.
  - **Antes:** «¡Visca el Barça! Soy socio desde antes de nacer. Mi carné lo tiene mi abuelo, que tampoco puede entrar: hay obras.» **Pierde:** «Això és un robatori. Como siempre.» **Gana:** «Més que un club. Més que un combat.» **Después:** «El estadio estará terminado el año que viene. Lo dice el president cada año.»
- **Culé Pau** (`gym2_cule_2`), equipo: klink nv. 18, bronzor nv. 18.
  - **Antes:** «He hipotecado el piso para el abono. Y el club ha hipotecado el club. ¡Vamos empatados!» **Pierde:** «Otra palanca rota.» **Gana:** «Tiki, taka, y a casa.» **Después:** «Aquí el césped se cambia más que el entrenador. Y eso que el entrenador...»
- **Empresario Piqué** (`pique_gym`), equipo: ferroseed nv. 19, honedge nv. 19, pawniard nv. 19. *Lore:* Central del Barça hasta 2022; empresario (Kosmos, Kings League). La canción de Shakira con Bizarrap le dejó el «clara-mente», el Casio y el Twingo.
  - **Antes:** «He montado una liga, una copa y un negocio con cada uno de los tres. A ti te gano y lo retransmito.» **Pierde:** «Clara-mente, no era mi día.» **Gana:** «Contigo me río. Y cobro.» **Después:** «Cambié un Rolex por un Casio. El Casio da la hora igual y no sale en canciones.»

**Spotify Camp Nou · Sala de Palancas**

- **Culé Arnau** (`gym2_cule_3`), equipo: beldum nv. 18, cufant nv. 19.
  - **Antes:** «Yo vi jugar a Messi aquí. Bueno, vi la grúa que hay donde jugaba Messi. ¡Combate!» **Pierde:** «Culpa del arbitraje. Lo ponía en un informe.» **Gana:** «Así, así, así gana el Barça. A veces.» **Después:** «Dicen que debemos mil millones. Pero con mucho estilo.»
- **Culé Oriol** (`gym2_cule_4`), equipo: tinkatink nv. 19, mawile nv. 19.
  - **Antes:** «¡Visca el Barça! Soy socio desde antes de nacer. Mi carné lo tiene mi abuelo, que tampoco puede entrar: hay obras.» **Pierde:** «Això és un robatori. Como siempre.» **Gana:** «Més que un club. Més que un combat.» **Después:** «El estadio estará terminado el año que viene. Lo dice el president cada año.»
- **Araña Julián Álvarez** (`julian_alvarez`), equipo: magnemite nv. 19, aron nv. 20, skarmory nv. 20. *Lore:* Delantero argentino del Atlético de Madrid, «la Araña». El chiste es que se ha fugado del Metropolitano para irse al Barça. **Frase de Javier.**
  - **Antes:** «¡Por fin he logrado escapar!» **Pierde:** «Me vuelven a encerrar en el Metropolitano.» **Gana:** «¡Gol de la Araña! Y este no me lo anulan.» **Después:** «Salí por la M-30 de noche, con la camiseta del revés. Nadie hizo preguntas.»

**Spotify Camp Nou · Palco**

- **Culé Marc** (`gym2_cule_5`), equipo: klefki nv. 20, bronzor nv. 20.
  - **Antes:** «He hipotecado el piso para el abono. Y el club ha hipotecado el club. ¡Vamos empatados!» **Pierde:** «Otra palanca rota.» **Gana:** «Tiki, taka, y a casa.» **Después:** «Aquí el césped se cambia más que el entrenador. Y eso que el entrenador...»
- **Culé Roger** (`gym2_cule_6`), equipo: pawniard nv. 20, honedge nv. 20.
  - **Antes:** «Yo vi jugar a Messi aquí. Bueno, vi la grúa que hay donde jugaba Messi. ¡Combate!» **Pierde:** «Culpa del arbitraje. Lo ponía en un informe.» **Gana:** «Así, así, así gana el Barça. A veces.» **Después:** «Dicen que debemos mil millones. Pero con mucho estilo.»
- **D10S Messi** (`messi`), equipo: mawile nv. 20, klink nv. 21, skarmory nv. 21. *Lore:* Se marchó del Barça en 2021, llorando en la rueda de prensa, porque el club no podía inscribirle. Su primer contrato se firmó en una servilleta. «¿Qué mirás, bobo? Andá p'allá» es suya, del Mundial de 2022.
  - **Antes:** «¿Qué mirás, bobo? Andá p'allá. Bueno, ya que estás: combatí.» **Pierde:** «Me voy otra vez. Y otra vez llorando.» **Gana:** «Tranquilo. Me pasa desde los trece.» **Después:** «Firmé en una servilleta y me fui en una rueda de prensa. Lo del medio estuvo bien.»

**Spotify Camp Nou · Despacho del President**

- **Líder:** Laporta (sus frases, en el §2).

### 3 · Valencia — Medalla Tirantes

Entrenadores de sala: Gente de fiesta en Akuarela.

**Akuarela Playa · Pista**

- **Alcohólico Vicent** (`gym3_alcoholico_1`), equipo: machop nv. 23, makuhita nv. 23.
  - **Antes:** «¡Hip! Llevo desde las Fallas de 2019 sin salir de aquí. ¿Tú eres el del cubata o el del combate?» **Pierde:** «Camarero, otra. De lo que sea.» **Gana:** «¡Ronda para todos! Paga este.» **Después:** «El agua de Valencia no lleva agua. Me enteré tarde, pero me enteré bien.»
- **Porreta Ximo** (`gym3_porreta_1`), equipo: mankey nv. 24, croagunk nv. 24.
  - **Antes:** «Tranqui, tío... ¿Un combate? Buah, qué pereza. Venga, va, pero despacito.» **Pierde:** «Se me ha ido la olla. Y el Pokémon.» **Gana:** «Buah, tío. He ganado. Creo.» **Después:** «Lo mío es terapéutico. Tengo estrés de no hacer nada.»
- **Cocainómano Borja** (`gym3_cocainomano_1`), equipo: meditite nv. 24, scraggy nv. 24.
  - **Antes:** «¡Eh, eh, eh! Tengo veinte ideas de negocio y te las cuento todas mientras combatimos. ¡YA!» **Pierde:** «Voy un momento al baño y vuelvo.» **Gana:** «¡VAMOS! ¡VAMOS! ¿Otra? ¡Otra!» **Después:** «Llevo tres días sin dormir y nunca he estado más centrado. ¿De qué hablábamos?»

**Akuarela Playa · Reservado**

- **Alcohólico Paco** (`gym3_alcoholico_2`), equipo: tyrogue nv. 24, timburr nv. 24.
  - **Antes:** «Yo controlo. Controlo perfectamente. ¿Cuál de los tres eres tú?» **Pierde:** «Me voy a sentar un momento. En el suelo.» **Gana:** «¡Salud! Y pesetas.» **Después:** «Mañana lo dejo. Lo llevo diciendo desde que esto era una discoteca de las de antes.»
- **Porreta Nando** (`gym3_porreta_2`), equipo: pancham nv. 25, makuhita nv. 25.
  - **Antes:** «¿Tú también oyes el bombo o es mi corazón? Da igual. ¡Combate!» **Pierde:** «Qué mal viaje.» **Gana:** «Paz, hermano. Y victoria.» **Después:** «En la Ruta del Bakalao se bailaba de viernes a lunes. Yo sigo en el domingo.»
- **Cocainómano Kevin** (`gym3_cocainomano_2`), equipo: hitmonlee nv. 25, hitmonchan nv. 25.
  - **Antes:** «Soy muy amigo del dueño. Y del portero. Y tuyo. ¡Te quiero, tío! ¡Combate!» **Pierde:** «Me ha bajado todo de golpe.» **Gana:** «¡Soy el mejor! Lo he dicho yo, así que es verdad.» **Después:** «Esto no es vicio: es networking.»

**Akuarela Playa · Zona Vip**

- **Porreta Rafa** (`gym3_porreta_3`), equipo: croagunk nv. 25, scraggy nv. 26.
  - **Antes:** «Tranqui, tío... ¿Un combate? Buah, qué pereza. Venga, va, pero despacito.» **Pierde:** «Se me ha ido la olla. Y el Pokémon.» **Gana:** «Buah, tío. He ganado. Creo.» **Después:** «Lo mío es terapéutico. Tengo estrés de no hacer nada.»
- **Cocainómano Iván** (`gym3_cocainomano_3`), equipo: hitmontop nv. 26, hawlucha nv. 26.
  - **Antes:** «¡Eh, eh, eh! Tengo veinte ideas de negocio y te las cuento todas mientras combatimos. ¡YA!» **Pierde:** «Voy un momento al baño y vuelvo.» **Gana:** «¡VAMOS! ¡VAMOS! ¿Otra? ¡Otra!» **Después:** «Llevo tres días sin dormir y nunca he estado más centrado. ¿De qué hablábamos?»
- **Dueño Peter Lim** (`peter_lim`), equipo: meditite nv. 26, hariyama nv. 26, falinks nv. 27. *Lore:* Empresario de Singapur, dueño del Valencia CF desde 2014. Casi no pisa Mestalla; la afición le dedica el «Lim go home» y el nuevo estadio lleva años a medias.
  - **Antes:** «Compré el Valencia en 2014 y aún no sé dónde está Mestalla. Me han dicho que aquí se combate.» **Pierde:** «Vendo. A plazos y con cláusula.» **Gana:** «Otro activo que rinde.» **Después:** «Los aficionados me escriben «Lim go home». Yo ya estoy en home: en Singapur.»

**Akuarela Playa · Cabina**

- **Líder:** Labrador (sus frases, en el §2).

### 4 · Sevilla — Medalla Arte

Entrenadores de sala: Sevillanas vestidas de feria. Señoritos de traje en la Feria.

**El Club de la Comedia · Platea**

- **Flamenca Rocío** (`gym4_flamenca_1`), equipo: lombre nv. 29, cherrim nv. 29.
  - **Antes:** «¡Ole! Llevo el traje de gitana desde la Feria de Abril. De la del año pasado. ¡Arsa, a combatir!» **Pierde:** «Ay, qué fatiguita.» **Gana:** «¡Ole, ole y ole!» **Después:** «En la caseta solo se entra si conoces a alguien. Como en todo lo demás en Sevilla.»
- **Flamenco Curro** (`gym4_flamenco_1`), equipo: nuzleaf nv. 29, weepinbell nv. 30.
  - **Antes:** «Traje, corbata y treinta y cinco grados a la sombra. Un señorito no suda: brilla. ¡Combate!» **Pierde:** «Qué poca vergüenza. Con lo bien que iba vestido.» **Gana:** «Con arte. Como tiene que ser.» **Después:** «Tengo caseta propia, caballo propio y deudas propias.»
- **Extremo Antony** (`antony`), equipo: breloom nv. 30, cacnea nv. 30, scovillain nv. 30. *Lore:* Extremo brasileño cedido por el Manchester United al Betis en 2025, donde resucitó; famoso por el giro sobre el balón.
  - **Antes:** «En Mánchester no me querían y en Heliópolis me cantan. Doy tres vueltas sobre el balón y te gano.» **Pierde:** «Me he mareado con mi propio giro.» **Gana:** «¡Musho Betis! Lo digo regular, pero lo siento.» **Después:** «Vine cedido por unos meses. Llevo aquí desde entonces y ya pido la manzanilla sola.»

**El Club de la Comedia · Camerinos**

- **Flamenca Macarena** (`gym4_flamenca_2`), equipo: gloom nv. 30, sunflora nv. 30.
  - **Antes:** «Miarma, aquí se viene a reír y a bailar. Y a combatir, si queda rebujito.» **Pierde:** «Se me ha caído la flor.» **Gana:** «¡Esa es mi niña!» **Después:** «La Feria dura una semana. La resaca, hasta el Rocío.»
- **Cómico Berto Romero** (`berto_romero`), equipo: tropius nv. 30, maractus nv. 31, whimsicott nv. 31. *Lore:* Cómico de Cardona, pareja de Buenafuente en televisión y en el pódcast *Nadie sabe nada*; la nariz es chiste recurrente suyo.
  - **Antes:** «Soy el de al lado de Buenafuente. Sí, el de la nariz. Sí, todavía. ¡Combate!» **Pierde:** «Nadie sabe nada. Yo, menos.» **Gana:** «Mucho que perder, poco que ganar. Y aun así he ganado.» **Después:** «Soy de Cardona. Tenemos un castillo, una mina de sal y a mí. Por ese orden.»

**El Club de la Comedia · Entre Bambalinas**

- **Flamenco Manuel** (`gym4_flamenco_2`), equipo: quilladin nv. 31, floragato nv. 31.
  - **Antes:** «Vengo del Real de la Feria a pie porque el coche de caballos lo tengo en el taller. ¡Vamos allá!» **Pierde:** «Illo, qué ruina.» **Gana:** «Esto se celebra con un fino.» **Después:** «Aquí el que no tiene un primo cofrade no es nadie.»
- **Monologuista Dani Rovira** (`dani_rovira`), equipo: dolliv nv. 32, steenee nv. 32, skiddo nv. 32. *Lore:* Monologuista malagueño; protagonizó *Ocho apellidos vascos* haciendo de sevillano y presentó los Goya tres veces.
  - **Antes:** «Soy de Málaga y me hice famoso haciendo de sevillano que hace de vasco. Así que combatir contigo no me da miedo.» **Pierde:** «Ocho apellidos y ni una victoria.» **Gana:** «¡Viva el Betis manque pierda! Pero hoy gano yo.» **Después:** «Presenté los Goya tres veces. La tercera ya me sabía los chistes malos.»

**El Club de la Comedia · Escenario**

- **Presentador Buenafuente** (`buenafuente`), equipo: grotle nv. 31, servine nv. 31, lilligant nv. 31. *Lore:* Presentador de Reus; décadas de *late night* y de *Nadie sabe nada* con Berto.
  - **Antes:** «Buenas noches. Hoy en el programa: tú, perdiendo. Con todos ustedes, mi equipo.» **Pierde:** «Se nos ha ido el programa de las manos.» **Gana:** «Y hasta aquí el combate de hoy. Sean felices.» **Después:** «Soy de Reus, como el vermut. Lo mío también se toma antes de comer.»
- **Humorista José Mota** (`jose_mota`), equipo: breloom nv. 32, scovillain nv. 33, deerling nv. 33. *Lore:* Humorista manchego (Montiel). «Si hay que ir se va, pero ir pa ná es tontería», «hoy no… mañaaana», «las gallinas que entran por las que van saliendo» y «ahora vas y lo cascas» son de sus sketches.
  - **Antes:** «Si hay que combatir, se combate. Pero combatir pa ná es tontería.» **Pierde:** «Hoy no... ¡mañaaana!» **Gana:** «¡Las gallinas que entran por las que van saliendo!» **Después:** «Ahora vas y lo cascas.»
- **Líder:** Joaquín (sus frases, en el §2).

### 5 · Las Palmas de Gran Canaria — Medalla Quédate

Entrenadores de sala: Fans en bikini en primera fila del concierto.

**Concierto en la Playa · Pista**

- **Quesito Yaiza** (`gym5_quesito_1`), equipo: golduck nv. 35, lumineon nv. 35.
  - **Antes:** «¡Chacho! Llevo todo el día en primera fila esperando a Quevedo. A ti te despacho rápido.» **Pierde:** «Ños, qué palo.» **Gana:** «¡Quédate! Pero perdiendo.» **Después:** «Me sé la sesión entera. La de Bizarrap y las de después.»
- **Quesito Nayra** (`gym5_quesito_2`), equipo: seaking nv. 35, pelipper nv. 36.
  - **Antes:** «Mi niño, aquí se viene con protección cincuenta y con seis Pokémon. ¿Tú qué traes?» **Pierde:** «Me voy a refrescar al agua.» **Gana:** «¡Fuerte calor y fuerte paliza!» **Después:** «En Canarias una hora menos. Por eso siempre llegamos antes a ganarte.»
- **Cantante La Pantera** (`la_pantera`), equipo: sharpedo nv. 36, crawdaunt nv. 36, floatzel nv. 36. *Lore:* Cantante urbano de Las Palmas, de la misma hornada canaria que Quevedo.
  - **Antes:** «Vengo de La Isleta con la música puesta desde el coche. Bájale a tu equipo, que entro yo.» **Pierde:** «Se me fue el flow con la marea.» **Gana:** «De Las Palmas pal mundo.» **Después:** «Aquí grabamos en un cuarto con un colchón en la pared. Ahora el colchón es de marca.»

**Concierto en la Playa · Zona Vip**

- **Quesito Idaira** (`gym5_quesito_3`), equipo: tentacruel nv. 36, kingler nv. 36.
  - **Antes:** «¡Chacho! Llevo todo el día en primera fila esperando a Quevedo. A ti te despacho rápido.» **Pierde:** «Ños, qué palo.» **Gana:** «¡Quédate! Pero perdiendo.» **Después:** «Me sé la sesión entera. La de Bizarrap y las de después.»
- **Quesito Tamara** (`gym5_quesito_4`), equipo: gastrodon nv. 37, whiscash nv. 37.
  - **Antes:** «Mi niño, aquí se viene con protección cincuenta y con seis Pokémon. ¿Tú qué traes?» **Pierde:** «Me voy a refrescar al agua.» **Gana:** «¡Fuerte calor y fuerte paliza!» **Después:** «En Canarias una hora menos. Por eso siempre llegamos antes a ganarte.»
- **Cantante Lucho RK** (`lucho_rk`), equipo: barraskewda nv. 37, octillery nv. 37, lanturn nv. 37. *Lore:* Cantante madrileño muy ligado a la escena canaria, colaborador habitual de Quevedo y La Pantera.
  - **Antes:** «Madrileño de nacimiento y canario de vocación. Mi equipo tampoco sabe de dónde es, pero pega.» **Pierde:** «Me quedé sin estribillo.» **Gana:** «Otra para la lista de éxitos.» **Después:** «Vine a grabar un tema y me quedé por el clima. Y por las papas arrugadas.»

**Concierto en la Playa · Backstage**

- **Quesito Guacimara** (`gym5_quesito_5`), equipo: swanna nv. 37, wailmer nv. 38.
  - **Antes:** «¡Chacho! Llevo todo el día en primera fila esperando a Quevedo. A ti te despacho rápido.» **Pierde:** «Ños, qué palo.» **Gana:** «¡Quédate! Pero perdiendo.» **Después:** «Me sé la sesión entera. La de Bizarrap y las de después.»
- **Quesito Dácil** (`gym5_quesito_6`), equipo: azumarill nv. 38, quagsire nv. 38.
  - **Antes:** «Mi niño, aquí se viene con protección cincuenta y con seis Pokémon. ¿Tú qué traes?» **Pierde:** «Me voy a refrescar al agua.» **Gana:** «¡Fuerte calor y fuerte paliza!» **Después:** «En Canarias una hora menos. Por eso siempre llegamos antes a ganarte.»
- **Rapero Cruz Cafuné** (`cruz_cafune`), equipo: starmie nv. 38, lapras nv. 38, palafin nv. 39. *Lore:* Rapero de Tenerife; el pleito entre islas da el chiste. «Mina el Hammani» es su canción más conocida.
  - **Antes:** «Soy de Tenerife y estoy cantando en Gran Canaria. Eso es más peligroso que tu equipo.» **Pierde:** «Me vuelvo en el ferry.» **Gana:** «Me muero de la risa, como en la canción.» **Después:** «El pleito insular lo resolvemos así: yo canto, ellos aplauden y nadie dice de qué isla es el mojo.»

**Concierto en la Playa · Escenario**

- **Líder:** Quevedo (sus frases, en el §2).

### 6 · Bilbao — Medalla Txapela

Entrenadores de sala: La grada de San Mamés, con pasamontañas «por el frío».

**San Mamés · Grada de Animación**

- **Etarra Aitor** (`gym6_etarra_1`), equipo: machoke nv. 40, hariyama nv. 40.
  - **Antes:** «¡Aupa! El pasamontañas es por el frío de San Mamés, que entra del Nervión. Lo otro ya lo dejé. ¡Combate!» **Pierde:** «Me acojo a mi derecho a no declarar.» **Gana:** «¡Gora el pintxo de después!» **Después:** «Ahora milito en una sociedad gastronómica. Hay más normas que antes.»
- **Etarra Gorka** (`gym6_etarra_2`), equipo: primeape nv. 40, combusken nv. 41.
  - **Antes:** «Yo de aquí no me muevo: estoy empadronado en la grada. ¿Vienes a combatir o a pedir el RH?» **Pierde:** «Esto en Bilbao no pasa. Será que eres de Bilbao.» **Gana:** «Como el Athletic: solo con los de casa.» **Después:** «Dicen que los de Bilbao nacemos donde queremos. Yo nací ganando.»
- **Etarra Iker** (`gym6_etarra_3`), equipo: medicham nv. 41, pangoro nv. 41.
  - **Antes:** «¡Aupa! El pasamontañas es por el frío de San Mamés, que entra del Nervión. Lo otro ya lo dejé. ¡Combate!» **Pierde:** «Me acojo a mi derecho a no declarar.» **Gana:** «¡Gora el pintxo de después!» **Después:** «Ahora milito en una sociedad gastronómica. Hay más normas que antes.»

**San Mamés · Vestuario**

- **Etarra Unai** (`gym6_etarra_4`), equipo: gurdurr nv. 41, scrafty nv. 41.
  - **Antes:** «Yo de aquí no me muevo: estoy empadronado en la grada. ¿Vienes a combatir o a pedir el RH?» **Pierde:** «Esto en Bilbao no pasa. Será que eres de Bilbao.» **Gana:** «Como el Athletic: solo con los de casa.» **Después:** «Dicen que los de Bilbao nacemos donde queremos. Yo nací ganando.»
- **Etarra Asier** (`gym6_etarra_5`), equipo: toxicroak nv. 42, hitmonlee nv. 42.
  - **Antes:** «¡Aupa! El pasamontañas es por el frío de San Mamés, que entra del Nervión. Lo otro ya lo dejé. ¡Combate!» **Pierde:** «Me acojo a mi derecho a no declarar.» **Gana:** «¡Gora el pintxo de después!» **Después:** «Ahora milito en una sociedad gastronómica. Hay más normas que antes.»
- **Delantero Iñaki Williams** (`inaki_williams_gym`), equipo: lucario nv. 42, hawlucha nv. 42, blaziken nv. 42. *Lore:* Delantero del Athletic; encadenó 251 partidos de Liga seguidos, récord histórico. Sus padres cruzaron el Sáhara a pie antes de llegar a Bilbao.
  - **Antes:** «Jugué más de doscientos cincuenta partidos de Liga seguidos sin faltar a uno. A este combate tampoco voy a faltar.» **Pierde:** «Me cambio en el descanso. Que salga mi hermano.» **Gana:** «¡Aupa Athletic!» **Después:** «Mis padres cruzaron el desierto a pie. Yo cruzo la banda derecha. Lo mío tiene menos mérito.»

**San Mamés · Túnel**

- **Etarra Mikel** (`gym6_etarra_6`), equipo: falinks nv. 42, heracross nv. 43.
  - **Antes:** «Yo de aquí no me muevo: estoy empadronado en la grada. ¿Vienes a combatir o a pedir el RH?» **Pierde:** «Esto en Bilbao no pasa. Será que eres de Bilbao.» **Gana:** «Como el Athletic: solo con los de casa.» **Después:** «Dicen que los de Bilbao nacemos donde queremos. Yo nací ganando.»
- **Delantero Nico Williams** (`nico_williams_gym`), equipo: infernape nv. 43, mienfoo nv. 43, grapploct nv. 43. *Lore:* Extremo del Athletic y campeón de Europa en 2024; renovó en vez de irse al Barça.
  - **Antes:** «Medio mundo quiso ficharme y me quedé en casa. Así que hoy tengo tiempo para ganarte.» **Pierde:** «Me has regateado tú a mí. Eso es nuevo.» **Gana:** «Por la banda, como siempre.» **Después:** «Mi hermano me dice lo que tengo que hacer. Luego hago lo contrario y sale bien.»

**San Mamés · Césped**

- **Coordinador Arnaldo Otegi** (`otegi`), equipo: emboar nv. 43, bewear nv. 43, poliwrath nv. 44. *Lore:* Coordinador general de EH Bildu, de cuyos votos depende a veces el Gobierno. Lleva la ikurriña.
  - **Antes:** «Kaixo. Traigo la ikurriña y un discurso de cuarenta minutos. Si prefieres, combatimos, que es más corto.» **Pierde:** «Habrá que abrir un nuevo ciclo político.» **Gana:** «Esto es la voluntad mayoritaria de mi equipo.» **Después:** «Antes daba ruedas de prensa. Ahora doy apoyos de investidura. Se cobra más despacio, pero se cobra.»
- **Líder:** Aupa Athletic (sus frases, en el §2).

### 7 · Valladolid — Medalla Pucela

Entrenadores de sala: Cayetanos de pelo casco de Pucela.

**Plaza Mayor · Soportales**

- **Cayetano Borja** (`gym7_cayetano_1`), equipo: glalie nv. 44, piloswine nv. 44.
  - **Antes:** «Pelo casco, náuticos y chaleco. Mi padre conoce al tuyo: le despidió. ¡Combate!» **Pierde:** «Se lo voy a contar a papá.» **Gana:** «O sea, obvio.» **Después:** «Estudio ADE y Derecho en la privada. Bueno, estudio: voy.»
- **Cayetano Jacobo** (`gym7_cayetano_2`), equipo: jynx nv. 44, sealeo nv. 45.
  - **Antes:** «Vengo de Pucela de toda la vida, tío. De la calle Santiago para arriba. Lo demás es pueblo.» **Pierde:** «Qué ordinariez.» **Gana:** «Ganar es de buena familia.» **Después:** «El pelo no se mueve ni con el cierzo. Es laca de la buena, de la de mi abuela.»
- **Cayetano Pelayo** (`gym7_cayetano_3`), equipo: beartic nv. 45, cloyster nv. 45.
  - **Antes:** «Pelo casco, náuticos y chaleco. Mi padre conoce al tuyo: le despidió. ¡Combate!» **Pierde:** «Se lo voy a contar a papá.» **Gana:** «O sea, obvio.» **Después:** «Estudio ADE y Derecho en la privada. Bueno, estudio: voy.»

**Plaza Mayor · Salón de Plenos**

- **Cayetano Beltrán** (`gym7_cayetano_4`), equipo: vanillish nv. 45, avalugg nv. 45.
  - **Antes:** «Vengo de Pucela de toda la vida, tío. De la calle Santiago para arriba. Lo demás es pueblo.» **Pierde:** «Qué ordinariez.» **Gana:** «Ganar es de buena familia.» **Después:** «El pelo no se mueve ni con el cierzo. Es laca de la buena, de la de mi abuela.»
- **Cayetano Tristán** (`gym7_cayetano_5`), equipo: abomasnow nv. 46, dewgong nv. 46.
  - **Antes:** «Pelo casco, náuticos y chaleco. Mi padre conoce al tuyo: le despidió. ¡Combate!» **Pierde:** «Se lo voy a contar a papá.» **Gana:** «O sea, obvio.» **Después:** «Estudio ADE y Derecho en la privada. Bueno, estudio: voy.»
- **Ministro de Transportes Óscar Puente** (`oscar_puente_gym`), equipo: weavile nv. 46, lapras nv. 46, arctibax nv. 46. *Lore:* Alcalde de Valladolid de 2015 a 2023 y luego ministro de Transportes; se le conoce por los retrasos de los trenes y por bloquear y contestar en redes. Segunda aparición.
  - **Antes:** «Fui alcalde de esta plaza y ahora soy ministro de trenes. Llego tarde al combate, pero es por una incidencia en la catenaria.» **Pierde:** «Te bloqueo. En el combate y en redes.» **Gana:** «El tren ha llegado a su hora. Hacedle una foto.» **Después:** «El tren vive el mejor momento de su historia. Lo digo yo, que soy quien lo dice.»

**Plaza Mayor · Palco del Zorrilla**

- **Cayetano Rodrigo** (`gym7_cayetano_6`), equipo: froslass nv. 46, cryogonal nv. 47.
  - **Antes:** «Vengo de Pucela de toda la vida, tío. De la calle Santiago para arriba. Lo demás es pueblo.» **Pierde:** «Qué ordinariez.» **Gana:** «Ganar es de buena familia.» **Después:** «El pelo no se mueve ni con el cierzo. Es laca de la buena, de la de mi abuela.»
- **Cayetano Álvaro** (`gym7_cayetano_7`), equipo: frosmoth nv. 47, eiscue nv. 47.
  - **Antes:** «Pelo casco, náuticos y chaleco. Mi padre conoce al tuyo: le despidió. ¡Combate!» **Pierde:** «Se lo voy a contar a papá.» **Gana:** «O sea, obvio.» **Después:** «Estudio ADE y Derecho en la privada. Bueno, estudio: voy.»
- **Presidente Ronaldo Nazário** (`ronaldo_nazario`), equipo: walrein nv. 47, glaceon nv. 47, mamoswine nv. 48. *Lore:* El Fenómeno. Compró el Real Valladolid en 2018 y lo vendió en 2025, con varios descensos y la afición en contra por su ausencia. **Frase de Javier**, por un episodio de 2008.
  - **Antes:** «Yo no sabía que eran travestis.» **Pierde:** «Vendo el club. Otra vez.» **Gana:** «Fenómeno. Me lo dicen desde el 96.» **Después:** «Compré el Valladolid y lo vi dos veces: al firmar y al vender. Entre medias bajó, subió y volvió a bajar.»

**Plaza Mayor · Balcón del Ayuntamiento**

- **Líder:** Latasa (sus frases, en el §2).

### 8 · Málaga — Medalla Zorro

Entrenadores de sala: Actores de reparto del rodaje.

**Rodaje en el Puerto · Catering**

- **Actor de reparto Paco** (`gym8_actor_1`), equipo: mightyena nv. 49, liepard nv. 49.
  - **Antes:** «Soy el camarero número dos de la película. Tengo una frase: «¿Algo más?». ¡Y un combate!» **Pierde:** «Corten. Esta toma no vale.» **Gana:** «¡Mi mejor escena!» **Después:** «Llevo veinte años haciendo de policía que muere el primero. Ya ni me maquillan.»
- **Actor de reparto Curro** (`gym8_actor_2`), equipo: cacturne nv. 49, thievul nv. 50.
  - **Antes:** «Me presenté al casting de protagonista. Me han dado «transeúnte con paraguas». ¡Combate dramático!» **Pierde:** «Nominado a nada, otra vez.» **Gana:** «¡Y el Goya es para mí!» **Después:** «En el cine español comemos todos los días. Del catering, pero todos los días.»
- **Actor Mario Casas** (`mario_casas_gym`), equipo: houndoom nv. 50, zoroark nv. 50, absol nv. 50. *Lore:* Actor gallego; *Tres metros sobre el cielo* y *Tengo ganas de ti* le hicieron ídolo adolescente. Segunda aparición.
  - **Antes:** «Me he quitado la camiseta para esta escena. Y para la siguiente. Y para el combate.» **Pierde:** «Tres metros bajo el suelo.» **Gana:** «Tengo ganas de ti. De ganarte, digo.» **Después:** «En el guion pone «H. entra y mira intensamente». Llevo quince años mirando intensamente.»

**Rodaje en el Puerto · Camerinos**

- **Actor de reparto Antonio** (`gym8_actor_3`), equipo: skuntank nv. 50, sableye nv. 50.
  - **Antes:** «Soy el camarero número dos de la película. Tengo una frase: «¿Algo más?». ¡Y un combate!» **Pierde:** «Corten. Esta toma no vale.» **Gana:** «¡Mi mejor escena!» **Después:** «Llevo veinte años haciendo de policía que muere el primero. Ya ni me maquillan.»
- **Actriz Ester Expósito** (`ester_exposito_gym`), equipo: umbreon nv. 50, weavile nv. 51, liepard nv. 51. *Lore:* Actriz de *Élite* y fenómeno de redes. Segunda aparición, después de Madrid.
  - **Antes:** «¿Otra vez tú? En Madrid me pillaste entre dos rodajes. Aquí tengo camerino, maquilladora y ganas.» **Pierde:** «Esto no lo subo a redes.» **Gana:** «Otro millón de seguidores.» **Después:** «Hice de niña rica en un instituto donde moría alguien cada curso. Luego dicen de la pública.»

**Rodaje en el Puerto · Maquillaje**

- **Actor de reparto Manolo** (`gym8_actor_4`), equipo: krookodile nv. 51, drapion nv. 51.
  - **Antes:** «Me presenté al casting de protagonista. Me han dado «transeúnte con paraguas». ¡Combate dramático!» **Pierde:** «Nominado a nada, otra vez.» **Gana:** «¡Y el Goya es para mí!» **Después:** «En el cine español comemos todos los días. Del catering, pero todos los días.»
- **Brazo de la ley Torrente** (`torrente`), equipo: obstagoon nv. 51, malamar nv. 51, pangoro nv. 51. *Lore:* El personaje de Santiago Segura: expolicía casposo, del Atleti y del Fary, «el brazo tonto de la ley».
  - **Antes:** «José Luis Torrente, policía. Bueno, expolicía. Bueno: aficionado. Del Atleti y del Fary. ¡Venga, que te invito a que me invites!» **Pierde:** «Esto con Franco no pasaba.» **Gana:** «¡Toma, toma y toma! Apúntalo en mi cuenta.» **Después:** «Yo soy el brazo tonto de la ley. Pero brazo, ¿eh? Que conste.»
- **Actriz Penélope Cruz** (`penelope_cruz`), equipo: honchkrow nv. 52, meowscarada nv. 52, zoroark nv. 52. *Lore:* De Alcobendas; Óscar en 2009 por *Vicky Cristina Barcelona* y musa de Almodóvar («¡Pedrooo!» lo gritó ella al darle su Óscar).
  - **Antes:** «¡Pedrooo! Ah, no, que no eres Pedro. Da igual: tengo un Óscar y lo sé usar.» **Pierde:** «Corten. Repetimos y esta vez gano yo.» **Gana:** «And the winner is... yo.» **Después:** «Soy de Alcobendas. Lo digo en inglés, en italiano y en francés, y suena igual de bien.»

**Rodaje en el Puerto · Plató**

- **Actor Javier Bardem** (`javier_bardem`), equipo: incineroar nv. 52, bisharp nv. 52, grimmsnarl nv. 53. *Lore:* Óscar en 2008 por *No es país para viejos*; de saga de actores (su madre, Pilar Bardem; su tío, el director Juan Antonio Bardem).
  - **Antes:** «He hecho de narco, de poeta, de villano de Bond y de gusano de arena, casi. Hacer de tu rival me sale solo.» **Pierde:** «Otra nominación sin premio.» **Gana:** «Hay que decirlo más: he ganado.» **Después:** «Mi madre era actriz, mi abuelo era actor y mi tío dirigía. En mi casa el que no actuaba fregaba.»
- **Líder:** Banderas (sus frases, en el §2).
