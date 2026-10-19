# Interiores de Palma de Mallorca. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "palma/casa_1": {
        "tipo": "casa", "nombre": "Casa de la madona del barrio de Santa Catalina",
        "gente": [
            ("Madona", "npc_old_woman", "regalo:cocina", [
                "Madona es como llamamos aquí a las señoras de la casa. Yo soy madona desde los veinte.",
                "Antes Santa Catalina era de pescadores. Ahora es de suecos con patinete. Toma, para el camino."]),
            ("Nieto", "npc_youngster", "tele", ["Mi abuela no sabe decir «brunch». Dice «berenar tard», y tiene razón."]),
        ],
    },
    "palma/casa_2": {
        "tipo": "pasteleria", "nombre": "Forn de les ensaïmades",
        "gente": [
            ("Fornera", "npc_woman", "dependiente", [
                "La ensaimada lleva saïm, manteca de cerdo. Por eso se llama así. Si te la venden con mantequilla, no es ensaimada.",
                "Las cajas redondas de cartón son para el avión. Los de Barcelona se llevan seis y vuelven a por más."]),
            ("Alemán", "turistachanclas", "cliente", ["Eine Ensaimada, bitte. ¿Dos? Ja. ¿Diez? Ja, ja."]),
        ],
        "carteles": [("vitrina", ["ENSAÏMADA DE CABELL D'ÀNGEL. De cabello de ángel. Ningún ángel ha sido dañado."])],
    },
    "palma/sala_calle_19_6": {
        "tipo": "casa", "nombre": "Casa del payés que vende sobrasada",
        "gente": [
            ("Payés", "pastor", "libre", [
                "La sobrasada se hace con cerdo negro mallorquín y pimentón. Se cuelga y se espera. Como en el ayuntamiento.",
                "Mi finca era de mi abuelo. Ahora un alemán me ofrece un millón por ella cada verano."]),
            ("Payesa", "npc_old_woman", "cocina", ["Pan con aceite, tomate de ramallet y un trocito de sobrasada. Eso es un pa amb oli, no una tostada."]),
        ],
    },
    "palma/sala_calle_21_27": {
        "tipo": "piso", "nombre": "Piso de temporada de la camarera de hotel",
        "gente": [
            ("Camarera de piso", "npc_lass", "cama", [
                "Hago cuarenta habitaciones al día en temporada. En invierno hago cola en el paro.",
                "Pago de alquiler lo mismo que cobro. El resto de gastos los pago con fe."]),
            ("Compañera", "npc_woman", "tele", ["Somos cinco en un piso de dos habitaciones. La casera lo llama «convivencia mediterránea»."]),
        ],
    },
    "palma/sala_calle_32_40": {
        "tipo": "palacio", "nombre": "Palacio de la Almudaina",
        "gente": [
            ("Guía de Patrimonio", "npc_lass", "libre", [
                "Fue alcázar musulmán, palacio de los reyes de Mallorca y ahora residencia oficial del rey cuando viene.",
                "El ángel de la torre es el Ángel Custodio. Lleva vigilando la bahía desde el siglo XIV."]),
            ("Guardia Real", "npc_man", "libre", ["No puedo decirle si el rey está en Palma. Le diré que el barco no está en el puerto."]),
        ],
        "carteles": [("pared", ["Salón del Tinell. Aquí se celebraban los banquetes de los reyes de Mallorca. Ahora, las recepciones de verano."])],
    },
    "palma/sala_calle_3_38": {
        "tipo": "casa", "nombre": "Casa del regatista jubilado",
        "gente": [
            ("Regatista jubilado", "regatista", "tele", [
                "Corrí la Copa del Rey veinte veces. Ganó el rey dos. Yo, ninguna. Pero yo no tenía el barco del rey.",
                "En agosto el puerto se llena de yates. Algunos tienen piscina. Dentro del barco. En el mar."]),
            ("Mujer", "npc_old_woman", "cocina", ["Mi marido habla más de barcos que de mí. Por lo menos los barcos no le contestan."]),
        ],
    },
    "palma/sala_calle_42_41": {
        "tipo": "catedral", "nombre": "La Seu, catedral de Mallorca",
        "gente": [
            ("Sacristana", "npc_old_woman", "cura", [
                "La Seu tiene el rosetón gótico más grande del mundo. Cuando entra el sol por la mañana, el suelo se llena de colores.",
                "El baldaquino lo hizo Gaudí. Lo dejó a medias, como casi todo. Pero aquí nadie se queja."]),
            ("Turista", "turista", "publico", ["¿Esto es de Gaudí o de Barceló? Mi guía dice que de los dos, y que de Dios un poco."]),
        ],
        "dentro": {
            "palma/sala_calle_42_41_barcelo": {
                "tipo": "galeria", "nombre": "Capilla del Santísimo de Miquel Barceló",
                "gente": [("Restauradora", "npc_woman", "vitrina", [
                    "Barceló cubrió la capilla de cerámica: peces, panes, calaveras y frutas. Unos lo adoran y otros lo llaman «la cueva».",
                    "La cerámica se cocinó en Italia y se montó aquí pieza a pieza. Como un puzle, pero de arcilla."])],
                "carteles": [("pared", ["El milagro de los panes y los peces, en barro. Hay un pulpo. No preguntes por el pulpo."])],
            },
        },
    },
    "palma/sala_calle_44_12": {
        "tipo": "casa", "nombre": "Casa del vecino del Molinar",
        "gente": [
            ("Pescador", "npc_fisherman", "libre", [
                "El Molinar era un barrio de molinos y pescadores. Los molinos se pararon; los pescadores, casi.",
                "Llevo la llampuga a la lonja en otoño. En verano llevo turistas a ver delfines. Dan más dinero los turistas."]),
            ("Hija", "npc_girl", "tele", ["Mi padre dice que los delfines le reconocen. Yo creo que reconocen el pan."]),
        ],
    },
    "palma/sala_calle_45_26": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Palma",
        "gente": [
            ("Monitora", "crossfitero_f", "libre", [
                "En mayo todos quieren el cuerpo de playa. En junio ya están en la playa y en julio dejan de venir.",
                "Hay socios alemanes que vienen solo en agosto. Pagan el año entero. Son nuestros favoritos."]),
            ("Socio", "tronista", "libre", ["Entreno para el Magaluf. Allí no se baila: se sobrevive."]),
        ],
    },
    "palma/sala_calle_54_30": {
        "tipo": "piso", "nombre": "Piso turístico del Paseo Marítimo",
        "gente": [
            ("Anfitrión de piso turístico", "influencerlinkedin", "libre", [
                "Tengo nueve pisos turísticos en la isla. Mi empresa se llama «Vive como un local». Yo vivo en Barcelona.",
                "La llave está en una caja con código. El código es la fecha de mi primer piso."]),
            ("Turista inglesa", "turista_f", "cama", ["The flat is lovely. El ruido de las maletas a las cuatro de la mañana, not so much."]),
        ],
    },
    "palma/sala_calle_57_21": {
        "tipo": "casa", "nombre": "Casa de la pintora del barrio de la Llotja",
        "gente": [
            ("Pintora", "npc_woman", "mesa", [
                "Miró vivió en Mallorca sus últimos años. Dijo que la luz de aquí lo cambiaba todo. A mí me cambió el alquiler.",
                "Pinto el mar desde la ventana. Lo vendo a los del crucero. El cuadro llega a Miami y el mar se queda."]),
            ("Gato", "npc_boy", "libre", ["Miau. Bueno, soy el sobrino. Me ha pedido que haga de gato para un cuadro."]),
        ],
    },
    "palma/sala_calle_59_43": {
        "tipo": "portal", "nombre": "Portal de la calle Jaume III",
        "gente": [("Portero", "npc_old_man", "libre", [
            "Jaume III es la calle de las tiendas caras. Los soportales son para que no te dé el sol mientras te arruinas.",
            "Antes en este portal vivían familias. Ahora vive una caja de llaves."])],
    },
    "palma/sala_calle_61_30": {
        "tipo": "institucion", "nombre": "Consell de Mallorca",
        "gente": [
            ("Consellera", "npc_woman", "mesa", [
                "Hablamos de la ecotasa: dos euros por turista y noche. Los turistas pagan y la isla sigue igual de llena.",
                "Queremos limitar los cruceros. Los cruceros quieren limitarnos a nosotros."]),
            ("Ujier", "npc_man", "libre", ["Las sesiones del pleno son en catalán. Las preguntas de los turistas, en todos los idiomas."]),
        ],
        "carteles": [("pared", ["Escudo de Mallorca: castillo sobre el agua. Antes significaba defensa. Ahora, segunda residencia."])],
    },
    "palma/sala_calle_66_43": {
        "tipo": "piso", "nombre": "Piso del chef de un restaurante de la playa",
        "gente": [
            ("Chef", "camarero", "cocina", [
                "Por la mañana hago tumbet y frit mallorquí para mi madre. Por la noche, hamburguesas para los turistas.",
                "El tumbet es como un pisto, pero con patata y más sol."]),
            ("Madre del chef", "npc_old_woman", "tele", ["Mi hijo cocina en un restaurante de lujo. A mí me trae las sobras de lujo."]),
        ],
    },
    "palma/sala_calle_67_13": {
        "tipo": "portal", "nombre": "Portal de las Avenidas",
        "gente": [("Vecina mayor", "npc_old_woman", "libre", [
            "Llevo sesenta años en este portal. He visto llegar a los ingleses, a los alemanes y ahora a los nómadas digitales.",
            "Los nómadas digitales no hacen ruido. Solo llamadas por la mañana, en inglés, en el rellano."])],
    },
    "palma/sala_calle_67_29": {
        "tipo": "casa", "nombre": "Casa del músico que toca a Chopin",
        "gente": [
            ("Músico", "flautista", "libre", [
                "Chopin pasó un invierno en Valldemossa con George Sand. Le llovió todo el invierno. Lo escribió en el preludio de la gota de agua.",
                "Toco en las calles de Palma. Los turistas me piden Chopin; los de aquí, que me calle."]),
            ("Sobrina", "npc_lass", "tele", ["Mi tío se cree Chopin. Chopin, al menos, tenía piano."]),
        ],
    },
    "palma/sala_calle_7_14": {
        "tipo": "castillo", "nombre": "Castell de Bellver",
        "gente": [
            ("Guarda", "guarda_parque", "libre", [
                "Es el único castillo circular de España, del siglo XIV. Redondo para que no hubiera esquinas donde esconderse.",
                "Fue prisión. Aquí estuvo encerrado Jovellanos. Se pasaba el día escribiendo sobre la vista."]),
            ("Excursionista", "montanera", "libre", ["He subido andando por el bosque. Desde arriba se ve toda la bahía y catorce cruceros."]),
        ],
        "carteles": [("pared", ["Patio de armas circular, de dos pisos. Un castillo sin esquinas: aquí nadie se queda arrinconado."])],
    },
}
