-- In this query we are creating a state change table which captures the current state of the players.
-- for autograder

INSERT INTO sagararora492.nba_players_state_tracking
WITH last_season AS ( -- this CTE contains data from last season and if this is the first season then the table will be empty
    SELECT *        
    FROM sagararora492.nba_players_state_tracking 
    WHERE season = 1995 
),
this_season AS ( -- this cte contains data from the current season.
    SELECT DISTINCT
           player_name,
           COALESCE(is_active, false) as is_active,
           current_season
    FROM bootcamp.nba_players 
    WHERE current_season = 1996
)
,combined AS ( 
SELECT
  COALESCE(L.player_name, T.player_name) AS player_name,
  COALESCE(
    L.first_active_season,
    IF(T.is_active,T.current_season,NULL)
  ) AS first_active_season,-- This gets us the first active season 
  COALESCE(
    IF(T.is_active,T.current_season,NULL),
    L.last_active_season
  ) AS last_active_season, -- This cte gives us the last season
  CASE
      WHEN L.seasons_active IS NULL AND T.is_active THEN ARRAY[T.current_season]
      WHEN L.seasons_active IS NOT NULL AND (T.is_active IS NULL OR NOT T.is_active) THEN L.seasons_active
      ELSE L.seasons_active || ARRAY[T.current_season] 
  END AS seasons_active, 
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
      ELSE 'Stayed Retired' -- this is the current status of the player
  END AS yearly_active_state,
  season
FROM combined