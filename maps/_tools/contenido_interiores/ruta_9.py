# Interiores de la Ruta 9 (Devesa del Saler, la Albufera y El Palmar, Cullera y Gandía). Propuesta provisional.
SALAS = {
    "ruta_9/sala_calle_18_15": {
        "tipo": "rural", "nombre": "Casa forestal de la Devesa",
        "gente": [
            ("Guarda de la Devesa", "guarda_parque", "libre", [
                "Las dunas de la Devesa las replantamos a mano, planta a planta. Un coche aparcado encima se las carga en una tarde.",
                "En verano hago la ronda de las once de la noche. Siempre encuentro a alguien preparando una barbacoa «pequeñita»."]),
            ("Bióloga", "ornitologa", "mesa", ["Estoy contando fartets, un pez pequeño que solo vive en estas costas. Si ves uno, no lo pesques: no es un boquerón."]),
        ],
    },
    "ruta_9/sala_calle_16_24": {
        "tipo": "barraca", "nombre": "Barraca del anguilero",
        "gente": [
            ("Anguilero", "pescador", "libre", [
                "La anguila nace en el mar de los Sargazos y cruza el Atlántico para meterse en mi red. Hay que tener mala suerte.",
                "Con ella se hace el all i pebre: ajo, pimentón, guindilla y anguila. Si no repites, es que no era de aquí."]),
            ("Su mujer", "npc_woman", "cocina", ["La barraca tiene el tejado de paja y la cocina de vitrocerámica. Mitad patrimonio, mitad Ikea."]),
        ],
    },
    "ruta_9/sala_calle_21_24": {
        "tipo": "barraca", "nombre": "Barraca de la abuela del arroz",
        "gente": [
            ("Abuela", "abuela", "cocina", [
                "La paella se hace en el fuego de leña, se come de la paella con cuchara y se deja el socarrat para el final.",
                "Mi nieta me trajo una «paella fit» con quinoa. La he denunciado a la Guardia Civil."]),
            ("Nieta", "npc_lass", "libre", ["Mi abuela tiene un grupo de WhatsApp para denunciar paellas mal hechas. Tiene más miembros que el pueblo."]),
        ],
    },
    "ruta_9/sala_calle_17_33": {
        "tipo": "barraca", "nombre": "Barraca del barquero de vela latina",
        "gente": [
            ("Barquero", "marinero", "libre", [
                "Las barcas de vela latina llevaban arroz y paja por los canales. Ahora llevan parejas haciéndose fotos al atardecer.",
                "En la Albufera hay que empujar la barca con una pértiga. Los turistas preguntan dónde está el motor. El motor soy yo."]),
            ("Turista", "turista_f", "visitante", ["He reservado el paseo al atardecer por internet. Ponía «experiencia auténtica». El barquero lleva un chaleco con QR."]),
        ],
    },
    "ruta_9/sala_calle_22_33": {
        "tipo": "restaurante", "nombre": "Arrocería de El Palmar",
        "gente": [
            ("Arrocero", "camarero", "tras_mostrador", [
                "Arroz del Palmar, cultivado aquí al lado. Lo que no plantamos nosotros, lo plantan los patos. Y lo que no, los turistas lo pisan.",
                "Con la sequía de la Albufera, este año el arroz salió caro. La paella, igual de cara que siempre: eso no lo arregla la lluvia."]),
            ("Comensal", "turistachanclas", "mesa", ["I asked for sangría with my paella. The waiter looked at me like I had insulted his mother."]),
        ],
    },
    "ruta_9/sala_calle_22_40": {
        "tipo": "puesto", "nombre": "Puesto de tellinas y clóchinas",
        "gente": [
            ("Vendedora", "npc_woman", "dependiente", [
                "Tellinas de la playa del Saler y clóchinas del puerto. La clóchina solo se come de mayo a agosto: el resto del año es un mejillón.",
                "Con ajo, perejil y un chorro de limón. Si le echas tomate, lo mismo te las devuelvo yo a la playa."]),
        ],
    },
    "ruta_9/sala_calle_19_56": {
        "tipo": "portal", "nombre": "Torre de apartamentos de Cullera",
        "gente": [
            ("Portero", "npc_old_man", "libre", [
                "En invierno, en esta torre vivimos cuatro. En agosto, cuatrocientos. Y todos quieren el ascensor a la vez.",
                "Los de Madrid vienen en julio, los de Albacete en agosto y los alemanes en noviembre. Así se reparte Cullera."]),
            ("Veraneante de Albacete", "padretarjeta", "visitante", ["Desde Albacete se tarda dos horas al mar. Lo que se tarda en Albacete en ir a cualquier sitio."]),
        ],
    },
    "ruta_9/sala_calle_34_55": {
        "tipo": "faro", "nombre": "Faro de Cullera",
        "gente": [
            ("Farero", "marinero", "libre", [
                "El faro ya funciona solo. Yo vengo a limpiar la lente, a cambiar alguna bombilla y a que no se sienta abandonado.",
                "Desde aquí se ve el cabo de San Antonio, en Jávea. En días muy claros, dicen que Ibiza. Yo solo he visto la niebla."]),
        ],
        "carteles": [("pared", ["Un dibujo de la costa con los faros: Cullera, Jávea, Denia. Alguien ha añadido a lápiz «aquí tu Pokémon»."])],
    },
    "ruta_9/sala_calle_15_65": {
        "tipo": "casa", "nombre": "Casa de la familia gandiense",
        "gente": [
            ("Madre", "mom", "cocina", [
                "En agosto alquilamos el piso de la playa y nos venimos al de la abuela. Con eso pagamos el colegio de los niños.",
                "Hay que ver la gente que viene a Gandía: sevillanos, madrileños, alemanes... Y de Gandía, solo yo."]),
            ("Hijo opositor", "opositor", "mesa", ["Oposito a profesor de Historia. Gandía me ayuda: aquí nació un papa, un santo y un duque, y me los tengo que aprender."]),
        ],
    },
    "ruta_9/sala_calle_22_66": {
        "tipo": "heladeria", "nombre": "Horchatería de Gandía",
        "gente": [
            ("Horchatera", "npc_lass", "tras_mostrador", [
                "La horchata se hace con chufa de Alboraya, agua y azúcar. Nada más. Si lleva leche, es un batido con complejo.",
                "Fartons para mojar. Si te sobran, no los guardes: al día siguiente son un arma."]),
            ("Cliente", "npc_boy", "cliente", ["Mi madre dice que la horchata es sana. Yo me he tomado tres y me noto sanísimo."]),
        ],
    },
    "ruta_9/sala_calle_31_65": {
        "tipo": "chalet", "nombre": "Chalet del reality de Gandía",
        "gente": [
            ("Exconcursante", "tronista", "sofa", [
                "Yo salí en la primera temporada. Tres semanas de fiesta, cámaras en el baño y un jacuzzi que no he vuelto a ver tan lleno.",
                "Ahora vendo seguros. Cuando me reconocen, me piden una foto. Cuando me piden un seguro, no me reconocen."]),
            ("Dueña del chalet", "npc_old_woman", "libre", ["Lo alquilé para una serie de la tele. Me dijeron «un programa familiar». Aún estoy sacando purpurina de la piscina."]),
        ],
    },
    "ruta_9/sala_calle_7_66": {
        "tipo": "palacio", "nombre": "Palau Ducal dels Borja",
        "gente": [
            ("Guía del Palau", "profesor", "libre", [
                "Aquí nació Francisco de Borja, duque de Gandía. Lo dejó todo para hacerse jesuita y acabó de santo. Lo normal en esta familia.",
                "Su bisabuelo fue el papa Alejandro VI. Los Borja de Roma tenían mala fama; los de Gandía, una fábrica de azúcar."]),
            ("Visitante", "turista", "visitante", ["Vengo por la serie de los Borgia. Me han dicho que es más fiel la del palacio. Menos sangre, más azulejo."]),
        ],
        "dentro": {
            "ruta_9/sala_calle_7_66_galeria": {
                "tipo": "museo", "nombre": "Galería Dorada del Palau",
                "gente": [("Restauradora", "npc_woman", "libre", [
                    "Esta galería se decoró para celebrar la santidad de Francisco de Borja: techos dorados y suelo de azulejo valenciano.",
                    "El azulejo pintado a mano no se pisa con tacones. Lo pone en la entrada. Lo leen después de pisarlo."])],
                "carteles": [("pared", ["Un suelo de azulejos con los cuatro elementos: agua, aire, tierra y fuego. Ningún Pokémon de tipo Planta: se ve que no los conocían."])],
            },
        },
    },
    "ruta_9/sala_calle_41_67": {
        "tipo": "socorrismo", "nombre": "Caseta de socorrismo de la playa de Gandía",
        "gente": [
            ("Socorrista", "nadador_f", "libre", [
                "Bandera verde, amarilla o roja. La roja quiere decir «no te bañes». Hay quien lo entiende como «bañarse con más emoción».",
                "Hoy he rescatado a un señor, a un flotador con forma de unicornio y a un niño que iba en el unicornio. Por ese orden."]),
        ],
    },
    "ruta_9/sala_calle_5_74": {
        "tipo": "casa", "nombre": "Apartamento de los veraneantes de toda la vida",
        "gente": [
            ("Veraneante jubilado", "jubiladoobras", "tele", [
                "Venimos a Gandía desde 1987. El mismo apartamento, la misma sombrilla y la misma discusión por el aire acondicionado.",
                "Antes la playa estaba vacía. Ahora está llena de gente como yo hace treinta años. No me gusta nada."]),
            ("Su mujer", "npc_old_woman", "cocina", ["Él va a la playa a las ocho a poner la sombrilla. Yo voy a las doce. La sombrilla nos espera los dos turnos."]),
        ],
    },
    "ruta_9/sala_calle_11_74": {
        "tipo": "souvenirs", "nombre": "Tienda de recuerdos del paseo",
        "gente": [
            ("Dependiente", "clerk", "tras_mostrador", [
                "Imanes de la paella, abanicos y toallas con el toro. La toalla del toro la hacen en China y la compran los chinos.",
                "Lo que más se vende en verano es protector solar. Lo segundo, aftersun para los que no lo compraron."]),
        ],
    },
    "ruta_9/sala_calle_17_74": {
        "tipo": "casa", "nombre": "Casa del DJ de verano",
        "gente": [
            ("DJ", "raver", "libre", [
                "Pincho en un chiringuito de la playa de junio a septiembre. El resto del año pincho en bodas, que pagan mejor.",
                "Si pongo reguetón, protestan los de cuarenta. Si pongo los ochenta, bailan los de cuarenta y se van los de veinte. Ganan los de cuarenta."]),
        ],
    },
    "ruta_9/sala_calle_23_74": {
        "tipo": "peluqueria", "nombre": "Peluquería del paseo marítimo",
        "gente": [
            ("Peluquera", "npc_lass", "tras_mostrador", [
                "En verano peino trenzas de playa a las turistas y en invierno tinto a las abuelas de Gandía. Las abuelas dan mejor propina.",
                "La sal y el cloro destrozan el pelo. Te lo digo yo, que me baño todos los días a la hora de comer."]),
            ("Clienta", "npc_old_woman", "cliente", ["Vengo todos los sábados a que me peinen para la misa del domingo. El domingo llueve. Siempre."]),
        ],
    },
    "ruta_9/sala_calle_32_74": {
        "tipo": "heladeria", "nombre": "Heladería del Paseo",
        "gente": [
            ("Heladero", "npc_man", "tras_mostrador", [
                "Tengo treinta sabores. El que más se vende es el de vainilla. Treinta sabores para que me pidan vainilla.",
                "En septiembre cierro y me voy de vacaciones. Tú vienes en verano a mi pueblo; yo me voy en otoño al tuyo."]),
            ("Niña", "npc_girl", "cliente", ["Quiero uno de chocolate, uno de fresa y uno de turrón. Para mí sola. Es que es verano."]),
        ],
    },
}
