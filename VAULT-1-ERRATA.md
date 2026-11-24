# Vault 1 — Errata (29 Oct 2026)

Format: Vault Series Asset Specification v1.0, §7. Types: Fact (wrong claim) · Precision (right idea, imprecise words) · Omission (left out something that matters) · Transcript (captions or speech-to-text).

Corrections to the two videos and to the asset corpus. The reference doc and the files in this pack already use the corrected versions; this sheet tells you what to change anywhere else (captions, pinned comment, older copies).

## A. Video corrections

| ID | Video | Where | Type | Said | Correct |
|---|---|---|---|---|---|
| V1-E01 | Full | the four installs | Fact | the Hugging Face CLI "will allow us to go to Hugging Face and download our local LLM" | The model was pulled by **Ollama from its own registry** (`ollama pull smollm2:360m-instruct-q8_0`). The HF CLI was installed and tested with a pinned 570-byte download; the embedding model was cached by Python's sentence-transformers. |
| V1-E02 | Summary | second question | Transcript | "Tyler was the bottleneck" | "the **tiler**" (a tradesman), as written in the email. Fix the captions. |
| V1-E03 | Summary | the capstone recap | Precision | the text never refers to the ticket as a ticket; a pronoun refers to it | The **answer sentence** ("He kept it fifteen years") says "it". The passage around it does mention "the second ticket". |
| V1-E04 | Full | capstone | Omission | "a little mistake" | An HTTP 404 from Ollama: the model wasn't installed (an earlier step had removed it). Fixed with `ollama pull`, then rerun. |
| V1-E05 | Full | capstone | Fact | "five documents" | Four documents plus `question.txt`. |
| V1-E06 | Summary | the audit | Precision | "question packet", "corpus packet" | `question.parquet` and `corpus.parquet`. |
| V1-E07 | Summary | setup | Fact | "make sure that we have our Python environment activated" | Nothing is activated: the scripts call the venv's `python.exe` (and vector-snake's Python) by full path. |
| V1-E08 | Full | vectors | Precision | each section is "transformed into a semantic number" | Each chunk becomes a vector of **384 numbers**. |
| V1-E09 | Full | gap scan | Omission | it confirms DuckDB, Hugging Face and LanceDB are not found | Ollama was not found either. Section 3b also lists AI packages already in the global Python (reported, not removed). |
| V1-E10 | Full | conclusion | Precision | "installed the entire system without disrupting anything else" | True of the Vault 1 installs (shadow table identical; PATH +2, both explained). Separately, unrelated work added 16 packages to the global Python on 18–21 Oct, before the recording. |

## B. Asset corrections (applied in this pack)

| File | Change |
|---|---|
| `The 100% rule.txt` → `docs/01-The-100-Percent-Rule.md` | blank lines removed; the three examples grouped; wording unchanged |
| `Lexical and Semantic.txt` → `docs/02-Lexical-and-Semantic.md` | scratch notes removed (they held a personal Windows path) |
| `FOUR INSTALLS.md` → `docs/03-Four-Installs.md` | "What Ollama **will add later**" → "What Ollama adds" (it is installed); the HF section names where both models came from |
| `vector-snake and chunking.md` → `docs/04-vector-snake-and-chunking.md` | the setlist was **1 chunk** in the capstone run, not 3 (example text 3, notes 2, newsletter 21); outdated descriptions of the email and sample texts replaced; id example uses the newsletter |
| `PowerShell 5.1 vs 7.6.7 Quick Reference` → `docs/05-PowerShell-5.1-vs-7.md` | web-page leftovers removed (favicon links, "+1", `&#x20;`, "You asked about 7.6.7…"); version note: SPOOKY ran 7.6.7 at recording and **7.6.9** afterwards |
| `CUCS v1.0` → `docs/06-CUCS-v1.0.md` | unchanged, plus §3 "Where Vault 1 sits" (levels 1, 2, 4, 5, 6) |
| `Using the Pipeline.md` → `docs/07-Using-the-Pipeline.md` | personal paths → `$HOME` / `$env:USERPROFILE`; two stray scratch blocks removed from Step 5; internal codes (Beat 0, R2-16, R3-1, R9, Addendum_02) replaced by plain explanations |
| `windows-11-gap-scan.ps1` | the attached copy was **v2.0**; the video ran **v2.1** (adds section 3b, ambient Python). The pack ships v2.1 |
| `anatomy/*.sql`, `stage-anatomy.ps1` | personal path in comments → "your vault-1 folder" / `$HOME\vault-1` |
| `Local AI Stack — Four-Tool Technical Brief.md` | retired; replaced by `docs/03-Four-Installs.md` |

**Not changed on purpose:** `data/51c2c11c.txt` and its vectors CSV. Their SHA-256 fingerprints match vector-snake's manifest (`51c2c11c…`, `bb88f519…`); any edit, even a header note, would break that proof.

## C. Versions to record

| Item | At recording | Now |
|---|---|---|
| PowerShell | 7.6.7 | 7.6.9 |
| Ollama | 0.40.4 | 0.40.11 (auto-download updates **off**, cloud **off** since 28 Oct) |
| Gap scan | v2.1 | v2.1 |

## D. Open before publishing

1. **Three capstone inputs are not in this pack:** `email1.txt`, `example.txt`, `setlist.txt`. Copy them from your `vault-1\capstone\input` and read each once for personal details (names, addresses, sign-offs).
2. **Honest Cut duration (D-2):** the full-video description lists the Ollama installer cut; fill in its real duration from the recording.
