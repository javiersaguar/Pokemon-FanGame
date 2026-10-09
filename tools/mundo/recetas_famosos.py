#!/usr/bin/env python3
"""Recetas de los personajes de Pokémon Spain (docs/mundo/personajes.md) para
assets/sprites/trainers/build_trainers.gd.

Cada personaje se describe con piezas del pack 11 (piel, peinado, arriba, abajo,
accesorio); este script busca el archivo real de cada pieza en las vistas de
combate (frente) y de mapa (andar) — los nombres del pack no son regulares — y
añade o actualiza su entrada en assets/sprites/trainers/recetas.json. No dibuja
nada: build_trainers.gd superpone las capas tal cual.

Uso: python3 tools/mundo/recetas_famosos.py [--recursos=<ruta del pack>]
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RECIPES = os.path.join(ROOT, "assets", "sprites", "trainers", "recetas.json")
PACK = "11_character_customization_gen4/pokemon png/"
DEFAULT_RES = "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"

# Tipos de prenda: nombres que puede tener en las carpetas del pack (se prueba en orden).
TOPS = {
    "americana": ["classy top"], "traje": ["formal top", "formal"], "camisa": ["collared shirt", "collard shirt"],
    "camiseta": ["t-shirt"], "rayas": ["shirt combo"], "sudadera": ["hoodie"], "tirantes": ["tank top"],
    "gabardina": ["trench coat", "trenchcoat"], "cuello_alto": ["turtleneck"], "chaleco": ["vest"], "pico": ["v-neck", "v neck"],
    "chaqueta": ["open jacket", "open"], "bufanda": ["scarf top", "scarf shirt"], "mono": ["jumpsuit top", "jumpsuit"],
    "mono_alt": ["jumpsuit alt top", "jumpsuit alt", "alt jumpsuit"], "playa": ["beach top"], "rey": ["lord suit top", "lords shirt", "lord shirt"],
    "uniforme": ["school uniform", "school uniform top"],
}
BOTTOMS = {
    "vaqueros": ["jeans"], "vestir": ["formal pants", "formal bottoms", "classy pants", "classy bottom"],
    "elegante": ["classy pants", "classy bottom", "evening bottom", "formal pants", "formal bottoms"],
    "corto": ["shorts", "short"], "playa": ["beach bottom", "beach  bottoms", "beach bottoms"], "pirata": ["capri", "capris"],
    "botas": ["pants and boots"], "falda_tubo": ["pencil skirt", "skirt pencil"], "falda_larga": ["long skirt"],
    "falda_lazo": ["ribbon skirt", "skirt ribbon"], "mono": ["jumpsuit pants"], "rey": ["lord suit pants", "lords pants"],
    "noche": ["evening bottom", "classy bottom", "pencil skirt"],
}
COLOR_ALIASES = {"blond": ["blond", "blonde"], "blonde": ["blonde", "blond"], "purple": ["purple", "violet"],
                 "violet": ["violet", "purple"], "brown": ["brown", "brownish"], "white": ["white"]}

# Personajes: sexo (m/f), piel (pale, light, medium, dark), pelo (estilo 1-4 y color; None = calvo),
# arriba, abajo y accesorio (opcional). "idea": cómo es y por qué.
SPECS = {
    # Líderes de gimnasio (decisión de Javier: quiénes; el aspecto es propuesta).
    "ayuso": ("f", "light", (2, "brown"), ("traje", "red"), ("falda_tubo", "black"), None,
              "Isabel Díaz Ayuso, líder 1 (Madrid): melena castaña, americana roja y falda negra."),
    "laporta": ("m", "light", (2, "white"), ("americana", "navy"), ("vestir", "black"), None,
                "Joan Laporta, líder 2 (Barcelona): pelo canoso y traje azul marino."),
    "labrador": ("m", "medium", (4, "black"), ("tirantes", "black"), ("playa", "blue"), None,
                 "Labrador, líder 3 (Valencia): cachas de Gandía Shore, camiseta de tirantes y bañador."),
    "joaquin": ("m", "medium", (3, "brown"), ("camiseta", "green"), ("vaqueros", "light blue"), None,
                "Joaquín, líder 4 (Sevilla): pelo ondulado y camiseta verde del Betis."),
    "quevedo": ("m", "light", (1, "black"), ("sudadera", "black"), ("vaqueros", "black"), ("glasses", "blue"),
                "Quevedo, líder 5 (Las Palmas): sudadera negra y gafas."),
    "aupa_athletic": ("f", "light", (4, "brown"), ("rayas", "red"), ("vaqueros", "navy"), ("beret", None),
                      "La chica del Aupa Athletic, líder 6 (Bilbao): coleta, camiseta rojiblanca y txapela."),
    "latasa": ("m", "light", (4, "brown"), ("sudadera", "purple"), ("corto", "white"), None,
               "Juanmi Latasa, líder 7 (Valladolid): morado del Pucela."),
    "banderas": ("m", "medium", (3, "black"), ("gabardina", "black"), ("vestir", "black"), ("fedora", None),
                 "Antonio Banderas, líder 8 (Málaga): El Zorro, gabardina negra y sombrero."),
    # Alto Mando y Líder Supremo.
    "iniesta": ("m", "pale", None, ("camiseta", "white"), ("corto", "white"), None,
                "Andrés Iniesta, Alto Mando: calvo, de blanco."),
    "nadal": ("m", "medium", (3, "brown"), ("tirantes", "green"), ("corto", "white"), ("headband", None),
              "Rafa Nadal, Alto Mando: melena, cinta y camiseta de tirantes."),
    "gasol": ("m", "light", (4, "brown"), ("camiseta", "red"), ("corto", "red"), None,
              "Pau Gasol, Alto Mando: la camiseta roja de la selección."),
    "alonso": ("m", "light", (4, "brown"), ("mono", "green"), ("mono", "green"), None,
               "Fernando Alonso, Alto Mando: mono verde de piloto."),
    "pedro_sanchez": ("m", "light", (2, "brown"), ("americana", "navy"), ("vestir", "navy"), None,
                      "Pedro Sánchez, Líder Supremo y jefe del Clan PSOE: traje azul marino."),
    # Clan PSOE.
    "abalos": ("m", "light", (2, "white"), ("americana", "grey"), ("vestir", "grey"), None,
               "Ábalos, del dúo del Clan PSOE: pelo gris y americana gris."),
    "koldo": ("m", "light", (4, "black"), ("chaqueta", "blue"), ("vaqueros", "black"), None,
              "Koldo, del dúo del Clan PSOE: grande, pelo corto y cazadora."),
    "leire_diez": ("f", "light", (3, "blonde"), ("gabardina", "navy"), ("vaqueros", "navy"), ("glasses", "red"),
                   "Leire Díez, la fontanera: melena rubia, gabardina y gafas."),
    "recluta_clan": ("m", "light", (1, "black"), ("chaqueta", "red"), ("vaqueros", "black"), None,
                     "Recluta del Clan PSOE: chaqueta roja."),
    "recluta_clan_f": ("f", "light", (4, "black"), ("chaqueta", "red"), ("vaqueros", "black"), None,
                       "Recluta del Clan PSOE (chica): chaqueta roja."),
    # Famosos (decisión de Javier: quiénes; dónde y cómo, propuesta).
    "ibai": ("m", "light", (1, "brown"), ("sudadera", "black"), ("vaqueros", "black"), ("youngster cap", "blue"),
             "Ibai Llanos: sudadera negra y gorra."),
    "lamine": ("m", "dark", (1, "black"), ("rayas", "blue"), ("corto", "blue"), None,
               "Lamine Yamal: camiseta azulgrana."),
    "hustlehard304": ("m", "medium", None, ("camiseta", "black"), ("vaqueros", "black"), None,
                      "HustleHard304, padre de Lamine: camiseta negra."),
    "keyne": ("m", "dark", (1, "black"), ("rayas", "blue"), ("corto", "blue"), ("youngster cap", "blue"),
              "Keyne, hermano pequeño de Lamine: camiseta del Barça y gorra."),
    "rosalia": ("f", "light", (3, "black"), ("chaqueta", "red"), ("falda_lazo", "red"), None,
                "Rosalía: melena negra y chaqueta roja de motomami."),
    "enrique_iglesias": ("m", "light", (4, "brown"), ("camiseta", "white"), ("vaqueros", "navy"), ("youngster cap", "blue"),
                         "Enrique Iglesias: camiseta blanca y gorra."),
    "julio_iglesias": ("m", "medium", (2, "white"), ("traje", "beige"), ("elegante", "beige"), None,
                       "Julio Iglesias: bronceado, pelo blanco y traje claro."),
    "sergio_ramos": ("m", "medium", (3, "black"), ("camiseta", "white"), ("vaqueros", "black"), None,
                     "Sergio Ramos: pelo peinado atrás y camiseta blanca."),
    "guardiola": ("m", "light", None, ("cuello_alto", "black"), ("vestir", "grey"), None,
                  "Pep Guardiola: calvo y jersey de cuello alto."),
    "pique": ("m", "light", (2, "brown"), ("camisa", "light blue"), ("vaqueros", "navy"), None,
              "Gerard Piqué: camisa azul y vaqueros."),
    "aitana": ("f", "light", (2, "blonde"), ("tirantes", "pink"), ("falda_lazo", "pink"), None,
               "Aitana: melena rubia corta, de rosa."),
    "ester_exposito": ("f", "light", (3, "blonde"), ("americana", "black"), ("noche", "black"), None,
                       "Ester Expósito: melena rubia y vestido negro de estreno."),
    "elxokas": ("m", "light", (2, "brown"), ("camiseta", "black"), ("vaqueros", "grey"), None,
                "Elxokas: camiseta negra."),
    "folagor": ("m", "light", (1, "brown"), ("sudadera", "blue"), ("vaqueros", "navy"), None,
                "Folagor03: sudadera azul."),
    "sekiam": ("m", "light", (1, "black"), ("sudadera", "red"), ("vaqueros", "black"), None,
               "Sekiam: sudadera roja."),
    "pokealex": ("m", "light", (4, "brown"), ("camiseta", "black"), ("vaqueros", "navy"), None,
                 "PokeAlex: camiseta negra de torneo."),
    "amancio_ortega": ("m", "light", (2, "white"), ("cuello_alto", "black"), ("vestir", "grey"), None,
                       "Amancio Ortega: pelo blanco y jersey oscuro."),
    "abascal": ("m", "light", (4, "black"), ("camisa", "white"), ("botas", "beige"), None,
                "Santiago Abascal: camisa y botas de montar."),
    "topuria": ("m", "light", (4, "black"), ("tirantes", "black"), ("corto", "black"), None,
                "Ilia Topuria: camiseta de tirantes y pantalón corto de luchador."),
    "nico_williams": ("m", "dark", (1, "black"), ("rayas", "red"), ("corto", "black"), None,
                      "Nico Williams: camiseta rojiblanca."),
    "inaki_williams": ("m", "dark", (4, "black"), ("rayas", "red"), ("corto", "black"), None,
                       "Iñaki Williams: camiseta rojiblanca."),
    "pereira7": ("m", "light", (1, "brown"), ("sudadera", "green"), ("vaqueros", "navy"), None,
                 "Pereira7: sudadera verde."),
    "broncano": ("m", "light", (1, "brown"), ("camiseta", "black"), ("vaqueros", "navy"), None,
                 "David Broncano: despeinado y camiseta negra."),
    "oscar_puente": ("m", "light", (4, "white"), ("americana", "grey"), ("vestir", "grey"), None,
                     "Óscar Puente: pelo canoso y americana gris."),
    "mario_casas": ("m", "light", (3, "brown"), ("chaqueta", "blue"), ("vaqueros", "black"), None,
                    "Mario Casas: cazadora y vaqueros."),
    "pablo_iglesias": ("m", "light", (4, "black"), ("camisa", "white"), ("vaqueros", "navy"), None,
                       "Pablo Iglesias: coleta y camisa blanca."),
    "irene_montero": ("f", "light", (2, "brown"), ("americana", "grey"), ("vaqueros", "navy"), None,
                      "Irene Montero: melena castaña y americana."),
    "franco": ("m", "pale", (4, "white"), ("americana", "beige"), ("botas", "beige"), None,
               "Francisco Franco, fantasma: piel pálida, uniforme beige."),
    "almeida": ("m", "light", (2, "brown"), ("americana", "navy"), ("vestir", "black"), ("glasses", "blue"),
                "Almeida: traje y gafas."),
    "chicote": ("m", "light", (2, "white"), ("camisa", "white"), ("vestir", "black"), None,
                "Chicote: chaqueta de cocinero."),
    "pedroche": ("f", "light", (3, "brown"), ("traje", "red"), ("noche", "wine"), None,
                 "Cristina Pedroche: vestido de las Campanadas."),
    "rubiales": ("m", "light", (2, "brown"), ("americana", "black"), ("vestir", "black"), None,
                 "Luis Rubiales: traje de boda."),
    "jenni_hermoso": ("f", "medium", (4, "black"), ("camiseta", "red"), ("corto", "blue"), None,
                      "Jenni Hermoso: coleta y camiseta de la selección."),
    "jorge_javier": ("m", "light", (4, "white"), ("americana", "wine"), ("vestir", "black"), None,
                     "Jorge Javier Vázquez: pelo blanco y americana de color."),
    "coto_matamoros": ("m", "medium", (2, "white"), ("camisa", "white"), ("vestir", "beige"), None,
                       "Coto Matamoros: camisa blanca abierta."),
    "belen_esteban": ("f", "light", (3, "blonde"), ("chaqueta", "pink"), ("vaqueros", "light blue"), None,
                      "Belén Esteban: melena rubia y chaqueta rosa."),
    "melendi": ("m", "light", (1, "black"), ("sudadera", "black"), ("vaqueros", "navy"), ("youngster cap", "yellow"),
                "Melendi: gorra y sudadera."),
    "felipe_vi": ("m", "light", (2, "white"), ("rey", "red"), ("rey", None), ("crown", "gold"),
                  "El rey Felipe VI: traje de rey con capa y corona de oro."),
    "juan_carlos": ("m", "light", (2, "white"), ("rey", "purple"), ("rey", None), ("crown", "silver"),
                    "El rey emérito Juan Carlos I: traje de rey morado y corona de plata."),
    "sarah_santaolalla": ("f", "light", (2, "blonde"), ("americana", "black"), ("vaqueros", "black"), None,
                          "Sarah Santaolalla: melena rubia y americana negra."),
    "vito_quiles": ("m", "light", (2, "brown"), ("americana", "navy"), ("vaqueros", "navy"), None,
                    "Vito Quiles: americana y vaqueros, micrófono en mano."),
    "bertrand_ndongo": ("m", "dark", (4, "black"), ("americana", "black"), ("vestir", "black"), None,
                        "Bertrand Ndongo: traje oscuro."),
    "vegeta": ("m", "light", (1, "black"), ("sudadera", "purple"), ("vaqueros", "black"), None,
               "Vegeta777: pelo de punta y sudadera morada."),
    "willyrex": ("m", "light", (2, "brown"), ("sudadera", "blue"), ("vaqueros", "navy"), None,
                 "Willyrex: sudadera azul."),
    "ferran_torres": ("m", "light", (2, "black"), ("rayas", "blue"), ("corto", "blue"), None,
                      "Ferran Torres: camiseta azulgrana."),
    "juan_roig": ("m", "light", (2, "white"), ("camisa", "white"), ("vestir", "grey"), None,
                  "Juan Roig: camisa blanca y chaleco de Mercadona."),
    # Clases de entrenador de las rutas (docs/mundo/rutas.md).
    "piraguista": ("m", "medium", (4, "brown"), ("tirantes", "red"), ("corto", "blue"), ("headband", None),
                   "Piragüista de las Hoces del Duratón: camiseta roja de tirantes, pantalón corto y cinta."),
    "ornitologa": ("f", "light", (2, "brown"), ("chaleco", "brown"), ("botas", "beige"), ("sun hat", None),
                   "Ornitóloga que cuenta buitres: chaleco marrón de campo, pantalón con botas y sombrero de sol."),
}


def norm(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower()).strip()


class Pack:
    def __init__(self, base: str):
        self.base = base
        self.files = {}
        for root_name in ("trainer front male", "trainer front female", "overworld walk", "overworld run"):
            root = os.path.join(base, root_name)
            found = []
            for d, _, names in os.walk(root):
                for n in names:
                    if n.lower().endswith(".png"):
                        found.append(os.path.relpath(os.path.join(d, n), base))
            self.files[root_name] = found

    def find(self, root: str, folder_words: list, file_words: list, sex: str = "") -> str:
        """Archivo de `root` cuya carpeta contiene alguna de `folder_words` y cuyo nombre tiene todas
        las `file_words` (normalizado). Prefiere las carpetas del sexo (m/f) cuando las hay."""
        best = None
        for path in self.files[root]:
            parts = norm(path).split("/")
            folder = " / ".join(parts[1:-1])
            name = parts[-1][:-4]
            if not any(w in folder or w in name for w in folder_words):
                continue
            if not all(re.search(r"(^|[\s/])" + re.escape(w) + r"($|\s)", name) for w in file_words if w):
                continue
            score = len(path)
            tail = folder.split(" / ")[-1] if folder else ""
            if sex and (tail.endswith(" " + sex) or name.endswith(" " + sex) or (" %s " % sex) in name):
                score -= 1000
            if sex and ((sex == "m" and (tail.endswith(" f") or " f " in name)) or (sex == "f" and (tail.endswith(" m") or " m " in name))):
                score += 1000
            if best is None or score < best[0]:
                best = (score, path)
        return best[1] if best else ""


def colors(color):
    if color is None:
        return [""]
    return COLOR_ALIASES.get(color, [color])


def layers(pack: Pack, view: str, spec: tuple) -> list:
    sex, skin, hair, top, bottom, hat, _ = spec
    if view == "frente":
        root = "trainer front male" if sex == "m" else "trainer front female"
    else:
        root = "overworld walk"
    out = []

    def need(path: str, what: str) -> None:
        if not path:
            raise SystemExit("Falta la pieza %s (%s) para %s" % (what, view, spec[-1]))
        out.append(path.replace(os.sep, "/").split("/", 0)[0])

    # Base de piel.
    need(pack.find(root, ["base"], [skin] + ([sex] if view != "frente" else []), sex), "piel")
    # Abajo y arriba (el orden de las capas del pack: base, abajo, arriba, pelo, accesorio).
    for kind, table, value in (("abajo", BOTTOMS, bottom), ("arriba", TOPS, top)):
        name, color = value
        found = ""
        for alias in table[name]:
            for c in colors(color):
                found = pack.find(root, [alias], [c], sex)
                if found:
                    break
            if found:
                break
        if not found:
            # Ese color no existe en esta vista: el primero que haya de la misma prenda.
            for alias in table[name]:
                found = pack.find(root, [alias], [], sex)
                if found:
                    print("  aviso: %s (%s) sin %s %s; uso %s" % (spec[-1].split(":")[0], view, name, color, found))
                    break
        need(found, "%s %s %s" % (kind, name, color))
    if hair is not None:
        style, color = hair
        word = ("hair %d" % style) if view == "frente" else (("boy %d" if sex == "m" else "girl %d") % style)
        found = ""
        for c in colors(color):
            found = pack.find(root, [word], [c])
            if found:
                break
        need(found, "pelo %s" % (hair,))
    if hat is not None:
        name, color = hat
        aliases = {"youngster cap": ["youngster"], "glasses": ["glasses"], "crown": ["crown"],
                   "beret": ["beret", "beanie"]}.get(name, [name])
        found = ""
        for alias in aliases:
            for c in colors(color):
                found = pack.find(root, ["hats"], [c] if c else [], "") if False else _hat(pack, root, alias, c)
                if found:
                    break
            if found:
                break
        need(found, "accesorio %s" % (hat,))
    return out


def _hat(pack: Pack, root: str, alias: str, color: str) -> str:
    for path in pack.files[root]:
        n = norm(path)
        if "/hats/" not in n:
            continue
        name = n.split("/")[-1][:-4]
        folder = n.split("/")[-2]
        if alias in name or alias in folder or (alias == "miner" and "mining" in name):
            if not color or color in name:
                return path
    return ""


def main() -> None:
    res = DEFAULT_RES
    for a in sys.argv[1:]:
        if a.startswith("--recursos="):
            res = a.split("=", 1)[1]
    pack = Pack(os.path.join(res, PACK))
    with open(RECIPES, encoding="utf-8") as f:
        recipes = json.load(f)
    for pid, spec in SPECS.items():
        entry = {"idea": spec[-1]}
        for view in ("frente", "mapa"):
            entry[view] = layers(pack, view, spec)
        recipes[pid] = entry
    with open(RECIPES, "w", encoding="utf-8") as f:
        f.write(json.dumps(recipes, ensure_ascii=False, indent="\t") + "\n")
    print("%d recetas de personajes en %s" % (len(SPECS), os.path.relpath(RECIPES, ROOT)))


if __name__ == "__main__":
    main()
