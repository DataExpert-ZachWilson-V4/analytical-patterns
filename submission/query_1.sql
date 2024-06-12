-- Insert data into sanniepatron.nba_players_track_state using CTEs for modular queries
--INSERT INTO sanniepatron.nba_players_track_state
WITH 
-- CTE to select records from yesterday's data
yesterday AS (
  SELECT
    *
  FROM sanniepatron.nba_players_track_state
  WHERE season = 1999
),

-- CTE to get active season of players as of yesterday
yesterday_players AS (
  SELECT
    player_name,
    MAX(CASE WHEN is_active = TRUE THEN current_season ELSE NULL END) AS active_season_yesterday
  FROM bootcamp.nba_players
  WHERE current_season = 1999
  GROUP BY player_name
),

-- CTE to get active season of players as of today
today AS (
  SELECT
    player_name,
    MAX(CASE WHEN is_active = TRUE THEN current_season ELSE NULL END) AS active_season
  FROM bootcamp.nba_players
  WHERE current_season = 2000
  GROUP BY player_name
),

-- CTE to join yesterday and today data on player_name
joined AS (
  SELECT
    COALESCE(yp.player_name, t.player_name) AS player_name,
    COALESCE(yp.active_season_yesterday, NULL) AS active_season_yesterday,
    t.active_season AS active_season
  FROM yesterday_players yp
  FULL OUTER JOIN today t
  ON yp.player_name = t.player_name
),

-- CTE to combine data and determine active seasons and state
combined AS (
  SELECT
    COALESCE(y.player_name, t.player_name) AS player_name,
    COALESCE(y.first_active_season, t.active_season) AS first_active_season,
    COALESCE(t.active_season, y.last_active_season) AS last_active_season,
    y.last_active_season AS last_active_season_yesterday,
    t.active_season AS active_season_today,
    t.active_season_yesterday AS active_season_yesterday,
    CASE
      WHEN y.seasons_active IS NULL THEN ARRAY[t.active_season]
      WHEN t.active_season IS NULL THEN y.seasons_active
      ELSE y.seasons_active || ARRAY[t.active_season]
    END AS seasons_active,
    2000 AS partition_season
  FROM
    yesterday y
    FULL OUTER JOIN joined t ON y.player_name = t.player_name
)

-- Final select to insert data into the table
SELECT 
  player_name,
  first_active_season AS first_season_active,
  last_active_season AS last_season_active,
  seasons_active,
  CASE 
    WHEN active_season_today = first_active_season THEN 'New'
    WHEN active_season_today IS NULL AND (partition_season - last_active_season) = 1 THEN 'Retired'
    WHEN active_season_today IS NOT NULL AND active_season_yesterday IS NOT NULL THEN 'Continued Playing'
    WHEN active_season_today IS NOT NULL AND active_season_yesterday IS NULL THEN 'Returned from Retirement'
    WHEN active_season_today = first_active_season THEN 'new'
    ELSE 'Stayed Retired' 
  END AS player_state,
  partition_season AS season
FROM combined