SELECT team, won_games
FROM adbeyer.nba_grouped_sets
WHERE aggregation_level = 'team'
ORDER BY won_games DESC
LIMIT 1 --Spurs