WITH team_games_won AS (
	SELECT
		home_team_id as team_id,
		season,
		SUM(home_team_wins) as games_won
	FROM bootcamp.nba_games
	GROUP BY home_team_id, season	
)

SELECT MAX_BY(team_id,games_won) as team_id
FROM team_games_won