

-- creating output table

CREATE OR REPLACE TABLE nancycast01.nba_players_growth_accounting (
player_name VARCHAR,
first_active_season INTEGER,
last_active_season INTEGER,
seasons_active ARRAY(INTEGER),
seasons_active_state VARCHAR,
season INTEGER
)

WITH (
format = 'PARQUET',
partitioning = ARRAY['season']

)

-- inserting data into the table

INSERT INTO nancycast01.nba_players_growth_accounting

WITH last_season AS (

SELECT * FROM nancycast01.nba_players_growth_accounting
WHERE season = 1996

),

current_season AS (

-- we wanna aggregate initially
  SELECT 
  
  player_name,
  COUNT(1) as number_of_seasons,
  MAX(current_season) as active_season,
  MAX(is_active) as is_active
  FROM bootcamp.nba_players
  WHERE current_season = 1997
  GROUP BY player_name

),

combined AS (

SELECT


COALESCE(ls.player_name, cs.player_name) as player_name,
COALESCE(
  ls.first_active_season, 
  (CASE WHEN cs.is_active THEN cs.active_season END) 
)as first_active_season,
COALESCE(
  (CASE WHEN cs.is_active THEN cs.active_season END),
   ls.last_active_season
) AS last_active_season,
cs.is_active,
ls.last_active_season AS ls_last_active_season,
CASE 
  WHEN ls.seasons_active IS NULL THEN ARRAY[cs.active_season]
  WHEN cs.active_season IS NULL THEN ls.seasons_active
  WHEN cs.active_season IS NOT NULL AND cs.is_active THEN ARRAY[cs.active_season] || ls.seasons_active
  ELSE ls.seasons_active
END AS seasons_active,
COALESCE(ls.season + 1, cs.active_season) AS season

FROM last_season ls 
FULL OUTER JOIN current_season cs
ON ls.player_name = cs.player_name

)


SELECT

  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE 
    WHEN is_active AND first_active_season - last_active_season = 0 THEN 'new'
    WHEN is_active AND season - ls_last_active_season = 1 THEN 'Continued Playing'
    WHEN is_active AND season - ls_last_active_season > 1 THEN 'Returned from Retirement'
    WHEN NOT is_active AND season - ls_last_active_season = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END AS season_active_state,
  season
  
  FROM combined



