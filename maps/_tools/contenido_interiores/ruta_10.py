# Interiores de la Ruta 10 (Calp, Altea, Benidorm y La Vila Joiosa). Propuesta provisional.
SALAS = {
    "ruta_10/sala_calle_31_8": {
        "tipo": "casa", "nombre": "Casa del pescador de Calp",
        "gente": [
            ("Pescador de Calp", "pescador", "libre", [
                "En la lonja de Calp se subasta el pescado a la vista del público. Los turistas pujan con los ojos y compran en el súper.",
                "La gamba roja de aquí se cotiza como el oro. Yo me como las que se rompen."]),
            ("Su hija", "npc_lass", "libre", ["Mi padre dice que el Peñón protege el puerto. Yo creo que lo que protege el puerto son los precios de la gamba."]),
        ],
    },
    "ruta_10/sala_calle_35_8": {
        "tipo": "casa", "nombre": "Casa de la jubilada holandesa",
        "gente": [
            ("Jubilada holandesa", "turista_f", "tele", [
                "Vine de vacaciones en 1998 y no me fui. En Holanda llueve; aquí llueve tres veces al año y sale en el telediario.",
                "Mi vecina es inglesa, la de enfrente alemana y el del bar ucraniano. El único español del barrio es el cartero."]),
        ],
        "carteles": [("pared", ["Un calendario de Ámsterdam con todos los días tachados de sol. Ninguno de lluvia."])],
    },
    "ruta_10/sala_calle_31_13": {
        "tipo": "casa", "nombre": "Casa del escalador del Peñón",
        "gente": [
            ("Escalador", "montanera", "libre", [
                "La vía normal del Peñón tiene un túnel y una cadena. Por ahí sube todo el mundo. Yo subo por la pared, que hay menos cola.",
                "Arriba anidan las gaviotas de Audouin. Te defienden el nido como un portero de discoteca."]),
        ],
    },
    "ruta_10/sala_calle_16_20": {
        "tipo": "casa", "nombre": "Estudio del pintor de Altea",
        "gente": [
            ("Galerista", "hippie", "libre", [
                "Altea está llena de artistas desde los años sesenta. Vinieron por la luz y se quedaron por el alquiler. Luego el alquiler se fue.",
                "Vendo cuadros de la cúpula azul. Pintados por el señor de la plaza, que lleva cuarenta años sin acabar uno."]),
        ],
        "carteles": [("pared", ["Cuadros de la cúpula azul de Altea. Treinta y dos azules distintos. El precio, el mismo."])],
    },
    "ruta_10/sala_calle_18_24": {
        "tipo": "casa", "nombre": "Casa de la vecina del casco antiguo",
        "gente": [
            ("Vecina de Altea", "npc_old_woman", "libre", [
                "Las casas de mi calle eran de pescadores. Ahora son de alquiler turístico. Mi calle es la única con más maletas que vecinos.",
                "Me ofrecieron una fortuna por la casa. Les dije que no. Ahora me ofrecen el doble, pero me ponen un candado al lado."]),
        ],
    },
    "ruta_10/sala_calle_10_23": {
        "tipo": "iglesia", "nombre": "Iglesia de Nuestra Señora del Consuelo",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "La cúpula está hecha de teja vidriada azul y blanca. Por eso brilla al sol. Y por eso la ves en todas las tazas de recuerdo.",
                "A misa viene poca gente. A hacerse fotos en la puerta, cientos. Algún día les pasaré el cepillo."]),
            ("Novia", "invitada_boda", "visitante", ["Me caso aquí en mayo. Me ha costado más la lista de espera que el vestido."]),
        ],
    },
    "ruta_10/sala_calle_41_27": {
        "tipo": "socorrismo", "nombre": "Caseta del socorrista de la Olla",
        "gente": [
            ("Socorrista", "surfista", "libre", [
                "La playa de la Olla es de cantos rodados. Los que vienen descalzos sueltan unos gritos que se oyen en Benidorm.",
                "Mi trabajo es mirar el mar ocho horas. Mi madre cree que es el trabajo más fácil del mundo. Mi madre no ha visto a un inglés con flotador."]),
        ],
    },
    "ruta_10/sala_calle_6_40": {
        "tipo": "piso", "nombre": "Apartamento de los jubilados ingleses",
        "gente": [
            ("Jubilado inglés", "turistachanclas", "tele", [
                "We watch the British telly, we eat British food and we drink British beer. In the sun. That's the difference.",
                "My grandson asked me if I speak Spanish. I said «una cerveza, por favor». That's all I need."]),
            ("Su mujer", "turistachanclas_f", "sofa", ["We came for two weeks in 1985. My husband still has the return ticket in his wallet."]),
        ],
    },
    "ruta_10/sala_calle_10_40": {
        "tipo": "hotel", "nombre": "Hotel del Imserso",
        "gente": [
            ("Recepcionista", "clerk", "tras_mostrador", [
                "En temporada baja el hotel es del Imserso. Si quitaran el Imserso, en Benidorm cerrarían medio centenar de hoteles.",
                "Los huéspedes desayunan a las siete, comen a las doce y cenan a las siete. A las nueve hay baile. A las diez, silencio."]),
            ("Jubilada bailona", "abuela", "visitante", ["Esta noche hay pasodoble y bachata. Mi marido no viene: dice que le duele la rodilla. Mejor: bailo con todos."]),
        ],
    },
    "ruta_10/sala_calle_15_40": {
        "tipo": "portal", "nombre": "Portal del Intempo",
        "gente": [
            ("Conserje del Intempo", "clerk", "libre", [
                "Cuarenta y siete plantas en forma de M. El arquitecto quería una puerta al cielo. Los compradores querían garaje.",
                "Hay pisos vacíos, pisos de inversores y pisos de alquiler por días. Vecinos de verdad, en la planta cuatro y en la doce."]),
        ],
        "dentro": {
            "ruta_10/sala_calle_15_40_atico": {
                "tipo": "piso", "nombre": "Ático del Intempo",
                "gente": [("Inversor", "influencerlinkedin", "libre", [
                    "Compré el ático sin verlo, por videollamada. Desde aquí se ve todo Benidorm, el mar y la grúa del edificio de al lado.",
                    "Vengo dos semanas al año. El resto, lo alquilo a gente que viene a hacerse fotos en el balcón."])],
                "carteles": [("pared", ["Un ventanal de suelo a techo. Abajo, la playa de Levante, llena de sombrillas, parece un tablero de parchís."])],
            },
        },
    },
    "ruta_10/sala_calle_20_40": {
        "tipo": "piso", "nombre": "Apartamento de la despedida de soltero",
        "gente": [
            ("Padrino de la despedida", "raver", "libre", [
                "Venimos doce de Bilbao para la despedida de Asier. Asier lleva disfraz de pollo desde el jueves. Es sábado.",
                "Mañana volvemos. Asier se casa el viernes. Si se acuerda."]),
            ("Asier", "cunado", "sofa", ["No me hables muy alto. Y no me mires a los ojos. Y no digas la palabra «chupito»."]),
        ],
    },
    "ruta_10/sala_calle_9_50": {
        "tipo": "bar", "nombre": "The Red Lion",
        "gente": [
            ("Dueña del pub", "camarero", "tras_mostrador", [
                "Soy de Murcia. Me llamo Encarna. Para los clientes, Annie. Así me dejan más propina.",
                "Hay karaoke los jueves. Los ingleses cantan Queen, los españoles cantan Camela y a las doce todos cantan Camela."]),
            ("Cliente", "turista", "cliente", ["This is the best pub in England. And it's in Spain. Brilliant."]),
        ],
    },
    "ruta_10/sala_calle_16_50": {
        "tipo": "tienda", "nombre": "Supermercado británico",
        "gente": [
            ("Dependiente", "npc_man", "tras_mostrador", [
                "Judías en tomate, té, salchichas y pan de molde. Todo traído de Inglaterra. El aceite de oliva, de Jaén: ese se lo venden ellos a sí mismos.",
                "Los españoles entran a curiosear y salen con una bolsa de chocolatinas. Somos un puente entre culturas."]),
        ],
    },
    "ruta_10/sala_calle_22_50": {
        "tipo": "floristeria", "nombre": "Floristería de Benidorm",
        "gente": [
            ("Florista", "npc_woman", "tras_mostrador", [
                "Hago coronas para las despedidas de soltera, ramos para las bodas y coronas para los entierros. Todo el ciclo, en la misma calle.",
                "Las buganvillas de los hoteles las pongo yo. Los turistas creen que crecen solas. Solas, solo las facturas."]),
        ],
    },
    "ruta_10/sala_calle_32_51": {
        "tipo": "portal", "nombre": "Portal de los vecinos de Benidorm",
        "gente": [
            ("Vecino de Benidorm", "npc_man", "libre", [
                "Soy de Benidorm de toda la vida. Existimos. Somos unos setenta mil, aunque en agosto no nos encuentra nadie.",
                "Mi abuelo pescaba atunes antes de que hubiera un solo rascacielos. Ahora mi abuelo vive en el piso trece."]),
        ],
    },
    "ruta_10/sala_calle_7_60": {
        "tipo": "tienda", "nombre": "Chocolatería de La Vila",
        "gente": [
            ("Chocolatera", "npc_old_woman", "tras_mostrador", [
                "El cacao llegaba por mar desde América y aquí lo molíamos a mano. Antes de las fábricas, cada familia tenía su receta.",
                "Pruébalo a la piedra, con canela. Si luego no te apetece otro, es que no lo has probado bien."]),
            ("Cliente", "npc_girl", "cliente", ["He venido a ver la fábrica de chocolate y no me han dejado comérmela entera."]),
        ],
    },
    "ruta_10/sala_calle_11_59": {
        "tipo": "casa", "nombre": "Casa azul del pescador",
        "gente": [
            ("Pescador jubilado", "npc_old_man", "tele", [
                "Mi casa es azul porque la de mi padre era azul. Si la pinto de otro color, me pierdo yo, no los barcos.",
                "Cada año el Ayuntamiento me dice qué azul puedo usar. El mar no me lo dijo nunca."]),
        ],
    },
    "ruta_10/sala_calle_17_59": {
        "tipo": "casa", "nombre": "Casa del festero de Moros y Cristianos",
        "gente": [
            ("Festero", "npc_man", "libre", [
                "En julio La Vila celebra Moros y Cristianos con un desembarco en la playa. Los moros llegan en barca, los cristianos los esperan en la arena.",
                "Yo salgo de moro. Me cuesta el traje más que las vacaciones, pero desembarcar con la banda sonando no lo paga nadie."]),
            ("Su mujer", "npc_woman", "cocina", ["Toda la casa huele a pólvora de julio a julio. Los vecinos ya ni se asustan."]),
        ],
    },
    "ruta_10/sala_calle_23_60": {
        "tipo": "casa", "nombre": "Casa roja de la familia del puerto",
        "gente": [
            ("Madre", "mom", "cocina", [
                "Mi marido sale a pescar a las cuatro y vuelve a las tres. Yo me levanto a las cuatro para despedirlo. No he dormido una noche entera desde 1995."]),
            ("Hijo", "npc_youngster", "libre", ["Mi padre quiere que sea pescador. Yo quiero ser youtuber. Mi madre quiere que sea funcionario. Gana mi madre."]),
        ],
    },
}
