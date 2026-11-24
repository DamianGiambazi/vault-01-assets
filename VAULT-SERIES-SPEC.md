# Vault Series — Final Asset Specification v1.0

**Applies to:** Vaults 1–6, every published asset. **Reference implementation:** the Vault 1 pack (29 Oct 2026), which conforms to this spec.
**Purpose:** every vault ships the same set of assets, in the same shape, with the same wording for anything that recurs, so a student moving from one vault to the next never has to relearn the packaging.

---

## 1. The series at a glance

| Vault | Thread | Video title | Vault title | Main reference doc |
|---|---|---|---|---|
| 1 | Tech | The 100% Rule: Building a Local AI Stack on 8 GB of RAM | The 100% Rule | *Vault 1 — The 100% Rule: Reference* ✅ |
| 2 | Humanities | Reproducible and Portable Truth: Finding the Spine, Then Making It Travel | Control Document Templates (The SSOT Library) | *Vault 2 — The SSOT Library: Reference* |
| 3 | Tech | From Curiosity to Custom MCP Server: The Phase-Gated AI Build | The Research & Preparation Playbook | *Vault 3 — The Research & Preparation Playbook: Reference* |
| 4 | Humanities | Rescuing the Leviathan: The 5-Stage Cognitive Contract Pipeline | Signature Prompt Collection | *Vault 4 — Signature Prompt Collection: Reference* |
| 5 | Ethics | The Disembodied Machine & The Somatic Human | Ethics & Human-Led AI Practices | *Vault 5 — Ethics & Human-Led AI Practices: Reference* |
| 6 | Survival | The Minimal Survival Kit: Stop Drowning in AI Slop | The Minimal Survival Kit | *Vault 6 — The Minimal Survival Kit: Reference* (+ the 2-page Survival Guide) |

**Naming rule:** "Vault N — <Vault title>" for vault assets; the video keeps its own title. The main text is always called the **Reference**: not "Desk Reference", "PDF" or "cheat sheet" (a vault may add a short guide, as Vault 6 does).

## 2. Series canon (must read identically everywhere)

| Item | Canonical form |
|---|---|
| The 100% Rule | "Are you 100% ready to execute the prompt, or do you need more information?" · the self-check: "Have I gathered all the relevant and correct information?" |
| The Five Golden Rules | 1. Raw evidence beats description · 2. Never stack two unknowns · 3. Plans are scaffolding, not scripture · 4. Trust but verify · 5. Context is a budget, curate it |
| Recording doctrine (SD-1, the Honest Cut) | Long waits are **cut, never sped up**; a 3–4 s card states the real duration and the reason; every cut is listed in the video description. No staged failures. **This replaces "single continuous session"**, wherever an older outline still says it (Vault 3 and Vault 4 outlines) |
| Prediction rule | Any experiment states its expected result in writing before it runs. A pass means "the prediction held", never "the AI understood" |
| The machine | SPOOKY: Lenovo V15-IGL, Intel Celeron N4020 (2 cores, no AVX), 8 GB RAM, Windows 11 Pro 25H2 |
| The local stack | DuckDB (the auditor) · LanceDB (the memory) · Hugging Face CLI (the logistics) · Ollama (the voice) · model `smollm2:360m-instruct-q8_0` · embeddings: vector-snake 2.0 with all-MiniLM-L6-v2, 384 numbers per chunk |
| Paths | `C:\Dev\smoke-lab\.venv` (the governed venv) · `C:\Dev\smoke-lab\<project>` for project folders · user-specific paths written `$HOME\…` or `$env:USERPROFILE\…`, never with a user name |
| GitHub | the account `DamianGiambazi` (as in `github.com/DamianGiambazi/suite-1992`) |
| vector-snake | written lowercase with a hyphen; "available on request" |
| The Book | the 24-chapter teaching novel; repository `novel-ssot` (Vault 2 onwards) |
| Versions | stated as "X at recording", with "now Y" only when it changed; never a version without its date context |
| Spelling | British English in authored text; commands, code, output and quoted on-screen text are kept verbatim |

## 3. The asset package (every vault)

```
vault-N-assets/
├── VAULT-N-INDEX.md          every file, in order of use
├── VAULT-N-ERRATA.md         corrections to the videos and to older copies of the assets
├── VAULT-N-DESCRIPTIONS.md   A. full-video description · B. summary-video description · C. lesson blurb
├── docs/                     numbered, cleaned teaching texts: 01-…md, 02-…md
├── scripts/                  runnable scripts used on camera
├── smoke-tests/              one test per installed or built component (where the vault installs or builds anything)
├── data/                     inputs shown on camera, untouched (fingerprints must still match)
├── <vault-specific>/         e.g. capstone/, anatomy/, mcp-server/, prompts/
└── lab/                      optional: beyond-the-vault material (model cards, test suites)
```
Plus **the Reference** as a Claude doc (exportable to PDF or Word), linked at the top of the index.

## 4. The Reference (main text)

- **Title:** `Vault N — <Vault title>: Reference` · byline: as-of date · author.
- **Section order:**
  1. What Vault N is: the lead sentence states what the vault achieves, then a fact table: machine or setting, stack or materials, videos.
  2. The core concept(s), one section each.
  3. The practical work, in the order the video does it.
  4. The proof (what was predicted, what was checked, what held).
  5. What the work taught us (snags table: *Snag · What it teaches*).
  6. Errata for the videos.
  7. Assets in this vault (pointer to the index).
  8. Glossary.
  9. What comes next.
- **Writing:** the first sentence of every section is its point; numbers with units; sentences under 25 words; no "this section describes…".
- **One drawing at most per Reference,** for the vault's central flow (Vault 1: the capstone pipeline).
- **Corrected content only:** the Reference never repeats an on-camera error; the errata section lists them.

## 5. Video descriptions (`VAULT-N-DESCRIPTIONS.md`, parts A and B)

**A. Full video: 150–200 words**
1. **Paragraph 1:** the vault's question or rule in the first sentence, then what is built or done, in order.
2. **Paragraph 2:** the concepts covered along the way, the proof moment, and how it ends.
3. **Fixed lines, in this order, only when they apply:**
   - `Cut, not sped up: <what> (real duration: mm:ss).` (one line per Honest Cut)
   - `Correction: <the single most important erratum, one line> (see the errata sheet).`

**B. Summary video: 80–120 words.** One paragraph: what the vault did, what is rerun or recapped, and the vault's key line as the closing sentence (Vault 1: *"If a system can't get something wrong, it can't be validated."*).

**Both:** first person, plain words, no hype words ("insane", "game-changing"), no timestamps unless chapters are added for the whole series.

## 6. Lesson blurb (part C): 180–230 words

```
**Vault N — <Vault title>.** <Hook: what the student learns and why, 1–2 sentences, ≤ 40 words.>

In this vault:
- **<Topic>:** <one line>
  (5–7 bullets, in the order the vault teaches them; the last bullet is the evidence or proof material)

You'll finish able to <three or four concrete abilities, ≤ 35 words>.
```
**Rules:**
- Every bullet names something the student can open in the asset package.
- No bullet promises what the vault doesn't contain.
- The tools are named the way the canon (§2) names them.

## 7. Errata (`VAULT-N-ERRATA.md`)

**Section A: video corrections.** Columns, fixed: `ID · Video · Where · Type · Said · Correct`
- **ID:** `V<N>-E<nn>` (Vault 1: V1-E01 … V1-E10). IDs never change once published; a withdrawn erratum stays, marked *withdrawn*.
- **Video:** Full | Summary.
- **Type:**
  - **Fact:** a wrong claim;
  - **Precision:** right idea, imprecise wording;
  - **Omission:** something left out that matters;
  - **Transcript:** a captions or speech-to-text error.
- **Said:** short quote or paraphrase in quotation marks. **Correct:** the true statement, then how it was fixed, if it was.

**Section B: asset corrections applied.** `File (old → new) · Change`. It also lists what was **deliberately not changed**, and why (e.g. fingerprinted data).

**Section C: versions to record.** `Item · At recording · Now`.

**Section D: open before publishing.** A numbered list; empty when the vault ships.

**Placement:**
- the full errata live in `VAULT-N-ERRATA.md`;
- the Reference carries the Section A table (ID, Video, Said, Correct);
- the full-video description carries one `Correction:` line;
- the captions are fixed for every Transcript item.

## 8. Index (`VAULT-N-INDEX.md`)

- **Opening:** one paragraph: what the pack is, the requirements, and the Reference link.
- **Fixed sections, in this order:** 1. Read first · 2. Concepts · 3–5. the vault's practical stages (named for that vault) · 6. Prove it, reproduce it, undo it · 7. Beyond the vault · **Not included** (with the reason for each item).
- **Table columns:** `# · File · What it is · Video`. Numbering runs through the whole index (1, 2, 3 … not per section).
- Every file in the package appears exactly once; anything mentioned on camera but not shipped appears under **Not included**.

## 9. Cleaning and privacy (before any asset ships)

1. No user names, email addresses, serial numbers, product IDs, MAC/IP addresses or personal paths, in any file, comment or output sample.
2. No scratch notes, chat leftovers ("You asked about…"), web-page residue or internal codes (beat numbers, R-codes, addendum names): replace them with the plain explanation.
3. Data shown on camera ships **byte-for-byte unchanged** when its fingerprint is recorded anywhere. Context goes in the index, not in the file.
4. Every script parses in PowerShell 7 or Python before shipping; smoke tests end in `<COMPONENT>_SMOKE_OK`.
5. Third-party claims in sample data are labelled in the index ("claims as reported by its sources").

## 10. Release checklist (per vault)

- [ ] The Reference complete; the errata table in it matches `VAULT-N-ERRATA.md` Section A.
- [ ] `VAULT-N-INDEX.md` lists every file once; the "Not included" section is complete.
- [ ] Descriptions A and B, and blurb C, are within their word ranges, and every Honest Cut has its real duration.
- [ ] The errata Section D is empty.
- [ ] The privacy scan is clean (search for the user name, "@", "Users\").
- [ ] Scripts parse; smoke tests pass on SPOOKY.
- [ ] Canon (§2) wording checked: rule, Golden Rules, tool names, versions.

## 11. Known inconsistencies to resolve in Vaults 2–6

| # | Where | Inconsistency | Resolution |
|---|---|---|---|
| S-1 | Vault 3 and Vault 4 outlines | "Single continuous session. No sped-up footage." | SD-1 Honest Cut (§2) |
| S-2 | Vault 6 outline, §2 | clones `github.com/daspooky/vault-6-survival-kit` | the `DamianGiambazi` account (§2): confirm before recording |
| S-3 | Vault 1 outline v2.0 | "Vault 1 Desk Reference PDF" | "the Reference" (a Claude doc, exportable to PDF) |
| S-4 | Vault 1 capstone vs Vault 4 | two five-tag prompt shapes: `role/context/task/constraints/question` (retrieval) and `role/context/task/constraints/output_format` (the canonical schema) | Vault 4's is **the canonical schema**; Vault 1's is labelled "a retrieval variant" wherever both appear |
| S-5 | Vault 3 and Vault 5 outlines | hand-set 5-number vectors (`[0.91, 0.12, …]`) after Vault 1 showed real 384-number vectors | either use real vector-snake output, or label them on screen as "illustrative, 5 of 384 dimensions" |
| S-6 | All vaults | the model versions moved after recording (Ollama 0.40.4 → 0.40.11) | the "at recording / now" rule (§2) |

## 12. Vault 1 conformance (applied 29 Oct 2026)

| Asset | Change for conformance |
|---|---|
| `VAULT-1-ERRATA.md` | IDs V-1 … V-10 → **V1-E01 … V1-E10**; *Where* and *Type* columns added |
| The Reference, errata table | IDs renumbered to match |
| `VAULT-1-DESCRIPTIONS.md` | A: 179 words ✅ · B: 98 words ✅ · C: 219 words, 7 bullets ✅. The Cut line awaits its duration (errata D-2) |
| `VAULT-1-INDEX.md` | conforms (sections 1–7 + Not included; numbering 1–31) |
