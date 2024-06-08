
WITH games AS (
	SELECT d.game_id, d.team_id, d.team_abbreviation as team, g.game_date_est as game_date, CASE WHEN d.team_id=g.home_team_id AND g.home_team_wins=1 THEN 1 ELSE 0 END as team_won
	FROM bootcamp.nba_game_details d 
	JOIN bootcamp.nba_games g 
	ON d.game_id = g.game_id
),
ranked AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY game_id, team_id, team, game_date, team_won) as ord
	FROM games
),
dedup AS (
	SELECT *
	FROM ranked
	WHERE ord=1
),
rolling_w AS (
	SELECT 
		game_id,
        team_id, 
        team, 
        game_date, 
        SUM(team_won) OVER (PARTITION BY team_id ORDER BY game_date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS rolling_wins
	FROM dedup
),
rolling_ranked AS (
	SELECT team_id, team, rolling_wins, DENSE_RANK() OVER (ORDER BY rolling_wins DESC) as rank_win
	FROM rolling_w
)
SELECT *
FROM rolling_ranked
WHERE rank_win = 1