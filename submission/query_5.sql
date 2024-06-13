-- query 5 team that has won the most games

SELECT 
    team,
    wins
FROM aayushi.nba_grouping_sets
WHERE 
    agg_data = 'team' AND wins > 0 
ORDER BY wins DESC 
LIMIT 1