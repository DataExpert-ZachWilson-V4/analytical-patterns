-- Insert data into the RaviT.nba_players_track_status table
INSERT INTO RaviT.nba_players_track_status

-- Define common table expressions (CTEs)
WITH
  -- CTE to get the last season's player data for the year 2002
  last_season AS (
    SELECT
      player_name,
      first_active_season,
      last_active_season,
      active_seasons,
      player_state,
      season
    FROM
      RaviT.nba_players_track_status
    WHERE
      season = 2002
  ),
  
  -- CTE to get the current season's player data for the year 2001
  current_season AS (
    SELECT
      player_name,
      MAX(is_active) AS is_active, -- Determine if the player is currently active
      MAX(current_season) AS active_season -- Get the most recent active season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 2001
    GROUP BY
      player_name
  ),
  
  -- CTE to combine data from last_season and current_season
  combined AS (
    SELECT
      COALESCE(ls.player_name, cs.player_name) AS player_name, -- Merge player names from both CTEs
      COALESCE(
        ls.first_active_season, -- Use last season's first_active_season if available
        (CASE WHEN cs.is_active THEN cs.active_season END) -- Otherwise use current season if active
      ) AS first_active_season,
      COALESCE(
        (CASE WHEN cs.is_active THEN cs.active_season END), -- Use current season if active
        ls.last_active_season -- Otherwise use last season's last_active_season
      ) AS last_active_season,
      cs.is_active, -- Is the player currently active
      ls.last_active_season AS ls_last_active_season, -- Last active season from last_season CTE
      CASE
        WHEN ls.active_seasons IS NULL THEN ARRAY[cs.active_season] -- If no active seasons, start with current season
        WHEN cs.active_season IS NULL THEN ls.active_seasons -- If no current season, keep last season's active seasons
        WHEN cs.active_season IS NOT NULL AND cs.is_active THEN ARRAY[cs.active_season] || ls.active_seasons -- Append current season if active
        ELSE ls.active_seasons -- Otherwise, keep last season's active seasons
      END AS active_seasons,
      COALESCE(ls.season + 1, cs.active_season) AS season -- Increment season or use current season
    FROM
      last_season ls
      FULL OUTER JOIN current_season cs ON ls.player_name = cs.player_name -- Combine data from both CTEs
  )

-- Select data to be inserted into the target table
SELECT
  player_name,
  first_active_season,
  last_active_season,
  active_seasons,
  -- Determine player state based on activity and season data
  CASE
    WHEN is_active AND first_active_season - last_active_season = 0 THEN 'New'
    WHEN is_active AND season - ls_last_active_season = 1 THEN 'Continued Playing'
    WHEN is_active AND season - ls_last_active_season > 1 THEN 'Returned from Retirement'
    WHEN NOT is_active AND season - ls_last_active_season = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END AS player_state,
  season
FROM
  combined
