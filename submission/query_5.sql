-- Which team has won the most games?
SELECT 
	team,
	season,
	team_wins
	FROM nba_game_stats
WHERE season = 'overall'
	AND player_name = 'overall'
	AND grouping_type = 'team'
ORDER BY team_wins DESC
LIMIT 1