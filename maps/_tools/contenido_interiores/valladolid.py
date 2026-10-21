# Interiores de Valladolid. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "valladolid/casa_1": {
        "tipo": "casa", "nombre": "Casa de la familia pucelana de la Plaza Mayor",
        "gente": [
            ("Abuela pucelana", "npc_old_woman", "regalo:cocina", [
                "Aquí no se dice «vallisoletano», se dice «pucelano». Y no preguntes por qué, que nadie lo sabe seguro.",
                "Toma, para el frío. En Valladolid hay nueve meses de invierno y tres de infierno."]),
            ("Nieto", "npc_youngster", "tele", ["Mi abuela dice «ahivalaostia» cuando algo le sorprende. Es una sola palabra, de aquí."]),
        ],
    },
    "valladolid/casa_2": {
        "tipo": "casa", "nombre": "Casa del cofrade de Semana Santa",
        "gente": [
            ("Cofrade", "costalero", "libre", [
                "La Semana Santa de Valladolid es de silencio. Los pasos son tallas del Museo de Escultura que salen a la calle.",
                "Gregorio Fernández talló Cristos que parecen respirar. Los sacamos a hombros en procesión, con cuidado de no despertarlos."]),
            ("Hija", "npc_lass", "tele", ["El Sermón de las Siete Palabras se dice en la Plaza Mayor. Hace tanto frío que se oyen ocho: la octava es «brrr»."]),
        ],
    },
    "valladolid/sala_calle_20_51": {
        "tipo": "institucion", "nombre": "Academia de Caballería",
        "gente": [
            ("Cadete", "npc_man", "libre", [
                "Aquí se forman los oficiales de Caballería desde el siglo XIX. Los caballos ahora son blindados, pero el nombre se queda.",
                "Mi Rapidash no entra en el reglamento. Lo he consultado."]),
            ("Ordenanza", "npc_old_man", "dependiente", ["La estatua del jinete de la puerta lleva cien años sin desmontar. Más disciplina que nadie."]),
        ],
        "carteles": [("pared", ["Academia de Caballería, 1852. Lema: «Por la Patria». Debajo, a lápiz: «y por el bocadillo de las once»."])],
    },
    "valladolid/sala_calle_23_15": {
        "tipo": "iglesia", "nombre": "Iglesia de San Pablo",
        "gente": [
            ("Fraile dominico", "npc_old_man", "cura", [
                "La fachada de San Pablo es un retablo de piedra gótico. Si la miras despacio, encuentras escudos, santos y algún bicho.",
                "Aquí fue bautizado Felipe II, que nació en Valladolid. Valladolid fue capital de España cinco años. Lo recordamos a menudo."]),
            ("Visitante", "npc_woman", "publico", ["He venido desde Medina del Campo a ver la fachada. Me he quedado con tortícolis."]),
        ],
        "dentro": {
            "valladolid/sala_calle_23_15_museo": {
                "tipo": "museo", "nombre": "Museo Nacional de Escultura",
                "gente": [("Conservadora", "npc_lass", "vitrina", [
                    "Tallas de Alonso Berruguete, Juan de Juni y Gregorio Fernández. Madera policromada que parece carne.",
                    "Las lágrimas de algunas vírgenes son de cristal. Sí, de cristal de verdad. Lloran mejor que yo."])],
                "carteles": [("pared", ["Colegio de San Gregorio (1488–1496). El patio es tan bonito que los visitantes se olvidan de entrar a las salas."])],
            },
        },
    },
    "valladolid/sala_calle_3_18": {
        "tipo": "casa", "nombre": "Casa del lechazo asado",
        "gente": [
            ("Asador", "camarero", "cocina", [
                "Lechazo churro, horno de leña, agua y sal. Nada más. El que le pone romero está en Burgos.",
                "Un cuarto de lechazo para dos personas. Si sois de Madrid, para una."]),
            ("Comensal", "cunado", "cliente", ["He venido en AVE desde Madrid solo para comer lechazo. Vuelvo en AVE para echar la siesta."]),
        ],
    },
    "valladolid/sala_calle_3_6": {
        "tipo": "casa", "nombre": "Casa de la escritora de la calle Santiago",
        "gente": [
            ("Escritora", "npc_woman", "mesa", [
                "Delibes vivió aquí y escribió sobre el campo castellano, la caza y los niños que se van a la ciudad. Yo escribo sobre mi gato.",
                "Zorrilla, el del Tenorio, también era de Valladolid. Aquí cada calle tiene un escritor y un bar."]),
            ("Gato", "npc_boy", "libre", ["Soy su sobrino. Me paga para no hacer ruido mientras escribe. Es el mejor trabajo del mundo."]),
        ],
    },
    "valladolid/sala_calle_47_9": {
        "tipo": "casa", "nombre": "Casa del bodeguero de la Ribera del Duero",
        "gente": [
            ("Bodeguero", "vendimiador", "libre", [
                "Ribera del Duero, Rueda, Toro y Cigales. Valladolid tiene más denominaciones de origen que algunos países.",
                "El verdejo de Rueda se toma frío y el tinto de la Ribera, despacio. Lo contrario es pecado."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido lleva el vino en la sangre. Por eso le sale la nariz roja."]),
        ],
    },
    "valladolid/sala_calle_49_47": {
        "tipo": "pasteleria", "nombre": "Confitería de las Delicias del Pasaje",
        "gente": [
            ("Confitera", "npc_old_woman", "dependiente", [
                "Pastas de Tordesillas, almendrados y la tarta de la casa. Los domingos hay cola desde la misa de doce.",
                "El Pasaje Gutiérrez es de 1886. Antes de los centros comerciales, la gente paseaba aquí a mirar escaparates."]),
            ("Niño", "npc_boy", "cliente", ["Mi abuela me trae aquí cada domingo si me porto bien. Me porto bien los domingos."]),
        ],
    },
    "valladolid/sala_calle_50_26": {
        "tipo": "casa", "nombre": "Casa del actor del Teatro Zorrilla",
        "gente": [
            ("Actor", "npc_man", "libre", [
                "Hago el Tenorio en noviembre en el Teatro Zorrilla. «¿No es verdad, ángel de amor…?» Las señoras de primera fila se lo saben.",
                "En la SEMINCI vienen directores de todo el mundo. Yo les sirvo el vino en el cóctel, por si me ven."]),
            ("Compañera", "npc_lass", "tele", ["Lleva veinte años haciendo de Don Juan. Ya tiene más edad de Comendador."]),
        ],
    },
    "valladolid/sala_calle_56_48": {
        "tipo": "casa", "nombre": "Casa de la familia del Campo Grande",
        "gente": [
            ("Madre", "npc_woman", "cocina", [
                "En el Campo Grande hay pavos reales sueltos. Se te comen el bocadillo si te descuidas.",
                "Los domingos paseamos por la Acera de Recoletos. Es lo que se hace en Valladolid: pasear, saludar y criticar."]),
            ("Hija", "npc_girl", "tele", ["Un pavo real me robó un ganchito. Lo vi abrir la cola de lo contento que estaba."]),
        ],
    },
    "valladolid/sala_calle_59_16": {
        "tipo": "catedral", "nombre": "Catedral de Valladolid",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "La trazó Juan de Herrera, el de El Escorial. Iba a ser enorme. Se acabó el dinero y se quedó en un cuarto.",
                "Es la catedral inacabada más famosa de Castilla. La torre se cayó en 1841. La otra ni se empezó."]),
            ("Turista", "turista", "publico", ["It looks like El Escorial, but smaller. And unfinished. Like my thesis."]),
        ],
    },
    "valladolid/sala_calle_64_38": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Valladolid",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "En invierno la gente viene por la calefacción. En enero tenemos más socios que el Real Valladolid.",
                "Un socio entrena con un abrigo de plumas. Dice que es para quemar más. Es para no pasar frío al salir."]),
            ("Socia", "crossfitero_f", "libre", ["Me apunté para la San Silvestre. La corrí con bufanda y gorro."]),
        ],
    },
    "valladolid/sala_calle_65_50": {
        "tipo": "casa", "nombre": "Casa del aficionado del Real Valladolid",
        "gente": [
            ("Aficionado blanquivioleta", "npc_old_man", "tele", [
                "Llevo cuarenta años en Zorrilla. Hemos subido, bajado y vuelto a subir. Como el ascensor de mi edificio.",
                "Lo de Ronaldo Nazário como presidente, mejor no lo comentamos. Bueno, sí: no vino casi nunca."]),
            ("Nieto", "npc_boy", "libre", ["Mi abuelo tiene una bufanda de cada temporada. Las de Segunda las guarda en otro cajón."]),
        ],
    },
    "valladolid/sala_calle_66_14": {
        "tipo": "portal", "nombre": "Portal de la calle Santiago",
        "gente": [("Portera", "npc_old_woman", "libre", [
            "La calle Santiago es la de las tiendas. En Navidad hay un belén enorme y una cola aún más grande.",
            "En este portal hay calefacción central. Por eso se juntan aquí los vecinos a hablar en enero."])],
    },
}

# Salas de dentro de los monumentos (21 de octubre).
SALAS['valladolid/sala_calle_59_16'].setdefault("dentro", {}).update({'valladolid/sala_calle_59_16_torre': {'tipo': 'torre', 'nombre': 'Torre de la Catedral', 'gente': [('Campanero', 'npc_man', 'libre', ['La catedral la trazó Juan de Herrera, el del Escorial, y se quedó a medias: lleva sin terminar desde el siglo XVI.', 'La torre antigua se derrumbó en 1841. Ésta se levantó después; desde arriba se ve toda Valladolid y el Pisuerga.'])], 'carteles': [('pared', ['Campanas grandes y pequeñas colgadas de vigas de madera. Una tiene una grieta y un cartel: «No tocar, que ya no suena».'])]}})
