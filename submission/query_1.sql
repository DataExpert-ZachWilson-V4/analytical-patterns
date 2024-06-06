INSERT INTO jsgomez14.nba_players_state_tracking
WITH last_season AS ( -- Define a CTE named last_season.
    SELECT *        -- This contains transformed data from last season. 
    FROM jsgomez14.nba_players_state_tracking -- If first season, it will be empty.
    WHERE season = 1995 
),
this_season AS ( -- Define a CTE named this_season. This reads from raw data.
    SELECT DISTINCT
           player_name,
           is_active,
           current_season
    FROM bootcamp.nba_players -- This contains data from the current season to be loaded.
    WHERE current_season = 1996
)
,combined AS ( -- Define a CTE named combined.
SELECT
  COALESCE(L.player_name, T.player_name) AS player_name,
  COALESCE(
    L.first_active_season,
    IF(T.is_active,T.current_season,NULL)
  ) AS first_active_season, -- Get first active season
  COALESCE(
    IF(T.is_active,T.current_season,NULL),
    L.last_active_season
  ) AS last_active_season, -- Get last active season
  CASE
      WHEN L.seasons_active IS NULL AND T.is_active THEN ARRAY[T.current_season]
      WHEN L.seasons_active IS NOT NULL AND (T.is_active IS NULL OR NOT T.is_active) THEN L.seasons_active
      ELSE L.seasons_active || ARRAY[T.current_season] 
  END AS seasons_active, -- Active seasons array
  L.last_active_season AS last_active_season_previous,
  T.is_active,
  COALESCE(L.season + 1, T.current_season) AS season
FROM last_season AS L
FULL OUTER JOIN this_season AS T
  ON L.player_name = T.player_name
)
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
      WHEN season - first_active_season  = 0 AND is_active THEN 'New'
      WHEN season - last_active_season_previous = 1 AND is_active THEN 'Continued Playing'
      WHEN season - last_active_season_previous = 1 AND NOT is_active THEN 'Retired'
      WHEN season - last_active_season_previous > 1 AND is_active THEN 'Returned from Retirement'
      ELSE 'Stayed Retired' -- Compute player_state
  END AS player_state,
  season
FROM combined