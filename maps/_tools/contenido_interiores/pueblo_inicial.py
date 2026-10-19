# Interiores de San Miguel de Bernuy (pueblo de Javier). Propuesta provisional: el lore del pueblo y de
# Javier es suyo (PENDIENTE JAVIER); aquí solo hay vecinos genéricos, sin la casa ni la familia de Javier.
SALAS = {
    "pueblo_inicial/casa_1": {
        "tipo": "casa", "nombre": "Casa de la abuela de la Plaza de España",
        "gente": [
            ("Abuela", "npc_old_woman", "regalo:cocina", [
                "En San Miguel somos ciento y pico vecinos en invierno y mil en agosto. En agosto, la plaza parece Madrid.",
                "Toma, para el camino. En este pueblo nadie se va sin algo en el bolsillo."]),
            ("Abuelo", "npc_old_man", "tele", ["Los jóvenes se van a Madrid a estudiar y vuelven en las fiestas. Los mayores nos quedamos a cuidar el pueblo."]),
        ],
    },
    "pueblo_inicial/casa_2": {
        "tipo": "bar", "nombre": "Bar del pueblo",
        "gente": [
            ("Dueño del bar", "camarero", "dependiente", [
                "Aquí se juega al mus desde las cuatro. A las ocho se discute la última mano. A las diez, la de ayer.",
                "Tenemos torreznos de Segovia, los mejores. Bueno, eso dicen en todos los pueblos de Segovia."]),
            ("Jugador de mus", "jubiladoobras", "cliente", ["¡Envido! ¿Cómo que no? ¡Si llevo treinta y una! Bueno, treinta. Bueno, no quiero."]),
        ],
        "carteles": [("pared", ["Cartel de las fiestas: Virgen del Río (8 de septiembre) y San Miguel Arcángel (29 de septiembre). Orquesta, peñas y verbena."])],
    },
    "pueblo_inicial/sala_calle_12_28": {
        "tipo": "casa", "nombre": "Casa del alquiler de canoas",
        "gente": [
            ("Monitor de canoas", "piraguista", "libre", [
                "Bajamos el Duratón en canoa por las Hoces. Se ven los buitres leonados y la ermita de San Frutos en lo alto.",
                "Lo más difícil no es remar: es no quedarse mirando los buitres y chocar con la orilla."]),
            ("Turista madrileña", "turista_f", "cliente", ["He venido a pasar el fin de semana y me he caído al agua dos veces. Ha sido el mejor fin de semana del año."]),
        ],
    },
    "pueblo_inicial/sala_calle_13_46": {
        "tipo": "casa", "nombre": "Casa del pastor de las Hoces",
        "gente": [
            ("Pastor", "pastor", "libre", [
                "Saco las ovejas por las laderas del Duratón. Aquí arriba solo estamos las ovejas, los buitres y yo.",
                "Los buitres no atacan a las ovejas vivas. Esperan. Son muy pacientes, como los de la Seguridad Social."]),
            ("Mujer", "npc_old_woman", "cocina", ["Cordero asado en horno de leña. Si viene un madrileño, le pongo doble ración para que vuelva."]),
        ],
    },
    "pueblo_inicial/sala_calle_19_14": {
        "tipo": "iglesia", "nombre": "Iglesia de San Miguel Arcángel",
        "gente": [
            ("Cura de varios pueblos", "npc_old_man", "cura", [
                "Doy misa en seis pueblos los domingos. Aquí a las doce, en el de al lado a la una. Voy en coche y rezo en las curvas.",
                "La iglesia tiene restos románicos del siglo XIII y un retablo barroco. Y cigüeñas en la torre desde siempre."]),
            ("Vecina", "npc_old_woman", "publico", ["En la fiesta de San Miguel sacamos al santo en procesión y luego hay limonada para todos."]),
        ],
    },
    "pueblo_inicial/sala_calle_25_29": {
        "tipo": "casa", "nombre": "Casa del vecino que volvió de Madrid",
        "gente": [
            ("Vecino teletrabajador", "influencerlinkedin", "mesa", [
                "Me vine de Madrid a teletrabajar en el pueblo. Tengo fibra, vistas al embalse y silencio. Bueno, y cigüeñas.",
                "En Madrid tardaba una hora en llegar a la oficina. Aquí tardo diez segundos en llegar al ordenador. Y cinco al bar."]),
            ("Pareja", "npc_woman", "tele", ["Somos de los pocos jóvenes del pueblo. En el bar nos llaman «los nuevos». Llevamos cuatro años."]),
        ],
    },
    "pueblo_inicial/sala_calle_25_39": {
        "tipo": "casa", "nombre": "Casa de la hortelana de la ribera",
        "gente": [
            ("Hortelana", "huertano", "libre", [
                "En la ribera del Duratón crecen los mejores tomates de la comarca. El agua del río y el sol de la meseta.",
                "Los chopos de la orilla dan sombra en verano y hojas amarillas en otoño. Y mucha pelusa en primavera."]),
            ("Nieto", "npc_boy", "tele", ["Mi abuela me paga un euro por cada caracol que quito de las lechugas. Este verano voy a ser rico."]),
        ],
    },
    "pueblo_inicial/sala_calle_26_48": {
        "tipo": "ermita", "nombre": "Ermita de la Virgen del Río",
        "gente": [
            ("Mayordoma de la cofradía", "npc_old_woman", "cura", [
                "El 8 de septiembre es la fiesta de la Virgen del Río. Vienen los del pueblo y los que se fueron. Ese día no falta nadie.",
                "La ermita está junto al río, a la entrada del pueblo. La Virgen mira hacia el agua, como cuidando a los que pescan."]),
            ("Devota", "npc_woman", "publico", ["Le traigo flores del campo. Las del súper no le gustan, ella es de pueblo."]),
        ],
    },
    "pueblo_inicial/sala_calle_30_39": {
        "tipo": "ayuntamiento", "nombre": "Ayuntamiento de San Miguel de Bernuy",
        "gente": [
            ("Secretaria del ayuntamiento", "npc_woman", "dependiente", [
                "Llevo la secretaría de tres ayuntamientos. Este martes y jueves, el resto de días en los otros pueblos.",
                "Para empadronarse aquí solo hace falta venir, quedarse y aguantar el primer invierno."]),
            ("Alcalde", "npc_old_man", "mesa", ["Mi programa electoral es sencillo: que no se cierre la escuela y que no se apague la luz de la plaza."]),
        ],
        "carteles": [("pared", ["Término municipal: San Miguel de Bernuy y los despoblados de Bernuy y Sarasona. España vaciada, pero no olvidada."])],
    },
    "pueblo_inicial/sala_calle_31_29": {
        "tipo": "casa", "nombre": "Casa de la peña de las fiestas",
        "gente": [
            ("Peñista", "npc_youngster", "libre", [
                "En las fiestas montamos la peña en este bajo. Hay sofás viejos, una nevera y un altavoz que se oye en el embalse.",
                "La peña se llama igual desde que mi padre la fundó. El nombre no se puede decir delante del cura."]),
            ("Peñista", "npc_lass", "tele", ["Pintamos las camisetas a mano cada año. Este año salen fatal. Como todos los años."]),
        ],
    },
    "pueblo_inicial/sala_calle_36_14": {
        "tipo": "casa", "nombre": "Casa de la cestera",
        "gente": [
            ("Cestera", "npc_old_woman", "mesa", [
                "Hago cestas con mimbre de los chopos de la ribera. Antes las hacía todo el pueblo; ahora quedo yo.",
                "Las vendo en el mercado de Sepúlveda. Los de la ciudad las usan para poner plantas. Se pierde la función, pero se queda la cesta."]),
            ("Vecino", "npc_man", "libre", ["Le traigo mimbre del río cada semana. A cambio, me regala una cesta por Navidad. Ya tengo cuarenta."]),
        ],
    },
    "pueblo_inicial/sala_calle_36_29": {
        "tipo": "panaderia", "nombre": "Panadería del pueblo",
        "gente": [
            ("Panadero", "npc_man", "dependiente", [
                "Hago pan para cinco pueblos. Salgo a las seis con la furgoneta y vuelvo a las once. Toco el claxon y salen todas las abuelas.",
                "Pan candeal, el de Castilla: blanco, prieto y con la corteza que cruje. Aguanta tres días, como los buenos amigos."]),
            ("Clienta", "npc_old_woman", "cliente", ["Una hogaza y dos libretas. Y lo de siempre para mi vecina, que hoy no baja."]),
        ],
    },
    "pueblo_inicial/sala_calle_36_39": {
        "tipo": "casa", "nombre": "Casa del pescador del embalse",
        "gente": [
            ("Pescador", "pescador", "libre", [
                "En el embalse de las Vencías hay barbos, carpas y algún lucio. Los lucios son los listos: miran la caña y se ríen.",
                "Pesco y suelto. Lo importante es la paciencia y el bocadillo. Sobre todo el bocadillo."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido sale a pescar a las seis y vuelve a las dos sin peces y muy feliz."]),
        ],
    },
    "pueblo_inicial/sala_calle_38_21": {
        "tipo": "casa", "nombre": "Casa del agricultor de cereal",
        "gente": [
            ("Agricultor", "npc_old_man", "tele", [
                "Trigo y cebada en los páramos. Cuando no llueve, mal; cuando llueve en la siega, peor. El campo nunca está contento.",
                "Antes se trillaba en la era con los mulos. Ahora pasa la cosechadora en una tarde. Echo de menos a los mulos."]),
            ("Nieta", "npc_girl", "libre", ["Mi abuelo me deja subir al tractor. Es lo más alto que he estado nunca."]),
        ],
    },
}
