CREATE TABLE commit_changes (
  id SERIAL PRIMARY KEY,
  commit_sha TEXT NOT NULL UNIQUE,
  commit_date TIMESTAMP,
  author TEXT,
  summary TEXT,
  priority TEXT CHECK (priority IN ('Major', 'Minor')),
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE commit_changes ADD COLUMN IF NOT EXISTS commit_url TEXT;
ALTER TABLE commit_changes ADD COLUMN IF NOT EXISTS review_recommendation TEXT;
ALTER TABLE commit_changes ADD COLUMN IF NOT EXISTS reasoning TEXT;
ALTER TABLE commit_changes ADD COLUMN IF NOT EXISTS file_changes TEXT;
