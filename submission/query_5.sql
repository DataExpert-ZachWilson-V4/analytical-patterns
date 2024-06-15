--Team that has won the most games

WITH teams_ranked_by_wins AS
(
SELECT 
  team,
  team_wins,
  DENSE_RANK() OVER(ORDER BY team_wins DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE 
aggregation_level = 'Team' and team_wins is not null
)
SELECT 
  team,
  team_wins
FROM teams_ranked_by_wins WHERE rnk = 1
