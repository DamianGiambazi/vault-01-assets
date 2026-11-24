"""capstone_rag.py — Capstone step 2: audited evidence -> LanceDB retrieval -> Ollama grounded answer.

Run from C:\\Dev\\smoke-lab\\capstone with the smoke-lab venv:
    ..\\.venv\\Scripts\\python.exe capstone_rag.py

Inputs : corpus.parquet, question.parquet  (written by `duckdb -bail -f audit.sql` only if the audit passed)
Needs  : lancedb (+ its pyarrow) in the venv; the Ollama service running with CAPSTONE_MODEL pulled.
No new packages: Ollama is called over its local REST API with the standard library.

Deterministic checks wrap a stochastic engine:
  - schema   : the model's reply parses as {"answer": str, "source_id": str}
  - citation : source_id is one of the retrieved passages (and the grammar only allows those)
  - grounding: the passage the model cited really contains the canary fact
  - canary   : the answer states the fact (value AND unit), which the model cannot know from training
The model is unloaded by the request itself (keep_alive=0): code that loads a model owns its unload.
"""
import json, os, re, shutil, sys, tempfile, time, urllib.request

import pyarrow as pa
import pyarrow.parquet as pq
import lancedb

sys.stdout.reconfigure(errors="replace")   # never crash on a console that can't print a dash

# ---- frozen at rehearsal --------------------------------------------------------------------
MODEL  = os.environ.get("CAPSTONE_MODEL", "smollm2:360m-instruct-q8_0")   # D4, rehearsal 2026-10-15
OLLAMA = os.environ.get("CAPSTONE_OLLAMA", "http://127.0.0.1:11434")
# The fact only the evidence holds, as a pattern: digits or words, but the UNIT must be right.
CANARY = os.environ.get("CAPSTONE_CANARY", r"\b(fifteen|15)\s+years?\b")
K      = 3                                              # passages handed to the model
DIM    = 384
# ---------------------------------------------------------------------------------------------

def fixed(table: pa.Table) -> pa.Table:
    """Parquet stores DuckDB's FLOAT[384] as a variable list; LanceDB wants a fixed-size vector."""
    col = table.column("vector").combine_chunks()
    flat = col.flatten()
    vec = pa.FixedSizeListArray.from_arrays(flat, DIM)
    return table.set_column(table.schema.get_field_index("vector"), "vector", vec)

corpus = fixed(pq.read_table("corpus.parquet"))
question = fixed(pq.read_table("question.parquet"))
q_text = question.column("text")[0].as_py()
q_vec = question.column("vector")[0].as_py()

db_dir = os.path.join(tempfile.gettempdir(), "lancedb_capstone")
shutil.rmtree(db_dir, ignore_errors=True)
db = lancedb.connect(db_dir)
tbl = db.create_table("evidence", data=corpus, mode="overwrite")

t0 = time.perf_counter()
hits = tbl.search(q_vec).distance_type("cosine").limit(K).to_list()
t_ret = (time.perf_counter() - t0) * 1000

print(f"EVIDENCE   top {K} of {corpus.num_rows} chunks, cosine distance  ({t_ret:.0f} ms)")
for h in hits:
    print(f"  {h['_distance']:.4f}  {h['id']:<18} {h['text'][:58]!r}")
print(f"QUESTION   {q_text}")

ids = [h["id"] for h in hits]
context = "\n".join(f'<passage id="{h["id"]}">{h["text"]}</passage>' for h in hits)
prompt = f"""<role>Archivist</role>
<context>
{context}
</context>
<task>Answer the question using only the passages above.</task>
<constraints>
- Use only the passages. Do not use outside knowledge.
- source_id must be the id of the passage that contains the answer.
- If the passages do not contain the answer, answer exactly: NOT IN EVIDENCE
</constraints>
<question>{q_text}</question>"""

schema = {
    "type": "object",
    "properties": {"answer": {"type": "string"}, "source_id": {"type": "string", "enum": ids}},
    "required": ["answer", "source_id"],
}
req = {
    "model": MODEL, "prompt": prompt, "format": schema, "stream": False, "keep_alive": 0,
    "options": {"temperature": 0, "seed": 42, "num_ctx": 2048, "num_predict": 96},
}
t0 = time.perf_counter()
with urllib.request.urlopen(urllib.request.Request(
        f"{OLLAMA}/api/generate", data=json.dumps(req).encode(),
        headers={"Content-Type": "application/json"}), timeout=600) as r:
    resp = json.load(r)
t_gen = time.perf_counter() - t0
print(f"MODEL      {MODEL}  temperature 0, seed 42, keep_alive 0  ({t_gen:.1f} s)")
ns = lambda k: resp.get(k, 0) / 1e9                       # Ollama reports nanoseconds
print(f"TIMING     load {ns('load_duration'):.1f} s | prompt {resp.get('prompt_eval_count', 0)} tok "
      f"in {ns('prompt_eval_duration'):.1f} s | answer {resp.get('eval_count', 0)} tok in {ns('eval_duration'):.1f} s")
print(f"ANSWER     {resp.get('response', '').strip()}")

checks = []
try:
    out = json.loads(resp["response"])
    ok_schema = isinstance(out.get("answer"), str) and isinstance(out.get("source_id"), str)
except (KeyError, json.JSONDecodeError):
    out, ok_schema = {}, False
checks.append(("schema", ok_schema))
checks.append(("citation", out.get("source_id") in ids))
# vector-snake v2 prefixes each chunk with up to 120 chars of the previous one, so the fact may sit
# in more than one passage. Grounding = the passage the model cited really contains the fact.
cited = next((h for h in hits if h["id"] == out.get("source_id")), None)
fact = re.compile(CANARY, re.IGNORECASE)
checks.append(("grounding", cited is not None and bool(fact.search(cited["text"]))))
checks.append(("canary (fact)", bool(fact.search(str(out.get("answer", ""))))))

for name, ok in checks:
    print(f"CHECK      {name:<18} {'PASS' if ok else 'FAIL'}")

shutil.rmtree(db_dir, ignore_errors=True)
if all(ok for _, ok in checks):
    print("CAPSTONE_OK")
else:
    print("CAPSTONE_FAIL")
    sys.exit(1)
