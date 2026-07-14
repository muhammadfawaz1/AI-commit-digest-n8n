# VoIPmonitor Sniffer - Weekly Change Digest

An n8n workflow that tracks core-file changes to the voipmonitor/sniffer
GitHub repository, summarizes and classifies each commit using an LLM, stores results in Postgres,
and emails a weekly digest.

## Architecture
GitHub (fetch commits + diffs) -> Groq LLM (summarize + classify Major/Minor, with chunking for large diffs)
-> Postgres/Supabase (permanent record) -> Resend (email digest)

## Setup
This workflow requires the following credentials configured in n8n:
- GitHub Personal Access Token (Header Auth: Authorization: Bearer <token>)
- Groq API key (Header Auth: Authorization: Bearer <key>)
- Resend API key (Header Auth: Authorization: Bearer <key>)
- Postgres/Supabase connection (host, database, user, password - see Supabase pooler connection settings)

No credentials are stored in this repository. Import workflow/voipmonitor-digest.json into n8n
and configure credentials separately in the n8n UI.

## Database schema
See sql/schema.sql for the Postgres table definition.

