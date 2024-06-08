--The query below adds a state column to the incremental load query for nba_players from the Dimensional Modeling Day 1 lab
--The state column compares the current season year and the most recent season year to determine the state of each player
--The data for the most recent season is the first row of the seasons array, and the season year is the first element of that row, hence the most recent season is seasons[1][1] since arrays in Trino are 1-based
--
--The state field is defined as follows:
--  A player entering the league should be New - occurs when the player has data for this season but not for last season
--  A player leaving the league should be Retired - occurs when the player has data for last season but not for this season, and the most recent season played was last season
--  A player staying in the league should be Continued Playing - occurs when the player has data for last season and for this season, and the most recent season played before this season was last season
--  A player that comes out of retirement should be Returned from Retirement - occurs when the player has data for last season and for this season, and the most recent season played before this season was prior to last season
--  A player that stays out of the league should be Stayed Retired - occurs when the player has data for last season but not for this season, and the most recent season played was prior to last season
--  Any other scenario is given the string ERROR

--This statement could be used to populate the newest partition of nba_players with the added column for state
WITH last_season AS (
    SELECT *
    FROM bootcamp.nba_players
    WHERE current_season = 2001
  ),
  this_season AS (
    SELECT *
    FROM bootcamp.nba_player_seasons
    WHERE season = 2002
  )
SELECT COALESCE(ls.player_name, ts.player_name) AS player_name,
  COALESCE(ls.height, ts.height) AS height,
  COALESCE(ls.college, ts.college) AS college,
  COALESCE(ls.country, ts.country) AS country,
  COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
  COALESCE(ls.draft_round, ts.draft_round) as draft_round,
  COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
  case when ts.season is NULL then ls.seasons
    when ts.season is not null and ls.seasons is null then array[row(ts.season, ts.age, ts.weight, ts.gp, ts.pts, ts.reb, ts.ast)] 
    when ts.season is not null and ls.seasons is not null then array[row(ts.season, ts.age, ts.weight, ts.gp, ts.pts, ts.reb, ts.ast)] || ls.seasons end AS seasons,
  ts.season IS NOT NULL AS is_active,
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
    END AS state
FROM last_season ls
  FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name 