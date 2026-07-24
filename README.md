# AI Commit Digest (n8n)

An n8n workflow that monitors a GitHub repository for commits, uses an LLM 
to summarize and classify each change, stores results in Postgres, and 
emails a weekly digest. Built entirely on free-tier services — no paid 
API plans required.

Originally built to track changes in the VoIPmonitor sniffer 
(voipmonitor/sniffer), but the pipeline works against any public repo.

## Why this exists

Most LLM-powered automations assume you have a paid API plan. This one 
doesn't. Groq's free tier caps you at 6000 tokens/minute — enough to 
summarize commits, but easy to blow through on a single large diff. 
This workflow is built specifically to survive that constraint: large 
commits get automatically chunked, spaced with rate-limit-aware waits, 
and reassembled, so the whole thing runs indefinitely on free-tier quota.

## Architecture

GitHub (fetch commits + diffs)
  → Groq LLM (summarize + classify Major/Minor, chunked for large diffs)
  → Postgres/Supabase (permanent record + file-purpose cache)
  → Resend (weekly email digest)

[Add a screenshot of the actual email output here — this is the single 
highest-value thing you can add, people judge a repo by what it produces]

## What makes this non-trivial

- **Free-tier TPM survival**: commits are chunked by diff size, not file 
  count, with Wait nodes tuned to keep cumulative token usage under 
  Groq's rolling 6000/min limit.
- **File-purpose caching**: rather than re-explaining what a file does on 
  every run, a Postgres lookup table caches per-file descriptions once 
  generated, so repeat runs only pay LLM cost for genuinely new files.
- **Defensive JSON parsing**: LLM output isn't always clean JSON. Every 
  parse step strips markdown fences, extracts JSON boundaries, and fails 
  loudly with the raw content included, rather than silently producing 
  bad data.

## Setup

Requires the following credentials in n8n:
- GitHub Personal Access Token (Header Auth: `Authorization: Bearer <token>`)
- Groq API key (Header Auth: `Authorization: Bearer <token>`)
- Resend API key (Header Auth: `Authorization: Bearer <token>`)
- Postgres/Supabase connection (see Supabase pooler connection settings)

No credentials are stored in this repository. Import 
`workflow/voipmonitor-digest.json` into n8n and configure credentials 
separately in the n8n UI.

## Database schema

See `sql/schema.sql` for the Postgres table definitions.

## Known limitations

- Summaries are generated per-file, not per-feature — a single logical 
  change spanning multiple files currently shows up as separate file 
  entries rather than one grouped explanation. This is a known tradeoff 
  of the chunking approach and an active area for improvement.
- The LLM infers "why" a change was made from the diff alone; it doesn't 
  have access to linked tickets or issue trackers, so causal explanations 
  are best-effort, not verified.

## Discussion

Questions and discussion are welcome in the Discussions tab — in 
particular, if you're hitting the same free-tier rate-limit walls, the 
chunking approach and Postgres caching pattern here should transfer 
directly to your use case.
