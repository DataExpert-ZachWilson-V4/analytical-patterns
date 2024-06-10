-- Which team has won the most games?

SELECT team, total_wins
FROM game_details_dashboard
WHERE aggregation_level = 'team'
AND total_wins IS NOT NULL
ORDER BY total_wins DESC
LIMIT 1