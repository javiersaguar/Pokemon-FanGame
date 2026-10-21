# Interiores de la Ruta 22 (Burgos y Atapuerca). Propuesta provisional.
SALAS = {
    "ruta_22/casa_1": {
        "tipo": "casa", "nombre": "Casa de la familia burgalesa",
        "gente": [
            ("Abuela burgalesa", "npc_old_woman", "regalo:cocina", [
                "En Burgos hace frío nueve meses y fresco los otros tres. Toma, que el que viene de fuera siempre llega helado.",
                "Morcilla de Burgos con arroz, queso fresco y lechazo. Aquí se come para aguantar el invierno."]),
            ("Nieto", "npc_boy", "tele", ["Mi abuela tiene la calefacción puesta en julio. Yo me quito el jersey dentro de casa."]),
        ],
    },
    "ruta_22/casa_2": {
        "tipo": "casa", "nombre": "Casa del peregrino del Camino Francés",
        "gente": [
            ("Hospitalera", "npc_woman", "dependiente", [
                "Llevo un albergue de peregrinos. Por aquí pasa el Camino Francés hacia Santiago. Cada noche duermen gentes de veinte países.",
                "Se sella la credencial, se cena en común y a las diez se apaga la luz. El que ronca, duerme en la cocina."]),
            ("Peregrino coreano", "turista", "cliente", ["I walk from Saint-Jean. Llevo doscientos kilómetros. Burgos tiene la catedral más bonita que he visto."]),
        ],
    },
    "ruta_22/sala_calle_16_15": {
        "tipo": "museo", "nombre": "Centro de visitantes de Atapuerca",
        "gente": [
            ("Arqueólogo", "arqueologo", "libre", [
                "En la Sima de los Huesos hay restos de hace cuatrocientos mil años. En la Gran Dolina, de hace casi un millón: los europeos más antiguos.",
                "Excavamos con brochas y paciencia. Cada verano encontramos algo. Un diente puede cambiar la historia."]),
            ("Escolar", "npc_boy", "libre", ["He visto un cráneo de verdad. Bueno, una réplica. El de verdad se llama Miguelón y está en un museo."]),
        ],
        "carteles": [("vitrina", ["Réplica del cráneo 5 de la Sima de los Huesos, «Miguelón». Unos cuatrocientos treinta mil años. Sin caries."])],
    },
    "ruta_22/sala_calle_8_26": {
        "tipo": "catedral", "nombre": "Catedral de Santa María de Burgos",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "Gótica desde 1221, con las agujas que se ven desde toda la llanura. Aquí está enterrado el Cid con doña Jimena.",
                "Arriba hay un muñeco, el Papamoscas, que abre la boca cada vez que da la hora. Los niños vienen a verlo bostezar."]),
            ("Turista", "turista_f", "publico", ["He esperado media hora para ver al Papamoscas abrir la boca. Ha merecido la pena. Un poco."]),
        ],
        "dentro": {
            "ruta_22/sala_calle_8_26_cimborrio": {
                "tipo": "iglesia", "nombre": "Crucero y cimborrio de la catedral",
                "gente": [("Guía", "npc_lass", "libre", [
                    "El cimborrio es una estrella de piedra calada sobre el crucero. Mirando hacia arriba, la luz parece encaje.",
                    "Debajo, una losa: la tumba del Cid Campeador y de doña Jimena. Llegaron aquí en 1921, después de mucho viaje."])],
                "carteles": [("pared", ["Tumba del Cid y doña Jimena. «Quien a buen señor sirve, buen galardón espera»."])],
            },
        },
    },
}

# Salas de dentro de los monumentos (21 de octubre).
SALAS['ruta_22/sala_calle_16_15'].setdefault("dentro", {}).update({'ruta_22/sala_calle_16_15_sima': {'tipo': 'cueva', 'nombre': 'Réplica de la Sima de los Huesos', 'gente': [('Paleontóloga', 'arqueologo', 'libre', ['En la Sima de los Huesos han salido restos de una treintena de personas de hace unos 430.000 años. Es el mayor hallazgo de su época en el mundo.', 'Se baja por una grieta estrecha, se excava tumbado y se sale con los huesos en cajitas. Esto es la réplica; la de verdad no la verías ni con linterna.'])], 'carteles': [('pared', ['Un fondo de cueva iluminado con huesos de mentira en el suelo y cuadrículas de cuerda. Una etiqueta: «Réplica: no recoger».'])]}})
