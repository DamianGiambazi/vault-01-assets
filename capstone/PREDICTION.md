# CAPSTONE PREDICTION (written before the run, shown before the run)

Planted fact   "He kept it fifteen years."  page 0652 of my draft notes, passage notes_0652_0001
Question       "How long had the train ticket been kept before it was handed over?"
               No shared keyword: the notes never say "train ticket", "kept ... before", "handed over".
Decoys         The same passage also says "Forty minutes", "the last train" and "06:52".

PREDICTION
  P1  LanceDB ranks notes_0652_0001 first of the 7 evidence passages
  P2  The answer states the fact: fifteen/15 + year/years, in any sentence
  P3  The answer cites notes_0652_0001
  P4  The cited passage itself contains the fact

ORACLE (what counts, decided in advance)
  Machine-checked   P2 canary, P3 citation, P4 grounding, plus the reply's JSON shape
  Read by eye       P1, from the EVIDENCE table (the first row)
  Accepted          "15 years", "fifteen years", "He kept it for 15 years."
  Rejected          "15 minutes", "15", "a decade and a half", "15 yrs"
                    The check is narrower than English, on purpose: a fact plus its unit.

IT CAN FAIL (rehearsal, 15 Oct)
  135M model             answered "15 minutes"            FAIL
  135M model, quantised  cited the wrong passage          FAIL
  360M model, quantised  "15 years", notes_0652_0001      PASS (3 of 3 runs identical)

SCOPE   One fact, seven passages, one question. A test of the pipeline, not of intelligence.
FIXED   Fact and question: 15 Oct 2026 (rehearsal 1). This file: 16 Oct 2026. Not edited after.
