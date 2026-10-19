# Interiores de Rocafonda (Mataró). Las ruinas tienen interior propio en pintar_salas_hitos.gd. Propuesta provisional.
SALAS = {
    "rocafonda/sala_calle_20_18": {
        "tipo": "casa", "nombre": "Casa de los vecinos del 304",
        "gente": [
            ("Vecina", "npc_woman", "cocina", [
                "Rocafonda es un barrio de gente trabajadora, de aquí y de fuera. En la misma escalera se habla catalán, árabe y castellano.",
                "Cuando el chaval marcó en la Eurocopa, salimos todos al balcón. Hasta el vecino que no habla con nadie."]),
            ("Hijo", "npc_boy", "tele", ["Hago el 304 con los dedos cada vez que marco en el patio. Mi profesor dice que es el código postal, no un baile."]),
        ],
    },
    "rocafonda/sala_calle_25_17": {
        "tipo": "casa", "nombre": "Casa del entrenador del campo del barrio",
        "gente": [
            ("Entrenador de base", "npc_man", "libre", [
                "Entreno a los niños del barrio en el campo de tierra. Ahora todos quieren regatear como Lamine. Yo les pido que primero sepan pasar.",
                "De cada cien niños que juegan aquí, uno llega al fútbol de verdad. Los otros noventa y nueve, a la amistad. También vale."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido llega del campo con las botas llenas de tierra. Las deja en la puerta como un trofeo."]),
        ],
    },
    "rocafonda/sala_calle_32_10": {
        "tipo": "palacio", "nombre": "Mansión de Rocafonda",
        "gente": [
            ("Mayordomo", "npc_man", "libre", [
                "El señor está fuera, entrenando. O en la puerta, combatiendo. No sabría decirle: aquí todo es muy rápido.",
                "La casa tiene piscina, gimnasio y una sala de trofeos. La sala de trofeos se queda pequeña cada año."]),
            ("Cocinera", "npc_old_woman", "cocina", ["Me han pedido que cocine como en casa de la abuela. Imposible: en casa de la abuela cocina la abuela."]),
        ],
        "carteles": [("vitrina", ["Vitrina de trofeos: medallas, balones firmados y una camiseta con el 19. Al fondo, sitio vacío para lo que venga."])],
    },
}
