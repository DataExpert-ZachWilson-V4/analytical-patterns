--The cumulative_wins column in the team_game_results CTE provides the cumulative wins for each team over the entire data set.
--To get the most wins over any 90-day period, we subtract the cumulative wins as of the current game from the cumulative_wins as
--of the game which occurred 90 games in the past. The maximum of this is the most games a team has won in a 90-game stretch.
--Note this window does cross seasons.
WITH nba_game_details_deduped AS (
	SELECT DISTINCT game_id,
		team_id,
		team_abbreviation
	FROM bootcamp.nba_game_details
), 
nba_games_deduped AS (
	SELECT DISTINCT game_id,
		team_id_home,
		home_team_wins,
		game_date_est
	FROM bootcamp.nba_games
),
team_game_results AS (
	SELECT ngd.team_id,
		ngd.game_id,
		ngd.team_abbreviation,
		game_date_est,
		SUM(CASE WHEN ngd.team_id = ng.team_id_home THEN ng.home_team_wins ELSE 1 - ng.home_team_wins END) OVER (PARTITION BY ngd.team_id, ngd.team_abbreviation ORDER BY ng.game_date_est) AS cumulative_wins
	FROM nba_game_details_deduped ngd
		JOIN nba_games_deduped ng ON ngd.game_id = ng.game_id
), 
cumulated_results AS (
	SELECT team_id,
		game_id,
		team_abbreviation,
		cumulative_wins - (LAG(cumulative_wins, 90, 0) OVER (PARTITION BY team_id, team_abbreviation ORDER BY game_date_est) ) AS rolling_90_day_wins
	FROM team_game_results
)
SELECT team_abbreviation,
	rolling_90_day_wins
FROM cumulated_results
ORDER BY rolling_90_day_wins DESC
LIMIT 1 