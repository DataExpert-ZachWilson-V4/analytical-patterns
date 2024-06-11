
-- De-duplicate the games and get the player details
WITH check_duplicate_games as (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY game_id
			ORDER BY game_date_est DESC
		) as row_num
	FROM bootcamp.nba_games
),
distinct_games as (
	SELECT *
	FROM check_duplicate_games
	WHERE row_num = 1
),
unique_team_data as (

	SELECT DISTINCT team_id, team_abbreviation, game_id 
	FROM bootcamp.nba_game_details_dedup 
),
team_win_details as (
	SELECT
		game_details.team_id,
		game_details.team_abbreviation,
		games.game_date_est,
		CASE WHEN games.home_team_wins = 1 AND game_details.team_id = games.home_team_id THEN 1
			WHEN games.home_team_wins = 0 AND game_details.team_id = games.visitor_team_id THEN 1
			ELSE 0
		END AS team_won
	FROM unique_team_data as game_details JOIN distinct_games as games 
	ON game_details.game_id = games.game_id
),

rolling_window as (
	SELECT 
		team_id,
		team_abbreviation as team,
		game_date_est,
		SUM(team_won) OVER (
			PARTITION BY team_id
			ORDER BY game_date_est
			ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
		) as rolling_wins
	FROM team_win_details
)

SELECT team, MAX(rolling_wins) as max_wins_in_90_game_window
FROM rolling_window
GROUP BY team
ORDER BY max_wins_in_90_game_window DESC
LIMIT 1