-- What is the most games a single team has won in a given 90-game stretch?

-- CTE to dedupe and retrieve the games for each team
WITH nba_game_details_deduped AS (
	SELECT DISTINCT
        game_id,
		team_id,
		team_abbreviation
	FROM
        bootcamp.nba_game_details
),
combined AS (
	SELECT
        gd.team_id,
		gd.game_id,
		gd.team_abbreviation,
		g.game_date_est,
        -- Window function to calculate cumulative wins for each team
		SUM(CASE WHEN gd.team_id = g.team_id_home THEN g.home_team_wins ELSE 1 - g.home_team_wins END) OVER (PARTITION BY gd.team_id, gd.team_abbreviation ORDER BY g.game_date_est) AS cumulative_wins
	FROM
        nba_game_details_deduped gd JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
),
cumulated_wins AS (
	SELECT
        team_id,
		game_id,
		team_abbreviation,
		cumulative_wins - (LAG(cumulative_wins, 90, 0) OVER (PARTITION BY team_id, team_abbreviation ORDER BY game_date_est) ) AS rolling_90_day_wins
	FROM
        combined
)
SELECT
    team_abbreviation,
	rolling_90_day_wins
FROM
    cumulated_wins
ORDER BY
    rolling_90_day_wins DESC
LIMIT 1 