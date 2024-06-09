--Create a table that will track the nba players' yearly active state
--CREATE OR REPLACE TABLE ykshon52797255.nba_players_tracker(
-- player_name VARCHAR,
--  first_active_season BIGINT,
--  last_active_season BIGINT,
--  seasons_active ARRAY(BIGINT),
--  yearly_active_state VARCHAR,
--  current_season BIGINT
--)
--WITH
--  (FORMAT = 'PARQUET', 
--  partitioning = ARRAY['current_season'])

--start of the calculations
INSERT INTO ykshon52797255.nba_players_tracker

-- grab yesterday's data
with
  yesterday AS (
    select * 
    from ykshon52797255.nba_players_tracker
    where 
    current_season = 1997
  ),
  -- grab today's data
  today AS (
    select player_name,
      current_season
    from bootcamp.nba_players
    where 
    current_season = 1998
  ),
  -- full outer join yesterday and today cte
  combined AS (
  select coalesce(y.player_name, t.player_name) as player_name,
  -- previous first_active season is the true first active season
  coalesce(y.first_active_season, t.current_season) as first_active_season,
  -- today's current season is the latest active season
  coalesce(t.current_season, y.last_active_season) as last_active_season,
  CASE
    WHEN y.seasons_active is NULL THEN ARRAY[t.current_season]
    WHEN t.current_season is NULL THEN y.seasons_active
    ELSE y.seasons_active || ARRAY[t.current_season]
  END AS seasons_active,
  -- included these columns for returned from retirement column
  t.current_season as active_season,
  -- included these columns for returned from retirement column
  y.last_active_season as previous_active_season,
  1998 as current_season
  from yesterday y
  full outer join today t
  on y.player_name = t.player_name
  )
  
select player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
    WHEN last_active_season - first_active_season = 0 THEN 'New'
    WHEN current_season - last_active_season = 1 THEN 'Retired'
    WHEN current_season - last_active_season = 0 THEN 'Continued Playing'
    WHEN active_season - previous_active_season > 1 THEN 'Returned from Retirement'
    WHEN current_season - last_active_season > 1 THEN 'Stayed Retired'
  END AS yearly_active_state,
  current_season
  from combined
