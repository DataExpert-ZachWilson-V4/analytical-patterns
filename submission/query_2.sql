--CTE query:
--combined: combining nba_game_details_dedup and nba_games to get all columns we need
--SELECT query: performing grouping sets operation (more on individual cols below)

WITH
  combined AS (
    SELECT
      ngd.game_id AS game_id,
      ngd.team_id AS team_id,
      ngd.team_abbreviation AS team_abbreviation,
      ngd.team_city AS team_city,
      ngd.player_id AS player_id,
      ngd.player_name AS player_name,
      ngd.pts AS pts,
  --new column needed to determine whether player's team win or not
      CASE WHEN (
      CASE WHEN 
	ng.home_team_wins = 1 
	THEN ng.home_team_id 
	ELSE ng.visitor_team_id 
	END) = team_id 
	THEN 1 ELSE 0 END AS player_team_win,
      ng.game_date_est AS game_date_est,
      ng.season AS season
    FROM
      bootcamp.nba_game_details_dedup ngd
      JOIN bootcamp.nba_games ng ON ngd.game_id = ng.game_id
  )
SELECT
  --coalescing NULLs produced in grouping sets with (overall)
  COALESCE(player_name, '(overall)') AS player,
  COALESCE(team_abbreviation, '(overall)') AS team,
  COALESCE(CAST(season AS VARCHAR), '(overall)') AS season,
  --only metrics related to q3/4/5 are chosen
  SUM(pts) AS sum_pts,
  --count distinct is only needed since same win per team would be multi-counted otherwise
  count( distinct (case when player_team_win = 1 then game_id end)) AS no_of_game_wins
FROM
  combined
GROUP BY
  GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation),
    ()
  )
