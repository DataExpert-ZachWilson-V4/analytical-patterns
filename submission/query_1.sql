
-- Create or replace the players_state_tracking table
-- CREATE OR REPLACE TABLE luiscoelho37431.players_state_tracking (
--     player_name VARCHAR,
--     first_active_season INTEGER,
--     last_active_season INTEGER,
--     seasons_active ARRAY<INTEGER>,
--     is_active BOOLEAN,
--     season INTEGER
-- )
-- WITH
-- (
--     FORMAT = 'PARQUET',
--     partitioning = ARRAY['season']
-- )

-- Insert data into the players_state_tracking table
INSERT INTO luiscoelho37431.players_state_tracking
WITH last_season AS (
    -- Selecting data from the players_state_tracking table for the previous season (2001)
    SELECT *
    FROM luiscoelho37431.players_state_tracking
    WHERE season = 2001
),
current_season AS (
    -- Selecting data from the nba_players table for the current season (2002)
    SELECT player_name,
           is_active,
           current_season
    FROM bootcamp.nba_players
    WHERE current_season = 2002
),
combined AS (
    -- Combining the data from the last_season and current_season using a full outer join
    SELECT
        COALESCE(ls.player_name, cs.player_name) AS player_name,
        COALESCE(ls.first_active_season, IF(cs.is_active, cs.current_season, NULL)) AS first_active_season,
        COALESCE(IF(cs.is_active, cs.current_season, NULL), ls.last_active_season) AS last_active_season,
        CASE
            -- Determining the seasons_active based on the conditions
            WHEN ls.seasons_active IS NULL AND cs.is_active THEN ARRAY[cs.current_season]
            WHEN ls.seasons_active IS NOT NULL AND (cs.is_active IS NULL OR NOT cs.is_active) THEN ls.seasons_active
            ELSE ls.seasons_active || ARRAY[cs.current_season]
        END AS seasons_active,
        cs.is_active,
        COALESCE(ls.season + 1, cs.current_season) AS season
    FROM last_season AS ls
    FULL OUTER JOIN current_season AS cs
    ON ls.player_name = cs.player_name
)
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
      -- Determining the player_state based on the conditions
      WHEN season - first_active_season  = 0 AND is_active THEN 'New'
      WHEN season - last_active_season = 1 AND is_active THEN 'Continued Playing'
      WHEN season - last_active_season = 1 AND NOT is_active THEN 'Retired'
      WHEN season - last_active_season > 1 AND is_active THEN 'Returned from Retirement'
      ELSE 'Stayed Retired'
  END AS player_state,
  season
FROM combined