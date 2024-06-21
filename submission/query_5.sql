-- Which team has won the most games
--
SELECT team, total_wins
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'team'
AND total_points IS NOT NULL
AND total_wins IS NOT NULL
ORDER BY total_wins DESC
LIMIT 1