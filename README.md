# Vault 1 — The 100% Rule: Reference

Oct 29, 2026 · @Damian

## What Vault 1 is

Vault 1 installs a private, local AI layer on an old 8 GB laptop and proves every step: four tools, each tested alone, then one question answered from local documents, with the answer predicted in writing before the run. Nothing leaves the machine.

|  |  |
| --- | --- |
| Laptop | Lenovo V15-IGL ("SPOOKY"): Intel Celeron N4020, 2 cores, 8 GB RAM, no AVX, Windows 11 Pro 25H2 |
| Stack | DuckDB 1.5.6 · LanceDB 0.40.0 · Hugging Face CLI 2.2.0 · Ollama 0.40.4 (at recording) · model `smollm2:360m-instruct-q8_0` |
| Embeddings | vector-snake 2.0 with all-MiniLM-L6-v2 (384 numbers per chunk); vector-snake is available on request |
| Videos | *The 100% Rule* (full lesson) · *Vault 1 summary* (the whole pipeline rerun in minutes) |

By the end, a student works at levels 2 to 6 of the Computer Use Capability Scale (CUCS): the command line (L2), scripts (L4), Python and SQL driving data (L5), and isolated environments with uv and a venv (L6).

The method carries beyond computers: record a reference point, change one thing at a time, test each change, predict before you experiment, and compare against the reference when you finish.

## The 100% Rule

The rule is one question that makes an AI check itself before it acts: *"Are you 100% ready to execute the prompt, or do you need more information?"* It is a cheap validation loop: the model reviews the whole session, names any gaps, and admits doubt before it produces anything.

Ask it at the end of a session, just before the artifact:

- "Are you 100% ready to write the summer holiday checklist, or do you need more information?"
- "Are you 100% ready to deliver the final response email to the accountant, or do you need more details?"
- "Are you 100% ready to generate the updated Python file, or do you need more information?"

The other half of the rule is a question you ask yourself while gathering material: *"Have I gathered all the relevant and correct information?"*

At system scale the same rule becomes a procedure, because an AI can only answer for its words; only the machine can answer for the machine:

1. **Profile** the machine: what it is.
2. **Inventory** and save a **reference point**: what it has, and where.
3. **Gap scan**: what is missing.
4. **Change one thing at a time**, each with its own test.
5. **Predict before an experiment**, in writing, then run it.
6. **Compare** against the reference point when you finish.
7. **On any error:** copy the whole error, give it to the AI session, diagnose it, fix it at the source, run again.

## The command line

Everything in Vault 1 runs in PowerShell 7 (`pwsh`). The command line is one level below the desktop: you move to a folder, list what is in it and run programs, as you would with the mouse, but written as text.

```powershell
Set-Location "$HOME\Desktop"     # go to a folder
Get-ChildItem                    # list what is in it
notepad.exe .\notes.txt          # open (or create) a file
```

Windows ships two PowerShells side by side, and Vault 1 needs the newer one:

|  | Windows PowerShell 5.1 | PowerShell 7 |
| --- | --- | --- |
| Program | `powershell.exe` | `pwsh.exe` |
| Comes from | built into Windows | a separate install: `winget install --id Microsoft.PowerShell` |
| Check | `$PSVersionTable.PSEdition` → `Desktop` | `$PSVersionTable.PSEdition` → `Core` |
| Use it for | old Windows-only scripts | everything in this vault |

Two habits prevent most errors:

- **Check the prompt before every block.** It must start with `PS`. A prompt like `C:\Dev>` is Command Prompt (cmd.exe), where PowerShell commands fail. A new terminal tab may open 5.1 or cmd; type `pwsh` to switch.
- **Open a new tab after an installer changes PATH.** A shell reads PATH only when it starts, so a tool installed a moment ago is invisible to the old tab.

## Lexical, semantic and hybrid retrieval

Lexical retrieval finds text by its words; semantic retrieval finds it by its meaning. Vault 1 builds semantic retrieval.

| Kind | Finds text by | Strong at | Weak at |
| --- | --- | --- | --- |
| Lexical | matching words and tokens | exact names, file names, numbers, codes | the same idea in different words |
| Semantic | closeness between learned representations of meaning | questions worded differently from the text | telling near-identical passages apart; exact numbers |
| Hybrid | both, combined | exact precision and paraphrase together | more parts to build and check |

In short: lexical = what the text says; semantic = what the text means, approximately, as the embedding model represents it.

The capstone shows the difference. The sentence that holds the answer, "He kept it fifteen years", never names the ticket: it says "it". The question asks how long "the train ticket" was kept, and the link is made through the meaning of the passage. (The passage around that sentence does mention "the second ticket", so it is a test of meaning, not a test with zero shared words.)

## Chunks and vectors

vector-snake turns a document into numbered passages (chunks) and gives each one a vector: 384 numbers that place its meaning in space. The worked example is the *Native AI Newsletter* (2–19 Sep 2026): 14,625 characters became **21 chunks**.

1. **Read** the text file and normalise it (line endings, spacing).
2. **Cut** it into chunks of up to 1,000 characters at natural boundaries: paragraph, then line, sentence, word.
3. **Overlap**: each chunk after the first starts with up to 120 characters copied from the end of the one before, so no sentence loses its context.
4. **Embed** each chunk with a small local model, all-MiniLM-L6-v2. It reads at most 256 tokens; the newsletter's longest chunk used 225.
5. **Write** a timestamped CSV and a manifest (the receipt), then audit itself: 14 of 14 checks passed, including exact coverage, every character in exactly one chunk.

Each vector has a length of exactly 1 (it is normalised), so only its direction carries meaning. Chunks about similar things point in similar directions; that closeness is what LanceDB measures.

| Column in the vectors CSV | What it holds | Read it as |
| --- | --- | --- |
| `id` | document stem + chunk number, e.g. `51c2c11c_0000` | the evidence label |
| `source_file` | the file name as processed | traceability back to the source |
| `chunk_index` | 0, 1, 2 … | order inside the document |
| `created_utc` | creation time in UTC (the file name uses local time) | the forensic timestamp |
| `embedding_model` | `all-MiniLM-L6-v2` | a compatibility rule: vectors from different models can't be compared |
| `vector_dim` | `384` | must be the same in every row |
| `text` | the chunk, readable | the human evidence layer |
| `vector_json` | the 384 numbers, as text | the machine-readable meaning signature |

The newsletter file name, `51c2c11c`, is the first 8 characters of its SHA-256 fingerprint. The published text and CSV match the fingerprints recorded in vector-snake's manifest exactly.

## Know the machine before you change it

Four read-only checks build the reference point that every later claim is compared against. None of them changes anything.

| Step | Command or script | Answers | Result on SPOOKY |
| --- | --- | --- | --- |
| Profile | `Get-ComputerInfo`, cross-checked with `Get-CimInstance Win32_OperatingSystem` | what is this machine? | 8 GB, 2 logical processors. The OS reports "Windows 11 Pro" and, in a legacy field, "Windows 10 Pro": one source can be wrong, so cross-check |
| Inventory | `windows-11-full-scan.ps1` | which tools and versions are installed? | 29 version probes plus Visual Studio / MSVC |
| Reference point | `windows-11-shadow.ps1`, saved to a file | where does each tool live, and how many copies can PATH find? | 27 tools; every double copy explained (python 2, pyenv 3, gcloud 3 …) |
| Gap scan | `windows-11-gap-scan.ps1` v2.1 | are the new tools absent? | duckdb, hf, ollama, lancedb: NOT FOUND before, FOUND after |

A **shadow** is a second copy of a command that PATH can find. A new shadow appearing after an install is how silent breakage starts, so the reference point counts them.

The gap scan's section 3b also lists AI packages already present in the global Python from earlier experiments. It reports them and never removes them: saying what else the instrument found is part of the rule.

**Privacy before you share any output.** `Get-ComputerInfo` prints the owner's email address, the BIOS serial number and the Windows product ID; network listings show MAC and IP addresses and user names. Blur or delete them before you post, upload or paste them anywhere.

## The four installs

Each tool goes in alone and follows the same ritual: install → new tab → check the version → smoke test → clean up. If something breaks, you know which change broke it.

| Tool | Role | Install | Smoke test (script) | What it changed |
| --- | --- | --- | --- | --- |
| DuckDB 1.5.6 | **the auditor**: exact questions about structured files (rows, files, models, duplicates) | `winget install --id DuckDB.cli --exact` | `smoke-duckdb.ps1`: a query, then a 3-row CSV read straight from disk | +1 User PATH entry |
| LanceDB 0.40.0 | **the memory**: stores vectors, returns the passages closest to a question | in `C:\Dev\smoke-lab`: `uv venv .venv --python 3.11`, then `uv pip install --python .venv\Scripts\python.exe lancedb` | `smoke_lancedb.py` → `LANCEDB_SMOKE_OK` | the project's venv only; PATH untouched |
| Hugging Face CLI 2.2.0 | **the logistics**: fetches models and data, pinned to an exact revision | `uv tool install huggingface-hub==2.2.0` | `smoke-hf.ps1`: `hf env` (no token), a pinned 570-byte download, then delete it | `hf` and `tiny-agents` commands |
| Ollama 0.40.4 | **the voice**: runs a language model locally | `winget install --id Ollama.Ollama --exact` (1.47 GB), then `ollama pull smollm2:360m-instruct-q8_0` (386 MB) | `smoke-ollama.ps1`: reply `SMOKE_OK`, `ollama ps` shows 582 MB, `ollama stop` unloads it | +1 User PATH entry; a background service that starts itself |

The language model comes from **Ollama's own registry**, not from Hugging Face. The embedding model that vector-snake uses (all-MiniLM-L6-v2) was cached by Python's sentence-transformers library. The Hugging Face CLI is installed for controlled, version-pinned downloads in later vaults.

What to expect along the way:

- **Two Hugging Face warnings, no errors:** no token (anonymous on purpose) and no symlinks (Windows needs Developer Mode for them, so files are copied instead). Don't turn on Developer Mode to silence a warning.
- **LanceDB's `WARN … No existing dataset`** is information: the test creates its table.
- **The Ollama installer is large.** On SPOOKY's Wi-Fi it took about a quarter of an hour, and winget can't resume a cancelled download, so keep your hands off the keyboard while it runs.
- **A budget for the model:** at most 3B parameters, quantised, one model loaded at a time. smollm2 uses 582 MB, about a fifth of the 3 GB allowance.
- **Ollama settings, after recording:** *Auto-download updates* off and *Cloud* off, so the model can't change underneath a measurement and nothing leaves the laptop.

## The capstone: one question through the whole stack

The capstone is a declared experiment, not a magic trick: the answer was planted in a document and written down as a prediction before anything ran. `CAPSTONE_OK` means the prediction held, not that the AI "understood".

&#91;embedded content: the capstone pipeline · 5 stages, 1 gate, 4 checks\]

The documents and the question travel the same road until the gate splits them into evidence and question; the verdict comes only from the four checks against the prediction written before the run.

**The setup.** Four documents (an email, an example text, a band setlist and a page of draft notes, `notes_0652.txt`) plus `question.txt`. The notes contain the planted fact, "He kept it fifteen years.", in the same passage as three decoys: "Forty minutes", "the last train" and "06:52". The question: *"How long had the train ticket been kept before it was handed over?"*

**The prediction** (`PREDICTION.md`, saved before the run):

- P1: LanceDB ranks passage `notes_0652_0001` first of the 7 evidence passages.
- P2: the answer states the fact, fifteen/15 + year/years, in any sentence.
- P3: the answer cites `notes_0652_0001`.
- P4: the cited passage itself contains the fact.

**The run**, three commands in the capstone folder:

```powershell
& $VS_PY C:\Dev\vector-snake\vector_snake_v2.py input --output-dir vectors --offline
duckdb -bail -f audit.sql
..\.venv\Scripts\python.exe capstone_rag.py
```

1. **vector-snake** cuts and embeds all five files in one run: 5 × PASS. The question goes through the same model as the evidence, so both are translated by the same translator.
2. **DuckDB (`audit.sql`) is the gate.** It checks one run, no failures, one model, one vector size, no duplicate ids, exactly one question, and only then writes `corpus.parquet` and `question.parquet`: `AUDIT_PASS runs=1 evidence_rows=7`. If any check fails, nothing is exported.
3. **LanceDB** compares the question's vector with every passage and hands the 3 closest to the model. In rehearsal, `notes_0652_0001` ranked first (cosine distance 0.6933).
4. **Ollama** answers in a fixed JSON shape, `{"answer": …, "source_id": …}`, and may only cite a passage it was given. It runs at temperature 0 with seed 42, so the same input gives the same answer, and it unloads itself afterwards.
5. **Four checks**, written in code, decide the verdict:

| Check | Passes when |
| --- | --- |
| schema | the reply has the right JSON shape |
| citation | it cites one of the passages it was given |
| grounding | the cited passage really contains the fact |
| canary | the answer states the fact with its unit: "15 years" passes, "15 minutes" fails |

Result: `{"answer": "15 years", "source_id": "notes_0652_0001"}`, four PASS, `CAPSTONE_OK`. All four predictions held.

**It can fail, and it has.** In rehearsal, a 135M-parameter model answered "15 minutes" (FAIL), and its quantised version cited the wrong passage (FAIL). The 360M quantised model passed 3 times out of 3. A test that can't fail proves nothing.

**The error on camera, and the loop that fixed it.** The first run stopped with an HTTP 404 from Ollama: the model wasn't on the machine, because an earlier step had removed it. The whole error was copied into the AI session and diagnosed; the fix was `ollama pull smollm2:360m-instruct-q8_0`, and the rerun passed.

## Proof nothing broke, and how to reproduce it

The tools working is half the result; the other half is that nothing already on the laptop changed by accident. The reference point from the start makes that checkable:

| Check | Before | After | Verdict |
| --- | --- | --- | --- |
| New tools (gap scan) | NOT FOUND | FOUND, one copy each | as intended |
| The 27 existing tools (shadow table) | saved to a file | identical | nothing disturbed |
| User PATH | saved to a file | +2 entries: DuckDB's package folder and `Programs\Ollama` | both explained: their installers added them |
| LanceDB | not installed | only inside the project venv | contained |
| Models loaded after the run | none | none | the model unloads itself |

`windows-11-restore.ps1` takes the laptop back to the reference point. It was verified twice in rehearsal: afterwards the gap scan read NOT FOUND for all four tools, and the PATH, shadow and package comparisons were all empty.

One honest note: between 18 and 21 Oct, unrelated work added 16 packages to the laptop's global Python. The Vault 1 installs didn't cause it, but a comparison of that environment against the 15 Oct snapshot shows them. Always ask what else the instrument sees.

**Reproduce it in a workbench** (the summary video). Keep the recorded capstone folder untouched and work in a copy, `C:\Dev\smoke-lab\workbench`:

1. **Health check:** `pwsh`, `duckdb --version`, LanceDB import, `ollama list` (the model is present).
2. **Inputs:** copy the documents into `input\` and write `question.txt`. There is exactly one question, and the file must have that name.
3. **Vectorise** with vector-snake into an empty `vectors\` folder: one run only.
4. **Audit** with `duckdb -bail -f audit.sql`.
5. **Predict, then ask:** set `$env:CAPSTONE_CANARY` to a pattern for the expected fact, then run `capstone_rag.py`.
6. **Clean up** `vectors\` and both `.parquet` files before the next question.

The summary video ran two predicted questions back to back. The 15-years question passed again. Then a new, unrehearsed question about the email ("What caused the bottleneck in March?") was predicted as "the tiler" and passed. A system that can't get something wrong can't be validated; this one could, and didn't.

## What the machine taught us

The 100% Rule doesn't mean nothing goes wrong. It means whatever goes wrong is diagnosed, fixed at the source and verified. These snags were real, from rehearsal and recording:

| Snag | What it teaches |
| --- | --- |
| The same three CSV rows typed at the prompt mixed two kinds of line ending, and DuckDB refused the file | tested somewhere else is not tested here |
| The smallest model read "He kept it fifteen years" and answered "15 minutes" | finding the right passage isn't reading it: check the answer, not just the output |
| Uninstallers left their PATH entries behind | "uninstalled" isn't "gone"; only the saved reference point showed it |
| The real limit was the processor, not the RAM (no AVX or F16C) | measure before you believe the title: quantising made a 135M model run in 19.5 s instead of 165 s |
| The first fact check would have rejected a correct "15 years" | checking code deserves the same scepticism as the model |
| A Python update rebuilt pyenv's launchers and an old `hf` appeared on PATH | the gap scan caught it; never `pip install` into the global Python |
| Ollama updated itself between sessions | turn *Auto-download updates* off, and record the version with every result |

**On SPOOKY, in numbers:** the model is 386 MB on disk and 582 MB in memory. The capstone took about 49 s without screen recording; the model reads a prompt at about 24 tokens per second and writes at 5 to 6.5.

**What this model can and can't do.** After the vault, the same stack was put through 42 sealed questions on five interwoven travel diaries ([suite-1992 on GitHub](https://github.com/DamianGiambazi/suite-1992), model card MC-01). It passed 10 of 42. With the right passage ranked first it read a single fact correctly 8 times in 13, never refused correctly on the 3 unanswerable questions, and twice reported what the documents said over what it knew from training. It is fit for checked demonstrations like the capstone, and not for answers nobody checks.

## Errata for the videos

These are corrections to what was said on camera; this reference already uses the correct versions. Full detail is in `VAULT-1-ERRATA.md`.

| ID | Video | Said | Correct |
| --- | --- | --- | --- |
| V1-E01 | Full | the Hugging Face CLI downloads our local LLM | Ollama pulled the model from its own registry; the HF CLI is the pinned-download tool for later vaults |
| V1-E02 | Summary | "Tyler was the bottleneck" | "the **tiler**" (a tradesman), as written in the email |
| V1-E03 | Summary | the text never calls it a ticket | the answer *sentence* says "it"; the passage around it mentions "the second ticket" |
| V1-E04 | Full | "a little mistake" | HTTP 404: the model wasn't installed; fixed with `ollama pull` |
| V1-E05 | Full | five documents | four documents plus `question.txt` |
| V1-E06 | Summary | question packet, corpus packet | `question.parquet`, `corpus.parquet` |
| V1-E07 | Summary | the Python environment is activated | the scripts call the venv's `python.exe` by its path; nothing is activated |
| V1-E08 | Full | each section becomes a semantic number | each chunk becomes 384 numbers |
| V1-E09 | Full | the gap scan finds DuckDB, HF and LanceDB missing | Ollama too; section 3b also lists AI packages already in the global Python |
| V1-E10 | Full | installed without disrupting anything | true of the Vault 1 installs; separate additions to the global Python (18–21 Oct) predate the recording |

## Assets in this vault

Every file is listed with its purpose, version and order of use in `VAULT-1-INDEX.md`. Scripts, the capstone pack, the smoke tests and the restore script are cleaned of personal paths. vector-snake itself is available on request.

## Glossary

| Term | Meaning here |
| --- | --- |
| CLI | command-line interface; here, PowerShell 7 |
| PATH | the list of folders the shell searches for commands |
| shadow | a second copy of a command that PATH can find |
| reference point | a saved record of the machine before a change, compared after it |
| winget | Windows' package installer |
| uv, venv | a fast Python installer, and an isolated Python environment for one project |
| chunk | a passage cut from a document for retrieval |
| overlap | the words a chunk repeats from the end of the previous one |
| embedding, vector | the 384 numbers a model gives a chunk to represent its meaning |
| cosine distance | how far apart two vectors point; smaller = closer in meaning |
| RAG | retrieval-augmented generation: find the evidence, then let a model answer from it |
| quantisation | storing a model's numbers with fewer bits (8-bit here): smaller and much faster on a weak CPU |
| gate | a check that refuses bad input and exports nothing |
| canary | the planted fact, written as a pattern, that the answer must contain |
| grounding | the cited passage really contains the answer |
| Honest Cut | a long wait cut from the video, never sped up, with its real duration stated |

## What comes next

Vault 2 puts a whole novel through the same pipeline, explains how the cuts are chosen, and contrasts keyword search with search by meaning. Then git and GitHub make the work reproducible: seal it, share it, rebuild it anywhere.
