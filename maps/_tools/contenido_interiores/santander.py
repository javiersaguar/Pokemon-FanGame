# Interiores de Santander. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "santander/sala_calle_21_5": {
        "tipo": "casa", "nombre": "Villa de veraneo del Sardinero",
        "gente": [
            ("Veraneante de Madrid", "padretarjeta", "tele", [
                "Mi familia veranea en el Sardinero desde que veraneaba el rey Alfonso XIII. El rey ya no viene; nosotros, sí.",
                "En agosto aquí hace veintidós grados. En Madrid, cuarenta. Es la mejor inversión de mi abuelo."]),
            ("Hija", "npc_lass", "libre", ["Me he bañado en la Segunda playa del Sardinero. El agua me ha cortado la respiración. Literal."]),
        ],
    },
    "santander/sala_calle_30_18": {
        "tipo": "mercado", "nombre": "Mercado de la Esperanza",
        "gente": [
            ("Pescadera", "npc_woman", "dependiente", [
                "Bocarte de Santoña, rape del Cantábrico y almejas de la bahía. Aquí el pescado llega antes que los turistas.",
                "El mercado es de hierro, del siglo XIX. Se salvó del incendio de 1941. Las merluzas, no tanto."]),
            ("Clienta", "npc_old_woman", "cliente", ["Quiero un rape para el guiso y que me lo limpie usted, que yo ya no veo la espina."]),
        ],
    },
    "santander/sala_calle_32_29": {
        "tipo": "teatro", "nombre": "Teatro de la Plaza Porticada",
        "gente": [
            ("Actor", "npc_man", "artista", [
                "En agosto se celebra el Festival Internacional de Santander. Antes, en la Plaza Porticada, al aire libre y con lluvia.",
                "Esta noche hacemos zarzuela. Los de la primera fila cantan más alto que nosotros."]),
            ("Espectadora", "npc_woman", "publico", ["Vengo todos los veranos. Me sé el repertorio. Ellos no tanto, a veces."]),
        ],
    },
    "santander/sala_calle_39_18": {
        "tipo": "portal", "nombre": "Portal de la calle Burgos",
        "gente": [("Portero", "npc_old_man", "libre", [
            "Cuando sopla el viento sur, Santander se vuelve loca. Los vecinos discuten, los perros ladran y yo cierro el portal.",
            "El incendio de 1941 empezó por un viento sur. Desde entonces, en este portal se mira el cielo con respeto."])],
    },
    "santander/sala_calle_41_29": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Santander",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "Aquí la gente entrena para remar en las traineras. La bahía es un gimnasio, pero aquí no llueve dentro.",
                "En verano vienen los veraneantes a mantener la línea del Sardinero. En septiembre, desaparecen."]),
            ("Socia", "nadador_f", "libre", ["Nado en la bahía todo el año. En febrero me sirvo del gimnasio para descongelarme."]),
        ],
    },
    "santander/sala_calle_45_6": {
        "tipo": "socorrismo", "nombre": "Caseta de socorrismo del Sardinero",
        "gente": [("Socorrista", "nadador", "libre", [
            "El Sardinero tiene corrientes cuando sube la marea. Los surfistas lo saben; los madrileños, no.",
            "Lo que más rescato son sombrillas que se lleva el nordeste. Vuelan mejor que un Pidgey."])],
    },
    "santander/sala_calle_4_18": {
        "tipo": "catedral", "nombre": "Catedral de Nuestra Señora de la Asunción",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "La catedral está encima de una iglesia más antigua, la del Cristo, del siglo XIII. Una iglesia dentro de otra, como una muñeca rusa.",
                "En la cripta se ven restos romanos a través de un cristal en el suelo. Hay que pisar con fe."]),
            ("Visitante", "npc_woman", "publico", ["El claustro gótico es lo único que sobrevivió del todo al incendio. Aquí se viene a respirar."]),
        ],
        "dentro": {
            "santander/sala_calle_4_18_cristo": {
                "tipo": "cripta", "nombre": "Iglesia del Cristo (cripta de la catedral)",
                "gente": [("Guía", "npc_lass", "libre", [
                    "Aquí abajo hay restos de unas termas romanas. Los santanderinos ya se bañaban hace dos mil años.",
                    "Las reliquias de los mártires Emeterio y Celedonio, los patronos, llegaron por mar en una barca de piedra. Eso dice la leyenda."])],
                "carteles": [("pared", ["Cristal del suelo: restos de la Portus Victoriae romana. No saltes encima."])],
            },
        },
    },
    "santander/sala_calle_4_29": {
        "tipo": "floristeria", "nombre": "Floristería de los Jardines de Pereda",
        "gente": [
            ("Florista", "npc_lass", "dependiente", [
                "Las hortensias cántabras son azules por la tierra ácida. Si las plantas en Madrid, salen rosas y tristes.",
                "Para la Virgen del Mar se hacen alfombras de flores. Aquí se nos va la primavera entera en eso."]),
            ("Cliente", "npc_man", "cliente", ["Quiero un ramo para disculparme. Grande. Muy grande."]),
        ],
    },
    "santander/sala_calle_53_11": {
        "tipo": "casino", "nombre": "Gran Casino del Sardinero",
        "gente": [
            ("Crupier", "npc_man", "dependiente", [
                "El casino es de 1916, modernista y con vistas al mar. Antes venía la aristocracia. Ahora, despedidas de soltero.",
                "Hagan juego, señores. Las Poké Balls no se aceptan como fichas."]),
            ("Jugadora", "npc_woman", "cliente", ["He apostado al rojo. Ha salido el negro. Siempre sale el negro."]),
        ],
        "carteles": [("pared", ["Gran Casino del Sardinero (1916). La banca siempre gana. La playa de enfrente, también."])],
    },
    "santander/sala_calle_58_29": {
        "tipo": "palacio", "nombre": "Palacio de la Magdalena",
        "gente": [
            ("Guía", "npc_lass", "libre", [
                "El palacio lo pagaron los santanderinos por suscripción popular para regalárselo a Alfonso XIII. Él veraneó aquí cada verano.",
                "Ahora acoge los cursos de verano de la Universidad Menéndez Pelayo. Antes reyes; ahora, profesores en chanclas."]),
            ("Profesor de cursos de verano", "tertuliano", "mesa", ["Doy un curso sobre la España contemporánea. Con estas vistas, la España contemporánea parece maravillosa."]),
        ],
        "carteles": [("pared", ["Salón de los Reyes. Vistas a la bahía, a la isla de Mouro y a las focas del mini zoo."])],
    },
    "santander/sala_calle_5_11": {
        "tipo": "casa", "nombre": "Casa del pejino de Puertochico",
        "gente": [
            ("Pejino", "npc_fisherman", "libre", [
                "Los pejinos somos los del barrio pescador. Los del centro dicen que olemos a pescado. Olemos a mar, que es distinto.",
                "Las rabas se fríen con harina, un poco de sal y aceite muy caliente. El limón, aparte."]),
            ("Mujer", "npc_woman", "cocina", ["Sorropotún: bonito, patata y pan. Un guiso de barco que se come en tierra."]),
        ],
    },
    "santander/sala_calle_9_28": {
        "tipo": "casa", "nombre": "Casa de la familia del Racing",
        "gente": [
            ("Aficionado racinguista", "npc_man", "tele", [
                "El Racing de Santander fue de los fundadores de la Liga en 1929. Ahora sufrimos en Segunda. Sufrir también es tradición.",
                "En El Sardinero cantamos con lluvia y con viento sur. Con viento sur, más."]),
            ("Hija", "npc_girl", "libre", ["Mi padre se puso a llorar cuando ascendimos. Y cuando bajamos. Llora mucho mi padre."]),
        ],
    },
}

# Salas de dentro de los monumentos (21 de octubre).
SALAS['santander/sala_calle_58_29'].setdefault("dentro", {}).update({'santander/sala_calle_58_29_salon': {'tipo': 'palacio', 'nombre': 'Salón de baile de la Magdalena', 'gente': [('Profesora de los cursos', 'profesor', 'libre', ['Santander regaló el palacio a Alfonso XIII en 1912 como residencia de verano. Lo pagó la ciudad con una suscripción popular.', 'Desde 1932 aquí se dan los cursos de verano de la Universidad Menéndez Pelayo. Los alumnos estudian con vistas al Sardinero.'])], 'carteles': [('pared', ['Un salón con parqué y ventanales al mar. Las sillas plegables de los cursos tapan la mitad del parqué.'])]}})
