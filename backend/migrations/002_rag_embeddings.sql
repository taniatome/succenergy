-- 002_rag_embeddings.sql
--
-- The RAG vector store. Created empty.
--
-- The client's knowledge base has not arrived yet. The table exists now so
-- that ingestion is a script run later rather than a schema change on a live
-- database — and so the security posture below is in place before any
-- proprietary content lands in it.
--
-- Nothing in this pass writes, embeds, reads or retrieves from this table.

-- pgvector is already enabled on the client's Supabase project. Declared here
-- anyway so this migration is self-contained and applies to an empty database
-- — a fresh local one included.
--
-- On a plain Postgres without the pgvector extension installed this line is
-- where the migration stops. That is the correct failure: the table cannot be
-- created without the `vector` type. Local development should use a Supabase
-- project or the `pgvector/pgvector` Docker image, both of which ship it.
create extension if not exists vector;

-- ---------------------------------------------------------------------------
-- knowledge_chunks
-- ---------------------------------------------------------------------------
--
-- One row per retrievable chunk of the coaching knowledge base.
--
-- `chunk_id` is supplied by the ingestion script rather than generated, so
-- re-running ingestion over a corrected source document updates the rows it
-- already wrote instead of duplicating them.

create table if not exists knowledge_chunks (
  chunk_id     text primary key,

  -- The document the chunk came from, for provenance in a citation.
  source       text,

  content      text not null,

  -- voyage-multilingual-2 returns 1024 dimensions. Changing the embedding
  -- model means a new column or a new table, not an in-place alter: vectors
  -- of different models are not comparable.
  embedding    vector(1024),

  language     text,
  principle    text,
  content_type text,
  source_type  text,

  -- Proprietary by default. Anything in here is the client's material unless
  -- ingestion says otherwise, and the default should fail closed.
  proprietary  boolean not null default true,

  created_at   timestamptz not null default now(),

  constraint knowledge_chunks_language_check
    check (language is null or language in ('pt', 'en')),
  constraint knowledge_chunks_principle_check
    check (principle is null
           or principle in ('purpose', 'passion', 'planning', 'praxis',
                            'persistence', 'progress', 'perfection'))
);

-- Cosine similarity, matching how the embeddings will be normalised and
-- queried.
--
-- NOTE: ivfflat builds its lists by clustering the rows that exist when the
-- index is created. Built against an empty table it is meaningless, and it
-- stays meaningless as rows arrive. **Rebuild it after the first ingestion
-- run** — `reindex index knowledge_chunks_embedding_idx` — and size `lists`
-- to roughly rows/1000 at that point. It is declared now so the schema is
-- complete and the rebuild is a one-line operational step rather than a
-- forgotten migration.
create index if not exists knowledge_chunks_embedding_idx
  on knowledge_chunks
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

-- Retrieval is filtered by principle and content type before the vector
-- search narrows it, per the system prompt spec.
create index if not exists knowledge_chunks_principle_idx
  on knowledge_chunks (principle);

create index if not exists knowledge_chunks_content_type_idx
  on knowledge_chunks (content_type);

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------
--
-- This table matters most of all. It holds proprietary coaching material that
-- is server-side only and must never be client-reachable — the client asked
-- specifically to verify the vector store is not publicly readable.
--
-- RLS on, no policies. The backend reads it as the service role, which
-- bypasses RLS. The anon key, the authenticated key and anything else read
-- zero rows.

alter table knowledge_chunks enable row level security;
