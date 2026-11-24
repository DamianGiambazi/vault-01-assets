# Vault 1 — Video descriptions and lesson blurb

## A. Full video — *Vault 1: The 100% Rule*

One question, "Are you 100% ready to execute the prompt, or do you need more information?", turned into a working method. On an old, low-powered laptop (8 GB, a 2-core Celeron), I profile the machine, save a reference point, find the gaps, and install a fully local AI layer one tool at a time: DuckDB (the auditor), LanceDB (the memory), the Hugging Face CLI (the logistics) and Ollama running a 360M-parameter model (the voice). Each tool gets its own test.

Along the way: the command line in a few minutes, lexical vs semantic search, and how my tool vector-snake turns a newsletter into chunks and vectors. The capstone is a declared experiment: a fact planted in my notes, the answer predicted before the run, four checks in code, and a real error diagnosed and fixed on camera. To finish, a before-and-after comparison shows nothing else on the laptop changed. Everything runs offline.

Cut, not sped up: the Ollama installer download (real duration: [mm:ss]).
Correction: the Hugging Face CLI doesn't download the model; Ollama does (see the errata sheet).

## B. Summary video — *Vault 1 in a few minutes*

The whole of Vault 1, recapped and rerun from scratch to show it wasn't a fluke. vector-snake makes the vectors; DuckDB audits them and writes the corpus and question files; LanceDB finds the closest passages; a small local model writes the answer. In a clean workbench, the prediction "15 years" is lodged before the code runs, and the system returns it, cited and checked. Then an unrehearsed second question about an email, "What caused the bottleneck in March?", predicted as "the tiler": the system gets that too. If a system can't get something wrong, it can't be validated.

## C. Lesson blurb

**Vault 1 — The 100% Rule.** Learn the one question that makes an AI admit what it doesn't know, then apply the same rule to a real machine: build a private AI layer on an 8 GB laptop and prove every step.

In this vault:
- **The rule** at prompt scale (the question, with examples) and system scale (profile, reference point, gap scan, one change at a time, predict, compare).
- **The command line:** PowerShell 7 vs 5.1, and the first commands.
- **Search by words vs search by meaning:** lexical, semantic and hybrid retrieval, and how documents become chunks and 384-number vectors, using a real newsletter and its vector file.
- **Four installs, each tested:** DuckDB, LanceDB, the Hugging Face CLI and Ollama, with ready-made smoke-test scripts.
- **The capstone:** one question through the whole stack, with the answer predicted in writing first and four checks deciding the verdict.
- **Scripts:** the machine scan, reference-point (shadow), gap scan and restore scripts, the capstone files and a workbench guide for your own documents.
- **The evidence:** what this small model can and can't do, measured on 42 sealed questions (model card MC-01, suite-1992 on GitHub).

You'll finish able to work at the command line, run Python and SQL against your own files, keep tools in isolated environments, and check any AI answer instead of trusting it.
