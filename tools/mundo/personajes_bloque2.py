#!/usr/bin/env python3
"""Da clase, equipo, textos y sitio (propuesta) a los personajes que tenían arte pero no combate, y añade las
segundas apariciones que decidió Javier (docs/DECISIONES_JAVIER_2026-10-13.md, §4). Escribe en
data/trainer_classes.json, data/trainers/famosos.json, data/trainers/liga.json y data/personajes_en_el_mapa.json.
Es idempotente: si una entrada ya existe, la sustituye por la de aquí.

Equipos y frases: propuesta del Agente 2 (PENDIENTE JAVIER). Cada especie va en la etapa de su nivel
(compruébalo con python3 tools/mundo/comprobar_equipos.py). Las casillas las calcula después
maps/_tools/colocar_personajes.gd.

Uso: python3 tools/mundo/personajes_bloque2.py
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FAMOUS = ("encounter_smart", "battle_trainer")
CLAN = ("encounter_villain", "battle_villain")
TOUGH = ("encounter_tough", "battle_trainer")


def path(*parts: str) -> str:
    return os.path.join(ROOT, *parts)


def load(rel: str) -> dict:
    return json.load(open(path(rel), encoding="utf-8"))


def save(rel: str, data: dict, indent) -> None:
    with open(path(rel), "w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(data, indent=indent, ensure_ascii=False) + "\n")


def lines(intro: str, lose: str, win: str, after: str) -> dict:
    return {"intro_text": intro, "lose_text": lose, "win_text": win, "after_text": after}


def party(*members) -> list:
    return [{"species": s, "level": lv} for s, lv in members]


# Clases nuevas: id -> (título, dinero base, nivel de IA, música).
CLASSES = {
    "omar_montes": ("Cantante", 60, 2, TOUGH),
    "pablo_motos": ("Presentador", 60, 2, FAMOUS),
    "zona_gemelos_carlos": ("Gemelo", 60, 2, FAMOUS),
    "zona_gemelos_dani": ("Gemelo", 60, 2, FAMOUS),
    "amador_rivas": ("Vecino", 60, 2, FAMOUS),
    "antonio_recio": ("Mayorista", 60, 2, FAMOUS),
    "mente_fria": ("Vecino", 60, 2, FAMOUS),
    "marc_cucurella": ("Lateral", 60, 2, TOUGH),
    "joan_pradells": ("Culturista", 60, 2, TOUGH),
    "david_bisbal": ("Cantante", 60, 2, FAMOUS),
    "jc_reyes": ("Rapero", 60, 2, TOUGH),
    "puigdemont": ("Expresident", 80, 2, FAMOUS),
    "rufian": ("Diputado", 80, 2, FAMOUS),
    "zapatero": ("Expresidente", 100, 3, FAMOUS),
    "maduro": ("Presidente", 100, 3, CLAN),
    "trump": ("Presidente", 120, 3, CLAN),
    "paache": ("Streamer", 60, 2, FAMOUS),
    "churumbel": ("Tiktoker", 60, 2, TOUGH),
    "javier": ("Creador", 200, 4, ("encounter_tough", "battle_rival")),
}

# Entrenadores: id -> (archivo, clase, nombre, equipo, textos, objetos).
TRAINERS = {
    "omar_montes": ("famosos", "omar_montes", "Omar Montes", party(("tyrogue", 6), ("makuhita", 7)), lines(
        "¡Alocao! Soy de Pan Bendito y antes de cantar boxeaba. Ponte en guardia.",
        "Me has dado más fuerte que la vida. Me voy a cantar para olvidarlo.",
        "¡Ay, que me pongo alocao!",
        "Carabanchel es el barrio más bonito de Madrid. Lo digo en todas las teles."), []),
    "pablo_motos": ("famosos", "pablo_motos", "Pablo Motos", party(("nincada", 13), ("trapinch", 14), ("durant", 15)), lines(
        "¡Bienvenido a El Hormiguero! Trancas y Barrancas te han preparado una prueba: perder.",
        "Esto no lo emitimos. Bueno, sí, que la audiencia es la audiencia.",
        "¡Hoy volvemos a ganar a La Revuelta!",
        "¿El de enfrente? Nosotros tenemos hormigas. Él tiene un sofá."), []),
    "zona_gemelos_carlos": ("famosos", "zona_gemelos_carlos", "Carlos", party(("plusle", 16), ("gimmighoul", 17)), lines(
        "¡Bienvenido a La Casa de los Gemelos! Aquí se emite todo, las veinticuatro horas.",
        "Esta no la habíamos pronosticado.",
        "¡Pronóstico acertado, hermano!",
        "Somos dos chicos normales de barrio. De Getafe, para más señas."), []),
    "zona_gemelos_dani": ("famosos", "zona_gemelos_dani", "Dani", party(("minun", 16), ("meowth", 17)), lines(
        "Y hemos apostado a que pierdes. Cuota 1,01.",
        "No siempre se gana, pero en diez años siempre acabamos sumando.",
        "Directo al canal. ¡Gracias por la audiencia!",
        "El programa del barrio para el barrio. Sin productores. Bueno, casi."), []),
    "antonio_recio": ("famosos", "antonio_recio", "Antonio Recio", party(("krabby", 15), ("clauncher", 16), ("wiglett", 17)), lines(
        "¡Mariscos Recio, el mar al mejor precio! Y que conste: soy mayorista, no limpio pescado.",
        "¡Esto es un atropello! Voy a llamar a la policía. O a mi madre.",
        "¡Lo que yo decía! Aquí manda el mayorista.",
        "En Montepinar el presidente de la comunidad debería ser yo. Lo sabe todo el mundo."), []),
    "amador_rivas": ("famosos", "amador_rivas", "Amador", party(("slakoth", 15), ("lechonk", 16), ("spinda", 17)), lines(
        "¡Viva la Pepa! Hoy no trabajo, que es lunes. Pero combatir sí, eso sí.",
        "Me has dejado más tirado que a mi Maite.",
        "¡Toma! ¡Esto es un pichón ganador!",
        "La vida es una fiesta. Lo malo es que siempre me toca recoger."), []),
    "mente_fria": ("famosos", "mente_fria", "Mente Fría", party(("snorunt", 15), ("smoochum", 16), ("spheal", 17)), lines(
        "Mente fría. Tú calienta, que yo pienso.",
        "He perdido la calma. Y eso que me llaman Mente Fría.",
        "Te lo dije: cabeza fría y paciencia.",
        "En esta comunidad hace falta alguien con la mente fría. Y una piscina que funcione."), []),
    "marc_cucurella": ("famosos", "marc_cucurella", "Cucurella", party(("wooloo", 20), ("falinks", 20), ("raboot", 21)), lines(
        "¡Cucurella, Cucurella! Me lo cantan en todos los estadios. Aquí, en el Maresme, también.",
        "Me has hecho un caño. Y eso que soy lateral.",
        "Campeón de Europa. Y ahora, de este campo de tierra.",
        "Soy de Alella, aquí al lado. En este campo jugaba yo antes que Lamine. Bueno, más o menos."), []),
    "joan_pradells": ("famosos", "joan_pradells", "Joan Pradells", party(("gurdurr", 25), ("hariyama", 26), ("bewear", 27)), lines(
        "Hoy toca pierna. Y espalda. Y combate. Y pollo con arroz.",
        "Me has dejado más seco que mi última definición.",
        "¡Menudo ejemplar, niño!",
        "Peso ciento treinta kilos y aun así toco el suelo con los dedos. Tú no tocas ni la medalla."), []),
    "david_bisbal": ("famosos", "david_bisbal", "Bisbal", party(("kricketune", 31), ("chimecho", 31), ("flareon", 32)), lines(
        "¡Ave María! ¿Cuándo serás mía? Si me das un combate, te doy una canción.",
        "Me has dejado sin voz. Y sin rizos.",
        "¡Bulería, bulería, tan dentro del alma mía!",
        "Soy de Almería. Por aquí se va a mi tierra: dale recuerdos al desierto de Tabernas."), []),
    "jc_reyes": ("famosos", "jc_reyes", "JC Reyes", party(("krokorok", 31), ("liepard", 32), ("mabosstiff", 33)), lines(
        "¡The Young Gypsy! Vengo de Palmete y he llenado La Cartuja. Tú no llenas ni la Pokédex.",
        "Esto lo canto en el próximo disco, primo.",
        "Los Green Lanters no pierden.",
        "Solo el cinco por ciento de los artistas canta en directo. Yo también combato en directo."), []),
    "puigdemont": ("famosos", "puigdemont", "Puigdemont", party(("abra", 20), ("ninjask", 20), ("emolga", 21)), lines(
        "Vengo de Waterloo de incógnito. Si me ves, no me has visto.",
        "Me vuelvo a Waterloo. En el maletero, que se viaja más tranquilo.",
        "¡Visca Catalunya! Y visca el maletero.",
        "Si me buscas, estaré en Bélgica. O detrás de un contenedor del puerto."), []),
    "rufian": ("famosos", "rufian", "Rufián", party(("chatot", 20), ("scraggy", 20), ("liepard", 21)), lines(
        "Dije que me iba del Congreso en dieciocho meses. Lo dije en 2016. Mientras tanto, combate.",
        "Esto lo tuiteo. Y lo retuiteo.",
        "Zasca.",
        "Mi habitación es mía. Si oyes ruido dentro, no preguntes."), []),
    "zapatero": ("famosos", "zapatero", "Zapatero", party(("sableye", 36), ("gholdengo", 37)), lines(
        "Talante y diálogo. Primero hablamos; luego te gano.",
        "Toma estas joyas. Son de... bueno, no preguntes de dónde.",
        "La tierra no pertenece a nadie, salvo al viento. Y esta victoria, a mí.",
        "Las joyas se venden muy bien en cualquier tienda. Yo de ti no preguntaría el origen."), []),
    "maduro": ("famosos", "maduro", "Maduro", party(("chatot", 36), ("bombirdier", 37)), lines(
        "¡Un pajarito me ha dicho que vas a perder!",
        "¡Esto es un golpe del imperio!",
        "¡El pajarito tenía razón!",
        "Canarias es la octava isla de Venezuela. O al revés, ya no me acuerdo."), []),
    "trump": ("famosos", "trump", "Trump", party(("persian", 38), ("talonflame", 38), ("gyarados", 39)), lines(
        "Tengo a Maduro en una Poké Ball. Ahora vengo a por las islas. Tremendous.",
        "Fake news. This battle was rigged.",
        "We are winning so much!",
        "Me llevo a Maduro a Washington. A ti te pongo aranceles."), []),
    "paache": ("famosos", "paache", "Paache", party(("rotom", 39), ("pawmot", 39), ("golisopod", 40)), lines(
        "¡Buenas, chat! Hoy toca virgenlocke: si me debilitas uno, lloro en directo.",
        "Chat, eso no cuenta. ¿Reiniciamos?",
        "¡Gáñame si puedes, que estoy en directo!",
        "Desde Galicia con amor. Y con la Wii enchufada."), []),
    "churumbel": ("famosos", "churumbel", "El Churumbel", party(("krookodile", 50), ("grimmsnarl", 50), ("tinkaton", 51)), lines(
        "¡Illo, que soy el Churumbel de Málaga! Esto lo subo a TikTok antes de que acabe.",
        "Me has dejado más quieto que al portero de la discoteca.",
        "¡Toma ya, pisha!",
        "Málaga es la mejor ciudad del mundo. Lo digo en todos mis vídeos."), []),
    "javier": ("famosos", "javier", "Javier Saguar", party(("gengar", 56), ("lucario", 56), ("gyarados", 56), ("togekiss", 57), ("garchomp", 57), ("charizard", 58)), lines(
        "¡Por fin has vuelto a San Miguel! Soy Javier Saguar, el que ha hecho este juego. Veamos si has aprendido algo.",
        "Bien jugado. El juego lo he hecho yo, pero el combate lo has ganado tú.",
        "El creador siempre se guarda un as.",
        "Vuelve cuando quieras. San Miguel de Bernuy siempre tiene la puerta abierta. Y el bar, también."), ["hyperpotion", "hyperpotion"]),
    # Segundas apariciones (decisiones de Javier del 2026-10-13, §4).
    "vito_quiles_elche": ("famosos", "vito_quiles", "Vito", party(("chatot", 30), ("honchkrow", 30), ("kilowattrel", 31)), lines(
        "¿Otra vez tú? ¡Responde: ¿cuándo dimites?! Esta vez juego en casa.",
        "¡En Elche no! ¡En mi ciudad no!",
        "¡Lo tengo grabado! ¡Lo subo ya!",
        "Soy de Elche. Aquí hasta las palmeras me hacen preguntas."), []),
    "vito_quiles_rufian": ("famosos", "vito_quiles", "Vito", party(("chatot", 20), ("murkrow", 20), ("wattrel", 21)), lines(
        "¡Chist! Estoy esperando a Rufián para hacerle una pregunta. Desde su armario.",
        "Esto no ha pasado. Ni el armario tampoco.",
        "¡Exclusiva! ¡La habitación de Rufián!",
        "Cuando entre Rufián, ni una palabra. Le voy a preguntar por los dieciocho meses."), []),
    "abascal_covadonga": ("famosos", "abascal", "Abascal", party(("rapidash", 41), ("mudsdale", 41), ("tauros", 42)), lines(
        "Aquí empezó la Reconquista. Y aquí empieza tu derrota.",
        "Volveré. Como don Pelayo. A caballo.",
        "¡Santiago y cierra combate!",
        "Covadonga es el kilómetro cero de España. Bueno, el otro kilómetro cero."), []),
    "abalos_albufera": ("liga", "abalos", "Ábalos", party(("mimikyu", 28), ("liepard", 29)), lines(
        "Estoy de vacaciones en la Albufera. Pagadas por... bueno, pagadas.",
        "Esto es una persecución. ¡Y en plena paella!",
        "Ja. Vuelve cuando sepas combatir.",
        "¿Jessica? Aquí no hay ninguna Jessica. Hay arroz."), []),
    "koldo_albufera": ("liga", "koldo", "Koldo", party(("timburr", 28), ("gurdurr", 29)), lines(
        "Estas cajas son de arroz. Para la paella. Para muchas paellas.",
        "Esto no estaba en el contrato. Ni en la paella.",
        "Ja. Vuelve cuando sepas combatir.",
        "Yo solo llevaba las cajas. Y el arroz. Y lo que hubiera debajo del arroz."), []),
}

# Colocaciones (propuesta): id -> datos de la entrada de personajes_en_el_mapa.json.
PLACEMENTS = {
    "omar_montes": {"mapa": "madrid_rio/exterior", "cerca": [9, 16], "mira": "abajo", "vista": 3,
                    "lugar": "Madrid Río, junto al Matadero, camino de Carabanchel (Pan Bendito, su barrio). Propuesta"},
    "pablo_motos": {"mapa": "madrid/centro", "cerca": [33, 25], "mira": "abajo", "vista": 0,
                    "lugar": "Gran Vía, enfrente de La Revuelta de Broncano: la guerra de audiencias. Propuesta"},
    "zona_gemelos_carlos": {"mapa": "getafe/exterior", "cerca": [36, 52], "mira": "abajo", "vista": 3, "pareja": "zona_gemelos_dani",
                            "lugar": "Getafe, su ciudad, a la puerta de la nave donde graban La Casa de los Gemelos. Propuesta"},
    "zona_gemelos_dani": {"mapa": "getafe/exterior", "cerca": [38, 52], "mira": "abajo", "vista": 3,
                          "lugar": "Getafe, con su gemelo Carlos. Propuesta"},
    "antonio_recio": {"mapa": "mostoles/exterior", "cerca": [30, 46], "mira": "abajo", "vista": 2,
                      "lugar": "Móstoles, en una urbanización nueva: el Mirador de Montepinar de La que se avecina. Propuesta"},
    "amador_rivas": {"mapa": "mostoles/exterior", "cerca": [34, 46], "mira": "abajo", "vista": 2,
                     "lugar": "Móstoles, de vecino en el Mirador de Montepinar. Propuesta"},
    "mente_fria": {"mapa": "mostoles/exterior", "cerca": [38, 46], "mira": "abajo", "vista": 2,
                   "lugar": "Móstoles, de vecino en el Mirador de Montepinar. Propuesta"},
    "marc_cucurella": {"mapa": "rocafonda/exterior", "cerca": [27, 30], "mira": "abajo", "vista": 2,
                       "lugar": "Rocafonda (Maresme), en el campo de los niños: es de Alella, al lado. Propuesta"},
    "joan_pradells": {"mapa": "valencia/malvarrosa", "cerca": [46, 16], "mira": "abajo", "vista": 3,
                      "lugar": "Playa de la Malvarrosa, entrenando al aire libre: es culturista y valenciano. Propuesta"},
    "david_bisbal": {"mapa": "ruta_12/exterior", "cerca": [64, 27], "mira": "derecha", "vista": 3,
                     "lugar": "Ruta 12, en la entrada desde Murcia: el camino de Almería, su tierra. Propuesta"},
    "jc_reyes": {"mapa": "sevilla/centro", "cerca": [55, 30], "mira": "abajo", "vista": 3,
                 "lugar": "Sevilla, en el lado este del centro, camino de Palmete, su barrio. Propuesta"},
    "puigdemont": {"mapa": "barcelona/ciutat_vella", "cerca": [18, 49], "mira": "izquierda", "vista": 0,
                   "lugar": "Port Vell, junto a la terminal de ferris: listo para fugarse otra vez. Propuesta"},
    "zapatero": {"mapa": "las_palmas/canteras", "cerca": [40, 38], "mira": "abajo", "vista": 3, "pareja": "maduro",
                 "lugar": "Puerto de La Luz (Las Palmas), con Maduro: Venezuela es «la octava isla» de Canarias. Propuesta"},
    "maduro": {"mapa": "las_palmas/canteras", "cerca": [42, 38], "mira": "abajo", "vista": 3,
               "lugar": "Puerto de La Luz (Las Palmas), con Zapatero. Propuesta"},
    "trump": {"mapa": "playa_del_ingles/exterior", "cerca": [17, 9], "mira": "abajo", "vista": 3,
              "requiere": {"flag": "trainer_defeated:maduro"},
              "lugar": "Aeropuerto de Gran Canaria: llega a por Maduro (sale después de ganar a Zapatero y Maduro). Propuesta"},
    "paache": {"mapa": "ruta_17/exterior", "cerca": [14, 28], "mira": "abajo", "vista": 3,
               "lugar": "Ruta 17 (Galicia interior), junto al hórreo. Que esté en Galicia es decisión de Javier; el sitio exacto, propuesta"},
    "churumbel": {"mapa": "malaga/exterior", "cerca": [30, 44], "mira": "abajo", "vista": 3,
                  "lugar": "Málaga, su ciudad, junto al mercado. Propuesta"},
    "javier": {"mapa": "pueblo_inicial/exterior", "cerca": [37, 41], "mira": "abajo", "vista": 0, "sustituye": "Javier",
               "requiere": {"medallas": 7},
               "lugar": "San Miguel de Bernuy, delante de su casa, al volver por la Ruta 23 con siete medallas (decisión de Javier). Sustituye al vecino «Javier» del mapa"},
    "vito_quiles_elche": {"mapa": "ruta_11/exterior", "cerca": [52, 17], "mira": "abajo", "vista": 3,
                          "lugar": "Palmeral de Elche, su ciudad: la revancha (decisión de Javier)"},
    "abascal_covadonga": {"mapa": "ruta_18/exterior", "cerca": [36, 26], "mira": "abajo", "vista": 3,
                          "lugar": "Covadonga, delante de la basílica: su segunda aparición (dos apariciones: decisión de Javier; el sitio, propuesta)"},
    "abalos_albufera": {"mapa": "ruta_9/exterior", "cerca": [11, 27], "mira": "derecha", "vista": 3, "pareja": "koldo_albufera",
                        "requiere": {"medallas": 3},
                        "lugar": "La Albufera (El Palmar), de «vacaciones»: segundo encuentro, con tres medallas (decisión de Javier)"},
    "koldo_albufera": {"mapa": "ruta_9/exterior", "cerca": [12, 29], "mira": "derecha", "vista": 3,
                       "requiere": {"medallas": 3},
                       "lugar": "La Albufera (El Palmar), con Ábalos y sus cajas de «arroz» (decisión de Javier)"},
    # Recolocados: la familia de Lamine se muda con él a Rocafonda; los antiguos del gimnasio 6, a la calle de Bilbao.
    "hustlehard304": {"mapa": "rocafonda/exterior", "cerca": [28, 15], "mira": "abajo", "vista": 2,
                      "lugar": "Rocafonda, a la puerta de la mansión de su hijo Lamine"},
    "keyne": {"mapa": "rocafonda/exterior", "cerca": [34, 15], "mira": "abajo", "vista": 2,
              "lugar": "Rocafonda, con su hermano Lamine"},
    "gym6_camarero": {"mapa": "bilbao/exterior", "cerca": [16, 20], "mira": "abajo", "vista": 3,
                      "lugar": "Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6)"},
    "gym6_crossfitero": {"mapa": "bilbao/exterior", "cerca": [20, 23], "mira": "izquierda", "vista": 3,
                         "lugar": "Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6)"},
    "gym6_tertuliano": {"mapa": "bilbao/exterior", "cerca": [25, 20], "mira": "abajo", "vista": 3,
                        "lugar": "Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6)"},
    "nico_williams": {"mapa": "bilbao/exterior", "cerca": [12, 24], "mira": "abajo", "vista": 3, "pareja": "inaki_williams",
                      "requiere": {"medallas": 6},
                      "lugar": "A la salida de San Mamés, con la medalla 6: la revancha de Copa (dentro combaten por separado). Propuesta"},
    "inaki_williams": {"mapa": "bilbao/exterior", "cerca": [14, 24], "mira": "abajo", "vista": 3,
                       "requiere": {"medallas": 6},
                       "lugar": "A la salida de San Mamés, con su hermano Nico. Propuesta"},
}

# Pendientes con motivo hasta que exista su mapa (bloque 4).
PENDING = {
    "rufian": ("Su casa de Barcelona, con habitación propia (decisión de Javier)",
               "Falta el mapa de su casa: lo pinta el Agente 2 en el bloque 4 (2026-10-15)"),
    "vito_quiles_rufian": ("La habitación de Rufián, en Barcelona (decisión de Javier)",
                           "Falta el mapa de la casa de Rufián: lo pinta el Agente 2 en el bloque 4 (2026-10-15)"),
}

# Los Williams del doble: revancha después de la medalla 6.
WILLIAMS = {
    "nico_williams": (party(("cinderace", 45), ("talonflame", 46)), lines(
        "¡Revancha! Dentro nos ganaste uno a uno. Fuera, los dos a la vez.",
        "Vale, vale. Ya nos vengaremos en Copa.",
        "¡Eso es cantera!",
        "Dos hermanos, una banda. Y una camiseta rojiblanca cada uno.")),
    "inaki_williams": (party(("zeraora", 45), ("lokix", 46)), lines(
        "¡Dos hermanos, una banda!",
        "Hoy no era nuestro día. El de Copa, sí.",
        "¡Aupa Athletic!",
        "Mi hermano corre más, pero yo llevo más partidos seguidos.")),
}


def main() -> None:
    classes = load("data/trainer_classes.json")
    for cid, (title, money, ai, music) in CLASSES.items():
        classes[cid] = {"name": title, "gender": "male", "base_money": money, "ai_level": ai,
                        "battle_sprite": "res://assets/sprites/trainers/%s.png" % cid,
                        "overworld_sprite": "res://assets/sprites/characters/%s.png" % cid,
                        "intro_bgm": music[0], "battle_bgm": music[1]}
    save("data/trainer_classes.json", classes, 2)

    files = {"famosos": load("data/trainers/famosos.json"), "liga": load("data/trainers/liga.json")}
    for tid, (file, cid, name, team, texts, items) in TRAINERS.items():
        entry = {"class": cid, "name": name}
        entry.update(texts)
        entry["items"] = items
        entry["party"] = team
        files[file][tid] = entry
    for tid, (team, texts) in WILLIAMS.items():
        files["famosos"][tid].update(texts)
        files["famosos"][tid]["party"] = team
    save("data/trainers/famosos.json", files["famosos"], 2)
    save("data/trainers/liga.json", files["liga"], 2)

    doc = load("data/personajes_en_el_mapa.json")
    placed = {e["id"]: e for e in doc["colocados"]}
    for tid, data in PLACEMENTS.items():
        entry = {"id": tid, "entrenador": tid}
        entry.update(data)
        if tid in placed and "casilla" in placed[tid] and placed[tid]["mapa"] == data["mapa"]:
            entry["casilla"] = placed[tid]["casilla"]
        if tid in placed:
            doc["colocados"][doc["colocados"].index(placed[tid])] = entry
        else:
            doc["colocados"].append(entry)
    doc["pendientes"] = [e for e in doc["pendientes"] if e["id"] not in PLACEMENTS and e["id"] not in PENDING]
    for tid, (where, why) in PENDING.items():
        doc["pendientes"].append({"id": tid, "lugar": where, "motivo": why})
    used = set(TRAINERS) | {c for c in CLASSES}
    doc["arte_sin_uso"] = [e for e in doc.get("arte_sin_uso", []) if e["id"] not in used]
    save("data/personajes_en_el_mapa.json", doc, 1)
    print("bloque 2: %d clases, %d entrenadores, %d colocaciones, %d pendientes" % (
        len(CLASSES), len(TRAINERS), len(PLACEMENTS), len(doc["pendientes"])))


if __name__ == "__main__":
    main()
