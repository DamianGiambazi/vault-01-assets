# The four installs: what each tool does

Vault 1 installs four tools, one at a time, each with its own test: DuckDB 1.5.6, LanceDB 0.40.0, the Hugging Face CLI 2.2.0 and Ollama (0.40.4 at recording). The commands and tests are in `smoke-tests/`.

## 01. What DuckDB does

DuckDB is the analytical database.

Its job is to inspect structured data with precision.

It does not perform semantic search. It does not understand meaning in the way LanceDB does.

Instead, it lets you ask exact structural questions.

For example, DuckDB can tell you:

- how many vector rows exist,
- which source files were processed,
- how many chunks each file produced,
- whether all vectors have the same dimension,
- which embedding model was used,
- when records were created,
- whether there are duplicates,
- and whether expected metadata is missing.

DuckDB is therefore the audit layer.

It gives you confidence that the corpus is organized, complete, and structurally valid.

A new user should interpret DuckDB as the catalogue inspector.

It does not ask what the text means. It asks what the records contain and whether they are well-formed.


## 02. What LanceDB does

LanceDB is the vector database.

Its job is to store vector rows and search them efficiently.

It does not create the vectors by itself. It receives them from the embedding process.

Once the vectors are inside LanceDB, you can ask questions in natural language, but only because the question is first converted into a vector by the embedding model.

LanceDB then finds the stored chunks whose vectors are closest to the question vector.

The result is not a generated answer. The result is a set of retrieved text chunks.

This distinction is critical.

On its own, LanceDB gives you retrieval, not conversation.

A new user should interpret LanceDB as semantic memory.

It remembers where similar meanings are stored and can fetch them when asked.

---

## 03. What Hugging Face CLI is for

Hugging Face CLI is a supporting tool for acquiring models, datasets, and related artifacts.

It is not required for every part of this system.

In the Vault 1 workflow, the embedding model (all-MiniLM-L6-v2) was downloaded and cached through the Python embedding library (sentence-transformers), and the language model came from Ollama's own registry. The Hugging Face CLI was needed for neither.

However, Hugging Face CLI becomes useful when you want more controlled model acquisition, version pinning, or access to specific repositories outside the normal automatic download path.

A new user should interpret Hugging Face CLI as the logistics tool.

It helps bring artifacts onto the machine, but it does not itself perform search, analysis, or inference.

---

## 04. What Ollama adds

Ollama is the local language model runtime.

It is not required for vector creation. It is not required for DuckDB auditing. It is not required for LanceDB retrieval.

But it is required for generative synthesis.

With Ollama installed, the system moves from retrieval to answer generation.

The workflow becomes:

1. The user asks a question.
2. The question is embedded.
3. LanceDB retrieves relevant chunks.
4. Those chunks are given to Ollama as context.
5. Ollama produces a natural language answer based on that context.

This is called retrieval-augmented generation.

Without Ollama, the system can fetch evidence.

With Ollama, the system can also explain, summarize, or answer using that evidence.

A new user should interpret Ollama as the voice of the system.

It does not replace retrieval. It speaks from retrieved evidence.

---
