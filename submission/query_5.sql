WITH team_wins_max AS
(
SELECT 
  *,
  Dense_Rank() OVER(ORDER BY team_wins DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE 
aggregation_level = 'Team'
)
SELECT 
  team,
  team_wins
FROM team_wins_max WHERE rnk = 1
