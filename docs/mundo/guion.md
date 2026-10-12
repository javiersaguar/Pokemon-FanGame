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
