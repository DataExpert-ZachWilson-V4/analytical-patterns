-- "Which player scored the most points in one season?
SELECT 
	player_name,
	season,
	total_points
FROM nba_game_stats
WHERE grouping_type = 'player_season'
	AND player_name != 'overall'
	AND season != 'overall'
ORDER BY total_points DESC
LIMIT 1

