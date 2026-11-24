-- audit.sql — Capstone gate: DuckDB audits vector-snake v2's artifacts, then exports clean evidence.
-- Run from C:\Dev\smoke-lab\capstone :   duckdb -bail -f audit.sql
-- Input : vectors\  — ONE vector-snake v2 run over input\ (corpus documents + question.txt)
--         *_vectors.csv  (one per document)   *_run_manifest.json  (one per run)
-- Output: corpus.parquet, question.parquet — written only if every gate below passes.

-- 1. vector-snake's own verdict on its run (it audits itself; we read the receipt).
SELECT run_id, summary.inputs AS inputs, summary.passed AS passed,
       summary.warned AS warned, summary.failed AS failed
FROM read_json_auto('vectors/*_run_manifest.json');

-- 2. What did it hand us?  One row per source document.
SELECT source_file, count(*) AS chunks,
       any_value(embedding_model) AS model, any_value(vector_dim) AS dim
FROM read_csv_auto('vectors/*_vectors.csv')
GROUP BY ALL ORDER BY source_file;

-- 3. The gate. Exactly one run, nothing failed, one model, one dimension, no duplicate ids,
--    every vector really holds vector_dim numbers, and exactly one question row.
SELECT CASE
         WHEN m.runs = 1 AND m.failed = 0
          AND c.models = 1 AND c.dims = 1 AND c.dup_ids = 0 AND c.bad_vectors = 0
          AND c.question_rows = 1
         THEN 'AUDIT_PASS  runs=1  evidence_rows=' || (c.rows - c.question_rows) || '  model=' || c.model || '  dim=' || c.dim
         ELSE error('AUDIT_FAIL  runs=' || m.runs || ' failed=' || m.failed || ' models=' || c.models
                    || ' dims=' || c.dims || ' dup_ids=' || c.dup_ids || ' bad_vectors=' || c.bad_vectors
                    || ' question_rows=' || c.question_rows)
       END AS verdict
FROM (
  SELECT count(*) AS runs, sum(summary.failed) AS failed
  FROM read_json_auto('vectors/*_run_manifest.json')
) m,
(
  SELECT count(*)                         AS rows,
         count(DISTINCT embedding_model)  AS models,
         count(DISTINCT vector_dim)       AS dims,
         any_value(embedding_model)       AS model,
         any_value(vector_dim)            AS dim,
         count(*) - count(DISTINCT id)    AS dup_ids,
         count(*) FILTER (WHERE len(CAST(vector_json AS FLOAT[])) <> vector_dim) AS bad_vectors,
         count(*) FILTER (WHERE source_file = 'question.txt') AS question_rows
  FROM read_csv_auto('vectors/*_vectors.csv')
) c;

-- 4. Export. The evidence keeps its readable text; the vector becomes a typed array.
COPY (
  SELECT id, source_file, chunk_index, text, CAST(vector_json AS FLOAT[384]) AS vector
  FROM read_csv_auto('vectors/*_vectors.csv')
  WHERE source_file <> 'question.txt'
  ORDER BY source_file, chunk_index
) TO 'corpus.parquet' (FORMAT parquet);

COPY (
  SELECT id, text, CAST(vector_json AS FLOAT[384]) AS vector
  FROM read_csv_auto('vectors/*_vectors.csv')
  WHERE source_file = 'question.txt'
) TO 'question.parquet' (FORMAT parquet);

SELECT 'EXPORT_OK' AS status;
