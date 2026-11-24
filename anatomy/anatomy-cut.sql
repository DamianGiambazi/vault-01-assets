-- anatomy-cut.sql — V1 §6E Beat 0, part 1: HOW A DOCUMENT IS CUT INTO PASSAGES.
-- Read-only tour of one finished vector-snake run: the Native AI Newsletter (13 Oct 2026, 21 chunks).
-- Run from your vault-1 folder :   duckdb -bail -f anatomy\anatomy-cut.sql
-- Reads anatomy\newsletter_manifest.json (vector-snake's receipt). Writes nothing.

.mode box
.maxwidth 120

-- 1. The receipt: one document in, 21 passages out, every audit check passed.
SELECT source.file                                   AS document,
       normalization.normalized_chars                AS chars,
       chunking.chunk_count                          AS chunks,
       embedding.model                               AS model,
       embedding.vector_dim                          AS dim,
       embedding.token_telemetry.max_tokens || ' / '
         || embedding.token_telemetry.max_seq_length AS max_tokens,
       len(list_filter(audit.checks, lambda c: c.passed)) || ' / '
         || len(audit.checks)                        AS checks_passed
FROM read_json_auto('anatomy/newsletter_manifest.json');

-- 2. The cut. Each passage's own span starts exactly where the previous one ended: no gap, nothing
--    counted twice. Each passage after the first also carries a run-up of up to 120 characters copied
--    from the end of the previous one ("overlap"), so a sentence is never cut off from its context.
SELECT c.index                                     AS chunk,
       c.base_start                                AS starts,
       c.base_end                                  AS ends,
       c.base_end - c.base_start                   AS own_chars,
       coalesce(c.prefix_end - c.prefix_start, 0)  AS overlap_chars,
       CASE WHEN c.index = 0 AND c.base_start = 0                         THEN 'start of text'
            WHEN c.base_start = lag(c.base_end) OVER (ORDER BY c.index)  THEN 'joins exactly'
            ELSE 'GAP OR DOUBLE COUNT' END         AS seam
FROM (SELECT unnest(chunks) AS c FROM read_json_auto('anatomy/newsletter_manifest.json'))
ORDER BY chunk;
