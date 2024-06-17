/*
A query that does state change tracking for `nba_players`. 
Create a state change-tracking field that takes on the following values:

A player entering the league should be New
A player leaving the league should be Retired
A player staying in the league should be Continued Playing
A player that comes out of retirement should be Returned from Retirement
A player that stays out of the league should be Stayed Retired

-- testing table
CREATE TABLE siawayforward.nba_growth_accounting (
  player_name VARCHAR,
  first_active_season INTEGER,
  last_active_season INTEGER,
  season_active_status VARCHAR,
  current_season INTEGER
)
WITH (
  format='PARQUET',
  partitioning=ARRAY['current_season']
);
*/


-- INSERT INTO siawayforward.nba_growth_accounting
-- loaded and tested 1996 to 2002
WITH last_season AS (

    SELECT *
    FROM siawayforward.nba_growth_accounting
    WHERE current_season = 2001

), this_season AS (

    SELECT
        player_name,
        current_season,
        MIN(s.season) AS first_active_season,
        MAX(s.season) AS last_active_season
    FROM bootcamp.nba_players,
    UNNEST(seasons) s
    WHERE current_season = 2002
    GROUP BY 1, 2

), combined AS (

    SELECT
      COALESCE(l.player_name, t.player_name) AS player_name,
      CASE WHEN l.player_name IS NULL THEN t.first_active_season ELSE l.first_active_season 
      END AS first_active_season,
      CASE WHEN t.current_season - t.last_active_season != 0 THEN l.last_active_season ELSE t.current_season
      END AS last_active_season,
      l.last_active_season AS prev_last_active_season,
      t.current_season
    FROM last_season l 
    FULL OUTER JOIN this_season t
        ON t.player_name = l.player_name
    
), status_selection AS (
  SELECT 
    player_name,
    first_active_season,
    last_active_season,
    CASE
      -- A player entering the league should be New
      WHEN last_active_season - first_active_season = 0 THEN 'New'
      -- A player leaving the league should be Retired
      WHEN current_season - last_active_season = 1 THEN 'Retired'
      -- A player staying in the league should be Continued Playing
      WHEN last_active_season - prev_last_active_season = 1 THEN 'Continued Playing'
      -- A player that comes out of retirement should be Returned from Retirement
      WHEN current_season - prev_last_active_season > 1 AND current_season = last_active_season
          THEN 'Returned from Retirement'
      -- A player that stays out of the league should be Stayed Retired
      ELSE 'Stayed Retired'
  END AS season_active_status,
    current_season
  FROM combined
  
)
SELECT *
FROM status_selection
-- WHERE player_name = 'Michael Jordan'