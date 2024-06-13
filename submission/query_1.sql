WITH last_season --previous year player data
AS 
(
    SELECT player_name,
           height,
           college,
           country,
           draft_year,
           draft_round,
           draft_number,
           seasons,
           current_season, 
           years_since_last_active
    FROM bootcamp.nba_players
    WHERE current_season = 1996
),
  this_season --this year player data
  AS (
    SELECT player_name,
           height,
           college,
           country,
           draft_year,
           draft_round,
           draft_number,
           season,
           age,
           weight,
           gp,
           pts,
           reb,
           ast
    FROM bootcamp.nba_player_seasons
    WHERE season = 1997
  )
  
-- combine previous and current year data to find the player state
SELECT 
  COALESCE(ls.player_name, ts.player_name) as player_name,
  COALESCE(ls.height, ts.height) AS height,
  COALESCE(ls.college, ts.college) AS college,
  COALESCE(ls.country, ts.country) AS country,
  COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
  COALESCE(ls.draft_round, ts.draft_round) as draft_round,
  COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
  case when ts.season is null then ls.seasons
       when ts.season is not null and ls.seasons is null then ARRAY[ROW(ts.season, ts.age,ts.weight, ts.gp,ts.pts,ts.reb,ts.ast)]
       else ARRAY[ROW(ts.season, ts.age,ts.weight, ts.gp,ts.pts,ts.reb,ts.ast)] || ls.seasons end as seasons, --step to insert seasons array data
  ts.season IS NOT NULL AS is_active, -- is active check
  CASE
    WHEN ts.season IS NOT NULL THEN 0
    ELSE years_since_last_active + 1
  END AS years_since_last_active,
  COALESCE(ts.season, ls.current_season + 1) AS current_season,
  CASE WHEN ls.seasons IS NULL AND ts.season IS NOT NULL THEN 'New'
      WHEN ts.season IS NULL AND ls.seasons[1][1] = ls.current_season THEN 'Retired'
      WHEN ts.season IS NULL AND ls.seasons[1][1] < ls.current_season THEN 'Stayed Retired'
      WHEN ts.season IS NOT NULL AND ls.seasons[1][1] = ls.current_season THEN 'Continued Playing'
      WHEN ts.season IS NOT NULL AND ls.seasons[1][1] < ls.current_season THEN 'Returned from Retirement' 
      ELSE 'ERROR'
    END AS state -- based on season data we determine the player state
FROM last_season ls
FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name 
