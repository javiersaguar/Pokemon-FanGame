# Interiores de la Ruta 3 (Puerto de Navacerrada y el Valle de Cuelgamuros). Propuesta provisional.
# La basílica de Cuelgamuros se trata con respeto y con datos: quién aparece ahí (si aparece alguien famoso) lo decide Javier.
SALAS = {
    "ruta_3/casa_1": {
        "tipo": "rural", "nombre": "Refugio del puerto de Navacerrada",
        "gente": [
            ("Montañera del refugio", "montanera", "regalo:libre", [
                "Este refugio lo abrieron montañeros madrileños hace un siglo, cuando se subía en tren y con botas de clavos.",
                "Toma, que en el puerto el tiempo cambia en diez minutos y la ambulancia tarda cuarenta."]),
            ("Esquiador", "esquiador", "libre", [
                "Medio puerto se ha quedado sin remontes. Ahora se esquía como en los años veinte: subiendo a pie y bajando de culo."]),
        ],
    },
    "ruta_3/casa_2": {
        "tipo": "casa", "nombre": "Casa del conductor de la quitanieves",
        "gente": [
            ("Conductor de la quitanieves", "npc_man", "tele", [
                "Cuando nieva salgo a las cuatro de la mañana. A las siete ya hay un todoterreno atravesado en la curva con chanclas.",
                "Las cadenas se ponen antes de que haga falta. Lo pone en todos los carteles; lo lee una persona de cada diez."]),
            ("Su mujer", "npc_woman", "cocina", ["Llevo veinte inviernos con la sopa al fuego esperando a que baje del puerto. Algún año baja para Reyes."]),
        ],
    },
    "ruta_3/sala_calle_6_66": {
        "tipo": "basilica", "nombre": "Basílica del Valle de Cuelgamuros",
        "gente": [
            ("Guía", "profesor", "libre", [
                "La basílica está excavada en la roca del monte. Se construyó entre 1940 y 1958, también con trabajo de presos políticos.",
                "Desde 2022 el lugar se llama otra vez Valle de Cuelgamuros. Los restos del dictador salieron en 2019; los de Primo de Rivera, en 2023."]),
            ("Forense", "arqueologo", "libre", [
                "En las criptas hay más de treinta mil personas de los dos bandos. A muchas las trajeron sin avisar a sus familias.",
                "Trabajamos caja por caja para identificarlas por su ADN. Cada nombre que sale es una familia que por fin puede enterrar a los suyos."]),
            ("Nieta", "npc_old_woman", "libre", [
                "Mi abuelo está ahí abajo, en algún sitio. Di mi ADN hace años. Cada vez que suena el teléfono, pienso que es para eso."]),
        ],
        "carteles": [("pared", ["Ley de Memoria Democrática (2022): el Valle de Cuelgamuros pasa a ser un lugar de memoria, sin exaltar a nadie."])],
    },
}
