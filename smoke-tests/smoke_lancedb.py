# smoke_lancedb.py — Vault 1 smoke test for LanceDB, run with the project venv:
#     C:\Dev\smoke-lab\.venv\Scripts\python.exe smoke_lancedb.py
# Three tiny vectors; the search must rank the one nearest the query first.
# Expect: near_sine ~0.0008, then sine_440 ~0.0128, then LANCEDB_SMOKE_OK.
# The "WARN ... No existing dataset" line is information: the test creates its table.
import os, shutil, tempfile
import lancedb

db_dir = os.path.join(tempfile.gettempdir(), "lancedb_smoke")
shutil.rmtree(db_dir, ignore_errors=True)

db = lancedb.connect(db_dir)
data = [
    {"vector": [1.0, 0.0, 0.0], "id": "sine_440"},
    {"vector": [0.0, 1.0, 0.0], "id": "noise_white"},
    {"vector": [0.9, 0.1, 0.0], "id": "near_sine"},
]
tbl = db.create_table("smoke", data=data, mode="overwrite")

hits = tbl.search([0.92, 0.08, 0.0]).limit(2).to_list()
for h in hits:
    print(h["id"], round(h["_distance"], 4))
print("LANCEDB_SMOKE_OK")

shutil.rmtree(db_dir, ignore_errors=True)
