SELECT MAX_BY(player_name, total_points) as player_name,
       MAX_BY(season, total_points) as season,
       max(total_points) as max_total_points
FROM bgar.nba_grouping_sets
WHERE level_id = 'player and season'
