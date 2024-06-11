-- Select the team and total_wins columns from the game_details_dashboard table
SELECT team, total_wins
FROM game_details_dashboard

-- Filter the results to only include rows where aggregation_level is 'team' and total_wins is not NULL
WHERE aggregation_level = 'team'
AND total_wins IS NOT NULL

-- Sort the results in descending order based on total_wins
ORDER BY total_wins DESC

-- Limit the result set to only the first row
LIMIT 1