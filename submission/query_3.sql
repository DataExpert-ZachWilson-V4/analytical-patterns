SELECT player, team, total_points
FROM adbeyer.nba_grouped_sets
WHERE aggregation_level = 'player_and_team' 
ORDER BY total_points DESC
LIMIT 1 -- Lebron James