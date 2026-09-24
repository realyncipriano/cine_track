-- 011_add_runtime_to_watch_history.sql
-- Adds runtime column to watch_history for stats computation

ALTER TABLE watch_history ADD COLUMN runtime INT DEFAULT 0 AFTER watch_count;

-- Backfill runtime from the movies table where matches exist
UPDATE watch_history wh
JOIN movies m ON m.tmdb_id = wh.movie_id
SET wh.runtime = m.runtime
WHERE wh.runtime = 0 AND m.runtime > 0;
