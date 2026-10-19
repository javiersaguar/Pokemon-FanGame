# Interiores de Bilbao (el Guggenheim tiene interior propio en pintar_salas_hitos.gd). Propuesta provisional.
SALAS = {
    "bilbao/sala_calle_29_25": {
        "tipo": "oficina", "nombre": "Oficinas de la Torre Iberdrola",
        "gente": [
            ("Ingeniera eléctrica", "influencerlinkedin_f", "mesa", [
                "Ciento sesenta y cinco metros, cuarenta y una plantas. Desde aquí arriba la ría parece un hilo y San Mamés, una tarta.",
                "Vigilamos la red eléctrica de medio país. Cuando hay un apagón, aquí no se toma café."]),
            ("Guardia de seguridad", "npc_man", "libre", ["Tarjeta de visitante, por favor. Sin tarjeta no se sube ni al primer piso."]),
        ],
    },
    "bilbao/sala_calle_34_42": {
        "tipo": "taberna", "nombre": "Taberna de pintxos de las Siete Calles",
        "gente": [
            ("Tabernera", "camarero", "dependiente", [
                "Gilda, tortilla, bacalao al pil pil y una de rabas. Coges el pintxo de la barra y al final cuentas los palillos.",
                "El txikito es un vino pequeño. Se toma uno en cada bar. Por eso la cuadrilla tarda tres horas en recorrer una calle."]),
            ("Cuadrilla", "tertuliano", "cliente", ["Somos una cuadrilla de once. Pagamos a bote: todos ponemos lo mismo y el que bebe más, calla."]),
        ],
        "carteles": [("pared", ["«La gilda: guindilla, anchoa y aceituna. Verde, salada y un poco picante. Como Rita Hayworth.»"])],
    },
    "bilbao/sala_calle_35_7": {
        "tipo": "casa", "nombre": "Casa del remero de la trainera",
        "gente": [
            ("Remero", "piraguista", "libre", [
                "Entrenamos en la ría al amanecer. En verano remamos las regatas de traineras del Cantábrico. La Bandera de La Concha es lo más grande.",
                "Una trainera tiene trece remeros y un patrón que grita. Yo, de momento, remo y escucho."]),
            ("Madre", "npc_woman", "cocina", ["Mi hijo come por tres. Bueno, por trece: rema por la tripulación entera."]),
        ],
    },
    "bilbao/sala_calle_38_26": {
        "tipo": "piso", "nombre": "Piso de la familia de Abando",
        "gente": [
            ("Abuelo", "npc_old_man", "tele", [
                "He visto a Bilbao cambiar de ciudad gris de altos hornos a ciudad de museos. Los altos hornos daban trabajo; el museo, fotos.",
                "Bilbao es el centro del mundo. Lo sabe todo el mundo, menos el mundo."]),
            ("Nieta", "npc_lass", "libre", ["Mi aitite dice que nació en Bilbao porque quiso. Cualquier bilbaíno te lo dirá."]),
        ],
    },
    "bilbao/sala_calle_44_41": {
        "tipo": "catedral", "nombre": "Catedral de Santiago",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "La catedral de Santiago es gótica y está en el Casco Viejo. Por aquí pasaban los peregrinos del Camino del Norte.",
                "El claustro es pequeño y silencioso. Es el único sitio de las Siete Calles donde no se oye un txikito."]),
            ("Peregrina", "montanera", "publico", ["Hago el Camino del Norte. Desde Irún hasta aquí he subido más cuestas que en toda mi vida."]),
        ],
    },
    "bilbao/sala_calle_46_14": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Bilbao",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "Aquí se entrena para el deporte rural: levantar piedras, cortar troncos y tirar de la soga. Tenemos troncos de verdad.",
                "Cuando llueve, el gimnasio se llena. En Bilbao llueve. Llueve mucho."]),
            ("Harrijasotzaile", "crossfitero_f", "libre", ["Levanto una piedra de cien kilos. Mi aitite levantaba ciento cincuenta. Dice."]),
        ],
    },
    "bilbao/sala_calle_50_14": {
        "tipo": "portal", "nombre": "Portal de la Gran Vía de Bilbao",
        "gente": [("Portera", "npc_old_woman", "libre", [
            "La Gran Vía de Bilbao es la calle de los bancos y de las tiendas. Aquí se pasea con paraguas aunque no llueva.",
            "En este portal vive un concejal, un tenor y una señora que ha visto ganar ocho Copas al Athletic. La señora manda."])],
    },
    "bilbao/sala_calle_53_27": {
        "tipo": "teatro", "nombre": "Teatro Arriaga",
        "gente": [
            ("Soprano", "npc_lass", "artista", [
                "El Arriaga lleva el nombre de Juan Crisóstomo Arriaga, el Mozart español. Murió con diecinueve años y ya había compuesto una sinfonía.",
                "Esta noche cantamos ópera. En el entreacto, pintxos en el foyer. Aquí hasta la ópera tiene pintxos."]),
            ("Espectador", "tertuliano", "publico", ["He visto la misma ópera seis veces. Me sigo emocionando en el mismo sitio y me sigo durmiendo en el mismo sitio."]),
        ],
        "carteles": [("pared", ["Teatro Arriaga (1890). Lo inundó la riada de 1983 hasta el patio de butacas. Se secó y siguió la función."])],
    },
    "bilbao/sala_calle_57_18": {
        "tipo": "casa", "nombre": "Casa del aficionado del Athletic",
        "gente": [
            ("Aficionado zurigorri", "npc_man", "tele", [
                "El Athletic solo juega con jugadores de aquí. Bueno, de aquí, de Navarra, de Iparralde y de cualquiera con una abuela de aquí.",
                "En 2024 ganamos la Copa y sacamos la gabarra por la ría. Medio millón de personas en las orillas. Lloré como un niño."]),
            ("Hijo", "npc_boy", "libre", ["En casa hay una foto de la gabarra en cada habitación. Hasta en el baño."]),
        ],
        "carteles": [("pared", ["Foto enmarcada de la gabarra navegando por la ría con la Copa. Firmada por nadie, pero sagrada."])],
    },
    "bilbao/sala_calle_57_41": {
        "tipo": "mercado", "nombre": "Mercado de la Ribera",
        "gente": [
            ("Pescatera", "npc_woman", "dependiente", [
                "Es uno de los mercados cubiertos más grandes de Europa, a la orilla de la ría. Abajo pescado; arriba, carne y verdura; y en la planta baja, pintxos.",
                "Bacalao para el pil pil. El pil pil se hace moviendo la cazuela hasta que la gelatina del bacalao liga el aceite. Mucho brazo."]),
            ("Cocinero de sociedad", "npc_old_man", "cliente", ["Vengo a por chipirones para la sociedad gastronómica. Allí cocinamos los hombres. Las mujeres, a veces, nos dejan."]),
        ],
    },
    "bilbao/sala_calle_61_49": {
        "tipo": "casa", "nombre": "Sociedad gastronómica de las Siete Calles",
        "gente": [
            ("Socio cocinero", "npc_old_man", "cocina", [
                "En la sociedad cada uno cocina, come y apunta en un cuaderno lo que ha gastado. Se paga por honor. Nadie hace trampas. Casi nadie.",
                "Hoy hago merluza en salsa verde. Mañana, alubias de Gernika. Pasado, la revancha del mus."]),
            ("Socio de mus", "tertuliano", "mesa", ["¡Órdago a la grande! Y si no lo quieres, paga la ronda."]),
        ],
    },
    "bilbao/sala_calle_64_48": {
        "tipo": "casa", "nombre": "Casa de la etxekoandre",
        "gente": [
            ("Etxekoandre", "npc_old_woman", "cocina", [
                "Etxekoandre es la señora de la casa. En esta casa mando yo, y la casa está muy bien mandada.",
                "Pastel vasco, goxua y canutillos. Si vienes a casa, no te vas sin merendar. Es norma."]),
            ("Nieto", "npc_boy", "tele", ["Mi amama me da merienda dos veces: una al llegar y otra antes de irme. Por si acaso."]),
        ],
    },
    "bilbao/sala_calle_65_23": {
        "tipo": "casa", "nombre": "Casa del trabajador del puerto de Santurtzi",
        "gente": [
            ("Estibador", "marinero", "libre", [
                "El puerto de Bilbao se fue a Santurtzi, junto al mar. Allí las sardinas se asan en la calle y se venden con la canción.",
                "«Desde Santurce a Bilbao vengo por toda la orilla». Lo cantamos tanto que las sardinas ya se lo saben."]),
            ("Mujer", "npc_woman", "tele", ["Mi marido trabaja con contenedores de medio mundo. En casa, ni una caja en su sitio."]),
        ],
    },
    "bilbao/sala_calle_69_48": {
        "tipo": "casa", "nombre": "Caserío del baserritarra del monte Artxanda",
        "gente": [
            ("Baserritarra", "pastor", "libre", [
                "En el caserío tenemos vacas, huerta y una txapela para cada ocasión. La de los domingos es la más grande.",
                "Bajo a Bilbao en el funicular de Artxanda a vender queso. Subo más ligero y con el monedero más pesado."]),
            ("Amona", "npc_old_woman", "cocina", ["La cuajada se hace con leche de oveja y una piedra caliente. Así sabe a humo y a monte."]),
        ],
    },
}
