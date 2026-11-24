# vector-snake and chunking: reading the output

vector-snake 2.0 is the operator's own tool (available on request). This guide explains what it does and how to read every column of the CSV it writes. The worked example is `data/20261013_194027_51c2c11c_vectors.csv`.

## 1. What vector-snake actually does

Vector-snake is the local preparation pipeline.

It performs several tasks in sequence.

First, it reads one or more plain text files.

Second, it normalizes the text enough to work with it reliably.

Third, it divides the text into chunks. These chunks are intended to be large enough to contain meaningful context, but small enough to be retrieved precisely later.

Fourth, it passes those chunks through a local embedding model.

Fifth, it receives a numerical vector for each chunk.

Sixth, it writes a timestamped CSV file containing the original text, the source metadata, and the vector representation.

The output is not a final database. It is a portable, inspectable, durable artifact.

That artifact can later be examined by DuckDB, imported into LanceDB, archived, compared, rebuilt, or used as test evidence.

---

## 2. What chunking means

Chunking is the process of dividing a document into smaller pieces before vectorization.

This is necessary because retrieval systems work better when they retrieve focused passages rather than entire long documents.

If a document is short, it may become one chunk.

If a document is long, it may become several chunks.

If a document has natural sections, the chunking process may preserve those sections.

You can see this in the Vault 1 runs. In the capstone, the email and the setlist each became one chunk, the example text three, and the page of draft notes two. The newsletter, a much longer document (14,625 characters), became 21 chunks, each starting a new section or paragraph where it could.

This is a good outcome. The chunks follow meaningful parts of the document.

A new user should interpret chunking as an attempt to preserve usable context, not as arbitrary cutting.

---

## 3. How to interpret the vector CSV filename

Each output CSV has a timestamped filename.

The filename usually contains:

- the date,
- the time,
- the original document stem,
- and the word “vectors”.

The purpose of this is to prevent accidental overwriting and to preserve a chronological record of processing runs.

If you process the same document twice, you do not destroy the earlier output. You create a new timestamped artifact.

This is useful for auditing, comparison, and recovery.

A new user should interpret the filename as an event record.

It tells you when a vectorization event happened and which source document was involved.

---

## 4. How to interpret the created_utc field

Inside the CSV there is a field called created_utc.

This records the time the vectorization row was created, expressed in Coordinated Universal Time.

This may differ from the local time embedded in the filename.

For example, a file processed at 16:12:22 local time records a created_utc of 14:12:22. That means the machine was two hours ahead of UTC at that moment (Central European Summer Time).

This is not an error.

It is actually a sign that the system is recording time responsibly.

The filename reflects local execution time. The created_utc field provides a normalized timestamp that can be compared across machines, sessions, and time zones.

A new user should interpret created_utc as the forensic timestamp.

It is the more reliable field for sequencing, auditing, and comparing records.

---

## 5. How to interpret the id field

Each row has an id.

The id usually combines the source document name and the chunk index.

For example, the newsletter's first chunk is `51c2c11c_0000`, its second `51c2c11c_0001`, and so on: the same source name, the next chunk number.

The id is not the meaning of the text. It is a stable identifier for the row.

It allows the system to refer to a specific piece of evidence later.

A new user should interpret the id as the evidence label.

It tells you which document and which part of that document the row represents.

---

## 6. How to interpret source_file

The source_file field records the name of the text file that was processed.

This field is important for traceability.

It allows you to connect a vector row back to the original document.

However, a new user should be careful here.

The source_file field reflects the name of the file that was actually processed, not necessarily the name you may later give the document when uploading it elsewhere.

For example, one email document was provided as email_01.txt, but the CSV recorded source_file as email1.txt. That suggests the file inside the input folder had been named email1.txt at the time of processing.

This is not a failure. It is a naming variance.

The important question is whether the text content matches the intended source.

A new user should interpret source_file as the operational source name, not necessarily the final archival name.

---

## 7. How to interpret chunk_index

The chunk_index field shows the position of the chunk within the processed document.

Chunk zero is the first chunk. Chunk one is the second chunk. Chunk two is the third chunk.

This is useful for reconstructing the document order later.

If you retrieve several chunks from the same document, chunk_index helps you understand where they came from relative to one another.

A new user should interpret chunk_index as the ordering marker.

It preserves the sequence of evidence inside the original document.

---

## 8. How to interpret embedding_model

The embedding_model field records which model created the vector.

In the Vault 1 outputs, this is all-MiniLM-L6-v2.

This field is extremely important because vectors only make sense relative to the model that created them.

If you change the embedding model, the mathematical space changes. Vectors created by one model cannot normally be compared directly with vectors created by another model.

This means the embedding_model field is not decorative metadata. It is a compatibility condition.

A new user should interpret embedding_model as the rule that keeps the corpus mathematically consistent.

As long as all rows use the same embedding model and dimension, they can be searched together.

If the embedding model changes, the corpus should usually be rebuilt.

---

## 9. How to interpret vector_dim

The vector_dim field records the number of numerical dimensions in the vector.

In the Vault 1 outputs, this is 384.

That means each chunk has been represented as a point in a 384-dimensional mathematical space.

This number is determined by the embedding model.

If all rows have vector_dim 384, they are dimensionally compatible.

If one row had 384 and another had 768, they would not belong in the same vector table without special handling.

A new user should interpret vector_dim as the structural compatibility check.

It tells you whether the vectors can live together in the same search space.

---

## 10. How to interpret the text field

The text field contains the human-readable chunk.

This is the part of the system that you can read directly.

It contains the actual language from the source document, or a close normalized version of it.

This field is crucial because it allows you to verify what the vector represents.

A vector without its text is difficult to interpret. A vector with its text becomes inspectable evidence.

Open any vectors CSV and the text column shows exactly which words each vector stands for: a whole short email in one row, a newsletter section in another.

A new user should interpret the text field as the human evidence layer.

It is what you read when you want to know what the machine is searching against.

---

## 11. How to interpret vector_json

The vector_json field contains the embedding itself.

It is a long list of numbers stored as text.

These numbers are not meant to be read by humans. They are meant to be compared mathematically.

Each number contributes to the overall position of the text chunk in semantic space.

Chunks with similar meanings will tend to have vectors that are closer together. Chunks with unrelated meanings will tend to be farther apart.

You may see very small numbers, negative numbers, positive numbers, and occasionally scientific notation. That is normal.

A new user should interpret vector_json as the machine-readable meaning signature.

It is not the meaning itself. It is a mathematical representation of meaning produced by a specific model.

---

## 12. What the embedding model actually does

The embedding model is a local model that converts text into vectors.

It does not write answers. It does not chat. It does not summarize.

Its role is translation.

It translates language into a numerical form that can be stored and compared.

When you embed a document chunk, the model produces a vector for that chunk.

When you later embed a question, the same model produces a vector for that question.

The retrieval system then compares the question vector to the stored document vectors and finds the closest matches.

This is why the same embedding model must be used for both storage and querying.

A new user should interpret the embedding model as the translator between human language and vector space.
