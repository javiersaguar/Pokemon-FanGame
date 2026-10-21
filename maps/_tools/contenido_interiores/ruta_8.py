# Interiores de la Ruta 8 (Montserrat, Santpedor y Sant Esteve Sesrovires). Propuesta provisional.
SALAS = {
    "ruta_8/casa_1": {
        "tipo": "casa", "nombre": "Masía de Santpedor",
        "gente": [
            ("Payés", "huertano", "regalo:libre", [
                "En Santpedor nació un entrenador muy famoso. Cuando gana, el pueblo pone la bandera en el balcón. Gana mucho.",
                "Toma, que en esta masía nadie se va sin un regalo. Ni los ciclistas que se pierden."]),
            ("Payesa", "npc_old_woman", "cocina", ["Pa amb tomàquet, embutido de la comarca y vino del Bages. Así se almuerza en una masía."]),
        ],
    },
    "ruta_8/casa_2": {
        "tipo": "casa", "nombre": "Casa de la familia de Sant Esteve Sesrovires",
        "gente": [
            ("Madre", "npc_woman", "cocina", [
                "En Sant Esteve todo el mundo conoce a la cantante. Cuando sale en la tele, la abuela del tercero dice que le cambió los pañales.",
                "Aquí hay viñas, polígonos y un castillo. Y desde que es famosa, autobuses de turistas japoneses."]),
            ("Hija", "npc_lass", "tele", ["Me he hecho las uñas como ella. Mi madre dice que así no se puede fregar. Ella no friega."]),
        ],
    },
    "ruta_8/sala_calle_36_10": {
        "tipo": "monasterio", "nombre": "Basílica de Montserrat",
        "gente": [
            ("Monje benedictino", "npc_old_man", "cura", [
                "Aquí vive la Moreneta, la Virgen negra patrona de Cataluña. Se besa su mano, que asoma con la bola del mundo.",
                "La Escolanía es uno de los coros de niños más antiguos de Europa. Cantan a la una. A la una y cinco, se van a jugar."]),
            ("Escolano", "npc_boy", "publico", ["Canto el Virolai todos los días. Los Pokémon de tipo Hada vienen a escucharlo."]),
            ("Excursionista", "montanera", "libre", ["He subido en el cremallera y bajaré andando. O al revés. Depende de las piernas."]),
        ],
        "carteles": [("pared", ["Montserrat: «montaña serrada». Las agujas de roca parecen dedos. Dicen que los ángeles la serraron con sierras de oro."])],
    },
    "ruta_8/sala_calle_51_36": {
        "tipo": "casa", "nombre": "Casa del ciclista del Bages",
        "gente": [
            ("Ciclista", "repartidorbici", "libre", [
                "Subo a Montserrat en bici los domingos. Arriba me como un bocadillo y bajo sin pedalear. Es mi recompensa.",
                "Los fines de semana hay más ciclistas que coches en esta carretera. Y más maillots que pájaros."]),
            ("Mujer", "npc_woman", "tele", ["Mi marido tiene tres bicis. Yo tengo una y la uso para ir al pan."]),
        ],
    },
    "ruta_8/sala_calle_56_36": {
        "tipo": "bodega", "nombre": "Celler de cava del Penedès",
        "gente": [
            ("Enóloga", "vendimiador", "dependiente", [
                "El cava se hace con el método tradicional: segunda fermentación en botella. Se gira la botella a mano un poco cada día.",
                "Macabeo, xarel·lo y parellada. Tres uvas y mucha paciencia en la cava, a oscuras."]),
            ("Visitante", "turista_f", "cliente", ["La visita incluye una copa. He hecho la visita dos veces."]),
        ],
    },
}

# Salas de dentro de los monumentos (21 de octubre).
SALAS['ruta_8/sala_calle_36_10'].setdefault("dentro", {}).update({'ruta_8/sala_calle_36_10_camarin': {'tipo': 'iglesia', 'nombre': 'Camarín de la Moreneta', 'gente': [('Devota', 'npc_old_woman', 'publico', ['La Moreneta es una talla románica de la Virgen, morena por el humo de las velas y el paso de los siglos. Es la patrona de Cataluña.', 'La cara está tras un cristal; se toca la bola que tiene en la mano. Los domingos, la cola da la vuelta a la basílica.'])], 'carteles': [('pared', ['Un camarín de mármol y oro, con la talla en lo alto. La bola de la mano brilla de tanto que la han tocado.'])]}, 'ruta_8/sala_calle_36_10_escolania': {'tipo': 'aula', 'nombre': 'Escolanía de Montserrat', 'gente': [('Escolán', 'npc_boy', 'libre', ['Somos uno de los coros de niños más antiguos de Europa. Cada día, a la una, cantamos el Virolai en la basílica.', 'Vivimos aquí arriba, entre clases y ensayos. Lo más difícil no es el latín: es bajar la montaña el fin de semana.']), ('Maestro de capilla', 'profesor', 'libre', ['Un niño que canta en la basílica a los diez años no pierde el oído en toda su vida. Ni la paciencia.'])], 'carteles': [('pared', ['Partituras en atriles de madera y un piano vertical. En la pizarra, el Virolai con las respiraciones marcadas en rojo.'])]}})
