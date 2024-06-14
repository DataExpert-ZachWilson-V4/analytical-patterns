--  The state field definition:
--  A player entering the league should be "New" - When the player has data for current season but not for last season
--  A player leaving the league should be "Retired"                  - When player has data for last season but not for current season, and the most recent season played was last season
--  A player that stays out of the league should be "Stayed Retired" - When player has data for last season but not for current season, and the most recent season played was prior to last season
--  A player staying in the league should be "Continued Playing"                - When the player has data for last season and for current season, and the most recent season played was last season
--  A player that comes out of retirement should be "Returned from Retirement"  - When the player has data for last season and for current season, and the most recent season played was prior to last season
--  Any other scenario is represented by NA


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
  COALESCE(ts.season, ls.current_season + 1) AS current_season,
  CASE
	  WHEN ts.season IS NOT NULL AND ls.seasons IS NULL THEN 'New'
	  WHEN ts.season IS NOT NULL AND ls.seasons[1].season = ls.current_season THEN 'Continued Playing'
      WHEN ts.season IS NOT NULL AND ls.seasons[1].season < ls.current_season THEN 'Returned from Retirement'
      WHEN ts.season IS NULL AND ls.seasons[1].season = ls.current_season THEN 'Retired'
      WHEN ts.season IS NULL AND ls.seasons[1].season < ls.current_season THEN 'Stayed Retired'
      ELSE 'NA'
   END AS state
FROM last_season ls
FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name