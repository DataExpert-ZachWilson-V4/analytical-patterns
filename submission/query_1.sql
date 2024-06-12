-- This query is used to determine a players state across seasons
-- The results are saved in ovoxo.nba_players_state_tracking
-- -- To setup, ovoxo.nba_players_state_tracking is first created and then inserts are run across sequential years
-- CREATE TABLE ovoxo.nba_players_state_tracking (
--     player_name varchar, 
--     height varchar, 
--     college varchar, 
--     country varchar, 
--     draft_year varchar,
--     draft_round varchar, 
--     draft_number varchar, 
--     seasons array(
--         ROW(season integer, 
--             age integer, 
--             weight integer, 
--             gp integer, 
--             pts double, 
--             reb double,
--             ast double)), 
--     is_active boolean, 
--     years_since_last_active integer, 
--     first_active_season integer,
--     last_active_season integer,
--     season_state varchar,
--     current_season integer
-- )
-- WITH (
--   FORMAT = 'PARQUET',
--   PARTITIONING = array['current_season']
-- )


WITH
  previous_season AS (
    SELECT *
    FROM ovoxo.nba_players_state_tracking
    WHERE current_season = 2001
  ),

-- CTE this_season retrives raw data from the player's current season
  this_season AS (
    SELECT
      *
    FROM bootcamp.nba_players
    WHERE current_season = 2002
  ),

-- CTE combined combines previous_season and this_season. 
  combined AS (
    SELECT
        COALESCE(y.player_name, t.player_name) AS player_name,
        COALESCE(y.height, t.height) AS height,
        COALESCE(y.college, t.college) AS college,
        COALESCE(y.country, t.country) AS country,
        COALESCE(y.draft_year, t.draft_year) AS draft_year,
        COALESCE(y.draft_round, t.draft_round) AS draft_round,
        COALESCE(y.draft_number, t.draft_number) AS draft_number,
        COALESCE(y.seasons, t.seasons) AS seasons,
        COALESCE(y.is_active, t.is_active) AS is_active,
        COALESCE(y.years_since_last_active, t.years_since_last_active) AS years_since_last_active ,
        COALESCE(y.first_active_season, t.current_season) AS first_active_season, -- first season player was active
        y.last_active_season AS last_active_season_yesterday, -- last season they were active in previous season
        t.current_season AS active_season, -- current season
        COALESCE(t.current_season, y.last_active_season) AS last_active_season, -- last season player was active, including in current season
        2002 AS partition_year
    FROM previous_season y
      FULL OUTER JOIN this_season t ON y.player_name = t.player_name
  )
  
SELECT
    player_name,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    seasons,
    is_active,
    years_since_last_active ,
    first_active_season,
    last_active_season,
    CASE
            WHEN active_season - first_active_season = 0 THEN 'New'  -- If active season and first active season are the same, it's new.
            WHEN active_season - last_active_season_yesterday = 1 THEN 'Continued Playing'  -- Player was active in previous and current seasonif there is a year difference between the last active season tracked in the previous season and the current aseason, it's continued playing.
            WHEN active_season - last_active_season_yesterday > 1 THEN 'Returned from Retirement' -- Player was not active last season in one or more previous but played in current season. If there is more year difference between the last active season tracked in the previous season and the current season, it's returned from retirement.  
            WHEN active_season IS NULL 
                AND partition_year - last_active_season_yesterday = 1 THEN 'Retired' -- Player is not active in current season but was active in a previous season.
        ELSE 'Stayed Retired' -- If doesn't meet any of the above conditions, it's stayed retired.
    END AS season_state,
    partition_year
FROM
  combined