-- Insert data into the RaviT.nba_players_track_status table
INSERT INTO datademonslayer.nba_players_track_status
-- Prepare data for insertion into player_season_tracking
WITH
  -- Retrieve last season's data (2001) for each player
  previous_season AS (
    SELECT
      player_name,
      first_active_season,
      last_active_season,
      active_seasons,
      player_state,
      season
    FROM
      datademonslayer.nba_players_track_status
    WHERE
      season = 2001
  ),
  
  -- Gather current season's data (2002), focusing on active status and recent activity
  this_season AS (
    SELECT
      player_name,
      MAX(is_active) AS is_active, -- Flag indicating whether the player is currently active
      MAX(current_season) AS season_active -- Most recent season the player was active
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 2002
    GROUP BY
      player_name
  ), 
  
  -- Combine previous and current season data for comprehensive tracking
  merged_data AS (
    SELECT
      COALESCE(ps.player_name, ts.player_name) AS player_name, -- Ensure all player names are included
      COALESCE(
        ps.first_active_season, -- Prioritize historical first active season
        (CASE WHEN ts.is_active THEN ts.season_active END) -- Use current active season if player is active
      ) AS first_active_season,
      COALESCE(
        (CASE WHEN ts.is_active THEN ts.season_active END), -- Use current season if player is active
        ps.last_active_season -- Otherwise, use last recorded active season
      ) AS last_active_season,
      ts.is_active, -- Current active status
      ps.last_active_season AS ps_last_active_season, -- Record of the last active season from historical data
      CASE
        WHEN ps.active_seasons IS NULL THEN ARRAY[ts.season_active] -- Start new tracking if no historical data
        WHEN ts.season_active IS NULL THEN ps.active_seasons-- Maintain historical seasons if no current activity
        WHEN ts.season_active IS NOT NULL AND ts.is_active THEN ARRAY[ts.season_active] || ps.active_seasons-- Append current season to historical seasons if active
        ELSE ps.active_seasons -- Use existing seasons if current season is inactive
      END AS active_seasons,
      COALESCE(ps.season + 1, ts.season_active) AS season -- Calculate next season number or use current season
    FROM
      previous_season ps
      FULL OUTER JOIN this_season ts ON ps.player_name = ts.player_name -- Merge data based on player name
  )

-- Select final dataset to insert into the new tracking table
SELECT
  player_name,
  first_active_season,
  last_active_season,
  active_seasons,
  -- Analyze player state based on activity and season data
  CASE
    WHEN is_active AND first_active_season - last_active_season = 0 THEN 'New'
    WHEN is_active AND season - ps_last_active_season = 1 THEN 'Continued Playing'
    WHEN is_active AND season - ps_last_active_season > 1 THEN 'Returned from Retirement'
    WHEN NOT is_active AND season - ps_last_active_season = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END AS player_status,
  season
FROM
  merged_data