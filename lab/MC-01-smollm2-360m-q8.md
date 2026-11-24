# MODEL REPORT CARD MC-01 — smollm2:360m-instruct-q8_0
*Antibes corpus (suite-1992 v1.0) · template for every future reader*

| Field | Value |
|---|---|
| **Model** | `smollm2:360m-instruct-q8_0` · digest `dfd48b1fa28f` · 386 MB on disk · 8-bit quantised · 360M parameters |
| **Runtime** | Ollama 0.40.11 · auto-update **off** · cloud **off** · loopback only |
| **Machine** | SPOOKY · Celeron N4020 (2 cores, no AVX/AVX2/F16C) · 8 GB · Windows 11 25H2 |
| **Fixed setup** | prompt `708febac…` (V1 Archivist) · JSON schema with source_id ∈ retrieved ids · temp 0 · seed 42 · `num_ctx` 2048 · `num_predict` 96 · `keep_alive` 0 |
| **Search (not graded here)** | all-MiniLM-L6-v2 384-d via vector-snake 2.0.0 · LanceDB 0.40.0 cosine |
| **Runs** | B1 K=3 (`20261029_050813_baseline`) · E1 K=1 (`20261029_054751_k1`) · sealed 2026-10-29T04:57:39+01:00 |
| **Card date** | 2026-10-29 |

---

## 1. Headline

| Metric | K=3 | K=1 |
|---|---|---|
| PASS / strict PASS (of 42) | **10 / 9** (24 %) | **10 / 8** (24 %) |
| **Reading accuracy**: single fact, evidence at rank 1 (n=13) | **8 / 13 (62 %)** | **8 / 13 (62 %)** |
| Reading accuracy: evidence at rank 2–3 (n=8) | 1 / 8 | — (not shown) |
| Search hit (embedder, same for every reader) | 26 / 39 | 18 / 39 |

**One line:** finds a stated fact in the right passage about 6 times in 10, and that 60 % shifts with whatever else is in the prompt. It never abstains correctly, but it trusts the evidence over its own knowledge.

## 2. Capability grades
Scale: **A** ≥ 80 % · **B** 60–79 % · **C** 30–59 % · **D** < 30 %. Grades the **reader** only. Where the search failed first, the grade is marked *(search-limited)*.

| # | Capability | Evidence (B1 unless noted) | Score | Grade |
|---|---|---|---|---|
| C1 | Extract a stated fact (evidence at rank 1) | T1–T4, T8 at rank 1 | 8/13 (62 %) | **B** |
| C2 | Keep the unit under decoys | T3 | 3/8 (38 %) | **C** |
| C3 | Paraphrased questions | T2 | 0/5 | **D** (2 of 5 search-limited) |
| C4 | Attribution / disambiguation | T4 | 1/7 | **D** *(search-limited: 1/7 found)* |
| C5 | Cross-document, multi-step | T5 | 0/5 | **D** (expected: one citation only) |
| C6 | Count / order / arithmetic / negation | T6 | 0/6 | **D** |
| C7 | **Abstain when the evidence is absent** | T7 + false refusals | 0/3 correct · 2 false refusals | **D** |
| C8 | **Evidence over prior knowledge** | Q40, Q41 diary errors (both runs) | 2/2 answered as the diary says | **A** |
| C9 | Cite the expected passage when it was retrieved | `cited_expected` among found | 18/26 (69 %) | **B** |
| C10 | **Stability**: same verdict at K=3 and K=1 on identical rank-1 evidence | B1 vs E1 | 5/13 (38 %) | **C** |

## 3. Failure signatures (what to look for in the next model)

| Code | Signature | Example | Seen |
|---|---|---|---|
| FS-1 | **Role binding**: a nearby quoted phrase instead of the asked-for one | Q02 "Ciao bella" for the tune | P1, B1 |
| FS-2 | **Decoy number or unit** from the same passage | Q12 "six weeks" (E1), Q14 "20" (B1) | B1, E1 |
| FS-3 | **Magnet passage**: a number taken from a number-dense passage ranked lower | Q15 "151 km", Q21 "13:40" | B1 |
| FS-4 | **Echo**: the question returned as the answer | Q06, Q10 | B1 |
| FS-5 | **Invention**: a value found in no passage | Q16 "5 hours"; T7 "Pina" | E1, B1 |
| FS-6 | **False refusal**: "NOT IN EVIDENCE" with the evidence present | Q11, Q17 | B1 |
| FS-7 | **Citation slip**: right answer, neighbouring passage cited | Q41 (B1), P2 | B1, P2 |
| FS-8 | **Empty answer** | Q05 | E1 |
| FS-9 | **Guessable canary**: a correct answer possibly from training | P2 "Volare" | P2 |

## 4. Cost on this machine

| Measure | K=3 | K=1 |
|---|---|---|
| Prompt reading | 23.7 tokens/s | 24.7 tokens/s |
| Answer writing | 4.9 tokens/s | 6.5 tokens/s |
| Per question (mean) | 45.3 s | 22.3 s |
| 42-question suite | 31.7 min | 15.6 min |
| Model load | 1.4 s (3.0 s cold) | 1.5 s |
| Resident memory | 582 MB (V1, `ollama ps`, context 4096); within the 3 GB Addendum_02 budget | — |

## 5. Determinism

| Check | Result |
|---|---|
| Search (top-1 passage, B1 vs E1) | **42/42 identical** ✅ |
| Answers (repeat Q02, Q12, Q19, Q37) | **pending** (the compare wasn't run) |

## 6. Verdict and fit

| Use | Fit |
|---|---|
| Pipeline smoke test / teaching demo (one planted fact, checked) | ✅ **Fit**: the V1 capstone passed 3/3 |
| Single-fact lookup with machine checks on every answer | ⚠️ **Conditional**: about 60 %; never use without the four checks |
| Anything needing abstention, attribution, multi-step or arithmetic | ❌ **Unfit** |
| Recommended setting on SPOOKY | **K = 1** (same accuracy, half the time) |

**Bottleneck:** the reader (E1: changing the context fixes some answers and breaks others) for C1–C2 and C6–C7; the **search** for C3–C4.

---

### How to fill in the next card (MC-02 …)
1. Same sealed corpus and question bank, **only `CAPSTONE_MODEL` changes**. Run at K=1 and K=3, plus a 4-question repeat and its compare.
2. Copy this card. Fill the **Field** table from `config.json`. Fill §1 and §2 from `results.csv` (the rank-1 set is the 13 questions with `search_rank` = 1 in B1, so the reader is compared on identical evidence).
3. In §3, mark each FS code as *seen*, *not seen* or *new*, and add new codes at the end.
4. Add a **Δ column against MC-01** in §1 and §2. The card's verdict is decided by C1, C2, C7 and C10, the reader capabilities the search can't mask.
