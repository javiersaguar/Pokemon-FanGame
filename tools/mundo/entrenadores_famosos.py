#!/usr/bin/env python3
"""Clases y entrenadores de los personajes de Pokémon Spain (docs/mundo/personajes.md).

Escribe sus clases en data/trainer_classes.json (una por personaje: el título que sale
antes del nombre y su sprite) y sus combates en data/trainers/liga.json (líderes,
Alto Mando, Líder Supremo y Clan PSOE) y data/trainers/famosos.json (el resto).
Comprueba que las especies existen en data/generated/species.json.

Quiénes salen: decisión de Javier. Tipos, equipos, niveles y frases: propuesta
(PENDIENTE JAVIER). Uso: python3 tools/mundo/entrenadores_famosos.py
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CLASSES = os.path.join(ROOT, "data", "trainer_classes.json")
TRAINERS = os.path.join(ROOT, "data", "trainers")
SPECIES = os.path.join(ROOT, "data", "generated", "species.json")

# id: (título, nombre, sexo, ai, dinero base, música [intro, combate], fichero, equipo [(especie, nivel)], frases)
LEADER = ("encounter_tough", "battle_gym_leader")
ELITE = ("encounter_tough", "battle_elite_four")
CHAMPION = ("encounter_villain", "battle_champion")
CLAN = ("encounter_villain", "battle_villain")
FAMOUS = ("encounter_smart", "battle_trainer")


def lines(intro, lose, win="", after=""):
    return {"intro_text": intro, "lose_text": lose, "win_text": win or "Ja. Vuelve cuando sepas combatir.", "after_text": after or lose}


PEOPLE = {
    # --- Gimnasios (decisión de Javier: líder, ciudad y lugar) ---
    "ayuso": ("Líder", "Ayuso", "female", 3, 120, LEADER, "liga",
              [("growlithe", 12), ("litleo", 12), ("arcanine", 14)],
              lines("Bienvenido a Madrid, la capital de la libertad. Aquí combates con una caña en la mano o no combates.",
                    "Esto es cosa del Gobierno. Me voy a tomar una caña con mi medalla y con la tuya.",
                    "Libertad... para ganarte.", "Desde mi ático se ve todo Madrid. Y todo lo que ha hecho mal el Gobierno.")),
    "laporta": ("Líder", "Laporta", "male", 3, 120, LEADER, "liga",
                [("magnemite", 19), ("bronzor", 19), ("klefki", 20), ("copperajah", 21)],
                lines("Benvingut al Camp Nou. Bueno, a lo que hay del Camp Nou. Activo una palanca y te gano.",
                      "He activado todas las palancas... y ni así. La temporada que viene, el estadio al cien por cien.",
                      "Una palanca más y ganamos la Champions.", "El estadio estará acabado... la temporada que viene.")),
    "labrador": ("Líder", "Labrador", "male", 3, 120, LEADER, "liga",
                 [("mankey", 25), ("hariyama", 25), ("pawmot", 26), ("machamp", 27)],
                 lines("¿Tú vienes a entrenar o a mirar? Aquí, en Akuarela, el que no suda no liga.",
                       "Me has ganado, tío. Me voy a hacer una serie de bíceps para olvidarlo.",
                       "Hoy es día de pierna. Y tú, de perder.", "Esta noche hay fiesta en la terraza. Tú no entras.")),
    "joaquin": ("Líder", "Joaquín", "male", 3, 120, LEADER, "liga",
                [("sunflora", 31), ("lilligant", 31), ("tsareena", 32), ("meowscarada", 33)],
                lines("¡Illo! ¿Sabes el chiste del Pokémon que se fue a Triana? Pues empieza cuando te gane.",
                      "¡Me has dejado más seco que el Guadalquivir en agosto! Toma la medalla, anda, que me haces gracia.",
                      "¡Viva er Betis manque pierda! Pero hoy no ha perdido.", "¿Otro chiste? Va: un Bulbasaur entra en un bar...")),
    "quevedo": ("Líder", "Quevedo", "male", 3, 120, LEADER, "liga",
                [("wishiwashi", 37), ("lanturn", 37), ("barraskewda", 38), ("palafin", 39)],
                lines("Quédate... a ver cómo te gano en mi isla.", "Te quedas con la medalla. Yo me quedo con la playa.",
                      "Quédate... en el Centro Pokémon.", "La playa del Inglés es mía. La medalla, ya es tuya.")),
    "aupa_athletic": ("Líder", "Aupa Athletic", "female", 3, 120, LEADER, "liga",
                      [("pignite", 42), ("hawlucha", 42), ("blaziken", 43), ("infernape", 44)],
                      lines("¡Aupa Athletic! En La Catedral solo se gana con cantera.",
                            "¡Qué nivel! Ni en la final de Copa lloré tanto.", "¡Aupa! ¡A la gabarra!",
                            "San Mamés siempre canta. Hoy canta por ti.")),
    "latasa": ("Líder", "Latasa", "male", 3, 120, LEADER, "liga",
               [("cetitan", 46), ("glalie", 46), ("avalugg", 47), ("baxcalibur", 48)],
               lines("En Valladolid hace un frío que pela. Y yo, en el área, más.", "Gol en propia. Te la has ganado, la medalla.",
                     "Y otro gol para el Pucela.", "En invierno, la Plaza Mayor es una pista de hielo. Y yo, el que marca.")),
    "banderas": ("Líder", "Banderas", "male", 3, 120, LEADER, "liga",
                 [("sneasel", 51), ("absol", 51), ("hydreigon", 52), ("zoroark", 53)],
                 lines("¡Silencio, se rueda! Escena final: el Zorro derrota al aspirante. Toma una.",
                       "¡Corten! Me has robado la escena. Y la medalla. Vuelve cuando quieras al Soho.",
                       "Toma buena. Se imprime.", "La próxima película la ruedo contigo de protagonista. O de extra.")),
    # --- Alto Mando y Líder Supremo (decisión de Javier) ---
    "iniesta": ("Alto Mando", "Iniesta", "male", 4, 160, ELITE, "liga",
                [("espeon", 57), ("bronzong", 57), ("hatterene", 58), ("indeedee", 58), ("slowking", 59), ("gardevoir", 60)],
                lines("No hace falta correr. Hace falta ver el pase antes que nadie.", "Has visto el pase antes que yo. Enhorabuena.")),
    "nadal": ("Alto Mando", "Nadal", "male", 4, 160, ELITE, "liga",
              [("hippowdon", 57), ("excadrill", 57), ("krookodile", 58), ("mamoswine", 58), ("donphan", 59), ("garchomp", 60)],
              lines("En tierra batida no he perdido casi nunca. Vamos.", "¡Vamos! Bien jugado. Hasta el último punto.")),
    "gasol": ("Alto Mando", "Gasol", "male", 4, 160, ELITE, "liga",
              [("haxorus", 57), ("kingdra", 57), ("flygon", 58), ("goodra", 58), ("salamence", 59), ("dragonite", 60)],
              lines("Desde aquí arriba veo todos tus movimientos.", "Me has ganado el rebote. Y el partido.")),
    "alonso": ("Alto Mando", "Alonso", "male", 4, 160, ELITE, "liga",
               [("magnezone", 58), ("rotom", 58), ("jolteon", 59), ("electivire", 59), ("ironhands", 60), ("regieleki", 61)],
               lines("El 33 llegará. Hoy, por ejemplo.", "GP2 engine, GP2... digo, buen combate.")),
    "pedro_sanchez": ("Líder Supremo", "Pedro Sánchez", "male", 4, 200, CHAMPION, "liga",
                      [("corviknight", 61), ("toxapex", 61), ("gholdengo", 62), ("hydreigon", 62), ("annihilape", 63), ("kingambit", 65)],
                      lines("He resistido mociones, investigaciones y cinco años de campaña. Un niño con ocho medallas no es nada. Manual de resistencia, capítulo uno.",
                            "Convocaré elecciones... cuando me venga bien.", "Ya lo decía yo: hay Gobierno para rato.")),
    # --- Clan PSOE (propuesta de trama) ---
    "abalos": ("Dúo del Clan", "Ábalos", "male", 2, 60, CLAN, "liga",
               [("mimikyu", 10), ("liepard", 11)],
               lines("¡Prepárate para los problemas! ¡Y más vale que tengas mascarillas!", "¡El Clan PSOE vuelve a despegar...!")),
    "koldo": ("Dúo del Clan", "Koldo", "male", 2, 60, CLAN, "liga",
              [("timburr", 10), ("gurdurr", 11)],
              lines("¡Y yo soy Koldo! ¡El que lleva los sobres!", "¡El Clan PSOE vuelve a despegar...!")),
    "leire_diez": ("Fontanera del Clan", "Leire", "female", 3, 80, CLAN, "liga",
                   [("grimer", 22), ("swalot", 22), ("muk", 23), ("toxapex", 24)],
                   lines("Yo no investigo a nadie. Solo arreglo tuberías... y expedientes.",
                         "Esto no ha pasado. Y si ha pasado, es periodismo.")),
    # --- Famosos (decisión de Javier: quiénes; sitio, equipo y frases: propuesta) ---
    "ibai": ("Streamer", "Ibai", "male", 2, 60, FAMOUS, "famosos",
             [("munchlax", 20), ("snorlax", 21), ("grimmsnarl", 22)],
             lines("¡Chat, chat! ¡Que nos han retado en directo! Esto es contenido.", "Esto lo cortamos del directo. Tú no has visto nada.")),
    "lamine": ("Crack", "Lamine", "male", 3, 80, FAMOUS, "famosos",
               [("cinderace", 22), ("zeraora", 23)],
               lines("304, ¿sabes lo que es? Pues ahora lo vas a saber.", "Tengo 19 años. Ya te ganaré cuando sea mayor.")),
    "hustlehard304": ("Padre orgulloso", "HustleHard304", "male", 2, 60, FAMOUS, "famosos",
                      [("obstagoon", 21), ("bisharp", 22)],
                      lines("¡Ese es mi hijo! ¡Y esto es Rocafonda!", "Todo lo que digan de mi hijo, que me lo digan a mí.")),
    "keyne": ("Hermano pequeño", "Keyne", "male", 1, 20, FAMOUS, "famosos",
              [("pichu", 18), ("fidough", 19)],
              lines("¡Mi hermano es el mejor del mundo!", "¡Se lo voy a decir a mi hermano!")),
    "rosalia": ("Motomami", "Rosalía", "female", 2, 60, FAMOUS, "famosos",
                [("flabebe", 18), ("lopunny", 19), ("primarina", 20)],
                lines("Chiqui chiqui chi... ¡Saoko! Ahora te toca a ti.", "Qué malamente. Me voy a hacer otro disco.")),
    "enrique_iglesias": ("Cantante", "Enrique", "male", 2, 60, FAMOUS, "famosos",
                         [("lombre", 14), ("toucannon", 15), ("ludicolo", 16)],
                         lines("Bailando, bailando... ¡te voy a ganar bailando!", "Quiero ser tu héroe, pero hoy no ha podido ser.")),
    "julio_iglesias": ("Cantante", "Julio", "male", 2, 80, FAMOUS, "famosos",
                       [("lapras", 50), ("milotic", 51), ("gyarados", 52)],
                       lines("Y lo sabes. Te voy a ganar... y lo sabes.", "He perdido mil veces en mi vida. Esta es la mil una.")),
    "sergio_ramos": ("Defensa", "Sergio Ramos", "male", 3, 60, FAMOUS, "famosos",
                     [("rapidash", 31), ("taurospaldeacombat", 32), ("granbull", 33)],
                     lines("Minuto 93. Siempre aparezco en el 93.", "Me han expulsado. Pero que conste que fue con elegancia.")),
    "guardiola": ("Entrenador", "Pep", "male", 3, 80, FAMOUS, "famosos",
                  [("alakazam", 19), ("metagross", 20), ("porygonz", 21)],
                  lines("La posesión es lo más importante. Y la tuya es muy mejorable.", "Era un tema de... ¿cómo se dice? De talento. El tuyo.")),
    "pique": ("Empresario", "Piqué", "male", 2, 80, FAMOUS, "famosos",
              [("scizor", 21), ("bisharp", 21), ("kingambit", 22)],
              lines("Contigo, el que factura soy yo.", "Me has ganado. Esto lo arreglo en la Kings League.")),
    "aitana": ("Cantante", "Aitana", "female", 2, 60, FAMOUS, "famosos",
               [("comfey", 20), ("sylveon", 21), ("ninetales", 22)],
               lines("Esto es un concierto, así que toca: ¡vas a perder!", "Me has dejado sin medalla y sin bis.")),
    "ester_exposito": ("Actriz", "Ester", "female", 2, 60, FAMOUS, "famosos",
                       [("froslass", 14), ("mismagius", 15), ("gardevoir", 16)],
                       lines("Esto es un estreno. Solo me hago fotos con los que ganan.", "Corten... digo, buen combate.")),
    "elxokas": ("Streamer", "Elxokas", "male", 2, 60, FAMOUS, "famosos",
                [("primeape", 40), ("annihilape", 41), ("gyarados", 42)],
                lines("¿Qué haces aquí? ¿Me vienes a molestar en mi directo? ¡Venga, combate!", "¡No! ¡No me lo creo! Chat, eso no cuenta.")),
    "folagor": ("Youtuber Pokémon", "Folagor", "male", 3, 60, FAMOUS, "famosos",
                [("flygon", 15), ("gengar", 15), ("garchomp", 16)],
                lines("¿Nuzlocke? Aquí, si te debilitan uno, se va para siempre.", "Uno menos para el cementerio. ¡Gran combate!")),
    "sekiam": ("Youtuber Pokémon", "Sekiam", "male", 3, 60, FAMOUS, "famosos",
               [("tyranitar", 15), ("volcarona", 15), ("dragapult", 16)],
               lines("Hoy toca contenido de Pokémon del bueno.", "Lo subo igual, que ha quedado bonito.")),
    "pokealex": ("Jugador de VGC", "PokeAlex", "male", 4, 60, FAMOUS, "famosos",
                 [("incineroar", 15), ("rillaboom", 15), ("fluttermane", 16)],
                 lines("En dobles te gano. En triples, ni te cuento.", "Bien jugado. Me apunto este equipo.")),
    "amancio_ortega": ("Empresario", "Amancio", "male", 3, 200, FAMOUS, "famosos",
                       [("perrserker", 40), ("gholdengo", 41), ("kingambit", 42)],
                       lines("No concedo entrevistas. Ni combates. Bueno, uno.", "Lo apunto para la próxima colección.")),
    "abascal": ("Político", "Abascal", "male", 2, 80, FAMOUS, "famosos",
                [("rapidash", 14), ("mudsdale", 15), ("tauros", 16)],
                lines("Vengo a defender estas tierras. A caballo, como Dios manda.", "Esto es un pucherazo. Que se repita.")),
    "topuria": ("Campeón de UFC", "Topuria", "male", 3, 80, FAMOUS, "famosos",
                [("hitmonlee", 29), ("hitmonchan", 29), ("lucario", 30)],
                lines("Te lo digo antes: te voy a noquear en el primer asalto.", "Primera vez que me ganan. Quiero la revancha.")),
    "nico_williams": ("Delantero", "Nico Williams", "male", 3, 60, FAMOUS, "famosos",
                      [("cinderace", 42), ("talonflame", 43)],
                      lines("¡Dos hermanos, una banda!", "Ya nos vengaremos en Copa.")),
    "inaki_williams": ("Delantero", "Iñaki Williams", "male", 3, 60, FAMOUS, "famosos",
                       [("zeraora", 42), ("lokix", 43)],
                       lines("¡Hermano, a por él!", "Ya nos vengaremos en Copa.")),
    "pereira7": ("Streamer", "Pereira7", "male", 2, 60, FAMOUS, "famosos",
                 [("hawlucha", 39), ("sudowoodo", 40), ("tinkaton", 41)],
                 lines("¡Me estáis viendo 300.000 personas! ¡No me hagas quedar mal!", "Corta, corta el directo...")),
    "broncano": ("Presentador", "Broncano", "male", 2, 60, FAMOUS, "famosos",
                 [("grafaiai", 13), ("kilowattrel", 14), ("rabsca", 14), ("toxtricity", 15)],
                 lines("Bienvenido a La Revuelta. Primera pregunta: ¿cuánto dinero tienes en la cuenta?", "Pues ya está. Le damos un jamón al ganador.")),
    "oscar_puente": ("Ministro de Transportes", "Óscar Puente", "male", 2, 80, FAMOUS, "famosos",
                     [("bronzong", 46), ("klinklang", 46), ("orthworm", 47)],
                     lines("El tren llegará. Más tarde, pero llegará. Mientras, combatimos.", "Abriré una investigación sobre esta derrota.")),
    "mario_casas": ("Actor", "Mario Casas", "male", 3, 80, FAMOUS, "famosos",
                    [("krookodile", 50), ("zoroarkhisui", 50), ("toxtricity", 51)],
                    lines("Tres metros sobre el cielo. Y tú, a tres metros bajo tierra.", "Me quedo sin escena. Se la doy a Banderas.")),
    "pablo_iglesias": ("Exvicepresidente", "Pablo", "male", 2, 60, FAMOUS, "famosos",
                       [("grimmsnarl", 10), ("incineroar", 11)],
                       lines("¡Desde nuestra humilde casita de Galapagar, el pueblo te reta!", "Esto lo analizaremos en la Taberna Garibaldi.")),
    "irene_montero": ("Exministra", "Irene", "female", 2, 60, FAMOUS, "famosos",
                      [("hatterene", 10), ("mismagius", 11)],
                      lines("¡Sí se puede! ¡Combate!", "Esto lo llevamos a Bruselas.")),
    "franco": ("Fantasma", "Franco", "male", 3, 60, FAMOUS, "famosos",
               [("duskull", 7), ("banette", 8), ("gastly", 9)],
               lines("Me sacaron del Valle en 2019 sin preguntar. Así que ahora vago por aquí.", "Esto no lo dice el Nodo.")),
    "almeida": ("Alcalde", "Almeida", "male", 2, 80, FAMOUS, "famosos",
                [("diggersby", 13), ("excadrill", 14), ("copperajah", 15)],
                lines("Madrid está en obras. Tú también vas a estarlo.", "Lo apunto en la lista de obras pendientes.")),
    "chicote": ("Cocinero de las Campanadas", "Chicote", "male", 2, 60, FAMOUS, "famosos",
                [("slurpuff", 14), ("garbodor", 15)],
                lines("¡Esto es una pesadilla en la cocina! ¡Y tu equipo, también!", "¡Feliz año! Para ti, no tanto.")),
    "pedroche": ("Presentadora de las Campanadas", "Pedroche", "female", 2, 60, FAMOUS, "famosos",
                 [("gardevoir", 14), ("lopunny", 15)],
                 lines("¡Atentos, que vienen los cuartos! Y después, ¡las doce campanadas de tu derrota!", "¡Feliz año! ¿A que no adivinas mi vestido del año que viene?")),
    "rubiales": ("Invitado de la boda", "Rubiales", "male", 2, 60, FAMOUS, "famosos",
                 [("malamar", 30), ("grimmsnarl", 31)],
                 lines("¡No voy a dimitir! ¡No voy a dimitir!", "Esto es un falso feminismo de los combates.")),
    "jenni_hermoso": ("Campeona del mundo", "Jenni", "female", 3, 60, FAMOUS, "famosos",
                      [("lucario", 30), ("zeraora", 31)],
                      lines("Campeona del mundo. A ver qué traes tú.", "Buen partido. Pero la estrella en la camiseta es mía.")),
    "jorge_javier": ("Presentador", "Jorge Javier", "male", 2, 60, FAMOUS, "famosos",
                     [("chatot", 14), ("noctowl", 15), ("meowth", 15)],
                     lines("¡Soy rojo, soy de izquierdas y soy el que te va a ganar!", "¡Corten la publicidad! Esto no se emite.")),
    "coto_matamoros": ("Tertuliano", "Coto", "male", 2, 60, FAMOUS, "famosos",
                       [("mandibuzz", 50), ("murkrow", 50), ("honchkrow", 51)],
                       lines("¡A mí no me hables así, que te reviento en el plató!", "Me voy a Marbella a reírme de ti.")),
    "belen_esteban": ("Princesa del pueblo", "Belén", "female", 2, 60, FAMOUS, "famosos",
                      [("blissey", 14), ("lopunny", 15), ("kangaskhan", 15)],
                      lines("¡Yo por mi hija mato! ¡Y por mi medalla, también!", "¡Andreíta, cómete el filete!")),
    "melendi": ("Cantante", "Melendi", "male", 2, 60, FAMOUS, "famosos",
                [("toucannon", 41), ("mudbray", 41), ("mudsdale", 42)],
                lines("Caminando por la vida... me encontré contigo y te reté.", "Tengo un lunes de resaca y me has ganado.")),
    "felipe_vi": ("Rey", "Felipe VI", "male", 4, 250, CHAMPION, "famosos",
                  [("corviknight", 66), ("kingambit", 67), ("zacian", 70)],
                  lines("Es un honor recibir al nuevo campeón. Y un deber ponerle a prueba.", "Enhorabuena. Que conste en el BOE.")),
    "juan_carlos": ("Rey emérito", "Juan Carlos", "male", 3, 250, FAMOUS, "famosos",
                    [("kingdra", 39), ("lapras", 40), ("wailord", 41)],
                    lines("Lo siento mucho, me he equivocado y no volverá a ocurrir. Ahora, combate.", "Me vuelvo a Abu Dabi. Allí no me gana nadie.")),
    "sarah_santaolalla": ("Tertuliana", "Sarah", "female", 2, 60, FAMOUS, "famosos",
                          [("indeedee", 46), ("gothitelle", 46), ("hatterene", 47)],
                          lines("Te voy a hacer un zasca en directo.", "Esto lo debato mañana en otra cadena.")),
    "vito_quiles": ("Agitador", "Vito", "male", 2, 40, FAMOUS, "famosos",
                    [("chatot", 13), ("murkrow", 14), ("kilowattrel", 15)],
                    lines("¡Una pregunta! ¡Solo una pregunta! ¿Por qué no combates?", "Esto lo subo a mis redes recortado.")),
    "bertrand_ndongo": ("Agitador", "Bertrand", "male", 2, 40, FAMOUS, "famosos",
                        [("pangoro", 13), ("scrafty", 14), ("obstagoon", 15)],
                        lines("¡Te voy a grabar para mis redes! ¡Combate!", "Esto es censura.")),
    "vegeta": ("Youtuber", "Vegeta", "male", 2, 100, FAMOUS, "famosos",
               [("lucario", 18), ("garchomp", 19)],
               lines("¡Bienvenido a Andorra! Aquí los impuestos los pagas tú.", "Lo grabamos para el canal secundario.")),
    "willyrex": ("Youtuber", "Willyrex", "male", 2, 100, FAMOUS, "famosos",
                 [("scizor", 18), ("aegislash", 19)],
                 lines("¡Willy y Vegeta, otra vez juntos!", "Lo grabamos para el canal secundario.")),
    "ferran_torres": ("Delantero", "Ferran", "male", 2, 60, FAMOUS, "famosos",
                      [("raboot", 25), ("electrode", 26), ("talonflame", 27)],
                      lines("Me llaman el Tiburón. Ahora verás por qué.", "Ahora estoy de bajón. Mañana marco dos.")),
    "juan_roig": ("Presidente de Mercadona", "Juan Roig", "male", 3, 300, FAMOUS, "famosos",
                  [("miltank", 26), ("goodra", 27), ("chansey", 28)],
                  lines("En Mercadona, el cliente es el jefe. Pero el que gana soy yo.", "Te lo dejo a precio Hacendado.")),
    "recluta_clan": ("Recluta del Clan", "Recluta", "male", 1, 30, CLAN, "liga",
                     [("purrloin", 11), ("koffing", 12)],
                     lines("¡Por el Líder Supremo! ¡Y por la siguiente legislatura!", "Me van a abrir un expediente...")),
}


def main() -> None:
    with open(SPECIES, encoding="utf-8") as f:
        species = json.load(f)
    missing = [(pid, s) for pid, p in PEOPLE.items() for s, _ in p[7] if s not in species]
    if missing:
        raise SystemExit("Especies que no existen: %s" % missing)
    with open(CLASSES, encoding="utf-8") as f:
        classes = json.load(f)
    files = {"liga": {}, "famosos": {}}
    for pid, (title, name, gender, ai, money, (intro, battle), file_id, party, text) in PEOPLE.items():
        cls = {
            "name": title, "gender": gender, "base_money": money, "ai_level": ai,
            "battle_sprite": "res://assets/sprites/trainers/%s.png" % pid,
            "overworld_sprite": "res://assets/sprites/characters/%s.png" % pid,
            "intro_bgm": intro, "battle_bgm": battle,
        }
        if pid == "recluta_clan":
            cls["gender"] = "mixed"
            cls["battle_sprite_female"] = "res://assets/sprites/trainers/recluta_clan_f.png"
            cls["overworld_sprite_female"] = "res://assets/sprites/characters/recluta_clan_f.png"
        classes[pid] = cls
        trainer = {"class": pid, "name": name}
        trainer.update(text)
        trainer["items"] = ["hyperpotion", "hyperpotion"] if ai >= 4 else []
        trainer["party"] = [{"species": s, "level": lv} for s, lv in party]
        files[file_id][pid] = trainer
    with open(CLASSES, "w", encoding="utf-8") as f:
        f.write(json.dumps(classes, ensure_ascii=False, indent=2) + "\n")
    for file_id, data in files.items():
        path = os.path.join(TRAINERS, file_id + ".json")
        with open(path, "w", encoding="utf-8") as f:
            f.write(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
        print("%s: %d entrenadores" % (os.path.relpath(path, ROOT), len(data)))


if __name__ == "__main__":
    main()
