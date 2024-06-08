WITH
  yesterday AS (
    SELECT *
    FROM ovoxo.nba_players_state_tracking
    WHERE season = 2001
  ),

  today AS (
    SELECT
      *
    FROM bootcamp.nba_players
    WHERE current_season = 2002
  ),

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
        COALESCE(y.first_active_season, t.current_season) AS first_active_season,
        y.last_active_season AS last_active_season_yesterday,
        t.current_season AS active_season, 
        COALESCE(t.current_season, y.last_active_season) AS last_active_season,
        2002 AS partition_year
    FROM yesterday y
      FULL OUTER JOIN today t ON y.player_name = t.player_name
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
            WHEN ABS(active_season - first_active_season) = 0 THEN 'New' 
            WHEN ABS(last_active_season_yesterday - active_season) = 1 THEN 'Continued Playing'  
            WHEN ABS(last_active_season_yesterday - active_season) > 1 THEN 'Returned from Retirement' 
            WHEN active_season IS NULL AND ABS(last_active_season -  partition_year) = 1 THEN 'Retired' 
        ELSE 'Stayed Retired' 
    END AS season_state,
    partition_year
FROM
  combined