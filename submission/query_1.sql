WITH yesterday AS (
  SELECT *
  FROM meetapandit89096646.nba_player_status
  WHERE current_season = 1998
)
, today AS (
  SELECT player_name
       , is_active
       , current_season
       , CAST(seasons[1][1] AS INT) AS active_season
  FROM bootcamp.nba_players
  WHERE current_season = 1999
)

SELECT COALESCE(y.player_name, t.player_name) AS player_name
     , COALESCE(y.first_active_season, t.active_season) AS first_active_season
     , COALESCE(t.active_season, y.last_active_season) AS last_active_season
     , CASE WHEN t.is_active AND y.current_season IS NULL THEN 'New'
            WHEN NOT t.is_active AND (t.active_season - t.current_season) > 1 THEN 'Retired'
            WHEN t.is_active AND (t.active_season - y.current_season) = 1 THEN 'Continued Playing'
            WHEN t.is_active AND (t.active_season - y.current_season) > 1 THEN 'Returned from Retirement'
      ELSE 'Stayed Retired' END AS active_status
FROM yesterday y
FULL OUTER JOIN today t ON y.player_name = t.player_name