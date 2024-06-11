--Solution to query 2 is wrapped in group_table
--To answer which player earned the most points for a single team
--Simply do an order by then limit the results to 1
--Alternatively, we could also use a window function by rank
--and filter only the first entry

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
  ),
group_table AS(
SELECT
  COALESCE(player_name, '(overall)') AS player,
  COALESCE(team_abbreviation, '(overall)') AS team,
  COALESCE(CAST(season AS VARCHAR), '(overall)') AS season,
  SUM(pts) AS sum_pts,
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
)
select player from group_table
where player != '(overall)'
and team != '(overall)'
order by sum_pts desc
limit 1
