"""
    Which team has won the most games
"""
SELECT team, won_games
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'team'
ORDER BY won_games DESC
LIMIT 1
-- San Antonio Spurs