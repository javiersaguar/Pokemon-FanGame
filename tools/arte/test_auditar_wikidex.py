import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import auditar_wikidex as audit

class CatalogAuditTest(unittest.TestCase):
    def test_rowspan_y_notas_no_crean_identificadores_vacios(self):
        parser = audit.Tables()
        parser.feed('<table><tr><td>622</td><td rowspan="2">Nombre<sup>1</sup><br>English</td><td>A</td></tr><tr><td>623</td><td>B</td></tr></table>')
        self.assertEqual(parser.tables[0], [["622", "Nombre|English", "A"], ["623", "Nombre|English", "B"]])

    def test_referencia_conserva_variantes_y_no_duplica_movimientos_z(self):
        snapshot = json.loads((audit.OUT / "wikidex_referencia.json").read_text())
        for kind in audit.SOURCES:
            ids = [row["id"] for row in snapshot[kind]]
            self.assertEqual(len(ids), len(set(ids)))
        z = next(row for row in snapshot["moves"] if row["id"] == "breakneckblitz")
        self.assertEqual(z["indices"], [622, 623])
        self.assertTrue(set(audit.VARIANTS.values()) <= {row["id"] for row in snapshot["abilities"]})
        self.assertTrue(next(row for row in snapshot["abilities"] if row["id"] == "cacophony")["unused"])

    def test_compara_por_id_aunque_los_numeros_locales_estan_repetidos(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            out = root / "report"
            out.mkdir()
            (root / "data/generated").mkdir(parents=True)
            reference = {"checked_on": "2026-10-12", "sources": audit.SOURCES,
                         "moves": [{"id": "pound", "name_es": "Destructor", "name_en": "Pound", "indices": [1]}],
                         "abilities": [{"id": "beadsofruin", "index": 287, "name_es": "Abalorio Debacle"},
                                       {"id": "tabletsofruin", "index": 286, "name_es": "Tablilla Debacle"},
                                       {"id": "auraguard", "index": 319, "name_es": "Aura Protectora"}]}
            (out / "wikidex_referencia.json").write_text(json.dumps(reference))
            (root / "data/generated/moves.json").write_text(json.dumps({"pound": {"num": 1, "name": "Destructor", "name_en": "Pound"}}))
            abilities = {ident: {"num": 284, "name": name, "name_en": name} for ident, name in [("beadsofruin", "Abalorio Debacle"), ("tabletsofruin", "Tablilla Debacle")]}
            (root / "data/generated/abilities.json").write_text(json.dumps(abilities))
            (root / "data/battle_motion_moves.json").write_text('{"pound": {}}')
            with patch.object(audit, "ROOT", root), patch.object(audit, "OUT", out):
                result = audit.report()
                before = (out / "wikidex_estado.json").read_bytes()
                audit.report()
                self.assertEqual(before, (out / "wikidex_estado.json").read_bytes())
            self.assertEqual([row["id"] for row in result["abilities"]["missing"]], ["auraguard"])
            self.assertEqual(len(result["abilities"]["index_differences"]), 2)
            self.assertEqual(result["moves"]["missing"], [])

if __name__ == "__main__":
    unittest.main()
