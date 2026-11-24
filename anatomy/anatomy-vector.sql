-- anatomy-vector.sql — V1 §6E Beat 0, part 2: WHAT THE MACHINE KEEPS OF A PASSAGE.
-- Run from your vault-1 folder :   duckdb -bail -f anatomy\anatomy-vector.sql
-- Reads anatomy\newsletter_vectors.csv (21 rows, one per passage). Writes nothing.

.mode box
.maxwidth 120

-- 3. The overlap, in words: passage N opens with a run-up copied from the end of passage N-1.
--    Both rows are cut from the two passages exactly as stored; the text is the same.
--    Which seam is shown: change the number below (1..20). Default 12: a neutral, on-topic passage.
SET VARIABLE seam = 12;
WITH a AS (SELECT text FROM read_csv_auto('anatomy/newsletter_vectors.csv') WHERE chunk_index = getvariable('seam') - 1),
     b AS (SELECT text FROM read_csv_auto('anatomy/newsletter_vectors.csv') WHERE chunk_index = getvariable('seam'))
SELECT 'end of chunk '   || (getvariable('seam') - 1) AS seam,
       replace(substr(a.text, strpos(a.text, left(b.text, 30)), 80), chr(10), ' ') AS text
FROM a, b
UNION ALL
SELECT 'start of chunk ' || getvariable('seam'), replace(left(b.text, 80), chr(10), ' ') FROM b;

-- 4. One passage, and what the machine keeps of it: 384 numbers. Their squares sum to 1
--    ("normalised"), so only the direction of the arrow carries meaning, not its length.
SELECT id,
       left(replace(text, chr(10), ' '), 36) || '…'                                 AS passage,
       list_transform(CAST(vector_json AS FLOAT[])[1:4], lambda x: round(x, 4))      AS first_4_numbers,
       len(CAST(vector_json AS FLOAT[]))                                             AS how_many,
       round(sqrt(list_sum(list_transform(CAST(vector_json AS FLOAT[]), lambda x: x * x))), 4) AS length
FROM read_csv_auto('anatomy/newsletter_vectors.csv')
WHERE chunk_index = 0;

-- 5. The contract every row carries. Model and size must be identical in every row, or comparing
--    two vectors means nothing. (In the capstone, the DuckDB gate refuses evidence that breaks this.)
SELECT embedding_model, vector_dim, count(*) AS rows
FROM read_csv_auto('anatomy/newsletter_vectors.csv')
GROUP BY ALL;
