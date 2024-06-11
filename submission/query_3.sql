-- "Which player scored the most points playing for a single team?"
SELECT 
	player_name,
	team,
	total_points
FROM nba_game_stats
WHERE season = 'overall'
	AND player_name != 'overall'
	AND team != 'overall'
	AND grouping_type = 'player_team'
ORDER BY total_points DESC
LIMIT 1