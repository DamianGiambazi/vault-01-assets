# Vault 1 — The 100% Rule: Asset Index

Every file in the Vault 1 pack, in the order you'll use it. Start with the **reference** (the main text), then follow the steps. Requirements: Windows 10/11, PowerShell 7, `winget`, `uv`, and vector-snake 2.0 (the author's tool, **available on request**). Everything runs offline once installed.

**Main reference:** *Vault 1 — The 100% Rule: Reference* (Claude doc; export to PDF or Word): https://claude.ai/artifact/RicNwmqsZtBKZm1pU5MJBJ

## 1. Read first

| # | File | What it is | Video |
|---|---|---|---|
| 1 | `VAULT-1-DESCRIPTIONS.md` | the two video descriptions and the lesson blurb | both |
| 2 | `VAULT-1-ERRATA.md` | corrections to what was said on camera, and to earlier copies of the assets | both |
| 3 | `docs/01-The-100-Percent-Rule.md` | the rule, its three example prompts and the question to ask yourself | full: opening |
| 4 | `docs/06-CUCS-v1.0.md` | the Computer Use Capability Scale; §3 shows where Vault 1 takes you (levels 1–6) | — |

## 2. Concepts

| # | File | What it is | Video |
|---|---|---|---|
| 5 | `docs/05-PowerShell-5.1-vs-7.md` | the two PowerShells, how to tell them apart, why Vault 1 uses 7 | full: the command line |
| 6 | `docs/02-Lexical-and-Semantic.md` | search by words, by meaning, and both | full: concepts |
| 7 | `docs/04-vector-snake-and-chunking.md` | what vector-snake does and how to read every column of its CSV | full: concepts |
| 8 | `data/51c2c11c.txt` | the *Native AI Newsletter*, 2–19 Sep 2026 (an AI-distilled news digest; claims as reported by its sources) | full: chunking demo |
| 9 | `data/20261013_194027_51c2c11c_vectors.csv` | the same newsletter as 21 chunks with 384-number vectors | full: chunking demo |
| 10 | `data/20261013_194027_51c2c11c_manifest.json`, `…_run_manifest.json` | vector-snake's receipts: settings, 14 passed audit checks, SHA-256 fingerprints of both files above | — |

## 3. Know the machine (read-only scripts)

| # | File | What it does | Video |
|---|---|---|---|
| 11 | `Get-ComputerInfo` (a single command) | the machine describes itself; blur the identifiers before sharing | full: profile |
| 12 | `scripts/windows-11-full-scan.ps1` | 29 version probes plus Visual Studio / MSVC | full: inventory |
| 13 | `scripts/windows-11-shadow.ps1` | the reference point: where 27 tools live and how many copies PATH finds | full: shadow analysis |
| 14 | `scripts/windows-11-gap-scan.ps1` (v2.1) | are the four new tools absent (before) and present (after); section 3b lists AI packages already in the global Python | full: gap scan, conclusion |
| 15 | `scripts/windows-11-precheck.ps1` | optional pre-flight: LanceDB on this CPU, vector-snake's packages, disk and memory | — |

## 4. Install and test, one tool at a time

| # | File | Tests | Video |
|---|---|---|---|
| 16 | `docs/03-Four-Installs.md` | what each tool does, and doesn't | full: four installs |
| 17 | `smoke-tests/smoke-duckdb.ps1` | DuckDB: a query, then a CSV read from disk → `DUCKDB_SMOKE_OK` | full: DuckDB |
| 18 | `smoke-tests/smoke_lancedb.py` | LanceDB: nearest of three vectors → `LANCEDB_SMOKE_OK` | full: LanceDB |
| 19 | `smoke-tests/smoke-hf.ps1` | Hugging Face CLI: no token, a pinned 570-byte download, clean-up → `HF_SMOKE_OK` | full: HF CLI |
| 20 | `smoke-tests/smoke-ollama.ps1` | Ollama: pull, one reply, load, unload → `OLLAMA_SMOKE_OK` | full: Ollama |

## 5. The capstone (a sealed experiment)

| # | File | What it is | Video |
|---|---|---|---|
| 21 | `capstone/PREDICTION.md` | the planted fact, the question, the decoys, the four predictions, what counts as a pass | both |
| 22 | `capstone/input/notes_0652.txt` | a page of draft notes holding "He kept it fifteen years." | both |
| 23 | `capstone/input/question.txt` | "How long had the train ticket been kept before it was handed over?" | both |
| 24 | `capstone/input/email1.txt`, `example.txt`, `setlist.txt` | the other three documents (**add from your capstone folder after a privacy read**) | both |
| 25 | `capstone/audit.sql` | the DuckDB gate: one run, one model, one size, one question; exports two Parquet files or nothing | both |
| 26 | `capstone/capstone_rag.py` | LanceDB search → Ollama answer → four checks → `CAPSTONE_OK` / `CAPSTONE_FAIL` | both |

## 6. Prove it, reproduce it, undo it

| # | File | What it is | Video |
|---|---|---|---|
| 27 | `docs/07-Using-the-Pipeline.md` | the workbench guide: your own documents, your own question, a prediction first; four test runs | summary |
| 28 | `scripts/windows-11-restore.ps1` (v2.2) | uninstalls the four tools and removes their PATH entries; returns the laptop to the reference point | — |
| 29 | `anatomy/anatomy-cut.sql`, `anatomy-vector.sql`, `stage-anatomy.ps1` | a read-only DuckDB tour of the newsletter's 21 chunks: the cuts, the overlap, one vector | — |

## 7. Beyond the vault

| # | File | What it is |
|---|---|---|
| 30 | `lab/MC-01-smollm2-360m-q8.md` | the model's report card: 42 sealed questions, what a 360M model can and can't do |
| 31 | [github.com/DamianGiambazi/suite-1992](https://github.com/DamianGiambazi/suite-1992) | the full test suite (*The 8:17 from Antibes*), results and README, tag v1.0 |

## Not included

- **vector-snake** itself: available on request.
- **Baseline documents** for the author's laptop: machine-specific, and they contain identifiers.
- **`windows-11-clang.ps1`, `windows-10-full-scan.ps1`, `windows-10-install-scan.ps1`:** from earlier work; not used in either Vault 1 video.
- **Recording-only files** (OBS profile, benchmark, beat sheets).
