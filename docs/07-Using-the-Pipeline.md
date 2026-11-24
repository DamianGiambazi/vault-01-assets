# Using the pipeline: documents → vector-snake → DuckDB → LanceDB → Ollama

The workbench procedure from the Vault 1 summary video: ask your own question of your own documents, with a prediction written first. It needs the Vault 1 stack installed and vector-snake (available on request).

---

## How it fits together

```
input\  (your .txt documents + question.txt)
   │  1. vector-snake       cut into passages → 384 numbers each        → vectors\*.csv + manifests
   │  2. DuckDB audit.sql   gate: 1 run, 0 failed, 1 model, 1 size, 1 question → corpus.parquet, question.parquet
   │  3. capstone_rag.py    LanceDB: 3 closest passages → Ollama: answer + cited id → 4 checks
   ▼
CAPSTONE_OK / CAPSTONE_FAIL
```

**Three things the scripts assume (built in for V1):**
1. **The question is a file:** `input\question.txt`, short enough to stay one passage (under ~1,000 characters).
2. **One run per folder:** `vectors\` must hold exactly one vector-snake run, or the gate refuses it (`runs=2`).
3. **You state the expected fact in advance** (`CAPSTONE_CANARY`, a regex). That's the 100% Rule: no prediction, no verdict.

---

## Step 0 — Health check (once per session, ~1 min)

```powershell
pwsh -v                                              # 7.x (not 5.1)
duckdb --version                                     # v1.5.6
C:\Dev\smoke-lab\.venv\Scripts\python.exe -c "import lancedb; print('lancedb', lancedb.__version__)"
ollama --version
ollama list                                          # is smollm2:360m-instruct-q8_0 there?
```
- **If the model is missing:** `ollama pull smollm2:360m-instruct-q8_0` (386 MB). (The capstone ends by removing it, so this is normal after a capstone run.)
- **If `ollama` can't connect:** start the Ollama app from the Start menu, then retry.
- **Why:** each tool is checked alone first, so a failure later points to one step, not four.

## Step 1 — Set up a workbench (once)

```powershell
$wb = 'C:\Dev\smoke-lab\workbench'
New-Item -ItemType Directory -Force -Path "$wb\input" | Out-Null
Copy-Item "$HOME\vault-1\capstone\audit.sql", "$HOME\vault-1\capstone\capstone_rag.py" $wb
$VS_PY = "$env:USERPROFILE\.pyenv\pyenv-win\versions\3.11.9\python.exe"   # the Python that runs vector-snake
Set-Location $wb
```
**Why:** the capstone folder is the record of the recording, so leave it alone. The workbench is yours to change. It lives in smoke-lab so it can use the governed venv one level up (`..\.venv`).

## Step 2 — Put in documents and a question

```powershell
Copy-Item C:\path\to\your\docs\*.txt .\input\
Set-Content .\input\question.txt -Encoding utf8NoBOM -Value 'Your question in one sentence?'
Get-ChildItem .\input
```
**Why:** vector-snake vectorises the question in the **same run** as the documents, so both are translated by the same model: vectors from different models can't be compared. `.txt` is the validated input type; other formats are untested here.
**Tip:** word the question differently from the text, as V1 did. Then a hit proves search by meaning, not keyword matching.

## Step 3 — Vectorise (vector-snake)

```powershell
Remove-Item .\vectors -Recurse -Force -ErrorAction SilentlyContinue
& $VS_PY C:\Dev\vector-snake\vector_snake_v2.py input --output-dir vectors --offline
```
**Expect:** one `[PASS]` per file and `[SUMMARY] passed=N … failed=0`.
**Why clear `vectors\` first:** the gate accepts exactly one run. Two runs could mix different settings, so it refuses them.
**Don't pipe it** (`| Out-Null`, `> file`): with piped output, vector-snake 2.0 crashes on the `→` character it prints and marks every document FAILED.

## Step 4 — Audit and export (DuckDB gate)

```powershell
duckdb -bail -f audit.sql
```
**Expect:** the run table, the per-file table, `AUDIT_PASS  runs=1  evidence_rows=N …`, `EXPORT_OK`.
**If `AUDIT_FAIL`:** the line says which rule broke:
- `runs=2`: go back to Step 3 and clear `vectors\` first.
- `question_rows=2`: the question is too long and was split; shorten it.
- `failed=1`: read vector-snake's output for that file.

Nothing is exported on a failure, so Step 5 can't run on bad evidence.

## Step 5 — Predict, then ask (LanceDB + Ollama)

```powershell
$env:CAPSTONE_CANARY = '\b(fifteen|15)\s+years?\b'     # YOUR expected fact, written BEFORE the run
..\.venv\Scripts\python.exe capstone_rag.py
Remove-Item Env:\CAPSTONE_CANARY
ollama ps                                              # empty: the script unloaded the model
```


**Expect:** EVIDENCE (3 closest passages, distances) → QUESTION → MODEL → TIMING → ANSWER `{ "answer": …, "source_id": … }` → four CHECK lines → `CAPSTONE_OK` or `CAPSTONE_FAIL`. About 50 s on SPOOKY (longer while screen recording).

**Writing the canary:** a case-insensitive regex for the fact **plus its unit**:

- 15 years → `\b(fifteen|15)\s+years?\b`
- 6 p.m. → `\b6\s*p\.?m\.?`
- a name, e.g. Daniel → `\bDaniel\b`

Keep the single quotes in PowerShell so `\b` and `$` reach Python unchanged.

**What the four checks mean:**
- **schema:** the reply is valid `{answer, source_id}`.
- **citation:** it cites one of the 3 passages it was given.
- **grounding:** the cited passage really contains your fact.
- **canary:** the answer states your fact.

**No idea what the answer is?** Then you're exploring, not testing. Set `$env:CAPSTONE_CANARY = '.'`. Grounding and canary then pass trivially, so only schema and citation are machine-checked, and **you** must verify the ANSWER against the cited passage. Read the verdict accordingly.

## Step 6 — Clean up between questions

```powershell
Remove-Item .\vectors, .\corpus.parquet, .\question.parquet -Recurse -Force -ErrorAction SilentlyContinue
```
Then change `input\` and repeat Steps 3–5. LanceDB's table lives in `%TEMP%\lancedb_capstone` and is deleted by the script itself.

---

## Test plan: four runs, each with a prediction

| # | Setup | Predict | Proves |
|---|---|---|---|
| T1 | Copy `vault-1\capstone\input\*` to `input\`; default canary | `CAPSTONE_OK`, "15 years", `notes_0652_0001` | The workbench reproduces the recording |
| T2 | Your own 2–5 `.txt` files; a question whose answer you know; matching canary | `CAPSTONE_OK` citing the passage you expect | The pipeline works beyond the planted example |
| T3 | Same documents; a question they **can't** answer | ANSWER `NOT IN EVIDENCE` → `CAPSTONE_FAIL` (grounding fails: nothing to ground) | It refuses rather than invents. If it invents an answer instead, record that: it's a real limit of a 360M model |
| T4 | After T2, run Step 3 again **without** clearing `vectors\`, then Step 4 | `AUDIT_FAIL runs=2`; no parquet files written | The gate fails closed |

Log each run (question, canary, top passage, answer, verdict, TIMING line) in a simple text file. Those runs are the raw material for Vault 2.

## Limits to keep in mind

- **K = 3 passages, `num_ctx` 2048:** very long passages or many similar documents can push the right passage out of the top 3. Look at the EVIDENCE table first: if the right passage isn't there, the model never saw it.
- **A 360M model:** reliable for short factual lookups; weak at reasoning across passages, summaries or "why" questions.
- **One model at a time,** ≤ 3B parameters, quantised. Trying another model: `$env:CAPSTONE_MODEL = '<name>'` after `ollama pull`, then `ollama rm` it afterwards.
- **vector-snake runs in the global Python.** **Never `pip install` into it or run `pyenv rehash`**: in October a Python update rebuilt pyenv's launchers and an old copy of `hf` appeared on PATH.