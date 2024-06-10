--Write a query (query_1) that does state change tracking for nba_players. Create a state change-tracking field that takes on the following values:
--A player entering the league should be New
--A player leaving the league should be Retired
--A player staying in the league should be Continued Playing
--A player that comes out of retirement should be Returned from Retirement
--A player that stays out of the league should be Stayed Retired

---CREATE OR REPLACE TABLE nancyatienno21998.nba_players_tracker (
---    player_name VARCHAR,
--    first_active_season INT,
---    last_active_season INT,
---    seasons_active ARRAY(INT),
---    season_active_state VARCHAR,
---    season INT
---    ) WITH
--    (format = 'PARQUET',
---    partitioning = ARRAY['season'])

INSERT INTO nancyatienno21998.nba_players_tracker
WITH last_season AS(
  SELECT
    *
  FROM 
   nancyatienno21998.nba_players_tracker
   WHERE season= 1995 
),
current_season AS (
  SELECT 
    player_name,
    is_active,
    current_season
  FROM bootcamp.nba_players
  where current_season = 1996
),
combined AS(
SELECT
  is_active,
  COALESCE(ls.player_name, cs.player_name)     AS player_name,
  COALESCE(ls.first_active_season, cs.current_season) as first_active_season,
  COALESCE(cs.current_season, ls.last_active_season) as last_active_season,
  CASE
    WHEN ls.seasons_active IS NULL THEN ARRAY[cs.current_season]
    WHEN cs.current_season IS NULL THEN ls.seasons_active
    ELSE ls.seasons_active || ARRAY[cs.current_season]
    END AS seasons_active,
COALESCE(ls.season + 1, cs.current_season) AS season
FROM last_season ls
FULL OUTER JOIN current_season cs ON ls.player_name = cs.player_name
)
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
    WHEN is_active and first_active_season - last_active_season = 0 THEN 'New'
    WHEN is_active and season - last_active_season =1 THEN 'Continued Playing'
    WHEN is_active and season - last_active_season >1 THEN 'Returned from Retirement'
    WHEN NOT is_active and season - last_active_season = 1 THEN 'Retired'
    WHEN NOT is_active and season - last_active_season >1 THEN 'Stayed Retired'
    ELSE 'ERROR'
  END AS season_active_state,
  season
from combined