-- CREATE TABLE alia.player_state_tracking (
--   player_name VARCHAR,
--   first_active_season integer,
--   last_active_season integer,
--   seasons_active ARRAY(integer),
--   season_active_state VARCHAR,
--   current_season integer 
-- )
-- WITH
--   (FORMAT = 'PARQUET', partitioning = ARRAY['current_season'])

INSERT INTO
  alia.player_state_tracking
WITH
--last_season_cte: Retrieves player tracking data for the 1995 season from alia.player_state_tracking.
  last_season_cte AS (
    SELECT
      *
    FROM
      alia.player_state_tracking
    WHERE
      current_season = 1995
  ),
-- current_season_cte: Gathers player activity data for the 1996 season from bootcamp.nba_players, summarizing the maximum activity status, years since last active, and current active season for each player.
  current_season_cte AS (
    SELECT
      player_name,
      max(is_active) as is_active,
      max(years_since_last_active) as years_since_last_active,
      max(current_season) AS active_season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1996
    group by 1
  ),
-- combined: Merges data from the previous season (last_season_cte) and the current season (current_season_cte) using a full outer join on player_name. This handles new players, continuing players, and those with changes in activity status.
  combined AS (
    SELECT
      COALESCE(ls.player_name, cs.player_name) AS player_name,
      COALESCE(ls.first_active_season, cs.active_season) AS first_active_season,
      case
        when cs.is_active = True then cs.active_season 
        else ls.last_active_season
      end AS last_active_season,
      ls.last_active_season AS last_active_last_season,
      CASE
        when cs.is_active = True then cs.active_season
        else null 
      end AS active_season,
      CASE
        WHEN ls.seasons_active IS NULL THEN ARRAY[cs.active_season]
        WHEN cs.active_season IS NULL or cs.is_active = False THEN ls.seasons_active
        ELSE ls.seasons_active || ARRAY[cs.active_season]
      END AS seasons_active,
      1996 AS partition_season
    FROM
      last_season_cte ls
      FULL OUTER JOIN current_season_cte cs ON ls.player_name = cs.player_name
  )
--The season_active_state is determined based on the player's activity history:
    -- 'New' for players active for the first time in 1996.
    -- 'Returned from Retirement' for players who returned after being inactive.
    -- 'Continued Playing' for players who were active in consecutive seasons.
    -- 'Retired' for players who retired after the 1995 season.
    -- 'Stayed Retired' for players who did not return after retiring before 1996.
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
    WHEN active_season - first_active_season  = 0 THEN 'New'
    WHEN active_season - last_active_last_season > 1 THEN 'Returned from Retirement'
    WHEN active_season - last_active_season   = 0 THEN 'Continued Playing'
    WHEN active_season IS NULL
    AND partition_season - last_active_season = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END AS season_active_state,
  partition_season
FROM
  combined