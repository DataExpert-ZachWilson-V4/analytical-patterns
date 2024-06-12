-- This query gets the dataset which team has won the most games

SELECT team, won_games
FROM sagararora492.grouping_sets
WHERE aggregation_level = 'team'
ORDER BY won_games DESC