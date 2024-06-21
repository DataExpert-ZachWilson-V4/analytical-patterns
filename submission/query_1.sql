--  state change tracking for NBA players
--  between 1995 and 1996
INSERT INTO jimmybrock65656.nba_players_state_tracking
WITH last AS (
    -- last season results, 
    -- if first season then empty results
    SELECT * 
    FROM jimmybrock65656.nba_players_state_tracking 
    WHERE season = 1995 
),
this AS (
    -- data for the current_season
    SELECT DISTINCT
           player_name,
           is_active,
           current_season
    FROM bootcamp.nba_players
    WHERE current_season = 1996
    AND is_active IS NOT NULL
)
,combined AS (
-- combined data from last season and this season
SELECT
  COALESCE(l.player_name, t.player_name) AS player_name,
  COALESCE(
    l.first_active_season,
    IF(t.is_active,t.current_season,NULL)
  ) AS first_active_season, -- Get first active season
  COALESCE(
    IF(t.is_active,t.current_season,NULL),
    l.last_active_season
  ) AS last_active_season, -- Get last active season
  CASE
      WHEN l.seasons_active IS NULL AND t.is_active THEN ARRAY[t.current_season]
      WHEN l.seasons_active IS NOT NULL AND (t.is_active IS NULL OR NOT t.is_active) 
        THEN l.seasons_active
      ELSE l.seasons_active || ARRAY[t.current_season] 
  END AS seasons_active, -- Active seasons array
  l.last_active_season AS last_active_season_previous,
  t.is_active,
  COALESCE(l.season + 1, t.current_season) AS season
FROM last AS l
FULL OUTER JOIN this AS t
  ON l.player_name = t.player_name
)
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  -- determine player state
  CASE
      WHEN season - first_active_season  = 0 AND is_active THEN 'New'
      WHEN season - last_active_season_previous = 1 AND is_active THEN 'Continued Playing'
      WHEN season - last_active_season_previous = 1 AND NOT is_active THEN 'Retired'
      WHEN season - last_active_season_previous > 1 AND is_active THEN 'Returned from Retirement'
      ELSE 'Stayed Retired'
  END AS player_state,
  season
FROM combined
